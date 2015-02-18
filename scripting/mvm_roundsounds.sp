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
	TF2GameType_Unknown,
	TF2GameType_CTF,
	TF2GameType_CP,
	TF2GameType_PL,
	TF2GameType_Arena,
}

// Note: The following types are not separate game modes per se and you should do separate checks for them:
// * Medieval
// * MannPower
// Hybrid CTF/CP should also be detected separately as only the main mode is detected.
// Other than KOTH, the various CP types are technically not their own types either.
// TC, in particular, is tricky.  tc_hydro uses points, but tc_meridian uses flags
enum TF2GameMode:
{
	TF2GameMode_Unknown,		/**< Unknown type, unknown mode */
	TF2GameMode_CTF,			/**< General CTF */
	TF2GameMode_CP_AD,			/**< Attack/Defense Control Points */
	TF2GameMode_CP_Symmetric,	/**< 5CP or unknown Control Points */
	TF2GameMode_TC,				/**< Territory Control CP */
	TF2GameMode_PL,				/**< General Payload */
	TF2GameMode_Arena,			/**< Arena */
	TF2GameMode_ItemTest,		/**< Unknown type, Item Test mode */
	TF2GameMode_Koth,			/**< KOTH Control Points */
	TF2GameMode_HybridCTFCP,	/**< Hybrid CTF/CP mode */
	TF2GameMode_PLR,			/**< Payload Race, 2 team payload */
	TF2GameMode_Training,		/**< Unknown type, training mode */
	TF2GameMode_SD,				/**< CTF, Special Delivery */
	TF2GameMode_MvM,			/**< CTF, Mann Vs. Machine */
	TF2GameMode_RD,				/**< CTF, Robot Destruction */
}

ConVar g_Cvar_Enabled;

ConVar g_Cvar_MaxRounds;

int g_nRoundCount = 1;
int g_nStageCount = 1;

int g_nStageMax = 0;

MvMRoundType g_RoundType = MvMRoundFirst;

int g_GameRules = -1;

bool g_bDontInterruptBroadcast = false;

TF2GameMode g_GameMode = TF2GameMode_Unknown;

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
	g_nStageCount = 1;
	g_nStageMax = 0;
	g_GameRules = -1;
	g_bDontInterruptBroadcast = false;
	g_GameMode = TF2GameMode_Unknown;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	
	if (g_GameMode == TF2GameMode_Unknown)
	{
		g_GameMode = TF2_DetectGameMode();
	}
	
	if (g_nStageMax == 0)
	{
		g_nStageMax = GetRoundCount();
	}
	
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
	if (!g_Cvar_Enabled.BoolValue || GameRules_GetProp("m_bInWaitingForPlayers"))
		return;
	
	g_nStageCount++;
	
	int remainingTime;
	
	// Negative time means unlimited time left
	GetMapTimeLeft(remainingTime);
	
	// Was this the last stage of a map?
	if (event.GetBool("full_round"))
	{
		g_nRoundCount++;
		g_nStageCount = 1;
		
		// The next round will be the last round
		if (g_nRoundCount == g_Cvar_MaxRounds.IntValue)
		{
			g_RoundType = MvMRoundLast;
			return;
		}
		
		if (g_GameMode == TF2GameMode_Arena)
		{
			// The next round will *probably* be the last round
			if (-1 < remainingTime <= 120) // 2 Minutes
			{
				g_RoundType = MvMRoundLast;
				return;
			}
		}
		else
		{
			// The next round will *probably* be the last round
			if (-1 < remainingTime <= 600) // 10 minutes
			{
				g_RoundType = MvMRoundLast;
				return;
			}
		}
	}

	// Next stage is the last stage of a multi-round map with less than 10 minutes on the clock
	// Assume it will be the last round
	if (g_nStageCount == g_nStageMax && -1 < remainingTime <= 600)
	{
		g_RoundType = MvMRoundLast;
		return;
	}
	
	g_RoundType = RandomMidRoundType();
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
	return Plugin_Stop;
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

/**
 * This should not be executed until OnConfigsExecuted or later as the entities used may not yet exist earlier
 */
stock TF2GameMode TF2_DetectGameMode()
{
	int gameType = GameRules_GetProp("m_nGameType");
	
	switch (gameType)
	{
		case TF2GameType_Unknown:
		{
			if (GameRules_GetProp("m_bIsInItemTestingMode"))
			{
				return TF2GameMode_ItemTest;
			}
			else
			if (FindEntityByClassname(-1, "tf_logic_training_mode") > -1)
			{
				return TF2GameMode_Training;
			}
			
			return TF2GameMode_Unknown;
		}
		
		case TF2GameType_CTF:
		{
			if (GameRules_GetProp("m_bPlayingSpecialDeliveryMode"))
			{
				return TF2GameMode_SD;
			}
			else
			if (FindEntityByClassname(-1, "tf_logic_hybrid_ctf_cp") > -1)
			{
				return TF2GameMode_HybridCTFCP;
			}
			else
			if (FindEntityByClassname(-1, "tf_logic_mann_vs_machine") > -1)
			{
				return TF2GameMode_MvM;
			}
			else
			if (FindEntityByClassname(-1, "tf_logic_robot_destruction") > -1)
			{
				return TF2GameMode_RD;
			}

			return TF2GameMode_CTF;
		}
		
		case TF2GameType_CP:
		{
			if (FindEntityByClassname(-1, "tf_logic_hybrid_ctf_cp") > -1)
			{
				return TF2GameMode_HybridCTFCP;
			}
			else
			if (FindEntityByClassname(-1, "tf_logic_koth") > -1)
			{
				return TF2GameMode_Koth;
			}
			
			int cpMaster = FindEntityByClassname(-1, "team_control_point_master");
			
			// There is a limit of 8 CPs, but seemingly no limit on rounds
			// 16 is higher than you would normally see
			int roundEntities[16];
			
			int roundCount = GetRoundEntities(roundEntities);

			// 0 means there were no round entities, which means 1 round
			// TC is never single-round (kinda the point of TC)
			if (roundCount == 0)
			{
				// A/D CP restricts the cap winner
				// This catches maps like cp_gravelpit, but not cp_dustbowl
				if (GetEntProp(cpMaster, Prop_Data, "m_iInvalidCapWinner"))
				{
					return TF2GameMode_CP_AD;
				}
				
				return TF2GameMode_CP_Symmetric;
			}
			
			// OK, now check all the rounds to see if they have invalid cap winners
			bool bAllInvalidCapWinners = true;
			
			for (int i = 0; i < roundCount; i++)
			{
				if (!GetEntProp(cpMaster, Prop_Data, "m_iInvalidCapWinner"))
				{
					bAllInvalidCapWinners = false;
				}
			}
			
			// Properly designed A/D CP has all invalid cap winners
			if (bAllInvalidCapWinners)
			{
				return TF2GameMode_CP_AD;
			}
			
			// Normal CP maps will have no more than #cp / 2 rounds.
			// TC (assuming 2 points) can have minimum #cp - 1 rounds, assuming they're arranged in a line
			// For reference, Hydro has (#centercp - 1)! + #basecp == (4 - 1)! + 2 == 8 rounds for 6 cps.
			if (roundCount * 2 > GetCPCount()) // for dustbowl: 3*2 > 6 == 6 > 6 == false
			{
				return TF2GameMode_TC;
			}
			
			// Symmetric is the default
			return TF2GameMode_CP_Symmetric;
		}
		
		case TF2GameType_PL:
		{
			if (FindEntityByClassname(-1, "tf_logic_multiple_escort") > -1)
			{
				return TF2GameMode_PLR;
			}

			return TF2GameMode_PL;
		}
		
		case TF2GameType_Arena:
		{
			return TF2GameMode_Arena;
		}
	}
	
	return TF2GameMode_Unknown;
}

stock int GetRoundEntities(int[] roundEntities)
{
	int entity = -1;
	int roundCount = 0;
	while ((entity = FindEntityByClassname(entity, "team_control_point_round")) != -1)
	{
		roundEntities[roundCount] = entity;
		roundCount++;
	}
	
	return roundCount;
}

stock int GetRoundCount()
{
	int entity = -1;
	int roundCount = 0;
	while ((entity = FindEntityByClassname(entity, "team_control_point_round")) != -1)
	{
		roundCount++;
	}
	
	if (roundCount == 0)
	{
		roundCount = 1;
	}
	
	return roundCount;
}

stock int GetCPCount()
{
	int entity = -1;
	int cpCount = 0;
	while ((entity = FindEntityByClassname(entity, "team_control_point")) != -1)
	{
		cpCount++;
	}
	
	return cpCount;
}

stock bool IsPlayingMedieval()
{
	return view_as<bool>(GameRules_GetProp("m_bPlayingMedieval"));
}

stock bool IsPlayingMannPower()
{
	if (GameRules_GetProp("m_bPowerupMode") && FindEntityByClassname(entity, "info_powerup_spawn")) > -1)
	{
		return true;
	}
	
	return false;
}