import os
import pytest
from PIL import Image

from starkware.starknet.testing.starknet import Starknet

CONTRACT_FILE = os.path.join("contracts", "raymarching.cairo")

@pytest.mark.asyncio
async def test_pixels():
    starknet = await Starknet.empty()

    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    """Test math functions."""
    print('\n')
    # print('--------------------- vector legnth')
    # vec_length = await contract.length3(_vec=(20, 20, 0)).call()
    # print(str(vec_length.result.res))
    print('--------------------- vector legnth 64x61')
    # vec_length = await contract.test_vec_len(a=(20, -20, 0)).call()
    # print(str(vec_length.result.res))

    print('--------------------- test sub 64x61, should be 5')
    # sub = await contract.test_64(a=-20).call()
    # print(str(sub.result.res))
    
    print('--------------------- get size')
    size = await contract.get_size().call()
    print(str(size.result.res))

    # print('--------------------- normalize')
    # vec_normalize = await contract.normalize3(_vec=(20, -20, 0)).call()
    # print(str(vec_normalize.result.vec))

    """Test render."""
    screen = await contract.get_image().call()
    f = open("image.txt", "w")
    f.write(str(screen.result.pixels))
    f.close()
    
    image_size = size.result.res
    image_out = Image.new('L',[image_size, image_size])
    image_out.putdata(screen.result.pixels)
    image_out.save('test_out.png')

    
    assert screen
