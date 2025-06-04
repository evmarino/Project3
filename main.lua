-- main.lua

local Card       = require "Card"
local CardData   = require "CardData"
local Deck       = require "Deck"
local EventQueue = require "EventQueue"
local GMclass    = require "GameManager"  
local Location   = require "Location"
local Player     = require "Player"
local AI         = require "AI"
local UIClass    = require "UI"

local eventQueue, player1, player2, locations, UI

function love.load()
  math.randomseed(os.time())


  eventQueue = EventQueue:new()


  player1 = Player:new("You", true)
  player2 = AI:new("ZeusAI")

  -- give each player a shuffled card deck
  player1:initializeDeck(CardData)
  player2:initializeDeck(CardData)

  -- the three “battle” locations
  locations = {
    Location:new("Mount Olympus"),
    Location:new("Underworld"),
    Location:new("Sea of Poseidon")
  }

  GameManager = GMclass:new({
    players      = { player1, player2 },
    locations    = locations,
    eventQueue   = eventQueue,
    winningScore = 15
  })

  UI = UIClass:new({
    gameManager = GameManager,
    players     = { player1, player2 }
  })

  GameManager:startNewGame()
end

function love.update(dt)

  GameManager:update(dt)
  UI:update(dt)
  eventQueue:update(dt)
end

function love.draw()

  GameManager:draw()
  UI:draw()
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end


  if GameManager.state == GameManager.STATE_GAMEOVER then
    if UI:mousepressed(x, y) then return end
    return
  end

  if GameManager.state == GameManager.STATE_PLAYING then
    if UI:mousepressed(x, y) then return end
    player1:mousepressed(x, y, GameManager)
  end
end

function love.mousereleased(x, y, button)
  if button ~= 1 then return end

  player1:mousereleased(x, y, GameManager)
end

-- debug keys 
function love.keypressed(key)
  -- Press n to force the next phase
  if key == "n" then
    GameManager:forceNextPhase()
    return
  end
  -- Press w to force game over 
  if key == "w" then
    GameManager.state = GameManager.STATE_GAMEOVER
    return
  end
end

