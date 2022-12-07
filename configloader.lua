--- @type Mq
local mq = require('mq')
local luautils = require('utils/luahelpers')
local jsonUtil = require('utils/json')
local debug = require('utils/debug')

local configDir = mq.configDir.."/"
local serverName = mq.TLO.MacroQuest.Server()
local next = next

---@param fileName string
---@return string
local function getFilePath(fileName)
  return string.format("%s/%s/%s.json", configDir, serverName, fileName)
end

---@param keys string[]
---@param config table
---@return table
local function getNestedConfig(keys, config)
  local nestedConfig = config[keys[1]];
  if not nestedConfig then
    return {}
  end

  table.remove(keys, 1)
  if not next(keys) then
    return nestedConfig
  end

  return getNestedConfig(keys, nestedConfig)
end

---@generic T: table
---@param key string
---@param default? T
---@param filePath? string
---@return T
local function loadConfig(key, default, filePath)
  local configFilePath = getFilePath(filePath or mq.TLO.Me.Name())
  local loadedConfig = jsonUtil.LoadJSON(configFilePath)
  if key == "" then
    if default then
      return luautils.LeftJoin(default, loadedConfig)
    else
      return loadedConfig
    end
  end

  local keyedConfig = getNestedConfig(luautils.Split(key, '.'), loadedConfig)
  if default then
    return luautils.LeftJoin(default, keyedConfig)
  else
    return keyedConfig
  end
end

return loadConfig