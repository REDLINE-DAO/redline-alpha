%lang starknet

from starkware.cairo.common.math import unsigned_div_rem, sqrt, signed_div_rem, sign, abs_value, assert_nn, assert_le
from starkware.cairo.common.math_cmp import is_le, is_nn
from starkware.cairo.common.alloc import alloc
from contracts.Vec64x61 import (
    Vec64x61_add,
    Vec64x61_sub,
    Vec64x61_mul,
    Vec64x61_dot,
    Vec64x61_cross,
    Vec64x61_norm
)
from Math64x61 import (
    Math64x61_toFelt,
    Math64x61_fromFelt,
    # Math64x61_toUint256,
    # Math64x61_fromUint256,
    Math64x61_floor,
    Math64x61_ceil,
    Math64x61_min,
    Math64x61_max,
    Math64x61_mul,
    Math64x61_div,
    Math64x61__pow_int,
    Math64x61_pow,
    Math64x61_sqrt,
    Math64x61_exp2,
    Math64x61_exp,
    Math64x61_log2,
    Math64x61_ln,
    Math64x61_log10,
    Math64x61_sub,
    Math64x61_add
)
# from contracts.Trig64x61 import (
#     Trig64x61_sin,
#     Trig64x61_cos,
#     Trig64x61_tan,
#     Trig64x61_atan,
#     Trig64x61_asin,
#     Trig64x61_acos
# )


# canvas size 7 and 8 rays work
# canvas size 8 and 6 rays work
const size = 7
const color_range = 256

# raymarching
const ray_count = 8

const Math64x61_BOUND = 2 ** 125
const quart = 576460752303423488
const one = 2305843009213693952
const two = 4611686018427387904

# Vector functions

@view
func get_size{}() -> (res: felt):
    let res = size
    return (res)
end

@view
func get_const{range_check_ptr}(a: felt) -> (res: felt):
    let (res) = Math64x61_fromFelt(a)
    return (res)
end

@view
func get_const_div{range_check_ptr}(a: felt, b: felt) -> (res: felt):
    let (a64) = Math64x61_fromFelt(a)
    let (b64) = Math64x61_fromFelt(b)
    let (res) = Math64x61_div(a64, b64)
    return (res)
end


# func Math64x61_mod {range_check_ptr} (x: felt, y: felt) -> (res: felt):
#     let (int_val, mod_val) = signed_div_rem(x, y, Math64x61_BOUND)
#     let res = mod_val
#     return (res)
# end

@view
func Vec64x61_len{range_check_ptr}(a: (felt, felt, felt)) -> (res: felt):
    alloc_locals
    let (x) = Math64x61__pow_int(a[0], 2)
    let (y) = Math64x61__pow_int(a[1], 2)
    let (z) = Math64x61__pow_int(a[2], 2)
    let (res) = Math64x61_sqrt(x + y + z)
    return (res)
end

# @view
# func test_vec_len{range_check_ptr}(a: (felt, felt, felt)) -> (res: felt):
#     let (x) = Math64x61_fromFelt(a[0])
#     let (y) = Math64x61_fromFelt(a[1])
#     let (z) = Math64x61_fromFelt(a[2])
#     let (length) = Vec64x61_len((x, y, z))
#     let (res) = Math64x61_toFelt(length)
#     return (res)
# end

# @view
# func test_64{range_check_ptr}(a: felt) -> (res: felt):
#     let (a2) = Math64x61_fromFelt(a)
#     let (min) = Math64x61_fromFelt(25)
#     let (sub) = Math64x61_add(a2, min)
#     let (res) = Math64x61_toFelt(sub)
#     return (res)
# end

@view
func Vec64x61_normalize{range_check_ptr}(a: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    alloc_locals
    let (len) = Vec64x61_len(a)
    let (x) = Math64x61_div(a[0], len)
    let (y) = Math64x61_div(a[1], len)
    let (z) = Math64x61_div(a[2], len)
    return ((x, y, z))
end

# @view
# func Vec64x61_mod{range_check_ptr}(a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
#     alloc_locals
#     let (x) = Math64x61_mod(a[0], b[0])
#     let (y) = Math64x61_div(a[1], b[1])
#     let (z) = Math64x61_div(a[2], b[2])
#     return ((x, y, z))
# end

@view
func Vec64x61_abs{range_check_ptr}(a: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    let (x) = abs_value(a[0])
    let (y) = abs_value(a[1])
    let (z) = abs_value(a[2])
    return ((x, y, z))
end

@view
func Vec64x61_max{range_check_ptr}(a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    alloc_locals
    let (x) = Math64x61_max(a[0], b[0])
    let (y) = Math64x61_max(a[1], b[1])
    let (z) = Math64x61_max(a[2], b[2])
    return ((x, y, z))
end

func sd_sphere{range_check_ptr}(p: (felt, felt, felt), s: felt) -> (res: felt):
    let (len) = Vec64x61_len(p)
    let (res) = Math64x61_sub(len, s)
    return (res)
end

# func sd_box{range_check_ptr}(p: (felt, felt, felt), b: (felt, felt, felt)) -> (res: felt):
#     alloc_locals
#     let (zero) = Math64x61_fromFelt(0)
#     let (one) = Math64x61_fromFelt(1)
#     let (four) = Math64x61_fromFelt(40000000000) # 40000000000 works

#     let (p_abs) = Vec64x61_abs(p)
#     let (d) = Vec64x61_sub(p_abs, b)

#     let (r0) = Math64x61_max(d[1], d[2])
#     let (r1) = Math64x61_max(d[0], r0)
#     let (r2) = Math64x61_min(r1, zero)

#     let (r3) = Vec64x61_max(d, (zero, zero, zero))
#     let (quart) = Math64x61_div(one, four)
#     let (r4_1) = Vec64x61_mul(r3, quart)
#     let (r4) = Vec64x61_len(r4_1)
#     let (r4_2) = Math64x61_mul(r4, four)

#     let (res) = Math64x61_add(r2, r4_2)

#     return (res)
# end

# func op_rep{range_check_ptr}(p: (felt, felt, felt), c: (felt, felt, felt)) -> (res: felt):
#     alloc_locals
#     let (ten) = Math64x61_fromFelt(10)
#     let (one) = Math64x61_fromFelt(1)
#     let (two) = Math64x61_fromFelt(2)
#     let (half) = Math64x61_div(one, two)

#     let (q1) = Vec64x61_mod(p, c)
#     let (c1) = Vec64x61_mul(c, half)
#     let (q) = Vec64x61_sub(q1, c1)

#     let (s) = Math64x61_div(one, ten)
#     let s_vec = (s, s, s)

#     let (res) = sd_box(q, s_vec)
#     return (res)
# end


# func raymarch{range_check_ptr}(r: felt, eye: (felt, felt, felt), ray: (felt, felt, felt), color: felt, t: felt) -> (color: felt, t: felt):
#     alloc_locals
#     if r != 0:
#         let (one) = Math64x61_fromFelt(1)
#         let (two) = Math64x61_fromFelt(2)
#         let (half) = Math64x61_div(one, two)
#         let (quart) = Math64x61_div(half, two)
#         let r_new = r - 1

#         let (p_mul) = Vec64x61_mul(ray, t)
#         let (p) = Vec64x61_add(p_mul, eye)

#         # let (d) = op_rep(p, (half, half, half))
#         let (d) = sd_sphere(p, quart)

#         let (thou) = Math64x61_fromFelt(100) # 1000
#         let (ray_epsilon) = Math64x61_div(one, thou)
#         let (temp) = is_le(d, ray_epsilon)
#         if temp != 0:
#             let (ray_count64) = Math64x61_fromFelt(r_new)
#             let (color_new) = Math64x61_div(r, ray_count64)
#             return (color_new, t)
#         else:
#             let (t_new) = Math64x61_add(t, d)
#             raymarch(r_new, eye, ray, color, t_new)
#         end
#         tempvar range_check_ptr = range_check_ptr
#     else:
#         tempvar range_check_ptr = range_check_ptr
#     end
#     return (color, t)
# end

# we ran out of rays, return dist
# we hit something, return dist
# check for next step

func raymarch2{range_check_ptr}(i: felt, eye: (felt, felt, felt), direction: (felt, felt, felt), travel_distance: felt) -> (res: felt):
    alloc_locals
    # let (one) = Math64x61_fromFelt(1)
    # let (two) = Math64x61_fromFelt(2)
    # let (half) = Math64x61_div(one, two)
    # let (quart) = Math64x61_div(half, two)

    # we ran out of rays
    # if i == 0:
    #     tempvar range_check_ptr = range_check_ptr
    #     return (travel_distance)
    # else:
    #     let (pos_mul) = Vec64x61_mul(direction, travel_distance)
    #     let (pos) = Vec64x61_add(pos_mul, eye)
    #     let (dist_to_closest) = sd_sphere(pos, quart)

    #     let (thou) = Math64x61_fromFelt(100) # 1000
    #     let (ray_epsilon) = Math64x61_div(one, thou)
    #     let (temp) = is_le(dist_to_closest, ray_epsilon)
    #     tempvar range_check_ptr = range_check_ptr
    #     # we hit something, stop recursion, return travel_distance
    #     if temp != 0:
    #         return (travel_distance)
    #     end
    #     # we didn't hit something, and still have rays, continue with i--
    #     let i_new = i - 1
    #     let (travel_distance_new) = Math64x61_add(dist_to_closest, travel_distance)
    #     let (travel_distance_total) = raymarch2(i_new, pos, direction, travel_distance_new)
    #     tempvar range_check_ptr = range_check_ptr
    #     return (travel_distance_total)
    # end
    # return (0)

    if i != 0:
        let i_new = i - 1
        let (pos_mul) = Vec64x61_mul(direction, travel_distance)
        let (pos) = Vec64x61_add(pos_mul, eye)
        let (dist_to_closest) = sd_sphere(pos, quart)

        let (thou) = Math64x61_fromFelt(100) # 1000
        let (ray_epsilon) = Math64x61_div(one, thou)
        let (temp) = is_le(dist_to_closest, ray_epsilon)
        # we hit something, stop recursion, return travel_distance
        if temp != 0:
            return (travel_distance)
        end
        # we didn't hit something, compute for next dist
        let (travel_distance_new) = Math64x61_add(dist_to_closest, travel_distance)
        let (travel_distance_total) = raymarch2(i_new, pos, direction, travel_distance_new)
        tempvar range_check_ptr = range_check_ptr
        return (travel_distance_total)

    else:
        tempvar range_check_ptr = range_check_ptr
    end
    return (travel_distance)
end

func main_image{range_check_ptr}(x: felt, y: felt) -> (color: felt):
    alloc_locals
    # let (zero) = Math64x61_fromFelt(0)
    # let (one) = Math64x61_fromFelt(1)
    # let (two) = Math64x61_fromFelt(2)
    # let (half) = Math64x61_div(one, two)
    let (size64) = Math64x61_fromFelt(size)
    let (color_range64) = Math64x61_fromFelt(color_range)

    # let color = x * color_range / size
    # let (q,r) = unsigned_div_rem(color_range, size)
    # let u = color_range - x * r
    # let v = y * r
    # let u2 = u * 2 - color_range
    # let v2 = v * 2 - color_range
    # let u_div = u2/color_range
    # let (color_range64) = Math64x61_fromFelt(color_range)
    let (u64) = Math64x61_fromFelt(x)
    let (u64_scale) = Math64x61_div(u64, size64) # [0, 1] range
    let (u64_1) = Math64x61_mul(u64_scale, two) # [0, 2] range
    let (u64_2) = Math64x61_sub(u64_1, one) # [-1, 1] range
    let (v64) = Math64x61_fromFelt(y)
    let (v64_scale) = Math64x61_div(v64, size64)
    let (v64_1) = Math64x61_mul(v64_scale, two)
    let (v64_2) = Math64x61_sub(v64_1, one)


    # vec3 eye = vec3(0, 0, -1.);
    let (eye_z) = Math64x61_sub(0, one)
    let eye = (0, 0, eye_z)

    # vec3 front = vec3(0.,0.,1.)
    # let front = (0, 0, one)
    # let front = (half, half, one)
    # let right = (one, 0, 0) 
    # let up = (0, one, 0)

    let (ray_direction) = Vec64x61_normalize((u64_2, v64_2, one))

    # vec3 ray = normalize(front + right * uv.x + up * uv.y);
    # let (ray_right) = Vec64x61_mul(right, u64_2)
    # let (ray_up) = Vec64x61_mul(up, v64_2)
    # let (ray_front) = Vec64x61_add(front, ray_right)
    # let (ray_final) = Vec64x61_add(ray_front, ray_up)
    # let (ray) = Vec64x61_normalize(ray_final)

    # raymarching loop
    # let (color_raymarch, t) = raymarch(ray_count, eye, ray, zero, zero)
    # raymarching loop v2
    let (t) = raymarch2(ray_count, eye, ray_direction, 0)

    # get color64 and scale to felt * color range
    let (color_scale) = Math64x61_fromFelt(1)
    # let (color_temp1) = Math64x61_mul(t, color_range64)
    let (color_temp1) = Math64x61_div(t, color_scale)
    let (color_temp2) = Math64x61_floor(color_temp1)
    let (color) = Math64x61_toFelt(color_temp2)

    # DEBUG UV
    # let (color_temp1) = Math64x61_add(u64_2, one)
    # let (color_temp2) = Math64x61_div(color_temp1, two)
    # let (color_temp3) = Math64x61_mul(color_temp2, color_range64)
    # let (color_temp4) = Math64x61_toFelt(color_temp3)
    # let color = color_temp4
    return (color)
end

func set_arr{range_check_ptr}(pixels_arr: felt *, pixels_total: felt, pixels_left: felt):

    if pixels_left != 0:
        let (y, x) = unsigned_div_rem(pixels_left - 1, size)
        # let x = pixels_left - y * size # modulo 7 - (floor(7/4)*4)
        let (pixel) = main_image(x +0, y +0)
        # assign to array
        assert pixels_arr[pixels_total - pixels_left] = pixel
        # recursion
        set_arr(pixels_arr, pixels_total, pixels_left - 1)
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar range_check_ptr = range_check_ptr
    end

    return ()
end

# return an array of values
@view
func get_image{range_check_ptr}() -> (pixels_len, pixels : felt*):
    alloc_locals
    let (pixels_arr : felt *) = alloc()
    let pixels_total = size * size
    set_arr(pixels_arr, pixels_total, pixels_total)
    # for each pixel, populate the array
    return (pixels_len=pixels_total, pixels=pixels_arr)
end

