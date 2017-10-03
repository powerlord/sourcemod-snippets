/**
 * vim: set ts=4 :
 * =============================================================================
 * Spellbook Prompter
 * Prompt players to equip a spellbook
 *
 * Spellbook Prompter (C)2017 Powerlord (Ross Bemrose).  All rights reserved.
 * =============================================================================
 * See license at end of file
 */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

ConVar g_Cvar_Enabled;
bool g_bMapChanging = true;
int g_iHolidayEntity = -1;

public Plugin myinfo = {
	name			= "Spellbook Prompter",
	author			= "Powerlord",
	description		= "Prompt players to equip a spellbook",
	version			= VERSION,
	url				= "https://forums.alliedmods.net/showthread.php?t=301591"
};

public void OnPluginStart()
{
	CreateConVar("spellbook_prompter_version", VERSION, "Spellbook Prompter version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("spellbook_prompter_enable", "1", "Enable Spellbook Prompter?", FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
	g_Cvar_Enabled.AddChangeHook(EnableChanged);
}

int GetOrCreateHolidayEntity()
{
	if (g_iHolidayEntity == -1)
	{
		g_iHolidayEntity = FindEntityByClassname(-1, "tf_logic_holiday");
		
		if (g_iHolidayEntity == -1)
		{
			g_iHolidayEntity = CreateEntityByName("tf_logic_holiday");
			
			if (g_iHolidayEntity != -1)
			{
				DispatchSpawn(g_iHolidayEntity);
			}
		}
	}

	if (g_iHolidayEntity == -1)
	{
		ThrowError("Failed to find or create tf_logic_holiday entity.");
	}

	return g_iHolidayEntity;
}

public void OnConfigsExecuted()
{
	g_bMapChanging = false;
	if (g_Cvar_Enabled.BoolValue)
	{
		int entity = GetOrCreateHolidayEntity();
		SetVariantInt(1);
		AcceptEntityInput(entity, "HalloweenSetUsingSpells");
	}
	
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "tf_logic_holiday"))
	{
		g_iHolidayEntity = entity;
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_iHolidayEntity == entity)
	{
		g_iHolidayEntity = -1;
	}
}

public void OnMapEnd()
{
	g_bMapChanging = true;
}

public void EnableChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (!g_bMapChanging)
	{
		int entity = GetOrCreateHolidayEntity();
		
		SetVariantInt(convar.BoolValue ? 1 : 0);
		AcceptEntityInput(entity, "HalloweenSetUsingSpells");
	}
}

/*
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
