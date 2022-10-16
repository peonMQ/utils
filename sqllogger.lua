local mq = require('mq')
local packageMan = require('mq/PackageMan')
local configLoader = require('utils/configloader')
local debug = require('utils/debug')

local sqlite3 = packageMan.Require('lsqlite3complete')
-- local db = sqlite3.open('file:memlogdb?mode=memory&cache=shared')



local defaultConfig = {
  maxdisplayrows = 20,
  maxcacherows = 100,
}

local config = configLoader("logging.logviewer", defaultConfig)

local configDir = mq.configDir.."/"
local serverName = mq.TLO.MacroQuest.Server()
local db = sqlite3.open(configDir..serverName.."/logDB.sqlite")
db:exec[[
  CREATE TABLE IF NOT EXISTS log (
      id INTEGER PRIMARY KEY
      , character TEXT
      , level INTEGER
      , message TEXT
      , timestamp INTEGER
  );
]]

local function clean()
  local sql = [[
    DELETE FROM log a
      WHERE a.character = '%s' AND a.id NOT IN (
        SELECT b.id FROM log b
          WHERE b.character = '%s'
          ORDER BY b.timestamp DESC LIMIT %d
  )
  ]]
  db:exec(sql:format(mq.TLO.Me.Name(), config.maxcacherows-1))
end

---@return table
local function getCharacters()
  local sql = [[
    SELECT DISTINCT character FROM log 
      ORDER BY character
  ]]

  local characters = {"All"}
  for character in db:urows(sql) do table.insert(characters, character) end
  debug.PrintTable(characters)
  return characters
end

---@return table
local function getLatest(character, logLevels)
  local logRows = {}
  if not character or character == "" or not logLevels or logLevels == "" then
    return logRows
  end

  if character == "All" then
    local sql = [[
      SELECT * FROM log 
        WHERE level IN (%s)
        ORDER BY timestamp DESC 
        LIMIT %d
    ]]

    for logRow in db:nrows(sql:format(logLevels, config.maxdisplayrows)) do table.insert(logRows, 1, logRow) end
    return logRows
  end

  local sql = [[
    SELECT * FROM log 
      WHERE character = '%s' AND level IN (%s)
      ORDER BY timestamp DESC 
      LIMIT %d
  ]]

  for logRow in db:nrows(sql:format(character, logLevels, config.maxdisplayrows)) do table.insert(logRows, 1, logRow) end
  return logRows
end

---@param paramLogLevel integer
---@param logMessage string
local function insert(paramLogLevel, logMessage)
  clean()
  local insertStatement = string.format("INSERT INTO log(character, level, message, timestamp) VALUES('%s', %d, '%s', %d)", mq.TLO.Me.Name(), paramLogLevel, logMessage, os.time())
  db:exec(insertStatement)
end

local sqllogger = {
  GetCharacters = getCharacters,
  GetLatest = getLatest,
  Insert = insert
}

return sqllogger