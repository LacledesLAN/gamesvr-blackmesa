# Black Mesa Server in Docker

## Linux
[![](https://images.microbadger.com/badges/version/lacledeslan/gamesvr-blackmesa.svg)](https://microbadger.com/images/lacledeslan/gamesvr-blackmesa "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/lacledeslan/gamesvr-blackmesa.svg)](https://microbadger.com/images/lacledeslan/gamesvr-blackmesa "Get your own image badge on microbadger.com")

**Download**
```
docker pull lacledeslan/gamesvr-blackmesa
```

**Run self tests**
```
docker run -it --rm lacledeslan/gamesvr-blackmesa ./ll-tests/gamesvr-blackmesa.sh
```

**Run simple interactive server**
```
docker run -it --rm --net=host lacledeslan/gamesvr-blackmesa ./srcds_run -game bms +map gasworks +sv_lan 1 -console -usercon  +maxplayers 16
```

# Build Triggers
Automated builds of this image can be triggered by the following sources:
* [Builds of llgameserverbot/blackmesa-watcher](https://hub.docker.com/r/llgameserverbot/blackmesa-watcher/)
* [Commits on GitHub repository](https://github.com/LacledesLAN/gamesvr-srcds-blackmesa)
