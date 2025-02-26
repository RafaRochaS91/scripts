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

This script sets the AWS region for your AWS CLI configuration based on a specified environment:

- **dev**: Sets region to `eu-west-2` (London)
- **staging**: Sets region to `eu-west-1` (Ireland)
- **prod**: Sets region to `eu-central-1` (Frankfurt)

#### Usage

```bash
# Run with default environment (dev)
./aws.sh

# Explicitly specify environment
./aws.sh dev
./aws.sh staging
./aws.sh prod
```

#### Global Installation Example

To make this script available globally as `aws-env`:

```bash
sudo ln -s "$(pwd)/aws.sh" /usr/local/bin/aws-env
```

After installation, you can use it from anywhere:
```bash
aws-env [environment]
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