/**
 * vim: set ts=4 :
 * =============================================================================
 * TF2 UtlVector Wearables Test #2
 * Some commands to test CUtlVector wearables stuff
 *
 * TF2 UtlVector Wearables Test #2 (C)2015 Powerlord (Ross Bemrose).
 * All rights reserved.
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

#define MAXWEARABLES 8

#define VERSION "2.0.1"

new Handle:g_Cvar_Enabled;

public Plugin:myinfo = {
	name			= "TF2 UtlVector Wearables Test #2",
	author			= "Powerlord",
	description		= "Some commands to test CUtlVector wearables stuff",
	version			= VERSION,
	url				= ""
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	if (GetEngineVersion() != Engine_TF2)
	{
		strcopy(error, err_max, "This plugin only works on TF2.");
		return APLRes_Failure;
	}
	
	return APLRes_Success;
}

public OnPluginStart()
{
	CreateConVar("tf2_utlvector_version", VERSION, "TF2 UtlVector Wearables Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("tf2_utlvector_enable", "1", "Enable ?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	RegAdminCmd("getoffset", Cmd_GetOffSet, ADMFLAG_GENERIC, "Get offset of m_hMyWearables");
	
	HookEvent("post_inventory_application", Event_inventory);
}

public Action:Cmd_GetOffSet(client, args)
{
	new PropFieldType:type;
	new num_bits = 0;
	new local_offset = 0;

	new offset = FindSendPropInfo("CTFPlayer", "m_hMyWearables", type, num_bits, local_offset);
	ReplyToCommand(client, "CTFPlayer::m_hMyWearables offset: %d, type: %d, num_bits: %d, local_offset: %d", offset, type, num_bits, local_offset);
	
	offset = FindSendPropInfo("CTFPlayer", "m_Attributes", type, num_bits, local_offset);
	ReplyToCommand(client, "CTFPlayer::m_hMyWearables offset: %d, type: %d, num_bits: %d, local_offset: %d", offset, type, num_bits, local_offset);
	
	return Plugin_Handled;
}

public Event_inventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_Cvar_Enabled))
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	new elementCount = GetEntPropArraySize(client, Prop_Send, "m_hMyWearables");
	for (new i = 0; i < elementCount; i++)
	{
		new entity = GetEntPropEnt(client, Prop_Send, "m_hMyWearables", i);
		if (entity > 0)
		{
			new itemDefinitionIndex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
			PrintToChat(client, "Wearable [%d] index: %d", i, itemDefinitionIndex);
		}
	}
}
