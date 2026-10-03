#!/usr/bin/env bash
# Deletes everything created in the lab. Safe to run more than once.
set -uo pipefail
source "$(dirname "$0")/00-env.sh"

echo "Deleting VMs..."
gcloud compute instances delete web-vm   --zone="$ZONE_US" --quiet 2>/dev/null
gcloud compute instances delete tools-vm --zone="$ZONE_US" --quiet 2>/dev/null
gcloud compute instances delete partner-vm --zone="$ZONE_US" --quiet 2>/dev/null
gcloud compute instances delete db-vm    --zone="$ZONE_EU" --quiet 2>/dev/null

echo "Deleting peerings..."
for p in prod-to-shared shared-to-prod shared-to-partner partner-to-shared; do
  for n in "$VPC_PROD" "$VPC_SHARED" vpc-partner; do
    gcloud compute networks peerings delete "$p" --network="$n" --quiet 2>/dev/null
  done
done

echo "Deleting Cloud NAT and router..."
gcloud compute routers nats delete nat-eu --router=nat-router-eu --region="$REGION_EU" --quiet 2>/dev/null
gcloud compute routers delete nat-router-eu --region="$REGION_EU" --quiet 2>/dev/null

echo "Deleting firewall rules..."
for n in "$VPC_PROD" "$VPC_SHARED" vpc-partner; do
  for r in $(gcloud compute firewall-rules list --filter="network:$n" --format='value(name)' 2>/dev/null); do
    gcloud compute firewall-rules delete "$r" --quiet
  done
done

echo "Deleting subnets and networks..."
gcloud compute networks subnets delete "$SUBNET_US"     --region="$REGION_US" --quiet 2>/dev/null
gcloud compute networks subnets delete "$SUBNET_EU"     --region="$REGION_EU" --quiet 2>/dev/null
gcloud compute networks subnets delete "$SUBNET_SHARED" --region="$REGION_US" --quiet 2>/dev/null
gcloud compute networks subnets delete subnet-partner   --region="$REGION_US" --quiet 2>/dev/null
for n in "$VPC_PROD" "$VPC_SHARED" vpc-partner; do
  gcloud compute networks delete "$n" --quiet 2>/dev/null
done

echo "Remaining networks:"
gcloud compute networks list
