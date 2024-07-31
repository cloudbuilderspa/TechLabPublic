#!/usr/bin/env bash
set -e

ENV=$1
RESOURCE_PATH=$2
ACTION=$3


# function terraform_apply() {
#   cd ${ENV}/${RESOURCE_PATH} && terraform init && terraform ${ACTION} --auto-approve
# }

function terraform_plan() {
  cd ${ENV}/${RESOURCE_PATH} && terraform init && terraform ${ACTION} 
}

terraform_plan