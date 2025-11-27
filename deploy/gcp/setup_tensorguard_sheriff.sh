#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./setup_tensorguard_sheriff.sh <ORG_EXTERNAL_ID> <PROJECT_ID>
#
# Example:
#   ./setup_tensorguard_sheriff.sh 5a21c76b-... my-gcp-project

ORG_EXTERNAL_ID="${1:?ORG_EXTERNAL_ID is required}"
PROJECT_ID="${2:?PROJECT_ID is required}"

SA_NAME="tensorguard-sheriff-${ORG_EXTERNAL_ID}"
SA_ID="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Project: ${PROJECT_ID}"
echo "Org External ID: ${ORG_EXTERNAL_ID}"
echo

echo "Enabling required APIs..."
gcloud services enable \
  compute.googleapis.com \
  monitoring.googleapis.com \
  --project "${PROJECT_ID}"

echo "Creating service account ${SA_ID} (if not exists)..."
gcloud iam service-accounts create "${SA_NAME}" \
  --display-name="TensorGuard Sheriff (${ORG_EXTERNAL_ID})" \
  --project="${PROJECT_ID}" || true

echo "Granting roles to ${SA_ID}..."
# Read-only
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.viewer" \
  --quiet

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/monitoring.viewer" \
  --quiet

# Enforcement (instance + disk management)
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.admin" \
  --quiet

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.storageAdmin" \
  --quiet

echo
echo "Creating JSON key for ${SA_ID}..."
gcloud iam service-accounts keys create "tensorguard-sheriff-${ORG_EXTERNAL_ID}.json" \
  --iam-account="${SA_ID}" \
  --project="${PROJECT_ID}"

echo
echo "=== TensorGuard Sheriff GCP Credentials ==="
echo "Project ID:       ${PROJECT_ID}"
echo "Service Account:  ${SA_ID}"
echo "Key file:         tensorguard-sheriff-${ORG_EXTERNAL_ID}.json"
echo
echo "Upload this key and project ID into TensorGuard's 'Connect GCP (Sheriff)' form."

