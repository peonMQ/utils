local file = require('file')
local packageMan = require('mq.PackageMan')

local lyaml = packageMan.Require('lyaml') -- https://github.com/gvvaughan/lyaml

---@generic T : table
---@param filePath string
---@return T
local function loadYAML(filePath)
  local yaml_text = file.ReadAllText(filePath)
  return lyaml.load(yaml_text, { all = true })
end

---@generic T : table
---@param filePath string
---@param table T
local function saveYAML(filePath, table)
  local yaml_text = lyaml.dump(table, { all = true })
  file.WriteAllText(filePath, yaml_text)
end

local yamlUtil = {
  LoadYAML = loadYAML,
  SaveYAML = saveYAML
}

return yamlUtil