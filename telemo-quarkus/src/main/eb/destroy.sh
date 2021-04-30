#!/bin/bash
set -e

terraform init -upgrade -force-copy \
  -backend-config="bucket=$TF_VAR_bucket_name" \
  -backend-config="key=terraform/${TF_VAR_env_name}/state" \
  -backend-config="region=$AWS_REGION"

terraform destroy -auto-approve
