local packageMan = require('mq/PackageMan')
local file = require('utils/file')

local json = packageMan.Require('lua-cjson', 'cjson')

---@generic T : table
---@param filePath string
---@return T
local function loadJSON(filePath)
  local json_text = file.ReadAllText(filePath)
  return json.decode(json_text)
end

---@generic T : table
---@param filePath string
---@param table T
local function saveJSON(filePath, table)
  local json_text = json.encode(table)
  file.WriteAllText(filePath, json_text)
end

local jsonUtil = {
  LoadJSON = loadJSON,
  SaveJSON = saveJSON
}

return jsonUtil