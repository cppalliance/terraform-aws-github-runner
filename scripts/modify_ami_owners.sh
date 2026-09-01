#!/bin/bash

set -xe

usage() {
    echo "Usage: $0 -e <dev|prod>"
    echo "  -e  Environment (required): dev or prod"
    exit 1
}

while getopts "e:" opt; do
    case "$opt" in
        e) build_environment="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ "$build_environment" != "dev" ] && [ "$build_environment" != "prod" ]; then
    echo "ERROR: -e <dev|prod> is required"
    usage
fi

if [ "$build_environment" = "dev" ]; then
    export AWS_PROFILE=tagr-packer-dev
    ami_account=254949769574
else
    export AWS_PROFILE=tagr-packer-prod
    ami_account=047402373783
fi

imagestobuild="
ubuntu-bionic-arm64-cppal
ubuntu-bionic-cppal
ubuntu-focal-arm64-cppal
ubuntu-focal-cppal
ubuntu-jammy-arm64-cppal
ubuntu-jammy-cppal
ubuntu-noble-arm64-cppal
ubuntu-noble-cppal
ubuntu-resolute-arm64-cppal
ubuntu-resolute-cppal
windows-2019-cppal
windows-2022-cppal
windows-2025-cppal
"

timestamp=$(date +%Y%m%d_%H%M%S)
cd ..
mainfolder=$(pwd)

task(){
    set -xe
    thisimage=$1
    echo "Updating $thisimage"
    runnertemplatefolder="${mainfolder}/examples/multi-runner-cppal/templates/runner-configs"
    bckfolder="${runnertemplatefolder}/bcks"
    runnertemplate="${thisimage%-cppal}"
    # backup. perhaps not needed.
    # cp ${runnertemplatefolder}/${runnertemplate} ${bckfolder}/${runnertemplate}.${timestamp}
    newline="owners: [ \"$ami_account\" ]";
    sed -i "s/owners:.*/$newline/g" ${runnertemplatefolder}/${runnertemplate}
}

imagestobuild=$(ls -1 ${mainfolder}/examples/multi-runner-cppal/templates/runner-configs | grep -v bcks)

for image in $imagestobuild; do
  task "$image" &
done
