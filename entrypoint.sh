#!/bin/bash
set -e
if [ -f /opt/Xilinx/14.7/ISE_DS/settings64.sh ]; then
  # shellcheck disable=SC1091
  source /opt/Xilinx/14.7/ISE_DS/settings64.sh
fi
export PATH="/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64:${PATH}"
exec "$@"
