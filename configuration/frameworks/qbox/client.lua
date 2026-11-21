local job

local function set(playerData)
  local j = playerData and playerData.job
  job = j and j.name and {
    name = j.name,
    grade = type(j.grade) == 'table' and (j.grade.level or 0) or (j.grade or 0),
  } or nil
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
