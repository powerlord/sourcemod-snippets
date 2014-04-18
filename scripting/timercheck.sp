/**
 * vim: set ts=4 :
 * =============================================================================
 * Timer Check
 * Description
 *
 * Timer Check (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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
#include <sdktools>
#pragma semicolon 1

#define VERSION "1.0.0"

//new Handle:g_Cvar_Enabled;

public Plugin:myinfo = {
	name			= "Timer Check",
	author			= "Powerlord",
	description		= "Diagnostic plugin to check team_round_timer names and things",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("timercheck_version", VERSION, "Timer Check version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
//	g_Cvar_Enabled = CreateConVar("checkroundstate_enable", "1", "Enable Timer Check?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	RegAdminCmd("timercheck", Cmd_FindTimers, ADMFLAG_GENERIC, "Print Timer State");
}

public Action:Cmd_FindTimers(client, args)
{
	new timerEnt = -1;
	
	while ((timerEnt = FindEntityByClassname(timerEnt, "team_round_timer")) != -1)
	{
		if (!IsValidEntity(timerEnt))
		{
			continue;
		}
		
		decl String:name[128];
		GetEntPropString(timerEnt, Prop_Data, "m_iName", name, sizeof(name));
		
		ReplyToCommand(client, "Timer %d: %s", timerEnt, name);
	}
	
	return Plugin_Handled;
}
