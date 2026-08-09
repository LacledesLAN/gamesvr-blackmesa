FROM lacledeslan/steamcmd:linux AS blackmesa-builder

ARG ENABLE_STEAMCMD_CACHE=false

WORKDIR /output

# Download Blackmesa via SteamCMD
RUN --mount=type=cache,id=blackmesa-steamcmd-cache,target=/mnt/steam-cache \
    echo "Downloading/Updating Black Mesa Dedicated Server via SteamCMD..." && \
    if [ "$ENABLE_STEAMCMD_CACHE" = "true" ]; then \
        INSTALL_DIR="/mnt/steam-cache"; \
    else \
        INSTALL_DIR="/output"; \
    fi && \
    # Run SteamCMD
    /app/steamcmd.sh \
        +force_install_dir "$INSTALL_DIR" \
        +login anonymous \
        +app_update 346680 validate \
        +quit && \
    # Only perform the sync step if the user explicitly opted into the cache
    if [ "$ENABLE_STEAMCMD_CACHE" = "true" ]; then \
        cp -r "$INSTALL_DIR"/. /output/; \
    fi


#---------------------------------
FROM debian:trixie-slim

ARG BUILD_DATE=unspecified \
    BUILD_NODE=unspecified \
    GIT_REVISION=unspecified

HEALTHCHECK NONE

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

LABEL architecture="i386" \
      com.lacledeslan.build-node="${BUILD_NODE}" \
      maintainer="Laclede's LAN <contact@lacledeslan.com>" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.description="Black Mesa Dedicated Server" \
      org.opencontainers.image.revision="${GIT_REVISION}" \
      org.opencontainers.image.source="https://github.com/LacledesLAN/gamesvr-blackmesa" \
      org.opencontainers.image.vendor="Laclede's LAN"

# The Blackmesa server benefits from libtinfo.so.5, which is not available in Debian 12+ (Bookworm).
COPY ./dist/libtinfo.5_6.4.4/i386/lib/i386-linux-gnu/libtinfo.so.5.9 /lib/i386-linux-gnu/libtinfo.so.5

RUN dpkg --add-architecture i386 && \
    apt-get update && \
        apt-get install -y --no-install-recommends --no-install-suggests --no-upgrade \
            ca-certificates libsdl2-2.0-0:i386 libstdc++6:i386 && \
        apt-get clean && \
        rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    # Symlink the Steam client library to prevent srcds_run errors
    mkdir -p /app/.steam/sdk32/ && \
        ln -s /app/bin/steamclient.so /app/.steam/sdk32/steamclient.so && \
        test -L /app/.steam/sdk32/steamclient.so &&\
    # Update username, home directory, and permissions for the BlackMesa user
    useradd --home /app --gid root --system BlackMesa && \
        chown BlackMesa:root -R /app;

COPY --chown=BlackMesa:root --from=blackmesa-builder /output /app

USER BlackMesa

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
