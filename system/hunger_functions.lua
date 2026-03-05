-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator

-- Localize Luanti
local core_log = core.log
local get_player_by_name = core.get_player_by_name
local get_current_modname = core.get_current_modname


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
    local player = get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)
    --if not player then return false end
    assert(player ~= nil)

    local player_meta = player:get_meta()

    if as_string then
        return tostring(player_meta:get(field) or 'invalid')
    else
        return tonumber(player_meta:get(field) or nil)
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
    local player = get_player_by_name(playername)
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
    --minetest.log('interact: '..tostring(interact))
    local disabled = get_data(playername, a.hunger_disabled)
    --minetest.log('disabled: '..tostring(disabled))
    if core.is_yes(disabled) or not interact then return true end
    return false
end
local poop_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.poop_disabled)
    if core.is_yes(disabled) or not interact then return true end
    --return false
    return hunger_disabled(playername)
end
local sleep_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.sleep_disabled)
    if core.is_yes(disabled) or not interact then return true end
    return false
end
local thirst_disabled = function (playername)
    local interact = core.check_player_privs(playername, { interact=true })
    --local interact = ia_names.check_actor_privs(playername, { interact=true })
    local disabled = get_data(playername, a.thirst_disabled)
    if core.is_yes(disabled) or not interact then return true end
    --return false
    return hunger_disabled(playername)
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
    if not action then return end

    if action == 'enable' then
        set_data(playername, a.hunger_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.hunger_disabled, 1)
    end
end
local configure_poop = function (playername, action)
    if not action then return end

    if action == 'enable' then
        set_data(playername, a.poop_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.poop_disabled, 1)
    end
end
local configure_sleep = function (playername, action)
    if not action then return end

    if action == 'enable' then
        set_data(playername, a.sleep_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.sleep_disabled, 1)
    end
end
local configure_thirst = function (playername, action)
    if not action then return end

    if action == 'enable' then
        set_data(playername, a.thirst_disabled, 0)
    elseif action == 'disable' then
        set_data(playername, a.thirst_disabled, 1)
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
    local player = get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)
    if not player then return { invalid = true, player_name = playername } end

    local last_eaten = get_data(playername, a.eating_timestamp) or 0
    local last_pooped    = get_data(playername, a.pooping_timestamp)  or 0
    local last_slept     = get_data(playername, a.sleeping_timestamp) or 0
    local last_drank     = get_data(playername, a.drinking_timestamp) or 0
    local current_hunger = get_data(playername, a.hunger_value)
    local current_poop   = get_data(playername, a.poop_value)
    local current_sleep  = get_data(playername, a.sleep_value)
    local current_thirst = get_data(playername, a.thirst_value)
    local player_properties = player:get_properties()

    local e_heal = get_data(playername, a.effect_heal, true) == 'enabled'
    local e_hunger = get_data(playername, a.effect_hunger, true) == 'enabled'
    local e_starve = get_data(playername, a.effect_starve, true) == 'enabled'
    local e_digest    = get_data(playername, a.effect_digest,    true) == 'enabled'
    local e_sleep     = get_data(playername, a.effect_sleep,     true) == 'enabled'
    local e_dehydrate = get_data(playername, a.effect_dehydrate, true) == 'enabled'

    return {
        player_name = playername,
        hunger = {
            floored = math.floor(current_hunger),
            ceiled = math.ceil(current_hunger),
            disabled = hunger_disabled(playername),
            exact = current_hunger,
            enabled = e_heal,
        },
        maximum = {
            hunger = s.hunger.maximum,
            health = player_properties.hp_max,
            breath = player_properties.breath_max,

	    poop   = s.poop.maximum,
	    sleep  = s.sleep.maximum,
	    thirst = s.thirst.maximum,
        },
        effects = {
            starving = {
                enabled = e_starve,
                status = current_hunger < e.starve.below
            },
            healing = {
                enabled = e_heal,
                status = current_hunger > e.heal.above
            },
            current_breath = player:get_breath(),

	    digesting = {
                enabled = e_digest,
		status  = current_poop   > e.digest.above,
            },
	    sleeping  = {
                enabled = e_sleep,
		status  = current_sleep  < e.sleep.below,
            },
	    dehyrate  = {
                enabled = e_dehydrate,
		status  = current_thirst < e.thirst.below,
            },
        },
        timestamps = {
            last_eaten = tonumber(last_eaten),
            request = tonumber(os.time()),

	    last_pooped = tonumber(last_pooped),
	    last_slept  = tonumber(last_slept),
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
    }
end


-- Alter health by given value
--
-- @param playername The name of a player whose health value should be altered
-- @param change     The health change (can be negative to damage the player)
hunger_ng.functions.alter_health = function (playername, change, reason)
    local player = get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)
    local hp_max = player:get_properties().hp_max

    if player == nil then return end
    if hunger_disabled(playername) then return end

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
    local player = get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    --if player == nil then return end
    assert(player ~= nil)
    if hunger_disabled(playername) then
	    minetest.log('hunger disabled for '..playername)
	    return
    end

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
    local player = get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    if player == nil then return end
    if poop_disabled(playername) then return end

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
		ia_pooper.play_rumble_sound(playername)
		return
	end
	assert(change >= current_poop)
	local poop_below = e.digest.below
	if change < poop_below then -- not enough
		ia_pooper.play_rumble_sound(playername)
		return
	end
	assert(change >= poop_below)
	ia_pooper.defecate(playername)
end
hunger_ng.functions.alter_sleep = function (playername, change, reason)
    local player = get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    if player == nil then return end
    if sleep_disabled(playername) then return end

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
    local player = get_player_by_name(playername)
    --local player = ia_names.get_actor_by_name(playername)

    if player == nil then return end
    if thirst_disabled(playername) then return end

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
            ['+m'] = get_current_modname(),
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
            ['+m'] = get_current_modname(),
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
hunger_ng.functions.thirst_disabled  = sleep_disabled
hunger_ng.functions.configure_thirst = configure_sleep
