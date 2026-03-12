-- Exit if damage is not enabled and create dummy functions so mods using the
-- API do not crash the server.
if not core.is_yes(core.settings:get('enable_damage')) then
    local info = 'Hunger NG is disabled because damage is disabled.'

    local call = function (function_name)
        core.log('warning', ('+m tried to use +f but +i'):gsub('%+%a+', {
            ['+m'] = core.get_current_modname(),
            ['+f'] = 'hunger_ng.'..function_name..'()',
            ['+i'] = info
        }))
    end

    hunger_ng = {
        add_hunger_data = function () call('add_hunger_data') end,
        alter_hunger = function () call('alter_hunger') end,
        configure_hunger = function () call('configure_hunger') end,
        get_hunger_information = function () call('get_hunger_information') end,
        hunger_bar_image = '',

        --add_poop_data = function () call('add_poop_data') end,
        alter_poop = function () call('alter_poop') end,
        configure_poop = function () call('configure_poop') end,
        --get_poop_information = function () call('get_poop_information') end,
        poop_bar_image = '',
	-- TODO poop_maximum ?

        interoperability = {
            settings = {},
            attributes = {},
            translator = function () call('interoperability.translator') end,
            get_data = function () call('interoperability.get_data') end,
            set_data = function () call('interoperability.set_data') end,
        }
    }

    core.log('info', '[hunger_ng] '..info)
    return
end


-- Paths for later use
local modpath = core.get_modpath('hunger_ng')..DIR_DELIM
local worldpath = core.get_worldpath()..DIR_DELIM
local configpath = worldpath..'_hunger_ng'..DIR_DELIM..'hunger_ng_settings.conf'


-- World-specific configuration interface for use in the get function
local worldconfig = Settings(configpath)


-- Wrapper for getting configuration options
--
-- The function automatically prefixes the given setting with `hunger_ng_` and
-- returns the requested setting from one of the three sources.
--
-- 1. world-specific `./worlds/worldname/_hunger_ng/hunger_ng.conf` file
-- 2. server-specific configuration file
-- 3. the given default value
--
-- If 1. is found then it will be returned from there. If 2. is found then it
-- will be returned from there and after that it will be returned using 3.
--
-- @param setting The unprefixed setting name
-- @param default The default value if the setting is not found
-- @return string The value for the requested setting
local get = function (setting, default)
    local parameter = 'hunger_ng_'..setting
    local global_setting =  core.settings:get(parameter)
    local world_specific_setting = worldconfig:get(parameter)
    return world_specific_setting or global_setting or default
end

local function get_default_thirst_bar_image()
    local image_claycrafter = 'claycrafter_glass_of_water_inv.png'
    local image_farming     = 'farming_water_glass.png'

    local has_claycrafter   = (minetest.get_modpath('claycrafter') ~= nil)
    local has_farming       = (minetest.get_modpath('farming')     ~= nil) -- false positive: default farming
    if not has_claycrafter and not has_farming then return ''                end

    local glass_claycrafter = minetest.registered_items['claycrafter:glass_of_water']
    local glass_farming     = minetest.registered_items['farming:glass_water']
    local glass_pb          = minetest.registered_items['placeable_buckets:jcu_water']
    if ia_util.has_placeable_buckets_redo() then return image_claycrafter end
    if ia_util.has_farming_redo()           then return image_farming     end
    if ia_util.has_claycrafter_redo()       then return image_claycrafter end
    return '' -- TODO
--    has_claycrafter         = has_claycrafter and glass_claycrafter ~= nil -- sanity check
--    has_farming             = (has_farming and       glass_farming ~= nil) -- either we have farming_redo or it's been monkey-patched by claycrafter
--
--    local is_same           = (glass_claycrafter == glass_farming)         -- detect monkey-patch
--    --has_claycrafter       = (has_claycrafter and not is_same)            -- detect vanilla claycrafter
--    has_farming             = (has_farming     and not is_same)
--
--    if has_farming                             then return image_farming     end
--    --assert(has_claycrafter)
--    return image_claycrafter
end

-- Global hunger_ng table that will be used to pass around variables and use
-- them later in the game. The table is not to be used by mods. Mods should
-- only use the interoperability functionality. This table is for internal
-- use only.
hunger_ng = {
    functions = {},
    food_items = { -- counters
        satiating = 0,
        starving = 0,
        healing = 0,
        injuring = 0,

	digesting   = 0, -- makes you poop
	resting     = 0, -- makes you less sleepy
	exhausting  = 0, -- makes you more sleepy
	quenching   = 0, -- makes you less thirsty
	dehydrating = 0, -- makes you more thirsty
	hydrating   = 0, -- makes you pee
--	warming     = 0,
--	cooling     = 0,
    },
    attributes = {
        hunger_bar_id = 'hunger_ng:hunger_bar_id',
        hunger_value = 'hunger_ng:hunger_value',
        eating_timestamp = 'hunger_ng:eating_timestamp',
        hunger_disabled = 'hunger_ng:hunger_disabled',
        effect_heal = 'hunger_ng:effect_heal',
        effect_hunger = 'hunger_ng:effect_hunger',
        effect_starve = 'hunger_ng:effect_starve',
	
	poop_bar_id         = 'hunger_ng:poop_bar_id',
	poop_value          = 'hunger_ng:poop_value',
	pooping_timestamp   = 'hunger_ng:pooping_timestamp',
	poop_disabled       = 'hunger_ng:poop_disabled',
	effect_digest       = 'hunger_ng:effect_digest',

	sleep_bar_id        = 'hunger_ng:sleep_bar_id',
	sleep_value         = 'hunger_ng:sleep_value',
	sleeping_timestamp  = 'hunger_ng:sleeping_timestamp',
	sleep_disabled      = 'hunger_ng:sleep_disabled',
	effect_sleep        = 'hunger_ng:effect_sleep',

	thirst_bar_id       = 'hunger_ng:thirst_bar_id',
	thirst_value        = 'hunger_ng:thirst_value',
	drinking_timestamp  = 'hunger_ng:drinking_timestamp',
	thirst_disabled     = 'hunger_ng:thirst_disabled',
	effect_dehydrate    = 'hunger_ng:effect_dehydrate',

	pee_bar_id         = 'hunger_ng:pee_bar_id',
	pee_value          = 'hunger_ng:pee_value',
	peeing_timestamp   = 'hunger_ng:peeing_timestamp',
	pee_disabled       = 'hunger_ng:pee_disabled',
	effect_hydrate     = 'hunger_ng:effect_hydrate',

--	heat_bar_id         = 'hunger_ng:heat_bar_id',
--	heat_value          = 'hunger_ng:heat_value',
--	heating_timestamp   = 'hunger_ng:heating_timestamp',
--	heat_disabled       = 'hunger_ng:heat_disabled',
--	effect_heat         = 'hunger_ng:effect_heat',
    },
    configuration = {
        debug_mode = core.is_yes(get('debug_mode', false)),
        log_prefix = '[hunger_ng] ',
        translator = core.get_translator('hunger_ng')
    },
    settings = {
        hunger_bar = {
            image = get('hunger_bar_image', 'hunger_ng_builtin_bread_icon.png'),
            use = core.is_yes(get('use_hunger_bar', true)),
            force_builtin_image = get('force_builtin_image', false),
        },
        timers = {
            heal = tonumber(get('timer_heal', 5)),
            starve = tonumber(get('timer_starve', 10)),
            basal_metabolism = tonumber(get('timer_basal_metabolism', 60)),
            movement = tonumber(get('timer_movement', 0.5)),

	    digest  = tonumber(get('timer_digest',   3)),
	    --sleep  = tonumber(get('timer_sleep',  60*60*4)),
	    sleep   = tonumber(get('timer_sleep',   60)),
	    thirst  = tonumber(get('timer_thirst',  60)),
	    hydrate = tonumber(get('timer_digest',   3)), -- TODO faster (realistic)
--	    heat   = tonumber(get('timer_heat',     0.5)),
        },
        hunger = {
            timeout = tonumber(get('hunger_timeout', 0)),
            persistent = core.is_yes(get('hunger_persistent', true)),
            start_with = tonumber(get('hunger_start_with', 20)),
            maximum = tonumber(get('hunger_maximum', 20))
        },

        poop_bar   = {
            image               =             get('poop_bar_image',      'poop_turd.png'),
            use                 = core.is_yes(get('use_poop_bar',        true)),
            force_builtin_image =             get('force_builtin_image', false),
        },
        poop       = {
            timeout             = tonumber(   get('poop_timeout',     0)),
            persistent          = core.is_yes(get('poop_persistent', true)),
            start_with          = tonumber(   get('poop_start_with',  1)),
            maximum             = tonumber(   get('poop_maximum',    20)),
        },
	sleep_bar  = {
            image               =             get('sleep_bar_image',     'beds_bed.png'),
            use                 = core.is_yes(get('use_sleep_bar',       true)),
            force_builtin_image =             get('force_builtin_image', false),
	},
	sleep      = {
            timeout             = tonumber(   get('sleep_timeout',     0)),
            persistent          = core.is_yes(get('sleep_persistent', true)),
            start_with          = tonumber(   get('sleep_start_with', 20)),
            maximum             = tonumber(   get('sleep_maximum',    20)),
	},
	thirst_bar = {
	    --image               =             get('thirst_bar_image',     'claycrafter_glass_of_water_inv.png'),
	    image               =             get('thirst_bar_image',    get_default_thirst_bar_image()),
	    use                 = core.is_yes(get('use_thirst_bar',      true)),
	    force_builtin_image =             get('force_builtin_image', false),
	},
	thirst     = {
	    timeout             = tonumber(   get('thirst_timeout',     0)),
	    persistent          = core.is_yes(get('thirst_persistent', true)),
	    start_with          = tonumber(   get('thirst_start_with', 20)),
	    maximum             = tonumber(   get('thirst_maximum',    20)),
	},
        pee_bar   = {
            image               =             get('pee_bar_image',      'default_gold_lump.png'), -- TODO
            use                 = core.is_yes(get('use_pee_bar',        true)),
            force_builtin_image =             get('force_builtin_image', false),
        },
        pee       = {
            timeout             = tonumber(   get('pee_timeout',     0)),
            persistent          = core.is_yes(get('pee_persistent', true)),
            start_with          = tonumber(   get('pee_start_with',  1)),
            maximum             = tonumber(   get('pee_maximum',    20)),
        },
--	heat_bar   = {
--	    image               =             get('heat_bar_image',      ...), -- TODO
--	    use                 = core.is_yes(get('use_heat_bar',        true)),
--	    force_builtin_image =             get('force_builtin_image', false),
--	},
--	heat       = {
--	    timeout             = tonumber(   get('heat_timeout',     0)),
--	    persistent          = core.is_yes(get('heat_persistent', true)),
--	    start_with          = tonumber(   get('heat_start_with', ...)),
--	    maximum             = tonumber(   get('heat_maximum',    ...)),
--        },
    },
    effects = {
        heal = {
            above = tonumber(get('heal_above', 16)),
            amount = tonumber(get('heal_amount', 1)),
        },
        starve = {
            below = tonumber(get('starve_below', 1)),
            amount = tonumber(get('starve_amount', 1)),
            die = core.is_yes(get('starve_die', false))
        },
        disabled_attribute = 'hunger_ng:hunger_disabled',

	digest     = {
            above  = tonumber(   get('poop_above', 19)),
            amount = tonumber(   get('poop_amount', 1)),
            below  = tonumber(   get('poop_below',  5)), -- minimum amount to make a turd
	},
	sleep      = {
            below  = tonumber(   get('exhaust_below',  1)),
            amount = tonumber(   get('exhaust_amount', 1)),
            die    = core.is_yes(get('exhaust_die',    false))
	},
	dehydrate  = {
            below  = tonumber(   get('dehydrate_below',  1)),
            amount = tonumber(   get('dehydrate_amount', 1)),
            die    = core.is_yes(get('dehydrate_die',    false))
	},
	hydrate    = {
            above  = tonumber(   get('pee_above', 19)),
            amount = tonumber(   get('pee_amount', 1)),
            below  = tonumber(   get('pee_below',  1)), -- minimum amount to make a droplet
	},
--        heat       = {
--            below  = tonumber(   get('heat_below',   0)),
--            above  = tonumber(   get('heat_above',  45)),
--            amount = tonumber(   get('heat_amount',  1)),
--            die    = core.is_yes(get('heat_die',    false))
--        },
    },
    costs = {
        base = tonumber(get('cost_base', 0.1)),
        dig = tonumber(get('cost_dig', 0.005)),
        place = tonumber(get('cost_place', 0.01)),
        movement = tonumber(get('cost_movement', 0.008))
    }
}


-- Load mod parts
dofile(modpath..'system'..DIR_DELIM..'hunger_functions.lua')
dofile(modpath..'system'..DIR_DELIM..'chat_commands.lua')
dofile(modpath..'system'..DIR_DELIM..'timers.lua')
dofile(modpath..'system'..DIR_DELIM..'register_on.lua')
dofile(modpath..'system'..DIR_DELIM..'add_hunger_data.lua')
dofile(modpath..'system'..DIR_DELIM..'interoperability.lua')


-- Log debug mode warning
if hunger_ng.configuration.debug_mode then
    local log_prefix = hunger_ng.configuration.log_prefix
    core.log('warning', log_prefix..'Mod loaded with debug mode enabled!')
end


-- Replace the global table used for easy variable access within the mod with
-- an API-like global table for other mods to utilize.
local api_functions = {
    add_hunger_data = hunger_ng.functions.add_hunger_data,
    --add_poop_data = hunger_ng.functions.add_poop_data,
    alter_hunger = hunger_ng.functions.alter_hunger,
    alter_poop       = hunger_ng.functions.alter_poop,
    alter_sleep      = hunger_ng.functions.alter_sleep,
    alter_thirst     = hunger_ng.functions.alter_thirst,
    alter_pee        = hunger_ng.functions.alter_pee,
    configure_hunger = hunger_ng.functions.configure_hunger,
    configure_poop   = hunger_ng.functions.configure_poop,
    configure_sleep  = hunger_ng.functions.configure_sleep,
    configure_thirst = hunger_ng.functions.configure_thirst,
    configure_pee    = hunger_ng.functions.configure_pee,
    set_effect = hunger_ng.set_effect,
    get_hunger_information = hunger_ng.functions.get_hunger_information,
    --get_poop_information = hunger_ng.functions.get_poop_information,
    hunger_bar_image = hunger_ng.settings.hunger_bar.image,
    poop_bar_image   = hunger_ng.settings.poop_bar.image,
    sleep_bar_image  = hunger_ng.settings.sleep_bar.image,
    thirst_bar_image = hunger_ng.settings.thirst_bar.image,
    pee_bar_image    = hunger_ng.settings.pee_bar.image,
    poop_maximum     = hunger_ng.settings.poop.maximum,
    pee_maximum      = hunger_ng.settings.pee.maximum,
    on_joinplayer    = hunger_ng.functions.on_joinplayer,
    on_dieplayer     = hunger_ng.functions.on_dieplayer,
    on_leaveplayer   = hunger_ng.functions.on_leaveplayer,
    food_items = hunger_ng.food_items,
    interoperability = {
        settings = hunger_ng.settings,
        attributes = hunger_ng.attributes,
        translator = hunger_ng.configuration.translator,
        get_data = hunger_ng.functions.get_data,
        set_data = hunger_ng.functions.set_data
    },
    mod              = 'ia',
}


-- Replace the internal global table with the api functions
hunger_ng = api_functions
