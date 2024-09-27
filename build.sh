#/bin/bash
cd `dirname $BASH_SOURCE`

IT=$(cd $(dirname $BASH_SOURCE); pwd)
export CROSS_COMPILE="ccache $IT/toolchain/arm-cortex_a7-linux-gnueabihf-linaro_4.9/bin/arm-cortex_a7-linux-gnueabihf-"
export KCFLAGS="-pipe -mtune=cortex-a7 -march=armv7-a -mfpu=neon-vfpv4"
export MTK_ROOT_CUSTOM="$IT/mediatek/custom/"

cd kernel
bash -e build.sh lenovo89_tb_x10_jb2
