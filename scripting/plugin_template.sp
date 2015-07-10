/**
 * vim: set ts=4 :
 * =============================================================================
 * Name
 * Description
 *
 * Name (C)2015 Powerlord (Ross Bemrose).  All rights reserved.
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
#pragma newdecls required

#define VERSION "1.0.0"

ConVar g_Cvar_Enabled;

public Plugin myinfo = {
	name			= "",
	author			= "Powerlord",
	description		= "",
	version			= VERSION,
	url				= ""
};

// Native Support
/*
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Plugin_FunctionWithArg", Native_FunctionWithArg);
	CreateNative("Plugin_FunctionWithoutArg", Native_FunctionWithoutArg);
	CreateNative("Plugin_RegisterCallback", Native_RegisterCallback);
	CreateNative("Plugin_UnregisterCallback", Native_UnregisterCallback);
	
	RegPluginLibrary("pluginname");
	
	return APLRes_Success;
}
*/
  
public void OnPluginStart()
{
	CreateConVar("_version", VERSION, " version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	g_Cvar_Enabled = CreateConVar("_enable", "1", "Enable ?", FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
}

/*
// Natives

// native FunctionWithArg(const char[] param1);
public int Native_FunctionWithArg(Handle plugin, int numParams)
{
	// for const Strings
	int size;
	GetNativeStringLength(1, size);
	char[] param1 = new char[size+1];
	GetNativeString(1, param1, size+1);
}

// native bool FunctionWithoutArg();
public int Native_FunctionWithoutArg(Handle plugin, int numParams)
{
	return true;
}

// native RegisterCallback(ACallback);
public void Native_RegisterCallback(Handle plugin, int numParams)
{
}
	
// native UnregisterCallback(ACallback);
public void Native_UnregisterCallback(Handle plugin, int numParams)
{
}
*/

