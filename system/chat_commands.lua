-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator


-- Localize Luanto
local chat_send = core.chat_send_player
local log = core.log
local player_exists = core.player_exists
local get_player_by_name = core.get_player_by_name
local get_connected_players = core.get_connected_players


-- Set hunger to given value
--
-- Sets the hunger of the given player to the given value. If the player name
-- is omitted own hunger is set.
--
-- @param name   The name of the target player
-- @param value  The hunger value to set to
-- @param caller The player who invoked the command
-- @return mixed `void` if player exists, otherwise `nil`
local set_hunger = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.hunger_disabled(name) then
        chat_send(caller, S('Hunger for @1 is disabled', name))
        return
    end

    if value > s.hunger.maximum then value = s.hunger.maximum end
    if value < 0 then value = 0 end

    f.alter_hunger(name, -s.hunger.maximum, 'chat set 0')
    f.alter_hunger(name, value, 'chat set target')

    if name ~= caller then
        chat_send(caller, S('Hunger for @1 set to @2', name, value))
        chat_send(name, S('@1 set your hunger to @2', caller, value))
        message = caller..' sets hunger for '..name..' to '..value
    else
        chat_send(caller, S('Hunger set to @1', value))
        message = caller..' sets own hunger to '..value
    end

    log('action', '[hunger_ng] '..message)
end
local set_poop = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.poop_disabled(name) then
        chat_send(caller, S('Poop for @1 is disabled', name))
        return
    end

    if value > s.poop.maximum then value = s.poop.maximum end
    if value < 0 then value = 0 end

    f.alter_poop(name, -s.poop.maximum, 'chat set 0')
    f.alter_poop(name, value, 'chat set target')

    if name ~= caller then
        chat_send(caller, S('Poop for @1 set to @2', name, value))
        chat_send(name, S('@1 set your poop to @2', caller, value))
        message = caller..' sets poop for '..name..' to '..value
    else
        chat_send(caller, S('Poop set to @1', value))
        message = caller..' sets own poop to '..value
    end

    log('action', '[hunger_ng] '..message)
end
local set_sleep = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.sleep_disabled(name) then
        chat_send(caller, S('Sleep for @1 is disabled', name))
        return
    end

    if value > s.sleep.maximum then value = s.sleep.maximum end
    if value < 0 then value = 0 end

    f.alter_sleep(name, -s.sleep.maximum, 'chat set 0')
    f.alter_sleep(name, value, 'chat set target')

    if name ~= caller then
        chat_send(caller, S('Sleep for @1 set to @2', name, value))
        chat_send(name, S('@1 set your sleep to @2', caller, value))
        message = caller..' sets sleep for '..name..' to '..value
    else
        chat_send(caller, S('Sleep set to @1', value))
        message = caller..' sets own sleep to '..value
    end

    log('action', '[hunger_ng] '..message)
end
local set_thirst = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.thirst_disabled(name) then
        chat_send(caller, S('Thirst for @1 is disabled', name))
        return
    end

    if value > s.thirst.maximum then value = s.thirst.maximum end
    if value < 0 then value = 0 end

    f.alter_thirst(name, -s.thirst.maximum, 'chat set 0')
    f.alter_thirst(name, value, 'chat set target')

    if name ~= caller then
        chat_send(caller, S('Thirst for @1 set to @2', name, value))
        chat_send(name, S('@1 set your thirst to @2', caller, value))
        message = caller..' sets thirst for '..name..' to '..value
    else
        chat_send(caller, S('Thirst set to @1', value))
        message = caller..' sets own thirst to '..value
    end

    log('action', '[hunger_ng] '..message)
end


-- Change the hunger value
--
-- Changes the hunger value of the given player by the given value. Use
-- negative values to substract hunger. If the player name is omitted the own
-- hunger gets changed.
--
-- @param name   The name of the target player
-- @param value  The hunger value to change by
-- @param caller The player who invoked the command
-- @return mixed `void` if player exists, otherwise `nil`
local change_hunger = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.hunger_disabled(name) then
        chat_send(caller, S('Hunger for @1 is disabled', name))
        return
    end

    if value > s.hunger.maximum then value = s.hunger.maximum end
    if value < -s.hunger.maximum then value = -s.hunger.maximum end

    f.alter_hunger(name, value, 'chat change')

    if name ~= caller then
        chat_send(caller, S('Hunger for @1 changed by @2', name, value))
        chat_send(name, S('@1 changed your hunger by @2', caller, value))
        message = caller..'changes hunger for '..name..' by '..value
    else
        chat_send(caller, S('Hunger changed by @1', value))
        message = caller..' changes own hunger by '..value
    end

    log('action', '[hunger_ng] '..message)
end
local change_poop = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.poop_disabled(name) then
        chat_send(caller, S('Poop for @1 is disabled', name))
        return
    end

    if value > s.poop.maximum then value = s.poop.maximum end
    if value < -s.poop.maximum then value = -s.poop.maximum end

    f.alter_poop(name, value, 'chat change')

    if name ~= caller then
        chat_send(caller, S('Poop for @1 changed by @2', name, value))
        chat_send(name, S('@1 changed your poop by @2', caller, value))
        message = caller..'changes poop for '..name..' by '..value
    else
        chat_send(caller, S('Poop changed by @1', value))
        message = caller..' changes own poop by '..value
    end

    log('action', '[hunger_ng] '..message)
end
local change_sleep = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.sleep_disabled(name) then
        chat_send(caller, S('Sleep for @1 is disabled', name))
        return
    end

    if value > s.sleep.maximum then value = s.sleep.maximum end
    if value < -s.sleep.maximum then value = -s.sleep.maximum end

    f.alter_sleep(name, value, 'chat change')

    if name ~= caller then
        chat_send(caller, S('Sleep for @1 changed by @2', name, value))
        chat_send(name, S('@1 changed your sleep by @2', caller, value))
        message = caller..'changes sleep for '..name..' by '..value
    else
        chat_send(caller, S('Sleep changed by @1', value))
        message = caller..' changes own sleep by '..value
    end

    log('action', '[hunger_ng] '..message)
end
local change_thirst = function (name, value, caller)
    local message = ''

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.thirst_disabled(name) then
        chat_send(caller, S('Thirst for @1 is disabled', name))
        return
    end

    if value > s.thirst.maximum then value = s.thirst.maximum end
    if value < -s.thirst.maximum then value = -s.thirst.maximum end

    f.alter_thirst(name, value, 'chat change')

    if name ~= caller then
        chat_send(caller, S('Thirst for @1 changed by @2', name, value))
        chat_send(name, S('@1 changed your thirst by @2', caller, value))
        message = caller..'changes thirst for '..name..' by '..value
    else
        chat_send(caller, S('Thirst changed by @1', value))
        message = caller..' changes own thirst by '..value
    end

    log('action', '[hunger_ng] '..message)
end


-- Toggle hunger being enabled
--
-- Toggles the hunger for the given player from enabled to disabled.
--
-- @param name   The name of the target player
-- @param caller The player who invoked the command
-- @return mixed `void` if player exists, otherwise `nil`
local toggle_hunger = function (name, value, caller)
    local message = ''
    local action = ''
    local name = name == '' and caller or name

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.hunger_disabled(name) then
        hunger_ng.configure_hunger(name, 'enable')
        action = 'enabled'
    else
        hunger_ng.configure_hunger(name, 'disable')
        action = 'disabled'
    end

    if name ~= caller then
        chat_send(caller, S('Hunger for @1 was toggled', name))
        chat_send(name, S('@1 toggled your hunger', caller))
        message = caller..' '..action..' hunger for '..name
    else
        chat_send(caller, S('Own hunger was toggled'))
        message = caller..' '..action..' own hunger'
    end

    log('action', '[hunger_ng] '..message)
end
local toggle_poop = function (name, value, caller)
    local message = ''
    local action = ''
    local name = name == '' and caller or name

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.poop_disabled(name) then
        hunger_ng.configure_poop(name, 'enable')
        action = 'enabled'
    else
        hunger_ng.configure_poop(name, 'disable')
        action = 'disabled'
    end

    if name ~= caller then
        chat_send(caller, S('Poop for @1 was toggled', name))
        chat_send(name, S('@1 toggled your poop', caller))
        message = caller..' '..action..' poop for '..name
    else
        chat_send(caller, S('Own poop was toggled'))
        message = caller..' '..action..' own poop'
    end

    log('action', '[hunger_ng] '..message)
end
local toggle_sleep = function (name, value, caller)
    local message = ''
    local action = ''
    local name = name == '' and caller or name

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.sleep_disabled(name) then
        hunger_ng.configure_sleep(name, 'enable')
        action = 'enabled'
    else
        hunger_ng.configure_sleep(name, 'disable')
        action = 'disabled'
    end

    if name ~= caller then
        chat_send(caller, S('Sleep for @1 was toggled', name))
        chat_send(name, S('@1 toggled your sleep', caller))
        message = caller..' '..action..' sleep for '..name
    else
        chat_send(caller, S('Own sleep was toggled'))
        message = caller..' '..action..' own sleep'
    end

    log('action', '[hunger_ng] '..message)
end
local toggle_thirst = function (name, value, caller)
    local message = ''
    local action = ''
    local name = name == '' and caller or name

    if not get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.thirst_disabled(name) then
        hunger_ng.configure_thirst(name, 'enable')
        action = 'enabled'
    else
        hunger_ng.configure_thirst(name, 'disable')
        action = 'disabled'
    end

    if name ~= caller then
        chat_send(caller, S('Thirst for @1 was toggled', name))
        chat_send(name, S('@1 toggled your thirst', caller))
        message = caller..' '..action..' thirst for '..name
    else
        chat_send(caller, S('Own thirst was toggled'))
        message = caller..' '..action..' own thirst'
    end

    log('action', '[hunger_ng] '..message)
end


-- Get the hunger value
--
-- When called without name parameter it gets the hunger values from all
-- currently connected players. If a name is given the hunger value for that
-- player is returned if the player is online
--
-- @param name   The name of the target player
-- @param caller The player who invoked the command
-- @return void
local get_hunger = function(name, caller)
    local message = ''

    if name == '' then name = get_connected_players()
    else name = { get_player_by_name(name) } end

    for _,player in pairs(name) do
        if player:is_player() then
            local player_name = player:get_player_name()
            local player_hunger = f.get_data(player_name, a.hunger_value)
            local hunger_disabled = f.hunger_disabled(player_name)

            if not hunger_disabled then
                chat_send(caller, player_name..': '..player_hunger)
            else
                chat_send(caller, player_name..': '..S('Hunger is disabled'))
            end

            if player_name == caller then
                message = caller..' gets own hunger value'
            else
                message = caller..' gets hunger value for '..player_name
            end

            log('action', '[hunger_ng] '..message)
        end
    end

    if #name == 0 then
        chat_send(caller, S('No player matches your criteria'))
    end
end
local get_poop = function(name, caller)
    local message = ''

    if name == '' then name = get_connected_players()
    else name = { get_player_by_name(name) } end

    for _,player in pairs(name) do
        if player:is_player() then
            local player_name = player:get_player_name()
            local player_poop = f.get_data(player_name, a.poop_value)
            local poop_disabled = f.poop_disabled(player_name)

            if not poop_disabled then
                chat_send(caller, player_name..': '..player_poop)
            else
                chat_send(caller, player_name..': '..S('Poop is disabled'))
            end

            if player_name == caller then
                message = caller..' gets own poop value'
            else
                message = caller..' gets poop value for '..player_name
            end

            log('action', '[hunger_ng] '..message)
        end
    end

    if #name == 0 then
        chat_send(caller, S('No player matches your criteria'))
    end
end
local get_sleep = function(name, caller)
    local message = ''

    if name == '' then name = get_connected_players()
    else name = { get_player_by_name(name) } end

    for _,player in pairs(name) do
        if player:is_player() then
            local player_name = player:get_player_name()
            local player_sleep = f.get_data(player_name, a.sleep_value)
            local sleep_disabled = f.sleep_disabled(player_name)

            if not sleep_disabled then
                chat_send(caller, player_name..': '..player_sleep)
            else
                chat_send(caller, player_name..': '..S('Sleep is disabled'))
            end

            if player_name == caller then
                message = caller..' gets own sleep value'
            else
                message = caller..' gets sleep value for '..player_name
            end

            log('action', '[hunger_ng] '..message)
        end
    end

    if #name == 0 then
        chat_send(caller, S('No player matches your criteria'))
    end
end
local get_thirst = function(name, caller)
    local message = ''

    if name == '' then name = get_connected_players()
    else name = { get_player_by_name(name) } end

    for _,player in pairs(name) do
        if player:is_player() then
            local player_name = player:get_player_name()
            local player_thirst = f.get_data(player_name, a.thirst_value)
            local thirst_disabled = f.thirst_disabled(player_name)

            if not thirst_disabled then
                chat_send(caller, player_name..': '..player_thirst)
            else
                chat_send(caller, player_name..': '..S('Thirst is disabled'))
            end

            if player_name == caller then
                message = caller..' gets own thirst value'
            else
                message = caller..' gets thirst value for '..player_name
            end

            log('action', '[hunger_ng] '..message)
        end
    end

    if #name == 0 then
        chat_send(caller, S('No player matches your criteria'))
    end
end


-- Show the help message
--
-- Shows the help message to the caller
--
-- @param caller The player who invoked the command
-- @return void
local show_help = function (caller)
    chat_send(caller, S('run `/help hunger` to show help'))
end


-- Register privilege for hunger control
core.register_privilege('manage_hunger', {
    description = S('Player can view and alter own and others hunger values.')
})


-- Administrative chat command definition
core.register_chatcommand('hunger', {
    params = '<set/change/get/toggle> <name> <value>',
    description = S('Modify or get hunger values'),
    privs = { manage_hunger = true },
    func = function (caller, parameters)
        local pt= {}
        for p in parameters:gmatch("%S+") do table.insert(pt, p) end
        local action = pt[1] or ''
        local name = pt[2] or ''
        local value = pt[3] or ''

        -- Name parameter missing
        if not player_exists(name) and tonumber(name) and value == '' then
            value = name
            name = caller
        end

        -- Convert value to number or print error message when trying to set
        -- a value but no proper value was given
        if tonumber(value) then
            value = tonumber(value)
        else
            if action ~= 'get' and action ~= 'toggle' then
                show_help(caller)
                return
            end
        end

        -- Execute the corresponding function for the defined action
        if     action == 'set' then set_hunger(name, value, caller)
        elseif action == 'change' then change_hunger(name, value, caller)
        elseif action == 'get' then get_hunger(name, caller)
        elseif action == 'toggle' then toggle_hunger(name, value, caller)
        else show_help(caller) end
    end
})
core.register_chatcommand('poop', {
    params = '<set/change/get/toggle> <name> <value>',
    description = S('Modify or get poop values'),
    privs = { manage_hunger = true },
    func = function (caller, parameters)
        local pt= {}
        for p in parameters:gmatch("%S+") do table.insert(pt, p) end
        local action = pt[1] or ''
        local name = pt[2] or ''
        local value = pt[3] or ''

        -- Name parameter missing
        if not player_exists(name) and tonumber(name) and value == '' then
            value = name
            name = caller
        end

        -- Convert value to number or print error message when trying to set
        -- a value but no proper value was given
        if tonumber(value) then
            value = tonumber(value)
        else
            if action ~= 'get' and action ~= 'toggle' then
                show_help(caller)
                return
            end
        end

        -- Execute the corresponding function for the defined action
        if     action == 'set' then set_poop(name, value, caller)
        elseif action == 'change' then change_poop(name, value, caller)
        elseif action == 'get' then get_poop(name, caller)
        elseif action == 'toggle' then toggle_poop(name, value, caller)
        else show_help(caller) end
    end
})
core.register_chatcommand('sleep', {
    params = '<set/change/get/toggle> <name> <value>',
    description = S('Modify or get sleep values'),
    privs = { manage_hunger = true },
    func = function (caller, parameters)
        local pt= {}
        for p in parameters:gmatch("%S+") do table.insert(pt, p) end
        local action = pt[1] or ''
        local name = pt[2] or ''
        local value = pt[3] or ''

        -- Name parameter missing
        if not player_exists(name) and tonumber(name) and value == '' then
            value = name
            name = caller
        end

        -- Convert value to number or print error message when trying to set
        -- a value but no proper value was given
        if tonumber(value) then
            value = tonumber(value)
        else
            if action ~= 'get' and action ~= 'toggle' then
                show_help(caller)
                return
            end
        end

        -- Execute the corresponding function for the defined action
        if     action == 'set' then set_sleep(name, value, caller)
        elseif action == 'change' then change_sleep(name, value, caller)
        elseif action == 'get' then get_sleep(name, caller)
        elseif action == 'toggle' then toggle_sleep(name, value, caller)
        else show_help(caller) end
    end
})
core.register_chatcommand('thirst', {
    params = '<set/change/get/toggle> <name> <value>',
    description = S('Modify or get thirst values'),
    privs = { manage_hunger = true },
    func = function (caller, parameters)
        local pt= {}
        for p in parameters:gmatch("%S+") do table.insert(pt, p) end
        local action = pt[1] or ''
        local name = pt[2] or ''
        local value = pt[3] or ''

        -- Name parameter missing
        if not player_exists(name) and tonumber(name) and value == '' then
            value = name
            name = caller
        end

        -- Convert value to number or print error message when trying to set
        -- a value but no proper value was given
        if tonumber(value) then
            value = tonumber(value)
        else
            if action ~= 'get' and action ~= 'toggle' then
                show_help(caller)
                return
            end
        end

        -- Execute the corresponding function for the defined action
        if     action == 'set' then set_thirst(name, value, caller)
        elseif action == 'change' then change_thirst(name, value, caller)
        elseif action == 'get' then get_thirst(name, caller)
        elseif action == 'toggle' then toggle_thirst(name, value, caller)
        else show_help(caller) end
    end
})


-- Personal information chat command
core.register_chatcommand('myhunger', {
    params = 'name',
    description = S('Show own hunger value'),
    privs = { interact = true },
    func = function (caller)
        local player_hunger = f.get_data(caller, a.hunger_value)
        local hunger_disabled = f.hunger_disabled(caller)
        if hunger_disabled then
            chat_send(caller, S('Your hunger is disabled'))
        else
            chat_send(caller, S('Your hunger value is @1', player_hunger))
        end
    end
})
core.register_chatcommand('mypoop', {
    params = 'name',
    description = S('Show own poop value'),
    privs = { interact = true },
    func = function (caller)
        local player_poop = f.get_data(caller, a.poop_value)
        local poop_disabled = f.poop_disabled(caller)
        if poop_disabled then
            chat_send(caller, S('Your poop is disabled'))
        else
            chat_send(caller, S('Your poop value is @1', player_poop))
        end
    end
})
core.register_chatcommand('mysleep', {
    params = 'name',
    description = S('Show own sleep value'),
    privs = { interact = true },
    func = function (caller)
        local player_sleep = f.get_data(caller, a.sleep_value)
        local sleep_disabled = f.sleep_disabled(caller)
        if sleep_disabled then
            chat_send(caller, S('Your sleep is disabled'))
        else
            chat_send(caller, S('Your sleep value is @1', player_sleep))
        end
    end
})
core.register_chatcommand('mythirst', {
    params = 'name',
    description = S('Show own thirst value'),
    privs = { interact = true },
    func = function (caller)
        local player_thirst = f.get_data(caller, a.thirst_value)
        local thirst_disabled = f.thirst_disabled(caller)
        if thirst_disabled then
            chat_send(caller, S('Your thirst is disabled'))
        else
            chat_send(caller, S('Your thirst value is @1', player_thirst))
        end
    end
})


core.register_chatcommand('defecate', {
	params = 'name',
	privs  = {interact=true,},
	func   = function(caller)
		assert (caller ~= nil)
		local current_poop = f.get_data(caller, a.poop_value)
		if current_poop <= 0 then
			minetest.chat_send_player(caller, "Your bowels are empty!")
			return
		end
		f.defecate(caller, nil, 'potty trained')
	end,
})
-- TODO allow sleep without bed? i.e., may cause injury in general, and also temperature damage
-- TODO urinate
