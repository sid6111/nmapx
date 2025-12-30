# nmapx ⚡

**nmapx** is a fast, minimal reconnaissance wrapper built for **speed, predictability, and daily use**.

It combines lightweight passive recon with targeted network scanning, while keeping heavy and slow actions **explicitly opt-in**.

---

## Philosophy

Most recon tools fail because they try to do everything by default.

`nmapx` follows a simple rule:

> **Fast by default. Deep only when asked.**

This keeps runtime short, output clean, and usage practical during real reconnaissance.

---

## Features

- Time-bounded **WHOIS**
- Lightweight **DNS enumeration**
- **Subfinder** for fast passive subdomain discovery
- **Fast Nmap scan** (top 100 ports)
- Targeted **service enrichment**
- Optional **active recon** mode
- Clean summary output
- Optional verbose mode
- Optional output file
- Predictable execution time

---

## What nmapx Is (and Is Not)

### ✅ nmapx IS
- A fast recon entry point
- A daily-driver reconnaissance utility
- A wrapper that respects your time

### ❌ nmapx is NOT
- A full recon framework
- A vulnerability scanner
- A replacement for Amass, Nuclei, BBOT, etc.

Those tools belong **later** in the workflow.

---

## Requirements

Make sure the following tools are installed:

- `bash`
- `nmap`
- `subfinder`
- `whois`
- `dig` (dnsutils)

### To install in Kali Linux
```bash
sudo apt install nmap whois dnsutils

go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```
Ensure `$GOPATH/bin` is in your PATH.

---

## Installation

Clone or copy the script:

```bash
git clone https://github.com/yourusername/nmapx.git
cd nmapx
chmod +x nmapx.sh
```

(Optional)
```bash
sudo mv nmapx.sh /usr/local/bin/nmapx
```
---

## Usage
Show help
```bash
nmapx --help
```

Basic recon (fast, recommended)
```bash
nmapx example.com
```

Active recon (explicit)
```bash
nmapx example.com --active
```

Verbose output (raw tool output)
```bash
nmapx example.com --verbose
```

Save output to file
```bash
nmapx example.com -o output.txt
```
---

## Help Output
```lua
nmapx — fast recon wrapper

Usage:
  nmapx <target> [options]

Options:
  --active        Enable deeper active reconnaissance
                  (full port scan + NSE scripts)

  --verbose       Print full raw output from all tools

  -o <file>       Save output to a file

  --help          Show this help message and exit
```

---

## Example Output

```lua
[+] WHOIS...
[+] DNS info...
[+] Subfinder passive enum...
[+] FAST Nmap scan (top 100 ports)...
[+] Service enrichment...

====== SUMMARY ======
Target:
Nmap scan report for example.com (1.2.3.4)

Subdomains:
api.example.com
dev.example.com
test.example.com

Open Ports:
80/tcp open  http
443/tcp open https

Observed Services:
nginx 1.19.0

Vulnerabilities:
None confirmed

[✓] Recon complete
```

---

## Security & Legal Notice

Use this tool only on systems you own or have explicit permission to test.

Unauthorized scanning is illegal and unethical.
