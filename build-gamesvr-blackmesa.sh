#!/bin/bash
set -e;
set -o pipefail;
set -u;

exec 3>&1
exec 1>&2

printf '## Build gamesvr-blackmesa\n\n'

created_image_tags=()
command_fence_open=false

record_image_tag() {
    local image_tag="$1"
    local existing_tag

    for existing_tag in "${created_image_tags[@]+"${created_image_tags[@]}"}"; do
        [[ "$existing_tag" == "$image_tag" ]] && return 0
    done
    created_image_tags+=("$image_tag")
}

run_fenced() {
    local command_status=0
    local escape_character=$'\033'

    printf '````````console\n'
    command_fence_open=true
    if "$@" 2>&1 | tr '\r' '\n' | sed -E "s/${escape_character}\\[[0-9;?]*[[:alpha:]]//g"; then
        command_status=${PIPESTATUS[0]}
    else
        command_status=${PIPESTATUS[0]}
    fi
    command_fence_open=false
    printf '````````\n\n'
    return "$command_status"
}

on_exit() {
    local exit_status=$?

    trap - EXIT HUP INT TERM PIPE
    trap '' HUP INT TERM PIPE
    set +e
    if [[ "$command_fence_open" == true ]]; then
        printf '````````\n\n'
        command_fence_open=false
    fi
    if (( ${#created_image_tags[@]} > 0 )); then
        printf '\n### Completed images\n\n' >&2
    fi
    exec 1>&3
    if (( ${#created_image_tags[@]} > 0 )); then
        printf '%s\n' "${created_image_tags[@]}" 2>/dev/null || true
    fi
    exit "$exit_status"
}

trap on_exit EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM


####################################################################################################
## Options
####################################################################################################

build_options=()

# Parse command line options
while [ "$#" -gt 0 ]
do
	case "$1" in
        --delta) build_options+=('--delta') ;;
        --enable-steamcmd-cache) build_options+=('--enable-steamcmd-cache') ;;
        --disable-docker-cache) build_options+=('--disable-docker-cache') ;;
        --progress-plain) build_options+=('--progress-plain') ;;
        --skip-pull) build_options+=('--skip-pull') ;;
        --skip-tests) build_options+=('--skip-tests') ;;
        --skip-push) build_options+=('--skip-push') ;;
		# unknown
		*)
			echo "Error: unknown option '${1}'. Exiting." >&2;
			exit 12;
			;;
	esac
	shift
done;

# DESCRIPTION: Reports whether a common build option was specified.
# PARAMETERS:
#   $1 (option_name) - Canonical command-line option to find in build_options.
# RETURNS:
#   0 - The option is present.
#   1 - The option is absent.
has_build_option() {
    local element
    for element in "${build_options[@]}"; do
        [[ "$element" == "$1" ]] && return 0
    done
    return 1
}

required_commands=(date docker git hostname sed tr)
for required_command in "${required_commands[@]}"; do
    if ! command -v "$required_command" > /dev/null 2>&1; then
        printf "ERROR: Required command '%s' is not installed or not in PATH.\n" "$required_command" >&2
        exit 1
    fi
done
if ! docker info > /dev/null 2>&1; then
    printf "ERROR: Docker is installed, but the current user cannot access the Docker daemon.\n" >&2
    exit 1
fi
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    printf "ERROR: The current directory is not a Git repository.\n" >&2
    exit 1
fi

if has_build_option '--enable-steamcmd-cache'; then
    echo "--enable-steamcmd-cache has no effect for this project."
fi
if has_build_option '--skip-tests' && ! has_build_option '--skip-push'; then
    echo "WARNING: --skip-tests was specified without --skip-push. The requested images will be pushed without testing." >&2
fi
if has_build_option '--delta' && has_build_option '--disable-docker-cache'; then
    echo "--disable-docker-cache has no effect for this delta invocation because it performs no Docker build."
fi
if has_build_option '--delta' && has_build_option '--progress-plain'; then
    echo "--progress-plain has no Docker build progress to change for this delta invocation."
fi
if ! has_build_option '--skip-tests' && [[ ! -x ./test-gamesvr-blackmesa.sh ]]; then
    echo "ERROR: Required test script is missing or not executable: ./test-gamesvr-blackmesa.sh" >&2
    exit 1
fi


####################################################################################################
## Helper Functions
####################################################################################################

####################################################################################################
## Build
####################################################################################################

if ! has_build_option '--delta'; then
    #
    # Full Update
    #

    printf '### Build full image\n\n'
    docker_options=()
    if ! has_build_option '--skip-pull'; then
        docker_options+=(--pull)
    else
        echo "Skipping pulls because --skip-pull was specified."
    fi
    if has_build_option '--disable-docker-cache'; then
        docker_options+=(--no-cache)
    fi
    if has_build_option '--progress-plain'; then
        docker_options+=(--progress=plain)
    fi
    build_node="$(hostname)"
    git_revision="$(git rev-parse HEAD)"
    if [[ -n $(git status --porcelain) ]]; then
        git_revision+="-dirty"
    fi
    run_fenced docker build . "${docker_options[@]}" -f linux.Dockerfile --rm -t gamesvr-blackmesa:latest --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" --build-arg BUILD_NODE="$build_node" --build-arg GIT_REVISION="$git_revision";
    record_image_tag gamesvr-blackmesa:latest
else
    #
    # Delta Update
    #

    printf '### Prepare SteamCMD\n\n'
    # to bad `--volumes-from` doesn't support path aliasing ヽ(ಠ_ಠ)ノ
    docker container rm LLSteamCMD-Extractor &>/dev/null || true
    run_fenced docker create --name LLSteamCMD-Extractor lacledeslan/steamcmd:latest;
    run_fenced docker cp LLSteamCMD-Extractor:/app "$(pwd)/.steamcmd/linux";
    run_fenced docker container rm LLSteamCMD-Extractor;


    printf '### Build delta container\n\n'
    if ! has_build_option '--skip-pull'; then
        run_fenced docker pull lacledeslan/gamesvr-blackmesa:base
    else
        echo "Skipping explicit parent pull because --skip-pull was specified."
    fi
    docker container rm LL-BLACKMESA-DELTA-CAPTURE &>/dev/null || true
    run_fenced docker run -it --name LL-BLACKMESA-DELTA-CAPTURE \
        --mount type=bind,source="$(pwd)"/.steamcmd/linux/app/,target=/steamcmd/ \
        lacledeslan/gamesvr-blackmesa \
        /steamcmd/steamcmd.sh +login anonymous +force_install_dir /app +app_update 346680 +quit


    printf '### Commit delta image\n\n'
    run_fenced docker commit --change='CMD ["/bin/bash"]' --message="Content delta update $(date '+%d/%m/%Y %H:%M:%S')" "$(docker ps -aqf "name=LL-BLACKMESA-DELTA-CAPTURE")" gamesvr-blackmesa:latest
    record_image_tag gamesvr-blackmesa:latest
    run_fenced docker container rm LL-BLACKMESA-DELTA-CAPTURE
fi;


if ! has_build_option '--skip-tests'; then
    printf '### Tests\n\n'
    run_fenced ./test-gamesvr-blackmesa.sh gamesvr-blackmesa:latest;
else
    echo "Skipping tests because --skip-tests was specified."
fi


printf '### Publish tags\n\n'
run_fenced docker tag gamesvr-blackmesa:latest lacledeslan/gamesvr-blackmesa:latest;
record_image_tag lacledeslan/gamesvr-blackmesa:latest

if ! has_build_option '--delta'; then
    #
    # Full Update
    #

    run_fenced docker tag lacledeslan/gamesvr-blackmesa:latest lacledeslan/gamesvr-blackmesa:base
    record_image_tag lacledeslan/gamesvr-blackmesa:base
    if ! has_build_option '--skip-push'; then
        echo "> push lacledeslan/gamesvr-blackmesa:base"
        run_fenced docker push lacledeslan/gamesvr-blackmesa:base
        echo "> push lacledeslan/gamesvr-blackmesa:latest"
        run_fenced docker push lacledeslan/gamesvr-blackmesa:latest
    else
        echo "Skipping pushes because --skip-push was specified."
    fi
else
    #
    # Delta Update
    #

    if ! has_build_option '--skip-push'; then
        echo "> push lacledeslan/gamesvr-blackmesa:latest"
        run_fenced docker push lacledeslan/gamesvr-blackmesa:latest
    else
        echo "Skipping pushes because --skip-push was specified."
    fi
fi;
