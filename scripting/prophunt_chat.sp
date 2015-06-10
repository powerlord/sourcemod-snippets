/**
 * vim: set ts=4 :
 * =============================================================================
 * PropHunt Chat
 * Disable chat for some players
 *
 * PropHunt Chat (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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
#include <tf2_stocks>

#pragma semicolon 1

#define VERSION "1.0.0"

new Handle:g_Cvar_Enabled;

new Handle:g_Cvar_Alltalk;

new bool:g_bProtoBuf = false;

new bool:g_bEnabled = false;

#define TEAM_BLUE _:TFTeam_Blue
#define TEAM_RED _:TFTeam_Red
#define TEAM_SPEC _:TFTeam_Spectator
#define TEAM_UNASSIGNED _:TFTeam_Unassigned

#define TEAM_PROP TEAM_RED
#define TEAM_HUNTER TEAM_BLUE

public Plugin:myinfo = {
	name			= "PropHunt Chat",
	author			= "Powerlord",
	description		= "Modify which players can hear other players / see chat",
	version			= VERSION,
	url				= ""
};
 
public OnPluginStart()
{
	CreateConVar("prophunt_chat_version", VERSION, "PropHunt Chat version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("prophunt_chat_enable", "1", "Enable PropHunt Chat?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
	g_Cvar_Alltalk = FindConVar("sv_alltalk");
	
	HookConVarChange(g_Cvar_Alltalk, CvarChange_Alltalk);
	
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("player_team", Event_TeamChange);
	HookEvent("player_death", Event_PlayerDeath);
	
	// To my knowledge, only SayText2 is used by TF2 for chat
	HookUserMessage(GetUserMessageId("SayText2"), UsrMsg_SayText2, true);
	
	g_bProtoBuf = GetUserMessageType() == UM_Protobuf;
}

public OnConfigsExecuted()
{
	g_bEnabled = GetConVarBool(g_Cvar_Enabled);
}

public OnClientPutInServer(client)
{
	if (!g_bEnabled)
	{
		return;
	}
	
	SetClientListeningFlags(client, VOICE_LISTENALL);
}

public CvarChange_Alltalk(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (!g_bEnabled)
	{
		return;
	}
	
	// Force sv_alltalk off
	if (GetConVarBool(convar))
	{
		SetConVarBool(convar, false);
	}
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bEnabled)
	{
		return;
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (GetClientTeam(i) != TEAM_HUNTER)
			{
				SetClientListeningFlags(i, VOICE_LISTENALL);
			}
			else
			{
				SetClientListeningFlags(i, VOICE_NORMAL);
			}
		}
	}
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bEnabled)
	{
		return;
	}
	
	if (GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	SetClientListeningFlags(client, VOICE_LISTENALL);
}



public Event_TeamChange(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bEnabled)
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new team = GetEventInt(event, "team");
	
	if (team != TEAM_HUNTER)
	{
		SetClientListeningFlags(client, VOICE_LISTENALL);
	}
	else 
	{
		SetClientListeningFlags(client, VOICE_NORMAL);
	}
}

public Action:UsrMsg_SayText2(UserMsg:msg_id, Handle:msg, const players[], playersNum, bool:reliable, bool:init)
{
	if (!g_bEnabled)
	{
		return Plugin_Continue;
	}
	
	new client;
	new bool:chat;
	new String:msg_name[128];
	new String:params[4][64];
	
	if (g_bProtoBuf)
	{
		client = PbReadInt(msg, "ent_idx");
		chat = PbReadBool(msg, "chat");
		PbReadString(msg, "msg_name", msg_name, sizeof(msg_name));
		for (new i = 0; i < 4; i++)
		{
			PbReadString(msg, "params", params[i], sizeof(params[]), i);
		}
	}
	else
	{
		client = BfReadByte(msg);
		chat = bool:BfReadByte(msg);
		BfReadString(msg, msg_name, sizeof(msg_name));
		for (new i = 0; i < 4; i++)
		{
			BfReadString(msg, params[i], sizeof(params[]));
		}
	}

	// Not sent by a player/sent by disconnected player index, let it through
	if (!StrEqual(msg_name, "TF_Chat_All") || !chat || client <= 0 || client > MaxClients || !IsClientInGame(client))
	{
		return Plugin_Continue;
	}
	
	// Logic to figure out targets here
	
	new team = GetClientTeam(client);
	
	// Messages from hunters should go through to all players
	if (team == TEAM_HUNTER)
	{
		return Plugin_Continue;
	}
	
	new newPlayers[MaxClients];
	new newPlayersNum = 0;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if ( (GetClientTeam(i) == TEAM_HUNTER && !IsPlayerAlive(i)) || GetClientTeam(i) != TEAM_HUNTER )
			{
				newPlayers[newPlayersNum] = i;
				newPlayersNum++;
			}
		}
	}
	
	new flags;
	
	if (reliable)
	{
		flags |= USERMSG_RELIABLE;
	}
	
	if (init)
	{
		flags |= USERMSG_INITMSG;
	}
	
	new Handle:data = CreateDataPack();
	
	WritePackCell(data, flags);
	WritePackCell(data, client);
	WritePackCell(data, chat);
	WritePackString(data, msg_name);
	for (new i = 0; i < 4; i++)
	{
		WritePackString(data, params[i]);
	}
	
	WritePackCell(data, newPlayersNum);
	for (new i = 0; i < newPlayersNum; i++)
	{
		WritePackCell(data, newPlayers[i]);
	}
	
	ResetPack(data);
	
	// You cannot modify the params in a usermessage and you cannot send a new usermessage within a user message.
	// Wait a frame, then send it.
	RequestFrame(SendSayText2, data);
	
	return Plugin_Handled;
}

public SendSayText2(any:data)
{
	new flags;
	new client;
	new bool:chat;
	new String:msg_name[128];
	new String:params[4][64];
	int playersNum;
	
	flags = ReadPackCell(data);
	client = ReadPackCell(data);
	chat = bool:ReadPackCell(data);
	ReadPackString(data, msg_name, sizeof(msg_name));
	
	flags |= USERMSG_BLOCKHOOKS;
	
	for (new i = 0; i < 4; i++)
	{
		ReadPackString(data, params[i], sizeof(params[]));
	}
	
	playersNum = ReadPackCell(data);
	
	new players[playersNum];
	
	for (new i = 0; i < playersNum; i++)
	{
		players[i] = ReadPackCell(data);
	}
	
	new Handle:msg = StartMessage("SayText2", players, playersNum, flags);
	
	if (g_bProtoBuf)
	{
		PbSetInt(msg, "ent_idx", client);
		PbSetBool(msg, "chat", chat);
		PbSetString(msg, "msg_name", msg_name);
		
		for (new i = 0; i < 4; i++)
		{
			PbAddString(msg, "params", params[i]);
		}
	}
	else
	{
		BfWriteByte(msg, client);
		BfWriteByte(msg, chat);
		BfWriteString(msg, msg_name);
		
		for (new i = 0; i < 4; i++)
		{
			BfWriteString(msg, params[i]);
		}
	}
	
	EndMessage();
}