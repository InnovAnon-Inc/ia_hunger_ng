-- ia_hunger_ng/interoperability/claycrafter.lua

local add = hunger_ng.add_hunger_data

--minetest.override_item("claycrafter:glass_of_water", {
--	on_use=nil,
--})
add('claycrafter:glass_of_water', {
        heals    = 0,
        satiates = 0,
	quenches = 1,
	returns  = 'vessels:drinking_glass',
})

