local militaryPowerInitPath = "/Game/UI/Widget/Menu/MilitaryPower/WBP_M_MilitaryPowerAll00.WBP_M_MilitaryPowerAll00_C:Init"
local cachedAccessor = nil
local isMilitaryPowerHooked = false

local function getAccessor()
  if cachedAccessor and cachedAccessor:IsValid() then
    return cachedAccessor
  end

  local manager = FindFirstOf("BP_GamePlayDataManager_C")
  if manager and manager:IsValid() then
    cachedAccessor = manager.GamePlayDataManagerAccessor
  end
  return cachedAccessor
end

local function registerMilitaryPowerHook()
  if isMilitaryPowerHooked then
    return
  end
  isMilitaryPowerHooked = true

  RegisterHook(militaryPowerInitPath, function(self)
    local widget = self:get()
    if not widget or not widget:IsValid() then
      return
    end
    if not widget.TextNum_10 or not widget.TextNum_10:IsValid() then
      return
    end

    local accessor = getAccessor()
    if not accessor or not accessor:IsValid() then
      return
    end

    local periodBattleCount = accessor:GetPeriodBattleCount()
    local totalBattleCount = accessor:GetTotalBattleCount()
    widget.TextNum_10:SetText(FText(string.format("%d(%d)回", totalBattleCount, periodBattleCount)))
  end)
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(self)
  registerMilitaryPowerHook()
end)
