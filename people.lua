local utils = require("utils")

local people = {}

local seed_male = {
  'Felton',
  'Johnathon',
  'Lonnie',
  'Avery',
  'Aron',
  'Alfonzo',
  'Leopoldo',
  'Ferdinand',
  'Wilfred',
  'Scotty',
  'Dean',
  'Morgan',
  'William',
  'Walker',
  'Len',
  'Young',
  'Elijah',
  'Lauren',
  'Samuel',
  'Hoyt',
}

local seed_female = {
  'Jong',
  'Ninfa',
  'Quyen',
  'Almeda',
  'Lita',
  'Genevie',
  'Zada',
  'Cristine',
  'Vivian',
  'Lakesha',
  'Selma',
  'Arvilla',
  'Jacqualine',
  'Shan',
  'Liza',
  'Mari',
  'Laurice',
  'Deedee',
  'Beatrice',
  'Onie',
}

local seed_last = {
  'Snipe',
  'Goodson',
  'Fujimoto',
  'Schwarz',
  'Holzer',
  'Hubert',
  'Eichman',
  'Sinn',
  'Kisner',
  'Uplinger',
  'Obert',
  'Covin',
  'Plascencia',
  'Venters',
  'Cushing',
  'Jeanbart',
  'Kennelly',
  'Morrissey',
  'Brabant',
  'Todd',
  'Paredes',
  'Short',
  'Crafts',
  'Vaughan',
  'Hazlewood',
  'Cookingham',
  'Stagner',
  'Zeller',
  'Myres',
  'Toppin',
  'Dray',
  'Westlake',
  'Palumbo',
  'Dever',
  'Griffy',
  'Billingsley',
  'Mynatt',
  'Bertone',
  'Sin',
  'Krikorian',
}

local seed_genders = {
  'female',
  'male',
}

local seed_skin = {
  'a', 'b', 'c'
}

local seed_face = {
  'a', 'b', 'c'
}

local seed_hair = {
  'a', 'b', 'c'
}

local seed_stats = {
  'strength',
  'constitution',
  'dexterity',
  'intelligence',
  'wisdom',
  'charisma',
}

STAT_MIN = 1
STAT_MAX = 10
STAT_START_INIT = #seed_stats
STAT_START_FREE = 12
STAT_START_MAX = 4

function people.rand_stat()
  local n = math.random(#seed_stats)
  return seed_stats[n]
end

function people.init_stats(orig)
  local stats = {}
  for _, k in ipairs(orig) do
    stats[k] = 1
  end
  return stats
end

function people.sum_stats(t)
  local sum = 0
  for _, v in pairs(t) do
    sum = sum + v
  end
  return sum
end

function people.print_stats(t)
  for _, s in ipairs(seed_stats) do
    len = #s
    stat = string.format("%s%" .. (13-len).. "s", utils.ucfirst(s)," ")
    val = string.format("%2d", t[s])
    print("  " .. stat  .. " "  .. val)
  end
end

function people.add_random_stats(t, num)
  local t2 = utils.shallowcopy(t)

  while people.sum_stats(t2) < STAT_START_INIT + STAT_START_FREE do
    s = people.rand_stat()
    for k, _ in pairs(t2) do
      if k == s and t2[k] < STAT_START_MAX then
        t2[k] = t2[k] + 1
      end
    end
  end
  return t2
end

function people.generate()
  local gender = math.random( #seed_genders )
  local t = (gender == 1) and seed_female or seed_male
  local first = math.random(#t)
  local last = math.random(#seed_last)
  local name = t[first] .. " " .. seed_last[last]
  local stats = people.init_stats(seed_stats)
  local rstats = people.add_random_stats(stats, STAT_START_FREE)

  local person = {
    name   = name,
    gender = seed_genders[gender],
    stats  = rstats,
    weapon = {},
    armor  = {},
    skin   = math.random(#seed_skin),
    hair   = math.random(#seed_hair),
    face   = math.random(#seed_face),
    affinity = seed_stats[math.random(#seed_stats)],
    assigned = {},
  }
  return person
end

function people.print_person(t)
  for i, k in pairs(t) do
    --print(i .. " : " .. k)
  end
  local ass
  if #t.assigned > 0 then
    ass = string.format("[%s,%s]", t.assigned[1], t.assigned[2])
  else
    ass = "No"
  end
  print("====================")
  print("Name     : " .. t.name)
  print("Gender   : " .. t.gender)
  print("Affinity : " .. utils.ucfirst(t.affinity))
  print("Weapon   : None")
  print("Armor    : None")
  print("Assigned : " .. ass)
  print("Stats    :")
  people.print_stats(t.stats)
  --print("Skin : " .. t.skin)
  --print("Face : " .. t.face)
  --print("Hair : " .. t.hair)
  print("====================")
end

function people.firstname(p)
  parts = utils.split(p.name, " ")
  return parts[1]
end

people.Genders = seed_genders
people.Stats = seed_stats

return people
