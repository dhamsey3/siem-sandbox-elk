#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${LOG_DIR:-./logs}"
AUTH_LOG="${LOG_DIR}/auth.log"
EVENT_LOG="${LOG_DIR}/test.log"

mkdir -p "${LOG_DIR}"

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

append_json_event() {
  local action="$1"
  local message="$2"

  printf '{"@timestamp":"%s","event.kind":"event","event.category":"threat","event.action":"%s","source.ip":"192.168.1.101","message":"%s"}\n' \
    "$(timestamp)" "${action}" "${message}" >> "${EVENT_LOG}"
}

echo "[1/3] Simulating failed SSH login..."
printf '%s sshd[2345]: Failed password for root from 192.168.1.101 port 22 ssh2\n' "$(timestamp)" >> "${AUTH_LOG}"
append_json_event "failed-ssh-login" "Simulated failed SSH login for root"
sleep 1

echo "[2/3] Simulating privilege escalation attempt..."
printf '%s sudo: user john added to /etc/sudoers\n' "$(timestamp)" >> "${AUTH_LOG}"
append_json_event "sudoers-modification" "Simulated sudoers modification"
sleep 1

echo "[3/3] Simulating suspicious artifact creation..."
touch "${LOG_DIR}/malicious_mimikatz_dump.exe"
append_json_event "suspicious-file-created" "Simulated suspicious credential dumping artifact"

echo "Attack simulation completed. Events written to ${LOG_DIR}/."
