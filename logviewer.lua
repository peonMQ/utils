--- @type Mq
local mq = require 'mq'
local sqllogger = require('utils/sqllogger')
--- @type ImGui
require 'ImGui'

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

local openGUI = true
local shouldDrawGUI = true
local terminate = false

local ColumnID_Character = 0
local ColumnID_Level = 1
local ColumnID_Message = 2

local logRows = {}

local function updateLogData()
  logRows = sqllogger.GetLatest()
end

local function GetLevelColor(level)
  return unpack(loglevels[level].color)
end

-- ImGui main function for rendering the UI window
local renderLogViewer = function()
  openGUI, shouldDrawGUI = ImGui.Begin('Log Event Viewer', openGUI)
  ImGui.SetWindowSize(430, 277, ImGuiCond.FirstUseEver)
  if shouldDrawGUI then
    if ImGui.BeginTable('logTable', 3) then
      ImGui.TableSetupColumn('Character', ImGuiTableColumnFlags.WidthFixed, -1.0, ColumnID_Character)
      ImGui.TableSetupColumn('Level', ImGuiTableColumnFlags.WidthFixed, -1.0, ColumnID_Level)
      ImGui.TableSetupColumn('Message', ImGuiTableColumnFlags.WidthFixed, -1.0, ColumnID_Message)
    end

    ImGui.TableHeadersRow()

    for _, logRow in ipairs(logRows) do
      ImGui.TableNextRow()
      ImGui.TableNextColumn()
      ImGui.Text(logRow.character)
      ImGui.TableNextColumn()
      ImGui.PushStyleColor(ImGuiCol.Text, GetLevelColor(logRow.level))
      ImGui.Text(loglevels[logRow.level].abbreviation)
      ImGui.PopStyleColor(1)
      ImGui.TableNextColumn()
      ImGui.Text(logRow.message)
    end

    ImGui.EndTable()
  end

  ImGui.End()

  if not openGUI then
      terminate = true
  end
end

mq.imgui.init('logviewer', renderLogViewer)

while not terminate do
  updateLogData()
  mq.delay(500)
end