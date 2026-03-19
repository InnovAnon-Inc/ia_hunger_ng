-- ia_hunger_ng/interoperability/peeer.lua
assert(minetest.get_modpath('milker'))

local add = hunger_ng.add_hunger_data

add('milker:jcu_milk', {
        heals    =  2, --1,
        quenches =  2, --1,
	satiates =  1,
	-- digests  =  1,
	returns  = 'vessels:drinking_glass',
})

add('milker:jbo_milk', {
        heals    =  4, --2,
        quenches =  4, --2,
	satiates =  2,
	-- digests  =  1,
	returns  = 'vessels:glass_bottle',
})

add('milker:jsb_milk', {
        heals    =  4, --2,
        quenches =  4, --2,
	satiates =  2,
	-- digests  =  1,
	returns  = 'vessels:steel_bottle',
})

