#!/usr/bin/env bash
# Part 5 — second VPC (vpc-shared) and VPC peering with vpc-prod (solution).
set -euo pipefail
source "$(dirname "$0")/00-env.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 5.1 The second network
gcloud compute networks create "$VPC_SHARED" --subnet-mode=custom
gcloud compute networks subnets create "$SUBNET_SHARED" \
  --network="$VPC_SHARED" --region="$REGION_US" --range=10.30.0.0/24

gcloud compute firewall-rules create shared-allow-iap-ssh \
  --network="$VPC_SHARED" --direction=INGRESS --action=ALLOW \
  --rules=tcp:22 --source-ranges="$IAP_RANGE"

gcloud compute instances create tools-vm \
  --zone="$ZONE_US" --machine-type=e2-micro \
  --subnet="$SUBNET_SHARED" --no-address \
  --image-family=debian-12 --image-project=debian-cloud \
  --metadata-from-file=startup-script="$ROOT/startup/db.sh"

# 5.2 Peering must be created from BOTH sides
gcloud compute networks peerings create prod-to-shared \
  --network="$VPC_PROD" --peer-network="$VPC_SHARED"
gcloud compute networks peerings create shared-to-prod \
  --network="$VPC_SHARED" --peer-network="$VPC_PROD"

# 5.3 Source tags do not cross a peering: use the peer's IP range instead
gcloud compute firewall-rules create allow-db-from-shared \
  --network="$VPC_PROD" --direction=INGRESS --action=ALLOW \
  --rules=tcp:5432 --source-ranges=10.30.0.0/24 --target-tags=db \
  --priority=1000 --enable-logging

gcloud compute networks peerings list
