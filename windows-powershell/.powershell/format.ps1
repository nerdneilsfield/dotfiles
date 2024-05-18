# format
function Format-Json {
    param (
        [string]$Path
    )
    cat $Path | ConvertFrom-Json | ConvertTo-Json
}
function Format-Xml {
    param (
        [string]$Path
    )
    cat $Path | ConvertTo-Xml | Format-Table
}
function Format-Yaml {
    param (
        [string]$Path
    )
    cat $Path | ConvertFrom-Yaml | ConvertTo-Yaml
}

function Convert-XlsxToCsv {
    param (
        [string]$xlsxFilePath,
        [string]$csvFilePath
    )

    # 创建 Excel 应用程序对象
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    try {
        # 打开 Excel 文件
        $workbook = $excel.Workbooks.Open($xlsxFilePath)

        # 保存为 CSV 文件
        $workbook.SaveAs($csvFilePath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSV)

        # 关闭工作簿
        $workbook.Close($false)
    } catch {
        Write-Error "转换过程中发生错误: $_"
    } finally {
        # 退出 Excel 应用程序
        $excel.Quit()
        # 释放 COM 对象
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
}