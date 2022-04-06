#!/bin/sh

echo "sending" $1 $2
source ~/cairo_venv/bin/activate
export STARKNET_NETWORK=alpha-goerli
starknet invoke \
    --address $2 \
    --abi ../cairo/artifacts/abis/oracles.json \
    --function update_random_oracle \
    --inputs 999
