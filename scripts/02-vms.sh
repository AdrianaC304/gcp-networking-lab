#!/usr/bin/env bash
# Part 2 — two VMs: web-vm (public) and db-vm (private, no external IP).
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

gcloud compute instances create web-vm \
  --zone="$ZONE_US" --machine-type=e2-micro \
  --subnet="$SUBNET_US" --tags=web \
  --image-family=debian-12 --image-project=debian-cloud \
  --metadata-from-file=startup-script="$ROOT/startup/web.sh"

gcloud compute instances create db-vm \
  --zone="$ZONE_EU" --machine-type=e2-micro \
  --subnet="$SUBNET_EU" --tags=db --no-address \
  --image-family=debian-12 --image-project=debian-cloud \
  --metadata-from-file=startup-script="$ROOT/startup/db.sh"

gcloud compute instances list \
  --format="table(name, zone.basename(), networkInterfaces[0].networkIP:label=INTERNAL_IP, networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP, tags.items)"
