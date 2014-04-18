/**
 * vim: set ts=4 :
 * =============================================================================
 * Check Round State
 * Description
 *
 * Check Round State (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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
	name			= "Check Round State",
	author			= "Powerlord",
	description		= "Diagnostic plugin to check the current RoundState value",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("checkroundstate_version", VERSION, "Check Round State version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
//	g_Cvar_Enabled = CreateConVar("checkroundstate_enable", "1", "Enable Check Round State?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	RegAdminCmd("roundstate", Cmd_RoundState, ADMFLAG_GENERIC, "Print Round State");
}

public Action:Cmd_RoundState(client, args)
{
	decl String:stateName[64];
	new RoundState:roundState = GameRules_GetRoundState();
	RoundStateToString(roundState, stateName, sizeof(stateName));
	
	ReplyToCommand(client, "Round State is: %s (%d)", stateName, _:roundState);
	return Plugin_Handled;
}

RoundStateToString(RoundState:roundState, String:stateName[], maxlength)
{
	switch(roundState)
	{
		case RoundState_Init:
		{
			strcopy(stateName, maxlength, "Init");
		}
		
		case RoundState_Pregame:
		{
			strcopy(stateName, maxlength, "Pregame");
		}
		
		case RoundState_StartGame:
		{
			strcopy(stateName, maxlength, "Start Game");
		}
		
		case RoundState_Preround:
		{
			strcopy(stateName, maxlength, "Pre-round");
		}
		
		case RoundState_RoundRunning:
		{
			strcopy(stateName, maxlength, "Round Running");
		}
		
		case RoundState_TeamWin:
		{
			strcopy(stateName, maxlength, "Team Win");
		}
		
		case RoundState_Restart:
		{
			strcopy(stateName, maxlength, "Restart");
		}
		
		case RoundState_Stalemate:
		{
			strcopy(stateName, maxlength, "Stalemate");
		}
		
		case RoundState_GameOver:
		{
			strcopy(stateName, maxlength, "Game Over");
		}
		
		case RoundState_Bonus:
		{
			strcopy(stateName, maxlength, "Bonus");
		}
		
		case RoundState_BetweenRounds:
		{
			strcopy(stateName, maxlength, "Between Rounds");
		}
		
		default:
		{
			strcopy(stateName, maxlength, "Unknown");
		}
	}
}