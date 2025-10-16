local Perimeter = include("Perimeter/Core.lua")
local Log = include("Perimeter/Log.lua")

local UI = {}

local function getPanelState(playerID)
  return {
    auto = Perimeter.IsAuto(playerID),
    preset = Perimeter.GetPreset(playerID),
    al = Perimeter.GetAL(playerID),
  }
end

function UI.OpenPanel(playerID)
  local state = getPanelState(playerID)
  Log.info(string.format("Opening Perimeter UI for player %d (AL=%d Auto=%s Preset=%s)", playerID, state.al, tostring(state.auto), state.preset))
end

function UI.ToggleAuto(playerID)
  local newValue = not Perimeter.IsAuto(playerID)
  Perimeter.SetAuto(playerID, newValue)
  Log.info(string.format("Player %d auto mode -> %s", playerID, tostring(newValue)))
end

function UI.CyclePreset(playerID)
  local presets = {"Defensive", "Balanced", "Harsh"}
  local current = Perimeter.GetPreset(playerID)
  local index = 1
  for i, name in ipairs(presets) do
    if name == current then
      index = i
      break
    end
  end
  local nextPreset = presets[(index % #presets) + 1]
  Perimeter.SetPreset(playerID, nextPreset)
  Log.info(string.format("Player %d preset -> %s", playerID, nextPreset))
end

function UI.OnDiploCornerPopulate()
  local playerID = Game.GetActivePlayer and Game.GetActivePlayer()
  if playerID == nil then
    return
  end

  Log.info("DiploCorner button placeholder registered")
end

function UI.Register()
  if LuaEvents and LuaEvents.DiploCornerAddinButton then
    LuaEvents.DiploCornerAddinButton.Add(UI.OnDiploCornerPopulate)
  end
end

return UI
