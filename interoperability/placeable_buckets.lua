-- ia_hunger_ng/interoperability/placeable_buckets.lua

local add = hunger_ng.add_hunger_data

--minetest.override_item("claycrafter:glass_of_water", {
--	on_use=nil,
--})

assert(minetest.get_modpath('placeable_buckets'))
if ia_util.has_placeable_buckets_redo() then
  add('placeable_buckets:jcu_water', {
      heals    = 0,
      satiates = 0,
      quenches = 1,
      returns  = 'vessels:drinking_glass',
  })
  add('placeable_buckets:jbo_water', {
      heals    = 0,
      satiates = 0,
      quenches = 2,
      returns  = 'vessels:glass_bottle',
  })
  add('placeable_buckets:jsb_water', {
      heals    = 0,
      satiates = 0,
      quenches = 2,
      returns  = 'vessels:steel_bottle',
  })
  add('placeable_buckets:jcu_river_water', {
      heals    = 0,
      satiates = 0,
      quenches = 1,
      returns  = 'vessels:drinking_glass',
  })
  add('placeable_buckets:jbo_river_water', {
      heals    = 0,
      satiates = 0,
      quenches = 2,
      returns  = 'vessels:glass_bottle',
  })
  add('placeable_buckets:jsb_river_water', {
      heals    = 0,
      satiates = 0,
      quenches = 2,
      returns  = 'vessels:steel_bottle',
  })
end
