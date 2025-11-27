#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./setup_tensorguard_gcp.sh <ORG_EXTERNAL_ID>
#
# This helper lets the user pick a project, choose Auditor/Sheriff/both,
# and runs the existing setup scripts.

ORG_EXTERNAL_ID="${1:-}"
if [[ -z "${ORG_EXTERNAL_ID}" ]]; then
  echo "Usage: $0 <ORG_EXTERNAL_ID>"
  exit 1
fi

echo "== TensorGuard GCP setup =="
echo "Org External ID: ${ORG_EXTERNAL_ID}"
echo

echo "Current gcloud account/session:"
gcloud auth list
echo

echo "Available projects:"
gcloud projects list --format="value(projectId)"
echo
read -rp "Enter PROJECT_ID to connect: " PROJECT_ID
if [[ -z "${PROJECT_ID}" ]]; then
  echo "Project is required"
  exit 1
fi
gcloud config set project "${PROJECT_ID}"

echo
echo "Select mode: [1] Auditor (read-only) [2] Sheriff (enforcement) [3] Both"
read -rp "Choice: " CHOICE

# Ensure scripts are executable
chmod +x ./deploy/gcp/setup_tensorguard_auditor.sh ./deploy/gcp/setup_tensorguard_sheriff.sh

run_auditor() {
  ./deploy/gcp/setup_tensorguard_auditor.sh "${ORG_EXTERNAL_ID}" "${PROJECT_ID}"
}
run_sheriff() {
  ./deploy/gcp/setup_tensorguard_sheriff.sh "${ORG_EXTERNAL_ID}" "${PROJECT_ID}"
}

case "${CHOICE}" in
  1) run_auditor ;;
  2) run_sheriff ;;
  3) run_auditor; run_sheriff ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

echo
echo "If you saw a billing error, please enable billing for project '${PROJECT_ID}' and rerun:"
echo "  gcloud billing accounts list"
echo "  gcloud billing projects link ${PROJECT_ID} --billing-account <ACCOUNT_ID>"
echo
echo "Done. Upload the generated JSON key(s) and project ID into TensorGuard."
