-- GameManager.lua

local GameManager = {}
GameManager.__index = GameManager

GameManager.STATE_PLAYING   = 1
GameManager.STATE_REVEAL    = 2
GameManager.STATE_SCORING   = 3
GameManager.STATE_GAMEOVER  = 4

function GameManager:new(params)
  local gm = {
    players      = params.players,      
    locations    = params.locations,    
    eventQueue   = params.eventQueue,   
    winningScore = params.winningScore or 20,
    turnNumber   = 1,
    state        = GameManager.STATE_PLAYING
  }
  return setmetatable(gm, GameManager)
end

function GameManager:startNewGame()
  local CardData = require "CardData"

  -- resets both players
  for _, p in ipairs(self.players) do
    p.hand    = {}
    p.points  = 0
    p.discard = {}
    p:initializeDeck(CardData)
    
    -- draw initial 3 cards
    for i = 1, 3 do
      if not p.deckObj:isEmpty() then
        local c = p.deckObj:drawOne()
        c.owner = p
        c.zone = "hand"
        table.insert(p.hand, c)
      end
    end
    p.observer:notify("handChanged", p.hand)
    p.observer:notify("pointsChanged", p.points)
  end

  -- clear staged cards
  for _, loc in ipairs(self.locations) do
    loc.staged = {}
  end

  self.turnNumber = 1
  self.state      = GameManager.STATE_PLAYING

  -- give each player their turn’s card draw + mana
  for _, p in ipairs(self.players) do
    p:startTurn(self.turnNumber)
  end
end

-- called when player clicks “Submit”
function GameManager:processSubmitPhase()
 
  local ai = self.players[2]
  ai:choosePlays(self, self.turnNumber)

  local delay = 0.2
  for _, loc in ipairs(self.locations) do
    delay = loc:revealAll(self.eventQueue, delay)
  end

  self.state = GameManager.STATE_REVEAL
end

function GameManager:scoreRound()

  for _, loc in ipairs(self.locations) do
    local totals = loc:calculatePower()
    local p1     = totals[self.players[1]] or 0
    local p2     = totals[self.players[2]] or 0
    if p1 > p2 then
      local diff = p1 - p2
      self.players[1].points = self.players[1].points + diff
      self.players[1].observer:notify("pointsChanged", self.players[1].points)

    elseif p2 > p1 then
      local diff = p2 - p1
      self.players[2].points = self.players[2].points + diff
      self.players[2].observer:notify("pointsChanged", self.players[2].points)

    else
      -- flip coin for +1 if a tie
      if love.math.random() < 0.5 then
        self.players[1].points = self.players[1].points + 1
        self.players[1].observer:notify("pointsChanged", self.players[1].points)
      else
        self.players[2].points = self.players[2].points + 1
        self.players[2].observer:notify("pointsChanged", self.players[2].points)
      end
    end
  end

  -- move all staged cards to discard
  for _, loc in ipairs(self.locations) do
    loc:clearStaged()
  end

  -- checks for a winner
  local winner = self:checkWinCondition()
  if winner then
    self.state = GameManager.STATE_GAMEOVER
    return
  end

  -- next turn
  self.turnNumber = self.turnNumber + 1
  self.state      = GameManager.STATE_PLAYING
  for _, p in ipairs(self.players) do
    p:startTurn(self.turnNumber)
  end
end

function GameManager:checkWinCondition()
  local p1 = self.players[1].points
  local p2 = self.players[2].points
  if p1 >= self.winningScore or p2 >= self.winningScore then
    if p1 > p2 then return self.players[1]
    elseif p2 > p1 then return self.players[2]
    else return nil end
  end
  return nil
end

function GameManager:update(dt)
  if self.state == GameManager.STATE_PLAYING then

    if self.players[1].submitted and self.players[2].submitted then
      self:processSubmitPhase()
    end

  elseif self.state == GameManager.STATE_REVEAL then
  
    if #self.eventQueue.queue == 0 then
      self.state = GameManager.STATE_SCORING
    end

  elseif self.state == GameManager.STATE_SCORING then
    self:scoreRound()

  elseif self.state == GameManager.STATE_GAMEOVER then
    -- idle until "play again"
  end
end

function GameManager:draw()
  -- draw each of the locations
  for i, loc in ipairs(self.locations) do
    local x = (i - 1) * 300 + 100
    local y = 150
    loc:draw(x, y)
  end

  -- draw card hand at bottom
  self.players[1]:drawHandUI(50, 580)

  -- Display turn number
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Turn: " .. self.turnNumber, 900, 50)
end

-- debug helper to skip phases with keypress
function GameManager:forceNextPhase()
  if self.state == GameManager.STATE_PLAYING then
    self:processSubmitPhase()

  elseif self.state == GameManager.STATE_REVEAL then
    self.eventQueue.queue = {}
    self.state = GameManager.STATE_SCORING

  elseif self.state == GameManager.STATE_SCORING then
    local winner = self:checkWinCondition()
    if winner then
      self.state = GameManager.STATE_GAMEOVER
    else
      self.turnNumber = self.turnNumber + 1
      self.state      = GameManager.STATE_PLAYING
      for _, p in ipairs(self.players) do
        p:startTurn(self.turnNumber)
      end
    end

  else
    self:startNewGame()
  end
end

return setmetatable(GameManager, GameManager)

