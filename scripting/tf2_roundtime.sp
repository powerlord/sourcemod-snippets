#include <sourcemod>
#include <sdktools>
#include <tf2>

#define VERSION "1.1"

new Handle:g_Cvar_Enabled;
new Handle:g_Cvar_Seconds;
new bool:g_bValidMap;

public Plugin:myinfo = 
{
	name = "TF2 Round Time Limiter",
	author = "Powerlord",
	description = "Plugin to limit the round max time on A/D CP, 5CP, and PL maps",
	version = VERSION,
	url = ""
}

public OnPluginStart()
{
	CreateConVar("tf2_roundtime_version", VERSION, "TF2 Round Time Limiter version", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_Cvar_Enabled = CreateConVar("tf2_roundtime_enabled", "1", "Is TF2 Round Time Limiter enabled?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_Cvar_Seconds = CreateConVar("tf2_roundtime_limit", "300", "Time to limit round timers to, in seconds", FCVAR_NOTIFY, true, 30.0);
	
	HookEvent("teamplay_round_start", Event_RoundStart);
	
	AutoExecConfig(true, "tf2_roundtime");
}

public OnMapStart()
{
	g_bValidMap = false;
}

public TF2_OnWaitingForPlayersEnd()
{
	decl String:mapName[64];
	GetCurrentMap(mapName, sizeof(mapName));

	g_bValidMap = IsCorrectMap(mapName);
}

// IsValidMap is already a SourceMod function
bool:IsCorrectMap(const String:mapName[])
{
	new String:nameParts[1][8];
	ExplodeString(mapName, "_", nameParts, sizeof(nameParts), sizeof(nameParts[]));
	
	if (StrEqual(nameParts[0], "cp", false) || StrEqual(nameParts[0], "5cp", false) || StrEqual(nameParts[0], "pl", false))
	{
		return true;
	}
	
	return false;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bValidMap || !GetConVarBool(g_Cvar_Enabled))
	{
		return;
	}
	
	new timer = -1;
	while ((timer = FindEntityByClassname(timer, "team_round_timer")) != -1)
	{
		SetVariantInt(GetConVarInt(g_Cvar_Seconds));
		AcceptEntityInput(timer, "SetMaxTime");
	}
}
