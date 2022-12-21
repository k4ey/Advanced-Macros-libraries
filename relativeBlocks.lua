local Blocks = {}
local minecraft = getMinecraft()

-- returns a table of relative coords based on your direction and selected side.
-- for example dir = "left" will return {-1,0,0} when looking north
-- dir = "left" when looking east will return {0,0,-1} and so on
-- dir accepts: "right", "left", "forward", "back", "up", "down"
-- offset changes number of blocks returned
function Blocks.direction(dir,offset)
    offset = offset or 1

    local player =  minecraft:func_175606_aa()  --getRenderViewEntity
    local direction = player:func_174811_aO()   --getHorizontalFacing 
    local sides = {
        left = direction:func_176735_f(),  --rotateYCCW
        right = direction:func_176746_e(), --rotateY
        back = direction:func_176734_d(),  --getOpposite
        up = direction:func_82600_a(1),    --byIndex
        down = direction:func_82600_a(0),  --byIndex
        forward = direction,

    }
    local directionVector = sides[dir].field_176756_m -- directionVec
    local x,y,z = directionVector.field_177962_a , directionVector.field_177960_b, directionVector.field_177961_c
    return x*offset, y*offset, z*offset
end

-- adds item at index 1 in table 1 to index 1 in table 2 and so on
-- accepts two tables
function Blocks.addIndices(t1,t2)
    for i=1,#t1 do
        t1[i] = t1[i]+t2[i]
    end
    return t1
end

--[[ 
returns block at position specified by <position> adjusted by direction faced.
<horizontalOffset> is the horizontal offset from position
<verticalOffset> is the vertical offset from position
<direction> specifies direction to take block from "right", "left", "forward", "back", "up", "down"
]]--
function Blocks.getBlockByDirection(direction,position,horizontalOffset,verticalOffset)
    assert(direction, "direction not specified!")

    position = position or {getPlayerBlockPos()}
    horizontalOffset = horizontalOffset or 1
    verticalOffset = verticalOffset or 0
    local offset = { Blocks.direction(direction,horizontalOffset) }
    local blockPos = Blocks.addIndices(offset,position)
    blockPos[2] = blockPos[2] + verticalOffset

    return getBlock(table.unpack(blockPos))
end

function Blocks.getBlockByRelative(relative,position)
    assert(relative, "relative position not specified!")

    position = position or {getPlayerBlockPos()}
    local blockPos = Blocks.addIndices(position,relative)

    return getBlock(table.unpack(blockPos))
end

--[[ 
clears HUD3D and creates prop blocks at given position.
<blocks> can be: 
    - a table of rayTrace block instances
    - a single rayTrace block instance
    - a table of multiple tables with coords 
    - a single table with coords
<delay> takes time between showing each prop in miliseconds
 ]]
function Blocks.show(blocks,enableXray,delay)
    assert(type(blocks) == "table", "invalid type!")
    assert(type(delay) == "number" or type(delay) == "nil", "invalid delay!" )
    assert(type(enableXray) == "boolean" or type(delay) == "nil", "enableXray only takes boolean!" )

    local props = {}

    -- prepare coords to look like this:
    -- { {x,y,z},{x,y,z},{x,y,z} }

    -- { blocks[1].pos = {x,y,z}, blocks[2].pos = {x,y,z}}
    if type( blocks[1] ) == "table" and blocks[1].pos then
        for _,block in pairs(blocks) do
            props[#props+1] = block.pos
        end

    -- {x,y,z}
    elseif #blocks == 3 and type(blocks[1]) == "number" then
        props = { blocks }

    -- { {x,y,z},{x,y,z},{x,y,z} }
    elseif #blocks > 1 then
        props = blocks
    end

    -- clear props
    hud3D.clearAll()
    -- create props
    for i=1, #props do
        props[i] = hud3D.newBlock(table.unpack(props[i]))
        props[i].enableDraw()
        if enableXray then props[i].xray() end
        if delay then sleep(delay) end
    end
end

-- digs block on given position. 
-- <blockPos> takes a table of coords of the block
-- <pickaxeSlot> optional, if not specified uses the current tool, takes a number between 1,9 which indicates slot in hotbar
-- <delay> optional, takes a delay between checking if the mining is complete. In miliseconds
function Blocks.mine(blockPos,pickaxeSlot,delay)
    delay = delay or 600
    assert(type(blockPos) == "table" and type(blockPos[1]) == "number", "invalid position!")
    assert(type(pickaxeSlot) == "number" or pickaxeSlot == nil, "invalid slot")
    assert(type(delay) == "number", "invalid delay")
    -- restoring game focus -- this is workaround due bug
    minecraft.field_71415_G = true -- mc.inGameHasFocus = true
    while getBlock(table.unpack(blockPos)).name ~= "Air" do

        if pickaxeSlot then setHotbar(pickaxeSlot) end
        sleep(10)

        lookAt(blockPos[1],blockPos[2],blockPos[3])
        sleep(10)
        attack(delay+20)
        sleep(delay)
    end
    sleep(20)
end
Blocks.mine({getPlayerBlockPos()},8,50)

return Blocks
