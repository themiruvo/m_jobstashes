local job

local function set(playerData)
  local j = playerData and playerData.job
  job = j and j.name and {
    name = j.name,
    grade = type(j.grade) == 'table' and (j.grade.level or 0) or (j.grade or 0),
  } or nil
end

Integrations.Register('framework', 'qbcore', {
  resource = 'qb-core',
  priority = 2,
  init = function()
    set(exports['qb-core']:GetCoreObject().Functions.GetPlayerData())
    RegisterNetEvent('QBCore:Player:SetPlayerData', set)
    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() job = nil end)
  end,
  getJob = function() return job end,
})
