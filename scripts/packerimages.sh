#!/bin/bash

set -xe

build_environment=dev
# build_environment=prod

# Builds multiple new AMI images and updates the files in examples/multi-runner-cppal/templates/runner-configs to point to those images
# Instructions: Set the imagestobuild variable. Run the script: ./packerimages.sh | tee output.out 2>&1

# ubuntu-bionic-arm64-cppal
# ubuntu-bionic-cppal
# ubuntu-focal-arm64-cppal
# ubuntu-focal-cppal
# ubuntu-jammy-arm64-cppal
# ubuntu-jammy-cppal
# ubuntu-noble-arm64-cppal
# ubuntu-noble-cppal
# windows-2019-cppal
# windows-2022-cppal
# windows-2025-cppal

imagestobuild="
ubuntu-bionic-arm64-cppal
ubuntu-bionic-cppal
ubuntu-focal-arm64-cppal
ubuntu-focal-cppal
ubuntu-jammy-arm64-cppal
ubuntu-jammy-cppal
ubuntu-noble-arm64-cppal
ubuntu-noble-cppal
windows-2019-cppal
windows-2022-cppal
windows-2025-cppal
"

if [ "$build_environment" = "dev" ]; then
    echo "dev environment"
    varfiles=(-var-file="variables.auto.pkrvars.hcl" -var-file="dev.pkrvars.hcl")
    ami_file=dev_amis.sh
else
    echo "prod environment"
    varfiles=(-var-file="variables.auto.pkrvars.hcl")
    ami_file=prod_amis.sh
fi

timestamp=$(date +%Y%m%d_%H%M%S)
cd ..
mainfolder=$(pwd)

task(){
    set -xe
    set -o pipefail
    thisimage=$1
    echo "Building $thisimage"
    cd $mainfolder/images/$thisimage
    rm results.out || true
    packer build "${varfiles[@]}" . | tee output.out 2>&1
    echo "packer build successful" | tee results.out 2>&1
    # testing: echo "us-west-2: ami-0b5fa6619a10d7ca7" > output.out
    resultingami=$(tail -n 2 output.out | cut -d" " -f 2)
    runnertemplatefolder="${mainfolder}/examples/multi-runner-cppal/templates/runner-configs"
    bckfolder="${runnertemplatefolder}/bcks"
    runnertemplate="${thisimage%-cppal}.yaml"
    cp ${runnertemplatefolder}/${runnertemplate} ${bckfolder}/${runnertemplate}.${timestamp}
    echo "resultingami is $resultingami . runnertemplate is $runnertemplate ."
    ami_name=$(aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 | grep ${resultingami} | cut -f 1)
    echo "ami_name is ${ami_name}"
    # github-runner-ubuntu-jammy-amd64-202306021546
    newline="filter: { 'name': ['${ami_name}'] }"
    sed -i "s/filter:.*/$newline/g" ${runnertemplatefolder}/${runnertemplate}

    # Update ami_file also, with the same value
    if ! fgrep "all_amis[$runnertemplate]=" $mainfolder/scripts/${ami_file}; then
        sed -i "s/# all_amis - keep this line/# all_amis - keep this line\nall_amis[$runnertemplate]=X/" $mainfolder/scripts/${ami_file}
    fi
    newline="all_amis[$runnertemplate]=$ami_name"
    sed -i "s/all_amis\[$runnertemplate\]=.*/$newline/g" $mainfolder/scripts/${ami_file}
    echo "build completed"
}

for image in $imagestobuild; do
  task "$image" &
done
