--- @type Mq
local mq = require('mq')

--[[ 
\ab = black \ag = green \am = maroon \ao = orange \ap = purple \ar = red \at = cyan (or teal) \au = blue \aw = white \ax = default (which will do whatever the previous color was, the one before the last color change) \ay = yellow

You can put a - in front of any of those, to make it 'dark'. The general effect of it is: \a-b no effect really, still black! \a-g = dark green \a-m = dark maroon \a-o = dark orange (looks brown to me) \a-p = dark purple \a-r = dark red \a-t = dark cyan \a-u = dark blue \a-w = gray \a-x = same as \ax \a-y = dark yellow (looks gold) 
]]


local loglevels = {
  ['trace']  = { level = 1, color = '\at', abbreviation = '[TRACE%s]' },
  ['debug']  = { level = 2, color = '\am', abbreviation = '[DEBUG%s]' },
  ['info']   = { level = 3, color = '\au', abbreviation = '[INFO%s]'  },
  ['warn']   = { level = 4, color = '\ay', abbreviation = '[WARN%s]'  },
  ['error']  = { level = 5, color = '\ao', abbreviation = '[ERROR%s]' },
  ['fatal']  = { level = 6, color = '\ar', abbreviation = '[FATAL%s]' },
  ['help']   = { level = 7, color = '\aw', abbreviation = '[HELP%s]'  },
}

local config = {
  usecolors = true,
  usetimestamp = false,
  loglevel = 'warn',
  separator = '::'
}

local Logger = {}

local function Terminate()
  mq.exit()
end

local function GetColorStart(logLevel)
  if config.usecolors then
      return logLevel.color
  end
  return ''
end

local function GetColorEnd()
    if config.usecolors then
      return '\ax'
    end
    return ''
end

local function GetCallerString(paramLogLevel)
  if loglevels[paramLogLevel:lower()].level > loglevels['debug'].level then
      return ''
  end

  local callString = 'unknown'
  local callerInfo = debug.getinfo(4,'Sl')
  if callerInfo and callerInfo.short_src ~= nil and callerInfo.short_src ~= '=[C]' then
      callString = string.format('%s%s%s', callerInfo.short_src:match("[^\\^/]*.lua$"), config.separator, callerInfo.currentline)
  end

  local callingFunction = ''
  local callerFunctionInfo = debug.getinfo(4, "n")
  if callerFunctionInfo and callerFunctionInfo.name then
    callingFunction = string.format("%s%s", config.separator, callerFunctionInfo.name)
  end

  return string.format('\a <%s%s> ', callString, callingFunction)
end

local function GetAbbreviation(logLevel)
  local abbreviation
  if config.usetimestamp then
    abbreviation = string.format(logLevel.abbreviation, config.separator..os.date("%X"))
  else
    abbreviation = string.format(logLevel.abbreviation, "")
  end

  return string.format("%s%s%s", GetColorStart(logLevel), abbreviation, GetColorEnd())
end


local function Output(paramLogLevel, message, ...)
  local logLevel = loglevels[paramLogLevel]
  if loglevels[config.loglevel:lower()].level <= logLevel.level then
    local logMessage = string.format(message, ...)
    print(string.format('%s %s %s %s', GetAbbreviation(logLevel), config.separator, logMessage, GetCallerString(paramLogLevel)))
    mq.delay(50)
  end
end

---@param message string
---@param ... string|integer
function Logger.Debug(message, ...)
  Output('debug', message, ...)
end

---@param message string
---@param ... string|integer
function Logger.Info(message, ...)
  Output('info', message, ...)
end

---@param message string
---@param ... string|integer
function Logger.Warn(message, ...)
  Output('warn', message, ...)
end

---@param message string
---@param ... string|integer
function Logger.Error(message, ...)
  Output('error', message, ...)
end

---@param message string
---@param ... string|integer
function Logger.Fatal(message, ...)
  Output('fatal', message, ...)
  Terminate()
end

return Logger
