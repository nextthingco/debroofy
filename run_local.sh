#!/bin/bash

export CONTAINER_IMAGE=ntc-registry.githost.io/nextthingco/debroofy:docker

export AWS_ACCESS_KEY_ID=$(sed -n -e 's/aws_access_key_id = \(.*\)/\1/p' ~/.aws/credentials)
export AWS_SECRET_ACCESS_KEY=$(sed -n -e 's/aws_secret_access_key = \(.*\)/\1/p' ~/.aws/credentials)
export AWS_REGION=us-west-2
export AWS_BUCKET=s3://opensource.nextthing.co/githost/debroofy
export CI_JOB_ID=${RANDOM}
export CI_PIPELINE_ID=${RANDOM}

export DEB_REPO="http://opensource.nextthing.co/githost/deborah"
export DEB_REPO_PUBLIC_KEY="\
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFoTb30BEADufkHcF/jd5UzNlSg+Osa/BatqkhNI+ib3vFn4SqcVJEI/1zZP
VGKQOygxW3YgEqYgjZYVPT5rZqbSVk3utRksp93c3qk1XrNlwB/70WHyc2r0gslz
fRxQkeP4GhWtmMcFlUo3SJQBjHiUtvG9zJdzoymnnDYnjXHLH3gJ8oCL8R1HAYua
XmO8sYB2ytzrlneM6jodcZEkB4kaKo8bSaF3vK1eV/KYIqua+sw0mB5hCxCaiWx6
H+3sCfg6agRWzTYKGY1rzxGGzsvm1z51//gCTrJASciG4aFD2ph+C76uJcYy2QWi
I95+B51iPu1cL0EjRJGtlSXL3Td5R0oPvZdZn+q5bR3OsAO9z3RtX/rHy6TowXVA
VjOcYeUkGkKsVzyREz3VNZ41qpVWSqd1vHHPxcd8fHLZ30losKOC7wLo2TtVFSzm
oXJnaq6Dr0seYKudEZycGlFBdwTt8WotrH64n3lUCgdtWlrWG77ekLehlfKsE6RW
b7efTdFX1r2NSf/Q2syamJ/ByK5BB1s7MnwrRnG4/9yMbrmBS/2fOoHELimZbeu+
61gvUKcTzqFTZU6SQFm4rz5lojavWWNjRvdxz5Cy9RLZy0mjC+3Lw2kw52xCbd+g
9baBSjO8E2+8bogUPfLJq+ireAjPZ39jtDSsDRNRAQ5WYAWf/tUrUjg+UQARAQAB
tCVOZXh0IFRoaW5nIENvIDxzb2Z0d2FyZUBuZXh0dGhpbmcuY28+iQJOBBMBCAA4
FiEEnABy6M/4r0Xe9CkaILS2nUQGjNEFAloTb30CGwMFCwkIBwIGFQgJCgsCBBYC
AwECHgECF4AACgkQILS2nUQGjNEbrQ/7BMynd/1uVs38uFSatPhC0oNxbYJX40wi
Y5N4wHU7VejMb0OmseocUifG7NnKlhBqVoqyhsjw5IFKfyIx99ZxCCwxltYpPAR/
QmaZMsNJcVbogBoU8RHIj2R6x2X22shdXO/i7qd7d5nOqc6OWo+FOTcl6CDlqIyx
HFPD7g47CGwygZCGu6dPC5AKp/oya2HmOEVGz9vd1sCFaSzH2tK9w1gDasH4T+ma
MRyQibbLFJxm3act3iDRIfeZmuUMJniTvH37oBS7VOGpPChN3wCCBW/kdIIL4a2Q
rFnKTOJv49VpFnlfB2DqRhiBtkyrTQZkfQmQ7Vb6zCnZX8tur+2NkgJpsYZRklKM
8oHvCGjiXUYhGmaXDqtazbAP2wcdRFMs+dbeLI3WpaIVXPfw6Z1v6pyeEHYZ0S4D
NtqEWD+j1bCYlO5arRYKyJvNPtz0azWqWAyakD9rKzB4Yc5vjjK0mMxD5hjnkGUx
4ie9PRaUxAPMzq/FpUkQC9eauMFy6UnSKBn7KuQh1RTAapyhLNbe+zF29uER3zFV
b3EAbb2LdOtTA+JjJpVmRkzKoIxnYGtqHpBv2VpcGfjMq0/P2eeG7AAA3ByjfMJw
5CEucCJl/h5CdAHln9wgR9s+PwkAUDYw0NNcW427VoC1qRkpVNzYtcmj6hsNDxZx
heNriu1GZ0Y=
=Nvmo
-----END PGP PUBLIC KEY BLOCK-----"

export LOCAL_BUILDDIR=src # must be relative path
export DOCKER_VOLUME=debroofy_local_builddir
export USE_DOCKER_VOLUME="-v $DOCKER_VOLUME:/work/$LOCAL_BUILDDIR"
uname="$(uname -s)"
case "${uname}" in
    Linux*)
        mkdir -p "${LOCAL_BUILDDIR}"
        echo "Running natively on Linux, good!"
        export USE_DOCKER_VOLUME=""
        ;;
    Darwin*) ;;
    CYGWIN*) ;;
    MINGW*) ;;
    *)
        echo "ERROR: Building on $uname is currently not supported - sorry!"
        exit 1
        ;;
esac


docker pull $CONTAINER_IMAGE
[[ ! -z "${DOCKER_VOLME}" ]] && ( docker volume inspect "${DOCKER_VOLUME}" 2>/dev/null >/dev/null || docker volume create --name "${DOCKER_VOLUME}" )
docker run --rm -it --privileged \
           -e ARCH="${ARCH}" \
           -e DEB_REPO="${DEB_REPO}" \
           -e DEB_REPO_PUBLIC_KEY="${DEB_REPO_PUBLIC_KEY}" \
           -e LINUX_DEPLOY_PRIVATE_KEY="${LINUX_DEPLOY_PRIVATE_KEY}"  \
           -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
           -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
           -e AWS_REGION="${AWS_REGION}" \
           -e AWS_BUCKET="${AWS_BUCKET}" \
           -e CI_JOB_ID="${CI_JOB_ID}" \
           -e CI_PIPELINE_ID="${CI_PIPELINE_ID}" \
           -e LOCAL_BUILDDIR=/work/$LOCAL_BUILDDIR \
           -v $PWD:/work -w /work \
           ${USE_DOCKER_VOLUME} \
           $CONTAINER_IMAGE /bin/bash -c /work/build.sh

