#pragma semicolon 1
#pragma newdecls required

#define COLOR_MAX_LENGTH 16
#define TAG_MAX_LENGTH 16

#include <sourcemod>
#include <geoip>
#include <csgocolors_fix>

public Plugin myinfo =
{
	name			= "Connect message",
	author		= "kurumi",
	description = "A plugin to display connect/disconnect message to the chat.",
	version		= "1.1",
	url			= "https://github.com/tokKurumi"
};

ConVar g_cm_show_connect;
ConVar g_cm_show_disconnct;

ConVar g_cm_tag;
ConVar g_cm_tag_color;
ConVar g_cm_name_color;
ConVar g_cm_text_color;
ConVar g_cm_country_color;

bool g_SHOW_CONNECT = true;
bool g_SHOW_DISCONNECT = true;

char g_TAG[TAG_MAX_LENGTH];
char g_TAG_COLOR[COLOR_MAX_LENGTH];
char g_NAME_COLOR[COLOR_MAX_LENGTH];
char g_TEXT_COLOR[COLOR_MAX_LENGTH];
char g_COUNTRY_COLOR[COLOR_MAX_LENGTH];

public void OnShowConnectChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	g_SHOW_CONNECT = cvar.BoolValue;
}
public void OnShowDisconnectChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	g_SHOW_DISCONNECT = cvar.BoolValue;
}
public void OnTagChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	strcopy(g_TAG, sizeof(g_TAG), newValue);
}
public void OnTagColorChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	strcopy(g_TAG_COLOR, sizeof(g_TAG_COLOR), newValue);
}
public void OnNameColorChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	strcopy(g_NAME_COLOR, sizeof(g_NAME_COLOR), newValue);
}
public void OnTextColorChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	strcopy(g_TEXT_COLOR, sizeof(g_TEXT_COLOR), newValue);
}
public void OnCountryColorChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	strcopy(g_COUNTRY_COLOR, sizeof(g_COUNTRY_COLOR), newValue);
}

public void OnPluginStart()
{
	g_cm_show_connect = CreateConVar("cm_show_connect", "1", "Shows a connect message in the chat once a player joins.", _, true, 0.0, true, 1.0);
	g_cm_show_disconnct = CreateConVar("cm_show_disconnct", "1", "Shows a disconnect message in the chat once a player leaves.", _, true, 0.0, true, 1.0);

	g_cm_tag = CreateConVar("cm_tag", "[ZR]", "Connect message chat tag.");
	g_cm_tag_color = CreateConVar("cm_tag_color", "{blue}", "Connect message chat tag color.");
	g_cm_name_color = CreateConVar("cm_name_color", "{lightgreen}", "Connect message chat player name color.");
	g_cm_text_color = CreateConVar("cm_text_color", "{default}", "Connect message chat text color.");
	g_cm_country_color = CreateConVar("cm_country_color", "{lightgreen}", "Connect message chat country color.");


	g_cm_show_connect.AddChangeHook(OnShowConnectChanged);
	g_cm_show_disconnct.AddChangeHook(OnShowDisconnectChanged);

	g_cm_tag.AddChangeHook(OnTagChanged);
	g_cm_tag_color.AddChangeHook(OnTagColorChanged);
	g_cm_name_color.AddChangeHook(OnNameColorChanged);
	g_cm_text_color.AddChangeHook(OnTextColorChanged);
	g_cm_country_color.AddChangeHook(OnCountryColorChanged);


	g_cm_tag.GetDefault(g_TAG, sizeof(g_TAG));
	g_cm_tag_color.GetDefault(g_TAG_COLOR, sizeof(g_TAG_COLOR));
	g_cm_name_color.GetDefault(g_NAME_COLOR, sizeof(g_NAME_COLOR));
	g_cm_text_color.GetDefault(g_TEXT_COLOR, sizeof(g_TEXT_COLOR));
	g_cm_country_color.GetDefault(g_COUNTRY_COLOR, sizeof(g_COUNTRY_COLOR));

	RegAdminCmd("sm_connectmessage_test", CMD_TEST, ADMFLAG_ROOT, "Command to test 'Connect message' plugin.");
}

public Action CMD_TEST(int iClient, int args)
{
	if(g_SHOW_CONNECT)
	{
		CPrintToChatAll("%s%s %s%s (%s) %shas connected to the server from %s%s", g_TAG_COLOR, g_TAG, g_NAME_COLOR, "kurumi", "STEAM_0:0:217789846", g_TEXT_COLOR, g_COUNTRY_COLOR, "Russia");
	}

	if(g_SHOW_DISCONNECT)
	{
		CPrintToChatAll("%s%s %s%s (%s) %shas disconnected from the server", g_TAG_COLOR, g_TAG, g_NAME_COLOR, "kurumi", "STEAM_0:0:217789846", g_TEXT_COLOR);
	}

	return Plugin_Handled;
}

public void OnClientPutInServer(int iClient)
{
	if(g_SHOW_CONNECT && !IsFakeClient(iClient))
	{
		char name[MAX_MESSAGE_LENGTH];
		char authid[MAX_AUTHID_LENGTH];
		char ip[16];
		char country[MAX_MESSAGE_LENGTH];

		GetClientName(iClient, name, sizeof(name));
		GetClientAuthId(iClient, AuthId_Steam2, authid, sizeof(authid));
		GetClientIP(iClient, ip, sizeof(ip), true);

		if(!GeoipCountry(ip, country, sizeof(country)))
		{
			country = "{red}Unknown Country";
		}

		CPrintToChatAll("%s%s %s%s (%s) %shas connected to the server from %s%s", g_TAG_COLOR, g_TAG, g_NAME_COLOR, name, authid, g_TEXT_COLOR, g_COUNTRY_COLOR, country);
	}
}

public void OnClientDisconnect(int iClient)
{
	if(g_SHOW_DISCONNECT && !IsFakeClient(iClient))
	{
		char name[MAX_MESSAGE_LENGTH];
		char authid[MAX_AUTHID_LENGTH];
		char ip[16];
		char country[MAX_MESSAGE_LENGTH];

		GetClientName(iClient, name, sizeof(name));
		GetClientAuthId(iClient, AuthId_Steam2, authid, sizeof(authid));
		GetClientIP(iClient, ip, sizeof(ip), true);

		if(!GeoipCountry(ip, country, sizeof(country)))
		{
			country = "{red}Unknown Country";
		}

		CPrintToChatAll("%s%s %s%s (%s) %shas disconnected from the server", g_TAG_COLOR, g_TAG, g_NAME_COLOR, name, authid, g_TEXT_COLOR);
	}
}