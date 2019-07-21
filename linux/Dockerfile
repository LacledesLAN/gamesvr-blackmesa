# escape=`
FROM lacledeslan/steamcmd:linux as blackmesa-builder

#=======================================================================
FROM debian:stretch-slim

ARG BUILDNODE=unspecified
ARG SKIP_STEAMCMD=false
ARG SOURCE_COMMIT=unspecified

HEALTHCHECK NONE

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        ca-certificates lib32gcc1 lib32tinfo5 libstdc++6 libstdc++6:i386 locales locales-all tmux &&`
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

## Black Mesa is so large we can't reliably use multi-stage builds in docker cloud
COPY --chown=BlackMesa:root ./steamcmd-cache /app
COPY --chown=BlackMesa:root --from=blackmesa-builder /app /app/steamcmd
COPY --chown=BlackMesa:root ./ll-tests /app/ll-tests

RUN chmod +x /app/ll-tests/*.sh;

USER BlackMesa

# Download Black Mesa Source via SteamCMD
RUN if [ "$SKIP_STEAMCMD" = true ] ; then `
        echo "\n\nSkipping SteamCMD install -- using only contents from steamcmd-cache\n\n"; `
    else `
        echo "\n\nDownloading  Black Mesa Source via SteamCMD"; `
        /app/steamcmd/steamcmd.sh `
            +login anonymous `
            +force_install_dir /app `
            +app_update 346680 validate `
            +quit; `
    fi;

RUN echo $'\n\nLinking steamclient.so to prevent srcds_run errors' &&`
        mkdir -p /app/.steam/sdk32 &&`
        ln -s /app/bin/steamclient.so /app/.steam/sdk32/steamclient.so;

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
