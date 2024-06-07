function Install-Networks-CLI-Tools
{
  $tools = @(
    "nmap",
    "netcat",
    "gping",
    "dog",
    # "bandwhich",
    "cloudflared"
  )

  foreach ($tool in $tools)
  {
    scoop install $tool
    scoop update $tool
  }
}

function Install-Networks-GUI-Tools
{
  $tools = @(
    "wireshark",
    "zenmap",
    "putty",
    "winscp",
    "filezilla",
    "mremoteng",
    "mobaXterm",
    "termius"
  )

  foreach ($tool in $tools)
  {
    scoop install $tool
    scoop update $tool
  }
}
