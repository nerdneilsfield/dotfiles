function Install-Zigup
{
  scoop uninstall zig
  scoop install zigup
  scoop update zigup
}

function Install-Zig
{
  zigup --install-dir $env:USERPROFILE/.local/bin master
}
