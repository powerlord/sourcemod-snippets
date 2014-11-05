/**
 * vim: set ts=4 :
 * =============================================================================
 * SM 1.7 ConVar Testing
 * Test changes made to SM 1.7's ConVar syntax.
 *
 * SM 1.7 ConVar Testing (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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
#pragma semicolon 1

#define VERSION "1.0.0"

ConVar g_Cvar_Enabled;

ConVar g_Cvar_String;
ConVar g_Cvar_Float;
ConVar g_Cvar_Bool;
ConVar g_Cvar_Int;

public Plugin:myinfo = {
	name			= "SM 1.7 ConVar Testing",
	author			= "Powerlord",
	description		= "Test changes made to SM 1.7's ConVar syntax.",
	version			= VERSION,
	url				= ""
};
  
public OnPluginStart()
{
	CreateConVar("convar_test_version", VERSION, " version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("convar_test_enable", "1", "Enable ConVar Test?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
	g_Cvar_String = CreateConVar("convar_test_string", "Test String", "A test convar containing a string value.");
	g_Cvar_Float = CreateConVar("convar_test_float", "2.0", "A test convar containing a float value, with bounds", _, true, 0.0, true, 5.0);
	g_Cvar_Bool = CreateConVar("convar_test_bool", "1", "A test convar containing a bool value, with bounds", _, true, 0.0, true, 1.0);
	g_Cvar_Int = CreateConVar("convar_test_int", "7", "A test convar containing an int value, with bounds", _, true, 0.0, true, 10.0);
	
	RegAdminCmd("cvarstring", Cmd_String, ADMFLAG_GENERIC, "Do stuff with string convar");
	RegAdminCmd("cvarfloat", Cmd_Float, ADMFLAG_GENERIC, "Do stuff with float convar");
	RegAdminCmd("cvarbool", Cmd_Bool, ADMFLAG_GENERIC, "Do stuff with bool convar");
	RegAdminCmd("cvarint", Cmd_Int, ADMFLAG_GENERIC, "Do stuff with int convar");
	
	RegAdminCmd("cvarflags", Cmd_Flags, ADMFLAG_GENERIC, "Change enabled flags");
}

public Action:Cmd_String(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	char myName[64];
	g_Cvar_String.GetName(myName, sizeof(myName));
	
	char myValue[64];
	g_Cvar_String.GetString(myValue, sizeof(myValue));
	
	char defaultValue[64];
	g_Cvar_String.GetDefault(defaultValue, sizeof(defaultValue));
	
	int flags = g_Cvar_String.GetFlags();
	
	ReplyToCommand(client, "\"%s\" cvar flags: %d , value: \"%s\", default: \"%s\"", flags, myName, myValue, defaultValue);
	
	return Plugin_Handled;
}

public Action:Cmd_Float(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	char myName[64];
	g_Cvar_Float.GetName(myName, sizeof(myName));
	
	float myValue = g_Cvar_Float.GetFloat();
	
	bool boundsSet[2];
	float bounds[2];
	boundsSet[0] = g_Cvar_Float.GetBounds(ConVarBound_Lower, bounds[0]);
	boundsSet[1] = g_Cvar_Float.GetBounds(ConVarBound_Upper, bounds[1]);
	
	char defaultValue[64];
	g_Cvar_Float.GetDefault(defaultValue, sizeof(defaultValue));
	
	int flags = g_Cvar_Float.GetFlags();
	
	ReplyToCommand(client, "\"%s\" cvar flags: %d, value: %f, default: \"%s\", bounds: %f, %f", flags, myName, myValue, defaultValue, bounds[0], bounds[1]);

	return Plugin_Handled;
}

public Action:Cmd_Bool(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}

	char myName[64];
	g_Cvar_Bool.GetName(myName, sizeof(myName));
	
	bool myValue = g_Cvar_Bool.GetBool();
	
	bool boundsSet[2];
	float bounds[2];
	boundsSet[0] = g_Cvar_Bool.GetBounds(ConVarBound_Lower, bounds[0]);
	boundsSet[1] = g_Cvar_Bool.GetBounds(ConVarBound_Upper, bounds[1]);
	
	char defaultValue[64];
	g_Cvar_Bool.GetDefault(defaultValue, sizeof(defaultValue));
	
	int flags = g_Cvar_Bool.GetFlags();
	
	ReplyToCommand(client, "\"%s\" cvar flags: %d, value: %d, default: \"%s\", bounds: %f, %f", flags, myName, myValue, defaultValue, bounds[0], bounds[1]);
	
	return Plugin_Handled;
}

public Action:Cmd_Int(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	char myName[64];
	g_Cvar_Int.GetName(myName, sizeof(myName));
	
	int myValue = g_Cvar_Int.GetInt();
	
	bool boundsSet[2];
	float bounds[2];
	boundsSet[0] = g_Cvar_Int.GetBounds(ConVarBound_Lower, bounds[0]);
	boundsSet[1] = g_Cvar_Int.GetBounds(ConVarBound_Upper, bounds[1]);
	
	char defaultValue[64];
	g_Cvar_Int.GetDefault(defaultValue, sizeof(defaultValue));
	
	int flags = g_Cvar_Int.GetFlags();
	
	ReplyToCommand(client, "\"%s\" cvar flags: %d, value: %d, default: \"%s\", bounds: %f, %f", flags, myName, myValue, defaultValue, bounds[0], bounds[1]);
	
	return Plugin_Handled;
}

public Action:Cmd_Flags(client, args)
{
	new flags = g_Cvar_Enabled.GetFlags();
	if (flags & FCVAR_SPONLY)
	{
		flags &= ~FCVAR_SPONLY;
	}
	else
	{
		flags |= FCVAR_SPONLY;
	}
	
	g_Cvar_Enabled.SetFlags(flags);
	
	ReplyToCommand(client, "New enabled flags: %d", flags);
	
	return Plugin_Handled;
}