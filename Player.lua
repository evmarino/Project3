-- Player.lua
local Observer = require "Observer"
local Location = require "Location"

Player = {}
Player.__index = Player

function Player:new(name, isHuman)
  local p = {
    name      = name or "Player",
    isHuman   = (isHuman == true),
    hand      = {},       -- array of card instances
    mana      = 0,
    points    = 0,
    deckObj   = nil,      -- deck instance
    discard   = {},       -- discard pile
    observer  = Observer:new(),
    dragging  = nil,     
    originalX = 0,
    originalY = 0,
    submitted = false
  }
  return setmetatable(p, Player)
end

function Player:initializeDeck(cardList)
  local Deck = require "Deck"
  self.deckObj = Deck:new(cardList)
  self.deckObj:shuffle()
end

function Player:startTurn(turnNumber)
  self.mana = turnNumber
  self.submitted = false
  self.observer:notify("manaChanged", self.mana)

  if #self.hand < 7 and not self.deckObj:isEmpty() then
    local c = self.deckObj:drawOne()
    c.owner = self
    c.zone  = "hand"
    table.insert(self.hand, c)
    self.observer:notify("handChanged", self.hand)
  end
end

function Player:tryPlayCard(idx, locationId, gameManager)
  local c = self.hand[idx]
  if not c then return false end

  -- force cost to number
  local costNum = tonumber(c.cost) or 0
  if costNum > self.mana then
    return false
  end

  -- remove from hand
  table.remove(self.hand, idx)
  self.observer:notify("handChanged", self.hand)

  -- deduct mana
  self.mana = self.mana - costNum
  self.observer:notify("manaChanged", self.mana)

  -- face down staging
  c.zone = "location" .. tostring(locationId)
  gameManager.locations[locationId]:stageCard(self, c)

  -- mark as submitted
  self.submitted = true

  return true
end

-- pick up a card from hand
function Player:mousepressed(mx, my, gameManager)
  if not self.isHuman then return end

  for i, c in ipairs(self.hand) do
    if c:isHovered(mx, my) then
      self.dragging = { card = c, index = i }
      self.originalX = c.x
      self.originalY = c.y
      c.isDragging = true
      c.dragOffsetX = mx - c.x
      c.dragOffsetY = my - c.y
      return
    end
  end
end

--  drop dragged card 
function Player:mousereleased(mx, my, gameManager)
  if not self.isHuman or not self.dragging then return end
  local entry = self.dragging
  local c = entry.card
  c.isDragging = false

  -- Check location rectangles
  for locId, loc in ipairs(gameManager.locations) do
    local x0 = (locId - 1) * 300 + 100
    local y0 = 150
    local x1 = x0 + 240
    local y1 = y0 + 340

    if mx >= x0 and mx <= x1 and my >= y0 and my <= y1 then
      local played = self:tryPlayCard(entry.index, locId, gameManager)
      if not played then
        -- If illegal, snap back
        c.x = self.originalX
        c.y = self.originalY
      end
      self.dragging = nil
      return
    end
  end

  -- snap back to original position if not dropped
  c.x = self.originalX
  c.y = self.originalY
  self.dragging = nil
end

-- player hand 
function Player:drawHandUI(startX, startY)
  for i, c in ipairs(self.hand) do
    c.x = startX + (i - 1) * (c.width + 10)
    c.y = startY
    if not c.isDragging then
      c:draw()
    end
  end
  if self.dragging then
    local dc = self.dragging.card
    dc.x = love.mouse.getX() - dc.dragOffsetX
    dc.y = love.mouse.getY() - dc.dragOffsetY
    dc:draw()
  end
end

return Player
