/**************************************************************************
 *                                                                        *
 *                         More TF2 Stocks                                *
 *                   Author: Ross Bemrose (Powerlord)                     *
 *                       Contributions by Leonardo                        *
 *                          Version: 1.0                                  *
 *                                                                        *
 **************************************************************************/

#if defined _chatstocks_included
 #endinput
#endif
#define _chatstocks_included

#include <sourcemod>

/**
 * Print to chat matching a target mask.
 * 
 * @param pattern	The target mask
 * @param format	Formatting rules
 * @param ,,,		Variable number of format parameters
 */
stock PrintToChatTarget(const String:pattern[], const String:format[], any:...)
{
	decl String:buffer[192];
	
	new targets[MaxClients];
	decl String:target_name[128];
	new bool:tn_is_ml;
	
	new targetCount = ProcessTargetString(pattern, 0, targets, MaxClients, COMMAND_FILTER_NO_IMMUNITY, target_name, sizeof(target_name), tn_is_ml);

	for (new i = 0; i < targetCount; ++i)
	{
		if (IsClientInGame(targets[i]))
		{
			SetGlobalTransTarget(targets[i]);
			VFormat(buffer, sizeof(buffer), format, 3);
			PrintToChat(i, "%s", buffer);
		}
	}
}

/**
 * Prints a message to all clients on a team
 * 
 * @param team		Team to print message to.
 * @param format	Formatting rules.
 * @param ...		Variable number of format parameters.
 * @noreturn
 */
stock PrintToChatTeam(team, const String:format[], any:...)
{
	decl String:buffer[192];
	
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == team)
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 3);
			PrintToChat(i, "%s", buffer);
		}
	}
}

/**
 * Prints a message to all clients but one in the chat area
 * 
 * @param client	Client index to skip.
 * @param format	Formatting rules.
 * @param ...		Variable number of format parameters.
 * @noreturn
 */
stock PrintToChatAllButOne(client, const String:format[], any:...)
{
	decl String:buffer[192];
	
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && i != client)
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 3);
			PrintToChat(i, "%s", buffer);
		}
	}
}

stock PrintHintTextToTarget(const String:pattern[], const String:format[], any:...)
{
	decl String:buffer[192];
	
	new targets[MaxClients];
	decl String:target_name[128];
	new bool:tn_is_ml;
	
	new targetCount = ProcessTargetString(pattern, 0, targets, MaxClients, COMMAND_FILTER_NO_IMMUNITY, target_name, sizeof(target_name), tn_is_ml);

	for (new i = 0; i < targetCount; ++i)
	{
		if (IsClientInGame(targets[i]))
		{
			SetGlobalTransTarget(targets[i]);
			VFormat(buffer, sizeof(buffer), format, 3);
			PrintHintText(i, "%s", buffer);
		}
	}
}

stock PrintHintTextToTeam(team, const String:format[], any:...)
{
	decl String:buffer[192];
	
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == team)
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 3);
			PrintHintText(i, "%s", buffer);
		}
	}
}

stock PrintHintTextToAllButOne(client, const String:format[], any:...)
{
	decl String:buffer[192];
	
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && i != client)
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, sizeof(buffer), format, 3);
			PrintHintText(i, "%s", buffer);
		}
	}
}
