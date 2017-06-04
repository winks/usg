local utils = require("utils")
local people = require("people")

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

    print("")
    print('   USS "I suck at ascii art"')
    print("")
    -- first * row
    utils.printf("%s%s", left_margin, "           ")
    world.fill("*", (ship_width * (cell+2)) + (ship_width-1) - 6 - 4 - 6 - 6)
    print("")
    -- second * row
    utils.printf("%s%s", left_margin, "        ")
    world.fill("*", (ship_width * (cell+2)) + (ship_width-1) - 6 - 4 - 6)
    print("")
    -- third * row
    utils.printf("%s%s", left_margin, "     ")
    world.fill("*", (ship_width * (cell+2)) + (ship_width-1) - 6 - 4)
    print("")
    -- first X row
    utils.printf("%s%s", left_margin, "  /")
    world.fill("X", (ship_width * (cell+2)) + (ship_width-1) - 6)
    print("\\")
    -- top /\ row
    utils.printf("%s%s", left_margin, " /")
    for i = 1, ship_width-1 do
      world.fill("_", cell-2+i)
      utils.printf("| |")
    end
    world.fill("_", cell-1)
    utils.printf("\\")
    print("")
    -- bottom /\ row
    utils.printf("%s%s", left_margin, "/")
    for i = 1, ship_width-1 do
      world.fill("_", cell)
      utils.printf("| |")
    end
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
      -- room.kind line
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
      -- room.people line
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
          px = ""
          for ii, xx in ipairs(ship[x][y].people) do
            px = px .. "(" .. people.firstname(xx) .. ")"
          end
          utils.printf("%s %" .. (cell-2) .. "s %s%s", left_wall,
                 ship[x][y].kind == 'empty' and '' or px,
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
    world.fill("_", (ship_width * (cell+2)) + (ship_width-1))
    utils.printf("\\")
    print("")
    -- second row
    -- 2 -> 27/28 => 7x4
    -- 3 -> 41/42 => 7x3 
    -- 4 -> 55/56 => 7x8
    -- 5 -> 69/70 => 7x10
    utils.printf(" ")
    for i = 1, 7 do
      utils.printf("|")
      world.fill(" ", (ship_width*2)-1)
    end
    print("|")
    -- third row
    utils.printf(" ")
    for i = 1, 7 do
      utils.printf("|")
      world.fill("_", (ship_width*2)-1)
    end
    print("|")
    -- third row
    utils.printf(" ")
    for i = 1, 7 do
      utils.printf(" ")
      world.fill("v", (ship_width*2)-1)
    end
    print("")
  end
  print("")
end

function world.get_rates(ship, skip_people)
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
        if not skip_people then
          people = ship[i][j].people
          pr = 0
          stat = world.seed_rooms[kind].stat
          for k, p in ipairs(people) do
            pr = pr + p.stats[stat]
          end
          rates[resource] = rates[resource] + (pr / 10)
        end
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
  if #ship[x][y].people > 1 then
    return false
  end

  table.insert(ship[x][y].people, person)
  return ship
end

function world.get_assigned(ship)
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
