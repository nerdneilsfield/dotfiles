function Install-Command-Editor
{
    scoop install vim neovim-nightly helix nano -s
    scoop update vim neovim-nightly helix nano -s
}

function Install-Gui-Editor
{
    scoop install vscode sublime-text emeditor typora notepadplusplus vscode-insiders notepadnext
    scoop update vscode sublime-text emeditor typora notepadplusplus vscode-insiders notepadnext
}

function Install-Typst
{
    scoop install typst
    scoop update typst
}
