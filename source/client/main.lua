lib.locale(Config.Locale)

local function callBridge(name, ...)
  local ok, err = pcall(Bridge[name], ...)
  if not ok then
    print(('^1[%s] configuration/bridge/client.lua Bridge.%s failed: %s^0'):format(cache.resource, name, err))
  end
end

local framework = Integrations.Resolve('framework', Config.Framework == nil and 'auto' or Config.Framework)
if framework then
  local ok, err = pcall(framework.init)
  if not ok then
    print(('^1[%s] configuration/frameworks/%s/client.lua init failed: %s^0'):format(cache.resource, framework.name, err))
    framework = nil
  end
elseif Config.Framework ~= false then
  print(('^3[%s] no framework found (%s): markers are shown to everyone^0'):format(cache.resource, Integrations.Names('framework')))
end

local function canSee(data)
  if not framework then return true end
  local job = framework.getJob()
  return job ~= nil and job.name == data.job and job.grade >= (data.minGrade or 0)
end

local current

local function leave(stashId)
  if current ~= stashId then return end
  current = nil
  callBridge('hidePrompt')
end

local keybind = lib.addKeybind({
  name = 'm-jobstashes_open',
  description = locale('keybind'),
  defaultKey = Config.Key or 'E',
  onPressed = function()
    if current then callBridge('openStash', current) end
  end,
})

local m = Config.Marker

for stashId, data in pairs(Config.locations or {}) do
  if #ValidateStash(stashId, data) == 0 then
    local point = lib.points.new({ coords = data.pos, distance = Config.DrawDistance })

    function point:nearby()
      if not canSee(data) then return leave(stashId) end

      DrawMarker(m.type, data.pos.x, data.pos.y, data.pos.z - 0.95,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        m.scale.x, m.scale.y, m.scale.z,
        m.rgba[1], m.rgba[2], m.rgba[3], m.rgba[4],
        false, true, 2, false, nil, nil, false)

      if self.currentDistance > Config.InteractDistance then return leave(stashId) end

      if current ~= stashId then
        current = stashId
        callBridge('showPrompt', locale('open_prompt', keybind:getCurrentKey(), data.label or locale('stash')))
      end
    end

    function point:onExit() leave(stashId) end
  end
end

AddEventHandler('onResourceStop', function(res)
  if res == cache.resource and current then callBridge('hidePrompt') end
end)
