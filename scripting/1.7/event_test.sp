/**
 * vim: set ts=4 :
 * =============================================================================
 * SM 1.7 Event Testing
 * Test changes made to SM 1.7's Event syntax.
 *
 * SM 1.7 Event Testing (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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

// Valve likes to change this value, was -1 before mid-Oct update
#define ALL_TEAMS 0

ConVar g_Cvar_Enabled;

public Plugin myinfo = {
	name			= "SM 1.7 Event Testing",
	author			= "Powerlord",
	description		= "Test changes made to SM 1.7's Event syntax.",
	version			= VERSION,
	url				= ""
};
  
public void OnPluginStart()
{
	CreateConVar("event_test_version", VERSION, "Event Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("event_test_enable", "1", "Enable Event Test?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);

	HookEvent("teamplay_round_win", Event_RoundWin);
	
	RegAdminCmd("audio", Cmd_Audio, ADMFLAG_GENERIC, "Send a broadcast audio cue to all players.");
	
}

public void OnPluginEnd()
{
	UnhookEvent("teamplay_round_win", Event_RoundWin);
}

public void Event_RoundWin(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		return;
	}
	
	int team = event.GetInt("team");
	float roundTime = event.GetFloat("round_time");
	if (dontBroadcast)
	{
		event.SetBroadcast(!dontBroadcast);
	}
	PrintToChatAll("Team won: %s, round time: %f", team, roundTime);
}

public Action Cmd_Audio(int client, int args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled.");
		return Plugin_Handled;
	}
	
	Event event = Event("teamplay_broadcast_audio");
	
	event.SetInt("team", ALL_TEAMS);
	event.SetString("sound", "Announcer.Success");
	event.SetInt("additional_flags", 0);
	event.Fire();
	
	return Plugin_Handled;
}
