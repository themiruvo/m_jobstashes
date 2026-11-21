local function isInt(v, min)
  return type(v) == 'number' and math.type(v) == 'integer' and v >= min
end

function ValidateStash(id, s)
  if type(id) ~= 'string' then
    return { ('Config.locations key %s must be a string, e.g. [\'police_stash\']'):format(tostring(id)) }
  end
  if type(s) ~= 'table' then
    return { ('Config.locations[%q] must be a table'):format(id) }
  end

  local problems = {}
  local function bad(field, why, got)
    problems[#problems + 1] = ('Config.locations[%q].%s %s (got %s)'):format(id, field, why, tostring(got))
  end

  if type(s.job) ~= 'string' or s.job == '' then bad('job', 'must be a job name like "police"', s.job) end
  if type(s.pos) ~= 'vector3' then bad('pos', 'must be vector3(x, y, z)', s.pos) end
  if s.minGrade ~= nil and not isInt(s.minGrade, 0) then bad('minGrade', 'must be a whole number >= 0', s.minGrade) end
  if s.slots ~= nil and not isInt(s.slots, 1) then bad('slots', 'must be a whole number >= 1', s.slots) end
  if s.stashweight ~= nil and not (type(s.stashweight) == 'number' and s.stashweight > 0) then
    bad('stashweight', 'must be a number > 0 (grams)', s.stashweight)
  end
  if s.label ~= nil and type(s.label) ~= 'string' then bad('label', 'must be text', s.label) end

  return problems
end
