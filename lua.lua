--- @type Mq
local mq = require 'mq'
local file = require('utils/file')
local luaTableConverter = require('utils/lua-table-converter')

---@class RunningDir
local RunningDir = {scriptPath = ''}

---@return RunningDir
function RunningDir:new()
  self.__index = self
  local o = setmetatable({}, self)
  o.scriptPath = (debug.getinfo(2, "S").source:sub(2)):match("(.*[\\|/]).*$")
  return o
end

function RunningDir:AppendToPackagePath()
  local package_path_inc = self.scriptPath .. '?.lua'
  if not string.find(package.path, package_path_inc) then
      package.path = package_path_inc .. ';' .. package.path
  end
end

function RunningDir:RelativeToMQLuaPath()
  local relativeUrl = (self.scriptPath:sub(0, #mq.luaDir) == mq.luaDir) and self.scriptPath:sub(#mq.luaDir+1) or self.scriptPath
  if string.sub(relativeUrl, -1, -1) == "/" then
    relativeUrl=string.sub(relativeUrl, 1, -2)
  end

  if string.sub(relativeUrl, 1, 1) == "\\" then
    relativeUrl=string.sub(relativeUrl, 2)
  end

  return relativeUrl
end

function RunningDir:GetRelativeToMQLuaPath(subDir)
  local relativeUrl = self:RelativeToMQLuaPath()
  return relativeUrl.."/"..subDir
end

function RunningDir:Parent()
  local immutable = RunningDir:new()
  immutable.scriptPath = immutable.scriptPath:gsub('([a-zA-Z0-9]*)/$', '')
  return immutable
end

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

---@param t1 table
---@param t2 table
---@return table
local function tableConcat(t1,t2)
  for i=1,#t2 do
      t1[#t1+1] = t2[i]
  end
  return t1
end

local utils = {
  LeftJoin = leftJoin,
  Split = split,
  LoadTable = loadTable,
  SaveTable = saveTable,
  RunningDir = RunningDir,
  TableConcat = tableConcat
}

return utils
