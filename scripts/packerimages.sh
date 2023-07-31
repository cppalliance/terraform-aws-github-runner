#!/bin/bash

# ubuntu-bionic-arm64-cppal
# ubuntu-bionic-cppal
# ubuntu-focal-arm64-cppal
# ubuntu-focal-cppal
# ubuntu-jammy-arm64-cppal
# ubuntu-jammy-cppal
# windows-2019-cppal
# windows-2022-cppal

imagestobuild="
windows-2019-cppal
"

timestamp=$(date +%Y%m%d_%H%M%S)
cd ..
mainfolder=$(pwd)

task(){
    set -xe
    thisimage=$1
    echo "Building $thisimage"
    cd $mainfolder/images/$thisimage
    packer build . | tee output.out 2>&1
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
    newline="ami_filter: { 'name': ['${ami_name}'] }"
    sed -i "s/ami_filter:.*/$newline/g" ${runnertemplatefolder}/${runnertemplate}
}

for image in $imagestobuild; do
  task "$image" &
done
