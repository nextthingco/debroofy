#!/bin/bash

set -e

ARCH="${ARCH:-arm64}"
ROOTFS_FILE="debian_${ARCH}_rootfs_customized.tar.xz"

[[ -z "${AWS_BUCKET}" || -z "${AWS_REGION}" || -z "${AWS_ACCESS_KEY_ID}" || -z "${AWS_SECRET_ACCESS_KEY}" ]] && echo "S3 upload: missing variables -> SKIP" && return
aws s3 cp --no-progress --acl public-read "${PWD}/${ROOTFS_FILE}" "${AWS_BUCKET}/${ROOTFS_FILE}" 

