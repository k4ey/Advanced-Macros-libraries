-- Function that allows you to quickly get interesting information about userdata object. 
function luajava.getInfo(userdata,depth)
    depth = depth or 0
    log("&cGetting info about object: \n",userdata,"\n&c")
    log("&c DEPTH LEVEL:",depth)
    if depth >= 0 then
        log("&c=====Fields=====")
        log(luajava.getDeclaredFields(userdata))
        log("&c=====Methods=====")
        log(luajava.getDeclaredMethods(userdata))
    end
    if depth >= 1 then
        log("&c=====&4Interfaces&c=====")
        log(luajava.getInterfaces(userdata))
        log("&c=====&4InnerClasses&c=====")
        log(luajava.getInnerClasses(userdata))
        log("&c=====&4SuperClass&c=====")
        log(luajava.getSuperClass(userdata))
    end
    if depth >= 2 then
        log("&4=====Method Description=====")
        for name, method in pairs(luajava.getDeclaredMethods(userdata)) do
            log("\n&c Name: ",name,"&c description:\n",luajava.describeMethod(method))
        end
        log("&4=====Field Values=====")
        for _, field in pairs(luajava.getDeclaredFields(userdata)) do
            log("&c Key: ",field ,"&c value:\n",luajava.getField(field),"\n&cor \n&c<",userdata[field],"&c>")
        end
    end
end
