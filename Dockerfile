FROM debian:stretch

RUN apt -y update && apt -y upgrade && apt -y install \
debootstrap \
qemu-user-static \
cpio \
u-boot-tools \
libncurses5-dev \
crossbuild-essential-arm64 dpkg-dev dh-make dh-systemd dkms module-assistant bc \
git vim \
reprepro \
python-pip \
&& \
pip install awscli --upgrade

