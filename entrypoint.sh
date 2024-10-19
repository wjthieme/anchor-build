#!/bin/bash
set -xeo pipefail

# Configure Solana
solana config set --url "$2"

# Configure Solana Key
if [ -z "$1" ]; then
  solana-keygen new --no-bip39-passphrase
else
  echo "$1" > ~/.config/solana/id.json
fi

# Airdrop Solana if on devnet
if [ "$1" ] && [ "$2" == "devnet" ]; then
  solana airdrop 1 || true
fi

# Run the provided commands
eval "$3"
