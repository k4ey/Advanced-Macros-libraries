local config = {
    logLevel = 0, -- change this to allow more logs to show
    logLevels = {
        emerg=0,
        alert=1,
        crit=2,
        err=3,
        warning=4,
        notice=5,
        info=6,
        debug=7,
    },
    logColors= {
        emerg="&4",
        alert="&6",
        crit="&c",
        err="&4",
        warning="&a",
        notice="&0",
        info="&b",
        debug="&8",
    },
    sound = false, -- allow sound 
    save = true, -- allow logging to a file
}
local function sound(name)
    local sound = playSound(name)
    sound.setVolume(1)
    sound.play()
end

local function dump(text,level)
    local file = io.open(("AM_log_%s.txt"):format(os.date("%m_%d_%y")),'a+')
    if file then
        file:write(("[%s] [%s] : %s \n"):format(os.date("%X"),level,text))
        file:close()
    end
end

local function prepare(level,text)
    if config.logLevels[level] > config.logLevel then return end
    if config.sound then sound("pop.wav") end
    if config.save then dump(text,level) end

    log(("&8[%s] %s[%s] : &7%s"):format(os.date("%X"),config.logColors[level],level:upper(),text))
end
local logger = {
        emerg = function(text) prepare("emerg",text) end,
        alert = function(text) prepare("alert",text) end,
        crit = function(text) prepare("crit",text) end,
        err = function(text) prepare("err",text) end,
        warning= function(text) prepare("warning",text) end,
        notice= function(text) prepare("notice",text) end,
        info = function(text) prepare("info",text) end,
        debug = function(text) prepare("debug",text) end,
}

return logger
