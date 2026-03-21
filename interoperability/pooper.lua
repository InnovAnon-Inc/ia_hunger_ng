-- ia_hunger_ng/interoperability/pooper.lua

assert(ia_util.has_pooper_redo())
local add = hunger_ng.add_hunger_data

add('pooper:poop_turd', {
        heals    = -1,
        satiates =  1,
	-- digests  =  1,
})

add('pooper:digestive_agent', {
        heals    =  0,
        satiates =  0,
	--digests  =  0,
        returns  = "vessels:glass_bottle",
})	

minetest.override_item("pooper:laxative", {
	on_use=minetest.item_eat(0), -- TODO hunger_ng.defecate_soon()
})
add('pooper:laxative', {
	heals    =  0,
        satiates =  0,
	--digests  = hunger_ng.settings.poop.maximum,
	digests  = hunger_ng.poop_maximum,
        returns  = "vessels:glass_bottle",
})

-- ia_hunger_ng/interoperability/peeer.lua
--assert(minetest.get_modpath('milker'))

--local add = hunger_ng.add_hunger_data

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

-- ia_hunger_ng/interoperability/peeer.lua
--assert(minetest.get_modpath('peeer'))

--local add = hunger_ng.add_hunger_data

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

