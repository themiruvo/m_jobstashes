Stashes = {}

local function isText(value)
  return type(value) == 'string' and value:find('%S') ~= nil
end

function Stashes.IsFinite(value)
  return type(value) == 'number' and value > -math.huge and value < math.huge
end

local function whole(value, minimum)
  return type(value) == 'number' and math.tointeger(value) ~= nil and value >= minimum
end

local function normalizeStash(id, data)
  if not isText(id) then return nil, { 'Config.locations keys must be nonblank strings' } end
  if type(data) ~= 'table' then
    return nil, { ('Config.locations[%q] must be a table'):format(id) }
  end

  local problems = {}
  local function check(field, ok, reason)
    if not ok then problems[#problems + 1] = ('Config.locations[%q].%s %s'):format(id, field, reason) end
  end

  local pos = data.pos
  check('job', isText(data.job), 'must be a nonblank job name')
  check('pos', type(pos) == 'vector3' and Stashes.IsFinite(pos.x) and Stashes.IsFinite(pos.y)
    and Stashes.IsFinite(pos.z), 'must be a vector3 with finite coordinates')
  check('minGrade', data.minGrade == nil or whole(data.minGrade, 0), 'must be a whole number >= 0')
  check('slots', data.slots == nil or whole(data.slots, 1), 'must be a whole number >= 1')
  check('stashweight', data.stashweight == nil or (Stashes.IsFinite(data.stashweight)
    and data.stashweight > 0), 'must be a finite number > 0 (grams)')
  check('label', data.label == nil or isText(data.label), 'must be nonblank text')
  if #problems ~= 0 then return nil, problems end

  return {
    id = id,
    job = data.job,
    pos = pos,
    minGrade = math.tointeger(data.minGrade or 0),
    slots = math.tointeger(data.slots or 50),
    stashweight = data.stashweight or 50000,
    label = data.label,
  }
end

function Stashes.Build(locations)
  if type(locations) ~= 'table' then return {}, { 'Config.locations must be a table' } end

  local catalog, warnings = {}, {}
  for id, data in pairs(locations) do
    local stash, problems = normalizeStash(id, data)
    if stash then
      catalog[#catalog + 1] = stash
    else
      for _, problem in ipairs(problems) do warnings[#warnings + 1] = problem end
    end
  end

  table.sort(catalog, function(a, b) return a.id < b.id end)
  table.sort(warnings)
  return catalog, warnings
end

function Stashes.NormalizeJob(job)
  if type(job) ~= 'table' or not isText(job.name) then return nil end
  local grade = job.grade
  if type(grade) == 'table' then grade = grade.level end
  if type(grade) == 'string' then grade = tonumber(grade) end
  if not whole(grade, 0) then return nil end
  return { name = job.name, grade = math.tointeger(grade) }
end
