#/bin/bash
set -e

cd `dirname $BASH_SOURCE`

IT=$(cd $(dirname $BASH_SOURCE); pwd)
export CROSS_COMPILE="ccache $IT/toolchain/arm-cortex_a7-linux-gnueabihf-linaro_4.9/bin/arm-cortex_a7-linux-gnueabihf-"
export KCFLAGS="-pipe -mtune=cortex-a7 -march=armv7-a -mfpu=neon-vfpv4"
export MTK_ROOT_CUSTOM="$IT/mediatek/custom/"

cd kernel
bash -e build.sh lenovo89_tb_x10_jb2

echo "**** Successfully built kernel ****"

echo "**** Copying kernel to /build_result/kernel/ ****"
mkdir -p ./build_result/kernel/
cp ./kernel/arch/arm/boot/zImage ./build_result/kernel/boot.img-kernel

echo "**** Copying all built modules (.ko) to /build_result/modules/ ****"
mkdir -p ./build_result/modules/
for file in $(find ./kernel -name *.ko); do
 cp $file ./build_result/modules/
done

echo "**** Patching all built modules (.ko) in /build_result/modules/ ****"
find ./build_result/modules/ -type f -name '*.ko' | xargs -n 1 ${CROSS_COMPILE}strip --strip-unneeded
echo "**** Finnish ****"

#echo "**** You can find kernelFile in root folder: /build_result/kernel/ ****"
echo "**** You can find zImage in root folder: /build_result/kernel/ ****"
echo "**** You can find all modules in root folder: /build_result/modules/ ****"
#echo "**** Rename the kernelFile to zImage and repack with stock RamDisk ****"
echo "**** Now grab the zImage and repack with stock RamDisk ****"

echo "**** Packing build result ****"
tar zcvf build_result.tar.gz ./build_result
echo "**** build_result.tar.gz has been created ****"
