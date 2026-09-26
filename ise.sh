#!/bin/bash
xhost +local:docker
docker run --rm -it \
  -e DISPLAY="$DISPLAY" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "$HOME/.ise-home:/root" \
  -v "$HOME/.Xilinx:/root/.Xilinx" \
  -v "$PWD:/work" \
  -e XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic \
  --net host \
  ise:14.7-u2204 ise
