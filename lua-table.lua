---@generic T : table
---@param default T
---@param loaded T
---@return T
local function leftJoin(default, loaded)
  local config = {}
  for key, value in pairs(default) do
    config[key] = value
    local loadedValue = loaded[key]
    if type(value) == "table" then
      if type(loadedValue or false) == "table" then
        if next(value) then
          config[key] = leftJoin(default[key] or {}, loadedValue or {})
        else
          config[key] = loadedValue
        end
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

---@param t1 table
---@param t2 table
---@return table
local function tableConcat(t1,t2)
  for i=1,#t2 do
      t1[#t1+1] = t2[i]
  end
  return t1
end


---@param table table
---@return string
local function getKeysSorted(table)
  if type(table) ~= 'table' then return "" end
  local keyset={}
  for k,v in pairs(table) do
    table.insert(keyset, k)
  end

  table.sort(keyset)
  return table.concat(keyset, ", ")
end

local utils = {
  LeftJoin = leftJoin,
  Split = split,
  TableConcat = tableConcat,
  GetKeysSorted = getKeysSorted
}

return utils
