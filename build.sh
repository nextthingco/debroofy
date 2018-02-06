#!/bin/bash

set -e

echo DEB_REPO="$DEB_REPO"
echo DEB_REPO_PUBLIC_KEY="$DEB_REPO_PUBLIC_KEY"
./0010-debootstrap.sh
./0020-customize.sh
