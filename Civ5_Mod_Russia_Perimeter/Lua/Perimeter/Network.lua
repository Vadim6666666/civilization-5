local Log = include("Perimeter/Log.lua")
local Defines = include("Perimeter/Defines.lua")

local Network = {}

local networkState = {
  alive = false,
  nodes = {},
  lastRebuildTurn = -1,
}

local function countNodes(player)
  local count = 0
  for city in player:Cities() do
    if city:IsHasBuilding(GameInfoTypes and GameInfoTypes.BUILDING_RU_PERIMETER_NODE or -1) then
      count = count + 1
      networkState.nodes[city:GetID()] = true
    else
      networkState.nodes[city:GetID()] = nil
    end
  end
  return count
end

function Network.Rebuild(player)
  if not player then
    Log.warn("Network.Rebuild called without player context")
    return
  end

  local count = countNodes(player)
  networkState.alive = (count >= Defines.NETWORK_REQUIRED_NODES)
  networkState.lastRebuildTurn = Game and Game.GetGameTurn and Game.GetGameTurn() or networkState.lastRebuildTurn
  Log.info(string.format("Network rebuild for player %d (nodes=%d alive=%s)", player:GetID(), count, tostring(networkState.alive)))
end

function Network.IsAlive()
  return networkState.alive
end

function Network.GetNodes()
  return networkState.nodes
end

function Network.GetLastRebuildTurn()
  return networkState.lastRebuildTurn
end

return Network
