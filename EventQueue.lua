-- EventQueue.lua
local EventQueue = {}
EventQueue.__index = EventQueue

function EventQueue:new()
  local eq = {
    queue = {}  
  }
  return setmetatable(eq, EventQueue)
end

function EventQueue:pushEvent(delay, fn)
  table.insert(self.queue, { time = delay, fn = fn })
end

function EventQueue:update(dt)
  for i = #self.queue, 1, -1 do
    local e = self.queue[i]
    e.time = e.time - dt
    if e.time <= 0 then
      e.fn()
      table.remove(self.queue, i)
    end
  end
end

return EventQueue

