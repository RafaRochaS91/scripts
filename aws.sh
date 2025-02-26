#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/aws-config.json"

# Function to display help information
display_help() {
    echo "AWS Environment Region Configurator"
    echo ""
    echo "Usage: $(basename "$0") [COMMAND|ENVIRONMENT] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  <environment>   Set AWS region based on environment (default: dev)"
    echo "  info           Display environment to region mappings and current configuration"
    echo "  -h, --help     Display this help message"
    echo ""
    echo "Environments:"
    
    # Check if jq is installed and config file exists before trying to list environments
    if command -v jq &> /dev/null && [ -f "$CONFIG_FILE" ]; then
        echo "  $(jq -r '.environments | keys | join(", ")' "$CONFIG_FILE")"
    else
        echo "  Unable to list environments (jq not installed or config file not found)"
    fi
    
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")           # Set region for dev environment"
    echo "  $(basename "$0") staging   # Set region for staging environment"
    echo "  $(basename "$0") info      # Show current configuration"
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
    exit 0
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq to use this script."
    echo "Installation instructions: https://stedolan.github.io/jq/download/"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

# Function to show info about environments and current configuration
show_info() {
    echo "AWS Environment Region Configurator Info"
    echo "---------------------------------------"
    echo "Configuration file: $CONFIG_FILE"
    echo ""
    echo "Environment to region mappings:"
    jq -r '.environments | to_entries[] | "  \(.key): \(.value)"' "$CONFIG_FILE"
    echo ""
    echo "Current AWS configuration:"
    
    # Get current AWS region if available
    CURRENT_REGION=$(aws configure get region 2>/dev/null)
    if [ -n "$CURRENT_REGION" ]; then
        echo "  Region: $CURRENT_REGION"
        
        # Try to find which environment this region corresponds to
        ENV_FOR_REGION=$(jq -r --arg region "$CURRENT_REGION" '.environments | to_entries[] | select(.value == $region) | .key' "$CONFIG_FILE")
        if [ -n "$ENV_FOR_REGION" ]; then
            echo "  Environment: $ENV_FOR_REGION"
        else
            echo "  Environment: Custom (not matching any predefined environment)"
        fi
    else
        echo "  Region: Not set"
    fi
}

# Check if command is "info"
if [ "$1" == "info" ]; then
    show_info
    exit 0
fi

# Default to dev environment if no argument provided
ENVIRONMENT=${1:-dev}

# Get region from config file
REGION=$(jq -r ".environments.\"$ENVIRONMENT\"" "$CONFIG_FILE")

# Check if region is valid (not null or empty)
if [ "$REGION" == "null" ] || [ -z "$REGION" ]; then
    echo "Error: Invalid environment '$ENVIRONMENT'. Please use one of the environments defined in $CONFIG_FILE."
    echo "Available environments: $(jq -r '.environments | keys | join(", ")' "$CONFIG_FILE")"
    exit 1
fi

# Set AWS region
aws configure set region "$REGION"
echo "AWS region set to $REGION for environment $ENVIRONMENT"
