/**
 * vim: set ts=4 :
 * =============================================================================
 * Scene Data Collector
 * Collect data on scenes (logic_choreographed, instanced_scripted, scripted)
 *
 * Scene Data Collector (C)2014 Powerlord (Ross Bemrose).  All rights reserved.
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
#include <sdkhooks>
#include <sdktools>
#pragma semicolon 1

#define VERSION "1.0.1"

#define LOGFILE "scenes.txt"
public Plugin:myinfo = {
	name			= "Scene Data Collector",
	author			= "Powerlord",
	description		= "Collect data on scenes (logic_choreographed, instanced_scripted, scripted)",
	version			= VERSION,
	url				= ""
};

public OnPluginStart()
{
	CreateConVar("scenedatacollector_version", VERSION, "Scene Data Collector version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
}

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "instanced_scripted_scene"))
	{
		HookSingleEntityOutput(entity, "OnStart", InstanceOnStart);
	}
	else
	if (StrEqual(classname, "logic_choreographed_scene") || StrEqual(classname, "scripted_scene"))
	{
		HookSingleEntityOutput(entity, "OnStart", OnStart);
	}
}

public InstanceOnStart(const String:output[], caller, activator, Float:delay)
{
	OnStart(output, caller, activator, delay);
	
	new String:sInstanceFile[PLATFORM_MAX_PATH];
	
	GetEntPropString(caller, Prop_Data, "m_szInstanceFilename", sInstanceFile, sizeof(sInstanceFile));
	
	LogToFile(LOGFILE, "owner: %d, instancefile: %s, isBackground: %d", GetEntPropEnt(caller, Prop_Data, "m_hOwner"), sInstanceFile, GetEntProp(caller, Prop_Data, "m_bIsBackground"));
}

public OnStart(const String:output[], caller, activator, Float:delay)
{
	decl String:classname[64];
	new String:sSceneFile[PLATFORM_MAX_PATH];
	new String:sResumeSceneFile[PLATFORM_MAX_PATH];
	new String:sTargets[8][64];
	new targets[8];
	
	GetEntityClassname(caller, classname, sizeof(classname));
	
	GetEntPropString(caller, Prop_Data, "m_iszSceneFile", sSceneFile, sizeof(sSceneFile));
	GetEntPropString(caller, Prop_Data, "m_iszResumeSceneFile", sResumeSceneFile, sizeof(sResumeSceneFile));
	for (new i = 0; i < sizeof(sTargets); i++)
	{
		decl String:sTargetString[13];
		decl String:hTargetString[11];
		Format(sTargetString, sizeof(sTargetString), "m_iszTarget%d", i+1);
		Format(hTargetString, sizeof(hTargetString), "m_hTarget%d", i+1);
		GetEntPropString(caller, Prop_Data, sTargetString, sTargets[i], sizeof(sTargets[]));
		targets[i] = GetEntPropEnt(caller, Prop_Data, hTargetString);
	}
	
	LogToFile(LOGFILE, "%s started. file: %s, resumefile: %s, busyactor: %d, target1: %s (%d), target2: %s (%d), target3: %s (%d), target4: %s (%d), target5: %s (%d), target6: %s (%d), target7: %s (%d), target8: %s (%d)",
		classname, sSceneFile, sResumeSceneFile, GetEntProp(caller, Prop_Data, "m_BusyActor"), sTargets[0], targets[0], sTargets[1], targets[1], sTargets[2], targets[2], sTargets[3], targets[3], sTargets[4], targets[4],
		sTargets[5], targets[5], sTargets[6], targets[6], sTargets[7], targets[7]);
		
	for (new i = 0; i < sizeof(targets); i++)
	{
		if (targets[i] > 0 && targets[i] <= MaxClients)
		{
			LogToFile(LOGFILE, "target%d is %L", i, targets[i]);
		}
	}
}
