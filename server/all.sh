#!/bin/sh

echo "sending" $1 $2 $3
source ~/cairo_venv/bin/activate
export STARKNET_NETWORK=alpha-goerli
export STARKNET_WALLET="starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"
# echo "bef call" >> log_oracle.txt
/root/cairo_venv/bin/starknet call --address $1 --abi ../cairo/artifacts/abis/oracles.json --function get_caller #>> log_oracle.txt
# echo "after call" >> log_oracle.txt
/root/cairo_venv/bin/starknet invoke \
    --address $1 \
    --abi ../cairo/artifacts/abis/oracles.json \
    --function update_all \
    --inputs $2 0 0 $3 \
    --max_fee 0 #>> log_oracle.txt
