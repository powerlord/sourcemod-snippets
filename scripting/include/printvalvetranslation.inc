/*
 * Functions inspired by Valve's code in the Source SDK 2013
 */
#if defined _textmsg_included
  #endinput
#endif
#define _textmsg_included

enum Destination
{
	Destination_HintText 		= 1,
	Destination_ClientConsole	= 2,
	Destination_Chat			= 3,
	Destination_CenterText		= 4,
}

/**
 * Print a Valve translation phrase to a group of players
 * Adapted from util.h's UTIL_PrintToClientFilter
 * 
 * NOTE:  This CANNOT be called inside of a UserMessage handler.
 * If you need to call it from one, use RequestFrame or a timer to delay
 * the call
 * 
 * NOTE: param1 through param4 can also be another Valve translation
 * phrase. If it is, prefix it with a #
 * 
 * @param clients		A list of clients to send the message to
 * @param numClients	The number of clients in the list
 * @param msg_dest		A Destination enumeration value
 * 						Some values may not work on some games.
 * @param msg_name		The translation string to use, prefixed with #
 * @param param1		The first parameter in the translation phrase
 * @param param2		The second parameter in the translation phrase
 * @param param3		The third parameter in the translation phrase
 * @param param4		The fourth parameter in the translation phrase
*/
stock void PrintValveTranslation(int[] clients,
								 int numClients,
								 Destination msg_dest,
								 const char[] msg_name,
								 const char[] param1="",
								 const char[] param2="",
								 const char[] param3="",
								 const char[] param4="")
{
	Handle msg = StartMessage("TextMsg", clients, numClients, USERMSG_RELIABLE);
	
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf proto = UserMessageToProtobuf(msg);
		
		proto.SetInt("msg_dst", view_as<int>(msg_dest));
		proto.AddString("params", msg_name);
		
		proto.AddString("params", param1);
		proto.AddString("params", param2);
		proto.AddString("params", param3);
		proto.AddString("params", param4);
	}
	else
	{
		BfWrite bf = UserMessageToBfWrite(msg);
		
		bf.WriteByte(view_as<int>(msg_dest));
		bf.WriteString(msg_name);
		
		bf.WriteString(param1);
		bf.WriteString(param2);
		bf.WriteString(param3);
		bf.WriteString(param4);
	}
	
	EndMessage();
}

/**
 * Print a Valve translation phrase to all players
 * 
 * See documentation for PrintValveTranslation for more notes.
 * 
 * @param msg_dest		A Destination enumeration value
 * 						Some values may not work on some games.
 * @param msg_name		The translation string to use, prefixed with #
 * @param param1		The first parameter in the translation phrase
 * @param param2		The second parameter in the translation phrase
 * @param param3		The third parameter in the translation phrase
 * @param param4		The fourth parameter in the translation phrase
*/
stock void PrintValveTranslationToAll(Destination msg_dest,
									  const char[] msg_name,
									  const char[] param1="",
									  const char[] param2="",
									  const char[] param3="",
									  const char[] param4="")
{
	int total = 0;
	int[] clients = new int[MaxClients];
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			clients[total++] = i;
		}
	}
	PrintValveTranslation(clients, total, msg_dest, msg_name, param1, param2, param3, param4);
}

/**
 * Print a Valve translation phrase to one player.
 * 
 * See documentation for PrintValveTranslation for more notes.
 * 
 * @param client		The client to send to
 * @param msg_dest		A Destination enumeration value
 * 						Some values may not work on some games.
 * @param msg_name		The translation string to use, prefixed with #
 * @param param1		The first parameter in the translation phrase
 * @param param2		The second parameter in the translation phrase
 * @param param3		The third parameter in the translation phrase
 * @param param4		The fourth parameter in the translation phrase
*/
stock void PrintValveTranslationToOne(int client,
									  Destination msg_dest,
									  const char[] msg_name,
									  const char[] param1="",
									  const char[] param2="",
									  const char[] param3="",
									  const char[] param4="")
{
	int players[1];
	
	players[0] = client;
	
	PrintValveTranslation(players, 1, msg_dest, msg_name, param1, param2, param3, param4);
}
