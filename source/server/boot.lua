lib.locale(Config.Locale)

local inventory = 'ox_inventory'
local version = GetResourceMetadata(cache.resource, 'version', 0) or '?'
local catalog, warnings = Stashes.Build(Config.locations)
local registered = {}

for _, warning in ipairs(warnings) do
  print(('^3[%s] config:^7 %s^0'):format(cache.resource, warning))
end

local function registerPending()
  if GetResourceState(inventory) ~= 'started' then return end

  local ready, failed = 0, 0
  for _, stash in ipairs(catalog) do
    if not registered[stash.id] then
      local ok, err = pcall(function()
        exports.ox_inventory:RegisterStash(stash.id, stash.label or locale('default_label', stash.id),
          stash.slots, stash.stashweight, false, { [stash.job] = stash.minGrade }, stash.pos)
      end)
      if ok then
        registered[stash.id] = true
      else
        failed = failed + 1
        print(('^1[%s] failed to register stash %q: %s^0'):format(cache.resource, stash.id, tostring(err)))
      end
    end
    if registered[stash.id] then ready = ready + 1 end
  end

  print(('[%s] v%s | %d/%d stashes registered | %d failed | %d config warnings'):format(
    cache.resource, version, ready, #catalog, failed, #warnings))
end

AddEventHandler('onServerResourceStart', function(resource)
  if resource == inventory or resource == cache.resource then registerPending() end
end)

AddEventHandler('onServerResourceStop', function(resource)
  if resource == inventory then registered = {} end
end)
