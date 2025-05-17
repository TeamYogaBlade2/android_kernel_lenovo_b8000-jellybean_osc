#/bin/bash
set -e

rm -rf ./build_result

cd `dirname $BASH_SOURCE`

IT=$(cd $(dirname $BASH_SOURCE); pwd)
curdir=$(cd $(dirname $0) && pwd)/kernel

export CROSS_COMPILE="$IT/toolchain/arm-cortex_a7-linux-gnueabihf-linaro_4.9/bin/arm-cortex_a7-linux-gnueabihf-"
export MTK_ROOT_CUSTOM="$IT/mediatek/custom/"
export TARGET_PRODUCT=lenovo89_tb_x10_jb2

. ./mediatek/build/shell.sh . kernel

#export KBUILD_OUTPUT_SUPPORT="yes"

if [ "${KBUILD_OUTPUT_SUPPORT}" == "yes" ];then
  #outdir=$curdir/out
  outdir=$curdir/out # hack
  mkdir -p $outdir
fi

cd kernel
make $MAKEJOBS
cd ..

echo "**** Successfully built kernel ****"

mkimg="${MTK_ROOT_BUILD}/tools/mkimage"
if [ "${KBUILD_OUTPUT_SUPPORT}" == "yes" ]; then
  kernel_img="${outdir}/arch/arm/boot/Image"
  kernel_zimg="${outdir}/arch/arm/boot/zImage"
else
  kernel_img="${curdir}/arch/arm/boot/Image"
  kernel_zimg="${curdir}/arch/arm/boot/zImage"
fi

echo "**** Generate download images ****"

if [ ! -x ${mkimg} ]; then chmod a+x ${mkimg}; fi

if [ "${KBUILD_OUTPUT_SUPPORT}" == "yes" ]; then
  ${mkimg} ${kernel_zimg} KERNEL > $outdir/kernel_${MTK_PROJECT}.bin
  copy_to_legacy_download_flash_folder $outdir/kernel_${MTK_PROJECT}.bin rootfs_${MTK_PROJECT}.bin
else
  ${mkimg} ${kernel_zimg} KERNEL > $curdir/kernel_${MTK_PROJECT}.bin
  copy_to_legacy_download_flash_folder $curdir/kernel_${MTK_PROJECT}.bin rootfs_${MTK_PROJECT}.bin
fi

echo "**** Kernel build completed ****"

echo "**** Copying kernel to /build_result/kernel/ ****"
mkdir -p ./build_result/kernel/
cp ./kernel/arch/arm/boot/zImage ./build_result/kernel/boot.img-kernel

echo "**** Copying all built modules (.ko) to /build_result/modules/ ****"
mkdir -p ./build_result/modules/
for file in $(find kernel mediatek -name "*.ko"); do
 cp $file ./build_result/modules/
done

echo "**** Patching all built modules (.ko) in /build_result/modules/ ****"
find ./build_result/modules/ -type f -name '*.ko' | xargs -n 1 ${CROSS_COMPILE}strip --strip-unneeded

echo "**** Copying MediaTek files to /build_result/mtk ****"
cp -r ./out ./build_result/mtk

echo "**** Finnish ****"

#echo "**** You can find kernelFile in root folder: /build_result/kernel/ ****"
echo "**** You can find zImage in root folder: /build_result/kernel/ ****"
echo "**** You can find all modules in root folder: /build_result/modules/ ****"
#echo "**** Rename the kernelFile to zImage and repack with stock RamDisk ****"
echo "**** Now grab the zImage and repack with stock RamDisk ****"

echo "**** Packing build result ****"
tar zcvf build_result.tar.gz ./build_result
echo "**** build_result.tar.gz has been created ****"
