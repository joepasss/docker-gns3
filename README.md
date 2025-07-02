## joepasss/docker-gns3

docker gns3-server

[GNS3/gns3-server](https://github.com/GNS3/gns3-server)

[joepasss/gns3-server dockerhub](https://hub.docker.com/repository/docker/joepasss/gns3-server)

---

## Usage

### how to build?

* git clone
    * `git clone https://github.com/joepasss/docker-gns3.git`
* use `docker_build.sh` script
* or in terminal

``` bash
cd docker-gns3

# build docker image
docker build -t gns3:local .

# run docker image
docker run \
    -it \
    --name gns3 \
    -e BRIDGE_ADDRESS="172.21.1.1/24" \
    -v "path/to/data/directory:/data" \
    gns3:local
```

### pull from docker hub

``` bash
docker run \
    --rm -d \
    --name gns3 \
    --net=host --privileged \
    -e BRIDGE_ADDRESS="172.21.1.1/24" \
    -v <data path>:/data \
    joepasss/gns3-server:latest
```

---

### IOURC generator

``` bash
# check container name
docker ps

# run container interactive mode
docker exec -it <continer name> /bin/bash

# in docker container interactive mode
python3 /CiscoIOUKeygen3f.py
```

after you generate IOURC key, go to you gns3 client copy & paste generated key

---

### ARM64 MAC IOU

Due to IOU is 32bit binary file, you need QEMU emulation for 32 bit binary

``` bash
docker run \
    --rm -d \
    --platform linux/amd64 \
    --name gns3 \
    --net=host --privileged \
    -e BRIDGE_ADDRESS="172.21.1.1./24" \
    -v <data path>:/data \
    joepasss/gns3-server:latest
```

---

### parameters

* `-v /data`
    * path to persistant data
* `-e BRIDGE_ADDRESS="172.21.1.1/24`
    * Configure the internal NAT network bridge for GNS3
