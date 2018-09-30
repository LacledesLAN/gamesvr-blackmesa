# Black Mesa Dedicated Server in Docker

Black Mesa (originally Black Mesa: Source) is a third-party remake of Half-Life. The core gameplay remains unchanged from the original Half-Life; the player can carry a number of weapons that they find through the course of the game, though they must also locate ammunition for most weapons. Fight with or against your friends, in two game modes across 10 iconic maps from the Half-Life universe including Bounce, Gasworks, Stalkyard, Undertow and Crossfire!

![Black Mesa Box Art](https://raw.githubusercontent.com/LacledesLAN/gamesvr-blackmesa/master/.misc/boxart.jpg "Black Mesa Box Art")

This repository is maintained by [Laclede's LAN](https://lacledeslan.com). Its contents are intended to be bare-bones and used as a stock server. For examples of building a customized server from this Docker image browse its related child-project [gamesvr-blackmesa-freeplay](https://github.com/LacledesLAN/gamesvr-blackmesa-freeplay). If any documentation is unclear or it has any issues please see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Linux
[![](https://images.microbadger.com/badges/version/lacledeslan/gamesvr-blackmesa.svg)](https://microbadger.com/images/lacledeslan/gamesvr-blackmesa "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/lacledeslan/gamesvr-blackmesa.svg)](https://microbadger.com/images/lacledeslan/gamesvr-blackmesa "Get your own image badge on microbadger.com")

### Download
```
docker pull lacledeslan/gamesvr-blackmesa;
```

### Run Self Tests
The image includes a test script that can be used to verify its contents. No changes or pull-requests will be accepted to this repository if any tests fail.

```
docker run -it --rm lacledeslan/gamesvr-blackmesa ./ll-tests/gamesvr-blackmesa.sh;
```

### Run Interactive Server
```
docker run -it --rm --net=host lacledeslan/gamesvr-blackmesa ./srcds_run -game bms +map gasworks +sv_lan 1 +maxplayers 16
```

## Getting Started with Game Servers in Docker

[Docker](https://docs.docker.com/) is an open-source project that bundles applications into lightweight, portable, self-sufficient containers. For a crash course on running Dockerized game servers check out [Using Docker for Game Servers](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/DockerAndGameServers.md). For tips, tricks, and recommended tools for working with Laclede's LAN Dockerized game server repos see the guide for [Working with our Game Server Repos](https://github.com/LacledesLAN/README.1ST/blob/master/GameServers/WorkingWithOurRepos.md). You can also browse all of our other Dockerized game servers: [Laclede's LAN Game Servers Directory](https://github.com/LacledesLAN/README.1ST/tree/master/GameServers).
