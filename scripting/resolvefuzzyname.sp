/**
 * vim: set ts=4 :
 * =============================================================================
 * Resolve Fuzzy Map Name
 * Tests out the new native
 *
 * Resolve Fuzzy Map Name (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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

public Plugin myinfo = {
	name			= "Resolve Fuzzy Map Name",
	author			= "Powerlord",
	description		= "Tests out the new native",
	version			= VERSION,
	url				= ""
};

public void OnPluginStart()
{
	CreateConVar("resolvefuzzyname_version", VERSION, "Resolve Fuzzy Map Name version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegAdminCmd("mappath", Cmd_MapPath, ADMFLAG_GENERIC, "Print out a map's full path");
}

public Action Cmd_MapPath(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: mappath <mapentry>");
		return Plugin_Handled;
	}
	
	char map[PLATFORM_MAX_PATH];
	GetCmdArg(1, map, sizeof(map));
	
	if (!IsMapValid(map))
	{
		ReplyToCommand(client, "%s is not a valid map", map);
		return Plugin_Handled;
	}
	
	char output[PLATFORM_MAX_PATH];
	
	if (ResolveFuzzyMapName(map, output, sizeof(output)))
	{
		ReplyToCommand(client, "%s's real path is %s", map, output);
	}
	else
	{
		ReplyToCommand(client, "%s is the full path.", map);
	}
	
	
	return Plugin_Handled;
}