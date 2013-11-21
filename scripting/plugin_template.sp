#include <sourcemod>
#pragma semicolon 1

#define VERSION "1.0.0"

new Handle:g_Cvar_Enabled;

public Plugin:myinfo = {
	name			= "",
	author			= "Powerlord",
	description		= "",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("_version", VERSION, " version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("_enable", "1", "Enable  ?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
}
