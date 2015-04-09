function widget:GetInfo()
  return {
    name      = "Priority Sharing v2",
    desc      = "Automatically shares metal to the highest elo player on your team before the autoshare threshhold. (improved version by Ikinz editing Autowar's base script)",
    author    = "AutoWar/Ikinz",
    date      = "2015",
    license   = "GNU GPL, v2 or later",
    layer     = 9999,
    enabled   = false
  }
end

------------------------------------------------------------------

local spEcho = Spring.Echo
local myAllyID = Spring.GetMyAllyTeamID()
local myTeamID = Spring.GetMyTeamID()
local AlliedTeamIDArray = {}
local EloArray = {}
local AlliedPlayerIDList = {}
local spGetPlayerInfo = Spring.GetPlayerInfo
local spGetPlayerList = Spring.GetPlayerList()

------------------------------------------------------------------

--[[
local function ToInteger(number)
    return math.floor(tonumber(number) or error("Could not cast '" .. tostring(number) .. "' to number.'"))
end
]]

local bigEloTeamID
local bigEloName

local function GetAlliedPlayersInfo()
    local maxElo
	for i=1, #spGetPlayerList do
		local playerID = spGetPlayerList[i]
		local name,active,spectator,teamID,allyTeamID,pingTime,cpuUsage,country,rank,customKeys = spGetPlayerInfo(playerID)
		local clan, faction, level, elo, wins
		if customKeys then
			clan = customKeys.clan
			faction = customKeys.faction
			level = customKeys.level
			elo = tonumber(customKeys.elo)
		end
		if allyTeamID == myAllyID and teamID~=myTeamID then
            if elo ~= nil and (maxElo == nil or elo > maxElo) then
                maxElo = elo
                bigEloTeamID = teamID
                bigEloName = name
                spEcho(name .. ' ' .. elo .. ' ' .. teamID)
            end
		end
	end
end

local function ShareMetal()
	local currentlevel, storage, pull, income, expense, share, sent, recieved = Spring.GetTeamResources(myTeamID,"metal")
	if currentlevel > (0.90*storage) and bigEloName~=nil then
		--spEcho("I gave "..(0.10*storage).." metal to "..bigEloName..".")
		Spring.ShareResources(bigEloTeamID, "metal", (0.10*storage))
	end
end

local function CheckSpecState(widgetname)
	 if (Spring.GetSpectatingState() or Spring.IsReplay()) and (not Spring.IsCheatingEnabled()) then
		spEcho("<"..widgetname..">".." Spectator mode or replay. Widget removed.")
		widgetHandler:RemoveWidget()
		return true
	end
	return false
end

------------------------------------------------------------------

function widget:Initialize()
	if not CheckSpecState(widgetName) then
		curModID = string.upper(Game.modShortName or "")
		if ( curModID ~= "ZK" ) then
			widgetHandler:RemoveWidget()
			return
		else
			GetAlliedPlayersInfo()
		end
	end
end

function widget:GameFrame(frameNum)
	if frameNum%30==0 and Spring.GetGameSeconds() > 10 then
		ShareMetal()
	end
end
