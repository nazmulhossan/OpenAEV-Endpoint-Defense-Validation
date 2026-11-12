# Endpoint Defence Validation Using OpenAEV

Internship project that uses [OpenAEV](https://github.com/OpenAEV-Platform/openaev), an open-source Adversarial Exposure Validation (AEV) platform from Filigran, to measure how well a default Microsoft Defender configuration handles common MITRE ATT&CK techniques, then hardens the configuration and measures again.

> **Authorised use only.** Everything here was run in a private lab on virtual machines owned by the author. Do not run simulations on systems you do not own or have written permission to test.

## Table of Contents

1. [Overview](#overview)
2. [Lab Architecture](#lab-architecture)
3. [Repository Structure](#repository-structure)
4. [Setup](#setup)
5. [Running the Tests](#running-the-tests)
6. [Scenario](#scenario)
7. [Metrics](#metrics)
8. [Results](#results)
9. [Security Notes](#security-notes)
10. [Limitations](#limitations)
11. [Future Work](#future-work)
12. [References](#references)

## Overview

**Research question:** To what extent does a default Windows Defender configuration prevent or expose common ATT&CK techniques, and how much does coverage improve after remediation?

**Workflow:**

1. Deploy OpenAEV on an Ubuntu VM with Docker Compose.
2. Enrol a Windows VM as an endpoint by installing the OpenAEV agent.
3. Run atomic tests, then a scenario of low-risk ATT&CK techniques, to get a baseline.
4. Analyse the gaps and apply reversible Defender hardening.
5. Re-run the same scenario and compare before and after.

## Lab Architecture

Two VMware virtual machines on one physical machine:

```
+------------------------------+        TCP 8080        +--------------------------------+
|  Ubuntu 20.04 LTS VM         | <--------------------> |  Windows VM (target endpoint)  |
|  OpenAEV platform (Docker)   |                        |  OpenAEV agent (session mode)  |
|  PostgreSQL, Elasticsearch,  |                        |  Microsoft Defender            |
|  RabbitMQ, object storage    |                        |  Runs atomic tests             |
+------------------------------+                        +--------------------------------+
```

| Item | Server VM | Target VM |
|---|---|---|
| OS | Ubuntu 20.04 LTS | Windows 10 or 11 |
| Role | Hosts OpenAEV | Runs agent and tests |
| Resources | TODO: vCPU, RAM, disk | TODO: vCPU, RAM, disk |
| IP | TODO | TODO |

The OpenAEV overview page recommends production resources of at least 8 GB of RAM each for the OpenAEV core, PostgreSQL and Elasticsearch. A smaller lab VM is fine for testing but may be slow.

## Repository Structure

```
.
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── troubleshooting.md      # Setup problems and checks
│   ├── report/                 # Final report (add report.pdf)
│   └── screenshots/            # Evidence screenshots, secrets blurred
├── scenario/
│   └── scenario-notes.md       # Inject list and expectations
├── results/
│   ├── baseline.md
│   ├── after-remediation.md
│   └── comparison.md
├── remediation/
│   └── defender-hardening.md   # Settings changed and how to revert
└── scripts/
    ├── check-connectivity.ps1  # VM to platform connectivity check
    ├── check-agent.ps1         # Read-only agent state check
    └── defender-asr.ps1        # Enable or disable the ASR rule
```

Do not commit your `.env` file or any file that contains tokens, passwords or install commands with bearer tokens.

## Setup

These steps follow the [official OpenAEV installation guide](https://docs.openaev.io/latest/deployment/platform/installation/).

### 1. Prepare the Ubuntu VM

```bash
sudo apt-get update
sudo apt-get install -y git curl ca-certificates gnupg
```

Install Docker Engine and the Compose plugin using [Docker's instructions for Ubuntu](https://docs.docker.com/engine/install/ubuntu/), then verify:

```bash
sudo systemctl enable --now docker
docker --version
docker compose version
```

Ubuntu 20.04 LTS is past its standard support period, so use it for lab purposes only.

### 2. Clone the Docker repository

```bash
mkdir -p /path_to_your_app
cd /path_to_your_app
git clone https://github.com/OpenAEV-Platform/docker.git
cd docker
```

### 3. Configure the environment

```bash
cp .env.sample .env
nano .env
```

Fill in the administrator email, password and token, the database, RabbitMQ and object storage credentials, and the platform base URL. Points to watch:

- Do not use a reserved database user name such as `admin`.
- The PostgreSQL and datasource credentials must match.
- Set the base URL to the Ubuntu VM's IP address and port 8080, not `localhost`. The agent install command is built from it.
- Check variable names against your own `.env.sample`.

### 4. Start OpenAEV

```bash
docker compose up -d
docker compose ps
docker compose logs openaev --tail=50
```

Wait until PostgreSQL, Elasticsearch, RabbitMQ and object storage are healthy. If the Windows VM cannot reach the platform, check the firewall:

```bash
sudo ufw status
sudo ufw allow 8080/tcp
```

Open `http://<ubuntu-vm-ip>:8080` and log in with the administrator credentials from `.env`.

### 5. Prepare the Windows VM

Per the [Windows agent documentation](https://docs.openaev.io/latest/integrations/agents/windows/), the agent supports Windows 10, 11, Server 2019 and Server 2022, needs TLS 1.2 or higher, and needs `%SYSTEMROOT%\System32\` and `%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\` on the system `Path`.

1. Install Windows, VMware Tools and updates. Update Defender signatures.
2. Test connectivity: `Test-NetConnection <ubuntu-vm-ip> -Port 8080`
3. Open the OpenAEV login page in the VM browser.
4. Take a VMware snapshot named `clean-baseline`.

### 6. Install the agent

This project uses the **standard (session)** mode from an elevated PowerShell terminal.

1. In the Windows VM browser, open the OpenAEV page for installing simulation agents, choose Windows and the standard installation, and copy the command.
2. Check that the command contains the Ubuntu VM address and not `localhost`.
3. Add a Defender exclusion for the agent's `runtimes` folder only. The official documentation says antivirus exclusions must apply only to that folder:

   ```powershell
   Add-MpPreference -ExclusionPath "<agent folder>\runtimes"
   ```

4. Run the copied command in PowerShell as Administrator.
5. Confirm the agent is running and the endpoint appears under **Assets, Endpoints**:

   ```powershell
   Get-Process openaev-agent
   ```

A session-mode agent runs only while the user is logged in, so stay logged in during tests.

To remove the agent: stop the process, run `uninstall.exe` from the agent folder, then delete the endpoint in OpenAEV.

## Running the Tests

### Atomic test

1. Open **Atomic testing** and click the plus button.
2. Filter Threat Arsenal actions by Windows platform and ATT&CK technique.
3. Select an action, open **Inject content**, choose the Windows VM as the target and set expectations.
4. Click **Create** and review the Overview, Findings, Execution details and Remediations tabs.

### Scenario and simulation

1. Create a scenario named `Baseline-Windows-Endpoint`.
2. Add one inject per technique in the table below, targeting the Windows VM, spaced one to two minutes apart.
3. Launch the simulation and record the overview and MITRE ATT&CK matrix.
4. Apply remediation, revert or re-snapshot as needed, and run the identical scenario again.

## Scenario

Low-risk, read-only or benign techniques selected for the baseline:

| # | Tactic | Technique |
|---|---|---|
| 1 | Discovery | T1082 System Information Discovery |
| 2 | Discovery | T1033 System Owner / User Discovery |
| 3 | Discovery | T1087.001 Local Account Discovery |
| 4 | Discovery | T1016 System Network Configuration Discovery |
| 5 | Discovery | T1057 Process Discovery |
| 6 | Execution | T1059.001 PowerShell (benign command) |
| 7 | Discovery | T1069 Permission Groups Discovery |

Techniques that tamper with security tools, dump credentials or create persistence (T1562, T1003, T1547, T1053) were left out of this baseline and are listed under [Future Work](#future-work). TODO: adjust this table to the techniques you actually ran.

## Metrics

- **Prevention rate** = prevented techniques / total techniques x 100
- **Exposure rate** = techniques detected or logged but not prevented / total techniques x 100
- **Coverage** = (prevented + detected-only) / total techniques x 100
- **Gap** = techniques neither prevented nor detected

No EDR or SIEM collector is integrated in this lab, so detection is checked manually in Windows Security alerts and logs. TODO: confirm.

## Results

TODO: fill in after the runs.

| Metric | Baseline | After remediation |
|---|---|---|
| Prevention rate | TODO % | TODO % |
| Exposure rate | TODO % | TODO % |
| Coverage | TODO % | TODO % |

Remediation applied (TODO: list only what you changed):

- Defender Attack Surface Reduction rule for potentially obfuscated scripts
- PowerShell script block logging

Add screenshots under `docs/screenshots/` and link them here.

## Security Notes

- Never commit `.env`, tokens, passwords or screenshots that show them. Rotate any secret that was exposed.
- Keep the lab on a private virtual network and snapshot the target VM before testing.
- Run the simulations only on machines you own.

## Limitations

- One endpoint and a small set of low-risk techniques, so this is not full ATT&CK coverage.
- Higher-risk tactics were excluded from this iteration.
- No automated detection validation without an EDR or SIEM collector.
- Simulated techniques may behave differently from real malware.
- Results depend on the Defender version, signature state and Windows build.
- Each stage was run TODO time(s), so run-to-run variance was not measured.

## Future Work

- Add the excluded higher-risk techniques, using VM snapshots to restore a clean state.
- Integrate an EDR or SIEM, for example Wazuh, to validate detection automatically.
- Add more endpoints and operating systems.
- Build multi-stage attack chains and use OpenCTI threat intelligence to model relevant adversaries.
- Schedule recurring simulations to track configuration drift.

## References

- [OpenAEV installation](https://docs.openaev.io/latest/deployment/platform/installation/)
- [OpenAEV agent on Windows](https://docs.openaev.io/latest/integrations/agents/windows/)
- [OpenAEV atomic testing](https://docs.openaev.io/latest/usage/run-and-evaluate/atomic-testing/atomic-testing/)
- [OpenAEV on GitHub](https://github.com/OpenAEV-Platform/openaev)
- [OpenAEV Docker deployment](https://github.com/OpenAEV-Platform/docker)
- [MITRE ATT&CK](https://attack.mitre.org)
- [Atomic Red Team](https://atomicredteam.io)

## Disclaimer

This is an educational internship project. It is not affiliated with or endorsed by Filigran. Use at your own risk and only in authorised environments.
