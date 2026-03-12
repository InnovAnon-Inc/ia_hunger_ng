-- ia_hunger_ng/interoperability/claycrafter.lua

local add = hunger_ng.add_hunger_data

--minetest.override_item("claycrafter:glass_of_water", {
--	on_use=nil,
--})

--assert(ia_util.has_claycrafter_redo())
assert(minetest.get_modpath('claycrafter'))
if not ia_util.has_placeable_buckets_redo() then
    add('claycrafter:glass_of_water', {
        heals    = 0,
        satiates = 0,
        quenches = 1,
        returns  = 'vessels:drinking_glass',
    })
end

