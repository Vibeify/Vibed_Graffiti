# FiveM Graffiti System - Installation Guide

This resource allows players to tag walls with spray can animations and gangs to claim turf on your FiveM server.

## Features

  - Dynamic graffiti tagging system
  - Gang territory system with visual indicators
  - Customizable designs, colors, and text
  - Realistic spray animations
  - Turf war notifications

-----

## Installation

1.  Extract the `graffiti_system` folder to your server's resources directory.
2.  Add `ensure graffiti_system` to your `server.cfg`.
3.  Create spray can items in your inventory system.
4.  Restart your server.

-----

## Configuration

All configuration options can be found in `config.lua`:

  * `Config.GangTurf`: Define gang territories and their boundaries.
  * `Config.SprayCanItem`: The item name required for spraying.
  * `Config.SprayDuration`: How long it takes to spray in milliseconds.
  * `Config.GraffitiLifetime`: How long graffiti stays visible (in hours).
  * `Config.GraffitiDesigns`: Available graffiti designs and textures.

-----

## Framework Integration

The script includes placeholder functions for compatibility with different frameworks:

  * `GetPlayer(source)`: Returns player data from your framework.
  * `HasItem(source, item)`: Checks if a player has an item.
  * `RemoveItem(source, item, count)`: Removes an item from player inventory.

**Edit these functions in `config.lua` to match your framework (ESX, QBCore, or `ox_inventory`).**

### ESX Example

```lua
function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function HasItem(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(item)
    return item and item.count > 0
end

function RemoveItem(source, item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(item, count)
end
```

### QBCore Example

```lua
function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function HasItem(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local itemData = Player.Functions.GetItemByName(item)
    return itemData and itemData.amount > 0
end

function RemoveItem(source, item, count)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(item, count or 1)
end
```

### ox inventory Example

```lua
function GetPlayer(source)
    return source -- ox_inventory functions typically work directly with the player's server ID.
end

function HasItem(source, item)
    -- This checks if the player has any quantity of the specified item.
    local items = exports.ox_inventory:Search(source, 'slots', item)
    return items and #items > 0
end

function RemoveItem(source, item, count)
    -- Removes the specified 'count' of the 'item' from the player's inventory.
    exports.ox_inventory:RemoveItem(source, item, count or 1) -- 'count or 1' ensures at least 1 item is removed if 'count' isn't specified.
end
```

-----

## ox inventory Setup

To use this graffiti system with `ox_inventory`, add the following to your `items.lua` in the `ox_inventory` resource:

```lua
['spray_can'] = {
    label = 'Spray Can',
    weight = 200,
    stack = true,
    close = true,
    description = 'A can of spray paint for graffiti tagging.'
},
```

  * Make sure the item name matches `Config.SprayCanItem` in `config.lua`.
  * Restart your server or reload `ox_inventory` after adding the item.

-----

## Usage

1.  In-game, equip a spray can item.
2.  Use the `/tag` command to open the tagging interface.
3.  Select a design, color, and enter text.
4.  Click "Spray Tag" to create your tag.

For gang tags, select your gang from the dropdown to claim territory.

-----

## Adding Custom Designs

1.  Add new design entries to `Config.GraffitiDesigns` in `config.lua`.
2.  Create texture images (PNG format) and place them in `html/images/`.
3.  Add any CSS styling needed for the new design in `html/graffiti.html`.

-----

## Dependencies

  * None required, but designed to work with:
      * **ESX** or **QBCore** for inventory management.
      * Any progress bar script (default configuration uses the `progressbar` export).

-----

## Credits

Created by Vibeify
Support or other Questions: [https://discord.gg/7AcwrDfuPv](https://discord.gg/7AcwrDfuPv)