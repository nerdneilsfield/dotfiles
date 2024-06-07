# Green-Echo "=======windows.ps1 sourced========="

function Install-WindowsTools
{
  $tools = @(
    "windirstat",
    "everything",
    "listary",
    "ditto",
    "Flow-Launcher"
  )
  foreach ($tool in $tools)
  {
    Green-Echo "=======install $tool========="
    scoop install $tool
    scoop update $tool
  }
}
