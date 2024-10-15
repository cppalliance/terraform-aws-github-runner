#!/bin/bash

# Delete ami and the associated snapshot

set -xe

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

test="
"

amis="
ami-05feff530e1a4a834
ami-05c6de2225452c8c2
ami-0862bbc2ea5687509
ami-09882530fd7b06926
ami-0fff460fae7935005
ami-08eafe65cbe92778b
ami-0c64e333fe0ccbb5c
ami-033177fd61cf8e25d
ami-08c16a272765a8f02
ami-0d62ce7834b283d88
ami-069040f193ba209a3
ami-085b225767c4ac0c7
ami-0ad135e7fd0f1313f
ami-01fb6887bb9bcf622
ami-022b4860aba5be25a
ami-0376b5b60450d00e2
ami-03f7786eb74e843b5
ami-0f8b73d040984706b
ami-0b1c489b5f9982c70
ami-0e6f3607a741c7f9c
ami-0d15c32796376f610
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --snapshot-id $SNAPSHOT; done
done
