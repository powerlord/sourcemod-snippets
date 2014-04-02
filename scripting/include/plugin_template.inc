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
#if defined _pluginname_included_
  #endinput
#endif
#define _pluginname_included_

// Plugin 1.0 series

enum AppropriateEnum
{
	AppropriateEnum_First,		/** Description of first */
	AppropriateEnum_Second,		/** Description of second */
};

/**
 * Called whenever a global forward happens
 * 
 */
forward Plugin_AGlobalForward();


/**
 * Callback for something
 */
functag public Plugin_ACallback(const String:param1[]);

/**
 * Register and unregister said callbacks
 */
native Plugin_RegisterCallback(ACallback);
native Plugin_UnregisterCallback(ACallback);

/**
 * A function with arg that returns nothing
 * 
 * @param param1 	Param to check
 * @noreturn
 * @error if it errors sometimes
 */
native Plugin_FunctionWithArg(const String:param1[]);

/**
 * Function without arg
 * 
 * @return 		True if it's true. Otherwise false
 */
native bool:Plugin_FunctionWithoutArg();

/**
 * A Common Function for doing something, probably a wrapper for a native
 *
 * @noreturn
 */
stock Plugin_ACommonFunction()
{
	// Some code here
}

public SharedPlugin:__pl_pluginname = 
{
	name = "pluginname",
	file = "pluginname.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_pluginname_SetNTVOptional()
{
	MarkNativeAsOptional("FunctionWithArg");
	MarkNativeAsOptional("FunctionWithoutArg");
	MarkNativeAsOptional("RegisterCallback");
	MarkNativeAsOptional("UnregisterCallback");
}
#endif
