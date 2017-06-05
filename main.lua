local utils = require("utils")
local world = require("world")
local people = require("people")

function love.load()
  -- trying to work with as few globals as possible:
  --  * GLOB  - global variables, kind of constant
  --  * UI    - images, buttons, sprites
  --  * state - everything in the game world

  -- change me
  GLOB = {
    DEBUG = true,
    win_size_x = 800,
    win_size_y = 700,
    win_flags = {resizable = false},

    font_size = 16,
    world_size_x = 3,
    world_size_y = 4,

    img_h = 150,
    img_w = 150,

    margin_x = 40,
    margin_y = 10,
    margin_menu = 5,
    margin_selected = 5,
    margin_names = 5,

    chars_w = 75,

    menu_w = 200,
    -- light blue
    menu_color_bg = {0, 153, 255, 255},

    header_h = 25,
    -- dark grey
    header_color_bg = {64, 64, 64, 255},

    new_crew_interval = 10,
  }

  -- don't change me
  state = {
    -- 1 tick per second
    tick = 0,
    tick_crew = 1,
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
    ui = {
      -- coords: {x, y}
      selected = {},
      show_chars = false,
    },
  }

  -- init love
  love.window.setMode(GLOB.win_size_x, GLOB.win_size_y, GLOB.win_flags)

  -- init game world
  state.chars = {}
  local person_one = people.generate()
  state.chars[#state.chars+1] = person_one
  people.print_person(state.chars[1])
  print("")

  state.ship = world.gen_ship(GLOB.world_size_x, GLOB.world_size_y)

  --local result = world.assign(state.ship, 2, 1, person_one)
  utils.dbg(world.get_assigned(state.ship))

  world.print_ship(state.ship, true)

  local rates = world.get_rates(state.ship)
  world.update_rates(state, rates)
  utils.dbg("current rates:")
  utils.dbg(rates)
  print("")

  -- init UI stuff
  UI = {}
  -- init images for rooms
  UI.images = {}
  local img_x = GLOB.menu_w + GLOB.margin_x
  local img_y = GLOB.header_h + GLOB.margin_y

  for x = 1, GLOB.world_size_x do
    UI.images[x] = {}
    for y = 1, GLOB.world_size_y do
      xx = img_x + (x-1) * ( GLOB.margin_x + GLOB.img_h )
      yy = img_y + (y-1) * ( GLOB.margin_y + GLOB.img_w )
      UI.images[x][y] = {
        src = love.graphics.newImage("assets/back.jpg"),
        xx = xx,
        yy = yy,
      }
      --utils.dbg("xx " .. xx)
      --utils.dbg("yy " .. yy)
    end
  end

  UI.btn = {}
  UI.btn.chars = {
    x = 0,
    y = 0,
    w = GLOB.chars_w,
    h = GLOB.header_h,
    bg = {0, 155, 53, 155},
    tx = GLOB.margin_menu,
    ty = GLOB.margin_menu,
    tl = GLOB.chars_w,
    ta = 'left',
  }
  UI.btn.assignedLeft = {
    x = GLOB.margin_menu * 2,
    y = GLOB.menu_w,
    w = (GLOB.menu_w / 2) - GLOB.margin_menu,
    h = GLOB.header_h,
    bg = {0, 55, 53, 155},
    tx = GLOB.margin_menu,
    ty = GLOB.margin_menu,
    tl = GLOB.menu_w / 2,
    ta = 'left',
  }
  UI.btn.assignedRight = {
    x = GLOB.margin_menu + (GLOB.menu_w / 2),
    y = GLOB.menu_w,
    w = (GLOB.menu_w / 2) - GLOB.margin_menu,
    h = GLOB.header_h,
    bg = {0, 35, 53, 155},
    tx = GLOB.margin_menu,
    ty = GLOB.margin_menu,
    tl = GLOB.menu_w / 2,
    ta = 'left',
  }
end

function love.draw()
  -- header area
  drawHeader()
  drawButton(UI.btn.chars, string.format("People: %s", #state.chars))
  drawResources(state)
  drawTicks(utils.round2(state.tick))

  -- menu area
  drawMenu()

  if state.ui.selected.coords and #state.ui.selected.coords > 0 then
    local room = state.ui.selected
    if room.kind ~= 'empty' then
      local em = "[empty]"
      local left = room.people[1]
      local right = room.people[2]
      drawButton(UI.btn.assignedLeft, left and people.firstname(left) or em)
      drawButton(UI.btn.assignedRight, right and people.firstname(right) or em)
    end
  end
  draw_chars_field(state)

  -- main field
  for x = 1, #UI.images do
    for y = 1, #UI.images[1] do
      love.graphics.draw(UI.images[x][y].src, UI.images[x][y].xx,
                         UI.images[x][y].yy)
    end
  end

  -- based on rooms
  drawCoords(state)
  drawRoomNames(state)
  drawRoomCrew(state)
  drawSelected(state)
end

function love.update(dt)
  -- one tick per second
  state.tick = state.tick + dt

  -- update resources, (rate * tick)
  for k, _ in pairs(state.resources) do
    plus = dt * state.resources[k].rate
    state.resources[k].amount = state.resources[k].amount + plus
  end

  -- update rates
  world.update_rates(state, world.get_rates(state.ship))

  -- get new crew members
  local diff = state.tick - (state.tick_crew * GLOB.new_crew_interval)
  if diff > 0 and diff <= GLOB.new_crew_interval then
    local person = people.generate()
    state.chars[#state.chars+1] = person
    people.print_person(state.chars[#state.chars])
    state.tick_crew = state.tick_crew + 1
  end
end

function love.mousepressed(x, y, button)
  -- only left-click
  if button == 1 then
    -- check btn_chars
    if checkClicked(UI.btn.chars, x, y) then
      state.ui.show_chars = not state.ui.show_chars
      return
    end
    -- check assign buttons
    if state.ui.selected.coords and state.ui.selected.kind ~= 'empty' then
      if checkClicked(UI.btn.assignedLeft, x, y) then
        if #state.ui.selected.people < 1 and #state.chars > 0 then
          local x, y = unpack(state.ui.selected.coords)
          for i = 1, #state.chars do
            if #state.chars[i].assigned < 1 then
              world.assign(state.ship, x, y, state.chars[#state.chars])
              people.print_person(state.chars[#state.chars])
              return
            else
              utils.dbg(string.format("%s is assigned already", state.chars[i].name))
            end
          end
        end
        return
      end
      if checkClicked(UI.btn.assignedRight, x, y) then
        if #state.ui.selected.people < 2 and #state.chars > 0 then
          local x, y = unpack(state.ui.selected.coords)
          for i = 1, #state.chars do
            if #state.chars[i].assigned < 1 then
              world.assign(state.ship, x, y, state.chars[#state.chars])
              people.print_person(state.chars[#state.chars])
              return
            else
              utils.dbg(string.format("%s is assigned already", state.chars[i].name))
            end
          end
        end
        return
      end
    end
    -- check menu area
    local m_x1 = GLOB.margin_menu
    local m_x2 = GLOB.margin_menu + GLOB.menu_w
    local m_y1 = GLOB.margin_menu + GLOB.header_h
    local m_y2 = GLOB.win_size_y - GLOB.margin_menu
    if x >= m_x1 and x <= m_x2 and y >= m_y1 and y <= m_y2 then
      utils.dbg("click: menu @ " .. x .. "," .. y)
      return
    end

    -- default area, images
    local v
    local match = false
    for i = 1, #state.ship do
      for j = 1, #state.ship[1] do
        v = UI.images[i][j]
        x2 = v.xx + GLOB.img_w
        y2 = v.yy + GLOB.img_h
        if x >= v.xx and x <= x2 and y >= v.yy and y <= y2 then
          utils.dbg("click: " .. i .. "," .. j)
          state.ui.selected = state.ship[i][j]
          match = true
        end
      end
    end

    -- unselect if not: in menu, on room
    if not match then
      state.ui.selected = {}
    end
  end
end

-- own stuff
function checkClicked(t, x, y)
  local xx, yy, w, h = utils.dim(t)
  if x >= xx and x <= xx+w and y >= yy and y <= yy+h then
    utils.dbg("click: btn @ " .. x .. "," .. y)
    return true
  end
  return false
end

function drawButton(t, text)
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(t.bg)
  love.graphics.rectangle("fill", t.x, t.y, t.w, t.h)
  love.graphics.setColor({r, g, b, a})
  love.graphics.printf(text, t.x + t.tx, t.y + t.ty, t.tl, t.ta)
end

-- @TODO could be a drawButton() call
function drawHeader()
  local x = 0
  local y = 0
  local w = GLOB.win_size_x
  local h = GLOB.header_h

  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(GLOB.header_color_bg)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor({r, g, b, a})
end

-- @TODO could be a drawButton() call
function drawMenu()
  local x = GLOB.margin_menu
  local y = GLOB.header_h + GLOB.margin_menu
  local w = GLOB.menu_w
  local h = GLOB.win_size_y - y - GLOB.margin_menu

  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(GLOB.menu_color_bg)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor({r, g, b, a})
end

function draw_chars_field(state)
  if not state.ui.show_chars then
    return
  end
  local text = ""
  if #state.chars < 1 then
    text = "No one :(\n"
  else
    text = text .. "Characters:\n"
    for i = 1, #state.chars do
      text = text .. state.chars[i].name .. "\n"
    end
  end
  local x = 2 * GLOB.margin_menu
  local y = GLOB.win_size_y - GLOB.margin_menu - ((#state.chars +1) * GLOB.font_size)
  love.graphics.printf(text, x, y, GLOB.menu_w, 'left')
end


function drawTicks(text)
  if not GLOB.DEBUG then
    return
  end
  local x = GLOB.win_size_x - 60
  local y = GLOB.margin_menu
  local text = string.format("Tick: %s", text)
  love.graphics.printf(text, x, y, 50, 'right')
end

function getRoomInfo(state, x, y)
  local room = state.ship[x][y]
  local base = world.Rooms[room.kind]

  local text = ""
  local tbl = {}
  local tx = ""

  tx ="Stat: [" .. utils.ucfirst(base.stat) .. "]"
  text = text .. tx .. "\n"
  table.insert(tbl, tx)

  tx = "Generates [" .. utils.ucfirst(base.resource) .. "]"
  text = text .. tx .. "\n"
  table.insert(tbl, tx)

  if GLOB.DEBUG then
    local r = world.get_rates(state)
    tx = "Rate(base): " .. base.base_rate
    text = text .. tx .. "\n"
    table.insert(tbl, tx)

    tx = "Rate(curr): " .. state.resources[base.resource].rate
    text = text .. tx .. "\n"
    table.insert(tbl, tx)
  end

  return text, tbl
end

function drawSelected(state)
  if not state.ui.selected.coords then
    return
  end

  local offset_x = GLOB.img_w - 30
  local offset_y = GLOB.img_h - 30

  local x = state.ui.selected.coords[1]
  local y = state.ui.selected.coords[2]

  -- selected room: border
  local xx = UI.images[x][y].xx
  local yy = UI.images[x][y].yy
  love.graphics.rectangle('line', xx, yy, GLOB.img_w, GLOB.img_h)
  -- menu: info area
  local mx = GLOB.margin_menu + GLOB.margin_selected
  local my = GLOB.margin_menu + GLOB.margin_selected + GLOB.header_h
  local mw = GLOB.menu_w - (2 * GLOB.margin_menu)
  love.graphics.rectangle('line', mx, my, mw, mw)
  -- contents of menu area
  local text = getRoomName(state, x, y)
  if text then
    local info = getRoomInfo(state, x, y)
    if info then
      text = text .. "\n\n" .. info
    end
    local ppl = getCrewNames(state, x, y, true)
    if ppl then
      text = text .. "\nAssigned:\n" .. ppl
    end
    love.graphics.printf(text, mx + 3, my + 3, mw, 'left')
  end
end

function getRoomName(state, x, y)
  local room = state.ship[x][y]
  local text = nil
  if room.kind ~= 'empty' then
    local info = world.Rooms[room.kind]
    text = string.format("%s\n(Level %s)", info.name, info.level)
  end
  return text
end

function drawRoomNames(state)
  local offset_x = GLOB.margin_names
  local offset_y = GLOB.margin_names
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      local text = getRoomName(state, x, y)
      if text then
        local xx = UI.images[x][y].xx + offset_x
        local yy = UI.images[x][y].yy + offset_y
        love.graphics.printf(text, xx, yy, GLOB.img_w, 'left')
      end
    end
  end
end

function getCrewNames(state, x, y, with_empty)
  local text = nil
  local tbl = {}
  local room = state.ship[x][y]
  local count = 1
  local em = "[empty slot]"
  if room.kind ~= 'empty' then
    if #room.people > 0 then
      text = ""
      for i = 1, #room.people do
        text = text .. room.people[i].name .. "\n"
        table.insert(tbl, room.people[i].name)
        count = count +1
      end
      if with_empty and count-1 < world.Rooms[room.kind].capacity then
        text = text .. "[empty slot]\n"
        table.insert(tbl, em)
      end
    elseif with_empty then
      text = ""
      for i = 1, world.Rooms[room.kind].capacity do
        text = text .. "[empty slot]\n"
        table.insert(tbl, em)
      end
    end
  end
  return text, tbl
end

function drawRoomCrew(state)
  local offset_x = GLOB.margin_names
  local offset_y = GLOB.margin_names
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      local room = state.ship[x][y]
      local text = getCrewNames(state, x, y, false)
      if text then
        local xx = UI.images[x][y].xx + offset_x
        local yy = UI.images[x][y].yy + GLOB.img_h - (14 * #room.people)
        love.graphics.printf(text, xx, yy, GLOB.img_w, 'left')
      end
    end
  end
end

function drawCoords(state)
  if not GLOB.DEBUG then
    return
  end
  local offset_x = 30
  local offset_y = 15
  for x = 1, #state.ship do
    for y = 1, #state.ship[1] do
      local text = string.format("[%s,%s]", x, y)
      local xx = UI.images[x][y].xx + GLOB.img_w - offset_x
      local yy = UI.images[x][y].yy + GLOB.img_h - offset_y
      love.graphics.printf(text, xx, yy, offset_x, 'right')
    end
  end
end

function drawResources(state)
  local power = state.resources.power.amount
  local text = string.format("[Power: %d]", power)
  local x = GLOB.margin_menu + GLOB.chars_w
  local y = GLOB.margin_menu
  local limit = GLOB.win_size_x * 3 / 4
  love.graphics.printf(text, x, y, limit, 'left')
end


