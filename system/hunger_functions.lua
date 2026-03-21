-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator

-- Localize Luanti
local core_log = core.log
--local get_player_by_name = core.get_player_by_name -- monkey-patches
--local get_current_modname = core.get_current_modname -- monkey-patches


-- Gets and returns the given player-related data
--
-- To gain more flexibility this function is used wherever something from the
-- player has to be loaded either as custom player attribute or as planned
-- player meta data.
--
-- @param playername The name of the player to get the information from
-- @param field      The field that has to be get.
-- @param as_string  Optionally return the value of the field as string
-- @return bool|string|number
local get_data = function (playername, field, as_string)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)
    --if not player then return false end
    assert(player ~= nil)

    local player_meta = player:get_meta()
    assert(player_meta ~= nil)

    local value = player_meta:get(field)
    --minetest.log('hunger_ng.get_data('..playername..') field: '..tostring(field))
    --minetest.log('hunger_ng.get_data('..playername..') value: '..tostring(value))
    --assert(value ~= nil)
    if as_string then
        return tostring(value or 'invalid')
    else
        return tonumber(value or nil)
    end
end


-- Sets a player-related attribute
--
-- To gain more flexibility on the player-related functions this function can
-- be used wherever a player-related attribute has to be set.
--
-- @param playername The name of the player to set the attribute to
-- @param field      The field to set
-- @param value      The value to set the field to
-- @return void
local set_data = function (playername, field, value)
    assert(type(playername) == 'string')
    --assert(type(field) == 'string', type(field))
    --assert(type(value) == 'string', type(value))
    assert(field ~= nil)
    assert(value ~= nil)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)
    --if not player then return false end
    assert(player ~= nil)
    local player_meta = player:get_meta()
    assert(player_meta ~= nil)
    --minetest.log('hunger_ng.set_data('..playername..') field: '..tostring(field))
    --minetest.log('hunger_ng.set_data('..playername..') value: '..tostring(value))
    player_meta:set_string(field, value)
    --minetest.log('value: '..value)
    --minetest.log('data : '..get_data(playername, field, true))
    assert(value ~= nil)
    assert(get_data(playername, field, true) == tostring(value))
end



-- Print health and hunger changes
--
-- This function prints all health and hunger changes that are triggered by
-- this mod. The following information will be shown for every change.
--
-- t: Ingame time when the change was applied
-- p: player name affected by the change
-- w: Information on what was changes (hunger/health)
-- n: The new value as defined by the definition
-- d: definition (calculation) of the change (old + change = new)
--
-- @param playername Name of the player (p)
-- @param what       Description on what was changed (w, hunger/health)
-- @param old        The old value
-- @param new        The new value
-- @param change     The change amount
-- @param reason     The given reason for the change
-- @return void
local debug_log = function (playername, what, old, new, change, reason)
    if not c.debug_mode then return end
    local timestamp = 24 * 60 * core.get_timeofday()
    local h = tostring((math.floor(timestamp/60) % 60))
    local m = tostring((math.floor(timestamp) % 60))
    local text = ('t: +t, p: +p, w: +w, n: +n, d: +o + +c, r: +r'):gsub('+.', {
        ['+t'] = string.rep('0', 2-#h)..h..':'..string.rep('0', 2-#m)..m,
        ['+p'] = playername,
        ['+w'] = what,
        ['+o'] = old,
        ['+n'] = new,
        ['+c'] = change,
        ['+r'] = reason or 'n/a'
    })
    core_log('action', c.log_prefix..text)
end


-- Returns if hunger is disabled for the given player
--
-- When the player is no `interact` permission or has the `hunger_disabled`
-- parameter set then this function returns boolean true. Otherwise boolean
-- false will be returned.
--
-- @param playername The name of the player to check
-- @return bool
local hunger_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    --minetest.log('hunger_ng.hunger_disabled('..playername..') interact: '..tostring(interact))
    local disabled = get_data(playername, a.hunger_disabled)
    --minetest.log('hunger_ng.hunger_disabled('..playername..') disabled: '..tostring(disabled))
    assert(interact)
    assert(not core.is_yes(disabled))
    if core.is_yes(disabled) or not interact then return true end
    return false
end
local poop_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.poop_disabled)
    assert(interact)
    assert(not core.is_yes(disabled))
    if core.is_yes(disabled) or not interact then return true end
    --return false
    return hunger_disabled(playername)
end
local sleep_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.sleep_disabled)
    assert(interact)
    assert(not core.is_yes(disabled))
    if core.is_yes(disabled) or not interact then return true end
    return false
end
local thirst_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.thirst_disabled)
    assert(interact)
    assert(not core.is_yes(disabled))
    if core.is_yes(disabled) or not interact then return true end
    --return false
    return hunger_disabled(playername)
end
local pee_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.pee_disabled)
    assert(interact)
    assert(not core.is_yes(disabled))
    if core.is_yes(disabled) or not interact then return true end
    --return false
    return thirst_disabled(playername)
end
local preggo_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.preggo_disabled)
    assert(interact)
    assert(not core.is_yes(disabled))
    if core.is_yes(disabled) or not interact then return true end
    --return false
    return false
end
local milk_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.milk_disabled)
    assert(interact)
    assert(not core.is_yes(disabled))
    if core.is_yes(disabled) or not interact then return true end
    --return false
    return preggo_disabled(playername)
end


-- Configures hunger effects for the player
--
-- The function can enable or disable hunger for a player. It is meant to be
-- used by other mods to disable or enable hunger effects for a specific
-- player. For example a magic item that prevents players from getting hungry.
--
-- The parameter `action` can be either `disable`, `enable`. The actions are
-- very self-explainatory.
--
-- @param playername The name of the player whose hunger is to be configured
-- @param action     The action that will be taken as described
local configure_hunger = function (playername, action)
    --if not action then return end
    assert(action)

    if action == 'enable' then
        set_data(playername, a.hunger_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.hunger_disabled, 1)
    else assert(false)
    end
end
local configure_poop = function (playername, action)
    --if not action then return end
    assert(action)

    if action == 'enable' then
        set_data(playername, a.poop_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.poop_disabled, 1)
    else assert(false)
    end
end
local configure_sleep = function (playername, action)
    --if not action then return end
    assert(action)

    if action == 'enable' then
        set_data(playername, a.sleep_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.sleep_disabled, 1)
    else assert(false)
    end
end
local configure_thirst = function (playername, action)
    --if not action then return end
    assert(action)

    if action == 'enable' then
        set_data(playername, a.thirst_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.thirst_disabled, 1)
    else assert(false)
    end
end
local configure_pee = function (playername, action)
    --if not action then return end
    assert(action)

    if action == 'enable' then
        set_data(playername, a.pee_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.pee_disabled, 1)
    else assert(false)
    end
end
local configure_milk = function (playername, action)
    --if not action then return end
    assert(action)

    if action == 'enable' then
        set_data(playername, a.milk_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.milk_disabled, 1)
    else assert(false)
    end
end
local configure_preggo = function (playername, action)
    --if not action then return end
    assert(action)

    if action == 'enable' then
        set_data(playername, a.preggo_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.preggo_disabled, 1)
    else assert(false)
    end
end


-- Get the current hunger information
--
-- Gets (Returns) the current hunger information for the given player. See API
-- documentation for a detailled overview of the returned table.
--
-- @param playername The name of the player whose hunger value is to be get
-- @return table     The table as described
hunger_ng.functions.get_hunger_information = function (playername)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)
    --if not player then return { invalid = true, player_name = playername } end
    assert(player)

    local last_eaten = get_data(playername, a.eating_timestamp) or 0
    local last_pooped    = get_data(playername, a.pooping_timestamp)  or 0
    local last_slept     = get_data(playername, a.sleeping_timestamp) or 0
    local last_drank     = get_data(playername, a.drinking_timestamp) or 0
    local last_peed      = get_data(playername, a.peeing_timestamp)   or 0
    local last_milked    = get_data(playername, a.milking_timestamp)  or 0
    local last_preggoed  = get_data(playername, a.preggo_timestamp)   or 0 -- TODO conception or birth time ?
    local current_hunger = get_data(playername, a.hunger_value)
    local current_poop   = get_data(playername, a.poop_value)
    local current_sleep  = get_data(playername, a.sleep_value)
    local current_thirst = get_data(playername, a.thirst_value)
    local current_pee    = get_data(playername, a.pee_value)
    local current_milk   = get_data(playername, a.milk_value)
    local current_preggo = get_data(playername, a.preggo_value)
    local player_properties = player:get_properties()

    local e_heal = get_data(playername, a.effect_heal, true) == 'enabled'
    local e_hunger = get_data(playername, a.effect_hunger, true) == 'enabled'
    local e_starve = get_data(playername, a.effect_starve, true) == 'enabled'
    local e_digest    = get_data(playername, a.effect_digest,    true) == 'enabled'
    local e_sleep     = get_data(playername, a.effect_sleep,     true) == 'enabled'
    local e_dehydrate = get_data(playername, a.effect_dehydrate, true) == 'enabled'
    local e_hydrate   = get_data(playername, a.effect_hydrate,   true) == 'enabled'
    local e_lactate   = get_data(playername, a.effect_lactate,   true) == 'enabled'
    local e_procreate = get_data(playername, a.effect_procreate, true) == 'enabled'

    return {
        player_name = playername,
        hunger = {
            floored = math.floor(current_hunger),
            ceiled = math.ceil(current_hunger),
            disabled = hunger_disabled(playername),
            exact = current_hunger,
            enabled = e_heal, -- e_hunger ?
        },
        maximum = {
            hunger = s.hunger.maximum,
            health = player_properties.hp_max,
            breath = player_properties.breath_max,

	    poop   = s.poop.maximum,
	    sleep  = s.sleep.maximum,
	    thirst = s.thirst.maximum,
	    pee    = s.pee.maximum,
	    milk   = s.milk.maximum,
	    preggo = s.preggo.maximum,
        },
        effects = {
            starving       = {
                enabled = e_starve,
                status  = current_hunger < e.starve.below,
		below   = e.starve.below,
            },
            healing        = {
                enabled = e_heal,
                status  = current_hunger > e.heal.above,
		above   = e.heal.above,
            },
            current_breath = player:get_breath(),

	    digesting      = {
                enabled = e_digest,
		status  = current_poop   > e.digest.above,
		above   = e.digest.above,
		able    = current_poop   > e.digest.below,
		below   = e.digest.below,
            },
	    sleeping  = {
                enabled = e_sleep,
		status  = current_sleep  < e.sleep.below,
		below   = e.sleep.below,
            },
	    dehydrate = {
                enabled = e_dehydrate,
		status  = current_thirst < e.dehydrate.below,
		below   = e.dehydrate.below,
            },
	    hydrate   = {
                enabled = e_hydrate,
		status  = current_pee    > e.hydrate.above,
		above   = e.hydrate.above,
		able    = current_pee    > e.hydrate.below,
		below   = e.hydrate.below,
            },
	    lactate   = {
                enabled = e_lactate,
		status  = current_milk   > e.lactate.above,
		above   = e.lactate.above,
		able    = current_milk   > e.lactate.below,
		below   = e.lactate.below,
            },
	    procreate = {
                enabled = e_procreate,
		status  = current_preggo   > e.procreate.above,
		above   = e.procreate.above,
		able    = current_preggo   > e.procreate.below,
		below   = e.procreate.below,
            },
        },
        timestamps = {
            last_eaten    = tonumber(last_eaten),
            request       = tonumber(os.time()),

	    last_pooped   = tonumber(last_pooped),
	    last_slept    = tonumber(last_slept),
	    last_drank    = tonumber(last_drank),
	    last_peed     = tonumber(last_peed),
	    last_milked   = tonumber(last_milked),
	    last_preggoed = tonumber(last_preggoed),
        },

        poop   = {
            floored  = math.floor(current_poop),
            ceiled   = math.ceil (current_poop),
            disabled = poop_disabled  (playername),
            exact    = current_poop,
            enabled  = e_digest,
        },
        sleep  = {
            floored  = math.floor(current_sleep),
            ceiled   = math.ceil (current_sleep),
            disabled = sleep_disabled (playername),
            exact    = current_sleep,
            enabled  = e_sleep,
        },
        thirst = {
            floored  = math.floor(current_thirst),
            ceiled   = math.ceil (current_thirst),
            disabled = thirst_disabled(playername),
            exact    = current_thirst,
            enabled  = e_dehydrate,
        },
        pee    = {
            floored  = math.floor(current_pee),
            ceiled   = math.ceil (current_pee),
            disabled = pee_disabled   (playername),
            exact    = current_pee,
            enabled  = e_hydrate,
        },
        milk   = {
            floored  = math.floor(current_milk),
            ceiled   = math.ceil (current_milk),
            disabled = milk_disabled  (playername),
            exact    = current_milk,
            enabled  = e_lactate,
        },
        preggo = {
            floored  = math.floor(current_preggo),
            ceiled   = math.ceil (current_preggo),
            disabled = preggo_disabled  (playername),
            exact    = current_preggo,
            enabled  = e_procreate,
        },
    }
end


-- Alter health by given value
--
-- @param playername The name of a player whose health value should be altered
-- @param change     The health change (can be negative to damage the player)
hunger_ng.functions.alter_health = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)
    local hp_max = player:get_properties().hp_max

    --if player == nil then return end
    assert(player ~= nil)
    --if hunger_disabled(playername) then return end
    assert(not hunger_disabled(playername))

    local current_health = player:get_hp()
    local new_health = current_health + change

    if new_health > hp_max then new_health = hp_max end
    if new_health < 0 then new_health = 0 end

    player:set_hp(new_health, { hunger = reason })
    debug_log(playername, 'health', current_health, new_health, change, reason)
end


-- Alter hunger by the given value
--
-- @param playername The name of a player whose hunger value should be altered
-- @param change     The hunger change (can be negative to make player hungry)
hunger_ng.functions.alter_hunger = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    --if hunger_disabled(playername) then return end
    assert(not hunger_disabled(playername))

    local current_hunger = get_data(playername, a.hunger_value)
    local new_hunger = current_hunger + change
    local bar_id = get_data(playername, a.hunger_bar_id)

    if new_hunger > s.hunger.maximum then new_hunger = s.hunger.maximum end
    if new_hunger < 0 then new_hunger = 0 end

    set_data(playername, a.hunger_value, new_hunger)

    if s.hunger_bar.use then
        player:hud_change(bar_id, 'number', math.ceil(new_hunger))
    end

    debug_log(playername, 'hunger', current_hunger, new_hunger, change, reason)
end
hunger_ng.functions.alter_poop = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    --if poop_disabled(playername) then return end
    assert(not poop_disabled(playername))

    local current_poop = get_data(playername, a.poop_value)
    local new_poop = current_poop + change
    local bar_id = get_data(playername, a.poop_bar_id)

    if new_poop > s.poop.maximum then new_poop = s.poop.maximum end
    if new_poop < 0 then new_poop = 0 end

    set_data(playername, a.poop_value, new_poop)

    if s.poop_bar.use then
        player:hud_change(bar_id, 'number', math.ceil(new_poop))
    end

    debug_log(playername, 'poop', current_poop, new_poop, change, reason)
end
hunger_ng.functions.alter_poop_soon = function (playername, change, reason, dt)
	minetest.after(dt, function()
		f.alter_poop(playername, change, reason)
	end)
end
hunger_ng.functions.defecate = function(playername, change, reason)
	assert(change == nil or change > 0)
	local current_poop = get_data(playername, a.poop_value)
--	if current_poop <= 0 then
--		minetest.chat_send_player(player, "Your bowels are empty!")
--		return
--	end
	assert(current_poop > 0)
	if change == nil then
		change = current_poop
	end
	assert(change > 0)
	f.alter_poop(playername, -change, reason)
	if change < current_poop then -- shit yourself
		pooper.play_rumble_sound(playername)
		return
	end
	assert(change >= current_poop)
	local poop_below = e.digest.below
	if change < poop_below then -- not enough
		pooper.play_rumble_sound(playername)
		return
	end
	assert(change >= poop_below)
	pooper.defecate(playername)
end
hunger_ng.functions.alter_sleep = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    --if sleep_disabled(playername) then return end
    assert(not sleep_disabled(playername))

    local current_sleep = get_data(playername, a.sleep_value)
    local new_sleep = current_sleep + change
    local bar_id = get_data(playername, a.sleep_bar_id)

    if new_sleep > s.sleep.maximum then new_sleep = s.sleep.maximum end
    if new_sleep < 0 then new_sleep = 0 end

    set_data(playername, a.sleep_value, new_sleep)

    if s.sleep_bar.use then
        player:hud_change(bar_id, 'number', math.ceil(new_sleep))
    end

    debug_log(playername, 'sleep', current_sleep, new_sleep, change, reason)
end
-- TODO allow sleep without bed? i.e., may cause injury in general, and also temperature damage
hunger_ng.functions.alter_thirst = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    --if thirst_disabled(playername) then return end
    assert(not thirst_disabled(playername))

    local current_thirst = get_data(playername, a.thirst_value)
    local new_thirst = current_thirst + change
    local bar_id = get_data(playername, a.thirst_bar_id)

    if new_thirst > s.thirst.maximum then new_thirst = s.thirst.maximum end
    if new_thirst < 0 then new_thirst = 0 end

    set_data(playername, a.thirst_value, new_thirst)

    if s.thirst_bar.use then
        player:hud_change(bar_id, 'number', math.ceil(new_thirst))
    end

    debug_log(playername, 'thirst', current_thirst, new_thirst, change, reason)
end
hunger_ng.functions.alter_pee = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    --if pee_disabled(playername) then return end
    assert(not pee_disabled(playername))

    local current_pee = get_data(playername, a.pee_value)
    local new_pee = current_pee + change
    local bar_id = get_data(playername, a.pee_bar_id)

    if new_pee > s.pee.maximum then new_pee = s.pee.maximum end
    if new_pee < 0 then new_pee = 0 end

    set_data(playername, a.pee_value, new_pee)

    if s.pee_bar.use then
        player:hud_change(bar_id, 'number', math.ceil(new_pee))
    end

    debug_log(playername, 'pee', current_pee, new_pee, change, reason)
end
hunger_ng.functions.alter_pee_soon = function (playername, change, reason, dt)
	minetest.after(dt, function()
		f.alter_pee(playername, change, reason)
	end)
end
hunger_ng.functions.urinate = function(playername, change, reason)
	assert(change == nil or change > 0)
	local current_pee = get_data(playername, a.pee_value)
--	if current_pee <= 0 then
--		minetest.chat_send_player(player, "Your bladder is empty!")
--		return
--	end
	assert(current_pee > 0)
	if change == nil then
		change = current_pee
	end
	assert(change > 0)
	f.alter_pee(playername, -change, reason)
	if change < current_pee then -- piss yourself
		ia_peeer.play_splatter_sound(playername)
		return
	end
	assert(change >= current_pee)
	local pee_below = e.hydrate.below
	if change < pee_below then -- not enough
		ia_peeer.play_zipper_sound(playername)
		return
	end
	assert(change >= pee_below)
	ia_peeer.urinate(playername, change)
end
hunger_ng.functions.alter_milk = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    --if milk_disabled(playername) then return end
    assert(not milk_disabled(playername))

    local current_milk = get_data(playername, a.milk_value)
    local new_milk = current_milk + change
    local bar_id = get_data(playername, a.milk_bar_id)

    if new_milk > s.milk.maximum then new_milk = s.milk.maximum end
    if new_milk < 0 then new_milk = 0 end

    set_data(playername, a.milk_value, new_milk)

    if s.milk_bar.use then
        player:hud_change(bar_id, 'number', math.ceil(new_milk))
    end

    debug_log(playername, 'milk', current_milk, new_milk, change, reason)
end
hunger_ng.functions.alter_milk_soon = function (playername, change, reason, dt)
	minetest.after(dt, function()
		f.alter_milk(playername, change, reason)
	end)
end
hunger_ng.functions.lactate = function(playername, change, reason)
	assert(change == nil or change > 0)
	local current_milk = get_data(playername, a.milk_value)
--	if current_milk <= 0 then
--		minetest.chat_send_player(player, "Your milkers are empty!")
--		return
--	end
	assert(current_milk > 0)
	if change == nil then
		change = current_milk
	end
	assert(change > 0)
	f.alter_milk(playername, -change, reason)
	if change < current_milk then -- piss yourself
		--ia_milker.play_splatter_sound(playername)
		return
	end
	assert(change >= current_milk)
	local milk_below = e.lactate.below
	if change < milk_below then -- not enough
		--ia_milker.play_zipper_sound(playername)
		return
	end
	assert(change >= milk_below)
	assert(playername ~= nil)
	assert(change ~= nil)
	ia_milker.lactate(playername, change)
end
hunger_ng.functions.alter_preggo = function (playername, change, reason)
    local player = core.get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    --if preggo_disabled(playername) then return end
    assert(not preggo_disabled(playername))

    local current_preggo = get_data(playername, a.preggo_value)
    local new_preggo = current_preggo + change
    local bar_id = get_data(playername, a.preggo_bar_id)

    if new_preggo > s.preggo.maximum then new_preggo = s.preggo.maximum end
    if new_preggo < 0 then new_preggo = 0 end

    set_data(playername, a.preggo_value, new_preggo)

    if s.preggo_bar.use then
        player:hud_change(bar_id, 'number', math.ceil(new_preggo))
    end

    debug_log(playername, 'preggo', current_preggo, new_preggo, change, reason)
end
hunger_ng.functions.procreate = function(playername, change, reason)
	assert(change == nil or change > 0)
	local current_preggo = get_data(playername, a.preggo_value)
--	if current_preggo <= 0 then
--		minetest.chat_send_player(player, "Your womb is empty!")
--		return
--	end
	assert(current_preggo > 0)
	if change == nil then
		change = current_preggo
	end
	assert(change > 0)
	f.alter_preggo(playername, -change, reason)
	if change < current_preggo then -- somehow become less pregnant
		ia_breeder.play_splatter_sound(playername)
		-- TODO set hp or spawn ketchup ?
		return
	end
	assert(change >= current_preggo)
	local preggo_below = e.procreate.below
	if change < preggo_below then -- miscarriage
		ia_breeder.play_splatter_sound(playername)
		-- TODO set hp or spawn ketchup ?
		return
	end
	assert(change >= preggo_below)
	assert(playername ~= nil)
	assert(change ~= nil)
	ia_breeder.execute_birth(playername)
end


-- Set hunger effect metadata
--
-- The hunger effect meta data can be set by mods to temporary disable hunger
-- effects for the given player. Everything works normal but hunger effects
-- like hunger itself, starving and healing are not performed even if the
-- player is in a state where this would happen.
--
-- The effect is not persistent. When a player rejoins the setting is actively
-- removed during join time of that player. Mods need to actively track the
-- status if they want the setting persist between joins.
--
-- @see hunger_ng.alter_hunger
-- @see system/timers.lua
--
-- @param playername Name of the player to set the effect for
-- @param effect     The effect name as described
-- @param setting    Either `enabled` or `disabled`
-- @return void
hunger_ng.set_effect = function (playername, effect, setting)
    local attribute = a['effect_'..effect] or false
    local allowed_values = { enabled = true, disabled = true  }

    -- Warn in server log when a mod tries to configure an unknown effect
    if attribute == false then
        core_log('warning', ('+t +m tried to set +v for +p'):gsub('+.', {
            ['+t'] = '[hunger_ng]',
            ['+m'] = core.get_current_modname(),
            ['+v'] = 'unknown effect '..effect,
            ['+p'] = playername
        }))
        return
    end

    -- Set the attribute according to what the mod wants and log that setting
    if allowed_values[setting] == true then
        set_data(playername, attribute, setting)
        core_log('verbose', ('+t +m sets +a to +v for +p'):gsub('+.', {
            ['+t'] = '[hunger_ng]',
            ['+m'] = core.get_current_modname(),
            ['+a'] = attribute,
            ['+v'] = setting,
            ['+p'] = playername
        }))
     end
end


-- Globalize the set and get function for player data for use in other files
hunger_ng.functions.get_data = get_data
hunger_ng.functions.set_data = set_data
hunger_ng.functions.hunger_disabled = hunger_disabled
hunger_ng.functions.configure_hunger = configure_hunger

hunger_ng.functions.poop_disabled    = poop_disabled
hunger_ng.functions.configure_poop   = configure_poop
hunger_ng.functions.sleep_disabled   = sleep_disabled
hunger_ng.functions.configure_sleep  = configure_sleep
hunger_ng.functions.thirst_disabled  = thirst_disabled
hunger_ng.functions.configure_thirst = configure_thirst
hunger_ng.functions.pee_disabled     = pee_disabled
hunger_ng.functions.milk_disabled    = milk_disabled
hunger_ng.functions.configure_pee    = configure_pee
hunger_ng.functions.configure_milk   = configure_milk
hunger_ng.functions.preggo_disabled  = preggo_disabled
hunger_ng.functions.configure_preggo = configure_preggo
