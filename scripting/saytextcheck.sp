/**
 * vim: set ts=4 :
 * =============================================================================
 * Say Text Check
 * Check which usermessages and values say and say_team kick off
 *
 * Say Text Check (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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

#define FILE "saytext.txt"

new Handle:g_Cvar_Enabled;

new bool:g_bProtoBuf = false;

public Plugin:myinfo = {
	name			= "Say Text Check",
	author			= "Powerlord",
	description		= "Record what chat fires",
	version			= VERSION,
	url				= ""
};
 
public OnPluginStart()
{
	CreateConVar("saytextcheck_version", VERSION, "Say Text Check version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("saytextcheck_enable", "1", "Enable PropHunt Chat?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
	AddCommandListener(Cmd_Say, "say");
	AddCommandListener(Cmd_Say, "say_team");
	
	HookUserMessage(GetUserMessageId("SayText"), UsrMsg_SayText);
	HookUserMessage(GetUserMessageId("SayText2"), UsrMsg_SayText2);
	
	g_bProtoBuf = GetUserMessageType() == UM_Protobuf;
}

public Action:Cmd_Say(client, const String:command[], argc)
{
	if (!GetConVarBool(g_Cvar_Enabled))
	{
		return Plugin_Continue;
	}
	
	new String:message[512];
	GetCmdArgString(message, sizeof(message));
	
	LogToFile(FILE, "%L used %s: %s", client, command, message);
	
	return Plugin_Continue;
}

public Action:UsrMsg_SayText(UserMsg:msg_id, Handle:msg, const players[], playersNum, bool:reliable, bool:init)
{
	if (!GetConVarBool(g_Cvar_Enabled))
	{
		return Plugin_Continue;
	}
	
	new client;
	new String:msg_name[128];
	new bool:chat;
	new bool:allchat;
	
	if (g_bProtoBuf)
	{
		client = PbReadInt(msg, "ent_idx");
		PbReadString(msg, "text", msg_name, sizeof(msg_name));
		chat = PbReadBool(msg, "chat");
		allchat = PbReadBool(msg, "textallchat");
		
		LogToFile(FILE, "SayText. numplayers: %d, client: %L, msg_name: %s, chat: %d, allchat: %d", playersNum, client, msg_name, chat, allchat);
	}
	else
	{
		client = BfReadByte(msg);
		BfReadString(msg, msg_name, sizeof(msg_name));
		chat = bool:BfReadByte(msg);

		LogToFile(FILE, "SayText. numplayers: %d, client: %L, msg_name: %s, chat: %d", playersNum, client, msg_name, chat);
	}
	
	return Plugin_Continue;	
}

public Action:UsrMsg_SayText2(UserMsg:msg_id, Handle:msg, const players[], playersNum, bool:reliable, bool:init)
{
	if (!GetConVarBool(g_Cvar_Enabled))
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

	LogToFile(FILE, "SayText2. numplayers: %d, client: %L, msg_name: %s, chat: %d, param1: %s, param2: %s, param3: %s, param4: %s", playersNum,
		client, msg_name, chat, params[0], params[1], params[2], params[3]);
		
	return Plugin_Continue;	
}
