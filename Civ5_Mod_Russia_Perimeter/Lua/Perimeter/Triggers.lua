local Perimeter = include("Perimeter/Core.lua")
local Network = include("Perimeter/Network.lua")
local Defines = include("Perimeter/Defines.lua")
local Log = include("Perimeter/Log.lua")

local Triggers = {}

local borderCooldowns = {}
local cityDamageCache = {}

local function getBorderKey(playerID, otherID)
  return string.format("%d:%d", playerID, otherID)
end

local function setBorderTriggered(playerID, otherID)
  local key = getBorderKey(playerID, otherID)
  borderCooldowns[key] = Game.GetGameTurn() + Defines.BORDER_TRIGGER_COOLDOWN
end

local function isBorderOnCooldown(playerID, otherID)
  local key = getBorderKey(playerID, otherID)
  local threshold = borderCooldowns[key]
  if not threshold then
    return false
  end
  return Game.GetGameTurn() < threshold
end

local function updateCityDamage(playerID)
  cityDamageCache[playerID] = cityDamageCache[playerID] or {}
  for city in Players[playerID]:Cities() do
    cityDamageCache[playerID][city:GetID()] = city:GetDamage()
  end
end

function Triggers.OnUnitSetXY(playerID, unitID, x, y)
  local unit = Players[playerID] and Players[playerID]:GetUnitByID(unitID)
  if not unit or not unit:IsCombatUnit() then
    return
  end

  local plot = Map.GetPlot(x, y)
  if not plot then
    return
  end

  local ownerID = plot:GetOwner()
  if ownerID == -1 or ownerID == playerID then
    return
  end

  if isBorderOnCooldown(ownerID, playerID) then
    return
  end

  setBorderTriggered(ownerID, playerID)
  Perimeter.AddAL(ownerID, 1)
  Log.info(string.format("Border violation: player %d triggered by %d", ownerID, playerID))
end

function Triggers.OnUnitPrekill(playerID, unitID, unitType, x, y, delay, killerID)
  local plot = Map.GetPlot(x, y)
  if not plot then
    return
  end

  local ownerID = plot:GetOwner()
  if ownerID ~= playerID then
    return
  end

  Perimeter.AddAL(playerID, 1)
  Log.info(string.format("Unit killed on our land: player %d", playerID))
end

function Triggers.OnCityBombCheck(playerID)
  if not Players[playerID] or Players[playerID]:IsMinorCiv() then
    return
  end

  cityDamageCache[playerID] = cityDamageCache[playerID] or {}

  for city in Players[playerID]:Cities() do
    local id = city:GetID()
    local previousDamage = cityDamageCache[playerID][id] or city:GetDamage()
    local currentDamage = city:GetDamage()
    local delta = currentDamage - previousDamage

    if delta >= Defines.CITY_BOMB_MIN_DELTA then
      local cacheKey = string.format("bomb:%d:%d", playerID, id)
      local cooldownTurn = borderCooldowns[cacheKey]
      if not cooldownTurn or Game.GetGameTurn() >= cooldownTurn then
        borderCooldowns[cacheKey] = Game.GetGameTurn() + Defines.CITY_BOMB_COOLDOWN
        Perimeter.AddAL(playerID, 2)
        Log.info(string.format("City %d bombed for %d damage", id, delta))
      end
    end

    cityDamageCache[playerID][id] = currentDamage
  end
end

function Triggers.OnPlayerTurn(playerID)
  if Players[playerID]:IsMinorCiv() then
    return
  end

  Perimeter.TickDecay(playerID, Game.GetGameTurn())
  Triggers.OnCityBombCheck(playerID)
end

function Triggers.Register()
  GameEvents.UnitSetXY.Add(Triggers.OnUnitSetXY)
  GameEvents.UnitPrekill.Add(Triggers.OnUnitPrekill)
  GameEvents.PlayerDoTurn.Add(Triggers.OnPlayerTurn)
end

return Triggers
