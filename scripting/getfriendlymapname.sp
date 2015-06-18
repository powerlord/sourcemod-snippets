/**
 * vim: set ts=4 :
 * =============================================================================
 * Get Friendly Map Name
 * Retrieve and display a friendly map name
 *
 * Get Friendly Map Name (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

//ConVar g_Cvar_Enabled;

public Plugin myinfo = {
	name			= "Get Friendly Map Name",
	author			= "Powerlord",
	description		= "Retrieve and display a friendly map name",
	version			= VERSION,
	url				= ""
};

public void OnPluginStart()
{
//	CreateConVar("_version", VERSION, " version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
//	g_Cvar_Enabled = CreateConVar("_enable", "1", "Enable ?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
	RegConsoleCmd("friendlyname", Cmd_FriendlyName, "Display the current map's friendly name");
}

public Action Cmd_FriendlyName(int client, int args)
{
	char map[PLATFORM_MAX_PATH];
	char friendlyName[PLATFORM_MAX_PATH];
	
	GetCurrentMap(map, sizeof(map));
	
	GetFriendlyMapName(map, friendlyName, sizeof(friendlyName));
	
	ReplyToCommand(client, "\"%s\" friendly name is \"%s\"", map, friendlyName);
	
	return Plugin_Handled;
}

/**
 * This is used to get the Friendly name for a Workshop map.  Used for the display name in a map vote.
 * 
 * Note: non-Workshop maps will be ignored.
 * 
 * @param resolvedMap		A map name returned from ResolveFuzzyMapName
 * @param friendlyName		The map name with the extra workshop path bits removed
 * @param maxlength			The max length of friendlyName
 * 							(We recommend PLATFORM_MAX_PATH)
 * @param bIsMapResolved	True if map is a resolved Fuzzy Name, false if we need to resolve it first.
 * 							Convenience field for plugins that don't need the resolved map name.
 */
stock void GetFriendlyMapName(const char[] resolvedMap, char[] friendlyName, int maxlength, bool bIsMapResolved=true)
{
	char szTmp[PLATFORM_MAX_PATH];

	if (bIsMapResolved || !ResolveFuzzyMapName(resolvedMap, szTmp, sizeof(szTmp)))
	{
		strcopy(szTmp, sizeof(szTmp), resolvedMap);
	}
	
	EngineVersion version = GetEngineVersion();
	switch (version)
	{
		case Engine_TF2:
		{
			int ugcPos;
			
			// In TF2, workshop maps show up as workshop/mapname.ugc123456789
			if (strncmp(szTmp, "workshop/", 9) == 0 && (ugcPos = StrContains(szTmp, ".ugc")) > -1)
			{
				// technically, this is (ugcPos + 1) - 9, but lets just cancel the 1.
				strcopy(friendlyName, maxlength < ugcPos - 8 ? maxlength : ugcPos - 8, szTmp[9]);
				return;
			}
		}
		
		case Engine_CSGO:
		{
			int lastSlashPos;
			if (strncmp(szTmp, "workshop/", 9) == 0 && (lastSlashPos = FindCharInString(szTmp, '/', true)) > 9)
			{
				int newlength = strlen(szTmp) - lastSlashPos;
				strcopy(friendlyName, maxlength < newlength ? maxlength : newlength, szTmp[lastSlashPos+1]);
				return;
			}
		}
	}
	
	// Fallback to just copying the name back to itself
	strcopy(friendlyName, maxlength, szTmp);
}
