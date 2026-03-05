-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator


-- Localize Luanti
local registered_items = core.registered_items
local override_item = core.override_item


-- Add custom _hunger_ng attribute to items
--
-- Checks if the item already has the attribute. If not, then the provided
-- values are set.
--
-- The data table has to be the following.
--
--     {
--         heals    = n,
--         satiates = n,
--         digests  = n|nil,
--         rests    = n,
--         quenches = n,
--         returns  = 'id'
--     }
--
-- Where n is a number (can be negative to damage the player or make the
-- player hungry) or a fraction of a number. If `returns` is set to an ID of
-- a registered item this item will be returned when the food is eaten.
--
-- @param id   The ID of the item to be modified.
-- @param data The data table as described
hunger_ng.functions.add_hunger_data = function (id, data)
    if registered_items[id] == nil then return end
    if registered_items[id]._hunger_ng ~= nil then return end
    if registered_items[id].on_use == nil then return end

    local item_data = registered_items[id]
    local info = ''
    local satiates = data.satiates or 0
    local heals = data.heals or 0
    local returns = data.returns or false
    local timeout = data.timeout or s.hunger.timeout

    local digests  = data.digests
    if digests == nil then
        digests    = math.abs(satiates)
    end
    local rests    = data.rests    or 0
    local quenches = data.quenches or 0

    if satiates > 0 then
        info = info..'\n'..S('Satiates: @1', satiates)
        hunger_ng.food_items.satiating = hunger_ng.food_items.satiating + 1
    elseif satiates < 0 then
        info = info..'\n'..S('Deprives: @1', math.abs(satiates))
        hunger_ng.food_items.starving = hunger_ng.food_items.starving + 1
    end

    assert(digests >= 0)
    if     digests > 0  then
        info                             = info..'\n'..S('Digests: @1',   digests)
        hunger_ng.food_items.digesting   = hunger_ng.food_items.digesting   + 1
    end

    if     rests > 0    then
        info                             = info..'\n'..S('Restores: @1',   rests)
        hunger_ng.food_items.resting     = hunger_ng.food_items.resting     + 1
    elseif rests < 0    then
        info                             = info..'\n'..S('Exhausts: @1',   math.abs(rests))
        hunger_ng.food_items.exhausting  = hunger_ng.food_items.exhausting  + 1
    end

    if     quenches > 0 then
        info                             = info..'\n'..S('Quenches: @1',   quenches)
        hunger_ng.food_items.quenching   = hunger_ng.food_items.quenching   + 1
    elseif quenches < 0 then
        info                             = info..'\n'..S('Dehydrates: @1', math.abs(quenches))
        hunger_ng.food_items.dehydrating = hunger_ng.food_items.dehydrating + 1
    end

    if heals > 0 then
        info = info..'\n'..S('Heals: @1', data.heals)
        hunger_ng.food_items.healing = hunger_ng.food_items.healing + 1
    elseif heals < 0 then
        info = info..'\n'..S('Injures: @1', math.abs(heals))
        hunger_ng.food_items.injuring = hunger_ng.food_items.injuring + 1
    end

    if returns and registered_items[returns] then
        local return_name = registered_items[returns].description
        info = info..'\n'..S('Returns: @1', return_name)
    end

    if data.returns and not registered_items[returns] then
        data.returns = nil
    end

    if timeout > 0 then
        info = info..'\n'..S('Eating timeout: @1 seconds', timeout)
    end

    override_item(id, {
        description = item_data.description..info,
        _hunger_ng = data
    })
end
