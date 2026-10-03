#!/usr/bin/env bash
# Part 1 — custom-mode VPC with two regional subnets.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

gcloud compute networks create "$VPC_PROD" \
  --subnet-mode=custom \
  --bgp-routing-mode=global

gcloud compute networks subnets create "$SUBNET_US" \
  --network="$VPC_PROD" --region="$REGION_US" --range=10.10.0.0/24

gcloud compute networks subnets create "$SUBNET_EU" \
  --network="$VPC_PROD" --region="$REGION_EU" --range=10.20.0.0/24

gcloud compute networks subnets list --network="$VPC_PROD"
