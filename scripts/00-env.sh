#!/usr/bin/env bash
# Shared variables for the networking lab.
# Load them in every new Cloud Shell tab with:   source scripts/00-env.sh

export PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"

export REGION_US="us-central1"
export ZONE_US="us-central1-a"
export REGION_EU="europe-west1"
export ZONE_EU="europe-west1-b"

export VPC_PROD="vpc-prod"
export VPC_SHARED="vpc-shared"

export SUBNET_US="subnet-us"          # 10.10.0.0/24
export SUBNET_EU="subnet-eu"          # 10.20.0.0/24
export SUBNET_SHARED="subnet-shared"  # 10.30.0.0/24

export IAP_RANGE="35.235.240.0/20"    # Google's fixed range for IAP TCP forwarding

echo "Project:  ${PROJECT_ID}"
echo "Regions:  ${REGION_US} (${ZONE_US}) and ${REGION_EU} (${ZONE_EU})"
