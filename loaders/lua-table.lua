local file = require 'utils/file'
local luaTableConverter = require 'utils/lua-table-converter'

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
  LoadTable = loadTable,
  SaveTable = saveTable,
}

return utils
