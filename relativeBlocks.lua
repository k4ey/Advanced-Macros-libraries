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
    if direction == nil then error("direction not specified!") end

    position = position or {getPlayerBlockPos()}
    horizontalOffset = horizontalOffset or 1
    verticalOffset = verticalOffset or 0
    local offset = { Blocks.direction(direction,horizontalOffset) }
    local blockPos = Blocks.addIndices(offset,position)
    blockPos[2] = blockPos[2] + verticalOffset

    return getBlock(table.unpack(blockPos))
end

function Blocks.getBlockByRelative(relative,position)
    if relative == nil then error("direction not specified!") end

    position = position or {getPlayerBlockPos()}
    local blockPos = Blocks.addIndices(position,relative)

    return getBlock(table.unpack(blockPos))
end

return Blocks
