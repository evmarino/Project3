-- Command.lua
local Command = {}
Command.__index = Command

function Command:new(doFunction, undoFunction)
  local cmd = {
    execute = doFunction  or function() end,
    undo    = undoFunction or function() end
  }
  return setmetatable(cmd, Command)
end

return Command
