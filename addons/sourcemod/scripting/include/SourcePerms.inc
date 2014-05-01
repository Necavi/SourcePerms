#pragma semicolon 1

#define MAX_PERMISSION_LENGTH 256

#include <sourcemod>

native AddClientPerm(client, const String:permission[]);
native RemoveClientPerm(client, const String:permission[]);
native ClientHasPerm(client, const String:permission[]);