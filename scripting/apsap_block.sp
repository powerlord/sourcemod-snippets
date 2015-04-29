/**
 * vim: set ts=4 :
 * =============================================================================
 * Ap-Sap Block
 * Block the Ap Sap
 *
 * Ap-Sap Block (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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
#include <tf2items>

#pragma semicolon 1

#define VERSION "1.0.0"

#define APSAP_ID 933
#define SAPPER_ID 735

new Handle:g_Cvar_Enabled;

public Plugin:myinfo = {
	name			= "Ap-Sap Block",
	author			= "Powerlord",
	description		= "Replaces the Ap-Sap with the stock sapper",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("apsap_block_version", VERSION, "Ap-Sap Block version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("apsap_block_enable", "1", "Enable Ap-Sap Block?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	static Handle:itemOverride;
	if (itemOverride != INVALID_HANDLE)
	{
		CloseHandle(itemOverride);
		itemOverride = INVALID_HANDLE;
	}
	
	if (GetConVarBool(g_Cvar_Enabled) && iItemDefinitionIndex == APSAP_ID)
	{
		itemOverride = TF2Items_CreateItem(OVERRIDE_ITEM_DEF|OVERRIDE_ITEM_LEVEL|OVERRIDE_ITEM_QUALITY|OVERRIDE_ATTRIBUTES);
		TF2Items_SetItemIndex(itemOverride, SAPPER_ID);
		TF2Items_SetLevel(itemOverride, 1);
		TF2Items_SetQuality(itemOverride, 0);
		TF2Items_SetNumAttributes(itemOverride, 0);
		hItem = itemOverride;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}
