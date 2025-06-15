# Setup Scripts

This repository contains a set of scripts for setting up a development environment on various operating systems.

## Directory Structure

- `lib/`: Contains reusable library scripts.
- `scripts/`: Contains the main setup scripts.
- `install.sh`: The entry point for the setup process.

## Usage

To run the setup process, execute the `install.sh` script:

```bash
./install.sh
```

This will automatically detect your operating system and run the appropriate setup scripts in order.

## Bootstrapping with bootstrap.sh

For automated or minimal environment setups—such as in cloud-init scripts or CDK deployments—you can use the `bootstrap.sh` script. This script ensures that git and minimal dependencies are installed, clones this repository, and then runs the main `install.sh` script.

It is designed for quick bootstrapping on fresh machines, and can be manually copy-pasted or pulled onto the new machine with the following command (assuming you have `curl` installed):

```bash
curl -sSL https://raw.githubusercontent.com/aherbrich/setup-scripts/main/bootstrap.sh | bash
```

## Supported Operating Systems

- macOS
- Amazon Linux

