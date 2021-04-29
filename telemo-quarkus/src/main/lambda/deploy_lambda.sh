#!/bin/bash

export SAM_CLI_TELEMETRY=0
export ENV_NAME="${BRANCH_NAME/\//}"
echo "SAM deploy to stack $ENV_NAME"

sam deploy -t target/sam.jvm.yaml \
    --stack-name "${ENV_NAME}" \
    --s3-bucket "${TF_VAR_bucket_name}" \
    --s3-prefix "sam" \
    --capabilities "CAPABILITY_NAMED_IAM"

export QUARKUS_LAMBDA=$(aws cloudformation describe-stack-resources \
    --stack-name "${ENV_NAME}" \
    --query "StackResources[?LogicalResourceId=='TelemoQuarkus']" \
    --output "text")

echo "Setting Quarkus Lambda env [$QUARKUS_LAMBDA]"
aws lambda wait function-exists --function-name "$QUARKUS_LAMBDA"

lenv="Variables={"
lenv="$lenv QUARKUS_DATASOURCE_JDBC_URL=\"$QUARKUS_DATASOURCE_JDBC_URL\","
lenv="$lenv QUARKUS_DATASOURCE_USERNAME=\"$QUARKUS_DATASOURCE_USERNAME\","
lenv="$lenv QUARKUS_DATASOURCE_PASSWORD=\"$QUARKUS_DATASOURCE_PASSWORD\","
lenv="$lenv QUARKUS_DATASOURCE_DB_KIND=\"$QUARKUS_DATASOURCE_DB_KIND\","
lenv="$lenv QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION=\"$QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION\""
lenv="$lenv }"

lvpc="SubnetIds=$TF_VAR_subnets,SecurityGroupIds=$TF_VAR_lambda_secg"

echo "Setting lambda environment"
echo "$lenv"
echo "---"
echo "vpc-config"
echo "$lvpc"
echo "---"
echo "role"
echo "$TF_VAR_lambda_role"

echo "wait before update..."
sleep 15

aws lambda update-function-configuration \
  --function-name "${QUARKUS_LAMBDA}" \
  --role "$TF_VAR_lambda_role" \
  --environment "$lenv" \
  --vpc-config "$lvpc" \
  --output "text"

export QUARKUS_API=$(aws cloudformation describe-stacks \
    --stack-name "${ENV_NAME}" \
    --query "Stacks[0].Outputs[?OutputKey=='TelemoQuarkusApi'].OutputValue" \
    --output "text")

echo "Quarkus API at $QUARKUS_API"
echo "Lambda deploy done"
