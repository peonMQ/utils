local mq = require 'mq'
local logger = require 'utils/logging'

-- Consolidate with these lists
-- https://www.eqemulator.org/forums/showthread.php?t=15238
-- https://docs.macroquest.org/reference/general/animations/
local possibleAggroAnimations = {5,8,12,17,18,32,42,44,80,106,129,144}

---@param spawn spawn
---@return boolean
local function isMaybeAggressive(spawn)
  if spawn.Aggressive() then
    return true
  end

  local spawnAnimation = spawn.Animation();
  if not spawnAnimation then
    return false
  end

  for index, value in ipairs(possibleAggroAnimations) do
    if value == spawnAnimation then
        return true
    end
  end

  return false
end

local function clearCursor()
	local i = 1
  local cursor = mq.TLO.Cursor

  while cursor() ~= nil and i < 5 do
    mq.cmd("/autoinventory")
    mq.delay("1s", function() return not cursor() end)
    i = i + 1
  end

  if cursor() ~= nil then
    mq.cmd("/beep")
    logger.Debug("Unable to clear cursor, ending script")
    mq.exit()
  end
end

local function ensureTarget(targetId)
  if not targetId then
    logger.Debug("Invalid <targetId>")
    return false
  end

  if mq.TLO.Target.ID() ~= targetId then
    if mq.TLO.SpawnCount("id "..targetId)() > 0 then
      mq.cmdf("/mqtarget id %s", targetId)
      mq.delay("3s", function() return mq.TLO.Target.ID() == targetId end)
    else
      logger.Warn("EnsureTarget has no spawncount for target id <%d>", targetId)
    end
  end

  return mq.TLO.Target.ID() == targetId
end

local function ensureClearTarget()
  if mq.TLO.Target.ID() then
      mq.cmd("/cleartarget")
      mq.delay("3s", function() return not mq.TLO.Target.ID() end)
  end

  return not mq.TLO.Target.ID()
end

local function npcInRange(radius)
  local maxRadius = radius or 100
  local query = "npc los targetable radius "..maxRadius
	local npcCount = mq.TLO.SpawnCount(query)()
  if npcCount < 1 then
    return false
  end

  for i=1,npcCount do
    local nearestSpawn = mq.TLO.NearestSpawn(i, query)
    if nearestSpawn() and isMaybeAggressive(nearestSpawn --[[@as spawn]]) then
      logger.Debug("%s is possibly an aggressive, mob in camp.", nearestSpawn.Name())
        return true
    end

    -- local npcAnimation = mq.TLO.NearestSpawn(i, query).Animation()
    -- for key, value in pairs(aggroAnimation) do
    --   if value == npcAnimation then return true end
    -- end
  end

  return false
end

local Utils = {
  ClearCursor = clearCursor,
  EnsureTarget = ensureTarget,
  EnsureClearTarget = ensureClearTarget,
  NPCInRange = npcInRange,
  IsMaybeAggressive = isMaybeAggressive
}

return Utils