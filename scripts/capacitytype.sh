#!/bin/bash

#   instance_target_capacity_type: "spot"

# ubuntu-bionic-arm64-cppal
# ubuntu-bionic-cppal
# ubuntu-focal-arm64-cppal
# ubuntu-focal-cppal
# ubuntu-jammy-arm64-cppal
# ubuntu-jammy-cppal
# windows-2019-cppal
# windows-2022-cppal

imagestobuild="
ubuntu-bionic-arm64-cppal
ubuntu-bionic-cppal
ubuntu-focal-arm64-cppal
ubuntu-focal-cppal
ubuntu-jammy-arm64-cppal
ubuntu-jammy-cppal
windows-2019-cppal
windows-2022-cppal
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
    runnertemplate="${thisimage%-cppal}.yaml"
    # backup. perhaps not needed.
    cp ${runnertemplatefolder}/${runnertemplate} ${bckfolder}/${runnertemplate}.${timestamp}
    newline="instance_target_capacity_type: \"on-demand\""
    sed -i "s/instance_target_capacity_type:.*/$newline/g" ${runnertemplatefolder}/${runnertemplate}
}

for image in $imagestobuild; do
  task "$image" &
done
