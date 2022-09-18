local Inventory = {}
local inv = openInventory()



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

-- count items with the same name in inventory AND curently opened container
function Inventory.calc(material)
    local totalSlots = inv.getTotalSlots()
    local chestStart = Inventory.inventoryPositions(totalSlots)["starts"]
    local items = 0
    for i=chestStart,totalSlots do
        local item = inv.getSlot(i)
        if item and item.name == material then
            items = items + item.amount
        end
    end
    return items
end

-- count items with the same name in inventory
function Inventory.calcInventory(material)
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory.inventoryPositions(totalSlots)["ends"]
    local items = 0
    for i=inventoryAt+1,totalSlots do
        local item = inv.getSlot(i)
        if item and item.name == material then
            items = items + item.amount
        end
    end
    return items
end

-- count items with the same name in curently opened container
function Inventory.calcContainer(material)
    local totalSlots = inv.getTotalSlots()
    local chestStart = Inventory.inventoryPositions(totalSlots)["starts"]
    local chestEnd = Inventory.inventoryPositions(totalSlots)["ends"]
    local items = 0
    for i=chestStart, chestEnd do
        local item = inv.getSlot(i)
        if item and item.name == material then
            items = items + item.amount
        end
    end
    return items
end

-- returns "mappings" for each vanilla inventory size
function Inventory.inventoryPositions(numOfSlots)
    local possible_inventories = {
        [63]={ ends=27, starts=1 }, -- single chest
        [90]={ ends=56, starts=1}, -- double chest
        [46]={ ends=9, starts=9}, -- nothing opened
        [53]={ ends=17, starts=3} -- donkey
    }
    return possible_inventories[numOfSlots]
end


-- take items from already opened container. Takes full stacks.
function Inventory.take(itemName,amount)
    local totalSlots = inv.getTotalSlots()
    if totalSlots == 46 then return end
    local chestEnds = Inventory.inventoryPositions(totalSlots)["ends"]

    local item
    for i=1,chestEnds do
        if Inventory.calcInventory(itemName) >= amount then inv.close() sleep(250) return true end
        item = inv.getSlot(i)
        if item and item.name == itemName then inv.quick(i) sleep(10) end
    end
    inv.close()
    return "NOT ENOUGH ITEMS IN CHEST"
end

-- put items from inventory to already opened container. Takes full stacks
function Inventory.put(itemName,amount)
    local totalSlots = inv.getTotalSlots()
    if totalSlots == 46 then return end
    local invStarts = Inventory.inventoryPositions(totalSlots)["starts"]

    local item
    for i=invStarts,totalSlots do
        if Inventory.calcContainer(itemName) >= amount then inv.close() sleep(250) return true end
        item = inv.getSlot(i)
        if item and item.name == itemName then inv.quick(i) sleep(10) end
    end
    inv.close()
    return "NOT ENOUGH ITEMS IN INV"
end

-- count empty slots 
function Inventory.calcEmptySlots()
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory.inventoryPositions(totalSlots)["ends"]
    local emptySlots = 0
    for i=inventoryAt+1,totalSlots-1 do
        local item = inv.getSlot(i)
        if not item then
            emptySlots = emptySlots + 1
        end
    end
    return emptySlots
end

-- shift clicks specified item in inv. This allows to "stack" unstacked items. Breaks sometimes.
function Inventory.stackUnstacked(stackableItems)
    --[[ local stackableItems= {
        ["minecraft:carpet"]=true
    } ]]
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory.inventoryPositions(totalSlots)["ends"]
    local item
    for i=totalSlots-1,inventoryAt+1,-1 do
        item = inv.getSlot(i)
        if item and stackableItems[item.id] then
            inv.quick(i)
            sleep(150)
        end
    end
end

-- drop all items from inventory except specified ones
function Inventory.dropUnused(usedItems)
    --[[ local usedItems = {
        ["minecraft:carpet"]=true,
    } ]]
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory.inventoryPositions(totalSlots)["ends"]
    local item
    for i=inventoryAt+1,totalSlots-1 do
        item = inv.getSlot(i)
        if item and not usedItems[item.id] then
            inv.drop(i)
        end
    end
end

-- drops all items with given name 
function Inventory.dropAllItems(items)
    --{ ["minecraft:carpet"]=true, } 
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory.inventoryPositions(totalSlots)["ends"]
    local item
    for i=inventoryAt+1,totalSlots-1 do
        item = inv.getSlot(i)
        if item and items[item.id] then
            inv.drop(i,true)
        end
    end
end

-- find item with specified name in the inventory and returns its slot
function Inventory.find(material)
    local totalSlots = inv.getTotalSlots()
    local inventoryAt = Inventory.inventoryPositions(totalSlots)["ends"]
    for i=inventoryAt+1,totalSlots do
        local item = inv.getSlot(i)
        if item and item.name == material then
            return i
        end
    end
    return false
end

-- find item in inventory and place it in hotbar
function Inventory.placeInHotbar(pos,item)
    local itemPos = Inventory.find(item)
    pos = pos + 36
    if itemPos == pos then return end
    inv.click(itemPos) -- take the item
    sleep(250)
    inv.click(pos) -- swap it with desired slot
    sleep(250)
    inv.click(itemPos) -- put the swapped item in the pos of previous item.
end

return Inventory
