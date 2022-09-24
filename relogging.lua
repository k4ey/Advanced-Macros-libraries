local function relog(ip,timeoutDuration)
    local timeout = timeoutDuration or -1 -- if timeout duration not specified then it will never timeout otherwise it will attempt to connect to the server again after timeout reaches 0
    while true do
        disconnect()
        waitTick()
        waitTick()
        connect(ip)
        repeat
            timeout = timeout - 1
            sleep(1000)
            if getWorld() then
                if playerDetails.getGamemode() ~= "spectator" then
                    return true
                end
            end
        until timeout == 0
        timeout = timeoutDuration
    end
end
return relog
