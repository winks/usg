local utils = {}

function utils.dbg(t)
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

return utils
