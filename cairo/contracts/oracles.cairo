%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp, get_tx_info
from starkware.cairo.common.math import assert_nn

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bitwise import bitwise_and


# city_id: 0: singapore, 1: monument valley

# data_id
#  0 -> weather id https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2
#  1 -> temp deg
#  2 -> humidity percent
#  3 -> visibility m
#  4 -> wind speed ms
#  5 -> wind deg
#  6 -> cloud cover percent
#  7 -> last update epoch sec
@storage_var
func weather(city_id: felt, data_id: felt) -> (res : felt):
end
@storage_var
func owner() -> (res : felt):
end
# Not a reliable source
@storage_var
func oracle_random() -> (res : felt):
end

# from https://perama-v.github.io/cairo/examples/constructor/
@constructor
func constructor{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(owner_address : felt):
    owner.write(value=owner_address)
    return ()
end

@external
func update_weather{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(_city_id: felt, _data_id: felt, _data_value: felt):
        
    # require owner to write balance
    let (caller) = get_caller_address()
    let (tmp_owner) = owner.read()
    with_attr error_message("you are not owner"):
        assert caller = tmp_owner
    end

    # let (time) = get_block_timestamp()
    weather.write(_city_id, _data_id, _data_value)
    return ()
end

@external
func update_owner{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(_new_owner : felt):

    # require owner to write balance
    let (caller) = get_caller_address()
    let (tmp_owner) = owner.read()
    with_attr error_message("you are not owner"):
        assert caller = tmp_owner
    end

    owner.write(_new_owner)
    return ()
end

@external
func update_random_oracle{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(_new_rand : felt):

    # require owner to write balance
    let (caller) = get_caller_address()
    let (tmp_owner) = owner.read()
    with_attr error_message("you are not owner"):
        assert caller = tmp_owner
    end

    oracle_random.write(_new_rand)
    return ()
end

@view
func get_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (res: felt):
    let (res) = owner.read()
    return (res)
end
@view
func get_caller{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (res: felt):
    let (res) = get_caller_address()
    return (res)
end
@view
func diff_call_own{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (res: felt):
    let (own) = owner.read()
    let (caller) = get_caller_address()

    let res = own - caller
    return (res)
end

@view
func get_weather{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(_city_id: felt, _data_id: felt) -> (res : felt):
    let (res) = weather.read(_city_id, _data_id)
    return (res)
end

@view
func get_random_oracle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (res: felt):
    let (res) = oracle_random.read()
    return (res)
end

@view
func get_random{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}() -> (final_hash: felt):
    
    let (blocktime) = get_block_timestamp()
    let (tx_info) = get_tx_info()
    let tx_hash = tx_info.transaction_hash
    let (_oracle_random) = oracle_random.read()
    
    # mix random oracle with block hash and tx hash
    let (first_hash) = hash2{hash_ptr=pedersen_ptr}(blocktime, tx_hash)
    let (final_hash) = hash2{hash_ptr=pedersen_ptr}(first_hash, _oracle_random)

    return (final_hash)
end