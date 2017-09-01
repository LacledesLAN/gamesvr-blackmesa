# escape=`

FROM lacledeslan/steamcmd:linux as blackmesa-builder

#=======================================================================
FROM debian:stretch-slim

HEALTHCHECK NONE

ARG BUILDNODE="unspecified"
ARG SOURCE_COMMIT

LABEL maintainer="Laclede's LAN <contact @lacledeslan.com>" `
      com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="Black Mesa in Docker" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-blackmesa"

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        ca-certificates lib32gcc1 lib32tinfo5 libcurl3-gnutls libncurses5 libstdc++6 libstdc++6:i386 libz1 &&`
    apt-get clean &&`
    rm -rf /var/lib/apt/lists/*;

## Black Mesa is so large we can't reliably use multi-stage builds in docker cloud

# Copy cached build files (if any)
COPY ./build-cache /app

#Pull in SteamCMD
COPY --from=blackmesa-builder /app /app/steamcmd

# Install Black Mesa using SteamCMD
RUN echo $'\n\nDownloading Black Mesa via SteamCMD' &&`
        /app/steamcmd/steamcmd.sh `
            +login anonymous `
            +force_install_dir /app `
            +app_update 346680 validate `
            +quit;

RUN echo $'\n\nLinking steamclient.so to prevent srcds_run errors' &&`
        mkdir --parents /app/.steam/sdk32 &&`
        ln -s /app/bin/steamclient.so /app/.steam/sdk32/steamclient.so

## Add in tests
COPY ./tests /app/ll-tests

RUN echo $'\n\nCreating user "BlackMesa" (to group "root" until [github.com/moby/moby/pull/34263] makes it into CE stable)' &&`
        useradd --home /app --gid root --system `
            BlackMesa &&`
    echo 'Setting user directory permissions' &&`
        chown BlackMesa:root /app &&`
        find /app -type d -exec chmod 775 {} + &&`
        chmod +x /app/ll-tests/*.sh

# Intentionally set after all build steps
USER BlackMesa

WORKDIR /app

ONBUILD USER root
