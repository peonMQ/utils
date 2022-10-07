---@generic T : table
---@param default T
---@param loaded T
---@return T
local function leftJoin(default, loaded)
  local config = {}
  for key, value in pairs(default) do
    config[key] = value
    local loadedValue = loaded[key]
    if type(value) == "table" or not value then
      if type(loadedValue or false) == "table" then
        config[key] = leftJoin(default[key] or {}, loadedValue or {})
      end
    elseif type(value) == type(loadedValue) then
      config[key] = loadedValue
    end
  end

  return config
end

---@param inputstr string
---@param separator string
---@return table
local function split (inputstr, separator)
  if separator == nil then
     separator = "%s"
  end

  local subStrings={}
  for subString in string.gmatch(inputstr, "([^"..separator.."]+)") do
     table.insert(subStrings, subString)
  end
  return subStrings
end

local utils = {
  LeftJoin = leftJoin,
  Split = split
}

return utils
