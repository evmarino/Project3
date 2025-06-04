-- Deck.lua
local Card = require "Card"

Deck = {}
Deck.__index = Deck


local function makeAbility(rawText)
  if not rawText or rawText:match("^%s*$") then
    return nil
  end

  if rawText:sub(1, 14) == "When Revealed:" then
    local abilityTxt = rawText:sub(16):match("^%s*(.+)$")
    return function(selfCard, gameManager, locationId)
      -- ZEUS
      if abilityTxt == "Lower the power of each card in your opponent's hand by 1." then
        local opp = (selfCard.owner == gameManager.players[1])
                    and gameManager.players[2]
                    or gameManager.players[1]
        for _, c in ipairs(opp.hand) do
          c.power = math.max(0, c.power - 1)
        end

      -- ARES
      elseif abilityTxt == "Gain +2 power for each enemy card here." then
        local loc = gameManager.locations[locationId]
        local count = 0
        for _, entry in ipairs(loc.staged) do
          if entry.player ~= selfCard.owner then
            count = count + 1
          end
        end
        selfCard.power = selfCard.power + 2 * count

      -- MEDUSA
      elseif abilityTxt == "When ANY other card is played here, lower that card's power by 1." then
        selfCard._onAnyCardPlayedHere = true

      -- CYCLOPS
      elseif abilityTxt == "Discard your other cards here; gain +2 power for each discarded." then
        local loc = gameManager.locations[locationId]
        local toDiscard = {}
        for _, entry in ipairs(loc.staged) do
          if entry.card ~= selfCard
             and entry.player == selfCard.owner then
            table.insert(toDiscard, entry.card)
          end
        end
        for _, dc in ipairs(toDiscard) do
          dc.zone = "discard"
          table.insert(dc.owner.discard, dc)
          for i, e in ipairs(loc.staged) do
            if e.card == dc then
              table.remove(loc.staged, i)
              break
            end
          end
          selfCard.power = selfCard.power + 2
        end

      -- POSEIDON
      elseif abilityTxt == "Move away an enemy card here with the lowest power." then
        local loc = gameManager.locations[locationId]
        local lowest, victimEntry = math.huge, nil
        for _, entry in ipairs(loc.staged) do
          if entry.player ~= selfCard.owner
             and entry.card.power < lowest then
            lowest = entry.card.power
            victimEntry = entry
          end
        end
        if victimEntry then
          local victim = victimEntry.card
          victim.zone = "hand"
          table.insert(victim.owner.hand, victim)
          for i, e in ipairs(loc.staged) do
            if e == victimEntry then
              table.remove(loc.staged, i)
              break
            end
          end
        end

      -- ARTEMIS
      elseif abilityTxt == "Gain +5 power if there is exactly one enemy card here." then
        local loc = gameManager.locations[locationId]
        local count = 0
        for _, entry in ipairs(loc.staged) do
          if entry.player ~= selfCard.owner then count = count + 1 end
        end
        if count == 1 then
          selfCard.power = selfCard.power + 5
        end

      -- HERA
      elseif abilityTxt == "Give all cards in your hand +1 power." then
        for _, c in ipairs(selfCard.owner.hand) do
          c.power = c.power + 1
        end

      -- DEMETER
      elseif abilityTxt == "Both players draw one card." then
        for _, p in ipairs(gameManager.players) do
          if #p.hand < 7 and not p.deckObj:isEmpty() then
            local c = p.deckObj:drawOne()
            c.owner = p
            c.zone = "hand"
            table.insert(p.hand, c)
            p.observer:notify("handChanged", p.hand)
          end
        end

      -- HADES
      elseif abilityTxt == "Gain +2 power for each card in your discard pile." then
        local dcount = #selfCard.owner.discard
        selfCard.power = selfCard.power + 2 * dcount

      -- HERCULES
      elseif abilityTxt == "If you are the strongest card here, double your power." then
        local loc = gameManager.locations[locationId]
        local maxP = 0
        for _, entry in ipairs(loc.staged) do
          if entry.card.power > maxP then
            maxP = entry.card.power
          end
        end
        if selfCard.power >= maxP then
          selfCard.power = selfCard.power * 2
        end
      end
    end

  elseif rawText:sub(1, 12) == "End of Turn:" then
    local abilityTxt = rawText:sub(14):match("^%s*(.+)$")
    return function(selfCard, gameManager, locationId)
      if abilityTxt == "Loses 1 power if not winning this location." then
        local loc = gameManager.locations[locationId]
        local totals = loc:calculatePower()
        local myP = totals[selfCard.owner] or 0
        local opponent = (selfCard.owner == gameManager.players[1])
                         and gameManager.players[2]
                         or gameManager.players[1]
        local oppP = totals[opponent] or 0
        if myP <= oppP then
          selfCard.power = math.max(0, selfCard.power - 1)
        end

      elseif abilityTxt == "Gains +1 power, but is discarded when its power is greater than 7." then
        selfCard.power = selfCard.power + 1
        if selfCard.power > 7 then
          selfCard.zone = "discard"
          table.insert(selfCard.owner.discard, selfCard)
          local loc = gameManager.locations[locationId]
          for i, entry in ipairs(loc.staged) do
            if entry.card == selfCard then
              table.remove(loc.staged, i)
              break
            end
          end
        end
      end
    end
  end

  return nil
end

function Deck:new(cardList)
  local d = setmetatable({}, Deck)
  d.cards = {}
  for _, data in ipairs(cardList) do
    local costNum  = tonumber(data.cost)  or 0
    local powerNum = tonumber(data.power) or 0
    local c = Card:new(data.name, costNum, powerNum, data.text)
    c.ability = makeAbility(data.text)
    table.insert(d.cards, c)
  end
  return d
end

function Deck:shuffle()
  for i = #self.cards, 2, -1 do
    local j = love.math.random(i)
    self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
  end
end

function Deck:drawOne()
  return table.remove(self.cards)
end

function Deck:isEmpty()
  return #self.cards == 0
end

return Deck

