-- ia_hunger_ng/interoperability/peeer.lua
assert(minetest.get_modpath('peeer'))

local add = hunger_ng.add_hunger_data

add('peeer:jcu_urine', {
        heals    = -1,
        quenches =  1,
	-- digests  =  1,
	returns  = 'vessels:drinking_glass',
})

add('peeer:jbo_urine', {
        heals    = -2,
        quenches =  2,
	-- digests  =  1,
	returns  = 'vessels:glass_bottle',
})

add('peeer:jsb_urine', {
        heals    = -2,
        quenches =  2,
	-- digests  =  1,
	returns  = 'vessels:steel_bottle',
})

