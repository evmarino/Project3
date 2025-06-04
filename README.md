# Project3

# Gorgon’s Gambit: A Greek 3CG

## Programming Patterns Used

**Constructor Pattern**  
- **Where:** `Player:new(…)`, `Location:new(…)`, `Card:new(…)`, `Deck:new(…)`, `UI:new(…)`.  
- **How & Why:** Each major object (players, cards, locations, decks, UI manager) is instantiated via a `:new(...)` function that initializes its fields and methods. This eliminates duplicate setup code (e.g. setting a player’s starting hand or a location’s battle state) and ensures every instance is created with the same baseline logic.

**Singleton Pattern**  
- **Where:** The global `GameManager` and the single `EventQueue` module.  
- **How & Why:**  
  - **GameManager** is assigned as a true global (not `local`) so that any module (e.g. `Location.lua`) can refer directly to the same game‐state manager. This ensures there’s exactly one master controller of turns, reveals, scoring, and win/lose logic.  
  - **EventQueue** is a single shared queue of timed callbacks (for card‐reveal animations and ability triggers). Having a single instance avoids passing it around; any module can push or consume events from the same queue.

**Observer Pattern**  
- **Where:** Each `Player` has an `observer` field (an `Observer` instance), and `UI.lua` subscribes to those `observer` events.  
- **How & Why:** Whenever a player’s hand changes, their mana changes, or their point total changes, the player calls `self.observer:notify("handChanged", hand)` or `:notify("manaChanged", mana)` or `:notify("pointsChanged", points)`. The UI code listens for those events to redraw the on‐screen hand, update the mana text, or update the scoreboard. This decouples the game logic (changing the hand array or deducting mana) from the rendering logic that updates the screen.

**Iterator Pattern**  
- **Where:** Loops like `for i, c in ipairs(self.hand) do … end`, `for _, loc in ipairs(self.locations) do … end`, `for _, entry in ipairs(self.staged) do … end`.  
- **How & Why:** Anytime the code needs to traverse all items in a list—draw every card in the player’s hand, stage every card in a location, compute total power at each battlefield—the `ipairs` iterator is used. It makes those loops concise and readable, avoiding manual index bookkeeping.

---

## Postmortem

**What I Did Well**  
- **Clear Separation of Concerns:** I divided the code into well‐defined modules—`Card` for rendering and attributes, `Deck` for shuffle/draw, `Location` for staging and reveals, `Player` for hand/mana/drag‐drop, `AI` inheriting from `Player`, `GameManager` for the overall turn loop, `UI` for on‐screen buttons and overlays, and `EventQueue` for timed animations. This modularity allowed me to debug and test each piece independently.  
- **Immediate Staging on Drag & Drop:** As soon as the human player drops a card into a location, `Player:tryPlayCard` removes it from the hand, deducts mana, and stages it face‐down. This “instant feedback” makes the game feel responsive—cards don’t flicker back into the hand just because Submit hasn’t been clicked yet.  
- **Complete Greek “When Revealed” Abilities:** I implemented ten unique Greek mythology cards (Zeus, Ares, Medusa, Cyclops, Poseidon, Artemis, Hera, Demeter, Hades, Hercules), each with a distinct ability that triggers when flipped. They all behave exactly as described in `CardData.lua`, fulfilling the requirement for at least ten custom cards.

**What I’d Do Differently**  
- **Refine Reveal Animation Management:** Currently, `Location:revealAll` pushes reveal events into a single `EventQueue` with a fixed 0.5‐second increment. In future iterations, I might create a dedicated `RevealManager` (or use a State pattern) to better orchestrate multi‐location reveal timing, especially if more than three locations or conditional reveals are added.  
- **Data‐Driven Layout:** Right now, card front layouts (where name, cost, power, and text appear) are hard‐coded with fixed y‐offsets. I would consider moving those offsets into a JSON or Lua configuration passed into `Card:draw`, so I can tweak font sizes, line breaks, and spacing without touching the drawing code.  
- **Introduce a Factory for Cards:** Instead of a big `makeAbility()` switch in `Deck.lua`, I could apply a Factory pattern that returns a specialized card subclass (e.g. `ZeusCard`) whose `onReveal()` method is defined inline. That would encapsulate each ability directly in its own class, making it easier to add or modify abilities later.

---

## Assets Used

- **Sprites / Images:** None. All card faces, battlefield slots, and buttons are drawn procedurally via Love2D’s `love.graphics.rectangle` and `love.graphics.printf`.  
- **Fonts:** Default Love2D font. No external `.ttf` files were used.  
- **Sound Effects & Music:** None in this version. (Planned for a future update.)  
- **Shaders:** None.  




