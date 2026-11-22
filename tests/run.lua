local originalType = type
local vector = { __name = 'vector3' }
function type(value)
  if getmetatable(value) == vector then return 'vector3' end
  return originalType(value)
end

local function position(x)
  return setmetatable({ x = x, y = 0, z = 0 }, vector)
end

local function equal(actual, expected)
  assert(actual == expected, ('expected %s, got %s'):format(tostring(expected), tostring(actual)))
end

local manifestFile = assert(io.open('fxmanifest.lua'))
local manifest = manifestFile:read('*a')
manifestFile:close()
assert(manifest:find('configuration/bridge/client.lua', 1, true), 'the prompt bridge must be loaded')

dofile('source/shared/validate.lua')
local catalog, warnings = Stashes.Build({
  b = { pos = position(1), job = 'police', minGrade = 2.0 },
  a = { pos = position(-1), job = 'police' },
  invalid = { pos = position(0), job = ' ' },
  invalidWeight = { pos = position(0), job = 'police', stashweight = math.huge },
})
equal(#catalog, 2)
equal(#warnings, 2)
equal(catalog[1].id, 'a')
equal(catalog[1].slots, 50)
equal(catalog[2].minGrade, 2)
equal(#(Stashes.Build(false)), 0)

local job = Stashes.NormalizeJob({ name = 'police', grade = { level = '2' } })
equal(job.grade, 2)
equal(Stashes.NormalizeJob({ name = 'police', grade = 'invalid' }), nil)

dofile('source/client/selection.lua')
local all = { b = catalog[2], a = catalog[1] }
equal(StashSelection.Nearest(all, position(0), 2, job).id, 'a')
equal(StashSelection.Nearest(all, position(0.9), 2, job).id, 'b')
equal(StashSelection.Nearest(all, position(0.9), 2, { name = 'police', grade = 0 }).id, 'a')
equal(StashSelection.Nearest(all, position(0), 0.1, job), nil)
equal(StashSelection.Nearest(all, position(0), 2, nil), nil)
equal(StashSelection.Nearest(all, position(0), 2, nil, true).id, 'a')

local handlers, calls, state = {}, {}, 'started'
cache = { resource = 'm_jobstashes' }
lib = { locale = function() end }
Config = { locations = {
  broken = { pos = position(0), job = 'police' },
  working = { pos = position(1), job = 'police', minGrade = 2 },
} }
function locale(_, id) return id end
function GetResourceMetadata() return '2.0.0' end
function GetResourceState() return state end
function AddEventHandler(name, handler) handlers[name] = handler end
exports = { ox_inventory = { RegisterStash = function(_, id, label, slots, weight, owner, groups, coords)
  calls[#calls + 1] = id
  if id == 'broken' then error('fixture export failure') end
  equal(label, 'working')
  equal(slots, 50)
  equal(weight, 50000)
  equal(owner, false)
  equal(groups.police, 2)
  equal(coords, Config.locations.working.pos)
end } }
dofile('source/server/boot.lua')
handlers.onServerResourceStart(cache.resource)
equal(table.concat(calls, ','), 'broken,working')
handlers.onServerResourceStart('ox_inventory')
equal(table.concat(calls, ','), 'broken,working,broken')
handlers.onServerResourceStop('ox_inventory')
handlers.onServerResourceStart('ox_inventory')
equal(table.concat(calls, ','), 'broken,working,broken,broken,working')

local points, shown, opened = {}, {}, {}
local player, playerJob, key = position(0), { name = 'police', grade = 2 }, nil
local frame, hidden = 1, 0
Config = {
  Framework = 'fixture',
  DrawDistance = 25,
  InteractDistance = 2,
  Marker = { type = 2, scale = position(1), rgba = { 255, 255, 255, 180 } },
  locations = {
    a = { pos = position(-1), job = 'police', label = 'Alpha' },
    b = { pos = position(1), job = 'police', label = 'Bravo', minGrade = 2 },
  },
}
lib.addKeybind = function(definition)
  key = definition
  return { getCurrentKey = function() return 'E' end }
end
lib.points = { new = function(point) points[#points + 1] = point return point end }
function locale(name, _, label) return name == 'open_prompt' and label or name end
function GetEntityCoords() return player end
function GetFrameCount() return frame end
function GetCurrentResourceName() return cache.resource end
function DrawMarker() end
Bridge = {
  showPrompt = function(text) shown[#shown + 1] = text end,
  hidePrompt = function() hidden = hidden + 1 end,
  openStash = function(id) opened[#opened + 1] = id end,
}

dofile('init.lua')
Integrations.Register('framework', 'fixture', {
  init = function() end,
  getJob = function() return playerJob end,
})
dofile('source/client/main.lua')
points[1]:onEnter()
points[2]:onEnter()
points[2]:nearby()
points[1]:nearby()
equal(table.concat(shown, ','), 'Alpha')
player = position(1)
key.onPressed()
equal(table.concat(opened, ','), 'b')
playerJob.grade = 0
player = position(0.5)
key.onPressed()
equal(table.concat(opened, ','), 'b,a')
player = position(3.1)
key.onPressed()
equal(table.concat(opened, ','), 'b,a')
equal(hidden, 1)
player, frame = position(-1), frame + 1
points[1]:nearby()
handlers.onResourceStop(cache.resource)
equal(hidden, 2)

print('All stash regression checks passed')
