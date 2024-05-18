# Windows Powershell Profile

## Usage

install `dploy` to deploy the profile

[dploy](https://github.com/arecarn/dploy)


```powershell
# use admin powershell
# run under dotfiles directory
# python -m dploy stow .\windows-powershell $HOME
New-Item -ItemType Junction -Path "$HOME\.powershell" -Target "$PWD\windows-powershell\.powershell"

Remove-Item $PROFILE
New-Item -ItemType SymbolicLink -Path "$PROFILE" -Target "$PWD\windows-powershell\init.ps1" 
```
