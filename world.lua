local utils = require("utils")

local world = {}

local seed_rooms = {
  empty = {
    name       = "empty",
    level      = 0,
    stat       = 'none',
    base_rate  = 0,
    build_cost = 0,
    resource   = 'empty',
  },
  gen_power = {
    name       = "Power Generator",
    level      = 1,
    stat       = 'constitution',
    base_rate  = 1,
    build_cost = 1,
    resource   = 'power',
  },
}

local seed_resources = {
  'power'
}

world.seed_resources = seed_resources
world.seed_rooms = seed_rooms

function world.gen_ship(x, y)
  local ship = {} --utils.shallowcopy(orig)

  for y = 1, y do
    row = {}
    for x = 1, x do
      kind = 'empty'
      if x == 1 and y == 1 then
        kind = 'gen_power'
      end
      room = {
        kind = kind,
        coords = {x, y},
        people = {},
      }
      table.insert(row, room)
    end
    table.insert(ship, row)
  end

  return ship
end

function world.fill(s, n)
  for i = 1, n do
    utils.printf(s)
  end
end

function world.print_row(cols, left_margin, fill_size, left_wall, right_wall, filler, middle)
  utils.printf(left_margin)
  for y = 1, cols do
    utils.printf(left_wall)
    world.fill(filler, fill_size)
    utils.printf(right_wall)
    utils.printf(middle)
  end
  print("")
end

function world.print_ship(ship, gfx)
  if #ship < 1 then
    return
  end
  local ship_width = #ship[1]
  local cell = 11
  local left_wall = ""
  local right_wall = ""
  local left_margin = ""
  local middle = ""
  -- graphical header
  if gfx then
    left_margin = "  "
    middle = " "
    left_wall = "|"
    right_wall = "|"

    print('   USS "I suck at ascii art"')
    print("")
    -- first row
    utils.printf("%s%s", left_margin, "           ")
    world.fill("*", (ship_width * cell) + - 17)
    print("")
    -- first row
    utils.printf("%s%s", left_margin, "        ")
    world.fill("*", (ship_width * cell) + - 11)
    print("")
    -- first row
    utils.printf("%s%s", left_margin, "     ")
    world.fill("*", (ship_width * cell) - 5)
    print("")
    -- first row
    utils.printf("%s%s", left_margin, "  /")
    world.fill("X", (ship_width * cell) - 1)
    print("\\")
    -- second row
    utils.printf("%s%s", left_margin, " /")
    world.fill("_", cell-1)
    utils.printf("| |")
    world.fill("_", cell-1)
    utils.printf("\\")
    print("")
    -- second row
    utils.printf("%s%s", left_margin, "/")
    world.fill("_", cell)
    utils.printf("| |")
    world.fill("_", cell)
    utils.printf("\\")
    print("")
  end
  for x = 1, #ship do
    row = ship[x]
    if gfx then
      utils.printf(left_margin)
    end
    for y = 1, #row do
      coords = "[" .. ship[x][y].coords[1] .. "," .. ship[x][y].coords[2] .."]"
      utils.printf("%s %" .. (cell-2) .. "s %s%s", left_wall, coords, right_wall, middle)
    end
    print("")
    if gfx then
      empty = true
      for y = 1, #row do
        if ship[x][y].kind ~= 'empty' then
          empty = false
        end
      end
      if empty then
        world.print_row(#row, left_margin, cell, left_wall, right_wall, " ", middle)
      else
        utils.printf(left_margin)
        for y = 1, #row do
          utils.printf("%s %" .. (cell-2) .. "s %s%s", left_wall,
                 ship[x][y].kind == 'empty' and '' or ship[x][y].kind,
                 right_wall, middle)
        end
        print("")
      end
      world.print_row(#row, left_margin, cell, left_wall, right_wall, "_", middle)
    end
  end
  -- graphical footer
  if gfx then
    -- first row
    utils.printf(" /")
    world.fill("_", (ship_width * cell) + 5)
    utils.printf("\\")
    print("")
    -- second row
    utils.printf(" ")
    for i = 1, (cell-4) do
      utils.printf("|   ")
    end
    print("|")
    -- third row
    utils.printf(" ")
    for i = 1, (cell-4) do
      utils.printf("|___")
    end
    print("|")
    -- third row
    utils.printf(" ")
    for i = 1, (cell-4) do
      utils.printf(" vvv")
    end
    print("")
  end
  print("")
end

function world.get_rates(ship)
  local rates = {}
  for _, k in ipairs(world.seed_resources) do
    rates[k] = 0
  end

  for i = 1, #ship do
    for j = 1, #ship[1] do
      kind = ship[i][j].kind
      if kind ~= 'empty' then
        resource = seed_rooms[kind].resource
        rate = seed_rooms[kind].base_rate
        rates[resource] = rates[resource] + rate
      end
    end
  end
  return rates
end

function world.update_rates(state, rates)
  for k, v in pairs(state.resources) do
    --print(k .. v.rate)
    state.resources[k].rate = rates[k]
  end
  for k, v in pairs(state.resources) do
    --print(k .. v.rate)
  end
end

function world.assign(ship, x, y, person)
  if ship[x][y].kind == 'empty' then
    return false
  end

  table.insert(ship[x][y].people, person)
  return ship
end

function world.show_assigned(ship)
  assigned = {}
  for i = 1, #ship do
    for j = 1, #ship[1] do
      if #ship[i][j].people > 0 then
        room = ship[i][j].kind
        for _, person in ipairs(ship[i][j].people) do
          text = string.format("[%s,%s][%s][%s]", i, j, room, person.name)
          table.insert(assigned, text)
        end
      end
    end
  end
  return assigned
end

return world
