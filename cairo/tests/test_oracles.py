"""oracles.cairo test file."""
import os
import pytest
from starkware.starknet.testing.starknet import Starknet
from utils.Signer import Signer
from utils.deploy import deploy


CONTRACT_FILE = os.path.join("contracts", "oracles.cairo")
ACC_FILE = os.path.join("contracts", "Account.cairo")

signer = Signer(123456789987654321)

@pytest.mark.asyncio
async def test_update_random_oracle():
    """Test update_random_oracle method."""
    # Create a new Starknet class that simulates the StarkNet system.
    starknet = await Starknet.empty()

    # 1. Deploy Account
    account = await starknet.deploy(
        "contracts/Account.cairo",
        constructor_calldata=[signer.public_key]
    )

    # 2. Send transaction through Account
    await signer.send_transaction(account, some_contract_address, 'some_function', [some_parameter])
    # account = await starknet.deploy(source=ACC_FILE, constructor_calldata=[signer.public_key])
    # await account.initialize(signer.public_key, L1_ADDRESS).invoke()

    contract = await starknet.deploy(source=CONTRACT_FILE,constructor_calldata=[account.contract_address])

    return starknet, ownable, owner

    # 2. test oracle
    

    new_rand = 1

    await contract.update_random_oracle(_new_rand=new_rand).invoke()

    execution_info = await contract.get_random_oracle().call()
    assert execution_info.result == (new_rand,)