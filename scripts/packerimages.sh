#!/bin/bash

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

# Set AWS profile so Packer and aws CLI use the right credentials.
# Profiles are expected in ~/.aws/credentials:
#   [tagr-packer-dev]  for dev
#   [tagr-packer-prod] for prod
if [ "$build_environment" = "dev" ]; then
    export AWS_PROFILE=tagr-packer-dev
    TF_PROFILE=tagr-dev
else
    export AWS_PROFILE=tagr-packer-prod
    TF_PROFILE=tagr-prod
fi

# Verify the AWS profiles actually exist (packer + terraform)
missing_profiles=""
for profile in "$AWS_PROFILE" "$TF_PROFILE"; do
    if ! aws configure list --profile "$profile" > /dev/null 2>&1; then
        echo "ERROR: AWS profile '$profile' not found in ~/.aws/credentials or ~/.aws/config"
        missing_profiles="$missing_profiles  $profile"$'\n'
    fi
done
if [ -n "$missing_profiles" ]; then
    echo ""
    echo "Please add these profiles to ~/.aws/credentials:"
    echo "  tagr-packer-$build_environment   (used by Packer)"
    echo "  tagr-$build_environment          (used by Terraform)"
    exit 1
fi

export AWS_MAX_ATTEMPTS=300
export AWS_POLL_DELAY_SECONDS=30

: <<'INSTALL_NOTES'
# Install Packer and Terraform on an Ubuntu laptop:

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer terraform
INSTALL_NOTES

# Builds multiple new AMI images and updates the files in examples/multi-runner-cppal/templates/runner-configs to point to those images
# Instructions: Set the imagestobuild variable. Run the script: ./packerimages.sh -e dev | tee packeroutput.out 2>&1

# ubuntu-bionic-arm64-cppal
# ubuntu-bionic-cppal
# ubuntu-focal-arm64-cppal
# ubuntu-focal-cppal
# ubuntu-jammy-arm64-cppal
# ubuntu-jammy-cppal
# ubuntu-noble-arm64-cppal
# ubuntu-noble-cppal
# ubuntu-resolute-arm64-cppal
# ubuntu-resolute-cppal
# windows-2019-cppal
# windows-2022-cppal
# windows-2025-cppal

imagestobuild="
ubuntu-bionic-arm64-cppal
ubuntu-bionic-cppal
ubuntu-focal-arm64-cppal
ubuntu-focal-cppal
ubuntu-jammy-arm64-cppal
ubuntu-jammy-cppal
ubuntu-noble-arm64-cppal
ubuntu-noble-cppal
windows-2019-cppal
windows-2022-cppal
windows-2025-cppal
"

if [ "$build_environment" = "dev" ]; then
    echo "dev environment (AWS_PROFILE=$AWS_PROFILE)"
    varfiles=(-var-file="variables.auto.pkrvars.hcl" -var-file="dev.pkrvars.hcl")
    ami_file=dev_amis.sh
else
    echo "prod environment (AWS_PROFILE=$AWS_PROFILE)"
    varfiles=(-var-file="variables.auto.pkrvars.hcl")
    ami_file=prod_amis.sh
fi

timestamp=$(date +%Y%m%d_%H%M%S)
cd ..
mainfolder=$(pwd)

# Preflight: every image must have a corresponding runner config template.
# packerimages.sh updates these templates with the new AMI name after each
# build, so they must exist before we start.
runnertemplatefolder="${mainfolder}/examples/multi-runner-cppal/templates/runner-configs"
missing_configs=""
for image in $imagestobuild; do
    runnertemplate="${runnertemplatefolder}/${image%-cppal}.yaml"
    if [ ! -f "$runnertemplate" ]; then
        echo "ERROR: runner config template not found: $runnertemplate"
        missing_configs="$missing_configs  $runnertemplate"$'\n'
    fi
done
if [ -n "$missing_configs" ]; then
    echo ""
    echo "Missing runner configs. Copy them from a similar OS, e.g.:"
    echo "  cp templates/runner-configs/ubuntu-noble.yaml templates/runner-configs/ubuntu-resolute.yaml"
    echo ""
    exit 1
fi

task(){
    set -xe
    set -o pipefail
    thisimage=$1
    echo "Building $thisimage"
    cd $mainfolder/images/$thisimage
    rm results.out || true
    packer build "${varfiles[@]}" . | tee output.out 2>&1
    echo "packer build successful" | tee results.out 2>&1
    # testing: echo "us-west-2: ami-0b5fa6619a10d7ca7" > output.out
    resultingami=$(tail -n 2 output.out | cut -d" " -f 2)
    runnertemplatefolder="${mainfolder}/examples/multi-runner-cppal/templates/runner-configs"
    bckfolder="${runnertemplatefolder}/bcks"
    runnertemplate="${thisimage%-cppal}.yaml"
    cp ${runnertemplatefolder}/${runnertemplate} ${bckfolder}/${runnertemplate}.${timestamp}
    echo "resultingami is $resultingami . runnertemplate is $runnertemplate ."
    ami_name=$(aws ec2 describe-images --owners self --query 'Images[*].[Name,ImageId]' --output text --region us-west-2 | grep ${resultingami} | cut -f 1)
    echo "ami_name is ${ami_name}"
    # github-runner-ubuntu-jammy-amd64-202306021546
    newline="filter: { 'name': ['${ami_name}'] }"
    sed -i "s/filter:.*/$newline/g" ${runnertemplatefolder}/${runnertemplate}

    # Update ami_file also, with the same value
    if ! fgrep "all_amis[$runnertemplate]=" $mainfolder/scripts/${ami_file}; then
        sed -i "s/# all_amis - keep this line/# all_amis - keep this line\nall_amis[$runnertemplate]=X/" $mainfolder/scripts/${ami_file}
    fi
    newline="all_amis[$runnertemplate]=$ami_name"
    sed -i "s/all_amis\[$runnertemplate\]=.*/$newline/g" $mainfolder/scripts/${ami_file}
    echo "build completed"
}

for image in $imagestobuild; do
  task "$image" &
done
