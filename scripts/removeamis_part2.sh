#!/bin/bash

# Delete ami and the associated snapshot

set -xe

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

test="
"

amis="
ami-0634124047903c1ed
ami-0841a945303463903
ami-09944338a248c5b89
ami-0c7a489e7f048f53e
ami-0668a7bad2329a87c
ami-0426bd562cd051f30
ami-00ec5f9bb8f5a19fa
ami-0d3905ec987855806
ami-029863b793a310918
ami-0c09b40136606c789
ami-07cb842ccc3adaecf
ami-0927ba164cbc67862
ami-01fa5982bda798944
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --snapshot-id $SNAPSHOT; done
done
