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
ami-00c5c20424985b693
ami-04e2f4f55b86f6bc5
ami-0d3ed736688b4a7e8
ami-02a2cadb3c8b074d9
ami-05645b656a4ba6119
ami-0b59d1579d6e77412
ami-0ae0b9b5a5397b564
ami-0131e050af792e166
ami-09a32e3151e406831
ami-0a49ef7c9296b9a90
ami-02d5b60d42beb3207
ami-0e2ba4f8eb7b40f3c
ami-050d271bd9f95d839
ami-08e34ea4fda08a602
ami-0a6438816509dd170
ami-06a5764bc858f04fc
ami-0db5c3de0dbadefbe
ami-00838559152ade588
ami-0a852bf80c6fedcec
ami-0ced4d45664f2ddbb
ami-0055dfe858716e721
ami-066933d4f3af15003
ami-05bd1912d71bc35aa
ami-01a9a23e6a127b282
ami-06f69ac13aefb726d
ami-08915d682e5aa8332
ami-0275cd6d99cf47198
ami-01d7a16a51e718780
ami-070a420c5613bc2ed
ami-039061904b8542322
ami-09b31bf6e84899b03
ami-01aaf45c1ad1dd335
ami-0984a51a7c985bc24
ami-04121226d36282f70
ami-06a517f98ded7f6a1
ami-07340de2b46a93104
ami-027ad6c9754840181
ami-0577088e19057d9dc
ami-085e6d9e9e11cfa5a
ami-085aa9a953756d2ac
ami-0ed821b5f3d2e2ecb
ami-0de752130b93ed6b3
ami-0f73fa700e5d6bd57
ami-0842adc2fbd1047d1
ami-03ec95da5522a4ede
ami-0f998d80bc8a7ac31
ami-0b61a11f6d7cdb17c
ami-0a06d60638ba4cb9c
ami-0d194afafa1ba374e
ami-0467945db4b0d50a8
ami-0055713482f5a0689
ami-05884447a7beeb78b
"

region=us-west-2

for ami in ${amis}; do
    echo ami is ${ami}
    snapshots="$(aws ec2 describe-images --image-ids ${ami} --region $region --query 'Images[*].BlockDeviceMappings[*].Ebs.SnapshotId' --output text)"
    echo $snapshots
    aws ec2 deregister-image --region $region --image-id ${ami}
    for SNAPSHOT in $snapshots ; do aws ec2 delete-snapshot --region $region --snapshot-id $SNAPSHOT; done
done
