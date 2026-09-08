#!/bin/bash

# Delete ami and the associated snapshot

set -xe

usage() {
    echo "Usage: $0 -e <dev|prod>"
    echo "  -e  Environment (required): dev or prod"
    exit 1
}

while getopts "e:" opt; do
    case "$opt" in
        e) build_environment="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ "$build_environment" != "dev" ] && [ "$build_environment" != "prod" ]; then
    echo "ERROR: -e <dev|prod> is required"
    usage
fi

if [ "$build_environment" = "dev" ]; then
    export AWS_PROFILE=tagr-packer-dev
else
    export AWS_PROFILE=tagr-packer-prod
fi

# aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 > output.out

test="
"

amis="
ami-0159b00b458695b64
ami-0463d80d1490db63c
ami-07457454307d4b4bf
ami-093b2fd6c675f7d7d
ami-087ebf80f26eb3132
ami-069a311f1389b7fb2
ami-0f8d8bd268f8adb17
ami-056e76c38cdcc5536
ami-04b21237adf3ed3c3
ami-0d363335cffc224bf
ami-0b1d3718e5955882e
ami-0778a1c4a635bebc4
ami-01d4894d0ad25f80d
ami-0571f14640198c079
ami-0d3b58566cf14b570
ami-0768671dc40d07808
ami-085e83ff10301c7ec
ami-0e0f6bc3fbc6a8689
ami-068abef3ee7fbc0e0
ami-0739d0989697a1c04
ami-044c0d459bffc49a6
ami-0a30de2a5f0ea6e03
ami-07d6ec2a8d931d915
ami-02ef126ac2db41667
ami-0bac4a38745782f49
ami-0ea2c8fd50f1ea3d5
ami-00885e29d201224a5
ami-059967ca94370b440
ami-0f93c95b043c86d1d
ami-048452a0425888c87
ami-08648766b55e233b6
ami-06073904dd382382b
ami-09d0251efb17f50dd
ami-050841a7c19e468f7
ami-05f0ef25a7f53172f
ami-008448f14dc5ae577
ami-03e7df93747700641
ami-0ebdc3dc6a9c3bb08
ami-00eb9c2ae78b0d888
ami-0d54e39e4e84cfea0
ami-038d9925eb00254c1
ami-0441856c23809de6b
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --region $region --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --region $region --snapshot-id $SNAPSHOT; done
done
