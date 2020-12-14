#!/bin/bash
git submodule init scripts
git submodule update scripts

KERNEL_DIR=$PWD
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel3
CCACHEDIR=../CCACHE/cepheus
TOOLCHAINDIR=/pipeline/build/root/toolchain/sdclang
TOOLCHAIN32=/pipeline/build/root/toolchain/supergcc32
DATE=$(date +"%d%m%Y")
KERNEL_NAME="mesziman"
DEVICE="-cepheus-R11-TESTBUILD-"
VER=$(git rev-parse --short HEAD)
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$VER".zip
corenumber=$( nproc --all )
buildspeed=$(( $corenumber + 2 ))


rm $ANYKERNEL_DIR/Image.gz-dtb
rm $KERNEL_DIR/arch/arm64/boot/Image.gz $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
export ARCH=arm64
export KBUILD_BUILD_USER="mesziman"
export KBUILD_BUILD_HOST="github"

export PATH="${TOOLCHAINDIR}/bin:${TOOLCHAIN32}/bin:${PATH}"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAINDIR}/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAIN32}/lib"

echo "=========================debug============================================"
$TOOLCHAINDIR/bin/llc --version 2>&1
echo "======== CLANG FLAGS =========="
$TOOLCHAINDIR/bin/llvm-as < /dev/null | $TOOLCHAINDIR/bin/llc -march=arm64 -mcpu=help | grep "kryo\|a76\|a55"

echo "=========================MATTR============================================"

$TOOLCHAINDIR/bin/llvm-as < /dev/null | $TOOLCHAINDIR/bin/llc -march=arm64 -mattr=help
echo "==================== "
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git revert c29f49fee539 --no-edit;
sed -i "s/mcpu=cortex-a.*/mcpu=cortex-a55 -mtune=cortex-a55 -mattr=+crc,+crypto,+dotprod/g" $KERNEL_DIR/Makefile
grep cortex $KERNEL_DIR/Makefile
make clean && make mrproper
make O=out -C $KERNEL_DIR cepheus_defconfig
make -s O=out -C $KERNEL_DIR -j$buildspeed ARCH=arm64 CC=$TOOLCHAINDIR/bin/clang LD=$TOOLCHAINDIR/bin/ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu-  CROSS_COMPILE_ARM32=${TOOLCHAIN32}/bin/arm-eabi- 2>&1 | tee ${WERCKER_REPORT_ARTIFACTS_DIR}/errorlog.txt
{
cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/
} || {
if [ $? != 0 ]; then
  echo "FAILED BUILD"
  exit
fi
}
echo "======================VERIFY CLANG==============================="
cat $KERNEL_DIR/out/include/generated/compile.h
echo "======================VERIFY CLANG==============================="
cd $ANYKERNEL_DIR/
zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
cp $FINAL_ZIP ${WERCKER_REPORT_ARTIFACTS_DIR}/
curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="New build $(cat $KERNEL_DIR/changelog.txt)" -d chat_id=@meszimankernel ;
curl -F chat_id="-1001477254593" -F document=@"$FINAL_ZIP" https://api.telegram.org/bot$BOT_API_KEY/sendDocument
mv $FINAL_ZIP /pipeline/output/$FINAL_ZIP
