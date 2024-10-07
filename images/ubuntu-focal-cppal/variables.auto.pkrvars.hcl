
# packer init .
# packer validate -evaluate-datasources .
# packer build -debug -var-file=variables.auto.pkrvars.hcl github_agent.ubuntu.pkr.hcl
# or
# packer build .
region = "us-west-2"
instance_type = "t2.xlarge"
root_volume_size_gb = 30
custom_shell_commands = [
"set -xe",
"sudo mkdir -p /etc/apt/apt.conf.d/",
"echo 'APT::Acquire::Retries \"10\";' | sudo tee /etc/apt/apt.conf.d/80-retries",
"echo 'APT::Get::Assume-Yes \"true\";' | sudo tee /etc/apt/apt.conf.d/90assumeyes",
"sudo apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive sudo apt-get -y install tzdata && sudo apt-get -o Acquire::Retries=3 install -y sudo software-properties-common rsync wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ python3 python3-pip ruby cpio pkgconf ccache && sudo apt-get install -y gcc-multilib || true && sudo apt-get install -y g++-multilib || true",
"sudo apt-add-repository ppa:git-core/ppa",
"sudo apt-get -o Acquire::Retries=3 update && sudo apt-get -o Acquire::Retries=3 -y install git",
"sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y",
"sudo apt-get update -y",
"sudo apt-get install -y clang-10 clang-11 clang-12",
"echo Place custom LLVM install here",
"sudo ln -s /usr/bin/python3 /usr/bin/python",
"sudo -H pip3 install cmake",
"if uname -p | grep -q 'x86_64'",
"then",
"sudo dpkg --add-architecture i386",
"fi",
"sudo systemctl stop unattended-upgrades",
"sudo systemctl disable unattended-upgrades",
"sudo apt-get purge -y unattended-upgrades",
"sudo systemctl disable apt-daily-upgrade.timer || true",
"sudo systemctl stop apt-daily-upgrade.timer || true",
"sudo systemctl disable apt-daily.timer || true",
"sudo systemctl stop apt-daily.timer || true",

"$DISABLE_DOCKER_REGISTRY || echo '{\n  \"insecure-registries\":[\"docker-registry-lb-1.cpp.al\"],\n  \"registry-mirrors\": [\"http://docker-registry-lb-1.cpp.al\"]\n }' | sudo tee /etc/docker/daemon.json"
]

# # custom LLVM install. Switching to standard clang packages.
# "export OSVERSION=20.04",
# "export CLANGVERSION=11.0.0",
# "export CLANGDOWNLOAD=https://github.com/llvm/llvm-project/releases/download/llvmorg-$CLANGVERSION/clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz",
# "sudo wget $CLANGDOWNLOAD && sudo mkdir -p /usr/local/clang+llvm-$CLANGVERSION && sudo tar xf clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz -C /usr/local/clang+llvm-$CLANGVERSION --strip-components=1",
# "sudo echo export PATH=\"/usr/local/clang+llvm-$${CLANGVERSION}/bin:\\$${PATH}\" | sudo tee -a /etc/profile.d/path-set.sh > /dev/null",
# "sudo chmod 755 /etc/profile.d/path-set.sh",
