/**
 * vim: set ts=4 :
 * =============================================================================
 * Timer Get
 * Get the time from the game timers
 *
 * Timer Get (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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
#include "include/tf2_morestocks"

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

public Plugin myinfo = {
	name			= "Timer Get",
	author			= "Powerlord",
	description		= "Get the time from the game timers",
	version			= VERSION,
	url				= ""
};

public void OnPluginStart()
{
	CreateConVar("tiemr_get_version", VERSION, "Timer Get version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegAdminCmd("timer_get", Cmd_TimerGet, ADMFLAG_GENERIC, "Get the current round time");
}

public Action Cmd_TimerGet(int client, int args)
{
	int timeleft;
	
	TF2TimerState state = TF2_GetRoundTimeLeft(timeleft);
	
	switch (state)
	{
		case TF2TimerState_NotApplicable:
		{
			ReplyToCommand(client, "Round time is not applicable.");
		}
		
		case TF2TimerState_WaitingForPlayers:
		{
			ReplyToCommand(client, "Waiting for Players has %d seconds left.", timeleft);
		}
		
		case TF2TimerState_Overtime:
		{
			ReplyToCommand(client, "Overtime has %d seconds left.", timeleft);
		}
		
		case TF2TimerState_Setup:
		{
			ReplyToCommand(client, "Setup time has %d seconds left.", timeleft);
		}
		
		case TF2TimerState_Paused:
		{
			ReplyToCommand(client, "Timer is paused at %d seconds left.", timeleft);
		}
		
		case TF2TimerState_KothRedActive:
		{
			ReplyToCommand(client, "Koth RED clock active with %d seconds left.", timeleft);
		}
		
		case TF2TimerState_KothBlueActive:
		{
			ReplyToCommand(client, "Koth BLU clock active with %d seconds left.", timeleft);
		}
		
		default:
		{
			ReplyToCommand(client, "Round time left: %d", timeleft);
		}			
	}
	
}
