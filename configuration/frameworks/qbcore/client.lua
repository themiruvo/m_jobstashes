local job

local function set(playerData)
  job = Stashes.NormalizeJob(type(playerData) == 'table' and playerData.job)
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
