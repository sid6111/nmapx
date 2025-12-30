#!/bin/bash
set -uo pipefail

# ---------- Colors ----------
RESET="\e[0m"; BOLD="\e[1m"
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"

show_help() {
  cat <<EOF
nmapx — fast recon wrapper

Usage:
  nmapx <target> [options]

Options:
  --active        Enable deeper active reconnaissance
                  (full port scan + NSE scripts)

  --verbose       Print full raw output from all tools

  -o <file>       Save output to a file

  --help          Show this help message and exit

Examples:
  nmapx example.com
  nmapx example.com --active
  nmapx example.com --verbose
  nmapx example.com -o output.txt

Notes:
  - Default mode is fast and mostly passive
  - Heavy scans only run when --active is used
  - Use only on authorized targets
EOF
}

# ---------- Vars ----------
TARGET=""
ACTIVE=false
VERBOSE=false
OUTPUT=""

# ---------- Args ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --active)  ACTIVE=true ;;
    --verbose) VERBOSE=true ;;
    --help)    show_help; exit 0 ;;
    -o)
      OUTPUT="$2"
      shift
      ;;
    *)
      TARGET="$1"
      ;;
  esac
  shift
done


if [[ -z "$TARGET" ]]; then
  echo -e "${RED}[!] No target specified.${RESET}\n"
  show_help
  exit 1
fi

# ---------- Banner ----------
echo -e "${BOLD}\e[38;5;39m
███╗   ██╗ ███╗   ███╗  █████╗  ██████╗ ██╗  ██╗
████╗  ██║ ████╗ ████║ ██╔══██╗ ██╔══██╗╚██╗██╔╝
██╔██╗ ██║ ██╔████╔██║ ███████║ ██████╔╝ ╚███╔╝ 
██║╚██╗██║ ██║╚██╔╝██║ ██╔══██║ ██╔═══╝  ██╔██╗ 
██║ ╚████║ ██║ ╚═╝ ██║ ██║  ██║ ██║     ██╔╝ ██╗
╚═╝  ╚═══╝ ╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═╝     ╚═╝  ╚═╝
\e[0m\e[38;5;82mnmapx — fast recon wrapper\e[0m\n"

# ---------- Output ----------
if [[ -n "$OUTPUT" ]]; then
  exec > >(tee "$OUTPUT") 2>&1
fi

echo -e "${CYAN}${BOLD}[*] Target:${RESET} $TARGET"
echo -e "${CYAN}[*] Active:${RESET} $ACTIVE | ${CYAN}Verbose:${RESET} $VERBOSE\n"

# ---------- Temp files ----------
WHOIS_TMP=$(mktemp)
DNS_TMP=$(mktemp)
SUB_TMP=$(mktemp)
NMAP_TMP=$(mktemp)

trap 'rm -f "$WHOIS_TMP" "$DNS_TMP" "$SUB_TMP" "$NMAP_TMP"' EXIT

# ---------- Helper ----------
nmap_cmd() { nmap "$@" "$TARGET"; }

# =============================
# PHASE 0 — WHOIS (FAST, QUIET)
# =============================
echo -e "${GREEN}[+] WHOIS...${RESET}"
timeout 5s whois "$TARGET" 2>/dev/null | head -n 20 > "$WHOIS_TMP" || true

# =============================
# PHASE 1 — DNS
# =============================
echo -e "${GREEN}[+] DNS info...${RESET}"
dig "$TARGET" A AAAA MX NS +short 2>/dev/null > "$DNS_TMP" || true

# =============================
# PHASE 2 — SUBFINDER (PASSIVE)
# =============================
if command -v subfinder &>/dev/null; then
  echo -e "${GREEN}[+] Subfinder passive enum...${RESET}"
  subfinder -d "$TARGET" -silent > "$SUB_TMP" || true
else
  echo -e "${YELLOW}[!] Subfinder not installed${RESET}"
fi

# =============================
# PHASE 3 — FAST NMAP
# =============================
echo -e "${GREEN}[+] FAST Nmap scan (top 100 ports)...${RESET}"
nmap_cmd -sS --top-ports 100 --open -T4 -Pn > "$NMAP_TMP"

OPEN_PORTS=$(grep -E "^[0-9]+/tcp\s+open" "$NMAP_TMP" \
  | cut -d/ -f1 | tr '\n' ',' | sed 's/,$//')

# =============================
# PHASE 4 — SERVICE ENUM
# =============================
if [[ -n "$OPEN_PORTS" ]]; then
  echo -e "${YELLOW}[+] Service enrichment...${RESET}"
  nmap_cmd -sV --version-light -p "$OPEN_PORTS" -T4 >> "$NMAP_TMP"
fi

# =============================
# PHASE 5 — ACTIVE (OPT-IN)
# =============================
if [[ "$ACTIVE" == true ]]; then
  echo -e "${RED}[+] ACTIVE recon enabled${RESET}"

  nmap_cmd -p- --open -T4 >> "$NMAP_TMP"
  nmap_cmd --script "default,safe" -p "$OPEN_PORTS" -T4 >> "$NMAP_TMP"
fi

# =============================
# OUTPUT
# =============================
if [[ "$VERBOSE" == true ]]; then
  cat "$WHOIS_TMP" "$DNS_TMP" "$SUB_TMP" "$NMAP_TMP"
  exit 0
fi

echo -e "\n${BOLD}${GREEN}====== SUMMARY ======${RESET}"

echo -e "${CYAN}Target:${RESET}"
grep -m1 "Nmap scan report" "$NMAP_TMP" || echo "$TARGET"

echo -e "\n${CYAN}Subdomains:${RESET}"
if [[ -s "$SUB_TMP" ]]; then
  sort -u "$SUB_TMP" | head -n 15
else
  echo "None"
fi

echo -e "\n${CYAN}Open Ports:${RESET}"
grep -E "^[0-9]+/tcp\s+open" "$NMAP_TMP" || echo "None"

echo -e "\n${CYAN}Observed Services:${RESET}"
grep -E "^[0-9]+/tcp\s+open" "$NMAP_TMP" | sed 's/^[[:space:]]*//' || echo "Unknown"

echo -e "\n${CYAN}Vulnerabilities:${RESET}"
grep -Ei "VULNERABLE|CVE-" "$NMAP_TMP" || echo "None confirmed"

echo -e "\n${GREEN}${BOLD}[✓] Recon complete${RESET}"
