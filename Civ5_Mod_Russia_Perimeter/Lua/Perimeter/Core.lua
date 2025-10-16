local Log = include("Perimeter/Log.lua")
local Defines = include("Perimeter/Defines.lua")
local SaveUtils = include("ThirdParty/TableSaverLoader.lua")

local Perimeter = {}

local DEFAULT_STATE = {
  AL = 0,
  lockTurns = 0,
  windows = {},
  auto = false,
  preset = "Balanced",
  delayedProtocol = false,
}

local states = {}
local cpEnabled = false

local function getPlayerState(playerID)
  if states[playerID] then
    return states[playerID]
  end

  local state = SaveUtils.Load(playerID, "RU_PERIM_STATE")
  if not state then
    state = {}
    for k, v in pairs(DEFAULT_STATE) do
      state[k] = v
    end
  end

  states[playerID] = state
  return state
end

local function isCPAvailable()
  if cpEnabled then
    return true
  end

  if not Defines.USE_CP_PROPERTIES_IF_AVAILABLE then
    return false
  end

  if Game ~= nil and Game.CustomModOptions ~= nil then
    local option = Game.CustomModOptions["CustomModOptions"]
    if option ~= nil then
      cpEnabled = true
      Log.info("Custom DLL detected - enabling CP properties")
    end
  end

  return cpEnabled
end

function Perimeter.Init(playerID)
  getPlayerState(playerID)
end

function Perimeter.Save(playerID)
  local state = states[playerID]
  if not state then
    return
  end

  SaveUtils.Save(playerID, "RU_PERIM_STATE", state)
end

function Perimeter.GetAL(playerID)
  return getPlayerState(playerID).AL
end

local function clampAL(value)
  if value < 0 then
    return 0
  elseif value > 5 then
    return 5
  end
  return value
end

function Perimeter.AddAL(playerID, delta)
  local state = getPlayerState(playerID)
  local old = state.AL
  state.AL = clampAL(old + (delta or 0))
  if state.AL ~= old then
    Log.info(string.format("Player %d AL changed from %d to %d", playerID, old, state.AL))
  end
end

function Perimeter.TickDecay(playerID, turn)
  local state = getPlayerState(playerID)
  if state.AL <= 0 then
    return
  end

  if turn % Defines.AL_DECAY_TURNS ~= 0 then
    return
  end

  if state.windows and next(state.windows) ~= nil then
    return
  end

  Perimeter.AddAL(playerID, -1)
end

function Perimeter.SetAuto(playerID, value)
  local state = getPlayerState(playerID)
  state.auto = value and true or false
end

function Perimeter.IsAuto(playerID)
  return getPlayerState(playerID).auto
end

function Perimeter.GetPreset(playerID)
  return getPlayerState(playerID).preset
end

function Perimeter.SetPreset(playerID, name)
  local state = getPlayerState(playerID)
  state.preset = name or state.preset
end

function Perimeter.IsProtocolDelayed(playerID)
  return getPlayerState(playerID).delayedProtocol
end

function Perimeter.SetProtocolDelayed(playerID, value)
  local state = getPlayerState(playerID)
  state.delayedProtocol = value and true or false
end

function Perimeter.ExportState(playerID)
  local state = getPlayerState(playerID)
  local copy = {}
  for k, v in pairs(state) do
    copy[k] = v
  end
  return copy
end

return Perimeter
