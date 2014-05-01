#include <sourcemod>
#include <regex>
#include <SourcePerms>

public Plugin:myinfo =
{
	name = "SourcePerms",
	author = "necavi",
	description = "A flexible framework for granular pernissions in sourcemod",
	version = "1",
	url = "http://necavi.org"
}

new Handle:g_hPermissionsCache[MAXPLAYERS + 2] = {INVALID_HANDLE, ...};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("AddClientPerm", Native_AddClientPerm);
	CreateNative("RemoveClientPerm", Native_RemoveClientPerm);
	CreateNative("ClientHasPerm", Native_ClientHasPerm);
	return APLRes_Success;
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen);
{
	if(g_hPermissionsCache[client] == INVALID_HANDLE)
	{
		g_hPermissionsCache[client] = CreateArray(MAX_PERMISSION_LENGTH * 2);
	}
	else
	{
		ClearArray(g_hPermissionsCache[client]);
	}
	return true;
}

bool:HasPermission(client, String:permission[])
{
	new String:node[MAX_PERMISSION_LENGTH];
	for(new i = 0; i < GetArraySize(g_hPermissionsCache[client]); i++)
	{
		GetArrayString(g_hPermissionsCache[client], i, node, sizeof(node));
		new Handle:regex = CompileRegex(node, PCRE_CASELESS);
		if(MatchRegex(regex, permission))
		{
			return true;
		}
	}
	return false;
}

public Native_ClientHasPerm(Handle:plugin, numParams)
{
	new String:permission[MAX_PERMISSION_LENGTH];
	GetNativeString(2, permission, sizeof(permission));
	return HasPermission(GetNativeCell(1), permission);
}

public Native_AddClientPerm(Handle:plugin, numParams)
{
	
	new String:permission[MAX_PERMISSION_LENGTH];
	GetNativeString(2, permission, sizeof(permission));
	ReplaceString(permission, MAX_PERMISSION_LENGTH * 2, ".", "\\.");
	ReplaceString(permission, MAX_PERMISSION_LENGTH * 2, "*", "(.*)");
	PushArrayString(g_hPermissionsCache[GetNativeCell(1)], permission);
}

public Native_RemoveClientPerm(Handle:plugin, numParams)
{
	new String:permission[MAX_PERMISSION_LENGTH];
	GetNativeString(2, permission, sizeof(permission));
	ReplaceString(permission, MAX_PERMISSION_LENGTH * 2, ".", "\\.");
	ReplaceString(permission, MAX_PERMISSION_LENGTH * 2, "*", "(.*)");
	new client = GetNativeCell(1);
	new index = FindStringInArray(g_hPermissionsCache[client], permission);
	if(index > 0)
	{
		RemoveFromArray(g_hPermissionsCache[client], index);
	}
}



