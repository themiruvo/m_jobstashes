local job

local function set(playerData)
  job = Stashes.NormalizeJob(type(playerData) == 'table' and playerData.job)
end

Integrations.Register('framework', 'qbox', {
  resource = 'qbx_core',
  priority = 3,
  init = function()
    set(exports.qbx_core:GetPlayerData())
    RegisterNetEvent('QBCore:Player:SetPlayerData', set)
    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() job = nil end)
  end,
  getJob = function() return job end,
})
