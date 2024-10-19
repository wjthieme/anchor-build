#!/bin/bash
set -eo pipefail

# Set default network to devnet if $2 is empty or not defined
if [ -z "$2" ]; then
  NETWORK="devnet"
else
  NETWORK="$2"
fi

# Configure Solana
solana config set --url "$NETWORK"

# Configure Solana Key
if [ -z "$3" ]; then
  solana-keygen new --no-bip39-passphrase
else
  echo "$3" > ~/.config/solana/id.json
fi

# Airdrop Solana if on devnet
if [ "$NETWORK" == "devnet" ]; then
  solana airdrop 1 || true
fi

# Run the provided commands
if [ -z "$1" ]; then
  anchor build
else
  eval "$1"
fi
