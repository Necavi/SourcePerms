#pragma semicolon 1

#define MAX_PERMISSION_LENGTH 256

#include <sourcemod>
#include <regex>

public Plugin:myinfo =
{
	name = "SourcePerms",
	author = "necavi",
	description = "A flexible framework for granular pernissions in sourcemod",
	version = "1",
	url = "http://necavi.org"
}

g_hPermissionsCache[MAXPLAYERS + 2] = {INVALID_HANDLE, ...};

APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	createnative("ClientHasPermission", Native_ClientHasPermission);
	return APLRes_Success;
}

OnClientConnected(client)
{
	if(g_hPermissionsCache[client] == INVALID_HANDLE)
	{
		g_hOnPermissionCheck[client] = createarray(MAX_PERMISSION_LENGTH);
	}
	else
	{
		cleararray(g_hPermissionsCache[client]);
	}
}

HasPermission(client, const String:permission[])
{

	
}
Native_ClientHasPermission(Handle:plugin, numParams)
{
	new String:permission[MAX_PERMISSION_LENGTH];
	GetNativeString(2, permission, sizeof(permission));
	return HasPermission(client, permission)
}