# Defender Hardening

Only reversible changes were applied, on the Windows VM. Record exactly what you change.

## 1. Attack Surface Reduction rule: block potentially obfuscated scripts

Check the current state:

```powershell
Get-MpPreference | Select AttackSurfaceReductionRules_Ids,AttackSurfaceReductionRules_Actions
```

Enable the rule (or use `scripts/defender-asr.ps1 -Mode Enable`):

```powershell
Add-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC -AttackSurfaceReductionRules_Actions Enabled
```

Revert:

```powershell
Add-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC -AttackSurfaceReductionRules_Actions Disabled
```

## 2. PowerShell script block logging

Enable through Group Policy: Computer Configuration, Administrative Templates, Windows Components, Windows PowerShell, **Turn on PowerShell Script Block Logging**. Revert by setting the policy back to Not Configured.

## 3. Other changes

| Change | Reason | Related technique | Reverted |
|---|---|---|---|
| TODO | TODO | TODO | TODO |

## Before and after settings

Add screenshots to `docs/screenshots/`.

Verify the Microsoft documentation for ASR rules and logging for your Windows build before applying.
