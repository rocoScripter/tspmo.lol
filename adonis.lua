local exe_name = identifyexecutor()

if exe_name ~= "Wave Windows" then
    local dummy1, dummy2 = function() end, function() end
    hookfunction(dummy2, dummy1)
    if not isfunctionhooked(dummy2) then
        game.Players.LocalPlayer:Destroy()
        return LPH_CRASH()
    end
end

local function checkEnvironment(env)
    for _, fn in env do
        if type(fn) == "function" and isfunctionhooked(fn) then
            game.Players.LocalPlayer:Destroy()
            return LPH_CRASH()
        end
    end
end

checkEnvironment(getgenv())
checkEnvironment(getrenv())

local getCons, getUpvals, hookFunc = getconnections, getupvalues, hookfunction
local setUpval = setupvalue

local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")

local good_check, last_beat = 0, 0
RunService.RenderStepped:Connect(function()
    if tick() > last_beat + 1 then
        last_beat = tick() + 1
        local a, b = true, true

        if not a or not b then
            if good_check <= 0 then
                game.Players.LocalPlayer:Destroy()
                return LPH_CRASH()
            end
            good_check -= 1
        else
            good_check += 1
        end
    end
end)

local currentConnections, hookedConnections = {}, {}
local lastUpdate, updateInterval = 0, 5

local function hookLogConnection(conn)
    pcall(function()
        local upvalues = getUpvals(conn.Function)
        local internalTable = upvalues[9]
        local mainFunc = internalTable and internalTable[1]

        if mainFunc then
            setUpval(mainFunc, 14, function(...)
                return function(...)
                    local args = { ... }
                    if type(args[1]) == "table" then
                        for i = 1, 4 do
                            local item = args[1][i]
                            if typeof(item) == "userdata" and item.Disconnect then
                                pcall(function() item:Disconnect() end)
                            end
                        end
                    end
                end
            end)

            setUpval(mainFunc, 1, function() task.wait(200) end)
            hookFunc(mainFunc, function() return {} end)
        end
    end)
end

local connectionMonitor
connectionMonitor = RunService.RenderStepped:Connect(function()
    if #getCons(LogService.MessageOut) >= 2 then
        connectionMonitor:Disconnect()
    end

    if tick() - lastUpdate >= updateInterval then
        lastUpdate = tick()
        for _, conn in getCons(LogService.MessageOut) do
            if not table.find(currentConnections, conn) then
                table.insert(currentConnections, conn)
                table.insert(hookedConnections, conn)
                hookLogConnection(conn)
            end
        end
    end
end)

local function antiKickInit()
    local success, err = pcall(function()
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" and rawget(obj, "indexInstance") then
                local inst = obj.indexInstance
                if type(inst) == "table" and inst[1] == "kick" then
                    setreadonly(obj, false)
                    setreadonly(inst, false)
                    rawset(obj, "Table", { "kick", function() coroutine.yield() end })
                    return true
                end
            end
        end
    end)

    if not success then
        warn("[Anti-Kick] Interception failed:", err)
    else
        print("[Anti-Kick] Kick interception active.")
    end
end

if game.PlaceId ~= 2788229376 then
    antiKickInit()
end
