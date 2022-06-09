# damageblocklist

This sourcemod plugin allows you to specify a list of weapon entities from which no damage will be taken.

This has only been tested with CS:GO, but could possibly work with other games.

## Configuration

### Convars

**sm_damageblocklist_enable**: 0 to disable, 1 to enable (default 0)

**sm_damageblocklist_debug**: 0 for normal operation, 1 to print debug information (default 0)

**sm_damageblocklist_file**: path to file containing a newline-separated list of entities which will not deal damage

**sm_damageblocklist_immediate**: 0 to wait til next round to apply blocklist, 1 to apply immediately on enable (default 0)

### File format

The file is a newline-separated list of entities which will not deal damage, e.g.

```
weapon_glock
weapon_hkp2000
weapon_knife
```

The convar `sm_damageblocklist_file` is specified relative to the root directory of the server, e.g. `csgo`.

A list of weapon entities can be found [here](https://developer.valvesoftware.com/wiki/List_of_Counter-Strike:_Global_Offensive_Entities).

If you enable `sm_damageblocklist_debug`, entity names will be printed to the console when damage is allowed or prevented.
