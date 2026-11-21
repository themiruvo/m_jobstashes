lib.locale(Config.Locale)

local VERSION = GetResourceMetadata(cache.resource, 'version', 0) or '?'

local function registerStashes()
  local registered, warnings = 0, 0

  if type(Config.locations) ~= 'table' then
    print(('^1[%s] config error:^7 Config.locations must be a table^0'):format(cache.resource))
    return 0, 1
  end

  for stashId, data in pairs(Config.locations) do
    local problems = ValidateStash(stashId, data)
    if #problems > 0 then
      for _, p in ipairs(problems) do print(('^3[%s] config:^7 %s, stash skipped^0'):format(cache.resource, p)) end
      warnings = warnings + #problems
    else
      exports.ox_inventory:RegisterStash(
        stashId,
        data.label or locale('default_label', stashId),
        data.slots or 50,
        data.stashweight or 50000,
        false,
        { [data.job] = data.minGrade or 0 },
        data.pos
      )
      registered = registered + 1
    end
  end

  return registered, warnings
end

AddEventHandler('onServerResourceStart', function(res)
  if res ~= 'ox_inventory' and res ~= cache.resource then return end
  local registered, warnings = registerStashes()
  print(('[%s] v%s · %d stash(es) registered in ox_inventory · locale %s · %d config warning(s)'):format(
    cache.resource, VERSION, registered, Config.Locale or 'convar', warnings))
end)
