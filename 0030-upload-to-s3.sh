#!/bin/bash

set -e

ARCH="${ARCH:-arm64}"
ROOTFS_FILE="debian_${ARCH}_rootfs_customized.tar.xz"

AWS_BUCKET="${AWS_BUCKET:?ERROR: AWS_BUCKET not defined}"
AWS_REGION="${AWS_REGION:?ERROR: AWS_REGION not defined}"
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?ERROR: AWS_ACCESS_KEY_ID not defined}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?ERROR AWS_SECRET_ACCESS_KEY not define}"

aws s3 cp --no-progress --acl public-read "${PWD}/${ROOTFS_FILE}" "${AWS_BUCKET}/${ROOTFS_FILE}" 
