
# packer init .
# packer validate -evaluate-datasources .
# packer build -debug -var-file=variables.auto.pkrvars.hcl github_agent.ubuntu.pkr.hcl
# or
# packer build .
region = "us-west-2"
instance_type = "t4g.xlarge"
tester1="$${PATH}"
root_volume_size_gb = 30
ssh_keypair_name = "cppalliance-us-west-2-kp"
ssh_private_key_file = "/root/.ssh/cppalliance-us-west-2-kp.pem"

custom_shell_commands = [
"set -xe",
"sudo mkdir -p /etc/apt/apt.conf.d/",
"echo 'APT::Acquire::Retries \"10\";' | sudo tee /etc/apt/apt.conf.d/80-retries",
"echo 'APT::Get::Assume-Yes \"true\";' | sudo tee /etc/apt/apt.conf.d/90assumeyes",
"DEBIAN_FRONTEND=noninteractive sudo apt-get -y install tzdata && sudo apt-get -o Acquire::Retries=3 install -y sudo software-properties-common wget curl apt-transport-https git make apt-file sudo unzip libssl-dev build-essential autotools-dev autoconf automake g++ g++-12 python3 python3-pip rsync ruby cpio pkgconf ccache locales cmake python-is-python3",
"sudo apt-get install -y gcc-multilib || true",
"sudo apt-get install -y g++-multilib || true",
"sudo apt-add-repository ppa:git-core/ppa",
"sudo apt-get -o Acquire::Retries=3 update && sudo apt-get -o Acquire::Retries=3 -y install git",
"sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y",
"sudo apt-get update -y",
"sudo apt-get install -y clang-16 clang-17 clang-18",
"echo Place custom LLVM install here",
"# if uname -p | grep -q 'x86_64'",
"# then",
"# sudo dpkg --add-architecture i386",
"# fi",
"sudo systemctl stop unattended-upgrades",
"sudo systemctl disable unattended-upgrades",
"sudo apt-get purge -y unattended-upgrades",
"sudo systemctl disable apt-daily-upgrade.timer",
"sudo systemctl stop apt-daily-upgrade.timer",
"sudo systemctl disable apt-daily.timer",
"sudo systemctl stop apt-daily.timer",
"$DISABLE_DOCKER_REGISTRY || echo '{\n  \"insecure-registries\":[\"docker-registry-lb-1.cpp.al\"],\n  \"registry-mirrors\": [\"http://docker-registry-lb-1.cpp.al\"]\n }' | sudo tee /etc/docker/daemon.json"
]

# # Custom LLVM install. Switching to standard clang packages.
# "echo start LLVM install",
# "export CLANGVERSION=14.0.3",
# "export LLVMTAG=llvmorg-14.0.3",
# "export LLVMDIR=clang+llvm-14.0.3",
# "export CPUS=4",
# "sudo mkdir -p /opt/github",
# "cd /opt/github",
# "sudo git clone -b $LLVMTAG https://github.com/llvm/llvm-project.git",
# "cd llvm-project",
# "sudo mkdir build",
# "cd build",
# "sudo cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' -DLLVM_ENABLE_RUNTIMES='libcxx;libcxxabi;libc' -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX=/usr/local/$LLVMDIR ../llvm",
# "sudo cmake --build . -j $CPUS",
# "sudo cmake --install .",
# "cd ../..",
# "sudo rm -rf llvm-project",
# "sudo echo export PATH=\"/usr/local/clang+llvm-$${CLANGVERSION}/bin:\\$${PATH}\" | sudo tee -a /etc/profile.d/path-set.sh > /dev/null",
# "sudo chmod 755 /etc/profile.d/path-set.sh",
# "echo finished LLVM install",
