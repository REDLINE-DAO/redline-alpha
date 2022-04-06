#!/bin/sh

echo "sending" $1 $2 $3
source ~/cairo_venv/bin/activate
export STARKNET_NETWORK=alpha-goerli
/root/cairo_venv/bin/starknet invoke \
    --address $1 \
    --abi ../cairo/artifacts/abis/oracles.json \
    --function update_all \
    --inputs $2 0 0 $3 \
    --max_fee 0
