StashSelection = {}

function StashSelection.Allowed(stash, job, showAll)
  return showAll or (job ~= nil and job.name == stash.job and job.grade >= stash.minGrade)
end

function StashSelection.Nearest(stashes, coords, radius, job, showAll)
  local nearest, best = nil, radius * radius
  for _, stash in pairs(stashes) do
    if StashSelection.Allowed(stash, job, showAll) then
      local x, y, z = coords.x - stash.pos.x, coords.y - stash.pos.y, coords.z - stash.pos.z
      local distance = x * x + y * y + z * z
      if distance <= best and (not nearest or distance < best or stash.id < nearest.id) then
        nearest, best = stash, distance
      end
    end
  end
  return nearest
end
