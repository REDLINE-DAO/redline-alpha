#!/bin/sh

echo "sending" $1 $2
source ~/cairo_venv/bin/activate
export STARKNET_NETWORK=alpha-goerli
starknet invoke \
    --address $2 \
    --abi ../cairo/artifacts/abis/oracles.json \
    --function update_weather \
    --inputs 0 0 $1 \
    --max_fee 0
