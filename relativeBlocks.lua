local Blocks = {}

-- returns a table of relative coords based on your direction and selected side.
-- for example dir = "left" will return {-1,0,0} when looking north
-- dir = "left" when looking east will return {0,0,-1} and so on
-- dir accepts: "right", "left", "forward", "back", "up", "down"
-- numberOfBlocks is the number returned in the table. Defaults to 1 
function Blocks.direction(dir,numberOfBlocks)
    -- the implementation is very stupid but i curently have no other idea for it.
    -- if it works - it works :)
    if dir ~= "string" then error("bad data") end
    numberOfBlocks = numberOfBlocks or 1
    local playerYaw = playerDetails.getYaw()
    local yaw_opt = math.floor(playerYaw / 90 + 3.5)
    local dir_mat = {[0]={-1,0,0}, [1]={0,0,-1}, [2]={1,0,0}, [3]={0,0,1}, [4]={-1,0,0}, [5]={0,0,-1} }
    for i=0,#dir_mat do
        dir_mat[i][1] = dir_mat[i][1]*numberOfBlocks
        dir_mat[i][2] = dir_mat[i][2]*numberOfBlocks
        dir_mat[i][3] = dir_mat[i][3]*numberOfBlocks
    end
    local offset
    if dir == "right" then
        offset = dir_mat[yaw_opt%4+1]
    elseif dir == "left" then
        offset = dir_mat[math.abs((yaw_opt-1)%4)]
    elseif dir == "forward" then
        offset = dir_mat[yaw_opt]
    elseif dir == "back" then
        offset = dir_mat[(yaw_opt+2)%4]
    elseif dir == "up" then
        offset = { 0,numberOfBlocks,0 }
    elseif dir == "down" then
        offset = { 0,numberOfBlocks*-1,0 }
    end
    return offset
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
returns block, just like _G.getBlock
allows for relative position or yaw dependent position
position {x,y,z}
relative position settings: {d,d,d} adds to d to the players position
yaw dependent position settings: {direction,offset,verticalOffset} adds <offset> to position in direction <direction> ("left","right","back","forward"), verticalOffset changes Y value
]]--
function Blocks.getBlock(position,settings)
    if type(position) ~= "table" or #position ~=3 then error("wrong position format!") end
    if type(settings) ~= "table" then error("wrong settings format!") end
    if ( #settings == 2 or #settings == 3 ) and type(settings[1]) == "string" and type(settings[2]) == "number" and (type(settings[3]) == "number" or type(settings[3]) == "nil") then
        local offset = Blocks.direction(settings[1],settings[2])
        local blockPos = Blocks.addIndices(offset,position)
        blockPos[2] = blockPos[2] + settings[3]
        return getBlock(table.unpack(blockPos))

    elseif #settings == 3 and type(settings[1]) == "number" and type(settings[2]) == "number" and type(settings[3]) == "number" then
        local blockPos = Blocks.addIndices(position,settings)
        return getBlock(table.unpack(blockPos))
    else
        error("bad settings")
    end
end
return Blocks
