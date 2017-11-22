#!/bin/bash

ARCH=arm64
ROOTFS_DIR="$PWD/rootfs"
TAR_FILE="$PWD/debian_${ARCH}_rootfs.tar.gz"

OUTPUT="${TAR_FILE}"

mkdir -p "${ROOTFS_DIR}"
/usr/sbin/debootstrap --foreign --arch ${ARCH} stretch "${ROOTFS_DIR}" http://ftp.us.debian.org/debian

cp "$(which qemu-aarch64-static)" "${ROOTFS_DIR}"/usr/bin/

LANG=C.UTF-8 chroot "${ROOTFS_DIR}" /bin/bash <<EOF
/debootstrap/debootstrap --second-stage
EOF

pushd ${ROOTFS_DIR}
tar --one-file-system -cvzf "${TAR_FILE}" .
popd
