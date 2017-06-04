local utils = require("utils")
local world = require("world")
local people = require("people")

function love.load()
  -- change me
  GLOB = {
    DEBUG = true,
    win_size = 600,
    font_size = 20,
  }

  -- don't change me
  state = {
    tick = 0,
    resources = {
      power = {
        amount = 0,
        rate = 0,
      },
    },
  }
  local win_flags = {resizable = false}

  -- init love
  love.window.setMode(GLOB.win_size, GLOB.win_size, win_flags)

  -- game world TEST
  chars = {}
  one = people.generate()
  --people.show_person(one)
  chars[#chars+1] = one
  people.show_person(chars[1])
  print("")

  ship = world.gen_ship(2, 3)
  world.print_ship(ship)
  print("")
  world.print_ship(ship, true)

  ret = world.assign(ship, 1, 1, one)
  print(ret ~= false)
  utils.dbg(world.show_assigned(ship))

  rates = world.get_rates(ship)
  utils.dbg(rates)
  world.update_rates(state, rates)

  print("")
end

function love.draw()
  print_tick(utils.round2(state.tick))
  print_resources(state)
end

function love.update(dt)
   -- one tick per second
   state.tick = state.tick + dt
   -- update resources, (rate * tick)
   for k, v in pairs(state.resources) do
     plus = dt * state.resources[k].rate
     state.resources[k].amount = state.resources[k].amount + plus
   end
end

-- own stuff

function print_centered(text, y_offset)
  if not y_offset then
    y_offset = -1 * GLOB.font_size
  end
  love.graphics.printf(text, 0, (GLOB.win_size/2)+y_offset, GLOB.win_size, 'center')
end

function print_tick(text)
  x = GLOB.win_size - 60
  y = GLOB.win_size - 50
  text = string.format("Tick: %s", text)
  love.graphics.printf(text, x, y, 50, 'right')
end

function print_resources(state)
  power = state.resources.power.amount
  text = string.format("[Power: %d]", power)
  x = 5
  y = 5
  love.graphics.printf(text, x, y, (GLOB.win_size/2), 'left')
end

function print_debug(text)
  if GLOB.DEBUG then
    print(text)
  end
end

