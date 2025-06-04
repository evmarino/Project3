-- UI.lua
local CardData = require "CardData"

UIClass = {}
UIClass.__index = UIClass

function UIClass:new(params)
  local ui = {
    gm      = params.gameManager,
    players = params.players,
    font    = love.graphics.newFont(18),

    buttonSubmit       = { x = 900, y = 350, w = 100, h = 40, text = "Submit" },
    buttonInstructions = { x = 900, y = 410, w = 100, h = 40, text = "Instructions" },
    buttonPlayAgain    = { x = 400, y = 350, w = 240, h = 60, text = "Play Again" },

    showInstructions = false,
    scrollY          = 0,
    scrollSpeed      = 200
  }
  ui.cardList = CardData
  return setmetatable(ui, UIClass)
end

function UIClass:update(dt)
  if self.showInstructions then
    if love.keyboard.isDown("up") then
      self.scrollY = math.max(self.scrollY - self.scrollSpeed * dt, 0)
    elseif love.keyboard.isDown("down") then
      self.scrollY = self.scrollY + self.scrollSpeed * dt
    end
  end
end

function UIClass:draw()
  love.graphics.setFont(self.font)
  love.graphics.setColor(1, 1, 1)

  if self.showInstructions then
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local bx, by, bw, bh = love.graphics.getWidth() - 120, 20, 100, 40
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", bx, by, bw, bh, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Close", bx, by + 10, bw, "center")

    local baseX = 40
    local baseY = 80 - self.scrollY
    local lineHeight = 24
    love.graphics.setColor(1, 1, 1)
    for i, data in ipairs(self.cardList) do
      local y = baseY + (i - 1) * (lineHeight * 3)
      local header = string.format("%d) %s   (Cost: %d  Power: %d)", i, data.name, data.cost, data.power)
      love.graphics.print(header, baseX, y)
      love.graphics.print(data.text, baseX + 20, y + lineHeight)
    end
    return
  end

  local p1 = self.players[1]
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Mana: " .. p1.mana, 50, 500)
  love.graphics.print("Pts: " .. p1.points, 200, 500)

  local p2 = self.players[2]
  love.graphics.print("AI Pts: " .. p2.points, 50, 20)

  if self.gm.state == self.gm.STATE_PLAYING then
    local b = self.buttonSubmit
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(b.text, b.x, b.y + 12, b.w, "center")
  end

  local bi = self.buttonInstructions
  love.graphics.setColor(0.2, 0.4, 0.8)
  love.graphics.rectangle("fill", bi.x, bi.y, bi.w, bi.h, 6, 6)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(bi.text, bi.x, bi.y + 12, bi.w, "center")

  if self.gm.state == self.gm.STATE_GAMEOVER then
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local winner = self.gm:checkWinCondition()
    local msg = "Tie!"
    if winner == self.players[1] then msg = "You Win!"
    elseif winner == self.players[2] then msg = "You Lose!" end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(msg, 0, love.graphics.getHeight() * 0.3, love.graphics.getWidth(), "center")

    local b = self.buttonPlayAgain
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 8, 8)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(b.text, b.x, b.y + 18, b.w, "center")
  end
end

function UIClass:mousepressed(mx, my)
  if self.showInstructions then
    local bx, by, bw, bh = love.graphics.getWidth() - 120, 20, 100, 40
    if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
      self.showInstructions = false
      self.scrollY = 0
      return true
    end
    return true
  end

  if self.gm.state == self.gm.STATE_PLAYING then
    local b = self.buttonSubmit
    if mx >= b.x and mx <= b.x + b.w
       and my >= b.y and my <= b.y + b.h then
      self.players[1].submitted = true
      if not self.players[2].submitted then
        self.players[2]:choosePlays(self.gm, self.gm.turnNumber)
      end
      return true
    end
  end

  do
    local bi = self.buttonInstructions
    if mx >= bi.x and mx <= bi.x + bi.w
       and my >= bi.y and my <= bi.y + bi.h then
      self.showInstructions = true
      return true
    end
  end

  if self.gm.state == self.gm.STATE_GAMEOVER then
    local b = self.buttonPlayAgain
    if mx >= b.x and mx <= b.x + b.w
       and my >= b.y and my <= b.y + b.h then
      self.gm:startNewGame()
      return true
    end
  end

  return false
end

return UIClass

