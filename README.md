# Black Mesa Dedicated Server in Docker

## Linux
[![](https://images.microbadger.com/badges/version/lacledeslan/gamesvr-blackmesa.svg)](https://microbadger.com/images/lacledeslan/gamesvr-blackmesa "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/lacledeslan/gamesvr-blackmesa.svg)](https://microbadger.com/images/lacledeslan/gamesvr-blackmesa "Get your own image badge on microbadger.com")

**Download**
```
docker pull lacledeslan/gamesvr-blackmesa;
```

**Run Self Tests**
```
docker run -it --rm lacledeslan/gamesvr-blackmesa ./ll-tests/gamesvr-blackmesa.sh;
```

**Run Interactive Server**
```
docker run -it --rm --net=host lacledeslan/gamesvr-blackmesa ./srcds_run -game bms +map gasworks +sv_lan 1 +maxplayers 16
```
