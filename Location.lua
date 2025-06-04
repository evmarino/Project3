-- Location.lua
Location = {}
Location.__index = Location

function Location:new(name)
  local loc = {
    name   = name or "Location",
    staged = {} 
  }
  return setmetatable(loc, Location)
end

function Location:stageCard(player, card)
 
  for _, entry in ipairs(self.staged) do
    if entry.card._onAnyCardPlayedHere then
      card.power = math.max(0, card.power - 1)
    end
  end
  card.faceUp = false
  table.insert(self.staged, { player = player, card = card, faceDown = true })
end

-- Reveal all staged cards face down 
function Location:revealAll(eventQueue, startDelay)
  local t = startDelay or 0
  for _, entry in ipairs(self.staged) do
    eventQueue:pushEvent(t, function()
      entry.faceDown    = false
      entry.card.faceUp = true

 
      if entry.card.ability then
        entry.card.ability(entry.card, GameManager, self:getLocationIndex())
      end
    end)
    t = t + 0.5
  end
  return t
end

-- tally power per player at this location
function Location:calculatePower()
  local totals = {}
  for _, entry in ipairs(self.staged) do
    local pl = entry.player
    totals[pl] = (totals[pl] or 0) + entry.card.power
  end
  return totals
end

-- after scoring, discard
function Location:clearStaged()
  for _, entry in ipairs(self.staged) do
    entry.card.zone = "discard"
    table.insert(entry.player.discard, entry.card)
  end
  self.staged = {}
end

function Location:getLocationIndex()
  for i, loc in ipairs(GameManager.locations) do
    if loc == self then return i end
  end
  return nil
end

-- draw location background and cards
function Location:draw(x, y)
  love.graphics.setColor(0.2, 0.2, 0.3)
  love.graphics.rectangle("fill", x, y, 240, 340, 6, 6)

  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(self.name, x, y - 20, 240, "center")

  for i, entry in ipairs(self.staged) do
    local card = entry.card
    local offsetX = (i - 1) * 30
    card.x = x + offsetX
    card.y = y + 20
    if entry.faceDown then
      love.graphics.setColor(0.1, 0.1, 0.1)
      love.graphics.rectangle("fill", card.x, card.y, card.width, card.height, 4, 4)
      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("line", card.x, card.y, card.width, card.height, 4, 4)
    else
      card:draw()
    end
  end
end

return Location


