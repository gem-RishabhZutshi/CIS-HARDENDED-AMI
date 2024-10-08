#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Initialize Packer
packer init .

# Validate Packer Template
packer validate -var-file=variables.json cis-ami.pkr.hcl

# Build the AMI and capture the output
output=$(packer build -var-file=variables.json cis-ami.pkr.hcl)

# Print the output for debugging
echo "$output"

# Extract the AMI ID
AMI_ID=$(echo "$output" | awk -F, '$0 ~/artifact,0,id/ {print $6}')

# Check if AMI_ID is empty and exit with error if so
if [[ -z "$AMI_ID" ]]; then
  echo "Error: AMI_ID is empty. The AMI was not created."
  exit 1
fi

# Export the AMI_ID to the GitHub Actions environment
echo "AMI_ID=${AMI_ID}" >> $GITHUB_ENV
echo "AMI_ID is $AMI_ID"
echo "AMI Built Successfully with AMI ID: ${AMI_ID}"

# Use AWS CLI to describe the newly created AMI
IMAGE_DETAILS=$(aws ec2 describe-images --image-ids "${AMI_ID}" --query 'Images[0]' --output json)

# Print the image details for debugging
echo "Image Details: $IMAGE_DETAILS"
