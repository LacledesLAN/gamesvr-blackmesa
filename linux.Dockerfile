# escape=`
FROM lacledeslan/steamcmd:linux as blackmesa-builder

ARG SKIP_STEAMCMD=false

# Copy in local cache files (if any)
COPY ./.steamcmd/linux /output

# Download Blackmesa via SteamCMD
RUN if [ "$SKIP_STEAMCMD" = true ] ; then `
        echo "\n\nSkipping SteamCMD install -- using only contents from steamcmd\n\n"; `
    else `
        echo "\n\nDownloading Blackmesa via SteamCMD"; `
        mkdir --parents /output; `
        /app/steamcmd.sh +login anonymous +force_install_dir /output +app_update 346680 validate +quit; `
    fi;

#=======================================================================
FROM debian:buster-slim

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

HEALTHCHECK NONE

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        ca-certificates lib32gcc1 libtinfo5:i386 libstdc++6:i386 locales locales-all tmux &&`
    apt-get clean &&`
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment &&`
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

LABEL maintainer="Laclede's LAN <contact @lacledeslan.com>" `
      com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="Black Mesa Dedicated Server" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-blackmesa"

# Set up Enviornment
RUN useradd --home /app --gid root --system BlackMesa &&`
    mkdir -p /app/ll-tests &&`
    chown BlackMesa:root -R /app;

# `RUN true` lines are work around for https://github.com/moby/moby/issues/36573
COPY --chown=BlackMesa:root --from=blackmesa-builder /output /app
RUN true

COPY --chown=BlackMesa:root ./dist/linux/ll-tests /app/ll-tests
RUN chmod +x /app/ll-tests/*.sh;

USER BlackMesa

RUN echo $'\n\nLinking steamclient.so to prevent srcds_run errors' &&`
        mkdir -p /app/.steam/sdk32 &&`
        ln -s /app/bin/steamclient.so /app/.steam/sdk32/steamclient.so;

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
