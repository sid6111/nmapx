#!/bin/bash
set -euo pipefail

# ---------- Colors ----------
RESET="\e[0m"; BOLD="\e[1m"
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"

# ---------- Vars ----------
TARGET=""
ACTIVE=false
VERBOSE=false
OUTPUT=""

# ---------- Args ----------
while [[ $# -gt 0 ]]; do
  case $1 in
    --active)  ACTIVE=true ;;
    --verbose) VERBOSE=true ;;
    -o) OUTPUT="$2"; shift ;;
    *) TARGET="$1" ;;
  esac
  shift
done

if [[ -z "$TARGET" ]]; then
  echo -e "${RED}[!] Usage:${RESET} $0 <target> [--active] [--verbose] [-o file]"
  exit 1
fi

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

# ---------- Temp file ----------
TMP=$(mktemp)

# ---------- Scan ----------
nmap_cmd() {
  nmap "$@" "$TARGET"
}

echo -e "${GREEN}[+] Running Nmap scan...${RESET}"

nmap_cmd \
  -sS -sV \
  --top-ports 1000 \
  --open \
  --script "default,safe" \
  -T3 \
  > "$TMP"

if [[ "$ACTIVE" == true ]]; then
  nmap_cmd -p- -T4 --open >> "$TMP"
fi

# ---------- Output Mode ----------
if [[ "$VERBOSE" == true ]]; then
  cat "$TMP"
else
  echo -e "\n${BOLD}${GREEN}====== SUMMARY ======${RESET}"

  echo -e "${CYAN}Target:${RESET}"
  grep -m1 "Nmap scan report" "$TMP"

  echo -e "\n${CYAN}Host Status:${RESET}"
  grep -m1 "Host is up" "$TMP"

  echo -e "\n${CYAN}Open Ports:${RESET}"
  grep -E "^[0-9]+/tcp\s+open" "$TMP"

  echo -e "\n${CYAN}Tech Stack:${RESET}"
  grep -Ei "cloudflare|proxy|nginx|apache|iis" "$TMP | sort -u"

  echo -e "\n${CYAN}TLS:${RESET}"
  grep -Ei "ssl-cert|Not valid after" "$TMP"

  echo -e "\n${CYAN}Confirmed Vulnerabilities:${RESET}"
  grep -Ei "VULNERABLE|CVE-" "$TMP" || echo "None confirmed"

  echo -e "\n${GREEN}${BOLD}[✓] Summary complete${RESET}"
fi

rm -f "$TMP"
