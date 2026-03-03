-- ia_hunger_ng/interoperability/pooper.lua

assert(ia_pooper ~= nil)
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

