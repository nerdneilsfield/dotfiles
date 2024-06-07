function Install-Python
{
    scoop install python27 mambaforge python312 python311 python310 python-pre rye
    $scoop = ""
    # if env:SCOOP is not null
    if ($env:SCOOP)
    {
        $scoop = $env:SCOOP
    } else
    {
        $scoop = $env:USERPROFILE + "\scoop"
    }
    $scoop_apps = $scoop + "\apps"
    $python27 = $scoop_apps + "\python27\current\python.exe"
    $python310 = $scoop_apps + "\python310\current\python.exe"
    $python311 = $scoop_apps + "\python311\current\python.exe"
    $python312 = $scoop_apps + "\python312\current\python.exe"
    $python_pre = $scoop_apps + "\python-pre\current\python.exe"
    $mambaforge = $scoop_apps + "\mambaforge\current\python.exe"

    $local_bin = $env:USERPROFILE + "\.local\bin"
    New-Item -ItemType Directory -Force $local_bin
    Add-To-Path $local_bin

    $local_python27 = $local_bin + "\python27.exe"
    $local_python310 = $local_bin + "\python310.exe"
    $local_python311 = $local_bin + "\python311.exe"
    $local_python312 = $local_bin + "\python312.exe"
    $local_python_pre = $local_bin + "\python-pre.exe"
    $local_mambaforge = $local_bin + "\python-mamba.exe"

    sudo New-Item -ItemType SymbolicLink -Path $local_python27 -Target $python27
    sudo New-Item -ItemType SymbolicLink -Path $local_python310 -Target $python310
    sudo New-Item -ItemType SymbolicLink -Path $local_python311 -Target $python311
    sudo New-Item -ItemType SymbolicLink -Path $local_python312 -Target $python312
    sudo New-Item -ItemType SymbolicLink -Path $local_python_pre -Target $python_pre
    sudo New-Item -ItemType SymbolicLink -Path $local_mambaforge -Target $mambaforge

    Add-To-Path $scoop_apps + "\python-pre\current\Scripts"

    scoop reset python-pre
}

function pipi
{
    python3 -m pip install -U -i https://pypi.tuna.tsinghua.edu.cn/simple $args
}

function pipl
{
    python3 -m pip list $args
}

function pipf
{
    python3 -m pip freeze $args
}

function Install-PythonTools
{
    # 定义要安装的 Python 工具数组
    $python_tools = @(
        "blue"
        "autopep8"
        "black"
        "isort"
        "pyright"
        "pydocstyle"
        # "flake8" # 与 blue 冲突
        "debugpy"
        "pylint"
        "sourcery"
        "vulture"
        "ruff"
        "pipx"
        "ptpython"
        "dploy"
    )

    # 循环安装每个工具
    foreach ($tool in $python_tools)
    {
        Green-Echo "=======install $tool========="
        pipi $tool
    }
}
