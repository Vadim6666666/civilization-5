local Perimeter = include("Perimeter/Core.lua")
local Reactions = include("Perimeter/Reactions.lua")
local Log = include("Perimeter/Log.lua")

local AI = {}

function AI.ShouldAutomate(playerID)
  local player = Players[playerID]
  if not player then
    return false
  end

  if not player:IsHuman() then
    return true
  end

  return Perimeter.IsAuto(playerID)
end

function AI.Process(playerID)
  if not AI.ShouldAutomate(playerID) then
    return
  end

  local al = Perimeter.GetAL(playerID)
  if al < 3 then
    return
  end

  Log.info(string.format("AI processing reactions for player %d (AL=%d)", playerID, al))
end

return AI
