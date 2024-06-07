function Install-Gcc
{
  scoop install gcc
  scoop update gcc
}

function Install-Clang
{
  scoop install llvm
  scoop update llvm
}

function Install-CCTools
{
  Install-Gcc
  Install-Clang

  $tools = @(
    "make",
    "cmake",
    "ninja",
    "xmake",
    # "mold",
    "cppcheck",
    "vcpkg"
  )

  foreach ($tool in $tools)
  {
    Green-Echo "=======install $tool========="
    scoop install $tool
    scoop update $tool
  }
}

function Set-CC
{
  if ($args.Count -eq 0)
  {
    Write-Error "Usage: Set-CC <tool>"
    return
  }

  switch ($args[0])
  {
    "gcc"
    { 
      Set-Evn "CC" "gcc"
      Set-Env "CXX" "g++"
    }
    "clang"
    { 
      Set-Env "CC" "clang"
      Set-Env "CXX" "clang++"
    }
    default
    { Write-Error "Unknown tool: $args[0]" 
    }
  }
}

if (Get-Command vcpkg -ErrorAction SilentlyContinue)
{
  Import-Module $env:SCOOP\apps\vcpkg\current\scripts\posh-vcpkg
}
