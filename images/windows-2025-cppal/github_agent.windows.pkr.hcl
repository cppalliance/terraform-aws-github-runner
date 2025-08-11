packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ssh_keypair_name" {
  description = "SSH keypair name"
  type        = string
  default     = null
}

variable "ssh_private_key_file" {
  description = "SSH private key file"
  type        = string
  default     = null
}

variable "disable_docker_registry" {
  description = "SSH private key file"
  type        = string
  default     = "false"
}

variable "runner_version" {
  description = "The version (no v prefix) of the runner software to install https://github.com/actions/runner/releases. The latest release will be fetched from GitHub if not provided."
  default     = null
}

variable "region" {
  description = "The region to build the image in"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "The instance type Packer will use for the builder"
  type        = string
  default     = "t3a.medium"
}

variable "iam_instance_profile" {
  description = "IAM instance profile Packer will use for the builder. An empty string (default) means no profile will be assigned."
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "The ID of the security group Packer will associate with the builder to enable access"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "If using VPC, the ID of the subnet, such as subnet-12345def, where Packer will launch the EC2 instance. This field is required if you are using an non-default VPC"
  type        = string
  default     = null
}

variable "root_volume_size_gb" {
  type    = number
  default = 30
}

variable "ebs_delete_on_termination" {
  description = "Indicates whether the EBS volume is deleted on instance termination."
  type        = bool
  default     = true
}

variable "associate_public_ip_address" {
  description = "If using a non-default VPC, there is no public IP address assigned to the EC2 instance. If you specified a public subnet, you probably want to set this to true. Otherwise the EC2 instance won't have access to the internet"
  type        = string
  default     = null
}

variable "custom_shell_commands" {
  description = "Additional commands to run on the EC2 instance, to customize the instance, like installing packages"
  type        = list(string)
  default     = []
}

variable "temporary_security_group_source_public_ip" {
  description = "When enabled, use public IP of the host (obtained from https://checkip.amazonaws.com) as CIDR block to be authorized access to the instance, when packer is creating a temporary security group. Note: If you specify `security_group_id` then this input is ignored."
  type        = bool
  default     = false
}

data "http" github_runner_release_json {
  url = "https://api.github.com/repos/actions/runner/releases/latest"
  request_headers = {
    Accept = "application/vnd.github+json"
    X-GitHub-Api-Version : "2022-11-28"
  }
}

locals {
  runner_version = coalesce(var.runner_version, trimprefix(jsondecode(data.http.github_runner_release_json.body).tag_name, "v"))
}

source "amazon-ebs" "githubrunner" {
  ssh_keypair_name            = var.ssh_keypair_name
  ssh_private_key_file        = var.ssh_private_key_file
  ami_name                    = "github-runner-windows-2025-amd64-${formatdate("YYYYMMDDhhmm", timestamp())}"
  communicator                = "winrm"
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile
  region                      = var.region
  security_group_id           = var.security_group_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  temporary_security_group_source_public_ip = var.temporary_security_group_source_public_ip

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2025-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  tags = {
    OS_Version    = "windows-core-2025"
    Release       = "Latest"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }
  user_data_file = "./bootstrap_win.ps1"
  winrm_insecure = true
  winrm_port     = 5986
  winrm_use_ssl  = true
  winrm_username = "Administrator"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "${var.root_volume_size_gb}"
    delete_on_termination = "${var.ebs_delete_on_termination}"
  }
}

build {
  name = "githubactions-runner"
  sources = [
    "source.amazon-ebs.githubrunner"
  ]

  provisioner "file" {
    content = templatefile("../start-runner.ps1", {
      start_runner = templatefile("../../modules/runners/templates/start-runner.ps1", {})
    })
    destination = "C:\\start-runner.ps1"
  }

  provisioner "file" {
  content = <<EOT
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="7zip.install" />
  <package id="awscli" />
  <package id="chocolatey" />
  <package id="chocolatey-compatibility.extension" />
  <package id="chocolatey-core.extension" />
  <package id="chocolatey-dotnetfx.extension" />
  <package id="chocolatey-visualstudio.extension" />
  <package id="chocolatey-windowsupdate.extension" />
  <package id="curl" />
  <package id="dotnetfx" />
  <package id="git" />
  <package id="git.install" />
  <package id="hashdeep" />
  <package id="jq" />
  <package id="KB2919355" />
  <package id="KB2919442" />
  <package id="KB2999226" />
  <package id="KB3033929" />
  <package id="KB3035131" />
  <package id="llvm" />
  <package id="microsoft-build-tools" />
  <package id="mingw" />
  <package id="notepadplusplus" />
  <package id="notepadplusplus.install" />
  <package id="python" />
  <package id="python3" />
  <package id="python313" />
  <package id="rsync" />
  <package id="ruby" />
  <package id="ruby.install" />
  <package id="vcredist140" />
  <package id="vcredist2015" />
  <package id="vcredist2017" />
  <package id="visualstudio2017buildtools" />
  <package id="visualstudio-installer" />
  <package id="Wget" />
  <package id="windows-sdk-10.1" />
  <package id="winscp" />
  <package id="winscp.install" />
</packages>
EOT

    destination = "C:\\tmp\\packages.prebuild.noversions.config"
  }

  provisioner "file" {
  content = <<EOT
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="7zip.install" version="22.1" />
  <package id="awscli" version="2.24.17" />
  <package id="chocolatey" version="2.4.3" />
  <package id="chocolatey-compatibility.extension" version="1.0.0" />
  <package id="chocolatey-core.extension" version="1.4.0" />
  <package id="chocolatey-dotnetfx.extension" version="1.0.1" />
  <package id="chocolatey-visualstudio.extension" version="1.11.1" />
  <package id="chocolatey-windowsupdate.extension" version="1.0.5" />
  <package id="curl" version="8.12.1" />
  <package id="dotnetfx" version="4.8.0.20220524" />
  <package id="git" version="2.48.1" />
  <package id="git.install" version="2.48.1" />
  <package id="hashdeep" version="4.4" />
  <package id="jq" version="1.7.1" />
  <package id="KB2919355" version="1.0.20160915" />
  <package id="KB2919442" version="1.0.20160915" />
  <package id="KB2999226" version="1.0.20181019" />
  <package id="KB3033929" version="1.0.5" />
  <package id="KB3035131" version="1.0.3" />
  <package id="llvm" version="19.1.7" />
  <package id="microsoft-build-tools" version="15.0.26320.2" />
  <package id="mingw" version="13.2.0" />
  <package id="notepadplusplus" version="8.7.7" />
  <package id="notepadplusplus.install" version="8.7.7" />
  <package id="python" version="3.13.1" />
  <package id="python3" version="3.13.1" />
  <package id="python313" version="3.13.1" />
  <package id="rsync" version="6.3.0" />
  <package id="ruby" version="3.4.1.1" />
  <package id="ruby.install" version="3.4.1.1" />
  <package id="vcredist140" version="14.42.34438.20250221" />
  <package id="vcredist2015" version="14.0.24215.20170201" />
  <package id="vcredist2017" version="14.16.27052" />
  <package id="visualstudio2017buildtools" version="15.9.70" />
  <package id="visualstudio-installer" version="2.0.3" />
  <package id="Wget" version="1.21.4" />
  <package id="windows-sdk-10.1" version="10.1.18362.1" />
  <package id="winscp" version="6.3.7" />
  <package id="winscp.install" version="6.3.7" />
</packages>
EOT
    destination = "C:\\tmp\\packages.prebuild.versions.config"
  }

  provisioner "powershell" {
    inline = concat([
      templatefile("./windows-provisioner.ps1", {
        action_runner_url = "https://github.com/actions/runner/releases/download/v${local.runner_version}/actions-runner-win-x64-${local.runner_version}.zip"
      })
    ], var.custom_shell_commands)
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }

}
