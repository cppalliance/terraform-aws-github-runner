#!/bin/bash

# Discover amis to delete

set -e

region=us-west-2
amis=""

results=$(aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region $region)

echo "all results:"
echo "$results"
echo " "

IFS='
'

for result in $results; do
    # echo "ami is $result"
    ami_name=$(echo "$result" | cut -f1)
    # echo "ami_name is $ami_name"
    ami_id=$(echo "$result" | cut -f2)
    # echo "ami_id is $ami_id"
    if grep $ami_name ../examples/multi-runner-cppal/templates/runner-configs/*.yaml ; then
        # ami is in use
        true
    else
        amis="${amis}\n${ami_id}"
    fi
done

echo " "
echo "to remove:"
echo -e "$amis"
echo " "
