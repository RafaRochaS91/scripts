# Utility Scripts Collection

A collection of useful utility scripts for various tasks.

## Global Installation Options

There are several ways to make scripts in this repository available globally on your system:

### Option 1: Create symbolic links in /usr/local/bin (recommended)

```bash
# Navigate to the directory containing the scripts
cd /path/to/script/directory

# Create a symbolic link with sudo privileges
sudo ln -s "$(pwd)/script-name.sh" /usr/local/bin/command-name
```

### Option 2: Add the script directory to your PATH

Add the following line to your shell configuration file (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
export PATH="$PATH:/path/to/script/directory"
```

Then source your configuration file:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Option 3: Create a personal bin directory

```bash
# Create a bin directory in your home if it doesn't exist
mkdir -p ~/bin

# Copy the script to your bin directory
cp script-name.sh ~/bin/command-name

# Make it executable
chmod +x ~/bin/command-name

# Add the bin directory to your PATH if not already added
echo 'export PATH="$PATH:$HOME/bin"' >> ~/.zshrc

# Source your updated configuration
source ~/.zshrc
```

---

## Available Scripts

### 1. AWS Environment Region Configurator (`aws.sh`)

A simple bash script to configure AWS CLI region based on environment (dev, staging, prod).

#### What it does

This script sets the AWS region for your AWS CLI configuration based on a specified environment.
The environment-to-region mappings are stored in a JSON configuration file (`aws-config.json`).

Currently configured mappings:
- **dev**: Sets region to `eu-west-2` (London)
- **staging**: Sets region to `eu-west-1` (Ireland)
- **prod**: Sets region to `eu-central-1` (Frankfurt)

#### Dependencies

This script requires the `jq` command-line JSON processor. If not installed, the script will prompt you with installation instructions.

To install jq:
- On macOS: `brew install jq`
- On Ubuntu/Debian: `sudo apt install jq`
- Other systems: Visit https://stedolan.github.io/jq/download/

#### Setup and Configuration

The script includes an interactive setup to create or modify the environment-to-region mappings:

```bash
./aws.sh setup
```

This command will:
- Create a new config file if none exists
- Allow you to update existing mappings
- Add new environment mappings
- Validate region formatting
- Save the configuration to `aws-config.json`

You can also manually edit the configuration file, which uses the following format:

```json
{
  "environments": {
    "dev": "eu-west-2",
    "staging": "eu-west-1", 
    "prod": "eu-central-1"
  }
}
```

The first time you run the script without a config file, it will automatically prompt you to run the setup.

#### Commands

The script supports the following commands:

- **`<environment>`**: Set AWS region based on environment (default: dev)
  ```bash
  ./aws.sh dev       # Set region to eu-west-2
  ./aws.sh staging   # Set region to eu-west-1
  ./aws.sh prod      # Set region to eu-central-1
  ```

- **`info`**: Display environment to region mappings and current configuration
  ```bash
  ./aws.sh info      # Show mappings and current region setting
  ```

- **`setup`**: Interactive setup to create or modify environment mappings
  ```bash
  ./aws.sh setup     # Run the interactive setup
  ```

- **`-h, --help`**: Display help message
  ```bash
  ./aws.sh -h        # Show help information
  ./aws.sh --help    # Show help information
  ```

#### Global Installation Example

To make this script available globally as `aws-env`:

```bash
sudo ln -s "$(pwd)/aws.sh" /usr/local/bin/aws-env
```

The script will automatically find its configuration file regardless of where it's called from. If the config file doesn't exist, it will prompt you to run the setup.

After installation, you can use it from anywhere:
```bash
aws-env [environment]   # Set region for specified environment
aws-env info            # Show mappings and current region
aws-env setup           # Run interactive setup
aws-env -h              # Show help information
```

The script will display a confirmation message showing the region that was set.

---

<!-- 
### 2. Script Name (`script-name.sh`)

Brief description of what the script does.

#### What it does

Detailed explanation of the script's functionality.

#### Usage

```bash
# Usage examples
./script-name.sh [options]
```

#### Global Installation Example

To make this script available globally as `command-name`:

```bash
sudo ln -s "$(pwd)/script-name.sh" /usr/local/bin/command-name
```
--> 