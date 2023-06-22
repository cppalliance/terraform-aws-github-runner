
## CPPAlliance fork of terraform-aws-github-runner  

Customizations have been made in various separate directories that do not conflict with philips to facilitate rebasing or keeping up to date with the upstream repository.  

scripts/  
  packerimages.sh: A script to rebuild the AMI images with packer.  
  removeami.sh: A script to find and remove old AMIs and their associated snapshots.  

images/ :  The packer images are kept in subdirectories ending in -cppal. 

examples/multi-runner-cppal/ : The main terraform directory. This is where "terraform apply" is run.  
examples/multi-runner-cppal/templates/runner-configs : Runner configs are maintained in this dir.  

## Upgrading the repository fork  

Rebase from main.  

Check files and manually apply any updates from main:  

examples/multi-runner/  
examples/multi-runner/templates/runner-configs/  
images/ubuntu-jammy/  

Update the lambdas:  
```
cd examples/lambdas-download-cppal  
terraform apply  
```

The typical procedure to make small updates:  
```
cd examples/multi-runner-cppal/
terraform apply  
```

During a major upgrade, the least error-prone method may be to rebuild the cloud from scratch:  
```
cd examples/multi-runner-cppal/
terraform destroy  
terraform apply  

terraform output -raw webhook_secret  
```

