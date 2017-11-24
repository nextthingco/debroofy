#!/bin/bash

set -e

ARCH=arm64
ROOTFS_DIR="$PWD/rootfs"
TAR_FILE="$PWD/debian_${ARCH}_rootfs.tar.gz"

OUTPUT="${TAR_FILE}"

echo -n "Running debootstragp stage 1..."
[[ -d "${ROOTFS_DIR}" ]] && rm -rf "${ROOTFS_DIR}"
mkdir -p "${ROOTFS_DIR}"
/usr/sbin/debootstrap --verbose --foreign --arch ${ARCH} stretch "${ROOTFS_DIR}" http://ftp.us.debian.org/debian
echo "OK"

echo -n "adding qemu-aarch64-static..."
cp -va "$(which qemu-aarch64-static)" "${ROOTFS_DIR}"/usr/bin/
echo "OK"

update-binfmts --display qemu-aarch64
update-binfmts --enable qemu-aarch64

echo "##########################"
echo "## ENTER CHROOT         ##"
echo "##########################"

LLANG=C.UTF-8 chroot "${ROOTFS_DIR}" /bin/bash <<EOF
echo -n "Running debootstragp stage 2..."
/debootstrap/debootstrap --second-stage || cat /debootstrap/debootstrap.log
echo "OK"
EOF

echo "##########################"
echo "## LEAVE CHROOT         ##"
echo "##########################"

pushd ${ROOTFS_DIR}
tar --one-file-system -cvzf "${TAR_FILE}" .
popd
