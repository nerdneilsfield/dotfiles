function Install-AI-Soft {
    $ai_soft=@(
        "aichat",
        "ollama"
    )
    foreach ($soft in $ai_soft) {
        scoop install $soft
    }
}

