function Install-Go
{
  $tools = @(
    "go",
    "goreleaser"
  )
  foreach ($tool in $tools)
  {
    Green-Echo "=======install $tool========="
    scoop install $tool
    scoop update $tool
  }
}


function Set-GoPath()
{
  param(
    [string]$Path
  )
  if ($Path -eq "")
  {
    Write-Error "Usage: Set-GoPath <path>"
    return
  }

  [Environment]::SetEnvironmentVariable("GOPATH", $Path, "User")
}

function Goto-GoPath()
{
  if ($null -eq [System.Environment]::GetEnvironmentVariable("GOPATH"))
  {
    Write-Error "GOPATH is not set, please set it first"
    return
  }

  Set-Location $env:GOPATH
}
