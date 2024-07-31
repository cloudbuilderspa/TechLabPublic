#!/usr/bin/env bash
set -e

ENV=$1
RESOURCE_PATH=$2
ACTION=$3


function terraform_apply() {
  cd ${ENV}/${RESOURCE_PATH} && terraform init -reconfigure && terraform ${ACTION} -lock=false --auto-approve
}

terraform_apply