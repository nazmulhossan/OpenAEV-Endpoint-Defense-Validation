<#
.SYNOPSIS
  Inspects the OpenAEV agent state on the Windows VM. Read-only.
  Run in an elevated PowerShell terminal.
#>
Write-Host "--- Agent process ---"
Get-Process | Where-Object { $_.Name -match "openaev|oaev" } | Select-Object Id, Name, Path

Write-Host "--- Scheduled tasks ---"
Get-ScheduledTask | Where-Object { $_.TaskName -match "openaev|oaev" } | Select-Object TaskName, State

Write-Host "--- Services ---"
Get-Service | Where-Object { $_.Name -match "oaev|openaev" } | Select-Object Name, Status

Write-Host "--- Agent folders ---"
Get-ChildItem $HOME -Force -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match "openaev" } | Select-Object FullName
Get-ChildItem "C:\Program Files (x86)\Filigran" -ErrorAction SilentlyContinue

Write-Host "--- Recent Defender detections ---"
Get-MpThreatDetection | Select-Object -Last 5 InitialDetectionTime, Resources

Write-Host "--- Clock ---"
Get-Date
