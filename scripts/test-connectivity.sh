#!/usr/bin/env bash
# Runs every connectivity check of the lab and prints OK / BLOCKED for each one.
# Usage:  bash scripts/test-connectivity.sh
set -uo pipefail
source "$(dirname "$0")/00-env.sh" >/dev/null

WEB_EXT=$(gcloud compute instances describe web-vm --zone="$ZONE_US" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
WEB_INT=$(gcloud compute instances describe web-vm --zone="$ZONE_US" --format='get(networkInterfaces[0].networkIP)')
DB_INT=$(gcloud compute instances describe db-vm --zone="$ZONE_EU" --format='get(networkInterfaces[0].networkIP)')
HAS_TOOLS=$(gcloud compute instances list --filter="name=tools-vm" --format='value(name)')

check() { # $1 = description, rest = command
  local desc="$1"; shift
  if out=$("$@" 2>/dev/null) && [ -n "$out" ]; then
    printf "  %-48s \e[32mOK\e[0m\n" "$desc"
  else
    printf "  %-48s \e[31mBLOCKED\e[0m\n" "$desc"
  fi
}
on_vm() { # $1 = vm, $2 = zone, $3 = command
  gcloud compute ssh "$1" --zone="$2" --tunnel-through-iap --quiet --command="$3"
}

echo "web-vm external: $WEB_EXT | web-vm internal: $WEB_INT | db-vm internal: $DB_INT"
echo
check "Internet  -> web-vm   tcp:80"            curl -s --max-time 5 "http://$WEB_EXT"
check "web-vm    -> db-vm    tcp:5432"          on_vm web-vm "$ZONE_US" "curl -s --max-time 5 http://$DB_INT:5432"
check "db-vm     -> internet (apt mirror)"      on_vm db-vm  "$ZONE_EU" "curl -s -o /dev/null -w '%{http_code}' --max-time 5 https://deb.debian.org"
if [ -n "$HAS_TOOLS" ]; then
  check "tools-vm  -> web-vm   tcp:80 (peering)"   on_vm tools-vm "$ZONE_US" "curl -s --max-time 5 http://$WEB_INT"
  check "tools-vm  -> db-vm    tcp:5432 (peering)" on_vm tools-vm "$ZONE_US" "curl -s --max-time 5 http://$DB_INT:5432"
fi
