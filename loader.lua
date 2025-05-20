local placeId = game.PlaceId

local scripts = {
    [2788229376] = "https://raw.githubusercontent.com/rocoScripter/tspmo.lol/refs/heads/main/adonis.lua",
    [105028250868995] = "https://raw.githubusercontent.com/rocoScripter/tspmo.lol/refs/heads/main/adonis.lua",
    [75159825516372] = "https://raw.githubusercontent.com/rocoScripter/tspmo.lol/refs/heads/main/npc.lua",
    [138673949835356] = "https://raw.githubusercontent.com/rocoScripter/tspmo.lol/refs/heads/main/npc.lua",
}

if scripts[placeId] then
    loadstring(game:HttpGet(scripts[placeId]))()
else
    game:GetService("Players").LocalPlayer:Kick("This game is not supported by the script loader.")
end
