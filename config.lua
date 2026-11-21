Config = {}

Config.Framework = 'auto'

Config.Locale = 'en'

Config.Key = 'E'

Config.DrawDistance = 25.0
Config.InteractDistance = 1.6

Config.Marker = {
  type = 2,
  scale = vec3(0.35, 0.35, 0.35),
  rgba = { 255, 255, 255, 180 }
}

Config.locations = {
  ['stash1'] = {
    pos = vector3(3419.8303, 4949.4204, 36.0011),
    job = "gang20",
    minGrade = 0,
    stashweight = 10000000,
    slots = 1000,
    label = "Förråd",
  },
  ['stash2'] = {
    pos = vector3(129.76, -1281.62, 28.27),
    job = "police",
    minGrade = 0,
    stashweight = 10000000,
    slots = 1000,
    label = "Förråd",
  },
}
