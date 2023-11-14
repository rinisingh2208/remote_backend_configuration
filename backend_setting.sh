#!/bin/bash
operation=${1:-create}
if [ "$operation" == "create" ]; then
    # Read variables from tfvars
    cluster_name=$(awk -F'"' '/virtual_machine_name/{print $2}' centos_agents/terraform.tfvars)
    s3_bucket_name=$(awk -F'"' '/tf_state_s3_bucket_name/{print $2}' centos_agents/terraform.tfvars)
    region="us-west-2"
elif [ "$operation" == "delete" ]; then
    # Read variables from command line
    cluster_name=$2
    region=$3
    bucket_name=$4
else
    echo "Invalid operation: $operation"
    exit 1
fi
# Create backend.tf with the dynamic bucket name
cat << EOF > centos_agents/backend.tf
terraform {
  backend "s3" {
    bucket = "${s3_bucket_name}"
    key    = "${cluster_name}/terraform.tfstate"
    region = "${region}"
  }
}
EOF
