-- Модуль Сокол ресурсов США
-- Агрессивно направляет ИИ США к стратегическим ресурсам и военному доминированию.

local TARGET_CIV = GameInfoTypes.CIVILIZATION_AMERICA
local RESOURCE_OIL = GameInfoTypes.RESOURCE_OIL
local RESOURCE_URANIUM = GameInfoTypes.RESOURCE_URANIUM
local RESOURCE_ALUMINUM = GameInfoTypes.RESOURCE_ALUMINUM
local RESOURCE_IRON = GameInfoTypes.RESOURCE_IRON

local TURN_INTERVAL = 5
local STRENGTH_ADVANTAGE_RATIO = 1.25
local FAILSAFE_RATIO = 0.9
local GOLD_BUFFER = 150

local lastAnalysisTurn = {}

-- Кэширование идентификаторов типов ------------------------------------------------
local function GetTypeId(typeName)
  local value = GameInfoTypes[typeName]
  return value
end

local NavalUnitTypes = {
  "UNIT_CARRIER",
  "UNIT_BATTLESHIP",
  "UNIT_MISSILE_CRUISER",
  "UNIT_DESTROYER",
  "UNIT_SUBMARINE",
  "UNIT_NUCLEAR_SUBMARINE"
}

local AirUnitTypes = {
  "UNIT_JET_FIGHTER",
  "UNIT_FIGHTER",
  "UNIT_BOMBER",
  "UNIT_STEALTH_BOMBER",
  "UNIT_ROCKET_ARTILLERY"
}

local LandUnitTypes = {
  "UNIT_MODERN_ARMOR",
  "UNIT_MECHANIZED_INFANTRY",
  "UNIT_MOBILE_SAM",
  "UNIT_XCOM_SQUAD",
  "UNIT_INFANTRY"
}

local ReconUnitTypes = {
  "UNIT_PARATROOPER",
  "UNIT_PATHFINDER",
  "UNIT_SCOUT",
  "UNIT_CHINOOK_HELICOPTER"
}

local NuclearProject = GetTypeId("PROJECT_MANHATTAN_PROJECT")
local NuclearMissile = GetTypeId("UNIT_NUCLEAR_MISSILE")
local AtomicBomb = GetTypeId("UNIT_ATOMIC_BOMB")
local NuclearPlant = GetTypeId("BUILDING_NUCLEAR_PLANT")
local OrderTrain = OrderTypes.ORDER_TRAIN
local OrderConstruct = OrderTypes.ORDER_CONSTRUCT
local OrderCreate = OrderTypes.ORDER_CREATE

-- Приближённый расчёт военной мощи --------------------------------------------------
local function GetMilitaryStrength(player)
  local total = 0
  for unit in player:Units() do
    if not unit:IsDead() and not unit:IsEmbarked() then
      if not unit:IsCivilianUnit() then
        local combat = unit:GetBaseCombatStrength() or 0
        local ranged = 0
        if unit.GetBaseRangedCombatStrength then
          ranged = unit:GetBaseRangedCombatStrength()
        else
          ranged = unit:GetRangedCombatStrength() or 0
        end
        total = total + combat + math.floor(ranged * 0.75)
      end
    end
  end
  return total
end

-- Проверка контроля стратегического ресурса ----------------------------------------
local function PlayerControlsResource(player, resourceType)
  if resourceType == nil then
    return false
  end
  if player:GetNumResourceAvailable(resourceType, true) > 0 then
    return true
  end
  local teamID = player:GetTeam()
  for city in player:Cities() do
    local plot = city:Plot()
    for dx = -3, 3 do
      for dy = -3, 3 do
        local targetPlot = Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, 3)
        if targetPlot then
          if targetPlot:GetResourceType(teamID) == resourceType and targetPlot:GetOwner() == player:GetID() then
            return true
          end
        end
      end
    end
  end
  return false
end

-- Сбор разведанных стратегических клеток -------------------------------------------
local function CollectStrategicPlots(player)
  local info = {
    hasVisible = false,
    oilPlots = {},
    uraniumPlots = {}
  }
  local teamID = player:GetTeam()
  local playerID = player:GetID()
  for plotIndex = 0, Map.GetNumPlots() - 1 do
    local plot = Map.GetPlotByIndex(plotIndex)
    if plot:IsRevealed(teamID, false) then
      local resourceType = plot:GetResourceType(teamID)
      if resourceType == RESOURCE_OIL or resourceType == RESOURCE_URANIUM then
        info.hasVisible = true
        local entry = {
          plot = plot,
          ownedByUS = plot:GetOwner() == playerID,
          resourceType = resourceType
        }
        if resourceType == RESOURCE_OIL then
          table.insert(info.oilPlots, entry)
        else
          table.insert(info.uraniumPlots, entry)
        end
      end
    end
  end
  return info
end

-- Агрессивная покупка клеток -------------------------------------------------------
local function PurchaseStrategicPlots(player, strategicInfo)
  local playerID = player:GetID()
  if player:GetGold() < GOLD_BUFFER then
    return
  end
  for _, city in player:Cities() do
    if not city:IsRazing() and not city:IsPuppet() then
      local plot = city:Plot()
      for dx = -3, 3 do
        for dy = -3, 3 do
          local targetPlot = Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, 3)
          if targetPlot then
            local owner = targetPlot:GetOwner()
            local resourceType = targetPlot:GetResourceType(player:GetTeam())
            if resourceType and (resourceType == RESOURCE_OIL or resourceType == RESOURCE_URANIUM) then
              if owner ~= playerID and owner == -1 then
                if city:CanPurchasePlot(targetPlot:GetX(), targetPlot:GetY()) then
                  local cost = city:GetBuyPlotCost(targetPlot:GetX(), targetPlot:GetY())
                  if cost > 0 and player:GetGold() >= cost + GOLD_BUFFER then
                    city:DoBuyPlot(targetPlot:GetX(), targetPlot:GetY())
                    print("Сокол ресурсов США: куплена клетка со стратегическим ресурсом")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

-- Приоритеты военного производства -------------------------------------------------
local function ChooseProduction(city, unitList)
  for _, unitType in ipairs(unitList) do
    local unitID = GetTypeId(unitType)
    if unitID and city:CanTrain(unitID) then
      city:PushOrder(OrderTrain, unitID, -1, false, false, false)
      return true
    end
  end
  return false
end

local function ChooseReconProduction(city)
  if ChooseProduction(city, ReconUnitTypes) then
    return true
  end
  return ChooseProduction(city, AirUnitTypes)
end

local function EnforceCityProduction(player, strategicInfo)
  local oilAvailable = player:GetNumResourceAvailable(RESOURCE_OIL, true)
  local uraniumAvailable = player:GetNumResourceAvailable(RESOURCE_URANIUM, true)
  local aluminumAvailable = player:GetNumResourceAvailable(RESOURCE_ALUMINUM, true)
  local hasVisible = strategicInfo.hasVisible
  local needsRecon = not hasVisible and oilAvailable <= 0 and uraniumAvailable <= 0
  local manhattanComplete = NuclearProject and player:GetProjectCount(NuclearProject) > 0

  for city in player:Cities() do
    if city:GetOrderQueueLength() == 0 and not city:IsPuppet() and not city:IsResistance() then
      local cityPlot = city:Plot()
      local prioritizeNukes = uraniumAvailable > 0
      local hasOilLocally = false
      local hasUraniumLocally = false
      for dx = -2, 2 do
        for dy = -2, 2 do
          local plot = Map.PlotXYWithRangeCheck(cityPlot:GetX(), cityPlot:GetY(), dx, dy, 2)
          if plot then
            local resourceType = plot:GetResourceType(player:GetTeam())
            if resourceType == RESOURCE_OIL and plot:GetOwner() == player:GetID() then
              hasOilLocally = true
            elseif resourceType == RESOURCE_URANIUM and plot:GetOwner() == player:GetID() then
              hasUraniumLocally = true
            end
          end
        end
      end

      -- Манхэттенский проект строится в первую очередь
      if NuclearProject and not manhattanComplete and city:CanCreate(NuclearProject) then
        city:PushOrder(OrderCreate, NuclearProject, -1, false, false, false)
        print("Сокол ресурсов США: Манхэттенский проект поставлен в очередь в " .. city:GetName())
        manhattanComplete = true
      elseif prioritizeNukes and NuclearMissile and city:CanTrain(NuclearMissile) then
        city:PushOrder(OrderTrain, NuclearMissile, -1, false, false, false)
        print("Сокол ресурсов США: ядерная ракета строится в " .. city:GetName())
      elseif prioritizeNukes and AtomicBomb and city:CanTrain(AtomicBomb) then
        city:PushOrder(OrderTrain, AtomicBomb, -1, false, false, false)
        print("Сокол ресурсов США: атомная бомба строится в " .. city:GetName())
      elseif hasUraniumLocally and NuclearPlant and not city:IsHasBuilding(NuclearPlant) and city:CanConstruct(NuclearPlant) then
        city:PushOrder(OrderConstruct, NuclearPlant, -1, false, false, false)
        print("Сокол ресурсов США: ядерная электростанция строится в " .. city:GetName())
      elseif city:IsCoastal() and oilAvailable > 0 then
        if ChooseProduction(city, NavalUnitTypes) then
          print("Сокол ресурсов США: морская очередь выставлена в " .. city:GetName())
        elseif aluminumAvailable > 0 then
          if ChooseProduction(city, AirUnitTypes) then
            print("Сокол ресурсов США: воздушное подкрепление заложено в прибрежном городе " .. city:GetName())
          end
        end
      elseif oilAvailable > 0 then
        if ChooseProduction(city, LandUnitTypes) then
          print("Сокол ресурсов США: наземная армия строится в " .. city:GetName())
        end
      elseif needsRecon then
        if ChooseReconProduction(city) then
          print("Сокол ресурсов США: разведка заказана в " .. city:GetName())
        end
      else
        -- По умолчанию усиливаем промышленность
        local factoryID = GetTypeId("BUILDING_FACTORY")
        if factoryID and not city:IsHasBuilding(factoryID) and city:CanConstruct(factoryID) then
          city:PushOrder(OrderConstruct, factoryID, -1, false, false, false)
          print("Сокол ресурсов США: фабрика строится в " .. city:GetName())
        else
          ChooseProduction(city, LandUnitTypes)
        end
      end
    end
  end
end

-- Планирование агрессивных войн ----------------------------------------------------
local function EvaluateWarTargets(player, strategicInfo)
  local usTeamID = player:GetTeam()
  local usTeam = Teams[usTeamID]
  local usStrength = GetMilitaryStrength(player)
  if usStrength <= 0 then
    return
  end

  local oilNeed = player:GetNumResourceAvailable(RESOURCE_OIL, true) < 6
  local uraniumNeed = player:GetNumResourceAvailable(RESOURCE_URANIUM, true) < 4

  if not oilNeed and not uraniumNeed then
    return
  end

  if usTeam:GetAtWarCount(false) >= 2 then
    return
  end

  for playerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
    local target = Players[playerID]
    if target and target:IsAlive() and target ~= player and not target:IsMinorCiv() then
      local targetTeamID = target:GetTeam()
      local targetTeam = Teams[targetTeamID]
      if not usTeam:IsAtWar(targetTeamID) and usTeam:CanDeclareWar(targetTeamID) then
        if not player:IsDoF(target:GetID()) then
          local targetStrength = GetMilitaryStrength(target)
          if targetStrength <= 0 or (usStrength >= targetStrength * STRENGTH_ADVANTAGE_RATIO and usStrength > targetStrength * FAILSAFE_RATIO) then
            local targetHasOil = oilNeed and PlayerControlsResource(target, RESOURCE_OIL)
            local targetHasUranium = uraniumNeed and PlayerControlsResource(target, RESOURCE_URANIUM)
            if targetHasOil or targetHasUranium then
              usTeam:DeclareWar(targetTeamID)
              print("Сокол ресурсов США: объявлена война державе " .. Locale.ConvertTextKey(target:GetCivilizationShortDescriptionKey()))
              return
            end
          end
        end
      end
    end
  end

  for playerID = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
    local target = Players[playerID]
    if target and target:IsAlive() and target:IsMinorCiv() then
      if player:IsAllied(target:GetID()) then
        -- Сохраняем долгосрочный союз
      elseif player:IsFriends(target:GetID()) then
        -- Избегаем войны с дружественными городами-государствами
      else
        local targetTeamID = target:GetTeam()
        local targetTeam = Teams[targetTeamID]
        if not usTeam:IsAtWar(targetTeamID) and usTeam:CanDeclareWar(targetTeamID) then
          local targetStrength = GetMilitaryStrength(target)
          if targetStrength == 0 or usStrength >= targetStrength * STRENGTH_ADVANTAGE_RATIO then
            local targetHasOil = oilNeed and PlayerControlsResource(target, RESOURCE_OIL)
            local targetHasUranium = uraniumNeed and PlayerControlsResource(target, RESOURCE_URANIUM)
            if targetHasOil or targetHasUranium then
              usTeam:DeclareWar(targetTeamID)
              print("Сокол ресурсов США: объявлена война городу-государству " .. Locale.ConvertTextKey(target:GetCivilizationShortDescriptionKey()))
              return
            end
          end
        end
      end
    end
  end
end

-- Основной цикл --------------------------------------------------------------------
local function ProcessAmericanTurn(player)
  local strategicInfo = CollectStrategicPlots(player)
  PurchaseStrategicPlots(player, strategicInfo)
  EvaluateWarTargets(player, strategicInfo)
  EnforceCityProduction(player, strategicInfo)
end

local function OnPlayerDoTurn(playerID)
  local player = Players[playerID]
  if not player or not player:IsAlive() then
    return
  end
  if player:GetCivilizationType() ~= TARGET_CIV then
    return
  end

  local gameTurn = Game.GetGameTurn()
  local lastTurn = lastAnalysisTurn[playerID] or -TURN_INTERVAL
  if gameTurn - lastTurn >= TURN_INTERVAL then
    lastAnalysisTurn[playerID] = gameTurn
    ProcessAmericanTurn(player)
  else
    EnforceCityProduction(player, CollectStrategicPlots(player))
  end
end

GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)
print("Сокол ресурсов США: скрипт активирован")
