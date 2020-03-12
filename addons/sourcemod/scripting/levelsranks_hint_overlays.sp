#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <clientprefs>
#include <lvl_ranks>
#include <IFR>

public Plugin myinfo = 
{
	name		= "[LR] Hint Overlay",
	version		= "1.0",
	description	= "Draw image in hint",
	author		= "ღ λŌK0ЌЭŦ ღ ™",
	url			= "https://github.com/IL0co"
}

KeyValues kv;
bool iEnable[MAXPLAYERS+1];
Handle g_hCookie;

public void OnPluginStart()
{
	if(LR_IsLoaded())
		LR_OnCoreIsReady();

	g_hCookie = RegClientCookie("LR_Overlays", "LR_Overlays", CookieAccess_Private);
	SetCookieMenuItem(CookieHandler, 0, "LR_Overlays");

	for(int i = 1; i <= MaxClients; i++)	if(IsClientAuthorized(i) && IsClientInGame(i))
		OnClientCookiesCached(i);

	LoadTranslations("lr_module_hint_overlays.phrases");
}

public void LR_OnCoreIsReady()
{
	LR_Hook(LR_OnSettingsModuleUpdate, ConfigLoad);
	LR_Hook(LR_OnLevelChangedPost, OnLevelChanged);
	LR_MenuHook(LR_SettingMenu, LR_OnMenuCreated, LR_OnMenuItemSelected);
	ConfigLoad();
}

public void ConfigLoad()
{
	kv = CreateKeyValues("FakeRank");
	
	char sBuffer[256];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "configs/levels_ranks/hint_overlays.ini");

	if (!FileToKeyValues(kv, sBuffer)) 
		SetFailState("Couldn't parse file %s", sBuffer);
}

void LR_OnMenuCreated(LR_MenuType OnMenuCreated, int client, Menu hMenu)
{
	char sText[64];
	FormatEx(sText, sizeof(sText), "%t", "Overlay_MenuName", iEnable[client] ? "plus" : "minus");
	hMenu.AddItem("Overlays", sText);
}

void LR_OnMenuItemSelected(LR_MenuType OnMenuCreated, int client, const char[] sInfo)
{
	if(strcmp(sInfo, "Overlays") == 0)
	{
		iEnable[client] = !iEnable[client];
		SetClientCookie(client, g_hCookie, iEnable[client] ? "1" : "0");
		LR_ShowMenu(client, LR_SettingMenu);
	}
}

void OnLevelChanged(int client, int iNewLevel, int iOldLevel)
{
	if(!iEnable[client])
		return;

	char buff[16];
	Format(buff, sizeof(buff), "%i", iNewLevel);
	IFR_ShowHintFakeRank(client, kv.GetNum(buff));
}

public void OnClientCookiesCached(int client)
{
	char sCookie[2];
	GetClientCookie(client, g_hCookie, sCookie, sizeof(sCookie));
	iEnable[client] = sCookie[0] == '1' || !sCookie[0];
}

public void CookieHandler(int client, CookieMenuAction action, any info, char[] buffer, int maxlen)
{
	switch (action)
	{
		case CookieMenuAction_DisplayOption:
		{
			SetGlobalTransTarget(client);
			Format(buffer, maxlen, "%t", "Overlay_MenuName", iEnable[client] ? "plus" : "minus");
		}
		case CookieMenuAction_SelectOption:
		{
			iEnable[client] = !iEnable[client];
			SetClientCookie(client, g_hCookie, iEnable[client] ? "1" : "0");
			
			ShowCookieMenu(client);
		}
	}
}
