# Orion, mintaka restart and mongodb is not live

```console
cd /ramp-iiot-data-platform
./service stop
docker run --privileged --rm tonistiigi/binfmt --install all
./service start
 ```
 