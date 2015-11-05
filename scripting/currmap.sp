#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR ""
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
//#include <cstrike>
//#include <sdkhooks>

//EngineVersion g_Game;

public Plugin myinfo = 
{
    name = "",
    author = PLUGIN_AUTHOR,
    description = "",
    version = PLUGIN_VERSION,
    url = ""
};

public void OnPluginStart()
{
      RegAdminCmd("sm_currmap", Command_Currmap, ADMFLAG_KICK, "show current map");
}

public Action Command_Currmap(client, args)
{
    char map[256]; char displaymap[256];
    GetCurrentMap(map, sizeof(map));
    GetMapDisplayName(map, displaymap, 255);
    ReplyToCommand(client, "Current map: %s", displaymap);
    
    return Plugin_Handled;
}
