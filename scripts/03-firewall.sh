#!/usr/bin/env bash
# Part 3 — firewall rules for vpc-prod (solution).
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

# SSH only through Identity-Aware Proxy
gcloud compute firewall-rules create allow-iap-ssh \
  --network="$VPC_PROD" --direction=INGRESS --action=ALLOW \
  --rules=tcp:22 --source-ranges="$IAP_RANGE" --priority=1000

# Public web traffic, only to VMs tagged "web"
gcloud compute firewall-rules create allow-http \
  --network="$VPC_PROD" --direction=INGRESS --action=ALLOW \
  --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=web \
  --priority=1000 --enable-logging

# Database port, only from VMs tagged "web" to VMs tagged "db"
gcloud compute firewall-rules create allow-db-from-web \
  --network="$VPC_PROD" --direction=INGRESS --action=ALLOW \
  --rules=tcp:5432 --source-tags=web --target-tags=db \
  --priority=1000 --enable-logging

# Explicit "deny everything else" with logging, so blocked packets show up in Cloud Logging.
# (The implied deny at 65535 does the same job but never writes logs.)
gcloud compute firewall-rules create deny-all-ingress-logged \
  --network="$VPC_PROD" --direction=INGRESS --action=DENY \
  --rules=all --source-ranges=0.0.0.0/0 \
  --priority=65000 --enable-logging

gcloud compute firewall-rules list --filter="network:$VPC_PROD" \
  --format="table(name, direction, priority, sourceRanges.list():label=SRC_RANGES, sourceTags.list():label=SRC_TAGS, targetTags.list():label=TARGET_TAGS, allowed[].map().firewall_rule().list():label=ALLOW, denied[].map().firewall_rule().list():label=DENY)"
