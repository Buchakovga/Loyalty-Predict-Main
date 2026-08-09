$ErrorActionPreference = 'Stop'

Write-Host 'Executando get_data.py...'
Set-Location "$PSScriptRoot/src/engeneering"
conda run -n loyalty-predict python get_data.py

Write-Host 'Executando pipeline_analytics.py...'
Set-Location "$PSScriptRoot/src/analytics"
conda run -n loyalty-predict python pipeline_analytics.py
