/**
 * vim: set ts=4 :
 * =============================================================================
 * Name
 * Description
 *
 * Name (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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

#pragma newdecls required
#include "include/colors"
#pragma semicolon 1

#define VERSION "2.0.0"

#define TAG "[CIT] "
//new Handle:g_Cvar_Enabled;

public Plugin myinfo = {
	name			= "colors.inc Tester",
	author			= "Powerlord",
	description		= "Tests new functions for colors.inc",
	version			= VERSION,
	url				= "https://forums.alliedmods.net/showthread.php?t=96831"
};

public void OnPluginStart()
{
	CreateConVar("colorstester_version", VERSION, "Colors Tester version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	//g_Cvar_Enabled = CreateConVar("colorstester_enable", "1", "Enable ?", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
	RegAdminCmd("creplytocommand", Cmd_CReplyToCommand, ADMFLAG_GENERIC, "Test CReplyToCommand");
	RegAdminCmd("creplytocommandex", Cmd_CReplyToCommandEx, ADMFLAG_GENERIC, "Test CReplyToCommandEx");
	RegAdminCmd("cprinttochat", Cmd_CPrintToChat, ADMFLAG_GENERIC, "Test CPrintToChat");
	RegAdminCmd("cprinttochatex", Cmd_CPrintToChatEx, ADMFLAG_GENERIC, "Test CPrintToChatEx");
	RegAdminCmd("cprinttochatall", Cmd_CPrintToChat, ADMFLAG_GENERIC, "Test CPrintToChatAll");
	RegAdminCmd("cprinttochatallex", Cmd_CPrintToChatEx, ADMFLAG_GENERIC, "Test CPrintToChatAllEx");
	RegAdminCmd("showactivity", Cmd_ShowActivity, ADMFLAG_GENERIC, "Test CShowActivity");
	RegAdminCmd("showactivityex", Cmd_ShowActivityEx, ADMFLAG_GENERIC, "Test CShowActivityEx");
	RegAdminCmd("showactivity2", Cmd_ShowActivity2, ADMFLAG_GENERIC, "Test CShowActivity2");
}

public Action Cmd_CReplyToCommand(int client, int args)
{
	CReplyToCommand(client, "Tested {green}CReplyToCommand");
	return Plugin_Handled;
}

public Action Cmd_CReplyToCommandEx(int client, int args)
{
	CReplyToCommandEx(client, client, "Tested {teamcolor}CReplyToCommandEx");
	return Plugin_Handled;
}

public Action Cmd_CPrintToChat(int client, int args)
{
	CPrintToChat(client, "Tested {green}CPrintToChat");
	return Plugin_Handled;
}

public Action Cmd_CPrintToChatEx(int client, int args)
{
	CPrintToChatEx(client, client, "Tested {teamcolor}CPrintToChatEx");
	return Plugin_Handled;
}

public Action Cmd_CPrintToChatAll(int client, int args)
{
	CPrintToChatAll("Tested {green}CPrintToChatAll");
	return Plugin_Handled;
}

public Action Cmd_CPrintToChatAllEx(int client, int args)
{
	CPrintToChatAllEx( client, "Tested {teamcolor}CPrintToChatAllEx");
	return Plugin_Handled;
}

public Action Cmd_ShowActivity(int client, int args)
{
	CShowActivity(client, "Tested {teamcolor}CShowActivity");
	return Plugin_Handled;
}

public Action Cmd_ShowActivityEx(int client, int args)
{
	CShowActivityEx(client, TAG, "Tested {teamcolor}CShowActivityEx");
	return Plugin_Handled;
}

public Action Cmd_ShowActivity2(int client, int args)
{
	CShowActivity2(client, TAG, "Tested {teamcolor}CShowActivity2");
	return Plugin_Handled;
}
