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
    echo "  setup          Interactive setup to create or modify environment mappings"
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
    echo "  $(basename "$0") setup     # Run interactive setup"
}

# Function to run interactive setup
run_setup() {
    echo "AWS Environment Region Configurator Setup"
    echo "----------------------------------------"
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed. Please install jq to use this script."
        echo "Installation instructions: https://stedolan.github.io/jq/download/"
        exit 1
    fi
    
    # Initialize JSON structure
    JSON_CONTENT='{"environments":{}}'
    
    # Load existing config if it exists
    if [ -f "$CONFIG_FILE" ]; then
        echo "Existing configuration found. You can update or add new environment mappings."
        JSON_CONTENT=$(cat "$CONFIG_FILE")
    else
        echo "No existing configuration found. Creating a new one."
    fi
    
    # Function to add/update environment
    add_environment() {
        local env=$1
        local region=""
        
        # Get current region for this environment if it exists
        if [ -f "$CONFIG_FILE" ]; then
            current_region=$(jq -r ".environments.\"$env\"" "$CONFIG_FILE" 2>/dev/null)
            if [ "$current_region" != "null" ] && [ -n "$current_region" ]; then
                echo "Current region for '$env' is '$current_region'"
                read -p "Enter new region for '$env' (or press enter to keep current): " region
                if [ -z "$region" ]; then
                    region=$current_region
                fi
            else
                read -p "Enter region for '$env': " region
            fi
        else
            read -p "Enter region for '$env': " region
        fi
        
        # Validate region format
        if [[ ! $region =~ ^[a-z]+-[a-z]+-[0-9]+$ ]]; then
            echo "Warning: Region '$region' doesn't match the typical AWS region format (e.g., eu-west-1)."
            read -p "Continue anyway? (y/n): " confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                return
            fi
        fi
        
        # Update JSON
        JSON_CONTENT=$(echo "$JSON_CONTENT" | jq --arg env "$env" --arg region "$region" '.environments[$env] = $region')
        echo "Environment '$env' set to region '$region'"
    }
    
    # Add default environments if new setup
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Setting up default environments (dev, staging, prod)..."
        add_environment "dev"
        add_environment "staging"
        add_environment "prod"
    else
        # Add/update environments interactively
        while true; do
            echo ""
            echo "Current environment mappings:"
            echo "$JSON_CONTENT" | jq -r '.environments | to_entries[] | "  \(.key): \(.value)"'
            echo ""
            echo "Options:"
            echo "  1) Add/update an environment"
            echo "  2) Save and exit"
            read -p "Choose an option (1-2): " option
            
            case $option in
                1)
                    read -p "Enter environment name: " env_name
                    add_environment "$env_name"
                    ;;
                2)
                    break
                    ;;
                *)
                    echo "Invalid option. Please try again."
                    ;;
            esac
        done
    fi
    
    # Save configuration
    echo "$JSON_CONTENT" | jq '.' > "$CONFIG_FILE"
    echo ""
    echo "Configuration saved to $CONFIG_FILE"
    echo "You can now use the script with your configured environments."
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
    exit 0
fi

# Check for setup command
if [ "$1" == "setup" ]; then
    run_setup
    exit 0
fi

# Check if config file exists and prompt for setup if it doesn't
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found at $CONFIG_FILE"
    read -p "Would you like to run the setup now? (y/n): " run_setup_now
    if [[ $run_setup_now =~ ^[Yy]$ ]]; then
        run_setup
        exit 0
    else
        echo "Error: Config file not found at $CONFIG_FILE"
        echo "Run '$(basename "$0") setup' to create a configuration file."
        exit 1
    fi
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq to use this script."
    echo "Installation instructions: https://stedolan.github.io/jq/download/"
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
