# nmapx ⚡

A **fast, sane Nmap wrapper** for reconnaissance.

Designed for:
- Pentesters
- Bug bounty hunters
- Students learning recon
- Anyone tired of Nmap noise

By default, `nmapx` shows **only what matters**.
Raw output is available when you explicitly ask for it.

---

## ✨ Features

- ⚡ Fast by default (summary-only)
- 🧠 Dual mode output (summary vs raw)
- 🔒 Safe recon-first philosophy
- 🎯 Clean, readable results
- 🛑 No accidental broadcast noise
- 📄 Optional output file support

---

## 🚀 Installation

```bash
git clone https://github.com/Survivor-sid/nmapx.git
cd nmapx
chmod +x nmapx.sh
```

---

## Usage
**Basic scan (FAST, summary only)**
```bash
nmapx example.com
```
Active scan (full ports)
```bash
nmapx example.com --active
```
Verbose mode (raw Nmap output)
```bash
nmapx example.com --verbose
```
Active + verbose
```bash
nmapx example.com --active --verbose
```
Save Output
```bash
nmapx example.com -o output.txt
```

---

## 📌 Output Modes
**Default (Summary)**

```bash
Shows only:

- Host status

- Open ports

- Services

- CDN / proxy indicators

- TLS info

- Confirmed vulnerabilities
```

**Verbose (--verbose)**

```bash
- Full raw Nmap output

- NSE script results

- Debug-level details
```

---

## 🧠 Design Philosophy

=> Recon should be fast.

=> Deep scans should be intentional.


**`nmapx` follows a two-speed recon model:**

1. Fast scan → decide if target is interesting

2. Deep scan → only when needed

---

## ⚠️ Legal Disclaimer

**Use this tool only on systems you own or have explicit permission to test.
The author is not responsible for misuse.**
