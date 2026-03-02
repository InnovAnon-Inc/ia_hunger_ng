-- vim: set sw=2:
-- Set Vim’s shiftwidth to 2 instead of 4 because the functions in this file
-- are deeply nested and there are some long lines. 2 instead of 4 gives a tiny
-- bit more space for each indentation level.


-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator
local costs = hunger_ng.costs

local digest_interval           = hunger_ng.settings.timers.digest

-- Localize Luanti
local chat_send = core.chat_send_player
local core_log = core.log


-- When a player digs or places a node the corresponding hunger alteration
-- will be applied
core.register_on_dignode(function(p, on, digger)
  if not digger then
    return
  end
  local playername = digger:get_player_name()
  f.alter_hunger(playername, -costs.dig, 'digging')
  f.alter_poop  (playername,  costs.dig, 'digging')
  f.alter_sleep (playername, -costs.dig, 'digging')
end)
core.register_on_placenode(function(p, nn, placer, on, is, pt)
  if placer then
    return
  end
  local playername = digger:get_player_name()
  f.alter_hunger(playername, -costs.place, 'placing')
  f.alter_poop  (playername,  costs.place, 'placing')
  f.alter_sleep (playername, -costs.place, 'placing')
end)

-- TODO persistence ?

-- If a player dies and respawns the hunger value will be properly deleted and
-- after respawn it will be set again. This avoids the player healing even if
-- the player died.
-- TODO expose
f.on_dieplayer = function(player)
  local playername = digger:get_player_name()
  f.alter_hunger(playername, -s.hunger.maximum, 'death')
  f.alter_poop  (playername, -s.poop  .maximum, 'death')
  f.alter_sleep (playername, -s.sleep .maximum, 'death')
  return true
end
core.register_on_dieplayer(f.on_dieplayer)
-- TODO expose ?
f.on_respawnplayer = function(player)
  local playername = player:get_player_name()
  f.alter_hunger(playername, s.hunger.start_with, 'respawn')
  f.alter_poop  (playername, s.poop  .start_with, 'respawn')
  f.alter_sleep (playername, s.sleep .start_with, 'respawn')
end
core.register_on_respawnplayer(f.on_respawnplayer)


-- Custom eating function
--
-- When the player eats an item it is checked if the item has the custom
-- _hunger_ng attribute set. If no, the eating won’t be intercepted by the
-- function and the item will be eat regularly.
--
-- If the item has the attribute set then it will be processed and the heal
-- and hunger values will be applied according to the item’s settings.
--
-- If the item has a timeout and the timeout is still active the user gets an
-- information about this mentioning the timeout and how long the user has to
-- wait before being able to eat again.
core.register_on_item_eat(function(hpc, rwi, itemstack, user, pt)
  --minetest.log('hunger_ng.register_on_item_eat() a')
  local definition = itemstack:get_definition()
  local hunger_def = definition._hunger_ng

  -- Make sure to run the Hunger NG actions only if the item has hunger
  -- information registered.
  if user:is_player() ~= true or hunger_def == nil then return end
  --minetest.log('hunger_ng.register_on_item_eat() b')

  local player_name = user:get_player_name()
  local current_hunger = f.get_data(player_name, a.hunger_value)
  local current_poop    = f.get_data(player_name, a.poop_value)
  local current_sleep   = f.get_data(player_name, a.sleep_value)
  local hunger_disabled = f.get_data(player_name, a.hunger_disabled)
  local poop_disabled   = f.get_data(player_name, a.poop_disabled)
  local sleep_disabled  = f.get_data(player_name, a.sleep_disabled)
  local item_sound = definition.sound or {}
  local eating_sound = item_sound.eat or 'hunger_ng_eat'

  -- If hunger is disabled by configuration the reular eating functionality
  -- is restored with chat message on eating.
  if core.is_yes(hunger_disabled) then
    chat_send(player_name, S('Hunger is disabled for you! Eating normally.'))
    return
  end
  --minetest.log('hunger_ng.register_on_item_eat() c')

  -- If a mod disabled the hunger effect the regular eating functionality
  -- is restored without chat message.
  if f.get_data(player_name,a.effect_hunger,true) == 'disabled' then return end
  --minetest.log('hunger_ng.register_on_item_eat() d')

  local heals = hunger_def.heals or 0
  local satiates = hunger_def.satiates or 0
  local digests  = hunger_def.digests  or 0
  local rests    = hunger_def.rests    or 0

  if current_hunger == s.hunger.maximum and heals <= 0 and satiates >= 0 then
    chat_send(player_name, S('You’re fully satiated already!'))
    return itemstack
  end
  --minetest.log('hunger_ng.register_on_item_eat() e')

  if hunger_def.returns then
    local inventory = user:get_inventory()
    if not inventory:room_for_item('main', hunger_def.returns..' 1') then
      local message = S('You have no inventory space to keep the leftovers.')
      chat_send(player_name, message)
      return itemstack
    end
    --minetest.log('hunger_ng.register_on_item_eat() f')
  end
  --minetest.log('hunger_ng.register_on_item_eat() g')

  local timeout = hunger_def.timeout or s.hunger.timeout
  local current_timestamp = os.time()
  local player_timestamp = f.get_data(player_name, a.eating_timestamp)

  if current_timestamp < player_timestamp + timeout then
    local wait = player_timestamp + timeout - current_timestamp
    local message = S('You’re eating too fast!')
    local info = S('Wait for eating timeout to end: @1s', wait)
    chat_send(player_name, message..' '..info)
    return itemstack
  else
    f.set_data(player_name, a.eating_timestamp, current_timestamp)
  end
  --minetest.log('hunger_ng.register_on_item_eat() h')

  core.sound_play(eating_sound, { to_player = player_name })
  f.alter_hunger(player_name, satiates, 'eating')
  f.alter_health(player_name, heals, 'eating')
  f.alter_poop_soon(player_name, digests, 'eating', digest_interval)
  f.alter_sleep    (player_name, rests,   'eating')
  itemstack:take_item(1)

  if hunger_def.returns then
    local inventory = user:get_inventory()
    inventory:add_item('main', hunger_def.returns..' 1')
  end

  return itemstack
end)


-- Initial hunger and hunger bar configuration
--
-- When a player joins it is checked if the custom attribute for hunger is set.
-- If hunger persistence is used then the value gets read and applied to the
-- hunger bar.
--
-- If the value is not set or hunger persistence is not used then the hunger
-- value to start with will be used. This can be different from the maximum
-- hunger value.
-- TODO expose
f.on_joinplayer = function(player)
  local player_name = player:get_player_name()
  local unset_h     = not f.get_data(player_name, a.hunger_value)
  local unset_p     = not f.get_data(player_name, a.poop_value)
  local unset_s     = not f.get_data(player_name, a.sleep_value)
  local unset       = unset_h or unset_p or unset_s
  local reset_h     = f.get_data(player_name, a.hunger_value) and not s.hunger.persistent
  local reset_p     = f.get_data(player_name, a.poop_value)   and not s.poop.persistent
  local reset_s     = f.get_data(player_name, a.sleep_value)  and not s.sleep.persistent
  local reset       = reset_h or reset_p or reset_s

  -- Only set if the value is not set or if hunger is configured not
  -- being persistent.
  if unset or reset then
    if c.debug_mode then
      local message = 'Set initial hunger values for '..player_name
      core_log('action', c.log_prefix..message)
    end
    f.set_data(player_name, a.hunger_value, s.hunger.start_with)
    f.set_data(player_name, a.eating_timestamp, 0)
    f.set_data(player_name, a.hunger_disabled, 0)
    f.set_data(player_name, a.poop_value,   s.poop.start_with)
    f.set_data(player_name, a.pooping_timestamp,  0)
    f.set_data(player_name, a.poop_disabled,      0)
    f.set_data(player_name, a.sleep_value,  s.sleep.start_with)
    f.set_data(player_name, a.sleeping_timestamp, 0)
    f.set_data(player_name, a.sleep_disabled,     0)
  end

  -- Always reset (enable) hunger effect settings
  f.set_data(player_name, a.effect_hunger, 'enabled')
  f.set_data(player_name, a.effect_heal, 'enabled')
  f.set_data(player_name, a.effect_starve, 'enabled')
  f.set_data(player_name, a.effect_digest, 'enabled')
  f.set_data(player_name, a.effect_sleep,  'enabled')

  -- Only set hunger bar ID if hunger bar is configured to be used
  if s.hunger_bar.use then
    --minetest.log('using hunger bar')
    f.set_data(player_name, a.hunger_bar_id, player:hud_add({
      type = 'statbar',
      position = { x=0.5, y=1 },
      text = hunger_ng.hunger_bar_image,
      direction = 0,
      number = f.get_data(player_name, a.hunger_value),
      size = { x=24, y=24 },
      offset = {x=25,y=-(48+24+16)},
    }))
  end

  if s.poop_bar.use then
    --minetest.log('using poop bar')
    assert(hunger_ng.poop_bar_image ~= nil)
    assert(f.get_data(player_name, a.poop_value) ~= nil)
    f.set_data(player_name, a.poop_bar_id, player:hud_add({
      type = 'statbar',
      position = { x=0.5, y=0.98 },
      text = hunger_ng.poop_bar_image,
      direction = 0,
      number = f.get_data(player_name, a.poop_value),
      size = { x=24, y=24 },
      offset = {x=25,y=-(48+24+16)},
    }))
  end

  if s.sleep_bar.use then
    --minetest.log('using sleep bar')
    assert(hunger_ng.sleep_bar_image ~= nil)
    assert(f.get_data(player_name, a.sleep_value) ~= nil)
    f.set_data(player_name, a.sleep_bar_id, player:hud_add({
      type = 'statbar',
      position = { x=0.5, y=0.96 },
      text = hunger_ng.sleep_bar_image,
      direction = 0,
      number = f.get_data(player_name, a.sleep_value),
      size = { x=24, y=24 },
      offset = {x=25,y=-(48+24+16)},
    }))
  end

end
core.register_on_joinplayer(f.on_joinplayer)
