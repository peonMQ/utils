local mq = require 'mq'
local file = require 'utils/file'
local luaTableConverter = require 'utils/lua-table-converter'

---@generic T : table
---@param filePath string
---@return T
local function loadTable(filePath)
  local file = loadfile(filePath)
  if file then
      return file()
  end

  return {}
end

---@generic T : table
---@param filePath string
---@param table T
local function saveTable(filePath, table)
  mq.pickle(filePath, table)
end

local utils = {
  LoadTable = loadTable,
  SaveTable = saveTable,
}

return utils
