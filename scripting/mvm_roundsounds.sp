/**
 * vim: set ts=4 :
 * =============================================================================
 * MvM Round Sounds
 * Replace normal round sounds with MvM Round Sounds
 *
 * MvM Round Sounds (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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
#pragma newdecls required

#define VERSION "1.0.0"

enum MvMRoundType:
{
	MvMRoundFirst,
	MvMRoundMid,
	MvMRoundTank,
	MvMRoundLast,
}

enum
{
	TF2GameType_CTF,
	TF2GameType_CP,
	TF2GameType_PL,
	TF2GameType_Arena,
}


ConVar g_Cvar_Enabled;

ConVar g_Cvar_MaxRounds;

int g_nRoundCount = 1;

MvMRoundType g_RoundType = MvMRoundFirst;

bool g_bInWaitingForPlayers;

public Plugin myinfo = {
	name			= "MvM Round Sounds",
	author			= "Powerlord",
	description		= "",
	version			= VERSION,
	url				= ""
};

public void OnPluginStart()
{
	CreateConVar("mvmroundsounds_version", VERSION, "MvM Round Sounds version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("mvmroundsounds_enable", "1", "Enable MvM Round Sounds?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);

	
	
	
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_win", Event_RoundEnd);
	HookEvent("teamplay_broadcast_audio", Event_BroadcastAudio, EventHookMode_Pre);
	
}

public void OnMapStart()
{
	// Make sure the MvM music is precached
	PrecacheScriptSound("music.mvm_start_wave");
	PrecacheScriptSound("music.mvm_start_mid_wave");
	PrecacheScriptSound("music.mvm_start_tank_wave");
	PrecacheScriptSound("music.mvm_start_last_wave");
	PrecacheScriptSound("music.mvm_end_wave");
	PrecacheScriptSound("music.mvm_end_tank_wave");
	PrecacheScriptSound("music.mvm_end_mid_wave");
	PrecacheScriptSound("music.mvm_end_last_wave");
	PrecacheScriptSound("music.mvm_lost_wave");
	
	g_RoundType = MvMRoundFirst;
	g_nRoundCount = 1;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_Cvar_Enabled.BoolValue || GameRules_GetProp("m_bInWaitingForPlayers"))
		return;
	
	
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	// Was this the last stage of a multi-stage map?
	if (!g_Cvar_Enabled.BoolValue)
		return;
	
	bool bWasFullRound = event.GetBool("full_round");
	
	int remainingTime;
	
	GetMapTimeLeft(remainingTime);
	
	g_nRoundCount++;
	
	if (!bWasFullRound)
	{
		// The next round will be the last round
		if (g_nRoundCount == g_Cvar_MaxRounds.IntValue)
		{
			g_RoundType = MvMRoundLast;
			return;
		}
		
		if (GameRules_GetProp("m_nGameType") == TF2GameType_Arena)
		{
			// The next round will *probably* be the last round
			if (remainingTime <= 120)
			{
				g_RoundType = MvMRoundLast;
				return;
			}
		}
		else
		{
			// The next round will *probably* be the last round
			if (remainingTime <= 600)
			{
				g_RoundType = MvMRoundLast;
				return;
			}
			
		}
	}
}

public Action Event_BroadcastAudio(Event event, const char[] name, bool dontBroadcast)
{
	//int team = event.GetInt("team");
	char sample[PLATFORM_MAX_PATH];
	event.GetString("sound", sample, sizeof(sample));
	
	if (StrEqual(sample, "Game.YourTeamLost", false))
	{
		event.SetString("sound", "music.mvm_lost_wave");
	}
	else
	if (StrEqual(sample, "Game.YourTeamWon", false))
	{
		switch (g_RoundType)
		{
			case MvMRoundFirst:
			{
				event.SetString("sound", "music.mvm_end_wave");
			}
			
			case MvMRoundMid:
			{
				event.SetString("sound", "music.mvm_end_mid_wave");
			}
			
			case MvMRoundTank:
			{
				event.SetString("sound", "music.mvm_end_tank_wave");
			}
			
			case MvMRoundLast:
			{
				event.SetString("sound", "music.mvm_end_last_wave");
			}
		}
	}
	return Plugin_Continue;
}

