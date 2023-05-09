
# packer init .
# packer validate -evaluate-datasources .
# packer build -debug -var-file=variables.auto.pkrvars.hcl github_agent.ubuntu.pkr.hcl
# or
# packer build .
region = "us-west-2"
instance_type = "t2.xlarge"
root_volume_size_gb = 30
# Based on drone-ci dockerfiles
custom_shell_commands = [
"export OSVERSION=18.04",
"export CLANGVERSION=7.0.1",
"export CLANGDOWNLOAD=https://releases.llvm.org/7.0.1/clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz",
"sudo apt-get -o Acquire::Retries=3 update && DEBIAN_FRONTEND=noninteractive sudo apt-get -y install tzdata && sudo apt-get -o Acquire::Retries=3 install -y sudo software-properties-common rsync wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ libc++-helpers python python-pip ruby cpio pkgconf python3 python3-pip ccache libpython-dev && sudo apt-get install -y gcc-multilib g++-multilib || true",
"sudo wget $CLANGDOWNLOAD && sudo mkdir -p /usr/local/clang+llvm-$CLANGVERSION && sudo tar xf clang+llvm-$CLANGVERSION-x86_64-linux-gnu-ubuntu-$OSVERSION.tar.xz -C /usr/local/clang+llvm-$CLANGVERSION --strip-components=1",
"sudo echo export PATH=\"/usr/local/clang+llvm-$${CLANGVERSION}/bin:\\$${PATH}\" | sudo tee -a /etc/profile.d/path-set.sh > /dev/null",
"sudo chmod 755 /etc/profile.d/path-set.sh",
"if uname -p | grep -q 'x86_64'",
"then",
"sudo dpkg --add-architecture i386",
"fi",
"sudo -H pip3 install --upgrade pip",
"sudo -H pip3 install cmake",
"sudo systemctl stop unattended-upgrades",
"sudo systemctl disable unattended-upgrades",
"sudo apt-get purge -y unattended-upgrades"
]
