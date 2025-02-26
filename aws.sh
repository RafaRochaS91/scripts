#!/bin/bash

# Default to dev environment if no argument provided
ENVIRONMENT=${1:-dev}

# Map environment to region
case "$ENVIRONMENT" in
  dev)
    REGION="eu-west-2"
    ;;
  staging)
    REGION="eu-west-1"
    ;;
  prod)
    REGION="eu-central-1"
    ;;
  *)
    echo "Error: Invalid environment '$ENVIRONMENT'. Please use dev, staging, or prod."
    exit 1
    ;;
esac

# Set AWS region
aws configure set region "$REGION"
echo "AWS region set to $REGION for environment $ENVIRONMENT"
