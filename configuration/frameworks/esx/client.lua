local job

local function setJob(j)
  job = Stashes.NormalizeJob(j)
end

Integrations.Register('framework', 'esx', {
  resource = 'es_extended',
  priority = 1,
  init = function()
    local data = exports.es_extended:getSharedObject().GetPlayerData()
    setJob(data and data.job)
    RegisterNetEvent('esx:playerLoaded', function(xPlayer) setJob(xPlayer and xPlayer.job) end)
    RegisterNetEvent('esx:setJob', setJob)
    RegisterNetEvent('esx:onPlayerLogout', function() job = nil end)
  end,
  getJob = function() return job end,
})
