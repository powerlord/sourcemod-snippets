#include <sourcemod>
#include <tf2items>

#pragma semicolon 1

#define VERSION "1.0.1"

new Handle:g_Cvar_Enabled;

public Plugin:myinfo = {
	name			= "Check Items",
	author			= "Powerlord",
	description		= "Check Items test stuff",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("checkitems_version", VERSION, "CheckItems version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("checkitems_enabled", "1", "Enable CheckItems?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if (CheckCommandAccess(client, "checkitem", ADMFLAG_KICK, true))
	{
		if (StrEqual(classname, "tf_weapon_spellbook", false))
		{
			PrintToChat(client, "Attempting to block Spellbook");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public TF2Items_OnGiveNamedItem_Post(client, String:classname[], itemDefinitionIndex, itemLevel, itemQuality, entityIndex)
{
	if (!GetConVarBool(g_Cvar_Enabled))
	{
		return;
	}
	
	if (CheckCommandAccess(client, "checkitem", ADMFLAG_KICK, true))
	{
		PrintToChat(client, "Given item %s, %d", classname, itemDefinitionIndex);
	}
}
