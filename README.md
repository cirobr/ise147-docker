# Xilinx ISE 14.7 on Docker

Builds an image of the Xilinx ISE 14.7 FPGA programmer on top of Ubuntu 22.04.

Instructions for programming a MIMAS V2 Spartan6 FPGA board, which requires ISE 14.7, are available at the end of this file.

**IMPORTANT**: the built image contains AMD/Xilinx software and MUST NOT be published or shared.

## Folder structure

```
ise147-docker
    Dockerfile
    entrypoint.sh
    install_config.txt
    README.md   # this file
    Xilinx_ISE_DS_Lin_14.7_1015_1.tar   # official Xilinx ISE package, not included here
```

The official ISE package can be downloaded from:
https://www.amd.com/pt/support/downloads/adaptive-socs-and-fpgas/legacy-ise/v2012_4---14_7.html

## Build commands

```
docker pull ubuntu:22.04
docker build --progress=plain -t ise:14.7-u2204 .
```

The extract + `batchxsetup` layer can take 60+ minutes. Do not interrupt it.

## Execution

CLI tools (`xst`, `ngdbuild`, `map`, `par`, `bitgen`, `xtclsh`):

```
docker run --rm -it \
  -v "$PWD:/work" \
  -v "$HOME/.Xilinx:/root/.Xilinx:ro" \
  -e XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic \
  ise:14.7-u2204 bash
```

GUI (Project Navigator) on a Linux host with X11:

```
xhost +local:docker
docker run --rm -it \
  -e DISPLAY="$DISPLAY" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "$HOME/.Xilinx:/root/.Xilinx" \
  -v "$PWD:/work" \
  -e XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic \
  --net host \
  ise:14.7-u2204 ise
```

Generate a Mimas V2 bitstream as `.bin` (not `.bit`):

- ISE GUI: Generate Programming File → properties → enable **Create Binary Configuration File**
- CLI, after place-and-route:

```
bitgen -w -g Binary:Yes design.ncd
```

## Programming the Numato Mimas V2 from Linux

The board is programmed over USB-CDC into the SPI flash. Use the `.bin` produced by ISE. Programming is simpler on the **host** than inside the ISE container.

Add your user to `dialout`, then log out and back in:

```
sudo usermod -aG dialout "$USER"
```

Confirm the board:

```
lsusb
ls /dev/ttyACM*
```

Stock Numato firmware usually appears as `2a19:1002` and `/dev/ttyACM0`. Set the board CFG switch to USB/config mode before flashing.

### Recommended: official Numato Python tool

Repo: https://github.com/numato/samplecode  
Path: `FPGA/MimasV2/tools/configuration/python/`

```
pip install 'git+https://github.com/numato/samplecode/#egg=MimasV2&subdirectory=FPGA/MimasV2/tools/configuration/python/'
```

```
python -m MimasV2.Config /dev/ttyACM0 design.bin
```

Board documentation: https://numato.com/docs/mimas-v2-spartan-6-fpga-development-board-with-ddr-sdram/
