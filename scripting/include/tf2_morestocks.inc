/**************************************************************************
 *                                                                        *
 *                         More TF2 Stocks                                *
 *                   Author: Ross Bemrose (Powerlord)                     *
 *                       Contributions by Leonardo                        *
 *                          Version: 1.0                                  *
 *                                                                        *
 **************************************************************************/

#if defined _tf2_morestocks_included
 #endinput
#endif
#define _tf2_morestocks_included

#include <sourcemod>
#include <sdktools>
#include <tf2>

#define WAITING_FOR_PLAYERS_TIMER "zz_teamplay_waiting_timer"
#define RED_KOTH_TIMER "zz_red_koth_timer"
#define BLU_KOTH_TIMER "zz_blue_koth_timer"

#define CONTROL_POINT_MIN 0
#define CONTROL_POINT_MAX 7

// Taken from TF2ItemsInfo
#if !defined _tf2itemsinfo_included
enum TF2ItemSlot
{
	TF2ItemSlot_Primary = 0,
	TF2ItemSlot_Secondary = 1,
	TF2ItemSlot_Sapper = 1,
	TF2ItemSlot_Melee = 2,
	TF2ItemSlot_PDA = 3,
	TF2ItemSlot_PDA1 = 3,
	TF2ItemSlot_PDA2 = 4,
	TF2ItemSlot_Building = 5,
	TF2ItemSlot_Hat = 5,
	TF2ItemSlot_Head = 5,
	TF2ItemSlot_Misc = 6,
	TF2ItemSlot_Action = 7
};
#endif

// This enum represents the order of values in DT_TFPlayerScoringDataExclusive
// Since the first offset is 4 (not 0), start the enum at 1
enum TF2ScoreData
{
	TF2Score_Captures = 1, // m_iCaptures
	TF2Score_Defenses, // m_iDefenses
	TF2Score_Kills, // m_iKilla
	TF2Score_Deaths, // m_iDeaths
	TF2Score_Suicides, // m_iSuicides
	TF2Score_Dominations, // m_iDominations
	TF2Score_Revenge, // m_iRevenge
	TF2Score_BuildingsBuilt, // m_iBuildingsBuilt
	TF2Score_BuildingDestroyed, // m_iBuildingsDestroyed
	TF2Score_Headshots, // m_iHeadshots
	TF2Score_Backstabs, // m_iBackstabs
	TF2Score_HealPoints, // m_iHealPoints
	TF2Score_Invulns, // m_iInvulns
	TF2Score_Teleports, // m_iTeleports
	TF2Score_DamageDone, // m_iDamageDone
	TF2Score_Crits, // m_iCrits
	TF2Score_ResupplyPoints, // m_iResupplyPoints
	TF2Score_KillAssists, // m_iKillAssists
	TF2Score_BonusPoints, // m_iBonusPoints
	TF2Score_Points, // m_iPoints
};

new TF2Hitpoints[] = {
	0, // TFClass_Unknown
	125, // TFClass_Scout
	125, // TFClass_Sniper
	200, // TFClass_Soldier
	175, // TFClass_DemoMan
	150, // TFClass_Medic
	300, // TFClass_Heavy
	175, // TFClass_Pyro
	125, // TFClass_Spy
	125 // TFClass_Engineer
}

enum TF2TimerState
{
	TF2TimerState_NotApplicable,		/**< We are in a round, but timers don't apply. */
	TF2TimerState_WaitingForPlayers,	/**< We are currently in waiting for players */
	TF2TimerState_Paused,				/**< Has timers, but they're paused */
	TF2TimerState_Setup,				/**< We are in Setup time and timer reflects that */
	TF2TimerState_Active,				/**< We are actively in a round */
}

enum TF2GameType
{
	TF2GameType_Generic,
	TF2GameType_CTF = 1,
	TF2GameType_CP = 2,
	TF2GameType_PL = 3,
	TF2GameType_Arena = 4,
}

enum
{
	TF2WinReason_None,
	TF2WinReason_AllPointsCapped,
	TF2WinReason_OpponentsDead,
	TF2WinReason_FlagCapLimit,
	TF2WinReason_DefendedUntilTimeOut,
	TF2WinReason_Stalemate,
	TF2WinReason_TimeLimit,
	TF2WinReason_WinLimit,
	TF2WinReason_WinDiffLimit,
}

enum
{
	TF2StalemateReason_JoinMid,
	TF2StalemateReason_Timer,
	TF2StalemateReason_ServerTimeLimit,
}

static g_hObjectiveEntity = -1;

/**
 * Get a class's base health
 * 
 * Note: You probably want TF2_GetMaxHealth instead.
 * 
 * This is used if you want to know what a class's base health is before attributes modify it
 */
stock TF2_GetBaseHealth(TFClassType:class)
{
	return TF2Hitpoints[class];
}
/**
 * Get a client's current health
 * This may duplicate SourceMod's GetClientHealth
 * 
 * @return client's current health or -1 if it couldn't be found
 */
stock TF2_GetHealth(client)
{
	return GetResourceProp(client, "m_iHealth");
}

/**
 * Get a client's max health.
 * 
 * @param client	A client index
 * 
 * @return client's max health or -1 if it couldn't be found
 */
stock TF2_GetMaxHealth(client)
{
	return GetResourceProp(client, "m_iMaxHealth");
}

/**
 * Get a client's max overheal.
 * 
 * @param client	A client index
 * NOTE: The overheal health is the standard overheal health, not the Quick-Fix's half overheal health.
 * 
 * @return client's max overheal or -1 if it couldn't be found
 */
stock TF2_GetMaxOverheal(client)
{
	return GetResourceProp(client, "m_iMaxBuffedHealth");
}

/**
 * Get a client's max Quick-fix overheal.
 * 
 * @param client	A client index
 * 
 * @return client's max Quick-fix overheal or -1 if it couldn't be found
 */
stock TF2_GetMaxQuickfixOverheal(client)
{
	new maxHealth = TF2_GetMaxHealth(client);
	new maxOverheal = TF2_GetMaxOverheal(client);

	if (maxHealth == -1 || maxOverheal == -1)
	{
		return -1;
	}

	new difference = maxOverheal - maxHealth;

	return (difference / 2) + maxHealth;
}

/**
 * Internal function for getting player resource data
 */
static stock GetResourceProp(client, const String:resourceName[])
{
	if (client < 1 || client > MaxClients)
	{
		ThrowError("Client index %d is out of bounds", client);
		return -1;
	}
	
	if (!IsClientInGame(client))
	{
		ThrowError("Client index %d is not in game", client);
		return -1;
	}
	
	new playerResource = GetPlayerResourceEntity();
	if (playerResource == -1 || !IsValidEntity(playerResource))
	{
		LogError("Player Resource Entity doesn't exist.")
		return -1;
	}

	return GetEntProp(playerResource, Prop_Send, resourceName, _, client);
}


/**
 * Return a value from a player's Score Data
 * This function exists because m_iCaptures, etc... can't be looked up directly
 * 
 * @param client	A valid client index
 * @param dataType	A TF2ScoreData type
 * 
 * @returns Value of resource or -1 if the player isn't in game
 */
stock TF2_GetScoreData(client, TF2ScoreData:dataType)
{
	if (client < 1 || client > MaxClients)
	{
		ThrowError("Client index %d is out of bounds", client);
		return -1;
	}
	
	if (!IsClientInGame(client))
	{
		ThrowError("Client index %d is not in game", client);
		return -1;
	}

	return GetEntProp(client, Prop_Send, "m_ScoreData", 4, _:dataType);
}

/**
 * Return a value from a player's Round Score Data
 * This function exists because m_iCaptures, etc... can't be looked up directly
 * 
 * @param client	A valid client index
 * @param dataType	A TF2ScoreData type
 * 
 * @returns Value of resource or -1 if the player isn't in game
 */
stock TF2_GetRoundScoreData(client, TF2ScoreData:dataType)
{
	if (client < 1 || client > MaxClients)
	{
		ThrowError("Client %d is out of bounds", client);
		return -1;
	}
	
	if (!IsClientInGame(client))
	{
		ThrowError("Client %d is not in game", client);
		return -1;
	}

	return GetEntProp(client, Prop_Send, "m_RoundScoreData", 4, _:dataType);
}

/**
 * Returns an estimate of the time left before the round ends. If the map has no timers, then the time left returned will always be infinite. 
 * 
 * @param timeleft	Variable to store the time, in seconds.  If the value is less than 0, the time limit is infinite. Note: overtime will have 0 left on the clock.
 * 
 * @return 	TF2TimerState reflecting current mode.
 */
stock TF2TimerState:TF2_GetRoundTimeLeft(&timeleft)
{
	timeleft = -1;

	new bool:bInSetup = false;
	
	if (GameRules_GetProp("m_bInSetup"))
	{
		bInSetup = true;
	}
	else
	if (GameRules_GetProp("m_bInWaitingForPlayers"))
	{
		timeleft = GetWaitingForPlayersTime();
		return TF2TimerState_WaitingForPlayers;
	}
	else
	if (GameRules_GetProp("m_bInOvertime"))
	{
		timeleft = 0;
		return TF2TimerState_Active;
	}
	
	new timerEnt = -1;

	if (TF2_IsMvM())
	{
		timeleft = -1;
		return TF2TimerState_NotApplicable;
	}
	
	if (TF2_IsKoth())
	{
		new tempRedTimeLeft = -1;
		new tempBluTimeLeft = -1;
		new TF2TimerState:redActive;
		new TF2TimerState:bluActive;
		
		redActive = TF2_GetKothREDTimeLeft(tempRedTimeLeft);
		bluActive = TF2_GetKothBLUTimeLeft(tempBluTimeLeft);
		
		if (redActive == TF2TimerState_Active)
		{
			timeleft = tempRedTimeLeft;
			return TF2TimerState_Active;
		}
		else
		if (bluActive == TF2TimerState_Active)
		{
			timeleft = tempBluTimeLeft;
			return TF2TimerState_Active;
		}
		else
		{
			timeleft = -1;
			return TF2TimerState_Paused;
		}
	}
	
	if (TF2_GetGameType() == TF2GameType_CTF && !TF2_IsGameModeSD())
	{
		new bool:valid = GetMapTimeLeft(timeleft);
	}
	
	new bool:bHasTimer = false;
	while ((timerEnt = FindEntityByClassname(timerEnt, "team_round_timer") != -1))
	{
		decl String:tempTimerName[128];
		GetEntPropString(timerEnt, Prop_Send, "m_iName", tempTimerName, sizof(tempTimerName));
		if (StrEqual(tempTimeName, WAITING_FOR_PLAYERS_TIMER))
			continue;
			
		bHasTimer = true;
		if (!GetEntProp(timerEnt, Prop_Send, "m_bIsDisabled"))
		{
			timeleft = GetTimerTime(timerEnt);
			
			if (GetEntProp(timerEnt, Prop_Send, "m_bTimerPaused"))
			{
				continue;
			}
			
			if (bInSetup)
			{
				return TF2TimerState_Setup;
			}
			
			return TF2TimerState_Active;
		}
	}
	
	if (hasTimer)
	{
		return TF2TimerState_Paused;
	}
	
	return TF2TimerState_NotApplicable;
}

static stock GetTimerTime(timerEnt)
{
	if (!IsValidEntity(timerEnt))
	{
		return -1;
	}
	
	new Float:fTimeLeft = GetEntPropFloat(timerEnt, Prop_Send, "m_flTimeRemaining");
	return RoundToZero(fTimeLeft);
}

stock TF2TimerState:TF2_GetKothREDTimeLeft(&timeleft)
{
	if (!GameRules_GetProp("m_bPlayingKoth"))
	{
		timeleft = -1;
		return TF2TimerState_NotApplicable;
	}
	
	if (GameRules_GetProp("m_bInWaitingForPlayers"))
	{
		timeleft = GetWaitingForPlayersTime();
		return TF2TimerState_WaitingForPlayers;
	}
	
	new timerEnt = GameRules_GetPropEnt("m_hRedKothTimer");
	
	timeleft = GetTimerTime(timerEnt);
	
	if (GetEntProp(timerEnt, Prop_Send, "m_bTimerPaused"))
	{
		return TF2TimerState_Paused;
	}
	
	return TF2TimerState_Active;
}

stock TF2TimerState:TF2_GetKothBLUTimeLeft(&timeleft)
{
	if (!GameRules_GetProp("m_bPlayingKoth"))
	{
		timeleft = -1;
		return TF2TimerState_NotApplicable;
	}
	
	if (GameRules_GetProp("m_bInWaitingForPlayers"))
	{
		timeleft = GetWaitingForPlayersTime();
		return TF2TimerState_WaitingForPlayers;
	}
	
	new timerEnt = GameRules_GetPropEnt("m_hBlueKothTimer");
	
	timeleft = GetTimerTime(timerEnt);
	
	if (GetEntProp(timerEnt, Prop_Send, "m_bTimerPaused"))
	{
		return TF2TimerState_Paused;
	}
	
	return TF2TimerState_Active;
}

static stock GetWaitingForPlayersTime()
{
	new timerEnt = GetEntityByTargetName(WAITING_FOR_PLAYERS_TIMER, "team_round_timer");
	if (timerEnt > -1)
	{
		timeleft = GetTimerTime(timerEnt);
	}
	else
	{
		timeleft = 0;
	}

	return timeleft;
}

stock GetEntityByTargetName(const String:targetName[], const String:classname[])
{
	entity = -1;
	
	while ((entity = FindEntityByClassname(entity, classname)) != -1)
	{
		decl String:tempTargetName[128];
		GetEntPropString(entity, Prop_Send, "m_iName", tempTargetName, sizeof(tempTargetName));
		
		if (StrEqual(tempTargetName, targetName, false))
		{
			return entity;
		}
	}
	
	return -1;
}

/**
 * What basic game type are we?
 *
 * Note that types are based on their base scoring type:
 * CTF - CTF, SD, and MvM
 * CP - CP, 5CP, and TC
 * PL - PL and PLR
 * Arena - Arena
 * 
 * You can find some of the specific types using the IsGameModeX functions.
 * You can tell if a CTF or CP also implements the opposite type using TF2_IsGameModeHybrid()
 * 
 * @return 	A TF2GameType value. 
 */
stock TF2GameType:TF2_GetGameType()
{
	return TF2GameType:GameRules_GetProp("m_nGameType");
}

/**
 * Is this a koth map?
 * 
 * @return 	True if this is a KOTH map.
 */
stock bool:TF2_IsGameModeKoth()
{
	return bool:GameRules_GetProp("m_bPlayingKoth");
}

/**
 * Is this a Payload Race map?
 * 
 * @return 	True if this is a Payload Race map.
 */
stock bool:TF2_IsGameModePLR()
{
	return (FindEntityByClassname(-1, "tf_logic_multiple_escort") != -1);
}

/**
 * Is this a Special Delivery map?
 * 
 * @return 	True if this is a Special Delivery map.
 */
stock bool:TF2_IsGameModeSD()
{
	return bool:GameRules_GetProp("m_bPlayingSpecialDeliveryMode");
}

/**
 * Is this a Mann vs. Machine map?
 * 
 * @return 	True if this is a Mann vs. Machine map.
 */
stock bool:TF2_IsGameModeMvM()
{
	return bool:GameRules_GetProp("m_bPlayingMannVsMachine");
}

/**
 * Is we running Medieval mode?
 * Note: This can be either via a tf_logic_medieval entity
 * or because tf_medieval was set to 1 before the map started
 * 
 * @return 	True if this Medieval mode is running.
 */
stock bool:TF2_IsGameModeMedieval()
{
	return bool:GameRules_GetProp("m_bPlayingMedieval");
}

/**
 * Does this map have both CTF and CP elements?
 * You can find out which type the scoring system uses via TF2_GetGameType()
 * 
 * @return 	True if this map has both CTF and CP elements.
 */
stock bool:TF2_IsGameModeHybrid()
{
	return bool:GameRules_GetProp("m_bPlayingHybrid_CTF_CP");
}

/**
 * Are we currently in setup time?
 * 
 * @return 	True if we're currently in setup time.
 */
stock bool:TF2_IsSetupTime()
{
	return bool:GameRules_GetProp("m_bInSetup");
}

/**
 * Are we currently in overtime?
 * 
 * @return 	True if we're currently in overtime.
 */
stock bool:TF2_IsOvertime()
{
	return bool:GameRules_GetProp("m_bInOvertime");
}

/**
 * Are we currently in Waiting for Players?
 * Note: This corresponds directly with RoundStart_Pregame.
 * 
 * @return 	True if we're currently in Waiting For Players.
 */
stock bool:TF2_IsWaitingForPlayers()
{
	return bool:GameRules_GetProp("m_bInWaitingForPlayers");
}

/**
 * Are we currently in Sudden Death?
 * Note: Arena mode is ALWAYS considered to be Sudden Death.
 * Note 2: This corresponds directly with RoundStart_Stalemate.
 * 
 * @return true if the game is currently in sudden death.
 */
stock bool:TF2_IsSuddenDeath()
{
	return (GameRules_GetRoundState() == RoundState_Stalemate);
}

/**
 * How many rounds do we have?
 * Not the same as MvM waves, so don't try it for that.
 * Not useful on TC maps as the rounds aren't played in order.
 *  
 * @return number of rounds.
 */
stock TF2_GetRoundCount()
{
	new count = 0;
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "team_control_point_round")) != -1)
	{
		count++;
	}
	
	if (count == 0)
	{
		count++;
	}
	
	return count;
}

stock TF2_GetCurrentMvMWave()
{
	if (!TF2_IsMvM())
	{
		return 0;
	}
	
	new objectiveEntity = GetObjectiveEntity();
	
	if (objectiveEntity != INVALID_ENT_REFERENCE)
	{
		return GetEntProp(objectiveEntity, Prop_Send, "m_nMannVsMachineWaveCount");
	}
	return -1;
}

stock TF2_GetMvMWaveCount()
{
	if (!TF2_IsMvM())
	{
		return 0;
	}
	
	new objectiveEntity = GetObjectiveEntity();
	
	if (objectiveEntity != INVALID_ENT_REFERENCE)
	{
		return GetEntProp(objectiveEntity, Prop_Send, "m_nMannVsMachineMaxWaveCount");
	}
	return -1;
}

static stock GetObjectiveEntity()
{
	new objectiveEntity = INVALID_ENT_REFERENCE;
	
	if (g_hObjectiveEntity > INVALID_ENT_REFERENCE)
	{
		objectiveEntity = EntRefToEntIndex(g_hObjectiveEntity);
	}

	if (objectiveEntity == INVALID_ENT_REFERENCE)
	{
		objectiveEntity = FindEntityByClassname(INVALID_ENT_REFERENCE, "tf_objective_resource");
		if (objectiveEntity != INVALID_ENT_REFERENCE)
		{
			g_hObjectiveEntity = EntIndexToEntRef(objectiveEntity);
		}
	}
	
	return objectiveEntity;
}
