# m-jobstashes

Job stashes for ox_inventory. You put a stash somewhere on the map, give it a job and a minimum grade, and only people with that job can open it. That's pretty much it.

This started as an old script of mine that honestly wasn't great. The access check only lived in my own event, so anyone with a mod menu could open any stash straight through ox_inventory. That's fixed now, ox_inventory itself checks the job, grade and distance every time someone opens a stash, so there's nothing in this resource left to abuse.

Other stuff that changed while I was at it:

- Markers only show for people with the right job, so randoms can't find your gang stash by walking around.
- It doesn't run anything when you're not near a stash.
- The open key can be rebound in the FiveM keybind settings.
- Works on Qbox, QBCore and ESX.
- English and Swedish included.
- If you mess up a stash in the config, the console tells you which one and what's wrong, and that stash just doesn't load. It won't end up open for everyone.

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- qbx_core, qb-core or es_extended

## Installation

1. Download the latest release, or clone the repo:
   ```
   git clone https://github.com/themiruvo/m-jobstashes.git
   ```
2. Put the `m-jobstashes` folder in your resources.
3. Add it to your `server.cfg` after its dependencies:
   ```
   ensure ox_lib
   ensure yourframework
   ensure ox_inventory
   ensure m-jobstashes
   ```
4. Set up your stashes in `config.lua`.
5. Restart the server. You should see the script start up in the console along with how many stashes it registered.

## Config

Everything is in `config.lua`.

```lua
Config.Framework = 'auto'        -- 'auto', 'qbox', 'qbcore', 'esx', or false to show markers to everyone
Config.Locale = 'en'             -- 'en' or 'sv'
Config.Key = 'E'                 -- default key, players can rebind it
Config.DrawDistance = 25.0       -- how close you need to be to see the marker
Config.InteractDistance = 1.6    -- how close you need to be to open it
```

A stash looks like this:

```lua
Config.locations = {
  ['police_main'] = {
    pos = vector3(441.8, -996.6, 30.7),
    job = 'police',
    minGrade = 2,          -- optional, default 0
    stashweight = 500000,  -- optional, in grams, default 50000
    slots = 100,           -- optional, default 50
    label = 'Armory',      -- optional
  },
}
```

`pos` and `job` are required, the rest is optional. Give your stashes proper names like `police_main` instead of `stash1` so they don't clash with stashes from other scripts.

`Config.Framework` only decides who can see the markers. Who can actually open a stash is always checked by ox_inventory on the server, whatever you set here.

## Changing the text UI

If you use something other than ox_lib's text UI, edit `configuration/bridge/client.lua`. It has three small functions: show the prompt, hide it, and open the stash. Swap them for whatever you use. If something in there errors, it gets printed in F8 and the rest of the script keeps going.

## Adding a language

Copy `locales/en.json`, translate it, save it as something like `locales/de.json` and set `Config.Locale = 'de'`. Leave the `%s` bits where they are.

## Problems

Open an issue and include your framework, your ox_inventory version and whatever the server console says when the script starts.
