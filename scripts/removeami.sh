#!/bin/bash

# Delete ami and the associated snapshot

set -xe

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

amis="
ami-08a15f73bf806ebef
ami-0a39d8c9d83b466f6
ami-0b14cb9a363389185
ami-0a132872811d816c3
ami-011cb4a3a9348099b
ami-06011f572c3465bfc
ami-09bbdba8ab3b657a8
ami-0ad742239217cf6a4
ami-0ef513d6e24de5f0f
ami-05d4bcb81d25edf8a
ami-04081993e8560aef7
ami-0e777941b3113c01e
ami-063049b87893067fd
ami-089f8f40f3005d60f
ami-0816e2b760b639340
ami-0b5fa6619a10d7ca7
ami-0ea56a2a15dca9862
ami-090b1f6ca0b10ccf4
ami-0321456892193098b
ami-0e3a486b0e272e82a
ami-0ea1c75b0d0cf8d0a
ami-04bd8307440e0ca00
ami-0507dfacfd1bbf26f
ami-017a6309e7098014f
ami-0706cce0f2e0fbb44
ami-0cbb9728759ee1ec7
ami-09ccc6bbf05dc7416
ami-0efc21b86a732de1b
ami-0a7edd8728036ffc3
ami-010557a947b0a56e1
ami-0b9cfbd9b067ae9f7
ami-021b97653fb9e2b25
ami-0570bb3bd1c1687a0
ami-06c943b4f8150d762
ami-0914f6c0fabde3cbd
ami-0d1153c0af3241a2a
ami-0dcbf000f91ac74a7
ami-04fe4baf6e3bf7aac
ami-06e9d064400a6d792
ami-0cca8904efcba768a
ami-0f8d79a5e33936bed
ami-0c9a5faa41cda5d61
ami-06a78cc963eebbedd
ami-0a37252988801b01c
ami-0fc9777696158b93c
ami-00b79f14bdd1d1eff
ami-0c76d2c158d5655a9
ami-06616508c110eaf8f
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --snapshot-id $SNAPSHOT; done
done

