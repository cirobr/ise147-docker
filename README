# Xilinx ISE 14.7 on Docker

Builds an image of the Xilinx ISE 14.7 on top of Ubuntu 22.04.

Remark: instructions for programming a MIMAS V2 Spartan6 FPGA board, which requires ISE 14.7, are available at the end of this file.

## Folder structure

```
ise147-docker
    Dockerfile
    entrypoint.sh
    install_config.txt
    README   # this file
    Xilinx_ISE_DS_Lin_14.7_1015_1.tar   # official Xilinx ISE package, not included here
```

## Build commands

```
docker pull ubuntu:22.04
docker build --progress=plain -t ise:14.7-u2204 .
```

The extract + `batchxsetup` layer can take 20–60+ minutes. Do not interrupt it.

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

### Recommended: official Numato Python tool (stock PIC firmware)

Repo: https://github.com/numato/samplecode  
Path: `FPGA/MimasV2/tools/configuration/python/`

```
pip install 'git+https://github.com/numato/samplecode/#egg=MimasV2&subdirectory=FPGA/MimasV2/tools/configuration/python/'
python -m MimasV2.Config /dev/ttyACM0 design.bin
```

Board documentation: https://numato.com/docs/mimas-v2-spartan-6-fpga-development-board-with-ddr-sdram/

### Optional: faster Linux firmware (two serial ports)

These replace the factory PIC firmware. Only needed if you want a dedicated programmer port plus FPGA UART at 115200 without using the mode switch.

- Firmware + `programmer.py`: https://github.com/jimmo/numato-mimasv2-pic-firmware
- Packaged loader (`mimasv2-prog`): https://github.com/toptensoftware/MimasV2-Loader

```
git clone https://github.com/jimmo/numato-mimasv2-pic-firmware.git
cd numato-mimasv2-pic-firmware
python3 -m venv venv && . venv/bin/activate
pip install pyserial xmodem
python3 programmer.py --filename /path/to/design.bin
```

Or:

```
git clone https://github.com/toptensoftware/MimasV2-Loader.git
cd MimasV2-Loader
sudo ./install.sh
mimasv2-prog --filename design.bin
```

If `lsusb` shows `04d8:003c`, the FWUP jumper is fitted and the PIC is in HID bootloader mode. That is only for updating PIC firmware with `mphidflash`, not for loading an FPGA bitstream.
