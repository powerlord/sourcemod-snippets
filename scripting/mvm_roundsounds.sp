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
#include <tf2>

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

int g_GameRules = -1;

bool g_bDontInterruptBroadcast = false;

public Plugin myinfo = {
	name			= "MvM Round Sounds",
	author			= "Powerlord",
	description		= "Replace normal round sounds with MvM Round Sounds",
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
	g_RoundType = MvMRoundFirst;
	g_nRoundCount = 1;
	g_GameRules = -1;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_Cvar_Enabled.BoolValue || GameRules_GetProp("m_bInWaitingForPlayers"))
		return;
	
	// Round type is selected on round end.
	// This is so we can guess if the next round is the last round
	// Also, so start and end round music matches
	switch (g_RoundType)
	{
		case MvMRoundFirst:
		{
			PlayNewSound(0, "music.mvm_start_wave");
		}
		
		case MvMRoundMid:
		{
			PlayNewSound(0, "music.mvm_start_mid_wave");
		}
		
		case MvMRoundTank:
		{
			PlayNewSound(0, "music.mvm_start_tank_wave");
		}
		
		case MvMRoundLast:
		{
			PlayNewSound(0, "music.mvm_start_last_wave");
		}
	}
	
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	// Was this the last stage of a multi-stage map?
	if (!g_Cvar_Enabled.BoolValue || GameRules_GetProp("m_bInWaitingForPlayers"))
		return;
	
	bool bWasFullRound = event.GetBool("full_round");
	
	int remainingTime;
	
	GetMapTimeLeft(remainingTime);
	
	g_nRoundCount++;
	
	if (bWasFullRound)
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
			g_RoundType = RandomMidRoundType();
		}
	}
	else
	{
		g_RoundType = RandomMidRoundType();
	}
}

// Tank round is rarer.
MvMRoundType RandomMidRoundType()
{
	int rand = GetRandomInt(1, 5);
	if (rand == 1)
	{
		return MvMRoundTank;
	}
	else
	{
		return MvMRoundMid;
	}
}

public Action Event_BroadcastAudio(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_Cvar_Enabled.BoolValue || g_bDontInterruptBroadcast)
		return Plugin_Continue;
		
	int team = event.GetInt("team");
	char sample[PLATFORM_MAX_PATH];
	event.GetString("sound", sample, sizeof(sample));
	
	if (StrEqual(sample, "Game.YourTeamLost", false))
	{
		QueueNewSound(team, "music.mvm_lost_wave");
		return Plugin_Stop;
	}
	else
	if (StrEqual(sample, "Game.YourTeamWon", false))
	{
		switch (g_RoundType)
		{
			case MvMRoundFirst:
			{
				QueueNewSound(team, "music.mvm_end_wave");
			}
			
			case MvMRoundMid:
			{
				QueueNewSound(team, "music.mvm_end_mid_wave");
			}
			
			case MvMRoundTank:
			{
				QueueNewSound(team, "music.mvm_end_tank_wave");
			}
			
			case MvMRoundLast:
			{
				QueueNewSound(team, "music.mvm_end_last_wave");
			}
		}
		return Plugin_Stop;		
	}
	return Plugin_Continue;
}

/**
 * Delay a new sound by 0.1 second.
 * This is to make sure we aren't firing an event/UserMessage from inside another event/UserMessage.
 * 
 * @param team		Which team are we playing the sound for. 0 = all teams
 * @param sound		What sound are we playing? For broadcast sounds, this is the name from a gamesounds file
 * 					For normal sounds, this is the filepath inside sound/
 * @param broadcast	Is this a broadcast sound?
 * @noreturn
 */
void QueueNewSound(int team, const char[] sound, bool broadcast=true)
{
	DataPack data;
	CreateDataTimer(0.1, Timer_PlayNewSound, data, TIMER_FLAG_NO_MAPCHANGE);
	data.WriteCell(team);
	data.WriteString(sound);
	data.WriteCell(broadcast);
	data.Reset();
}

public Action Timer_PlayNewSound(Handle timer, DataPack data)
{
	int team = data.ReadCell();
	
	char sound[PLATFORM_MAX_PATH];
	data.ReadString(sound, sizeof(sound));
	
	bool broadcast = data.ReadCell();
	
	PlayNewSound(team, sound, broadcast);
}

/**
 * This function plays either a broadcast sound or a regular sound sample
 * 
 * @param team		Which team are we playing the sound for. 0 = all teams
 * @param sound		What sound are we playing? For broadcast sounds, this is the name from a gamesounds file
 * 					For normal sounds, this is the filepath inside sound/
 * @param broadcast	Is this a broadcast sound?
 * @noreturn
 */

stock void PlayNewSound(int team, const char[] sound, bool broadcast=true)
{
	if (broadcast)
	{
		if (g_GameRules == -1)
		{
			FindGameRules();
		}
		
		if (EntRefToEntIndex(g_GameRules) == INVALID_ENT_REFERENCE)
		{
			FindGameRules();
		}
		
		PrecacheScriptSound(sound);
		
		g_bDontInterruptBroadcast = true;
		
		Event playSound = CreateEvent("teamplay_broadcast_audio");
		playSound.SetInt("team", team);
		playSound.SetString("sound", sound);
		playSound.Fire();
		
		g_bDontInterruptBroadcast = false;
	}
	else
	{
		if (!IsSoundPrecached(sound))
		{
			PrecacheSound(sound);
		}
		
		if (team == 0)
		{
			EmitSoundToAll(sound);
		}
		else
		{
			int[] clients = new int[MaxClients];
			int count = 0;
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) == team)
				{
					clients[count++] = i;
				}
			}
			
			EmitSound(clients, count, sound);
		}
	}
}

/**
 * Finds the tf_gamerules entity
 * 'cause I didn't want to stick this code in multiple spots.
 * 
 * @noreturn
 */
stock void FindGameRules()
{
	g_GameRules = EntIndexToEntRef(FindEntityByClassname(-1, "tf_gamerules"));
}