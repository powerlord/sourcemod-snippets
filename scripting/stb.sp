/**
 * vim: set ts=4 :
 * =============================================================================
 * Simple Team Balance plugin for FF
 * 
 * Put stb_teams "4" into the corresponding map cfg file (e.g. rats).
 * For maps where the teams are supposed to be uneven (e.g. the TFC map "hunted"),
 * the plugin can be disabled via map cfg file. Put stb_on "0" into the map cfg in
 * cfg/maps/.
 * 
 * Simple Team Balancer (C)2010 pizzahut.
 * Ported to SourceMod by Powerlord (Ross Bemrose).
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

#define VERSION "2.1.5"

#define MINTEAM 2
#define MAXTEAM 5



new Handle:g_stb_on;
new Handle:g_stb_teams;

public Plugin:myinfo = {
	name			= "Simple Team Balance plugin for FF",
	author			= "pizzahut and Powerlord",
	description		= "Balances team for Fortress Forever",
	version			= VERSION,
	url				= "https://forums.alliedmods.net/showthread.php?t=253674"
};
  
public OnPluginStart()
{
	CreateConVar("stb_version", VERSION, "Simple Team Balancer for FF version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_stb_on = CreateConVar("stb_on", "1", "Enable Simple Team Balancer for FF?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	g_stb_teams = CreateConVar("stb_teams", "2", "Number of teams for STB for FF", FCVAR_PLUGIN, true, 2.0, true, 4.0);
	
	AddCommandListener(jointeam, "team");
}

// TODO: Check which teams FF uses.  Most source games use 0 and 1 for connecting and spectator
public Action:jointeam(id, const String:command[], argc)
{
	if (argc == 0)
		return Plugin_Continue; // No team specified
	
	new oldteam = GetClientTeam(id);
	
	new String:Arg1[8];
	GetCmdArg(1, Arg1, sizeof(Arg1));
	new newteam = GetTargetTeam(Arg1);
	
	// Allow team switch if plugin is disabled
	// or player has immunity
	// or old team is invalid/unknown
	// or new team is unassigned (0), spectator (1), auto team (6) or invalid/unknown
	// or old and new team are identical
	// or player is a bot
	
	if (!GetConVarBool(g_stb_on)
	|| CheckCommandAccess(id, "stb", ADMFLAG_CUSTOM1, true)
	|| (oldteam < 0) || (oldteam > MAXTEAM)
	|| ((newteam < MINTEAM) || (newteam > MAXTEAM))
	|| (oldteam == newteam)
	|| IsFakeClient(id) )
		return Plugin_Continue; // Team switch allowed
		
	new HumanCount[MAXTEAM+1], teamnumber;
	new sum;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && !IsFakeClient(i) && !IsClientSourceTV(i))
		{
			teamnumber = GetClientTeam(i);
			if ((MINTEAM <= teamnumber) && (teamnumber <= MAXTEAM))
			{
				HumanCount[teamnumber]++;
				sum++;
			}
		}
	}
	
	// Allow team switch from TEAM_UNASSIGNED to TEAM_SPECTATOR
	if (oldteam < MINTEAM && newteam < MINTEAM)
		return Plugin_Continue; // Team switch allowed
	
	// Allow team switch if switching between regular teams (1 to 4)
	// and the old team has more players than the new one.
	if ((MINTEAM <= oldteam) && (oldteam <= MAXTEAM) && (MINTEAM <= newteam) && (newteam <= MAXTEAM)
	&& (HumanCount[oldteam] > HumanCount[newteam]))
		return Plugin_Continue; // Team switch allowed
		
	// Allow team switch if switching from unassigned/spectator to a regular team
	// and the size of the new team is less or equal than the average.
	if ((oldteam < MINTEAM) && (MINTEAM <= newteam) && (newteam <= MAXTEAM)
	&& ((HumanCount[newteam] * GetConVarInt(g_stb_teams)) <= sum))
		return Plugin_Continue; // Team switch allowed
	
	PrintToChat(id, "Team balancing active, team switch denied.");
	return Plugin_Handled; // Team switch denied
}

GetTargetTeam(const String:teamName[])
{
	if (StrEqual(teamName, "spec"))
	{
		return 1;
	}
	else if (StrEqual(teamName, "blue"))
	{
		return 2;
	}
	else if (StrEqual(teamName, "red"))
	{
		return 3;
	}
	else if (StrEqual(teamName, "yellow"))
	{
		return 4;
	}
	else if (StrEqual(teamName, "green"))
	{
		return 5;
	}
	else if (StrEqual(teamName, "auto"))
	{
		return 6;
	}
	
	return 0;
}