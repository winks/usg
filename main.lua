local utils = require("utils")
local world = require("world")
local people = require("people")

function love.load()
  -- change me
  GLOB = {
    DEBUG = true,
    win_size_x = 800,
    win_size_y = 600,
    win_flags = {resizable = false},

    font_size = 20,
    world_size_x = 3,
    world_size_y = 3,

    img_h = 150,
    img_w = 150,

    margin_x = 40,
    margin_y = 20,
    margin_menu = 5,
    margin_selected = 5,
    margin_names = 5,

    menu_w = 200,
    -- light blue
    menu_color_bg = {0, 153, 255, 255},

    header_h = 25,
    -- dark grey
    header_color_bg = {64, 64, 64, 255},
  }

  -- don't change me
  state = {
    -- 1 tick per second
    tick = 0,
    -- coords: {x, y}
    selected = {},
    -- the layout of the player's ship
    ship = {},
    -- all the player's active characters
    chars = {},
    -- the player's current resources and the rate per tick
    resources = {
      power = {
        amount = 0,
        rate = 0,
      },
    },
  }

  -- init love
  love.window.setMode(GLOB.win_size_x, GLOB.win_size_y, GLOB.win_flags)

  -- init game world
  state.chars = {}
  one = people.generate()
  --people.show_person(one)
  state.chars[#state.chars+1] = one
  people.show_person(state.chars[1])
  print("")

  state.ship = world.gen_ship(GLOB.world_size_x, GLOB.world_size_y)
  --world.print_ship(ship)
  --print("")

  local result = world.assign(state.ship, 1, 1, one)
  utils.dbg(world.get_assigned(state.ship))

  world.print_ship(state.ship, true)

  local rates = world.get_rates(state.ship)
  world.update_rates(state, rates)
  print_debug("current rates:")
  utils.dbg(rates)

  print("")

  -- init images for rooms
  images = {}
  local img_x = GLOB.menu_w + GLOB.margin_x
  local img_y = GLOB.margin_y * 2

  for x = 1, GLOB.world_size_x do
    images[x] = {}
    for y = 1, GLOB.world_size_y do
      xx = img_x + (x-1) * ( GLOB.margin_x + GLOB.img_h )
      yy = img_y + (y-1) * ( GLOB.margin_y + GLOB.img_w )
      images[x][y] = {
        src = love.graphics.newImage("assets/back.jpg"),
        xx = xx,
        yy = yy,
      }
      --print_debug("xx " .. xx)
      --print_debug("yy " .. yy)
    end
  end
end

function love.draw()
  draw_header_bg()
  draw_menu_bg()

  print_tick(utils.round2(state.tick))
  print_resources(state)

  for x = 1, #images do
    for y = 1, #images[1] do
      love.graphics.draw(images[x][y].src, images[x][y].xx, images[x][y].yy)
    end
  end

  print_coords(state)
  print_room_names(state)
  print_people(state)
  draw_selected(state)
end

function love.update(dt)
   -- one tick per second
   state.tick = state.tick + dt
   -- update resources, (rate * tick)
   for k, _ in pairs(state.resources) do
     plus = dt * state.resources[k].rate
     state.resources[k].amount = state.resources[k].amount + plus
   end
end

function love.mousepressed(x, y, button)
  -- only left-click
  if button == 1 then
    -- check menu area first
    local m_x1 = GLOB.margin_menu
    local m_x2 = GLOB.margin_menu + GLOB.menu_w
    local m_y1 = GLOB.margin_menu + GLOB.header_h
    local m_y2 = GLOB.win_size_y - GLOB.margin_menu
    if x >= m_x1 and x <= m_x2 and y >= m_y1 and y <= m_y2 then
      print_debug("click: menu @ " .. x .. "," .. y)
      return
    end

    local v
    local match = false
    for i = 1, #state.ship do
      for j = 1, #state.ship[1] do
        v = images[i][j]
        x2 = v.xx + GLOB.img_w
        y2 = v.yy + GLOB.img_h
        if x >= v.xx and x <= x2 and y >= v.yy and y <= y2 then
          print_debug("click: " .. i .. "," .. j)
          state.selected = {i, j}
          match = true
        end
      end
    end

    -- unselect if not in menu and not on room
    if not match then
      state.selected = {}
    end
  end
end

-- own stuff
function draw_header_bg()
  local x = 0
  local y = 0
  local w = GLOB.win_size_x
  local h = GLOB.header_h

  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(GLOB.header_color_bg)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor({r, g, b, a})
end

function draw_menu_bg()
  local x = GLOB.margin_menu
  local y = GLOB.header_h + GLOB.margin_menu
  local w = GLOB.menu_w
  local h = GLOB.win_size_y - y - GLOB.margin_menu

  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(GLOB.menu_color_bg)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor({r, g, b, a})
end

function print_tick(text)
  if not GLOB.DEBUG then
    return
  end
  local x = GLOB.win_size_x - 60
  local y = GLOB.margin_menu
  local text = string.format("Tick: %s", text)
  love.graphics.printf(text, x, y, 50, 'right')
end

function room_infos(state, x, y)
  local room = state.ship[x][y]
  local base = world.seed_rooms[room.kind]

  local text = "Generates [" .. utils.ucfirst(base.resource) .. "]\n"
  text = text .. "Stat: [" .. utils.ucfirst(base.stat) .. "]\n"

  return text
end

-- @TODO onclick
function draw_selected(state)
  local offset_x = GLOB.img_w - 30
  local offset_y = GLOB.img_h - 30
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      if x == state.selected[1] and y == state.selected[2] then
        -- selected room
        local xx = images[x][y].xx
        local yy = images[x][y].yy
        love.graphics.rectangle('line', xx, yy, GLOB.img_w, GLOB.img_h)
        -- selected area in menu
        local mx = GLOB.margin_menu + GLOB.margin_selected
        local my = GLOB.margin_menu + GLOB.margin_selected + GLOB.header_h
        local mw = GLOB.menu_w - (2 * GLOB.margin_menu)
        love.graphics.rectangle('line', mx, my, mw, mw)
        -- contents of menu area
        local text = room_name(state, x, y)
        if text then
          local info = room_infos(state, x, y)
          if info then
            text = text .. "\n\n" .. info
          end
          local ppl = people_names(state, x, y, true)
          if ppl then
            text = text .. "\nAssigned:\n" .. ppl
          end
          love.graphics.printf(text, mx + 3, my + 3, mw, 'left')
        end
        return
      end
    end
  end
end

function room_name(state, x, y)
  local room = state.ship[x][y]
  local text = nil
  if room.kind ~= 'empty' then
    local info = world.seed_rooms[room.kind]
    text = string.format("%s\n(Level %s)", info.name, info.level)
  end
  return text
end

function print_room_names(state)
  local offset_x = GLOB.margin_names
  local offset_y = GLOB.margin_names
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      local text = room_name(state, x, y)
      if text then
        local xx = images[x][y].xx + offset_x
        local yy = images[x][y].yy + offset_y
        love.graphics.printf(text, xx, yy, GLOB.img_w, 'left')
      end
    end
  end
end

function people_names(state, x, y, with_empty)
  local text = nil
  local room = state.ship[x][y]
  local count = 1
  if room.kind ~= 'empty' then
    if #room.people > 0 then
      text = ""
      for i = 1, #room.people do
        text = text .. room.people[i].name .. "\n"
        count = count +1
      end
      if with_empty and count-1 < world.seed_rooms[room.kind].capacity then
        text = text .. "[empty slot]\n"
      end
    elseif with_empty then
      text = ""
      for i = 1, room.capacity do
        text = text .. "[empty slot]\n"
      end
    end
  end
  return text
end

function print_people(state)
  local offset_x = GLOB.margin_names
  local offset_y = GLOB.margin_names
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      local room = state.ship[x][y]
      local text = people_names(state, x, y, false)
      if text then
        local xx = images[x][y].xx + offset_x
        local yy = images[x][y].yy + GLOB.img_h - (14 * #room.people)
        love.graphics.printf(text, xx, yy, GLOB.img_w, 'left')
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
      local text = string.format("[%s,%s]", x, y)
      local xx = images[x][y].xx + GLOB.img_w - offset_x
      local yy = images[x][y].yy + GLOB.img_h - offset_y
      love.graphics.printf(text, xx, yy, offset_x, 'right')
    end
  end
end

function print_resources(state)
  local power = state.resources.power.amount
  local text = string.format("[Power: %d]", power)
  local x = GLOB.margin_menu
  local y = GLOB.margin_menu
  local limit = GLOB.win_size_x/2
  love.graphics.printf(text, x, y, limit, 'left')
end

function print_debug(text)
  if GLOB.DEBUG then
    print(text)
  end
end

