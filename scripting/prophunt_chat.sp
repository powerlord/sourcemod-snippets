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

#pragma semicolon 1

#define VERSION "1.0.0"

new Handle:g_Cvar_Enabled;
new Handle:g_Cvar_SpectatorMode;

new Handle:g_Cvar_Alltalk;

new bool:g_Spec[MAXPLAYERS+1];

new bool:g_bProtoBuf = false;

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
	
	HookUserMessage(GetUserMessageId("SayText2"), UsrMsg_SayText2, true);
	
	g_bProtoBuf = GetUserMessageType() == UM_Protobuf;
}

public CvarChange_Alltalk(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// Force sv_alltalk off
	if (GetConVarBool(convar))
	{
		SetConVarBool(convar, false);
	}
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	
}

public Event_TeamChange(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new team = GetEventInt(event, "team");
	new oldTeam = GetEventInt(event, "oldteam");
	
	if (team == TEAM_PROP)
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
	new ent_idx;
	new bool:chat;
	new String:msg_name[128];
	new String:params[4][64];
	
	if (g_bProtoBuf)
	{
		ent_idx = PbReadInt(msg, "ent_idx");
		chat = PbReadBool(msg, "chat");
		PbReadString(msg, "msg_name", msg_name, sizeof(msg_name));
		for (new i = 0; i < 4; i++)
		{
			PbReadString(msg, "params", params[i], sizeof(params[]), i);
		}
	}
	else
	{
		ent_idx = BfReadByte(msg);
		chat = bool:BfReadByte(msg);
		BfReadString(msg, msg_name, sizeof(msg_name));
		for (new i = 0; i < 4; i++)
		{
			BfReadString(msg, params[i], sizeof(params[]));
		}
	}

	// Not sent by a player/sent by disconnected player index, let it through
	if (ent_idx <= 0 || ent_idx > MaxClients || !IsClientInGame(ent_idx))
	{
		return Plugin_Continue;
	}
	
	// Logic to figure out targets here
	
	new team = GetClientTeam(ent_idx);
	
	new alive = IsPlayerAlive(ent_idx);
	
	new Handle:data = CreateDataPack();
	
	WritePackString(data, "SayText2");
	WritePackCell(data, ent_idx);
	WritePackCell(data, chat);
	WritePackString(data, msg_name);
	for (new i = 0; i < 4; i++)
	{
		WritePackString(data, params[i]);
	}
	
	
	ResetPack(data);
	return Plugin_Handled;
}

public SendSayText(any:data)
{
	new ent_idx;
	new bool:chat;
	new String:usermsg_name[16];
	new String:msg_name[128];
	new String:params[4][64];
	
	ReadPackString(data, usermsg_name, sizeof(usermsg_name));
	ent_idx = ReadPackCell(data);
	chat = bool:ReadPackCell(data);
	ReadPackString(data, msg_name, sizeof(msg_name));
	
	for (new i = 0; i < 4; i++)
	{
		ReadPackString(data, params[i], sizeof(params[]));
	}
	
	if (g_bProtoBuf)
	{
	}
}