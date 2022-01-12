#include <sourcemod>
#include <convars>
#include <autoexecconfig>
#include <adt_array>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
    name = "damageblocklist",
    author = "tmick0",
    description = "Allows to specify a list of weapons which will do no damage",
    version = "0.1",
    url = "github.com/tmick0/sm_damageblocklist"
};

#define CVAR_FILTERENABLE "sm_damageblocklist_enable"
#define CVAR_FILTERFILEPATH "sm_damageblocklist_file"

#define ENTITY_NAME_MAX 128

// convars
ConVar CvarFilterFilePath;
ConVar CvarFilterEnable;

// plugin state
ArrayList FilterEntities;
int FilterEnable;

public void OnPluginStart() {
    // init config
    AutoExecConfig_SetCreateDirectory(true);
    AutoExecConfig_SetCreateFile(true);
    AutoExecConfig_SetFile("plugin_damageblocklist");
    CvarFilterFilePath = AutoExecConfig_CreateConVar(CVAR_FILTERFILEPATH, "", "path to list of entities to block damage from");
    CvarFilterEnable = AutoExecConfig_CreateConVar(CVAR_FILTERENABLE, "0", "enable (1) or disable (0) the plugin");
    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();

    // init hooks
    HookConVarChange(CvarFilterFilePath, ReloadFilterFile);
    HookConVarChange(CvarFilterEnable, UpdateState);
    HookEvent("player_spawn", AddHookToPlayer);

    // load filter
    LoadFilter();
}

public Action AddHookToPlayer(Handle event, const char[] name, bool dontBroadcast) {
    if (!FilterEnable) {
        return Plugin_Continue;
    }

    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    return Plugin_Handled;
}

public Action OnTakeDamage(int victim, int& attacker, int &inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3])
{
    if (!FilterEnable) {
        return Plugin_Continue;
    }

    if (weapon < 0) {
        return Plugin_Continue;
    }

    char entity[ENTITY_NAME_MAX];
    GetEdictClassname(weapon, entity, ENTITY_NAME_MAX);

    if (FilterEntities.FindString(entity) == -1) {
        return Plugin_Continue;    
    }
    
    damage = 0.0;
    return Plugin_Changed;
}


void ReloadFilterFile(ConVar convar, const char[] oldvalue, const char[] newvalue) {
    LoadFilter();
}

void UpdateState(ConVar convar, const char[] oldvalue, const char[] newvalue) {
    FilterEnable = GetConVarInt(CvarFilterEnable);
}

void LoadFilter() {
    char FilterFilePath[PLATFORM_MAX_PATH];
    GetConVarString(CvarFilterFilePath, FilterFilePath, PLATFORM_MAX_PATH);
    FilterEntities = new ArrayList(ENTITY_NAME_MAX);
    
    if (strlen(FilterFilePath) == 0) {
        LogMessage("no entity damage filter file specified");
        return;
    }

    Handle fh = OpenFile(FilterFilePath, "r");
    if (fh == INVALID_HANDLE) {
        LogMessage("failed to open entity damage filter file");
        return;
    }

    int count = 0;
    char line[ENTITY_NAME_MAX];
    while (ReadFileLine(fh, line, ENTITY_NAME_MAX)) {
        TrimString(line);
        if (strlen(line) > 0 && line[0] != '#') {
            FilterEntities.PushString(line);
            ++count;
        }
    }
    LogMessage("loaded %d entries from entity damage filter file <%s>", count, FilterFilePath);

    CloseHandle(fh);
}
