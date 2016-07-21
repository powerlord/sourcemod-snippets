/**
 * vim: set ts=4 :
 * =============================================================================
 * Implode/Explode ADT tester
 * Tests implodeexplode.inc
 *
 * Implode/Explode ADT tester (C)2016 Powerlord (Ross Bemrose).  All rights reserved.
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

// Force this to be newdecls checked
#include "include/implodeexplode.inc"

#define VERSION "1.0.0"

#define LIST "vanilla,chocolate,mint,butter pecan"
#define MAPLIST "scout:fast,heavy:slow,pyro:medium,demoman:kinda slow"

#define ITEM_SIZE 30

ArrayList g_TestArray;
StringMap g_TestMap;

public Plugin myinfo = {
	name			= "Implode/Explode ADT tester",
	author			= "Powerlord",
	description		= "Tests implodeexplode.inc",
	version			= VERSION,
	url				= ""
};

public void OnPluginStart()
{
	CreateConVar("implodeexplode_version", VERSION, "Implode/Explode ADT tester version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegAdminCmd("arrayexplode", Cmd_Explode, ADMFLAG_GENERIC, "Test ArrayList explode");
	RegAdminCmd("arrayimplode", Cmd_Implode, ADMFLAG_GENERIC, "Test ArrayList implode");
	RegAdminCmd("mapkeyexplode", Cmd_MapKeyExplode, ADMFLAG_GENERIC, "Test StringMap explode");
	RegAdminCmd("mapbothexplode", Cmd_MapBothExplode, ADMFLAG_GENERIC, "Test StringMap explode");
	RegAdminCmd("mapkeyimplode", Cmd_MapKeyImplode, ADMFLAG_GENERIC, "Test StringMap implode");
	RegAdminCmd("mapvalimplode", Cmd_MapValImplode, ADMFLAG_GENERIC, "Test StringMap implode");
	RegAdminCmd("mapbothimplode", Cmd_MapBothImplode, ADMFLAG_GENERIC, "Test StringMap implode");

	PopulateVars();
}

void PopulateVars()
{
	g_TestArray = new ArrayList(ByteCountToCells(ITEM_SIZE));
	g_TestArray.PushString("pepperoni");
	g_TestArray.PushString("sausage");
	g_TestArray.PushString("onion");
	g_TestArray.PushString("mushroom");
	
	g_TestMap = new StringMap();
	g_TestMap.SetString("apple", "yummy");
	g_TestMap.SetString("banana", "good");
	g_TestMap.SetString("kumquat", "yuck");
	g_TestMap.SetString("lemon", "sour");
}

public Action Cmd_Explode(int client, int args)
{
	ArrayList newItems = new ArrayList(ByteCountToCells(ITEM_SIZE));
	
	int count = ExplodeStringToArrayList(LIST, ",", newItems, ITEM_SIZE);
	
	ReplyToCommand(client, "%d items", count);
	PrintArrayList(client, newItems);
	
	return Plugin_Handled;
}

public Action Cmd_Implode(int client, int args)
{
	char itemString[1024];
	int bytes = ImplodeArrayListStrings(g_TestArray, ",", itemString, sizeof(itemString));
	
	ReplyToCommand(client, "%d bytes, string: \"%s\"", bytes, itemString);
	
	return Plugin_Handled;
}

public Action Cmd_MapKeyExplode(int client, int args)
{
	StringMap newItems = new StringMap();
	
	int count = ExplodeStringToStringMap(LIST, ",", newItems, ITEM_SIZE, ImplodePart_Key);
	ReplyToCommand(client, "%d items", count);
	PrintStringMap(client, newItems);
	
	return Plugin_Handled;
}

public Action Cmd_MapBothExplode(int client, int args)
{
	StringMap newItems = new StringMap();
	
	int count = ExplodeStringToStringMap(MAPLIST, ",", newItems, ITEM_SIZE, ImplodePart_Both, ":");
	ReplyToCommand(client, "%d items", count);
	PrintStringMap(client, newItems);
	
	return Plugin_Handled;
}

public Action Cmd_MapKeyImplode(int client, int args)
{
	char itemString[1024];
		
	int bytes = ImplodeStringMapToString(g_TestMap, ",", itemString, sizeof(itemString), ImplodePart_Key);

	ReplyToCommand(client, "%d bytes, string: \"%s\"", bytes, itemString);

	return Plugin_Handled;
}

public Action Cmd_MapValImplode(int client, int args)
{
	char itemString[1024];
		
	int bytes = ImplodeStringMapToString(g_TestMap, ",", itemString, sizeof(itemString), ImplodePart_Value);

	ReplyToCommand(client, "%d bytes, string: \"%s\"", bytes, itemString);

	return Plugin_Handled;
}

public Action Cmd_MapBothImplode(int client, int args)
{
	char itemString[1024];
	
	int bytes = ImplodeStringMapToString(g_TestMap, ",", itemString, sizeof(itemString), ImplodePart_Both, ":");

	ReplyToCommand(client, "%d bytes, string: \"%s\"", bytes, itemString);

	return Plugin_Handled;
}

void PrintArrayList(int client, ArrayList items)
{
	char item[ITEM_SIZE];
	
	for (int i = 0; i < items.Length; i++)
	{
		items.GetString(i, item, sizeof(item));
		ReplyToCommand(client, "%d: \"%s\"", i, item);
	}
}

void PrintStringMap(int client, StringMap items)
{
	StringMapSnapshot snapshot = items.Snapshot();
	
	for (int i = 0; i < snapshot.Length; i++)
	{
		int len = snapshot.KeyBufferSize(i);
		char[] key = new char[len];
		snapshot.GetKey(i, key, len);
		char value[ITEM_SIZE];
		items.GetString(key, value, sizeof(value));
		
		ReplyToCommand(client, "\"%s\": \"%s\"", key, value);
	}
}

