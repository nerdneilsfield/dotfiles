# 开发环境集成
# 提供版本管理器、项目脚手架、容器工具等开发环境支持

# 安装版本管理器
function Install-VersionManagers {
    [CmdletBinding()]
    param(
        [switch]$Node,
        [switch]$Python, 
        [switch]$Rust,
        [switch]$Go,
        [switch]$All
    )
    
    if ($All) {
        $Node = $Python = $Rust = $Go = $true
    }
    
    Write-Host "🛠️ 安装版本管理器..." -ForegroundColor Green
    
    if ($Node) {
        Write-Host "📦 安装 Node.js 版本管理器 (fnm)..." -ForegroundColor Yellow
        if (-not (Get-Command fnm -ErrorAction SilentlyContinue)) {
            try {
                if (Get-Command scoop -ErrorAction SilentlyContinue) {
                    scoop install fnm
                } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
                    winget install Schniz.fnm
                } else {
                    Write-Warning "需要 Scoop 或 Winget 来安装 fnm"
                }
            } catch {
                Write-Warning "安装 fnm 失败: $_"
            }
        } else {
            Write-Host "✅ fnm 已安装" -ForegroundColor Green
        }
    }
    
    if ($Python) {
        Write-Host "🐍 安装 Python 版本管理器 (pyenv-win)..." -ForegroundColor Yellow
        if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
            try {
                if (Get-Command scoop -ErrorAction SilentlyContinue) {
                    scoop install pyenv
                } else {
                    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; ./install-pyenv-win.ps1
                }
            } catch {
                Write-Warning "安装 pyenv-win 失败: $_"
            }
        } else {
            Write-Host "✅ pyenv 已安装" -ForegroundColor Green
        }
    }
    
    if ($Rust) {
        Write-Host "🦀 安装 Rust 工具链 (rustup)..." -ForegroundColor Yellow
        if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
            try {
                if (Get-Command scoop -ErrorAction SilentlyContinue) {
                    scoop install rustup
                } else {
                    Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile "rustup-init.exe"
                    ./rustup-init.exe -y
                    Remove-Item "rustup-init.exe"
                }
            } catch {
                Write-Warning "安装 rustup 失败: $_"
            }
        } else {
            Write-Host "✅ rustup 已安装" -ForegroundColor Green
        }
    }
    
    if ($Go) {
        Write-Host "🐹 安装 Go 版本管理器 (g)..." -ForegroundColor Yellow
        if (-not (Get-Command g -ErrorAction SilentlyContinue)) {
            try {
                if (Get-Command scoop -ErrorAction SilentlyContinue) {
                    scoop install g
                } else {
                    Write-Warning "需要 Scoop 来安装 Go 版本管理器 g"
                }
            } catch {
                Write-Warning "安装 g 失败: $_"
            }
        } else {
            Write-Host "✅ g 已安装" -ForegroundColor Green
        }
    }
}

# Node.js 版本管理
function Install-NodeVersionManager {
    [CmdletBinding()]
    param(
        [string]$Version = "lts",
        [switch]$UseLatest
    )
    
    if (-not (Get-Command fnm -ErrorAction SilentlyContinue)) {
        Write-Host "📦 fnm 未安装，正在安装..." -ForegroundColor Yellow
        Install-VersionManagers -Node
    }
    
    if (Get-Command fnm -ErrorAction SilentlyContinue) {
        if ($UseLatest) {
            Write-Host "📦 安装最新版本 Node.js..." -ForegroundColor Green
            fnm install latest
            fnm use latest
        } else {
            Write-Host "📦 安装 Node.js $Version..." -ForegroundColor Green
            fnm install $Version
            fnm use $Version
        }
        
        Write-Host "✅ Node.js 版本:" -ForegroundColor Green
        node --version
        npm --version
    }
}

# Python 版本管理
function Install-PythonVersions {
    [CmdletBinding()]
    param(
        [string[]]$Versions = @("3.11", "3.12"),
        [string]$GlobalVersion = "3.12"
    )
    
    if (-not (Get-Command pyenv -ErrorAction SilentlyContinue)) {
        Write-Host "🐍 pyenv 未安装，正在安装..." -ForegroundColor Yellow
        Install-VersionManagers -Python
    }
    
    if (Get-Command pyenv -ErrorAction SilentlyContinue) {
        foreach ($version in $Versions) {
            Write-Host "🐍 安装 Python $version..." -ForegroundColor Green
            pyenv install $version
        }
        
        Write-Host "🌐 设置全局 Python 版本为 $GlobalVersion..." -ForegroundColor Green
        pyenv global $GlobalVersion
        
        Write-Host "✅ Python 版本:" -ForegroundColor Green
        python --version
    }
}

# Rust 工具链管理
function Install-RustToolchain {
    [CmdletBinding()]
    param(
        [string]$Channel = "stable",
        [switch]$InstallComponents
    )
    
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        Write-Host "🦀 rustup 未安装，正在安装..." -ForegroundColor Yellow
        Install-VersionManagers -Rust
    }
    
    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        Write-Host "🦀 安装 Rust $Channel 工具链..." -ForegroundColor Green
        rustup install $Channel
        rustup default $Channel
        
        if ($InstallComponents) {
            Write-Host "📦 安装额外组件..." -ForegroundColor Yellow
            rustup component add rustfmt clippy rust-src rust-analyzer
        }
        
        Write-Host "✅ Rust 版本:" -ForegroundColor Green
        rustc --version
        cargo --version
    }
}

# Go 版本管理
function Install-GoVersionManager {
    [CmdletBinding()]
    param(
        [string]$Version = "latest"
    )
    
    if (-not (Get-Command g -ErrorAction SilentlyContinue)) {
        Write-Host "🐹 g 未安装，正在安装..." -ForegroundColor Yellow
        Install-VersionManagers -Go
    }
    
    if (Get-Command g -ErrorAction SilentlyContinue) {
        Write-Host "🐹 安装 Go $Version..." -ForegroundColor Green
        if ($Version -eq "latest") {
            g install latest
        } else {
            g install $Version
        }
        
        Write-Host "✅ Go 版本:" -ForegroundColor Green
        go version
    }
}

# 项目脚手架 - React
function New-ReactProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,
        
        [ValidateSet('vite', 'cra', 'next')]
        [string]$Template = 'vite',
        
        [switch]$TypeScript,
        [switch]$PWA
    )
    
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "Node.js/npm 未安装"
        return
    }
    
    Write-Host "⚛️ 创建 React 项目: $ProjectName" -ForegroundColor Green
    
    switch ($Template) {
        'vite' {
            $template = if ($TypeScript) { 'react-ts' } else { 'react' }
            npm create vite@latest $ProjectName -- --template $template
        }
        'cra' {
            $template = if ($TypeScript) { '--template typescript' } else { '' }
            if ($PWA) { $template += ' --template cra-template-pwa' }
            npx create-react-app $ProjectName $template
        }
        'next' {
            $template = if ($TypeScript) { '--typescript' } else { '' }
            npx create-next-app@latest $ProjectName $template
        }
    }
    
    if (Test-Path $ProjectName) {
        Set-Location $ProjectName
        Write-Host "✅ 项目创建成功！" -ForegroundColor Green
        Write-Host "📁 当前目录: $(Get-Location)"
        Write-Host "🚀 运行 'npm run dev' 启动开发服务器"
    }
}

# 项目脚手架 - Python
function New-PythonProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,
        
        [ValidateSet('basic', 'flask', 'fastapi', 'django')]
        [string]$Template = 'basic',
        
        [switch]$VirtualEnv,
        [string]$PythonVersion = "3.12"
    )
    
    Write-Host "🐍 创建 Python 项目: $ProjectName" -ForegroundColor Green
    
    # 创建项目目录
    New-Item -ItemType Directory -Name $ProjectName -Force
    Set-Location $ProjectName
    
    # 创建虚拟环境
    if ($VirtualEnv) {
        Write-Host "📦 创建虚拟环境..." -ForegroundColor Yellow
        if (Get-Command pyenv -ErrorAction SilentlyContinue) {
            pyenv local $PythonVersion
        }
        python -m venv venv
        .\venv\Scripts\Activate.ps1
    }
    
    # 根据模板创建项目结构
    switch ($Template) {
        'basic' {
            @"
# $ProjectName

## 安装依赖
```bash
pip install -r requirements.txt
```

## 运行
```bash
python main.py
```
"@ | Out-File -FilePath "README.md" -Encoding UTF8
            
            "# Python dependencies" | Out-File -FilePath "requirements.txt" -Encoding UTF8
            
            @"
#!/usr/bin/env python3
"""
$ProjectName - Main application
"""

def main():
    print("Hello, $ProjectName!")

if __name__ == "__main__":
    main()
"@ | Out-File -FilePath "main.py" -Encoding UTF8
        }
        
        'flask' {
            pip install flask
            @"
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, $ProjectName!'

if __name__ == '__main__':
    app.run(debug=True)
"@ | Out-File -FilePath "app.py" -Encoding UTF8
        }
        
        'fastapi' {
            pip install fastapi uvicorn
            @"
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello, $ProjectName!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
"@ | Out-File -FilePath "main.py" -Encoding UTF8
        }
    }
    
    Write-Host "✅ Python 项目创建成功！" -ForegroundColor Green
}

# 项目脚手架 - Rust
function New-RustProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,
        
        [ValidateSet('bin', 'lib')]
        [string]$Type = 'bin'
    )
    
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Error "Rust/Cargo 未安装"
        return
    }
    
    Write-Host "🦀 创建 Rust 项目: $ProjectName" -ForegroundColor Green
    
    $args = @('new', $ProjectName)
    if ($Type -eq 'lib') { $args += '--lib' }
    
    cargo @args
    
    if (Test-Path $ProjectName) {
        Set-Location $ProjectName
        Write-Host "✅ Rust 项目创建成功！" -ForegroundColor Green
        Write-Host "🚀 运行 'cargo run' 编译并运行"
    }
}

# 容器工具集成
function Install-ContainerTools {
    [CmdletBinding()]
    param(
        [switch]$Docker,
        [switch]$Podman,
        [switch]$Kubernetes,
        [switch]$All
    )
    
    if ($All) {
        $Docker = $Podman = $Kubernetes = $true
    }
    
    Write-Host "🐳 安装容器工具..." -ForegroundColor Green
    
    if ($Docker) {
        Write-Host "🐳 检查 Docker..." -ForegroundColor Yellow
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Host "📦 需要手动安装 Docker Desktop" -ForegroundColor Yellow
            Write-Host "🔗 下载地址: https://www.docker.com/products/docker-desktop"
        } else {
            Write-Host "✅ Docker 已安装" -ForegroundColor Green
            docker --version
        }
    }
    
    if ($Podman) {
        Write-Host "🦭 安装 Podman..." -ForegroundColor Yellow
        if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                scoop install podman
            } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
                winget install RedHat.Podman
            }
        } else {
            Write-Host "✅ Podman 已安装" -ForegroundColor Green
        }
    }
    
    if ($Kubernetes) {
        Write-Host "☸️ 安装 Kubernetes 工具..." -ForegroundColor Yellow
        
        # kubectl
        if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                scoop install kubectl
            }
        }
        
        # helm
        if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                scoop install helm
            }
        }
        
        # k9s
        if (-not (Get-Command k9s -ErrorAction SilentlyContinue)) {
            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                scoop install k9s
            }
        }
    }
}

# Docker 辅助函数
function docker-cleanup {
    Write-Host "🧹 清理 Docker..." -ForegroundColor Green
    docker system prune -f
    docker image prune -f
    docker volume prune -f
}

function docker-stats-live {
    Write-Host "📊 Docker 容器状态监控..." -ForegroundColor Green
    docker stats
}

# Kubernetes 辅助函数
function k {
    kubectl @args
}

function kgp {
    kubectl get pods @args
}

function kgs {
    kubectl get services @args
}

function kgd {
    kubectl get deployments @args
}

function kdesc {
    kubectl describe @args
}

function klogs {
    kubectl logs @args
}

# 开发环境检查
function Test-DevEnvironment {
    [CmdletBinding()]
    param()
    
    Write-Host "🔍 开发环境检查" -ForegroundColor Green
    Write-Host "=" * 40 -ForegroundColor Gray
    
    $tools = @{
        'Node.js' = 'node'
        'npm' = 'npm'
        'Python' = 'python'
        'pip' = 'pip'
        'Rust' = 'rustc'
        'Cargo' = 'cargo'
        'Go' = 'go'
        'Git' = 'git'
        'Docker' = 'docker'
        'kubectl' = 'kubectl'
    }
    
    foreach ($tool in $tools.Keys) {
        $command = $tools[$tool]
        if (Get-Command $command -ErrorAction SilentlyContinue) {
            try {
                $version = & $command --version 2>$null | Select-Object -First 1
                Write-Host "✅ $tool`: $version" -ForegroundColor Green
            } catch {
                Write-Host "✅ $tool`: 已安装" -ForegroundColor Green
            }
        } else {
            Write-Host "❌ $tool`: 未安装" -ForegroundColor Red
        }
    }
}

# 别名
Set-Alias -Name node-install -Value Install-NodeVersionManager -Force
Set-Alias -Name py-install -Value Install-PythonVersions -Force
Set-Alias -Name rust-install -Value Install-RustToolchain -Force
Set-Alias -Name go-install -Value Install-GoVersionManager -Force
Set-Alias -Name new-react -Value New-ReactProject -Force
Set-Alias -Name new-python -Value New-PythonProject -Force
Set-Alias -Name new-rust -Value New-RustProject -Force
Set-Alias -Name devcheck -Value Test-DevEnvironment -Force

# Note: Functions and aliases are automatically available when dot-sourced