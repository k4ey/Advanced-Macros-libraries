local function relog(ip,timeout,delay)
    timeout = timeout or -1 -- number of times to check if connection succeeded. If not, try connecting again if you want to turn this off, set this to -1
    delay = delay or 1000 -- delay between checks
    disconnect()
    sleep(5000)

    connect(ip)
    local playerPos
    local distanceFromSpawn
    local toTimeout = timeout
    while true do
        log('waiting for the world to load')
        if getWorld() then
            log("world loaded")
            playerPos = { getPlayerBlockPos() }
            distanceFromSpawn = math.sqrt(playerPos[1]^2+playerPos[3]^2)
            if distanceFromSpawn > 10000 then
                log("not in queue")
                return true
            end
        end
        sleep(1000)
        if timeout > -1 then
            toTimeout = toTimeout - 1
            log("time left to time out: ",toTimeout*delay/1000)
            if toTimeout == 0 then log("timing out") return relog(ip,delay,timeout) end
        end
    end
end
relog("8b8t.me",10,1000)
