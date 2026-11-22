fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'm-jobstashes'
author 'Magistern/Miruvo'
description 'Old ass Jobstashes (Updated)'
version '2.0.0'

files {
  'locales/*.json',
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'init.lua',
  'source/shared/*.lua',
}

client_scripts {
  'configuration/frameworks/**/client.lua',
  'configuration/frameworks/custom/custom.lua',
  'configuration/bridge/client.lua',
  'source/client/selection.lua',
  'source/client/main.lua',
}

server_scripts {
  'source/server/boot.lua',
}

dependencies {
  'ox_lib',
  'ox_inventory',
}

escrow_ignore {
  'config.lua',
  'init.lua',
  'configuration/**/*.lua',
  'locales/*.json',
}
