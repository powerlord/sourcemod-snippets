/**
 * vim: set ts=4 :
 * =============================================================================
 * Force Conga
 * Force all players to Conga
 *
 * Force Conga (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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
#include <tf2_stocks>
#pragma semicolon 1

#define VERSION "1.0.0"

public Plugin:myinfo = {
	name			= "[TF2] Force Conga",
	author			= "Powerlord",
	description		= "Force all players to Conga",
	version			= VERSION,
	url				= ""
};

// PLUGIN WILL NOT WORK UNTIL THIS ARRAY IS FILLED (except position 0)
// Unknown, Scout, Sniper, Soldier, DemoMan, Medic, Heavy, Pyro, Spy, Engineer
new String:CongaVCDs[TFClassType][PLATFORM_MAX_PATH] = { "", "", "", "", "", "", "", "", "", "" };

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	if (GetEngineVersion() != Engine_TF2)
	{
		strcopy(error, err_max, "Only supports Team Fortress 2");
		return APLRes_Failure;
	}
	return APLRes_Success;
}
  
public OnPluginStart()
{
	CreateConVar("tf2_forceconga_version", VERSION, "[TF2] Force Conga version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);

	LoadTranslations("common.phrases");
	
	RegAdminCmd("conga", Cmd_Conga, ADMFLAG_GENERIC, "Force players to Conga");
	RegConsoleCmd("congame", Cmd_CongaMe, "Allow a player to conga themselves");
}

public Action:Cmd_Conga(client, args)
{
	if (args == 0)
	{
		ReplyToCommand(client, "Usage: /conga <target>");
	}
	
	decl String:target[64];
	GetCmdArg(1, target, sizeof(target));
	
	decl String:target_name[64];
	new targets[MaxClients];
	new bool:tn_is_ml;
	
	new count = ProcessTargetString(target, client, targets, MaxClients, COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, target_name, sizeof(target_name), tn_is_ml);
	
	if (count < 1)
	{
		ReplyToTargetError(client, count);
		return Plugin_Handled;
	}
	
	for (new i = 0; i < count; i++)
	{
		CongaAnimation(targets[i]);
	}
	
	if (tn_is_ml)
	{
		Format(target_name, sizeof(target_name), "%T", target_name, client);
	}
	
	ReplyToCommand(client, "Congaed %s", target_name);
	return Plugin_Handled;
}

public Action:Cmd_CongaMe(client, args)
{
	if (!IsPlayerAlive(client))
	{
		ReplyToCommand(client, "%t", "Target must be alive");
		return Plugin_Handled;
	}
	
	CongaAnimation(client);
	ReplyToCommand(client, "Congaed %N", client);
	
	return Plugin_Handled;
}

CongaAnimation(client)
{
	new entity = CreateEntityByName("instanced_scripted_scene");
	
	new TFClassType:class = TF2_GetPlayerClass(client);
	
	if (!IsValidEntity(entity))
	{
		return;
	}
	
	DispatchKeyValue(entity, "SceneFile", CongaVCDs[class]);
	DispatchSpawn(entity);
	SetEntPropEnt(entity, Prop_Data, "m_hOwner", client);
	SetEntProp(entity, Prop_Data, "m_bHadOwner", true);
	SetEntPropString(entity, Prop_Data, "m_szInstanceFilename", CongaVCDs[class]);

	// Make it kill itself on cancellation or completion (not sure which fires)
	SetVariantString("OnCanceled !self:Kill:0:0:-1");
	AcceptEntityInput(entity, "AddOutput");
	
	SetVariantString("OnCompletion !self:Kill:0:0:-1");
	AcceptEntityInput(entity, "AddOutput");
	
	AcceptEntityInput(entity, "Start");
}