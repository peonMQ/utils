local mq = require 'mq'

local function printMemberItem(index, member, memberType, memberValue, depth)
   print(string.format('%s%d. %s (%s) [%s]', string.rep('\t',depth), index, member, memberType, tostring(memberValue)))
end

---@param datatype string
---@param dataTypePath string
---@param depth integer
local function listMembers(datatype, dataTypePath, depth)
  for i=1,300 do
    if mq.TLO.Type(datatype).Member(i)() then
      local member = mq.TLO.Type(datatype).Member(i)()
      local memberType = mq.gettype(mq.TLO.Me[member])
      local memberValue = nil
      if dataTypePath then
        memberValue = mq.TLO.Me[dataTypePath][member]()
      elseif mq.TLO.Me[member] then
        memberValue = mq.TLO.Me[member]()
      end
      printMemberItem(i, member, memberType, memberValue, depth)
      listMembers(memberType.Name(), member, depth + 1)
   end
  end
end

---@param node table
---@param printFunctions boolean|nil
local function toStringTable(node, printFunctions)
  local cache, stack, output = {},{},{}
  local depth = 1
  local output_str = "{\n"

  while true do
    local size = 0
    for k,v in pairs(node) do
      size = size + 1
    end

    local cur_index = 1
    for k,v in pairs(node) do
      if (cache[node] == nil) or (cur_index >= cache[node]) then
        if (string.find(output_str,"}",output_str:len())) then
          output_str = output_str .. ",\n"
        elseif not (string.find(output_str,"\n",output_str:len())) then
          output_str = output_str .. "\n"
        end

        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
        table.insert(output,output_str)
        output_str = ""

        local key
        if (type(k) == "number" or type(k) == "boolean") then
          key = "["..tostring(k).."]"
        else
          key = "['"..tostring(k).."']"
        end

        if (type(v) == "number" or type(v) == "boolean") then
          output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
        elseif (type(v) == "table") then
          output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
          table.insert(stack,node)
          table.insert(stack,v)
          cache[node] = cur_index+1
          break
        elseif type(v) ~= "function" or printFunctions then
          output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
        end

        if (cur_index == size) then
          output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        else
          output_str = output_str .. ","
        end
      else
        -- close the table
        if (cur_index == size) then
          output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end
      end

      cur_index = cur_index + 1
    end

    if (size == 0) then
      output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
    end

    if (#stack > 0) then
      node = stack[#stack]
      stack[#stack] = nil
      depth = cache[node] == nil and depth + 1 or depth - 1
    else
      break
    end
  end

  -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
  table.insert(output,output_str)
  output_str = table.concat(output)

  return output_str
end

local function printTable(table)
  print(toStringTable(table))
end

local debug = {
  ListMembers = listMembers,
  ToString = toStringTable,
  PrintTable = printTable
}

return debug