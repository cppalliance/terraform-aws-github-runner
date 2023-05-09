#!/bin/bash

# Delete ami and the associated snapshot

set -xe

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

amis="
ami-0b27952440107e7bb	
ami-0303f1c3f899ab0c0
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --snapshot-id $SNAPSHOT; done
done

