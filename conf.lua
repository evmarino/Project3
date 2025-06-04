 -- conf.lua
function love.conf(t)
  t.window.title   = "Gorgon's Gambit: A Greek 3CG"
  t.window.width   = 1024
  t.window.height  = 768
  t.version        = "11.4"
  t.modules.audio    = true
  t.modules.graphics = true
  t.modules.keyboard = true
  t.modules.mouse    = true
end
