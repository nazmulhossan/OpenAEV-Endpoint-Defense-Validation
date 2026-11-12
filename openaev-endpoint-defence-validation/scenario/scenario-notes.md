# Scenario: Baseline-Windows-Endpoint

Target: Windows VM (OpenAEV agent, standard session mode, elevated install).

| # | Tactic | Technique | Threat Arsenal action used | Delay | Expectation |
|---|---|---|---|---|---|
| 1 | Discovery | T1082 System Information Discovery | TODO | 0 min | Prevention |
| 2 | Discovery | T1033 System Owner / User Discovery | TODO | 1 min | Prevention |
| 3 | Discovery | T1087.001 Local Account Discovery | TODO | 2 min | Prevention |
| 4 | Discovery | T1016 System Network Configuration Discovery | TODO | 3 min | Prevention |
| 5 | Discovery | T1057 Process Discovery | TODO | 4 min | Prevention |
| 6 | Execution | T1059.001 PowerShell (benign command) | TODO | 5 min | Prevention |
| 7 | Discovery | T1069 Permission Groups Discovery | TODO | 6 min | Prevention |

## Notes

- Before launching, revert the VM to the `clean-baseline` snapshot and confirm the agent is active.
- Read the command of each action before adding it. Do not use actions that delete files, disable security tools or download unknown content.
- Excluded from this baseline: T1562 (security tool tampering), T1003 (credential dumping), T1547 (registry run keys) and T1053 (scheduled tasks). They can be added in a later iteration with snapshots.
- Detection is verified manually in Windows Security alerts and logs unless an EDR or SIEM collector is integrated.
