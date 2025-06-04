-- Observer.lua
local Observer = {}
Observer.__index = Observer

function Observer:new()
  local o = { listeners = {} }
  return setmetatable(o, Observer)
end

function Observer:subscribe(eventName, callback)
  if not self.listeners[eventName] then
    self.listeners[eventName] = {}
  end
  table.insert(self.listeners[eventName], callback)
end

function Observer:notify(eventName, ...)
  local list = self.listeners[eventName]
  if not list then return end
  for _, fn in ipairs(list) do
    fn(...)
  end
end

return Observer
