-- Ref: Galahaddruid/rs2-campaign-monitor: Read-only Windows companion for Romancing SaGa 2: Revenge of the Seven, powered by UE4SS and C#. - https://github.com/Galahaddruid/rs2-campaign-monitor

local cachedGamePlayAccessor = nil
local cachedPeriodAccessor = nil
local isMilitaryPowerHooked = false

local function getAccessors()
  if not cachedGamePlayAccessor or not cachedGamePlayAccessor:IsValid() then
    local manager = FindFirstOf("BP_GamePlayDataManager_C")
    cachedGamePlayAccessor = manager.GamePlayDataManagerAccessor
    cachedPeriodAccessor = manager.PeriodManagerAccessor
  end
  return cachedGamePlayAccessor, cachedPeriodAccessor
end

local function calculatePeriodJump(periodBattleCount, currentJumpPoint)
  if currentJumpPoint >= 15 then
    return 0, "常時"
  end

  if periodBattleCount >= 80 then
    return 0, "80回以上"
  end

  local remainder = periodBattleCount % 16
  local battlesUntilJump = 0

  if remainder > currentJumpPoint then
    battlesUntilJump = 16 - remainder
  end

  local cycleStart = (battlesUntilJump == 0) and (math.floor(periodBattleCount / 16) * 16) or (periodBattleCount + battlesUntilJump)
  local rangeEnd = cycleStart + currentJumpPoint

  local rangeStr
  if cycleStart >= 80 then
    rangeStr = "80回以上"
  else
    rangeStr = string.format("%d-%d回", cycleStart, rangeEnd)
  end

  return battlesUntilJump, rangeStr
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
  if isMilitaryPowerHooked then
    return
  end
  isMilitaryPowerHooked = true

  RegisterHook("/Game/UI/Widget/Menu/MilitaryPower/WBP_M_MilitaryPowerAll00.WBP_M_MilitaryPowerAll00_C:Init", function(self)
    local widget = self:get()
    local gamePlayAccessor, periodAccessor = getAccessors()

    local periodBattleCount = gamePlayAccessor:GetPeriodBattleCount()
    local totalBattleCount = gamePlayAccessor:GetTotalBattleCount()
    local currentJumpPoint = periodAccessor:GetCurrentJumpPoint()

    local battlesUntilJump, rangeStr = calculatePeriodJump(periodBattleCount, currentJumpPoint)

    StaticFindObject(nil, widget.WidgetTree, "Text_9"):SetText(
      FText(string.format("戦闘記録     EP: %d, 後: %d回, 範囲: %s", currentJumpPoint, battlesUntilJump, rangeStr))
    )
    widget.TextNum_10:SetText(FText(string.format("%d(%d)回", totalBattleCount, periodBattleCount)))
  end)
end)
