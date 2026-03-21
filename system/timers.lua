-- vim: set sw=2:
-- Set Vim’s shiftwidth to 2 instead of 4 because the functions in this file
-- are deeply nested and there are some long lines. 2 instead of 4 gives a tiny
-- bit more space for each indentation level.
assert(core.get_modpath('ia_gender'))
assert(core.get_modpath('ia_util'))
assert(ia_util.has_beds_redo())
assert(ia_util.has_pooper_redo())

--local alter_health              = hunger_ng.functions.alter_health -- health
--local alter_hunger              = hunger_ng.functions.alter_hunger -- hunger
--local alter_poop                = hunger_ng.functions.alter_poop   -- poop
local defecate                  = hunger_ng.functions.defecate
--local alter_thirst              = hunger_ng.functions.alter_thirst -- thirst
--local alter_pee                 = hunger_ng.functions.alter_pee    -- pee
local urinate                   = hunger_ng.functions.urinate
--local alter_sleep               = hunger_ng.functions.alter_sleep  -- sleep
--local alter_milk                = hunger_ng.functions.alter_milk   -- milk
local lactate                   = hunger_ng.functions.lactate
local procreate                 = hunger_ng.functions.procreate
local alter                     = {
  health                        = hunger_ng.functions.alter_health,
  hunger                        = hunger_ng.functions.alter_hunger,
  poop                          = hunger_ng.functions.alter_poop,
  thirst                        = hunger_ng.functions.alter_thirst,
  pee                           = hunger_ng.functions.alter_pee,
  sleep                         = hunger_ng.functions.alter_sleep,
  milk                          = hunger_ng.functions.alter_milk,
  preggo                        = hunger_ng.functions.alter_preggo,
}

local get_data       = hunger_ng.functions.get_data
local base_interval  = hunger_ng.settings.timers.basal_metabolism
local move_interval  = hunger_ng.settings.timers.movement
local costs_base     = hunger_ng.costs.base
local costs_movement = hunger_ng.costs.movement

--local effect_heal               = hunger_ng.attributes.effect_heal      -- health
--local effect_hunger             = hunger_ng.attributes.effect_hunger    -- hunger
--local effect_starve             = hunger_ng.attributes.effect_starve
--local effect_digest             = hunger_ng.attributes.effect_digest    -- poop
--local effect_dehydrate          = hunger_ng.attributes.effect_dehydrate -- thirst
--local effect_hydrate            = hunger_ng.attributes.effect_hydrate   -- pee
--local effect_sleep              = hunger_ng.attributes.effect_sleep     -- sleep
--local effect_lactate            = hunger_ng.attributes.effect_lactate   -- milk
--local effect_procreate          = hunger_ng.attributes.effect_procreate
local effect                    = {
    heal                        = hunger_ng.attributes.effect_heal,      -- health
    hunger                      = hunger_ng.attributes.effect_hunger,    -- hunger
    starve                      = hunger_ng.attributes.effect_starve,
    digest                      = hunger_ng.attributes.effect_digest,    -- poop
    dehydrate                   = hunger_ng.attributes.effect_dehydrate, -- thirst
    hydrate                     = hunger_ng.attributes.effect_hydrate,   -- pee
    sleep                       = hunger_ng.attributes.effect_sleep,     -- sleep
    lactate                     = hunger_ng.attributes.effect_lactate,   -- milk
    procreate                   = hunger_ng.attributes.effect_procreate,
}

local hunger_attribute          = hunger_ng.attributes.hunger_value -- hunger
local poop_attribute            = hunger_ng.attributes.poop_value   -- poop
local thirst_attribute          = hunger_ng.attributes.thirst_value -- thirst
local pee_attribute             = hunger_ng.attributes.pee_value    -- pee
local sleep_attribute           = hunger_ng.attributes.sleep_value  -- sleep
local milk_attribute            = hunger_ng.attributes.milk_value   -- milk
local preggo_attribute          = hunger_ng.attributes.preggo_value 

local hunger_bar_id             = hunger_ng.attributes.hunger_bar_id -- hunger
local poop_bar_id               = hunger_ng.attributes.poop_bar_id   -- poop
local thirst_bar_id             = hunger_ng.attributes.thirst_bar_id -- thirst
local pee_bar_id                = hunger_ng.attributes.pee_bar_id    -- pee
local sleep_bar_id              = hunger_ng.attributes.sleep_bar_id  -- sleep
local milk_bar_id               = hunger_ng.attributes.milk_bar_id   -- milk
local preggo_bar_id             = hunger_ng.attributes.preggo_bar_id 

local hunger_disabled_attribute = hunger_ng.attributes.hunger_disabled -- hunger
local poop_disabled_attribute   = hunger_ng.attributes.poop_disabled   -- poop
local thirst_disabled_attribute = hunger_ng.attributes.thirst_disabled -- thirst
local pee_disabled_attribute    = hunger_ng.attributes.pee_disabled    -- pee
local sleep_disabled_attribute  = hunger_ng.attributes.sleep_disabled  -- sleep
local milk_disabled_attribute   = hunger_ng.attributes.milk_disabled   -- milk
local preggo_disabled_attribute = hunger_ng.attributes.preggo_disabled 

local heal_above                = hunger_ng.effects.heal.above       -- health
local heal_amount               = hunger_ng.effects.heal.amount
local heal_interval             = hunger_ng.settings.timers.heal

local starve_amount             = hunger_ng.effects.starve.amount    -- hunger
local starve_below              = hunger_ng.effects.starve.below
local starve_die                = hunger_ng.effects.starve.die
local starve_interval           = hunger_ng.settings.timers.starve

local digest_above              = hunger_ng.effects.digest.above     -- poop
local digest_amount             = hunger_ng.effects.digest.amount
local digest_interval           = hunger_ng.settings.timers.digest
-- digest.below
-- poop.maximum

local dehydrate_amount          = hunger_ng.effects.dehydrate.amount -- thirst
local dehydrate_below           = hunger_ng.effects.dehydrate.below
local dehydrate_die             = hunger_ng.effects.dehydrate.die
local thirst_interval           = hunger_ng.settings.timers.thirst
local thirst_max                = hunger_ng.settings.thirst.maximum

local hydrate_above             = hunger_ng.effects.hydrate.above    -- pee
local hydrate_amount            = hunger_ng.effects.hydrate.amount
local hydrate_interval          = hunger_ng.settings.timers.hydrate
-- pee.maximum
-- hydrate.below

local sleep_amount              = hunger_ng.effects.sleep.amount
local sleep_below               = hunger_ng.effects.sleep.below      -- sleep
local sleep_die                 = hunger_ng.effects.sleep.die
local sleep_interval            = hunger_ng.settings.timers.sleep
local sleep_max                 = hunger_ng.settings.sleep.maximum

local lactate_above             = hunger_ng.effects.lactate.above    -- milk
local lactate_amount            = hunger_ng.effects.lactate.amount
local lactate_interval          = hunger_ng.settings.timers.lactate
local lactate_max               = hunger_ng.settings.milk.maximum
-- lactate.below

local procreate_above           = hunger_ng.effects.procreate.above
local procreate_amount          = hunger_ng.effects.procreate.amount
local procreate_interval        = hunger_ng.settings.timers.procreate
local procreate_max             = hunger_ng.settings.preggo.maximum
-- procreate.below

local use_hunger_bar            = hunger_ng.settings.hunger_bar.use
local use_poop_bar              = hunger_ng.settings.poop_bar.use
local use_pee_bar               = hunger_ng.settings.pee_bar.use
local use_milk_bar              = hunger_ng.settings.milk_bar.use
local use_sleep_bar             = hunger_ng.settings.sleep_bar.use
local use_thirst_bar            = hunger_ng.settings.thirst_bar.use

-- Localize Luanti
is_yes = core.is_yes
--get_connected_players = core.get_connected_players -- monkey-patch

-- Initiate globalstep timers
local base_timer      = 0
local move_timer      = 0
local heal_timer      = 0 -- health
local starve_timer    = 0 -- hunger
local digest_timer    = 0 -- poop
local dehydrate_timer = 0 -- thirst
local hydrate_timer   = 0 -- pee
local sleep_timer     = 0 -- sleep
local lactate_timer   = 0 -- milk
local procreate_timer = 0 


core.register_globalstep(function(dtime)
  --assert(procreate_timer    ~= nil)
  --assert(procreate_amount   ~= nil)
  --assert(procreate_interval ~= nil)

  -- Do not run if there are no satiating food items registered
  if hunger_ng.food_items.satiating == 0 then return end

  -- Raise timer values if needed
  if costs_base       ~= 0 then base_timer      = base_timer      + dtime end
  if costs_movement   ~= 0 then move_timer      = move_timer      + dtime end
  if heal_amount      ~= 0 then heal_timer      = heal_timer      + dtime end -- health
  if starve_amount    ~= 0 then starve_timer    = starve_timer    + dtime end -- hunger
  if digest_amount    ~= 0 then digest_timer    = digest_timer    + dtime end -- poop
  if dehydrate_amount ~= 0 then dehydrate_timer = dehydrate_timer + dtime end -- thirst
  if hydrate_amount   ~= 0 then hydrate_timer   = hydrate_timer   + dtime end -- pee
  if sleep_amount     ~= 0 then sleep_timer     = sleep_timer     + dtime end -- sleep
  if lactate_amount   ~= 0 then lactate_timer   = lactate_timer   + dtime end -- milk
  if procreate_amount ~= 0 then procreate_timer = procreate_timer + dtime end

  -- Reset timers if needed
  if costs_base       ~= 0 and base_timer      >= base_interval      then base_timer      = 0 end
  if costs_movement   ~= 0 and move_timer      >= move_interval      then move_timer      = 0 end
  if heal_amount      ~= 0 and heal_timer      >= heal_interval      then heal_timer      = 0 end -- health
  if starve_amount    ~= 0 and starve_timer    >= starve_interval    then starve_timer    = 0 end -- hunger
  if digest_amount    ~= 0 and digest_timer    >= digest_interval    then digest_timer    = 0 end -- poop
  if dehydrate_amount ~= 0 and dehydrate_timer >= thirst_interval    then dehydrate_timer = 0 end -- thirst
  if hydrate_amount   ~= 0 and hydrate_timer   >= hydrate_interval   then hydrate_timer   = 0 end -- pee
  if sleep_amount     ~= 0 and sleep_timer     >= sleep_interval     then sleep_timer     = 0 end -- sleep
  if lactate_amount   ~= 0 and lactate_timer   >= lactate_interval   then lactate_timer   = 0 end -- milk
  if procreate_amount ~= 0 and procreate_timer >= procreate_interval then procreate_timer = 0 end

  -- Iterate over all players
  --
  -- If the value and the timer for the corresponding attribute are not zero
  -- (value) and zero (timer) then the alteration of that attribute is executed.
  for _,player in ipairs(core.get_connected_players()) do -- TODO handle mobs
  --for _,player in ipairs(ia_names.get_all_actors()) do -- TODO handle mobs
    --player = fakelib.get_player_interface(player)
    if player:is_player() then
      local playername = player:get_player_name()
      local hp_max = player:get_properties().hp_max
      --local breath_max = ...
      local e_heal      = get_data(playername, effect.heal,       true) == 'enabled' -- health
      local e_hunger    = get_data(playername, effect.hunger,     true) == 'enabled' -- hunger
      local e_starve    = get_data(playername, effect.starve,     true) == 'enabled'
      local e_digest    = get_data(playername, effect.digest,     true) == 'enabled' -- poop
      local e_dehydrate = get_data(playername, effect.dehydrate,  true) == 'enabled' -- thirst
      local e_hydrate   = get_data(playername, effect.hydrate,    true) == 'enabled' -- pee
      local e_sleep     = get_data(playername, effect.sleep,      true) == 'enabled' -- sleep
      local e_lactate   = get_data(playername, effect.lactate,    true) == 'enabled' -- milk
      local e_procreate = get_data(playername, effect.procreate,  true) == 'enabled'
      -- in beds/functions.lua: lay_down()
      -- beds.player[name] = {}
      -- beds.pos[name] = pos
      -- beds.bed_position[name] = bed_pos
      local can_sleep  = (beds.player[playername] ~= nil)
      local is_female  = ia_gender .is_female  (playername) -- TODO more nuanced
      local is_preggo  = ia_breeder.is_pregnant(playername)
      local thirst     = get_data(playername, thirst_attribute)
      local sleep      = get_data(playername, sleep_attribute)

      -- Basal metabolism costs
      if costs_base ~= 0 and base_timer == 0 and e_hunger    then -- hunger
        alter.hunger(playername, -costs_base, 'base')
      end
      if costs_base ~= 0 and base_timer == 0 and e_digest    then -- poop
        alter.poop    (playername,  costs_base, 'base')
      end
      if costs_base ~= 0 and base_timer == 0 and e_dehydrate then -- thirst
        alter.thirst  (playername, -costs_base, 'base')
      end
      if costs_base ~= 0 and base_timer == 0 and e_hydrate   then -- pee
	alter.pee     (playername,  costs_base, 'base')
      end
      if costs_base ~= 0 and base_timer == 0 and e_sleep     then -- sleep
	if not can_sleep then
          alter.sleep (playername, -costs_base, 'base')
	end
      end
      if costs_base ~= 0 and base_timer == 0 and e_lactate   then -- milk
	if is_female then -- TODO more nuanced
	  alter.milk    (playername,  costs_base, 'base')
          alter.hunger  (playername, -costs_base, 'base')
	end
      end
      if costs_base ~= 0 and base_timer == 0 and e_procreate then
	if is_preggo then
	  alter.preggo  (playername,  costs_base, 'base')
          alter.hunger  (playername, -costs_base, 'base')
	end
      end

      -- Heal player if possible and needed
      if heal_amount ~= 0 and heal_timer == 0 then
        local hunger = get_data(playername, hunger_attribute)
	assert(hunger ~= nil)
        local health = player:get_hp()
	assert(health ~= nil)
	assert(player:get_breath() ~= nil)
	assert(player:get_properties().breath_max ~= nil)
        local awash = player:get_breath() < player:get_properties().breath_max
	assert(heal_above ~= nil)
        local can_heal_1 = (hunger >= heal_above)
        local can_heal_2 = (thirst <= (thirst_max - heal_above))
        local can_heal_3 = (sleep  >= heal_above)
	local can_heal   = ((not awash) and can_heal_1 and can_heal_2 and can_heal_3)
	assert(hp_max ~= nil)
        local needs_health = health < hp_max
        if can_heal and needs_health and e_heal then
          alter.health(playername, heal_amount, 'healing')
        end
      end

      if sleep_amount ~= 0 and sleep_timer == 0 then
	assert(sleep_amount > 0)
        --local sleep       = get_data(playername, sleep_attribute)
	local needs_sleep = sleep < sleep_max
	if can_sleep and needs_sleep and e_sleep then
	  alter.sleep(playername, sleep_amount, 'sleeping')
	end
      end

      -- Alter hunger based on movement costs
      if costs_movement ~= 0 and move_timer == 0 then
        local move = player:get_player_control()
        local moving = move.up or move.down or move.left or move.right
        if moving and e_hunger then
          alter.hunger(playername, -costs_movement, 'movement') -- hunger
        end
        if moving and e_digest    then
          alter.poop  (playername,  costs_movement, 'movement') -- poop
        end
	if moving and e_dehydrate then
          alter.thirst(playername, -costs_movement, 'movement') -- thirst
	end
	if moving and e_hydrate then
          alter.pee   (playername,  costs_movement, 'movement') -- pee
	end
        if moving and e_sleep     then
          alter.sleep (playername, -costs_movement, 'movement') -- sleep
        end
	--if moving and e_lactate then
	--  if is_female then -- TODO more nuanced
        --    alter.milk  (playername,  costs_movement, 'movement') -- milk
        --    alter.hunger(playername, -costs_movement, 'movement') -- hunger
	--  end
	--end
	--if moving and e_procreate then
	--  if is_preggo then
        --    alter.preggo(playername,  costs_movement, 'movement')
        --    alter.hunger(playername, -costs_movement, 'movement') -- hunger
	--  end
	--end
      end

      -- Starve player if starvation requirements are fulfilled
      if starve_amount    ~= 0 and starve_timer    == 0 then -- hunger
	assert(playername ~= nil)
	assert(hunger_attribute ~= nil)
        local hunger = get_data(playername, hunger_attribute)
        local health = player:get_hp()
	assert(hunger ~= nil)
	assert(health ~= nil)
	assert(starve_below ~= nil)
	--minetest.log('name        : '..playername)
	--minetest.log('hunger      : '..tostring(hunger))
	--minetest.log('starve below: '..tostring(starve_below))
        local starves = hunger < starve_below
        if starves and e_starve then
          if health == 1 and not starve_die then return end
          alter.health(playername, -starve_amount, 'starving')
        end
      end

      if digest_amount    ~= 0 and digest_timer    == 0 then -- poop
	assert(digest_amount    > 0)
        local poop       = get_data(playername, poop_attribute)
	assert(poop   ~= nil)
	assert(digest_above ~= nil)
	--minetest.log('name        : '..playername)
	--minetest.log('poop        : '..tostring(poop))
	--minetest.log('digest above: '..tostring(digest_above))
        local poops      = poop   > digest_above
        if poops      and e_digest    then
	  defecate(playername,      digest_amount,    'full of it') -- calls alter_poop(..., -digest_amount,...)
        end
      end

      if dehydrate_amount ~= 0 and dehydrate_timer == 0 then -- thirst
	assert(dehydrate_amount > 0)
        --local thirst     = get_data(playername, thirst_attribute)
	assert(thirst ~= nil)
	assert(dehydrate_below ~= nil)
	local dehydrates = thirst < dehydrate_below
	if dehydrates and e_dehydrate then
	  if health == 1 and not dehydrate_die then return end
          alter.health(playername, -dehydrate_amount, 'dehydration')
	end
      end

      if hydrate_amount    ~= 0 and hydrate_timer    == 0 then -- pee
	assert(hydrate_amount    > 0)
        local pee        = get_data(playername, pee_attribute)
	assert(pee    ~= nil)
	assert(hydrate_above ~= nil)
        local pees       = pee   > hydrate_above
        if pees      and e_hydrate    then
	  urinate (playername,      hydrate_amount,    'full of it') -- calls alter_pee(..., -hydrate_amount,...)
        end
      end

      if sleep_amount     ~= 0 and sleep_timer     == 0 then -- sleep
	assert(sleep_amount     > 0)
        local sleep      = get_data(playername, sleep_attribute)
	assert(sleep  ~= nil)
	assert(sleep_below ~= nil)
	local exhausts   = sleep  < sleep_below
	if exhausts   and e_sleep     then
	  if health == 1 and not sleep_die then return end
          alter.health(playername, -sleep_amount,     'exhaustion')
	end
      end

      if lactate_amount    ~= 0 and lactate_timer    == 0 then -- milk
	assert(lactate_amount    > 0)
        local milk       = get_data(playername, milk_attribute)
	assert(milk    ~= nil)
	assert(lactate_above ~= nil)
        local milks      = milk   > lactate_above
        if milks      and e_lactate    then
	  lactate (playername,      lactate_amount,    'full of it') -- calls alter_milk(..., -lactate_amount,...)
        end
      end

      if procreate_amount  ~= 0 and procreate_timer  == 0 then
	assert(procreate_amount  > 0)
        local preggo       = get_data(playername, preggo_attribute)
	assert(preggo    ~= nil)
	assert(procreate_above ~= nil)
        local preggos      = preggo   > procreate_above
        if preggos      and e_procreate    then
	  procreate (playername,      procreate_amount,    'full of it') -- calls alter_preggo(..., -procreate_amount,...)
        end
      end

    end -- is player
  end -- players iteration

end)

local function is_awash(player)
	local breath      = player:get_breath()
	local properties  = player:get_properties()
	local breath_max  = properties.breath_max
        assert(breath     == tonumber(breath),     'breath: '..tostring(breath))
	assert(breath_max == tonumber(breath_max), 'breath_max: '..tostring(breath_max))
	return (breath < breath_max)
end

-- TODO instead of always hiding when awash, can move all of these up when awash but holding airtank equipment ?
-- Show/hide hunger bar on player breath status or functionality status
if use_hunger_bar then -- hunger
  core.register_globalstep(function(dtime)
    for _,player in ipairs(core.get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id      = get_data(player_name, hunger_bar_id)
	local awash       = is_awash(player)
        local disabled    = get_data(player_name, hunger_disabled_attribute)
        local no_food     = (hunger_ng.food_items.satiating == 0)
        if awash or is_yes(disabled) or no_food then
          player:hud_change(bar_id, 'text', '')
        else
          player:hud_change(bar_id, 'text', hunger_ng.hunger_bar_image)
        end
      end
    end
  end)
end
if use_poop_bar then -- poop
  core.register_globalstep(function(dtime)
    for _,player in ipairs(core.get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id      = get_data(player_name, poop_bar_id)
	local awash       = is_awash(player)
        local disabled    = get_data(player_name, poop_disabled_attribute)
        local no_food     = (hunger_ng.food_items.digesting == 0)
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
if use_thirst_bar then -- thirst
  core.register_globalstep(function(dtime)
    for _,player in ipairs(core.get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id      = get_data(player_name, thirst_bar_id)
        local awash       = is_awash(player)
        local disabled    = get_data(player_name, thirst_disabled_attribute)
        local no_food     = (hunger_ng.food_items.quenching == 0)
        if awash or
	  is_yes(disabled)
	  --or no_food
	then
          player:hud_change(bar_id, 'text', '')
        else
          player:hud_change(bar_id, 'text', hunger_ng.thirst_bar_image)
        end
      end
    end
  end)
end
if use_pee_bar then -- pee
  core.register_globalstep(function(dtime)
    for _,player in ipairs(core.get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id      = get_data(player_name, pee_bar_id)
	local awash       = is_awash(player)
        local disabled    = get_data(player_name, pee_disabled_attribute)
        local no_food     = (hunger_ng.food_items.hydrating == 0)
        if awash or
	  is_yes(disabled) or no_food then
          player:hud_change(bar_id, 'text', '')
        else
          player:hud_change(bar_id, 'text', hunger_ng.pee_bar_image)
        end
      end
    end
  end)
end
if use_sleep_bar then -- sleep
  core.register_globalstep(function(dtime)
    for _,player in ipairs(core.get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local bar_id      = get_data(player_name, sleep_bar_id)
	local awash       = is_awash(player)
        local disabled    = get_data(player_name, sleep_disabled_attribute)
        --local no_food = hunger_ng.food_items.resting == 0 -- TODO check whether ia beds is present
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
if use_milk_bar then -- milk
  core.register_globalstep(function(dtime)
    for _,player in ipairs(core.get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local is_female   = ia_gender.is_female(player_name) -- TODO more nuanced
        local bar_id      = get_data(player_name, milk_bar_id)
	local awash       = is_awash(player)
        local disabled    = get_data(player_name, milk_disabled_attribute)
        local no_food     = (hunger_ng.food_items.weening == 0)
        if awash or
	  is_yes(disabled) or no_food or
	  (not is_female) then -- TODO more nuanced
          player:hud_change(bar_id, 'text', '')
        else
          player:hud_change(bar_id, 'text', hunger_ng.milk_bar_image)
        end
      end
    end
  end)
end
if use_preggo_bar then
  core.register_globalstep(function(dtime)
    for _,player in ipairs(core.get_connected_players()) do
      if player:is_player() then
        local player_name = player:get_player_name()
        local is_preggo   = ia_breeder.is_pregnant(player_name)
        local bar_id      = get_data(player_name, preggo_bar_id)
	local awash       = is_awash(player)
        local disabled    = get_data(player_name, preggo_disabled_attribute)
        --local no_food     = (hunger_ng.food_items.weening == 0)
        if awash or
	  is_yes(disabled) or --no_food or
	  (not is_preggo) then
          player:hud_change(bar_id, 'text', '')
        else
	  core.log('is_preggo: '..player_name)
          player:hud_change(bar_id, 'text', hunger_ng.preggo_bar_image)
        end
      end
    end
  end)
end
