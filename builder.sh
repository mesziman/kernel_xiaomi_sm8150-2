#!/bin/bash
git submodule init scripts
git submodule update scripts

KERNEL_DIR=$PWD
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel3
CCACHEDIR=../CCACHE/cepheus
TOOLCHAINDIR=/pipeline/build/root/toolchain/clang/bin
DATE=$(date +"%d%m%Y")
KERNEL_NAME="mesziman"
DEVICE="-cepheus-R11-TESTBUILD-"
VER=$(git rev-parse --short HEAD)
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$VER".zip
corenumber=$( nproc --all )
buildspeed=$(( $corenumber + 2 ))


rm $ANYKERNEL_DIR/Image.gz-dtb
rm $KERNEL_DIR/arch/arm64/boot/Image.gz $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
export PATH="${TOOLCHAINDIR}:${PATH}"
export LD_LIBRARY_PATH="${TOOLCHAINDIR}/lib:$LD_LIBRARY_PATH"
export ARCH=arm64
export KBUILD_BUILD_USER="mesziman"
export KBUILD_BUILD_HOST="github"


ls -l ${TOOLCHAINDIR}/clang
echo "=========================debug============================================"
echo " cc-namex: $(shell ${CC} -v 2>&1 )"
echo " cc-namegrep: $(shell ${CC} -v 2>&1  | grep -q "clang version" )"
echo " cc-namegrepq: $(shell ${CC} -v 2>&1  | grep "clang version" )"
echo " cc-name: $(shell ${CC} -v 2>&1  | grep -q "clang version" && echo clang || echo gcc)"
echo "ccname noshell build : $(${CC} -v 2>&1 | grep -q "clang version" && echo clang || echo gcc)"
echo "which 32tc $(which ${CROSS_COMPILE_ARM32}ld))"
echo "which tc $(which ${CROSS_COMPILE}ld))"
echo "which cc $(which ${CC}))"
echo "which gcc $(which ${CROSS_COMPILE}gcc)"
echo "which gcc32 $(which ${CROSS_COMPILE32}gcc)"
ver=$(clang -v)
echo $ver
echo "CC-name:"
echo $ccname
echo "=========================debug============================================"
make clean && make mrproper
make O=out -C $KERNEL_DIR cepheus_defconfig

${KERNEL_DIR}/scripts/config --file $KERNEL_DIR/out/.config \
    -d CGROUP_DEBUG \
    -d CMA_DEBUGFS \
    -d PM_DEBUG \
    -d DEBUG_PAGEALLOC \
    -d SLUB_DEBUG_PANIC_ON \
    -d DEBUG_PAGEALLOC_ENABLE_DEFAULT \
    -d DEBUG_OBJECTS \
    -d DEBUG_OBJECTS_FREE \
    -d DEBUG_OBJECTS_TIMERS \
    -d DEBUG_OBJECTS_WORK \
    -d DEBUG_OBJECTS_PERCPU_COUNTER \
    -d DEBUG_KMEMLEAK \
    -d DEBUG_KMEMLEAK_DEFAULT_OFF \
    -d DEBUG_KMEMLEAK_EARLY_LOG_SIZE \
    -d DEBUG_STACK_USAGE \
    -d DEBUG_SPINLOCK \
    -d DEBUG_MUTEXES \
    -d DEBUG_ATOMIC_SLEEP \
    -d DEBUG_SG \
    -d DEBUG_NOTIFIERS \
    -d DEBUG_CREDENTIALS \
    -d LOCK_TORTURE_TEST \
    -d RCU_TORTURE_TEST \
    -d FAULT_INJECTION \
    -d FAIL_PAGE_ALLOC \
    -d FAULT_INJECTION_STACKTRACE_FILTER \
    -d DEBUG_SECTION_MISMATCH \
    -d DEBUG_MEMORY_INIT \
    -d RMNET_DATA_DEBUG_PKT \
    -d ESOC_DEBUG \
    -d FHANDLE \
    -d RD_BZIP2 \
    -d RD_LZMA \
    -d SYSFS_SYSCALL \
    -d SLAB_FREELIST_RANDOM \
    -d SLAB_FREELIST_HARDENED \
    -d CMA_DEBUGFS \
    -e HARDEN_BRANCH_PREDICTOR \
    -d EFI \
    -d L2TP_DEBUGFS \
    -d REGMAP_ALLOW_WRITE_DEBUGFS \
    -d CORESIGHT \
    -d PAGE_POISONING \
    -d QCOM_RTB \
    -d BLK_DEV_IO_TRACE \
    -d PREEMPTIRQ_EVENTS \
    -d PREEMPT_TRACER \
    -d IRQSOFF_TRACER \
    -d PAGE_OWNER \
    -d DRM_SDE_EVTLOG_DEBUG \
    -d DRM_MSM_REGISTER_LOGGING \
    -d MSM_SDE_ROTATOR_EVTLOG_DEBUG \
    -d VIDEO_ADV_DEBUG \
    -d IPU_DEBUG \
    -d SPMI_MSM_PMIC_ARB_DEBUG \
    -d WQ_WATCHDOG \
    -d SCHED_STACK_END_CHECK \
    -d LOCKUP_DETECTOR \
    -d SOFTLOCKUP_DETECTOR \
    -d MHI_DEBUG

make -s O=out -C $KERNEL_DIR  -j$buildspeed ARCH=arm64 CROSS_COMPILE=${TOOLCHAINDIR}/bin/aarch64-elf- CROSS_COMPILE_ARM32=${TOOLCHAIN32}/bin/arm-eabi- | grep "error:"

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
