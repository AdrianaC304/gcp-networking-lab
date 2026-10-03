#!/usr/bin/env bash
# Part 4 — outbound internet for private VMs in europe-west1 with Cloud NAT.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

gcloud compute routers create nat-router-eu \
  --network="$VPC_PROD" --region="$REGION_EU"

gcloud compute routers nats create nat-eu \
  --router=nat-router-eu --region="$REGION_EU" \
  --auto-allocate-nat-external-ips \
  --nat-all-subnet-ip-ranges \
  --enable-logging

gcloud compute routers nats describe nat-eu --router=nat-router-eu --region="$REGION_EU"
