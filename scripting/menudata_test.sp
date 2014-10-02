/**
 * vim: set ts=4 :
 * =============================================================================
 * MenuData Test
 * Test SM 1.7 Menu Data stuffs
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
#pragma semicolon 1

#define VERSION "1.0.0"

public Plugin:myinfo = {
	name			= "Menu Data Test",
	author			= "Powerlord",
	description		= "Test SM 1.7 Menu Data stuffs",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("menudatatest_version", VERSION, "Menu Data Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);

	RegConsoleCmd("menu1", Cmd_Menu1, "Test a Handle for a menu.");
	RegConsoleCmd("menu2", Cmd_Menu2, "Test a value for a menu.");
	RegConsoleCmd("menu3", Cmd_Menu3, "Test a datamenu.");
	RegConsoleCmd("menu4", Cmd_Menu4, "Test a Handle for a menuex.");
	RegConsoleCmd("menu5", Cmd_Menu5, "Test a value for a menuex.");
	RegConsoleCmd("menu6", Cmd_Menu6, "Test a datamenuex.");
}

public Action Cmd_Menu1(int client, int args)
{
	Handle pack = CreateDataPack();
	WritePackString(pack, "Bacon");
	WritePackCell(pack, 12);
	ResetPack(pack);
	
	Menu menu = Menu(HandleCallback, MENU_ACTIONS_DEFAULT, pack);
	menu.SetCloseHandle(true);
	menu.SetTitle("Test Menu DataPack.");
	menu.AddItem("#test", "Test");
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public Action Cmd_Menu2(int client, int args)
{
	Menu menu = CreateMenu(ValueCallback, MENU_ACTIONS_DEFAULT, 42);
	menu.SetTitle("Test Menu any data.");
	menu.AddItem("#test", "Test");
	DisplayMenu(menu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public Action Cmd_Menu3(int client, int args)
{
	Handle pack;
	Menu menu = CreateDataMenu(HandleCallback, MENU_ACTIONS_DEFAULT, pack);
	
	WritePackString(pack, "Breakfast sandwich");
	WritePackCell(pack, 47);
	ResetPack(pack);
	
	menu.SetTitle("Test DataMenu DataPack.");
	menu.AddItem("#test", "Test");
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public Action Cmd_Menu4(int client, int args)
{
	Handle pack = CreateDataPack();
	WritePackString(pack, "Chalk");
	WritePackCell(pack, 1024);
	ResetPack(pack);
	
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), HandleCallback, MENU_ACTIONS_DEFAULT, pack);
	menu.SetCloseHandle(true);
	menu.SetTitle("Test MenuEx DataPack.");
	menu.AddItem("#test", "Test");
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public Action Cmd_Menu5(int client, int args)
{
	Menu menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), ValueCallback, MENU_ACTIONS_DEFAULT, 13);
	menu.SetTitle("Test MenuEx any data.");
	menu.AddItem("#test", "Test");
	DisplayMenu(menu, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public Action Cmd_Menu6(int client, int args)
{
	Handle pack;
	Menu menu = CreateDataMenuEx(GetMenuStyleHandle(MenuStyle_Radio), HandleCallback, MENU_ACTIONS_DEFAULT, pack);
	
	WritePackString(pack, "Soda Popinski");
	WritePackCell(pack, 104);
	ResetPack(pack);
	
	menu.SetTitle("Test DataMenuEx DataPack.");
	menu.AddItem("#test", "Test");
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int HandleCallback(Menu menu, MenuAction action, int param1, int param2, Handle hndl)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char iteminfo[64];
			menu.GetItem(param2, iteminfo, sizeof(iteminfo));
			if (StrEqual(iteminfo, "#test"))
			{
				char first[64];
				ReadPackString(hndl, first, sizeof(first));
				int second = ReadPackCell(hndl);
				PrintToChat(param1, "Menu returned: %s, %d", first, second);
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int ValueCallback(Menu menu, MenuAction action, int param1, int param2, any data)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char iteminfo[64];
			menu.GetItem(param2, iteminfo, sizeof(iteminfo));
			if (StrEqual(iteminfo, "#test"))
			{
				PrintToChat(param1, "Menu returned: %d", data);
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}