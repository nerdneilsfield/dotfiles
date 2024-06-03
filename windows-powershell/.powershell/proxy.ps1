Install-Proxy-Soft {
    $proxy_tools=@(
        "sing-box",
        "mihomo",
        "clash-verge-rev",
        "wireguard-ng",
        "tailscale"
    )
    foreach ($tool in $proxy_tools)
    {
        Green-Echo "=======install $tool========="
        scoop install $tool
    }
}
