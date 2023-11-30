--- @type StringBuilder
local stringBuilder = require 'utils/stringbuilder'

local write, writeIndent, writers, refCount

local converter =
{
	toString = function (...)
		local stringbuilder = stringBuilder:new()
		local n = select("#", ...)
		-- Count references
		local objRefCount = {} -- Stores reference that will be exported
		for i = 1, n do
			refCount(objRefCount, (select(i,...)))
		end
		-- Export Objects with more than one ref and assign name
		-- First, create empty tables for each
		local objRefNames = {}
		local objRefIdx = 0
		stringbuilder:Append("-- Persistent Data\n")
		stringbuilder:Append("local multiRefObjects = {\n")
		for obj, count in pairs(objRefCount) do
			if count > 1 then
				objRefIdx = objRefIdx + 1
				objRefNames[obj] = objRefIdx
				stringbuilder:Append("{};") -- table objRefIdx
			end
		end
		stringbuilder:Append("\n} -- multiRefObjects\n")
		-- Then fill them (this requires all empty multiRefObjects to exist)
		for obj, idx in pairs(objRefNames) do
			for k, v in pairs(obj) do
				stringbuilder:Append("multiRefObjects["..idx.."][")
				write(stringbuilder, k, 0, objRefNames)
				stringbuilder:Append("] = ")
				write(stringbuilder, v, 0, objRefNames)
				stringbuilder:Append(";\n")
			end
		end
		-- Create the remaining objects
		for i = 1, n do
			stringbuilder:Append("local ".."obj"..i.." = ")
			write(stringbuilder, (select(i,...)), 0, objRefNames)
			stringbuilder:Append("\n")
		end
		-- Return them
		if n > 0 then
			stringbuilder:Append("return obj1")
			for i = 2, n do
				stringbuilder:Append(" ,obj"..i)
			end
			stringbuilder:Append("\n")
		else
			stringbuilder:Append("return\n")
		end

		return tostring(stringbuilder)
	end,

	fromString = function (tableString)
		if tableString and tableString ~= "" then
			return tableString()
		end

		return {}
	end
}

-- Private methods

-- write thing (dispatcher)
write = function (stringbuilder, item, level, objRefNames)
	writers[type(item)](stringbuilder, item, level, objRefNames)
end

-- write indent
writeIndent = function (stringbuilder, level)
	for i = 1, level do
		stringbuilder:Append("\t")
	end
end

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1
		else
			objRefCount[item] = 1
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k)
				refCount(objRefCount, v)
			end
		end
	end
end

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (stringbuilder, item)
			stringbuilder:Append("nil")
		end,
	["number"] = function (stringbuilder, item)
			stringbuilder:Append(tostring(item))
		end,
	["string"] = function (stringbuilder, item)
			stringbuilder:Append(string.format("%q", item))
		end,
	["boolean"] = function (stringbuilder, item)
			if item then
				stringbuilder:Append("true")
			else
				stringbuilder:Append("false")
			end
		end,
	["table"] = function (stringbuilder, item, level, objRefNames)
			local refIdx = objRefNames[item]
			if refIdx then
				-- Table with multiple references
				stringbuilder:Append("multiRefObjects["..refIdx.."]")
			else
				-- Single use table
				stringbuilder:Append("{\n")
				for k, v in pairs(item) do
					writeIndent(stringbuilder, level+1)
					stringbuilder:Append("[")
					write(stringbuilder, k, level+1, objRefNames)
					stringbuilder:Append("] = ")
					write(stringbuilder, v, level+1, objRefNames)
					stringbuilder:Append(";\n")
				end
				writeIndent(stringbuilder, level)
				stringbuilder:Append("}")
			end
		end,
	["function"] = function (stringbuilder, item)
			-- Does only work for "normal" functions, not those
			-- with upvalues or c functions
			local dInfo = debug.getinfo(item, "uS")
			if dInfo.nups > 0 then
				stringbuilder:Append("nil --[[functions with upvalue not supported]]")
			elseif dInfo.what ~= "Lua" then
				stringbuilder:Append("nil --[[non-lua function not supported]]")
			else
				local r, s = pcall(string.dump,item)
				if r then
					stringbuilder:Append(string.format("loadstring(%q)", s))
				else
					stringbuilder:Append("nil --[[function could not be dumped]]")
				end
			end
		end,
	["thread"] = function (stringbuilder, item)
			stringbuilder:Append("nil --[[thread]]\n")
		end,
	["userdata"] = function (stringbuilder, item)
			stringbuilder:Append("nil --[[userdata]]\n")
		end
}

-- t_original = {1, 2, ["a"] = "string", b = "test", {"subtable", [4] = 2}}
-- persistence.store("storage.lua", t_original)
-- t_restored = persistence.load("storage.lua")

return converter