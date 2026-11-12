# Troubleshooting

Problems met during setup and how to check them. Edit this file to match what you actually experienced.

## Agent installed but the endpoint does not appear in OpenAEV

Run these on the **Windows VM** in an elevated PowerShell terminal, or use `scripts/check-agent.ps1`.

| Check | Command | What it means |
|---|---|---|
| Server reachable | `Test-NetConnection <server-ip> -Port 8080` | `TcpTestSucceeded : False` means the VM cannot reach the platform. Check the base URL, the firewall and the VM network mode |
| Agent running | `Get-Process openaev-agent` | No process means the agent did not start or was removed by antivirus |
| Agent folder | `Get-ChildItem $HOME -Force -Directory -Filter ".openaev*"` | A folder with no running process means an incomplete install |
| Defender detections | `Get-MpThreatDetection \| Select -Last 5` | Agent files listed here mean Defender blocked or quarantined them |

## Install command contains `localhost`

The platform base URL is wrong. Set it to the Ubuntu VM's IP address and port 8080 in `.env`, run `docker compose up -d` on the server VM, then generate a **new** install command. Use `docker compose up -d`, not only `docker restart`, so the new configuration is applied. Never use `docker compose down -v`, which deletes stored data.

## The agent appears under the wrong machine name

The install command was run on a different machine from the one intended, for example the physical host instead of the Windows VM. Remove the agent and its folder on that machine, delete the endpoint in OpenAEV, then open OpenAEV from inside the Windows VM, generate the command there and run it there.

## Defender blocks the installer script

The agent installer is a download-and-run PowerShell script, which antivirus often flags. The official documentation requires an antivirus exclusion for the agent's `runtimes` folder only. If the installer script itself is still blocked, document it and, in the lab VM only, change real-time protection temporarily and restore it immediately after installation.

## PostgreSQL: password authentication failed

Use a database user name that is not reserved (for example `openaev`, not `admin`) and make sure the PostgreSQL credentials and the datasource credentials in `.env` are identical.

## The OpenAEV container exits immediately

```bash
docker compose logs openaev
docker compose ps
```

Check that all required variables are set and that PostgreSQL, Elasticsearch, RabbitMQ and object storage are healthy.

## Session-mode agent stops working

A session-mode agent runs only while the user is logged in. Do not lock, sleep or log off the Windows VM during simulations.
