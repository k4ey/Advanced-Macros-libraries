local inv = openInventory()

local Inventory = {}
Inventory.mappings = {}
Inventory.mappings.inventory = {
    [63]={ starts=28,ends=63 }, -- single chest
    [90]={ starts=57,ends=90 }, -- double chest
    [46]={ starts=10,ends=45 }, -- nothing opened
    [53]={ starts=18,ends=53 } -- donkey
}
Inventory.mappings.container = {
    [63]={ starts=1,ends=27 }, -- single chest
    [90]={ starts=1,ends=56 }, -- double chest
    [46]={ starts=10,ends=45 }, -- nothing opened
    [53]={ starts=3,ends=17 } -- donkey
}

--translates mappings "inventory","container","all",{start,end},{slot1,slot2,slot3...}
function Inventory.mappings.getMappings(slots)
    local totalSlots = inv.getTotalSlots()
    -- inventory         - from the end of the chest to the last slot of the inventory
    -- container         - from the first slot of a container to the last slot of the container
    -- all               - from the first slot of a container to the last slot of the inventory
    -- <table>#2         - range from first to the second 
    -- <table>#1 or more - every given slot

    if slots == "inventory" then
        slots = {
            starts=Inventory.mappings.inventory[totalSlots].starts,
            ends=Inventory.mappings.inventory[totalSlots].ends}

    elseif slots == "container" then
        slots = {
            starts=Inventory.mappings.container[totalSlots].starts,
            ends=Inventory.mappings.container[totalSlots].ends}

    elseif slots == "all" then
        slots = {
            starts=Inventory.mappings.container[totalSlots].starts,
            ends=Inventory.mappings.inventory[totalSlots].ends}

    elseif type(slots) == "table" and #slots == 2 then
        slots = {
            starts=slots[1],
            ends=slots[2]}
    elseif type(slots) == "table" and ( #slots > 2 or #slots == 1 ) then
        return slots
    end
    local iterSlots = {}
    for i=slots.starts,slots.ends do
        iterSlots[#iterSlots+1] = i
    end
    return iterSlots
end

-- open chest at coords {x,y,z}
function Inventory.open(chest)
    chest = chest or getPlayer().lookingAt
    for i=1,3 do chest[i] = chest[i]+0.5 end
    repeat
        lookAt(table.unpack(chest))
        sleep(25)
        use()
        sleep(100)
    until inv.getTotalSlots() >= 63
    sleep(200)
end

-- returns number of items with the same name
function Inventory.calc(itemName,slots)
    slots = Inventory.mappings.getMappings(slots)
    local items = 0

    if not slots then return end
    for _,slot in ipairs(slots) do
        local item = inv.getSlot(slot)
        if item and item.name == itemName then
            items = items + item.amount
        end
    end
    return items
end

-- moves given amount items from <from> to <to> eg "inventory" -> "container"
function Inventory.move(itemName,amount,from,to)
    local totalSlots = inv.getTotalSlots()
    if totalSlots == 46 then return end
    if type(to) ~= "string" then error(( "%s expected string!" ):format(to)) end

    local slots = Inventory.mappings.getMappings(from)

    local item
    local took = 0
    for _,slot in ipairs(slots) do
        if took >= amount then sleep(250) return true end
        item = inv.getSlot(slot)
        if item and item.name == itemName then
            inv.quick(slot)
            took = took + item.amount
            sleep(100)
        end
    end
    return "NOT ENOUGH ITEMS IN CHEST"
end

-- does the same as Inventory.move but rather than calcing how many it moved, checks if there are enough items in the container already
function Inventory.refill(itemName,amount,from,to)
    local totalSlots = inv.getTotalSlots()
    if totalSlots == 46 then return end
    if type(to) ~= "string" then error(( "%s expected string!" ):format(to)) end

    local slots = Inventory.mappings.getMappings(from)

    local item
    for _,slot in ipairs(slots) do
        if Inventory.calc(itemName,to) >= amount then inv.close() sleep(250) return true end
        item = inv.getSlot(slot)
        if item and item.name == itemName then inv.quick(slot) sleep(10) end
    end
    inv.close()
    return "NOT ENOUGH ITEMS IN INV"
end

-- returns number of empty slots
function Inventory.calcEmptySlots(slots)
    slots = Inventory.mappings.getMappings(slots)
    local emptySlots = 0
    for _,slot in ipairs(slots) do
        local item = inv.getSlot(slot)
        if not item then
            emptySlots = emptySlots + 1
        end
    end
    return emptySlots
end

-- drops items with  given name from given range.
function Inventory.dropItems(items,slots)
    --{ ["minecraft:carpet"]=true, } 
    slots = Inventory.mappings.getMappings(slots)
    local item
    for _,slot in ipairs(slots) do
        item = inv.getSlot(slot)
        if item and items[item.id] then
            inv.drop(slot,true)
        end
    end
end

-- returns the slot of item with given name
function Inventory.find(itemName,slots)
    slots = Inventory.mappings.getMappings(slots)
    local item
    for _,slot in ipairs(slots) do
        item = inv.getSlot(slot)
        if item and item.name == itemName then
            return slot
        end
    end
    return false
end

-- places item with given name in your specified hotbar slot
function Inventory.placeInHotbar(item,pos)
    local itemPos = Inventory.find(item,"all")
    local totalSlots = inv.getTotalSlots()
    if totalSlots == 46 then totalSlots = totalSlots - 1 end -- smth strange 
    pos = totalSlots - 9 + pos
    if itemPos == pos then return end
    inv.click(itemPos) -- take the item
    sleep(250)
    inv.click(pos) -- swap it with desired slot
    sleep(250)
    inv.click(itemPos) -- put the swapped item in the pos of previous item.
end

-- helper function for Inventory.deepFind
function Inventory.deepFindCheckItem(item,itemInfo)
    local found
    if type(item) == "table" then
        for _,content in pairs(item) do
            if content then
                found = Inventory.deepFindCheckItem(content,itemInfo)
                if found then return found end
            end
        end
    elseif type(item) == "string" then
        if item:find(itemInfo) then
            return item
        end
    else return end
end

-- loops thru every attribute of an item looking for occurence of itemInfo
-- returns slot (number) and itemData (attribute in which the thing occured)
function Inventory.deepFind(itemInfo,slots)
    slots = Inventory.mappings.getMappings(slots)
    local item
    local itemData
    for _,slot in ipairs(slots) do
        item = inv.getSlot(slot)
        if item then
            itemData = Inventory.deepFindCheckItem(item,itemInfo)
            if itemData then return slot, itemData end
        end
    end
    return false
end

return Inventory
