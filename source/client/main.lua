lib.locale(Config.Locale)

local catalog = Stashes.Build(Config.locations)
if #catalog == 0 then return end

local drawDistance, interactDistance = Config.DrawDistance, Config.InteractDistance
if not Stashes.IsFinite(drawDistance) or not Stashes.IsFinite(interactDistance)
  or interactDistance <= 0 or drawDistance < interactDistance then
  print(('^1[%s] expected 0 < Config.InteractDistance <= Config.DrawDistance^0'):format(cache.resource))
  return
end

local marker = Config.Marker
if type(marker) ~= 'table' or type(marker.scale) ~= 'vector3' or type(marker.rgba) ~= 'table' then
  print(('^1[%s] Config.Marker requires a scale vector3 and an rgba table^0'):format(cache.resource))
  return
end

local function callBridge(name, ...)
  local ok, err = pcall(Bridge[name], ...)
  if not ok then
    print(('^1[%s] configuration/bridge/client.lua Bridge.%s failed: %s^0'):format(
      cache.resource, name, tostring(err)))
  end
  return ok
end

local setting = Config.Framework
local showAll = setting == false or setting == 'none'
local framework = Integrations.Resolve('framework', setting)
if framework then
  local ok, err = pcall(framework.init)
  if not ok then
    print(('^1[%s] framework %s initialization failed: %s^0'):format(cache.resource, framework.name, tostring(err)))
    framework = nil
  end
end
if not framework and not showAll then
  print(('^3[%s] no framework available: job markers are disabled^0'):format(cache.resource))
  return
end

local function currentJob()
  if framework and (framework.manual or Integrations.IsStarted(framework.resource)) then
    return framework.getJob()
  end
end

local nearby, prompt, frame, frameJob = {}, nil, nil, nil
local keybind

local function updatePrompt(stash)
  local text = stash and locale('open_prompt', keybind:getCurrentKey(), stash.label or locale('stash'))
  if text == prompt then return end
  if text then
    -- Record the attempted text so a broken custom bridge cannot log once per frame.
    prompt = text
    callBridge('showPrompt', text)
  else
    prompt = nil
    callBridge('hidePrompt')
  end
end

local function nearest(job)
  return StashSelection.Nearest(nearby, GetEntityCoords(cache.ped), interactDistance, job, showAll)
end

keybind = lib.addKeybind({
  name = 'm-jobstashes_open',
  description = locale('keybind'),
  defaultKey = Config.Key or 'E',
  onPressed = function()
    local stash = nearest(currentJob())
    updatePrompt(stash)
    if stash then callBridge('openStash', stash.id) end
  end,
})

for _, stash in ipairs(catalog) do
  local point = lib.points.new({ coords = stash.pos, distance = drawDistance })

  function point:onEnter()
    nearby[stash.id] = stash
  end

  function point:onExit()
    nearby[stash.id] = nil
    if not next(nearby) then updatePrompt(nil) end
  end

  function point:nearby()
    local currentFrame = GetFrameCount()
    if frame ~= currentFrame then
      frame = currentFrame
      frameJob = currentJob()
      updatePrompt(nearest(frameJob))
    end

    if not StashSelection.Allowed(stash, frameJob, showAll) then return end
    local pos, scale, rgba = stash.pos, marker.scale, marker.rgba
    DrawMarker(marker.type, pos.x, pos.y, pos.z - 0.95,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      scale.x, scale.y, scale.z, rgba[1], rgba[2], rgba[3], rgba[4],
      false, true, 2, false, nil, nil, false)
  end
end

AddEventHandler('onResourceStop', function(resource)
  if resource == cache.resource then updatePrompt(nil) end
end)
