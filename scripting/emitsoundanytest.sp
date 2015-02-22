/**
 * vim: set ts=4 :
 * =============================================================================
 * EmitSoundAny Test
 * Test EmitSoundAny
 *
 * EmitSoundAny Test (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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
#include <emitsoundany>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

#define SOUND "sourcemod/mapchooser/hl1/gman_choose2.wav"

public Plugin myinfo = {
	name			= "EmitSoundAny Test",
	author			= "Powerlord",
	description		= "Test EmitSoundAny",
	version			= VERSION,
	url				= ""
};

public void OnPluginStart()
{
	CreateConVar("_version", VERSION, " version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegAdminCmd("testsound", Cmd_TestSound, ADMFLAG_GENERIC, "Test Emit Sound Any");
	RegAdminCmd("testsoundall", Cmd_TestSoundAll, ADMFLAG_GENERIC, "Test Emit Sound Any");
	RegAdminCmd("testsoundambient", Cmd_TestSoundAmbient, ADMFLAG_GENERIC, "Test Emit Sound Any");
}

public void OnMapStart()
{
	PrecacheSoundAny(SOUND);
}

public Action Cmd_TestSound(int client, int args)
{
	EmitSoundToClientAny(client, SOUND);

	return Plugin_Handled;
}

public Action Cmd_TestSoundAll(int client, int args)
{
	EmitSoundToAllAny(SOUND);
	
	return Plugin_Handled;
}

public Action Cmd_TestSoundAmbient(int client, int args)
{
	float pos[3] = {0.0, ...};
	
	EmitAmbientSoundAny(SOUND, pos);
	
	return Plugin_Handled;
}
