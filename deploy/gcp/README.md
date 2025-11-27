TensorGuard GCP onboarding scripts
----------------------------------

What’s here:
- `setup_tensorguard_gcp.sh` — guided entrypoint. Prompts for project and mode (Auditor/Sheriff/Both) and runs the scripts below.
- `setup_tensorguard_auditor.sh` — creates a read-only service account, grants roles, generates a key.
- `setup_tensorguard_sheriff.sh` — creates an enforcement service account, grants roles (compute.admin, storageAdmin + viewer), generates a key.

Usage (from Cloud Shell clone):
1) Set your project: `gcloud config set project <PROJECT_ID>` (the script will also prompt/override).
2) Run:
```
./deploy/gcp/setup_tensorguard_gcp.sh <ORG_EXTERNAL_ID>
```
3) Choose Auditor/Sheriff/Both when prompted.
4) Upload the generated JSON key(s) and project ID into TensorGuard.
