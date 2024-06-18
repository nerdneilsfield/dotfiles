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

function Install-PDF-Tools
{
    scoop install sumatrapdf sioyek
    scoop update sumatrapdf sioyek
    winget install pympress
}
