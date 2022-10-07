
---@class StringBuilder
---@field public Lines string[]
local StringBuilder = {Lines = {}}

---@return StringBuilder
function StringBuilder:new ()
  self.__index = self
  local o = setmetatable({}, self)
  o.Lines = {}
  return o
end

function StringBuilder:Append(string)
  table.insert(self.Lines, string);
end

function StringBuilder:AppendLine(string)
  table.insert(self.Lines, string.."\n");
end

function StringBuilder:__tostring()
  return table.concat(self.Lines,"")
end


return StringBuilder