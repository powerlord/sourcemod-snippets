/**
 * vim: set ts=4 :
 * =============================================================================
 * CUtlVector Wearables Test
 * Test offsets fetched from a modified version of SDKTools to fetch wearables
 *
 * CUtlVector Wearables Test (C)2014 Powerlord (Ross Bemrose).
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
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#pragma semicolon 1

// This is hard-coded from a netprops dump
#define OFFSET 3504
// This has to be hard-coded as we have no way of reading it from the SourceMod side
#define OFFSET_SIZE 4

#define VERSION "1.0.0"

//new Handle:g_Cvar_Enabled;

new Handle:hGameConf;
new Handle:hEquipWearable;

public Plugin:myinfo = {
	name			= "CUtlVector Wearables Test",
	author			= "Powerlord",
	description		= "Test offsets fetched from a modified version of SDKTools to fetch wearables",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("cutlvector_wearables_test_version", VERSION, "CUtlVector Wearables Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	//g_Cvar_Enabled = CreateConVar("cutlvector_wearables_test_enable", "1", "Enable CUtlVector Wearables Test?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);

	HookEvent("post_inventory_application", Event_Inventory);
	RegAdminCmd("getallhats", Cmd_GetAllHats, ADMFLAG_GENERIC, "Get hat entities using an offset from the hard-coded offset... recommend trying 0, 1, and 4.");
	
	hGameConf = LoadGameConfigFile("tf2.wearables");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hEquipWearable = EndPrepSDKCall();
	
}

public Action:Cmd_GetAllHats(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "usage: getallhats offset");
		return Plugin_Handled;
	}
	
	new String:strOffset[3];
	GetCmdArg(1, strOffset, sizeof(strOffset));
	new offset = StringToInt(strOffset);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsClientObserver(i))
			continue;
			
		for (new j = 0; j < 8; j++)
		{
			new totalOffset = OFFSET + offset + (j * OFFSET_SIZE);
			new wearable = GetEntDataEnt2(i, OFFSET + offset + (j * OFFSET_SIZE));
			new itemDefinitionIndex = -1;
			new String:classname[64];
			
			if (wearable > 0 && IsValidEntity(wearable))
			{
				GetEntityClassname(wearable, classname, sizeof(classname));
				if (StrEqual(classname, "tf_wearable"))
				{
					itemDefinitionIndex = GetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex");
				}
			}
			
			ReplyToCommand(client, "\"%N\" wearable (%d) 00%d: %s %d (%d)", i, totalOffset, j+1, classname, wearable, itemDefinitionIndex);
			
		}
	}
	
	return Plugin_Handled;
}

public Event_Inventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && IsFakeClient(client))
	{
		new TFClassType:class = TF2_GetPlayerClass(client);
		
		switch (class)
		{
			case TFClass_Scout:
			{
				AddGenericMisc(client, 780); // Fed-Fightin' Fedora
				AddGenericMisc(client, 781); // Dillinger's Duffle
				AddGenericMisc(client, 30104); // Greybanns
			}
			
			case TFClass_Soldier:
			{
				AddGenericMisc(client, 980); // Soldier's Slope Scopers
				AddGenericMisc(client, 647); // All-Father
				AddGenericMisc(client, 541); // Merc's Pride Scarf
			}
			
			case TFClass_Pyro:
			{
				AddGenericMisc(client, 644, 36); // Head Warmer
				AddGenericMisc(client, 30305); // Sub-Zero Suit
				AddGenericMisc(client, 30308); // Trail Blazer
			}
			
			case TFClass_DemoMan:
			{
				AddGenericMisc(client, 30034); // Bolted Bicorne
				AddGenericMisc(client, 610); // Whiff of the Old Brimstone
				AddGenericMisc(client, 30011); // Bolted Bombardier
			}
			
			case TFClass_Heavy:
			{
				AddGenericMisc(client, 30374); // Sammy Cap
				AddGenericMisc(client, 643); // Sandvich Safe
				AddGenericMisc(client, 30141); // Gabe Glasses
			}
			
			case TFClass_Engineer:
			{
				AddGenericMisc(client, 322, 30); // Buckaroo's Hat
				AddGenericMisc(client, 389); // Googly Gazer
				AddGenericMisc(client, 30167); // Beep Boy
			}
			
			case TFClass_Medic:
			{
				AddGenericMisc(client, 616); // Surgeon's Stahlhelm
				AddGenericMisc(client, 978); // Der Wintermantel
				AddGenericMisc(client, 30186); // A Brush with Death
			}
			
			case TFClass_Sniper:
			{
				AddGenericMisc(client, 314); // Larrikin Robin
				AddGenericMisc(client, 393); // Villain's Veil
				AddGenericMisc(client, 522); // Deus Specs
			}
			
			case TFClass_Spy:
			{
				AddGenericMisc(client, 55, 18); // Fancy Fedora
				AddGenericMisc(client, 337, 6); // Le Party Phantom
				AddGenericMisc(client, 763); // Sneaky Spats of Sneaking
			}
		}
		
	}
}

AddGenericMisc(client, itemDefinitionIndex, effect = -1)
{
	
	new iLevel = GetRandomInt(1, 100);
	
	new Handle:item = TF2Items_CreateItem(OVERRIDE_ALL);
	TF2Items_SetClassname(item, "tf_wearable");
	TF2Items_SetItemIndex(item, itemDefinitionIndex);
	TF2Items_SetLevel(item, iLevel);
	
	if (effect > 0)
	{
		TF2Items_SetQuality(item, 6);
		TF2Items_SetAttribute(item, 0, 134, float(effect));
		TF2Items_SetNumAttributes(item, 1);
	}
	else
	{
		TF2Items_SetQuality(item, 0);
		TF2Items_SetNumAttributes(item, 0);
	}

	new index = TF2Items_GiveNamedItem(client, item);
	EquipWearable(client, index);

	CloseHandle(item);
}

EquipWearable(client, wearable)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client))
	{
		ThrowError("Client %d is invalid", client);
		return;
	}
	
	if (!IsValidEntity(wearable))
	{
		ThrowError("Wearable %d is invalid", wearable);
	}
	
	SDKCall(hEquipWearable, client, wearable);
}
