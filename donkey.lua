local DonkeyLib = {}


DonkeyLib.donkeyClass = "net.minecraft.entity.passive.EntityDonkey"


-- returns a donkey entity with given uuid
function DonkeyLib.getByUUID(uuid)
    for _,entity in pairs(getEntityList()) do
        if entity and entity.class == DonkeyLib.donkeyClass then
            local donkey = getEntity(entity.id)
            if donkey.uuid == uuid then
                return donkey
            end
        end
    end
end

-- returns the closest donkey entity that is not ridden by current player
function DonkeyLib.getClosest()
    local donkeys = {}
    local donkey
    for _,entity in pairs(getEntityList()) do
        if entity and entity.class == DonkeyLib.donkeyClass then
            donkey = getEntity(entity.id)
            if donkey then
                if not playerDetails.getRidingEntity() or playerDetails.getRidingEntity().uuid ~= donkey.uuid then
                    donkeys[#donkeys+1] = { entity=donkey, distance=DonkeyLib.distanceTo(donkey.uuid) }
                end
            end
        end
    end
    local closest
    for _,donkey in pairs(donkeys) do
        if not closest or closest.distance > donkey.distance then closest = donkey end
    end
    return closest.entity
end

-- return a donkey entity with given name (not the closest one)
function DonkeyLib.getByName(name)
    name = name or "Donkey"
    for _,entity in pairs(getEntityList()) do
        if entity and entity.class == DonkeyLib.donkeyClass and entity.name == name then
            return getEntity(entity.id)
        end
    end
end

-- sit on a donkey with given uuid. if donkey is too far it walks to it
function DonkeyLib.sit(uuid)
    local donkey = DonkeyLib.getByUUID(uuid)
    if not donkey then return end
    local target
    while not (playerDetails.getRidingEntity() and playerDetails.getRidingEntity().uuid == donkey.uuid) do
        DonkeyLib.lookAt(uuid)
        sleep(50)

        target = playerDetails.getTarget()
        if target and target.entity and target.entity.uuid ~= uuid or DonkeyLib.distanceTo(uuid) > 2.5 then DonkeyLib.walkTo(uuid) end

        use()
    end
end

-- get distance from player to a donkey with given uuid
function DonkeyLib.distanceTo(uuid)
    local donkey = DonkeyLib.getByUUID(uuid)
    if not donkey then return end
    local currentPos = {getPlayerBlockPos()}
    return math.sqrt((currentPos[1] - donkey.pos[1])^2 + (currentPos[3] - donkey.pos[3])^2)
end

-- walk to a donkey with given uuid
function DonkeyLib.walkTo(uuid)
    local donkey = DonkeyLib.getByUUID(uuid)
    if not donkey then return end
    local distanceToDonkey
    while true do
        DonkeyLib.lookAt(uuid)
        distanceToDonkey = DonkeyLib.distanceTo(uuid)
        if distanceToDonkey  < 2.5   then return end

        forward(100)
        sleep(100)
    end
end

-- open donkey's inventory
function DonkeyLib.open()
    getMinecraft().field_71439_g:func_175163_u()
end

-- look at the middle of a donkey with given UUID
function DonkeyLib.lookAt(uuid)
    local donkey = DonkeyLib.getByUUID(uuid)
    lookAt(donkey.pos[1]+0.1,donkey.pos[2]+0.6,donkey.pos[3]+0.1)
end

function DonkeyLib.dismount()
    while playerDetails.isPassenger() do
        sneak(250)
        sleep(250)
    end
end

return DonkeyLib
