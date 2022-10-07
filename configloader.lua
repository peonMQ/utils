local luautils = require('util/lua')
local jsonUtil = require('util/json')


local next = next


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
---@param default T
---@param filePath string
---@return T
local function loadConfig(key, default, filePath)
  local loadedConfig = jsonUtil.LoadJSON(filePath)
  if key == "" then
    if default then
      return luautils.leftJoin(default, loadedConfig)
    else 
      return loadedConfig
    end
  end

  local keyedConfig = getNestedConfig(luautils.Split(key, '.'), loadedConfig)
  if default then
    return luautils.leftJoin(default, keyedConfig)
  else
    return keyedConfig
  end
end

return loadConfig