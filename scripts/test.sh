#!/bin/bash

set -xe

runnertemplate="ubuntu-jammy.yaml"
ami_file="prod_amis.sh"

# Update ami_file also, with the same value
if ! fgrep "all_amis[$runnertemplate]=" ; then
    sed -i "s/# all_amis - keep this line/# all_amis - keep this line\nall_amis[$runnertemplate]=X/" ${ami_file}
fi
# newline="all_amis[$runnertemplate]=$ami_name"
# sed -i "s/all_amis\[$runnertemplate\]=.*/$newline/g" $mainfolder/scripts/${ami_file}
# echo "build completed"



