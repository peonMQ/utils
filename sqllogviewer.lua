local mq = require 'mq'
local sqllogger = require 'utils/sqllogger'
local debug = require 'utils/debug'
local imgui = require 'ImGui'

-- see MQ2ImGuiConsole.cpp linenumber 174
local loglevels = {
  [1]  = { color = {0,   1, 1, 1}, abbreviation = '[TRACE]' },
  [2]  = { color = {1,   0, 1, 1}, abbreviation = '[DEBUG]' },
  [3]  = { color = {0,   0, 1, 1}, abbreviation = '[INFO]'  },
  [4]  = { color = {1,   1, 0, 1}, abbreviation = '[WARN]'  },
  [5]  = { color = {1, 0.6, 0, 1}, abbreviation = '[ERROR]' },
  [6]  = { color = {1,   0, 0, 1}, abbreviation = '[FATAL]' },
  [7]  = { color = {1,   1, 1, 1}, abbreviation = '[HELP]'  },
}

local selected_character = 0
local selected_character_name = ""

local showTrace = true
local showDebug = true
local showInfo = true
local showWarn = true
local showError = true
local showFatal = true
local showHelp = true

local characters = {}
local comboOptions = ""

local function updateCharacters()
  local foundPreviousSelected = false
  characters = sqllogger.GetCharacters()
  comboOptions = ""
  for i,name in ipairs(characters) do
    comboOptions = comboOptions..name.."\0"
    if name == selected_character_name then
      selected_character = i-1
      foundPreviousSelected = true
    end
  end

  if not foundPreviousSelected then
    selected_character = 0
    selected_character_name = characters[selected_character+1]
  end
end

updateCharacters()

local logRows = {}
local function updateLogData()
  local searchLevels = {}
  if showTrace then
    table.insert(searchLevels, 1)
  end

  if showDebug then
    table.insert(searchLevels, 2)
  end

  if showInfo then
    table.insert(searchLevels, 3)
  end

  if showWarn then
    table.insert(searchLevels, 4)
  end

  if showError then
    table.insert(searchLevels, 5)
  end

  if showFatal then
    table.insert(searchLevels, 6)
  end

  if showHelp then
    table.insert(searchLevels, 7)
  end

  if next(searchLevels) then
  logRows = sqllogger.GetLatest(characters[selected_character+1], table.concat(searchLevels, ","))
  else
    logRows = sqllogger.GetLatest(characters[selected_character+1])
  end
end

local function GetLevelColor(level)
  return unpack(loglevels[level].color)
end

local openGUI = true
local shouldDrawGUI = true
local terminate = false

local ColumnID_Character = 0
local ColumnID_Level = 1
local ColumnID_Message = 2

-- ImGui main function for rendering the UI window
local renderLogViewer = function()
  openGUI, shouldDrawGUI = imgui.Begin('Log Event Viewer', openGUI)
  imgui.SetWindowSize(430, 277, ImGuiCond.FirstUseEver)
  if shouldDrawGUI then

    selected_character = imgui.Combo('##Character', selected_character, comboOptions)
    selected_character_name = characters[selected_character+1]
    imgui.SameLine()
    if imgui.Button("Delete") then
      sqllogger.Delete(selected_character_name)
    end
 
    showTrace, _ = imgui.Checkbox('Trace', showTrace)
    imgui.SameLine()
    showDebug, _ = imgui.Checkbox('Debug', showDebug)
    imgui.SameLine()
    showInfo, _ = imgui.Checkbox('Info', showInfo)
    imgui.SameLine()
    showWarn, _ = imgui.Checkbox('Warn', showWarn)
    imgui.SameLine()
    showError, _ = imgui.Checkbox('Error', showError)
    imgui.SameLine()
    showFatal, _ = imgui.Checkbox('Fatal', showFatal)
    imgui.SameLine()
    showHelp, _ = imgui.Checkbox('Help', showHelp)

    if imgui.BeginTable('logTable', 3) then
      imgui.TableSetupColumn('Character', ImGuiTableColumnFlags.WidthFixed, -1.0, ColumnID_Character)
      imgui.TableSetupColumn('Level', ImGuiTableColumnFlags.WidthFixed, -1.0, ColumnID_Level)
      imgui.TableSetupColumn('Message', ImGuiTableColumnFlags.WidthFixed, -1.0, ColumnID_Message)
    end

    imgui.TableHeadersRow()

    for _, logRow in ipairs(logRows) do
      imgui.TableNextRow()
      imgui.TableNextColumn()
      imgui.Text(logRow.character)
      imgui.TableNextColumn()
      imgui.PushStyleColor(ImGuiCol.Text, GetLevelColor(logRow.level))
      imgui.Text(loglevels[logRow.level].abbreviation)
      imgui.PopStyleColor(1)
      imgui.TableNextColumn()
      imgui.Text(logRow.message)
    end

    imgui.EndTable()
  end

  imgui.End()

  if not openGUI then
      terminate = true
  end
end

mq.imgui.init('logviewer', renderLogViewer)

while not terminate do
  updateCharacters()
  updateLogData()
  mq.delay(500)
end