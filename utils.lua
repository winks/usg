local utils = {}

function utils.dbg(t)
  if not GLOB.DEBUG then
    return
  end
  if type(t) ~= 'table' then
    print(t)
	return
  end
  if #t > 0 then
  for i, k in ipairs(t) do
    if type(k) == 'table' then
      print(i .. ": t" )
    else
      print(i .. ": " .. k)
    end
  end
  else
  for i, k in pairs(t) do
    if type(k) == 'table' then
      print(i .. ": t" )
    else
      print(i .. ": " .. k)
    end
  end
  end
end

function utils.printf(s, ...)
  return io.write(s:format(...))
end

function utils.shallowcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function utils.ucfirst(str)
  return (str:gsub("^%l", string.upper))
end

function utils.round2(num, numDecimalPlaces)
  return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
end

--- Split a string using a pattern.
-- @param str The string to search in
-- @param pat The pattern to search with
-- @see http://lua-users.org/wiki/SplitJoin
function utils.split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = '(.-)' .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= '' then
      t[#t+1] = cap
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    t[#t+1] = cap
  end
  return t
end

function utils.dim(t)
  return t.x, t.y, t.w, t.h
end

return utils
