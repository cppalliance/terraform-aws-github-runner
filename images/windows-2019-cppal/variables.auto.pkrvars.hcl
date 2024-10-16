
# packer init .
# packer validate -evaluate-datasources .
# packer build -debug -var-file=variables.auto.pkrvars.hcl github_agent.windows.pkr.hcl
# or
# packer build . | tee output.out 2>&1
region = "us-west-2"
instance_type = "t2.xlarge"
# 2019 set to 70GB. 2022 60GB, for now.
root_volume_size_gb = 70
ssh_keypair_name = "cppalliance-us-west-2-kp"
ssh_private_key_file = "/root/.ssh/cppalliance-us-west-2-kp.pem"

custom_shell_commands = [
"Set-PSDebug -Trace 1",
"cd C:\\",
"# already installed: powershell -Command iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))",
"choco feature enable -n allowGlobalConfirmation",
"choco install -y visualstudio2017buildtools --version 15.9.18.0",
"choco install -y 7zip.install --version 19.0",
"choco install -y chocolatey --version 0.12.1",
"# already installed:",
"choco install -y chocolatey-core.extension",
"choco install -y chocolatey-dotnetfx.extension",
"choco install -y chocolatey-fastanswers.extension",
"choco install -y chocolatey-visualstudio.extension",
"choco install -y chocolatey-windowsupdate.extension",
"# cmake not in path without extra flag",
"# choco install -y cmake.install --version 3.16.2 --installargs '\"ADD_CMAKE_TO_PATH=System\"'",
"choco install -y cmake.install --version 3.27.0 --installargs '\"ADD_CMAKE_TO_PATH=System\"'",
"choco install -y curl --version 7.68.0",
"choco install -y DotNet4.5.2 --version 4.5.2.20140902",
"choco install -y DotNet4.6 --version 4.6.00081.20150925",
"choco install -y DotNet4.6-TargetPack --version 4.6.00081.20150925",
"choco install -y DotNet4.6.1 --version 4.6.01055.20170308",
"# This is already the dotnet image",
"# choco install -y dotnetfx --version 4.8.0.20190930",
"choco install -y git.install --version 2.25.0",
"choco install -y hashdeep --version 4.4",
"choco install -y jq --version 1.6",
"choco install -y KB2919355 --version 1.0.20160915",
"choco install -y KB2919442 --version 1.0.20160915",
"choco install -y KB2999226 --version 1.0.20181019",
"choco install -y KB3033929 --version 1.0.5",
"choco install -y KB3035131 --version 1.0.3",
"choco install -y llvm --version 9.0.0",
"choco install -y microsoft-build-tools --version 15.0.26320.2",
"choco install -y mingw --version 12.2.0.03042023",
"choco install -y netfx-4.5.1-devpack --version 4.5.50932",
"choco install -y netfx-4.5.2-devpack --version 4.5.5165101.20180721",
"choco install -y netfx-4.6.1-devpack --version 4.6.01055.00",
"choco install -y rsync --version 5.5.0.20190204",
"choco install -y ruby --version 2.7.0.1",
"choco install -y vcredist140 --version 14.24.28127.4",
"choco install -y vcredist2017 --version 14.16.27033",
"choco install -y visualstudio-installer --version 2.0.2",
"choco install -y visualstudio2017-workload-netcorebuildtools --version 1.1.2",
"choco install -y visualstudio2017-workload-vctools --version 1.3.2",
"choco install -y visualstudio2017-workload-webbuildtools --version 1.3.2",
"choco install -y Wget --version 1.20.3.20190531",
"choco install -y windows-sdk-10.1 --version 10.1.18362.1",
"choco install -y winscp --version 5.15.9",
"choco install -y winscp.install --version 5.15.9",
"# wsl error. skip for now.",
"# choco install -y wsl --version 1.0.1",
"choco install -y python --version 3.8.3",
"New-Item -ItemType SymbolicLink -Path \"C:\\Git\" -Target \"C:\\Program Files\\Git\"",
"# Adding visualstudio2019",
"choco install visualstudio2019-workload-vctools --package-parameters \"--add Microsoft.VisualStudio.Component.VC.140\" \"--add Microsoft.VisualStudio.Component.VC.14.29.x86.x64\" -y",
"$${oldpath} = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\Environment' -Name PATH).path",
"$${newpath} = \"C:\\Git\\usr\\bin;$${oldpath}\"",
"Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\Environment' -Name PATH -Value $${newPath}",
"copy \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\10.0.18362.0\\x64\\rc.exe\" \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\x86\\rc.exe\"",
"copy \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\10.0.18362.0\\x64\\rcdll.dll\" \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\x86\\rcdll.dll\"",
"net user /add Administrator2 Testwin1234!",
"net localgroup administrators Administrator2 /add",
"Set-LocalUser -Name 'Administrator2' -PasswordNeverExpires 1",
"echo __done__"
]
