
# packer init .
# packer validate -evaluate-datasources .
# packer build -debug -var-file=variables.auto.pkrvars.hcl github_agent.ubuntu.pkr.hcl
# or
# packer build .
region = "us-west-2"
instance_type = "t4g.xlarge"
root_volume_size_gb = 30
ssh_keypair_name = "cppalliance-us-west-2-kp"
ssh_private_key_file = "/root/.ssh/cppalliance-us-west-2-kp.pem"

custom_shell_commands = [
"set -xe",
"env",
"sudo mkdir -p /etc/apt/apt.conf.d/",
"echo 'APT::Acquire::Retries \"10\";' | sudo tee /etc/apt/apt.conf.d/80-retries",
"echo 'APT::Get::Assume-Yes \"true\";' | sudo tee /etc/apt/apt.conf.d/90assumeyes",
"sudo apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive sudo apt-get -y install tzdata && sudo apt-get -o Acquire::Retries=3 install -y sudo software-properties-common rsync wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ libc++-helpers python python-pip ruby cpio pkgconf python3 python3-pip ccache libpython-dev && sudo apt-get install -y gcc-multilib g++-multilib || true",
"sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y",
"sudo apt-get update -y",
"sudo apt-get install -y clang-9",
"echo Place custom LLVM install here",
"if uname -p | grep -q 'x86_64'",
"then",
"sudo dpkg --add-architecture i386",
"fi",
"sudo -H pip3 install --upgrade pip",
"sudo -H pip3 install cmake",
"sudo systemctl stop unattended-upgrades",
"sudo systemctl disable unattended-upgrades",
"sudo apt-get purge -y unattended-upgrades",
"$DISABLE_DOCKER_REGISTRY || echo '{\n  \"insecure-registries\":[\"docker-registry-lb-1.cpp.al\"],\n  \"registry-mirrors\": [\"http://docker-registry-lb-1.cpp.al\"]\n }' | sudo tee /etc/docker/daemon.json"
]

# # Custom LLVM install. Switching to standard clang packages
# "export OSVERSION=18.04",
# "export CLANGVERSION=7.0.1",
# "export CLANGDOWNLOAD=https://releases.llvm.org/7.0.1/clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz",
# "sudo wget $CLANGDOWNLOAD && sudo mkdir -p /usr/local/clang+llvm-$CLANGVERSION && sudo tar xf clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz -C /usr/local/clang+llvm-$CLANGVERSION --strip-components=1",
# "sudo echo export PATH=\"/usr/local/clang+llvm-$${CLANGVERSION}/bin:\\$${PATH}\" | sudo tee -a /etc/profile.d/path-set.sh > /dev/null",
# "sudo chmod 755 /etc/profile.d/path-set.sh",
