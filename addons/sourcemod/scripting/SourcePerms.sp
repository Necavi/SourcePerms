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

new Handle:g_hPermissionCache[MAXPLAYERS + 2] = {INVALID_HANDLE, ...};
new Handle:g_hPermissionRegex[MAXPLAYERS + 2] = {INVALID_HANDLE, ...};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("AddClientPerm", Native_AddClientPerm);
	CreateNative("RemoveClientPerm", Native_RemoveClientPerm);
	CreateNative("ClientHasPerm", Native_ClientHasPerm);
	for(new i = 0; i <= MAXPLAYERS; i++)
	{
		g_hPermissionCache[i] = CreateArray(MAX_PERMISSION_LENGTH);
		g_hPermissionRegex[i] = CreateArray();
	}
	return APLRes_Success;
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{

	for(new i = 0; i < GetArraySize(g_hPermissionRegex[client]); i++)
	{
		CloseHandle(GetArrayCell(g_hPermissionRegex[client], i));
	}
	ClearArray(g_hPermissionRegex[client]);
	ClearArray(g_hPermissionCache[client]);
	return true;
}

bool:HasPermission(client, String:permission[])
{
	for(new i = 0; i < GetArraySize(g_hPermissionRegex[client]); i++)
	{
		if(MatchRegex(GetArrayCell(g_hPermissionRegex[client], i), permission))
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
	new client = GetNativeCell(1);
	new String:permission[MAX_PERMISSION_LENGTH];
	GetNativeString(2, permission, sizeof(permission));
	PushArrayString(g_hPermissionCache[GetNativeCell(1)], permission);
	ReplaceString(permission, MAX_PERMISSION_LENGTH * 2, ".", "\\.");
	ReplaceString(permission, MAX_PERMISSION_LENGTH * 2, "*", "(.*)");
	PushArrayCell(g_hPermissionRegex[client], CompileRegex(permission, PCRE_CASELESS));
}

public Native_RemoveClientPerm(Handle:plugin, numParams)
{
	new String:permission[MAX_PERMISSION_LENGTH];
	GetNativeString(2, permission, sizeof(permission));
	new client = GetNativeCell(1);
	new index = FindStringInArray(g_hPermissionCache[client], permission);
	if(index > 0)
	{
		RemoveFromArray(g_hPermissionCache[client], index);
		CloseHandle(GetArrayCell(g_hPermissionRegex[client], index));
		RemoveFromArray(g_hPermissionRegex[client], index);
	}
}







