#!/bin/bash

set -e

./0010-debootstrap.sh
./0020-customize.sh
./0030-upload-to-s3.sh
