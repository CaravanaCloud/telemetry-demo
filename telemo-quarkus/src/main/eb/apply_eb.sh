#!/bin/bash

terraform init -upgrade
terraform apply -auto-approve
terraform output

