FROM lacledeslan/steamcmd:linux AS blackmesa-builder

ARG SKIP_STEAMCMD=false

# Copy in local cache files (if any)
COPY ./.steamcmd/linux /output

# Download Blackmesa via SteamCMD
RUN if [ "$SKIP_STEAMCMD" = true ] ; then \
        echo "\n\nSkipping SteamCMD install -- using only contents from steamcmd\n\n"; \
    else \
        echo "\n\nDownloading Blackmesa via SteamCMD"; \
        mkdir --parents /output; \
        /app/steamcmd.sh +force_install_dir /output +login anonymous +app_update 346680 validate +quit; \
    fi;

#=======================================================================
FROM debian:bookworm-slim

ARG BUILD_NODE=unspecified
ARG GIT_REVISION=unspecified

LABEL architecture="i386" \
    com.lacledeslan.build-node="$BUILD_NODE" \
    maintainer="Laclede's LAN <contact@lacledeslan.com>" \
    org.opencontainers.image.description="Black Mesa Dedicated Server" \
    org.opencontainers.image.revision="$GIT_REVISION" \
    org.opencontainers.image.source="https://github.com/LacledesLAN/gamesvr-blackmesa" \
    org.opencontainers.image.vendor="Laclede's LAN"

HEALTHCHECK NONE

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
        ca-certificates lib32gcc-s1 libtinfo5:i386 libstdc++6:i386 locales locales-all tmux && \
    apt-get clean && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Set up Enviornment
RUN useradd --home /app --gid root --system BlackMesa && \
    mkdir -p /app/ll-tests && \
    chown BlackMesa:root -R /app;

# `RUN true` lines are work around for https://github.com/moby/moby/issues/36573
COPY --chown=BlackMesa:root --from=blackmesa-builder /output /app
RUN true

COPY --chown=BlackMesa:root ./dist/linux/ll-tests /app/ll-tests
RUN chmod +x /app/ll-tests/*.sh;

USER BlackMesa

RUN echo $'\n\nLinking steamclient.so to prevent srcds_run errors' && \
        mkdir -p /app/.steam/sdk32 && \
        ln -s /app/bin/steamclient.so /app/.steam/sdk32/steamclient.so;

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
