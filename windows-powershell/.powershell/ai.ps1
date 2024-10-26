function Install-AI-Soft
{
    $ai_soft=@(
        "aichat",
        "openai-translator"
    )
    foreach ($soft in $ai_soft)
    {
        scoop install $soft
        scoop update $soft
    }
}

