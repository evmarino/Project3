-- AI.lua
local Player = require "Player"

-- Make AI inherit from Player
AI = setmetatable({}, { __index = Player })
AI.__index = AI

function AI:new(name)
  
  local a = Player:new(name, false)
 
  return setmetatable(a, AI)
end

function AI:choosePlays(gameManager, turnNumber)
  local changed = true
  while changed do
    changed = false
    -- Shuffle
    local indices = {}
    for i = 1, #self.hand do indices[#indices + 1] = i end
    for i = #indices, 2, -1 do
      local j = love.math.random(i)
      indices[i], indices[j] = indices[j], indices[i]
    end

    for _, handIdx in ipairs(indices) do
      local c = self.hand[handIdx]
      if c and tonumber(c.cost) <= self.mana then
        local locId = love.math.random(1, 3)
        if self:tryPlayCard(handIdx, locId, gameManager) then
          changed = true
          break
        end
      end
    end
  end
  self.submitted = true
end

return AI
