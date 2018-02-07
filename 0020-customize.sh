#!/bin/bash

set -e

ARCH="${ARCH:-arm64}"
PASSWORD="${PASSWORD:-chip}"
USERNAME="${USERNAME:-chip}"
HOSTNAME="${USERNAME:-four}"

LOCAL_BUILDDIR="${LOCAL_BUILDDIR:-$PWD}"
INPUT="$LOCAL_BUILDDIR/debian_${ARCH}_rootfs.tar.gz"
OUTPUT="$LOCAL_BUILDDIR/debian_${ARCH}_rootfs_customized.tar.xz"

! [[ -f  "${INPUT}" ]] &&  echo "ERROR: ${INPUT} not found" && exit 1

TMP_DIR="$(mktemp -d)"

pushd ${TMP_DIR}
echo -n "unpacking input file ${INPUT}..."
tar xf "${INPUT}" .
echo "OK"
popd

# TODO: proper overlay mechanism here
echo -n "setup CHIP4 specific kernel post-install hooks..."
mkdir -p "${TMP_DIR}/etc/kernel/postinst.d"
cp create_uboot_image "${TMP_DIR}/etc/kernel/postinst.d/"
cp copy_dtb "${TMP_DIR}/etc/kernel/postinst.d/"
echo "OK"
cp fstab "${TMP_DIR}/etc/fstab"

pushd "${TMP_DIR}"
echo "##########################"
echo "## PREPARE              ##"
echo "##########################"
mount --bind /proc ${TMP_DIR}/proc
mount --bind /sys ${TMP_DIR}/sys
mount --bind /dev/pts ${TMP_DIR}/dev/pts

echo "disable demons"
cat > ${PWD}/usr/sbin/policy-rc.d <<EOF
#!/bin/sh
exit 101
EOF
chmod a+x ${PWD}/usr/sbin/policy-rc.d

#echo "##########################"
#echo "## INTERACTIVE CHROOT   ##"
#echo "##########################"
#LANG=C.UTF-8 chroot "${TMP_DIR}" /bin/bash --login

update-binfmts --display qemu-aarch64
update-binfmts --enable qemu-aarch64

echo "##########################"
echo "## ENTER CHROOT         ##"
echo "##########################"
LANG=C.UTF-8 chroot "${TMP_DIR}" /bin/bash -e <<EOF

echo -n "disabling Translations to save space..."
echo "path-exclude /usr/share/locale/*"   > /etc/dpkg/dpkg.cfg.d/02_no_translations
echo "path-include /usr/share/locale/en*" >>/etc/dpkg/dpkg.cfg.d/02_no_translations
echo "OK"

find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*'  |xargs rm -r

echo -n "adding kernel repository to /etc/apt/sources.list..."
mkdir -p /etc/apt/sources.list.d/
echo "deb ${DEB_REPO} stretch main" >/etc/apt/sources.list.d/ntc.list
echo "OK"

echo -n "adding public key for kernel repository..."
echo "${DEB_REPO_PUBLIC_KEY}" | apt-key add -
echo "OK"

echo -n "updating..."
apt-get -y update
apt-get -y upgrade
echo -n "installing..."
apt-get -y --no-install-recommends install u-boot-tools network-manager modemmanager sudo \
    linux-image-4.13.13-chip4 \
    rtl8723ds-mp-driver-common \
    rtl8723ds-mp-driver-modules-4.13.13-chip4
#rtl8723ds-bt*.deb
echo "OK"

echo -n "chreating user \"$USERNAME\"..."
echo -e "$PASSWORD\n$PASSWORD\n\n\n\n\n\nY\n" | adduser $USERNAME
adduser $USERNAME netdev 
adduser $USERNAME plugdev
adduser $USERNAME sudo
adduser $USERNAME audio
adduser $USERNAME video
adduser $USERNAME cdrom
echo "OK"

echo "$HOSTNAME" >/etc/hostname


sed -i -e '/ExecStart=.*/ aExecStartPost=/bin/bash -c "/bin/echo 4 >/proc/sys/kernel/printk"' /lib/systemd/system/wpa_supplicant.service
touch /etc/hosts
echo -e "127.0.0.1\t$HOSTNAME" >>/etc/hosts
touch /etc/NetworkManager/NetworkManager.conf
echo -e "[keyfile]\nunmanaged-devices=interface-name:wlan1\n" >>/etc/NetworkManager/NetworkManager.conf
cat

echo -n "## clearing cache to save space..."
rm -rf /var/cache/apt/*
echo "OK"
EOF

#echo "##########################"
#echo "## INTERACTIVE CHROOT   ##"
#echo "##########################"
#LANG=C.UTF-8 chroot "${TMP_DIR}" /bin/bash --login

echo "##########################"
echo "## LEAVE CHROOT         ##"
echo "##########################"

echo "##########################"
echo "## CLEANUP              ##"
echo "##########################"
umount ${PWD}/proc
umount ${PWD}/sys
umount ${PWD}/dev/pts
#umount ${PWD}/var/cache/apt
rm ${PWD}/usr/sbin/policy-rc.d
rm ${PWD}/usr/bin/qemu-aarch64-static
rm -rf ${TMP_DIR}/var/cache/apt/*

echo "packing output file ${OUTPUT}..."
XZ_OPT=-9 tar cJf "$OUTPUT" .
echo "OK"

popd

