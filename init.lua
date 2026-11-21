Integrations = { registered = {}, active = {} }

function Integrations.Register(kind, name, impl)
  impl.name, impl.resource, impl.priority = name, impl.resource or name, impl.priority or 0
  local list = Integrations.registered[kind] or {}
  Integrations.registered[kind] = list
  list[#list + 1] = impl
end

local function isStarted(resource)
  local state = GetResourceState(resource)
  return state == 'started' or state == 'starting'
end
Integrations.IsStarted = isStarted

function Integrations.Names(kind)
  local names = {}
  for _, impl in ipairs(Integrations.registered[kind] or {}) do names[#names + 1] = impl.name end
  return table.concat(names, ', ')
end

function Integrations.Resolve(kind, setting)
  local list = Integrations.registered[kind] or {}
  if setting == false or setting == 'none' then return nil end

  if setting and setting ~= 'auto' then
    for _, impl in ipairs(list) do
      if impl.name == setting then Integrations.active[kind] = impl return impl end
    end
    print(('^1[%s] %s "%s" is not supported. Options: %s^0'):format(
      GetCurrentResourceName(), kind, tostring(setting), Integrations.Names(kind)))
    return nil
  end

  local sorted = { table.unpack(list) }
  table.sort(sorted, function(a, b) return a.priority > b.priority end)
  for _, impl in ipairs(sorted) do
    if not impl.manual and isStarted(impl.resource) then
      Integrations.active[kind] = impl
      return impl
    end
  end
end
