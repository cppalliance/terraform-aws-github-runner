
# packer init .
# packer validate -evaluate-datasources .
# packer build -debug -var-file=variables.auto.pkrvars.hcl github_agent.windows.pkr.hcl
# or
# packer build . | tee output.out 2>&1
region = "us-west-2"
instance_type = "t3.xlarge"
# 2024-09 size was 70. Add 10 for the jobs, and 10 for the pagefile.
# then another 10 for the pagefile.
root_volume_size_gb = 100
ssh_keypair_name = "cppalliance-us-west-2-kp"
ssh_private_key_file = "/root/.ssh/cppalliance-us-west-2-kp.pem"

custom_shell_commands = [
"Set-PSDebug -Trace 1",
"cd C:\\",
"choco feature disable --name='ignoreInvalidOptionsSwitches'",
"New-Item -Path 'c:\\tmp' -ItemType Directory -Force",
"Write-Output 'packages.prebuild.noversions.config:'",
"Get-Content c:\\tmp\\packages.prebuild.noversions.config",
"Write-Output 'packages.prebuild.versions.config:'",
"Get-Content c:\\tmp\\packages.prebuild.versions.config",
"choco feature enable -n allowGlobalConfirmation",
"choco install -y visualstudio2022buildtools --parameters  '--add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.CMake.Project'",
"choco install -y cmake.install --installargs '\"ADD_CMAKE_TO_PATH=System\"'",
"choco upgrade -y visualstudio2022-workload-vctools --package-parameters '--add Microsoft.VisualStudio.Component.VC.14.42.17.12.x86.x64 --add Microsoft.VisualStudio.Component.VC.14.29.16.11.x86.x64 --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 --add Microsoft.VisualStudio.Component.VC.140'",
"choco install -y C:\\tmp\\packages.prebuild.versions.config",
"New-Item -ItemType SymbolicLink -Path \"C:\\Git\" -Target \"C:\\Program Files\\Git\"",
"$${oldpath} = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\Environment' -Name PATH).path",
"$${newpath} = \"C:\\Git\\usr\\bin;$${oldpath}\"",
"Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\Environment' -Name PATH -Value $${newPath}",
"# These files needed by msvc 14.0:",
"copy \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\10.0.18362.0\\x64\\rc.exe\" \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\x86\\rc.exe\"",
"copy \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\10.0.18362.0\\x64\\rcdll.dll\" \"C:\\Program Files (x86)\\Windows Kits\\10\\bin\\x86\\rcdll.dll\"",

"net user /add Administrator2 Testwin1234!",
"net localgroup administrators Administrator2 /add",
"Set-LocalUser -Name 'Administrator2' -PasswordNeverExpires 1",

" # Set page file",
"$ComputerSystem = Get-WmiObject -ClassName Win32_ComputerSystem",
"$ComputerSystem.AutomaticManagedPagefile = $false",
"$ComputerSystem.Put()",
"$PageFileSetting = Get-WmiObject -ClassName Win32_PageFileSetting",
"$PageFileSetting.InitialSize = 20000",
"$PageFileSetting.MaximumSize = 20000",
"$PageFileSetting.Put()",

"Write-Output 'Choco done. exporting packages'",
"choco export --output-file-path='c:\\tmp\\packages.postbuild.versions.config' --include-version-numbers",
"Write-Output 'packages.postbuild.versions.config:'",
"Get-Content c:\\tmp\\packages.postbuild.versions.config",
"choco export --output-file-path='c:\\tmp\\packages.postbuild.noversions.config'",
"Write-Output 'packages.postbuild.noversions.config:'",
"Get-Content c:\\tmp\\packages.postbuild.noversions.config",
"echo __done__"
]
