-- vim: set sw=2:
-- Set Vim’s shiftwidth to 2 instead of 4 because the functions in this file
-- are deeply nested and there are some long lines. 2 instead of 4 gives a tiny
-- bit more space for each indentation level.

local alter_health = hunger_ng.functions.alter_health
local alter_hunger = hunger_ng.functions.alter_hunger
local alter_poop                = hunger_ng.functions.alter_poop
local defecate                  = hunger_ng.functions.defecate
local alter_sleep               = hunger_ng.functions.alter_sleep
local base_interval = hunger_ng.settings.timers.basal_metabolism
local costs_base = hunger_ng.costs.base
local costs_movement = hunger_ng.costs.movement
local effect_heal = hunger_ng.attributes.effect_heal
local effect_hunger = hunger_ng.attributes.effect_hunger
local effect_starve = hunger_ng.attributes.effect_starve
local effect_digest             = hunger_ng.attributes.effect_digest
local effect_sleep              = hunger_ng.attributes.effect_sleep
local get_data = hunger_ng.functions.get_data
local heal_above = hunger_ng.effects.heal.above
local heal_amount = hunger_ng.effects.heal.amount
local heal_interval = hunger_ng.settings.timers.heal
local hunger_attribute = hunger_ng.attributes.hunger_value
local poop_attribute            = hunger_ng.attributes.poop_value
local sleep_attribute           = hunger_ng.attributes.sleep_value
local hunger_bar_id = hunger_ng.attributes.hunger_bar_id
local poop_bar_id               = hunger_ng.attributes.poop_bar_id
local sleep_bar_id              = hunger_ng.attributes.sleep_bar_id
local hunger_disabled_attribute = hunger_ng.attributes.hunger_disabled
local poop_disabled_attribute   = hunger_ng.attributes.poop_disabled
local sleep_disabled_attribute  = hunger_ng.attributes.sleep_disabled
local move_interval = hunger_ng.settings.timers.movement
local starve_amount = hunger_ng.effects.starve.amount
local starve_below = hunger_ng.effects.starve.below
local starve_die = hunger_ng.effects.starve.die
local starve_interval = hunger_ng.settings.timers.starve
local digest_above              = hunger_ng.effects.digest.above
local digest_amount             = hunger_ng.effects.digest.amount
local digest_interval           = hunger_ng.settings.timers.digest
local sleep_below               = hunger_ng.effects.sleep.below
local sleep_amount              = hunger_ng.effects.sleep.amount
local sleep_interval            = hunger_ng.settings.timers.sleep
local sleep_max                 = hunger_ng.settings.sleep.maximum
local use_hunger_bar = hunger_ng.settings.hunger_bar.use
local use_poop_bar              = hunger_ng.settings.poop_bar.use
local use_sleep_bar             = hunger_ng.settings.sleep_bar.use

-- Localize Luanti
is_yes = core.is_yes
get_connected_players = core.get_connected_players

-- Initiate globalstep timers
local base_timer   = 0
local heal_timer   = 0
local move_timer   = 0
local starve_timer = 0
local digest_timer = 0
local sleep_timer  = 0


core.register_globalstep(function(dtime)

  -- Do not run if there are no satiating food items registered
  if hunger_ng.food_items.satiating == 0 then return end

  -- Raise timer values if needed
  if costs_base     ~= 0 then base_timer   = base_timer   + dtime end
  if heal_amount    ~= 0 then heal_timer   = heal_timer   + dtime end
  if costs_movement ~= 0 then move_timer   = move_timer   + dtime end
  if starve_amount  ~= 0 then starve_timer = starve_timer + dtime end
  if digest_amount  ~= 0 then digest_timer = digest_timer + dtime end
  if sleep_amount   ~= 0 then sleep_timer  = sleep_timer  + dtime end

  -- Reset timers if needed
  if costs_base     ~= 0 and base_timer   >= base_interval   then base_timer   = 0 end
  if heal_amount    ~= 0 and heal_timer   >= heal_interval   then heal_timer   = 0 end
  if costs_movement ~= 0 and move_timer   >= move_interval   then move_timer   = 0 end
  if starve_amount  ~= 0 and starve_timer >= starve_interval then starve_timer = 0 end
  if digest_amount  ~= 0 and digest_timer >= digest_interval then digest_timer = 0 end
  if sleep_amount   ~= 0 and sleep_timer  >= sleep_interval  then sleep_timer  = 0 end

  -- Iterate over all players
  --
  -- If the value and the timer for the corresponding attribute are not zero
  -- (value) and zero (timer) then the alteration of that attribute is executed.
  --for _,player in ipairs(get_connected_players()) do -- TODO handle mobs
  for _,player in ipairs(ia_names.get_all_actors()) do -- TODO handle mobs
    --player = fakelib.get_player_interface(player)
    if player:is_player() then
      local playername = player:get_player_name()
      local hp_max = player:get_properties().hp_max
      --local breath_max = ...
      local e_heal = get_data(playername, effect_heal, true) == 'enabled'
      local e_hunger = get_data(playername, effect_hunger, true) == 'enabled'
      local e_starve = get_data(playername, effect_starve, true) == 'enabled'
      local e_digest   = get_data(playername, effect_digest, true) == 'enabled'
      local e_sleep    = get_data(playername, effect_sleep,  true) == 'enabled'
      -- in beds/functions.lua: lay_down()
      -- beds.player[name] = {}
      -- beds.pos[name] = pos
      -- beds.bed_position[name] = bed_pos
      local can_sleep  = beds.player[playername] ~= nil

      -- Basal metabolism costs
      if costs_base ~= 0 and base_timer == 0 and e_hunger then
        alter_hunger(playername, -costs_base, 'base')
      end
      if costs_base ~= 0 and base_timer == 0 and e_digest then
        alter_poop  (playername,  costs_base, 'base')
      end
      if costs_base ~= 0 and base_timer == 0 and e_sleep  then
	if not can_sleep then
            alter_sleep (playername, -costs_base, 'base')
	end
      end


      -- Heal player if possible and needed
      if heal_amount ~= 0 and heal_timer == 0 then
        local hunger = get_data(playername, hunger_attribute)
        local health = player:get_hp()
        local awash = player:get_breath() < player:get_properties().breath_max
        local can_heal = hunger >= heal_above and not awash
        local needs_health = health < hp_max
        if can_heal and needs_health and e_heal then
          alter_health(playername, heal_amount, 'healing')
        end
      end

      if sleep_amount ~= 0 and sleep_timer == 0 then
	assert(sleep_amount > 0)
        local sleep       = get_data(playername, sleep_attribute)
	local needs_sleep = sleep < sleep_max
	if can_sleep and needs_sleep and e_sleep then
	  alter_sleep(playername, sleep_amount, 'sleeping')
	end
      end

      -- Alter hunger based on movement costs
      if costs_movement ~= 0 and move_timer == 0 then
        local move = player:get_player_control()
        local moving = move.up or move.down or move.left or move.right
        if moving and e_hunger then
          alter_hunger(playername, -costs_movement, 'movement')
        end
        if moving and e_digest then
          alter_poop  (playername,  costs_movement, 'movement')
        end
        if moving and e_sleep  then
          alter_sleep (playername, -costs_movement, 'movement')
        end
      end

      -- Starve player if starvation requirements are fulfilled
      if starve_amount ~= 0 and starve_timer == 0 then
        local hunger = get_data(playername, hunger_attribute)
        local health = player:get_hp()
	--minetest.log('name        : '..playername)
	--minetest.log('hunger      : '..tostring(hunger))
	--minetest.log('starve below: '..tostring(starve_below))
        local starves = hunger < starve_below
        if starves and e_starve then
          if health == 1 and not starve_die then return end
          alter_health(playername, -starve_amount, 'starving')
        end
      end

      if digest_amount ~= 0 and digest_timer == 0 then
	assert(digest_amount > 0)
        local poop  = get_data(playername, poop_attribute)
	--minetest.log('name        : '..playername)
	--minetest.log('poop        : '..tostring(poop))
	--minetest.log('digest above: '..tostring(digest_above))
        local poops = poop > digest_above
        if poops and e_digest then
	  defecate(playername, digest_amount, 'full of it') -- calls alter_poop(..., -digest_amount,...)
        end
      end

      if sleep_amount ~= 0 and sleep_timer == 0 then
	assert(sleep_amount > 0)
        local sleep    = get_data(playername, sleep_attribute)
	local exhausts = sleep < sleep_below
	if exhausts and e_sleep then
          alter_health(playername, -sleep_amount, 'exhaustion')
	end
      end

    end -- is player
  end -- players iteration

end)


-- Show/hide hunger bar on player breath status or functionality status
if use_hunger_bar then
  core.register_globalstep(function(dtime)
    for _,player in ipairs(get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id = get_data(player_name, hunger_bar_id)
        local awash = player:get_breath() < player:get_properties().breath_max
        local disabled = get_data(player_name, hunger_disabled_attribute)
        local no_food = hunger_ng.food_items.satiating == 0
        if awash or is_yes(disabled) or no_food then
          player:hud_change(bar_id, 'text', '')
        else
          player:hud_change(bar_id, 'text', hunger_ng.hunger_bar_image)
        end
      end
    end
  end)
end
if use_poop_bar then
  core.register_globalstep(function(dtime)
    for _,player in ipairs(get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id = get_data(player_name, poop_bar_id)
        local awash = player:get_breath() < player:get_properties().breath_max
        local disabled = get_data(player_name, poop_disabled_attribute)
        local no_food = hunger_ng.food_items.digesting == 0
        if awash or
	  is_yes(disabled) or no_food then
          player:hud_change(bar_id, 'text', '')
        else
          player:hud_change(bar_id, 'text', hunger_ng.poop_bar_image)
        end
      end
    end
  end)
end
if use_sleep_bar then
  core.register_globalstep(function(dtime)
    for _,player in ipairs(get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id = get_data(player_name, sleep_bar_id)
        local awash = player:get_breath() < player:get_properties().breath_max
        local disabled = get_data(player_name, sleep_disabled_attribute)
        --local no_food = hunger_ng.food_items.resting == 0
        if awash or
	  is_yes(disabled)
	  --or no_food
	then
          player:hud_change(bar_id, 'text', '')
        else
          player:hud_change(bar_id, 'text', hunger_ng.sleep_bar_image)
        end
      end
    end
  end)
end
