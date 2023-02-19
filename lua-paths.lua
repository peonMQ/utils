local mq = require('mq')

---@class RunningDir
local RunningDir = {scriptPath = ''}

---@return RunningDir
function RunningDir:new(level)
  self.__index = self
  local o = setmetatable({}, self)
  o.scriptPath = (debug.getinfo(level or 2, "S").source:sub(2)):match("(.*[\\|/]).*$")
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
  return relativeUrl..subDir
end

function RunningDir:Parent()
  local immutable = RunningDir:new(3)
  immutable.scriptPath = immutable.scriptPath:gsub('([a-zA-Z0-9]*)/$', '')
  return immutable
end

local utils = {
  RunningDir = RunningDir,
}

return utils