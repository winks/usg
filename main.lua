local utils = require("utils")
local world = require("world")
local people = require("people")

function love.load()
  -- change me
  GLOB = {
    DEBUG = true,
    win_size_x = 800,
    win_size_y = 600,
    font_size = 20,
    size_x = 3,
    size_y = 3,
    img_h = 150,
    img_w = 150,
    margin_x = 40,
    margin_y = 20,

    menu_w = 200,
    menu_color_bg = {0, 153, 255, 255},

    header_h = 30,
    header_color_bg = {64, 64, 64, 255},
  }

  -- don't change me
  state = {
    tick = 0,
    selected = {},
    ship = {},
    resources = {
      power = {
        amount = 0,
        rate = 0,
      },
    },
  }
  local win_flags = {resizable = false}

  -- init love
  love.window.setMode(GLOB.win_size_x, GLOB.win_size_y, win_flags)

  -- game world TEST
  chars = {}
  one = people.generate()
  --people.show_person(one)
  chars[#chars+1] = one
  people.show_person(chars[1])
  print("")

  state.ship = world.gen_ship(GLOB.size_x, GLOB.size_y)
  --world.print_ship(ship)
  --print("")

  ret = world.assign(state.ship, 1, 1, one)
  utils.dbg(world.get_assigned(state.ship))

  world.print_ship(state.ship, true)

  rates = world.get_rates(state.ship)
  print("RATES:")
  utils.dbg(rates)
  world.update_rates(state, rates)

  print("")

  -- init images for rooms
  images = {}
  local img_x = GLOB.menu_w + GLOB.margin_x
  local img_y = GLOB.margin_y * 2

  for x = 1, GLOB.size_x do
    images[x] = {}
    for y = 1, GLOB.size_y do
      xx = img_x + (x-1) * ( GLOB.margin_x + GLOB.img_h )
      yy = img_y + (y-1) * ( GLOB.margin_y + GLOB.img_w )
      images[x][y] = {
        back = love.graphics.newImage("assets/back.jpg"),
        xx = xx,
        yy = yy,
      }
      --print_debug("xx " .. xx)
      --print_debug("yy " .. yy)
    end
  end

end

function love.draw()
  draw_header()
  draw_menu()

  print_tick(utils.round2(state.tick))
  print_resources(state)

  for x = 1, #images do
    for y = 1, #images[1] do
      love.graphics.draw(images[x][y].back, images[x][y].xx, images[x][y].yy)
    end
  end

  print_coords(state)
  print_names(state)
  print_people(state)
  print_selected(state)
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

function love.mousepressed(x, y, button)
  if button == 1 then
    local v
    for i = 1, #state.ship do
      for j = 1, #state.ship[1] do
        v = images[i][j]
        x2 = v.xx + GLOB.img_w
        y2 = v.yy + GLOB.img_h
        if x >= v.xx and x <= x2 and y >= v.yy and y <= y2 then
          print_debug("click: " .. i .. "," .. j)
          state.selected = {i, j}
        end
      end
    end
  end
end

-- own stuff
function draw_header()
  local x = 0
  local y = 0
  local h = GLOB.header_h
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(GLOB.header_color_bg)
  love.graphics.rectangle("fill", x, y, GLOB.win_size_x, h)
  love.graphics.setColor({r, g, b, a})
end

function draw_menu()
  local x = 5
  local y = GLOB.header_h + 5
  local w = GLOB.menu_w
  local h = GLOB.win_size_y - y - 5
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(GLOB.menu_color_bg)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor({r, g, b, a})
end

function print_centered(text, y_offset)
  if not y_offset then
    y_offset = -1 * GLOB.font_size
  end
  love.graphics.printf(text, 0, (GLOB.win_size/2)+y_offset, GLOB.win_size, 'center')
end

function print_tick(text)
  if not GLOB.DEBUG then
    return
  end
  x = GLOB.win_size_x - 60
  y = GLOB.win_size_y - 50
  text = string.format("Tick: %s", text)
  love.graphics.printf(text, x, y, 50, 'right')
end

function print_selected(state)
  local offset_x = GLOB.img_w - 30
  local offset_y = GLOB.img_h - 30
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      if x == state.selected[1] and y == state.selected[2] then
        local xx = images[x][y].xx + offset_x
        local yy = images[x][y].yy + offset_y
        love.graphics.printf("SEL", xx, yy, 50, 'right')
        return
      end
    end
  end
end

function print_names(state)
  local offset_x = 5
  local offset_y = 5
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      room = state.ship[x][y]
      if room.kind ~= 'empty' then
        info = world.seed_rooms[room.kind]
        text = string.format("%s\n(Level %s)", info.name, info.level)
        local xx = images[x][y].xx + offset_x
        local yy = images[x][y].yy + offset_y
        love.graphics.printf(text, xx, yy, GLOB.img_w, 'left')
      end
    end
  end
end

function print_people(state)
  local offset_x = 5
  local offset_y = 5
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      room = state.ship[x][y]
      if room.kind ~= 'empty' then
        if #room.people > 0 then
          text = ""
          local xx = images[x][y].xx + offset_x
          local yy = images[x][y].yy + GLOB.img_h - (14 * #room.people)
          for i = 1, #room.people do
            text = text .. room.people[i].name .. "\n"
          end
          love.graphics.printf(text, xx, yy, GLOB.img_w, 'left')
        end
      end
    end
  end

end

function print_coords(state)
  if not GLOB.DEBUG then
    return
  end
  local offset_x = 30
  local offset_y = 15
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      text = string.format("[%s,%s]", x, y)
      local xx = images[x][y].xx
      local yy = images[x][y].yy
      --love.graphics.printf(text, xx, yy, offset_x, 'left')
      love.graphics.printf(text, xx + GLOB.img_w - offset_x,
                           yy + GLOB.img_h - offset_y, offset_x, 'right')
    end
  end
end

function print_resources(state)
  power = state.resources.power.amount
  text = string.format("[Power: %d]", power)
  x = 5
  y = 5
  love.graphics.printf(text, x, y, (GLOB.win_size_x/2), 'left')
end

function print_debug(text)
  if GLOB.DEBUG then
    print(text)
  end
end

