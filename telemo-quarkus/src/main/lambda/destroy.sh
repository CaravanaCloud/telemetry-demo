#!/bin/bash
set -e

BRANCH_NAME=${BRANCH_NAME:-"$(git branch --show-current)"}
BRANCH_NAME=${BRANCH_NAME:-"$(whoami | awk '{ print tolower($0) }')"}
TF_VAR_env_name=${TF_VAR_env_name:-"${BRANCH_NAME/\//-}"}
TF_VAR_env_name="${TF_VAR_env_name}${TF_VAR_env_suffix}"
export TF_VAR_env_name

terraform init -upgrade -force-copy \
  -backend-config="bucket=$TF_VAR_bucket_name" \
  -backend-config="key=terraform/${TF_VAR_env_name}/state" \
  -backend-config="region=$AWS_REGION"

terraform destroy -auto-approve
