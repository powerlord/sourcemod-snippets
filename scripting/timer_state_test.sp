/**
 * vim: set ts=4 :
 * =============================================================================
 * Timer State Test
 * See if a timer's m_nState tells you whether we're currently in Setup
 *
 * Timer State Test (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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

public Plugin:myinfo = {
	name			= "Timer State Test",
	author			= "Powerlord",
	description		= "See if a timer's m_nState tells you whether we're currently in Setup",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("timerstatetest_version", VERSION, "Timer State Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegConsoleCmd("timerstate", Cmd_TimerState, "Check a timer's state");
}

public Action:Cmd_TimerState(client, args)
{
	new timer = -1;
	new bool:found = false;
	// Maps may have multiple timers, e.g. tc_hydro
	while (!found && (timer = FindEntityByClassname(timer, "team_round_timer")) != -1)
	{
		// Check if this is the active timer
		new bool:bShowInHUD = bool:GetEntProp(timer, Prop_Send, "m_bShowInHUD");
		if (bShowInHUD)
		{
			// It IS the active timer, so check its time left
			found = true;
			ReplyToCommand(client, "Current timer %d state is %d, with %d seconds left", timer, GetEntProp(timer, Prop_Send, "m_nState"), GetTimeRemaining(timer));
		}
	}
	
	new RoundState:state = GameRules_GetRoundState();
	ReplyToCommand(client, "Current round state is %d", _:state);
	
	return Plugin_Handled;
}

stock GetTimeRemaining(timer)
{
	if (!IsValidEntity(timer))
	{
		return -1;
	}
	
	decl String:classname[64];
	GetEntityClassname(timer, classname, sizeof(classname));
	if (strcmp(classname, "team_round_timer") != 0)
	{
		return -1;
	}
	
	new Float:flSecondsRemaining;
	
	if (GetEntProp(timer, Prop_Send, "m_bStopWatchTimer") && GetEntProp(timer, Prop_Send, "m_bInCaptureWatchState"))
	{
		flSecondsRemaining = GetEntPropFloat(timer, Prop_Send, "m_flTotalTime");
	}
	else
	{
		if (GetEntProp(timer, Prop_Send, "m_bTimerPaused"))
		{
			flSecondsRemaining = GetEntPropFloat(timer, Prop_Send, "m_flTimeRemaining");
		}
		else
		{
			flSecondsRemaining = GetEntPropFloat(timer, Prop_Send, "m_flTimerEndTime") - GetGameTime();
		}
	}
	
	return RoundFloat(flSecondsRemaining);
}
