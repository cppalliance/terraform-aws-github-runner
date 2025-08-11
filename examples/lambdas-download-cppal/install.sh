#!/bin/bash

set -xe

terraform init -upgrade
terraform init
# terraform apply -var=module_version=v3.3.0
# terraform apply -var=module_version=v3.4.2
terraform apply -var=module_version=v6.7.3
