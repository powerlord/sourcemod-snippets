/**
 * vim: set ts=4 :
 * =============================================================================
 * [TF2] ForceChangeTeam Test
 * Force a player to change teams using CTFPlayer::ForceChangeTeam(int, bool)
 *
 * [TF2] ForceChangeTeam Test (C)2014 Powerlord (Ross Bemrose).
 * All rights reserved.
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
#include <sdktools>
#include <tf2>
#pragma semicolon 1

#define VERSION "1.0.0"

public Plugin:myinfo = {
	name			= "[TF2] ForceChangeTeam Test",
	author			= "Powerlord",
	description		= "Force a player to change teams using CTFPlayer::ForceChangeTeam(int, bool)",
	version			= VERSION,
	url				= ""
};

new Handle:g_hForceChangeTeam;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	new Handle:gameconf = LoadGameConfigFile("forcechangeteam");
	CreateConVar("tf2_forcechangeteam_test_version", VERSION, "[TF2] ForceChangeTeam Test version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	RegAdminCmd("forcechangeteam", Cmd_ForceChangeTeam, ADMFLAG_KICK, "Force a player to change teams using CTFPlayer::ForceChangeTeam(int, bool)");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gameconf, SDKConf_Signature, "CTFPlayer::ForceChangeTeam");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // team
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain); // unknown bool
	g_hForceChangeTeam = EndPrepSDKCall();
}

public Action:Cmd_ForceChangeTeam(client, args)
{
	if (args == 0)
	{
		ReplyToCommand(client, "Usage: forcechangeteam target [0/1]");
		return Plugin_Handled;
	}
	
	decl String:sTarget[64];
	GetCmdArg(1, sTarget, sizeof(sTarget));
	new bool:useArg = false;
	new TFTeam:team = TFTeam_Unassigned;

	new target = FindTarget(client, sTarget, false, false);

	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	switch (TFTeam:GetClientTeam(target))
	{
		case TFTeam_Red:
		{
			team = TFTeam_Blue;
		}
		
		case TFTeam_Blue:
		{
			team = TFTeam_Red;
		}
		
		default:
		{
			ReplyToCommand(client, "We do not support changing people from unassigned or spectator in this test.");
			return Plugin_Handled;
		}
	}
	
	if (args > 1)
	{
		decl String:sUseArg[3];
		GetCmdArg(2, sUseArg, sizeof(sUseArg));
		useArg = bool:StringToInt(sUseArg);
	}
	
	SDKCall(g_hForceChangeTeam, target, team, useArg);
	
	ReplyToCommand(client, "Attempted to switch team of %N to %d with arg %d", client, team, useArg);
	return Plugin_Handled;
}
