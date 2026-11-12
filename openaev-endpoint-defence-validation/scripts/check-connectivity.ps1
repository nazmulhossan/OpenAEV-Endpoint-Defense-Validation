<#
.SYNOPSIS
  Checks that the Windows VM can reach the OpenAEV platform.
.EXAMPLE
  .\check-connectivity.ps1 -Server 192.168.0.71 -Port 8080
#>
param(
  [Parameter(Mandatory = $true)][string]$Server,
  [int]$Port = 8080
)

Write-Host "--- TCP test ---"
Test-NetConnection -ComputerName $Server -Port $Port | Select-Object ComputerName, RemotePort, TcpTestSucceeded

Write-Host "--- HTTP test ---"
try {
  $r = Invoke-WebRequest -Uri "http://${Server}:${Port}" -UseBasicParsing -TimeoutSec 10
  Write-Host "HTTP status: $($r.StatusCode)"
} catch {
  Write-Host "HTTP request failed: $($_.Exception.Message)"
}

Write-Host "--- Local addresses ---"
Get-NetIPAddress -AddressFamily IPv4 | Select-Object InterfaceAlias, IPAddress
