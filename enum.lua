local function Enum(definition)
  local enum = {}
  local reverse = {}

  -- enum value metatable (shared)
  local ENUM_VALUE_MT = {
    __tostring = function(self)
      return self.name
    end,

    __eq = function(a, b)
      return a.value == b.value
    end,

    __newindex = function()
      error("Enum values are read-only", 2)
    end,
  }

  for name, value in pairs(definition) do
    local obj = {
      value = value,
      name = name,
      enum = enum,
    }

    setmetatable(obj, ENUM_VALUE_MT)

    rawset(enum, name, obj)
    reverse[value] = obj
  end

  -- enum container metatable
  return setmetatable(enum, {
    __enum = true,

    __call = function(_, value)
      return reverse[value]
    end,

    __newindex = function()
      error("Enum tables are read-only", 2)
    end,

    __pairs = function()
      return pairs(enum)
    end,
  })
end

return Enum