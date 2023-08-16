#!/bin/bash

# A script to both keep track of the latest ami labels when they change,
# and also to reset the names to their correct values later.

set -xe

declare -A all_amis

all_amis[ubuntu-bionic-arm64.yaml]=github-runner-ubuntu-bionic-arm64-202308031506
all_amis[ubuntu-bionic.yaml]=github-runner-ubuntu-bionic-amd64-202308031506
all_amis[ubuntu-focal-arm64.yaml]=github-runner-ubuntu-focal-arm64-202308031506
all_amis[ubuntu-focal.yaml]=github-runner-ubuntu-focal-amd64-202308031506
all_amis[ubuntu-jammy-arm64.yaml]=github-runner-ubuntu-jammy-arm64-202308031506
all_amis[ubuntu-jammy.yaml]=github-runner-ubuntu-jammy-amd64-202308031506
all_amis[windows-2019.yaml]=github-runner-windows-2019-amd64-202308161544
all_amis[windows-2022.yaml]=github-runner-windows-2022-amd64-202308161544

# Update the templates with the above values

cd ..
mainfolder=$(pwd)
runnertemplatefolder="${mainfolder}/examples/multi-runner-cppal/templates/runner-configs"
cd ${runnertemplatefolder}
for runnertemplate in "${!all_amis[@]}"; do
    ami_name="${all_amis[$runnertemplate]}"
    newline="ami_filter: { 'name': ['${ami_name}'] }"
    sed -i "s/ami_filter:.*/$newline/g" ${runnertemplatefolder}/${runnertemplate}
done
