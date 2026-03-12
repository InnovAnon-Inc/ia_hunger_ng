-- ia_hunger_ng/interoperability/placeable_buckets.lua

local add = hunger_ng.add_hunger_data

--minetest.override_item("claycrafter:glass_of_water", {
--	on_use=nil,
--})

assert(minetest.get_modpath('placeable_buckets'))
if ia_util.has_placeable_buckets_redo() then
  add('placeable_buckets:glass_water', {
      heals    = 0,
      satiates = 0,
      quenches = 1,
      returns  = 'vessels:drinking_glass',
  })
  add('placeable_buckets:glass_river_water', {
      heals    = 0,
      satiates = 0,
      quenches = 1,
      returns  = 'vessels:drinking_glass',
  })
end
