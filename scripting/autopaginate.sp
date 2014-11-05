/**
 * vim: set ts=4 :
 * =============================================================================
 * Autopaginate Test
 * Test the Autopaginate stock
 *
 * Autopaginate Test (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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
#include "include/autopaginate.inc"
#pragma semicolon 1

#define VERSION "1.0.0"

public Plugin:myinfo = {
	name			= "Autopaginate Test",
	author			= "Powerlord",
	description		= "Test the Autopaginate stock",
	version			= VERSION,
	url				= "https://forums.alliedmods.net/showthread.php?t=250225"
};

public OnPluginStart()
{
	CreateConVar("autopaginate_test_version", VERSION, "Autopaginate Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegConsoleCmd("autopaginate1", Cmd_AutoPaginate1, "Autopagination test #1");
	RegConsoleCmd("autopaginate2", Cmd_AutoPaginate2, "Autopagination test #2");
	RegConsoleCmd("autopaginate3", Cmd_AutoPaginate3, "Autopagination test #3");
	RegConsoleCmd("autopaginate4", Cmd_AutoPaginate4, "Autopagination test #4");
}

public Action:Cmd_AutoPaginate1(client, args)
{
	new Handle:menu = CreateMenu(MyHandler);
	
	AddMenuItem(menu, "Item 1", "Item 1");
	AddMenuItem(menu, "Item 2", "Item 2");
	AddMenuItem(menu, "Item 3", "Item 3");
	AddMenuItem(menu, "Item 4", "Item 4");
	AddMenuItem(menu, "Item 5", "Item 5");
	AddMenuItem(menu, "Item 6", "Item 6");
	AddMenuItem(menu, "Item 7", "Item 7");
	
	AutoPaginate(menu);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public Action:Cmd_AutoPaginate2(client, args)
{
	new Handle:menu = CreateMenu(MyHandler);
	
	AddMenuItem(menu, "Item 1", "Item 1");
	AddMenuItem(menu, "Item 2", "Item 2");
	AddMenuItem(menu, "Item 3", "Item 3");
	AddMenuItem(menu, "Item 4", "Item 4");
	AddMenuItem(menu, "Item 5", "Item 5");
	AddMenuItem(menu, "Item 6", "Item 6");
	AddMenuItem(menu, "Item 7", "Item 7");
	AddMenuItem(menu, "Item 8", "Item 8");
	AddMenuItem(menu, "Item 9", "Item 9");
	AddMenuItem(menu, "Item 10", "Item 10");
	
	AutoPaginate(menu);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public Action:Cmd_AutoPaginate3(client, args)
{
	new Handle:menu = CreateMenu(MyHandler);
	
	AddMenuItem(menu, "Item 1", "Item 1");
	AddMenuItem(menu, "Item 2", "Item 2");
	AddMenuItem(menu, "Item 3", "Item 3");
	AddMenuItem(menu, "Item 4", "Item 4");
	AddMenuItem(menu, "Item 5", "Item 5");
	AddMenuItem(menu, "Item 6", "Item 6");
	AddMenuItem(menu, "Item 7", "Item 7");
	AddMenuItem(menu, "Item 8", "Item 8");
	AddMenuItem(menu, "Item 9", "Item 9");
	AddMenuItem(menu, "Item 10", "Item 10");
	
	SetMenuExitButton(menu, false);
	
	AutoPaginate(menu);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public Action:Cmd_AutoPaginate4(client, args)
{
	new Handle:menu = CreateMenu(MyHandler);
	
	AddMenuItem(menu, "Item 1", "Item 1");
	AddMenuItem(menu, "Item 2", "Item 2");
	AddMenuItem(menu, "Item 3", "Item 3");
	AddMenuItem(menu, "Item 4", "Item 4");
	AddMenuItem(menu, "Item 5", "Item 5");
	AddMenuItem(menu, "Item 6", "Item 6");
	AddMenuItem(menu, "Item 7", "Item 7");
	AddMenuItem(menu, "Item 8", "Item 8");
	AddMenuItem(menu, "Item 9", "Item 9");
	
	AutoPaginate(menu);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}


public MyHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			new String:itemText[64];
			GetMenuItem(menu, param2, itemText, sizeof(itemText));
			
			PrintToChat(param1, "You selected %s", itemText);
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}