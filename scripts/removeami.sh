#!/bin/bash

# Delete ami and the associated snapshot

set -xe

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

amis="
ami-04aabf193c156dd72
ami-08a1f288959c2d8cc
ami-0c802449bdf8d981e
ami-0a2e8524783d512eb
ami-029f82a5bf6a7d634
ami-0c549427a64402d3a
ami-08b6c8a835ed9332b
ami-0ac23aae25fdc4df9
ami-0a04141dcc0980740
ami-00a47faeeb02d03f0
ami-0e6220d742fc51b57
ami-09035050dec8b0d4d
ami-0fb62047befcdd856
ami-0d3cb1d97dab8043f
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --snapshot-id $SNAPSHOT; done
done

