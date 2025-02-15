#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # Kernel build steps
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all -j$(nproc)
    cp arch/${ARCH}/boot/Image ${OUTDIR}/Image
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# Create base directories
mkdir -p ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr/bin usr/lib var

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # Configure Busybox
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    sed -i 's/.*CONFIG_STATIC.*/CONFIG_STATIC=y/' .config
else
    cd busybox
fi

# Build and install Busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install CONFIG_PREFIX=${OUTDIR}/rootfs

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# Copy library dependencies
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
mkdir -p ${OUTDIR}/rootfs/lib
cp -a ${SYSROOT}/lib/* ${OUTDIR}/rootfs/lib/

# Create device nodes
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3

# Build writer utility
cd /home/dave/assignment-1-Dave-chem/finder-app/writer
make clean
make CC=${CROSS_COMPILE}gcc
cp writer ${OUTDIR}/rootfs/home/

# Copy finder scripts and modify paths
mkdir -p ${OUTDIR}/rootfs/home/conf
cp /home/dave/assignment-1-Dave-chem/conf/username.txt ${OUTDIR}/rootfs/home/conf/
cp /home/dave/assignment-1-Dave-chem/conf/assignment.txt ${OUTDIR}/rootfs/home/conf/
cp /home/dave/assignment-1-Dave-chem/finder-app/finder.sh ${OUTDIR}/rootfs/home/
cp /home/dave/assignment-1-Dave-chem/finder-app/finder-test.sh ${OUTDIR}/rootfs/home/
cp /home/dave/assignment-1-Dave-chem/finder-app/autorun-qemu.sh ${OUTDIR}/rootfs/home/
sed -i 's|../conf/assignment.txt|conf/assignment.txt|' ${OUTDIR}/rootfs/home/finder-test.sh

# Set ownership
sudo chown -R root:root ${OUTDIR}/rootfs

# Create initramfs
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov > ../initramfs.cpio
cd ..
gzip -f initramfs.cpio
mv initramfs.cpio.gz ${OUTDIR}/initramfs.cpio.gz
