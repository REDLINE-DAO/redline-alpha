# redline-alpha
 
## Cairo


## Server
### setup
in the cairo dir, run `nile compile`
make random.sh and weather.sh executable with `chmod +x random.sh weather.sh`

note that the contract address is hardcoded in oracles.py
`source ~/cairo_venv/bin/activate` to run `nile compile`
`export STARKNET_NETWORK=alpha-goerli` to run `starknet` stuff

### run
call `oracles.py` every 10 minutes with a cron job `*/10 * * * * cd /USER/redline-alpha/server && /usr/bin/python oracles.py`