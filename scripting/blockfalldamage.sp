/**
 * vim: set ts=4 :
 * =============================================================================
 * Block Fall Damage
 * Use SDKHooks to block player fall damage
 *
 * Block Fall Damage (C)2018 Powerlord (Ross Bemrose).  All rights reserved.
 * =============================================================================
 * License at end of file
 */
#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

ConVar g_Cvar_Enabled;

public Plugin myinfo = {
	name			= "Block Fall Damage",
	author			= "Powerlord",
	description		= "Use SDKHooks to block fall damage",
	version			= VERSION,
	url				= "https://forums.alliedmods.net/showthread.php?t=305353"
};

public void OnPluginStart()
{
	CreateConVar("blockfalldamage_version", VERSION, "Block Fall Damage version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("blockfalldamage_enable", "1", "Enable Block Fall Damage?", FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, TakeDamageHook);
}

public Action TakeDamageHook(int victim, int &attacker, int &inflictor, float &damage,
	int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (g_Cvar_Enabled.BoolValue && victim > 0 && victim <= MaxClients && IsClientInGame(victim) &&
		damagetype & DMG_FALL)
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
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
