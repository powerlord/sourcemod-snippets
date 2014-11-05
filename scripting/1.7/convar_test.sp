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
	
	RegAdminCmd("cvarreset", Cmd_Reset, ADMFLAG_GENERIC, "Reset convar_test_float");
	
	RegAdminCmd("cvarsetbounds", Cmd_SetBounds, ADMFLAG_GENERIC, "Set convar_test_float bounds");
	
	RegAdminCmd("cvarstring", Cmd_String, ADMFLAG_GENERIC, "Retrieve string convar and data");
	RegAdminCmd("cvarfloat", Cmd_Float, ADMFLAG_GENERIC, "Retrieve float convar and data");
	RegAdminCmd("cvarbool", Cmd_Bool, ADMFLAG_GENERIC, "Retrieve bool convar and data");
	RegAdminCmd("cvarint", Cmd_Int, ADMFLAG_GENERIC, "Retrieve int convar and data");

	RegAdminCmd("cvarsetstring", Cmd_SetString, ADMFLAG_GENERIC, "Set string convar");
	RegAdminCmd("cvarsetfloat", Cmd_SetFloat, ADMFLAG_GENERIC, "Set float convar");
	RegAdminCmd("cvarsetbool", Cmd_SetBool, ADMFLAG_GENERIC, "Set bool convar");
	RegAdminCmd("cvarsetint", Cmd_SetInt, ADMFLAG_GENERIC, "Set int convar");
	
	RegAdminCmd("cvarflags", Cmd_Flags, ADMFLAG_GENERIC, "Change convar_test_enable flags (add/remove FCVAR_NOTIFY)");

	g_Cvar_String.AddChangeHook(Cvar_Changed);
	g_Cvar_Float.AddChangeHook(Cvar_Changed);
	g_Cvar_Bool.AddChangeHook(Cvar_Changed);
	g_Cvar_Int.AddChangeHook(Cvar_Changed);
	
	g_Cvar_Enabled.AddChangeHook(Cvar_OldChanged);
}

public OnPluginEnd()
{
	g_Cvar_String.RemoveChangeHook(Cvar_Changed);
	g_Cvar_Float.RemoveChangeHook(Cvar_Changed);
	g_Cvar_Bool.RemoveChangeHook(Cvar_Changed);
	g_Cvar_Int.RemoveChangeHook(Cvar_Changed);

	g_Cvar_Enabled.RemoveChangeHook(Cvar_OldChanged);
}

public Action:Cmd_Reset(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	char myName[64];
	g_Cvar_Float.GetName(myName, sizeof(myName));
	
	g_Cvar_Float.RestoreDefaultValue();
	
	ReplyToCommand(client, "Reset %s to default value.", myName);
	return Plugin_Handled;
}

public Action:Cmd_SetBounds(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	char myName[64];
	g_Cvar_Float.GetName(myName, sizeof(myName));
	
	if (args < 2)
	{
		ReplyToCommand(client, "Syntax: %s 1.0 6.0");
		return Plugin_Handled;
	}

	float bounds[2];
	
	for (int i = 0; i < 2; i++)
	{
		char boundsString[6];
		GetCmdArg(i+1, boundsString, sizeof(boundsString));
		
		bounds[i] = StringToFloat(boundsString);
	}
	
	g_Cvar_Float.SetBounds(ConVarBound_Lower, true, bounds[0]);
	g_Cvar_Float.SetBounds(ConVarBound_Upper, true, bounds[1]);
	
	ReplyToCommand(client, "Changed %s bounds to %f, %f", myName, bounds[0], bounds[1]);
	return Plugin_Handled;
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
	g_Cvar_String.GetDefaultValue(defaultValue, sizeof(defaultValue));
	
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
	g_Cvar_Float.GetDefaultValue(defaultValue, sizeof(defaultValue));
	
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
	g_Cvar_Bool.GetDefaultValue(defaultValue, sizeof(defaultValue));
	
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
	g_Cvar_Int.GetDefaultValue(defaultValue, sizeof(defaultValue));
	
	int flags = g_Cvar_Int.GetFlags();
	
	ReplyToCommand(client, "\"%s\" cvar flags: %d, value: %d, default: \"%s\", bounds: %f, %f", flags, myName, myValue, defaultValue, bounds[0], bounds[1]);
	
	return Plugin_Handled;
}

public Action:Cmd_SetString(client, args)
{
	char myName[64];
	g_Cvar_String.GetName(myName, sizeof(myName));

	if (args < 1)
	{
		ReplyToCommand(client, "Syntax: %s \"string\"", myName);
		return Plugin_Handled;
	}
	
	char newValue[64];
	GetCmdArg(1, newValue, sizeof(newValue));
	
	ReplyToCommand(client, "Attempting to set %s to %s", myName, newValue);
	
	g_Cvar_String.SetString(newValue);
	
	return Plugin_Handled;
}

public Action:Cmd_SetFloat(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	char myName[64];
	g_Cvar_Float.GetName(myName, sizeof(myName));

	if (args < 1)
	{
		ReplyToCommand(client, "Syntax: %s \"string\"", myName);
		return Plugin_Handled;
	}
	
	char newValue[64];
	GetCmdArg(1, newValue, sizeof(newValue));
	
	float newValueFloat = StringToFloat(newValue);
	
	ReplyToCommand(client, "Attempting to set %s to %f", myName, newValueFloat);

	g_Cvar_Float.SetFloat(newValueFloat);

	return Plugin_Handled;
}

public Action:Cmd_SetBool(client, args)
{
	char myName[64];
	g_Cvar_Bool.GetName(myName, sizeof(myName));

	if (args < 1)
	{
		ReplyToCommand(client, "Syntax: %s \"string\"", myName);
		return Plugin_Handled;
	}
	
	char newValue[64];
	GetCmdArg(1, newValue, sizeof(newValue));
	
	bool newValueBool = bool:StringToInt(newValue);
	
	ReplyToCommand(client, "Attempting to set %s to %d", myName, newValueBool);

	g_Cvar_Bool.SetBool(newValueBool);

	return Plugin_Handled;
}

public Action:Cmd_SetInt(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	char myName[64];
	g_Cvar_Int.GetName(myName, sizeof(myName));

	if (args < 1)
	{
		ReplyToCommand(client, "Syntax: %s \"string\"", myName);
		return Plugin_Handled;
	}
	
	char newValue[64];
	GetCmdArg(1, newValue, sizeof(newValue));
	
	int newValueInt = StringToInt(newValue);
	
	ReplyToCommand(client, "Attempting to set %s to %d", myName, newValueInt);
	
	g_Cvar_Int.SetInt(newValueInt);
	
	return Plugin_Handled;
}

public Action:Cmd_Flags(client, args)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		ReplyToCommand(client, "Plugin is disabled");
		return Plugin_Handled;
	}
	
	new flags = g_Cvar_Enabled.GetFlags();
	if (flags & FCVAR_NOTIFY)
	{
		flags &= ~FCVAR_NOTIFY;
	}
	else
	{
		flags |= FCVAR_NOTIFY;
	}
	
	g_Cvar_Enabled.SetFlags(flags);
	
	ReplyToCommand(client, "New enabled flags: %d", flags);
	
	return Plugin_Handled;
}

public Cvar_Changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		return;
	}
	
	char myName[64];
	convar.GetName(myName, sizeof(myName));
	
	PrintToChatAll("Convar change: %s, from %s to %s", myName, oldValue, newValue);
}

public Cvar_OldChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (!g_Cvar_Enabled.GetBool())
	{
		return;
	}
	
	char myName[64];
	GetConVarName(convar, myName, sizeof(myName));
	
	PrintToChatAll("Convar change: %s, from %s to %s", myName, oldValue, newValue);
}