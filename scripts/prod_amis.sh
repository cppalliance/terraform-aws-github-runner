#!/bin/bash

# A script to both keep track of the latest ami labels when they change,
# and also to reset the names to their correct values later.

set -xe

declare -A all_amis

# all_amis - keep this line
all_amis[ubuntu-jammy.yaml]=github-runner-ubuntu-jammy-amd64-202411261305
all_amis[ubuntu-focal-arm64.yaml]=github-runner-ubuntu-focal-arm64-202410151633
all_amis[ubuntu-jammy-arm64.yaml]=github-runner-ubuntu-jammy-arm64-202410151633
all_amis[ubuntu-bionic.yaml]=github-runner-ubuntu-bionic-amd64-202411261305
all_amis[ubuntu-focal.yaml]=github-runner-ubuntu-focal-amd64-202411261305
all_amis[ubuntu-bionic-arm64.yaml]=github-runner-ubuntu-bionic-arm64-202410151633
all_amis[ubuntu-noble.yaml]=github-runner-ubuntu-noble-amd64-202411261305
all_amis[ubuntu-noble-arm64.yaml]=github-runner-ubuntu-noble-arm64-202410151633
all_amis[windows-2019.yaml]=github-runner-windows-2019-amd64-202503111933
all_amis[windows-2022.yaml]=github-runner-windows-2022-amd64-202503112051
all_amis[windows-2025.yaml]=github-runner-windows-2025-amd64-202503112051

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
