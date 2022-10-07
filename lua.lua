local file = require('file')
local luaTableConverter = require('utils/lua-table-converter')

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

---@generic T : table
---@param filePath string
---@return T
local function loadTable(filePath)
  local table_text = file.ReadAllText(filePath)
  return luaTableConverter.fromString(table_text)
end

---@generic T : table
---@param filePath string
---@param table T
local function saveTable(filePath, table)
  local table_text = luaTableConverter.toString(table)
  file.WriteAllText(filePath, table_text)
end

local utils = {
  LeftJoin = leftJoin,
  Split = split,
  LoadTable = loadTable,
  SaveTable = saveTable
}

return utils
