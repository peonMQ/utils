---@class EnumValue
---@field value number
---@field name string

local function Enum(definition)
  local enum = {}
  local reverse = {}

  for name, value in pairs(definition) do
    local obj = setmetatable({
      value = value,
      name = name,
    }, {
      __tostring = function(self)
        return self.name
      end,

      -- allow numeric comparisons
      __eq = function(a, b)
        return a.value == b.value
      end,

      __lt = function(a, b)
        return a.value < b.value
      end,

      __le = function(a, b)
        return a.value <= b.value
      end,

      -- allow arithmetic if you really want it
      __add = function(a, b)
        return a.value + (type(b) == "number" and b or b.value)
      end,

      __sub = function(a, b)
        return a.value - (type(b) == "number" and b or b.value)
      end,
    })

    enum[name] = obj
    reverse[value] = obj
  end

  -- lookup by numeric value
  return setmetatable(enum, {
    __call = function(_, value)
      return reverse[value]
    end
  })
end


return Enum