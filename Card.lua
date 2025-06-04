-- Card.lua
CardClass = {}
CardClass.__index = CardClass


function CardClass:new(name, cost, power, text)
  local c = setmetatable({}, CardClass)
  c.name        = name or "Unnamed"
  c.cost        = cost or 0
  c.power       = power or 0
  c.text        = text or ""
  c.owner       = nil         -- assigned when drawn
  c.zone        = "deck"      
  c.faceUp      = false
  c.x, c.y      = 0, 0        -- pixel position for draw/drag
  c.width       = 80
  c.height      = 120
  c.isDragging  = false
  c.dragOffsetX = 0
  c.dragOffsetY = 0
  c.ability     = nil         
  return c
end

function CardClass:draw()
  -- Background
  love.graphics.setColor(0.9, 0.9, 0.95)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 6, 6)

  -- Border
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 6, 6)

  local f = love.graphics.getFont()
  if not f or f:getHeight() ~= 12 then
    love.graphics.setFont(love.graphics.newFont(12))
  end
  love.graphics.setColor(0, 0, 0)

  -- name 
  love.graphics.printf(
    self.name,
    self.x + 4,
    self.y + 4,
    self.width - 8,
    "center"
  )

  -- cost 
  love.graphics.printf(
    "Cost: " .. tostring(self.cost),
    self.x + 4,
    self.y + 50,
    self.width - 8,
    "left"
  )

  -- power 
  love.graphics.printf(
    "Power: " .. tostring(self.power),
    self.x + 4,
    self.y + 60,
    self.width - 8,
    "left"
  )
end

-- returns true if (mx,my) is inside this card’s hitbox
function CardClass:isHovered(mx, my)
  return mx >= self.x
     and mx <= self.x + self.width
     and my >= self.y
     and my <= self.y + self.height
end

return CardClass
