#!/bin/bash

# Delete ami and the associated snapshot

set -xe

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

test="
"

amis="
ami-0277289baef564826
ami-0ff57019d58bc9864
ami-0b96e11dcf82c291b
ami-062ad1cc2717270dd
ami-0801bbce25c2c36e4
ami-0ba0f860382ff00e0
ami-051a8bf1576abee25
ami-0abe5c21e1b8652d1
ami-0c24080c9e1ecdf92
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --snapshot-id $SNAPSHOT; done
done
