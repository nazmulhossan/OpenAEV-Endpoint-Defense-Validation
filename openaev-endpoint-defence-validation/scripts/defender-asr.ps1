<#
.SYNOPSIS
  Enables or disables the Defender ASR rule "Block execution of potentially
  obfuscated scripts". Run in an elevated PowerShell terminal on the lab VM only.
.EXAMPLE
  .\defender-asr.ps1 -Mode Enable
  .\defender-asr.ps1 -Mode Disable
#>
param(
  [Parameter(Mandatory = $true)][ValidateSet("Enable", "Disable")][string]$Mode
)

$ruleId = "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC"
$action = if ($Mode -eq "Enable") { "Enabled" } else { "Disabled" }

Add-MpPreference -AttackSurfaceReductionRules_Ids $ruleId -AttackSurfaceReductionRules_Actions $action
Get-MpPreference | Select-Object AttackSurfaceReductionRules_Ids, AttackSurfaceReductionRules_Actions
