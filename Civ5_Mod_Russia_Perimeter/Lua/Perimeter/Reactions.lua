local Perimeter = include("Perimeter/Core.lua")
local Network = include("Perimeter/Network.lua")
local Defines = include("Perimeter/Defines.lua")
local Log = include("Perimeter/Log.lua")

local Reactions = {}

local function ensureNetwork(player)
  if not Network.IsAlive() then
    Network.Rebuild(player)
  end
  return Network.IsAlive()
end

local function canReact(playerID)
  local player = Players[playerID]
  if not player or player:IsBarbarian() then
    return false
  end
  return true
end

function Reactions.EWarSuppression(playerID)
  if not canReact(playerID) then
    return false
  end

  local player = Players[playerID]
  if not ensureNetwork(player) then
    Log.warn("EWar suppression attempted without active network")
    return false
  end

  Log.info("EWar suppression placeholder executed")
  return true
end

function Reactions.AirDefenseBubble(playerID)
  if not canReact(playerID) then
    return false
  end

  local player = Players[playerID]
  if not ensureNetwork(player) then
    return false
  end

  Log.info("Air Defense Bubble placeholder executed")
  return true
end

function Reactions.CruiseStrike(playerID, targetPlot)
  if not canReact(playerID) then
    return false
  end

  Log.info("Cruise strike placeholder executed")
  return targetPlot ~= nil
end

function Reactions.Cyberstorm(playerID, targetCity)
  if not canReact(playerID) then
    return false
  end

  Log.info("Cyberstorm placeholder executed")
  return targetCity ~= nil
end

function Reactions.MobilizationBoost(playerID)
  if not canReact(playerID) then
    return false
  end

  Log.info("Mobilization boost placeholder executed")
  return true
end

function Reactions.PerimeterProtocol(playerID, aggressorID)
  if not canReact(playerID) then
    return false
  end

  if Perimeter.GetAL(playerID) < 5 then
    Log.warn("Protocol attempted below AL5")
    return false
  end

  if not ensureNetwork(Players[playerID]) then
    Log.warn("Protocol attempted without network")
    return false
  end

  Log.info(string.format("Perimeter protocol placeholder executed vs %s", tostring(aggressorID)))
  return true
end

return Reactions
