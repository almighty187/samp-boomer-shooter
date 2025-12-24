#include <YSI_Coding\y_hooks>

static enum E_PLAYER_DATA
{
	E_PLAYER_CASH,
	E_PLAYER_SCORE
}

static PlayerData[MAX_PLAYERS][E_PLAYER_DATA];

AddPlayerScore(playerid, score = 1)
{
	PlayerData[playerid][E_PLAYER_SCORE] += score;
	SetPlayerScore(playerid, PlayerData[playerid][E_PLAYER_SCORE]);
}

GetPlayerCash(playerid)
{
	return PlayerData[playerid][E_PLAYER_CASH];
}

GetPlayerServerScore(playerid)
{
	return PlayerData[playerid][E_PLAYER_SCORE];
}

SetPlayerCash(playerid, amount)
{
	PlayerData[playerid][E_PLAYER_CASH] = amount;
	UpdateClientCash(playerid);
}

GivePlayerCash(playerid, amount)
{
	PlayerData[playerid][E_PLAYER_CASH] += amount;
	UpdateClientCash(playerid);
}

UpdateClientCash(playerid)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerData[playerid][E_PLAYER_CASH]);
}

ResetPlayerData(playerid)
{
	PlayerData[playerid][E_PLAYER_CASH] = 0;
	PlayerData[playerid][E_PLAYER_SCORE] = 0;
}

hook OnPlayerConnect(playerid)
{
	ResetPlayerData(playerid);
}

CMD:help(playerid, params[])
{
	new info[512];

	strcat(info, "{FFFFFF}=== General Commands ===\n");
	strcat(info, "/arenas - Select an arena to join\n");
	strcat(info, "/lobby - Return to the lobby\n");
	strcat(info, "/skin - Change your lobby skin\n");
	strcat(info, "/stats - View your statistics\n");
	strcat(info, "/myhighscores - View your highest killstreak\n");
	strcat(info, "/vips - View online VIP players\n\n");

	if (IsPlayerAdminLevel(playerid, ADMIN_LEVEL_MODERATOR))
	{
		strcat(info, "{FF6347}You have admin access. Use /ahelp for admin commands.\n");
	}

	new title[] = "Player Commands";
	new button[] = "Close";

	Dialog_Show(playerid, PlayerHelp, t_DIALOG_STYLE:DIALOG_STYLE_MSGBOX, title, info, button, "");
	return 1;
}

Dialog:PlayerHelp(playerid, response, listitem, inputtext[])
{
	return 1;
}

CMD:stats(playerid, params[])
{
	new score = GetPlayerServerScore(playerid);
	new cash = GetPlayerCash(playerid);
	new kills = GetPlayerKills(playerid);
	new deaths = GetPlayerDeaths(playerid);
	new Float:kd = GetPlayerKDRatio(playerid);
	new E_ADMIN_LEVEL:adminLevel = GetPlayerAdminLevel(playerid);
	new E_VIP_LEVEL:vipLevel = GetPlayerVipLevel(playerid);

	new adminLevelName[32], vipLevelName[32];
	GetAdminLevelName(adminLevel, adminLevelName);
	GetVipLevelName(vipLevel, vipLevelName);

	new info[512];
	format(info, sizeof info,
		"{FFFFFF}Score: {00FF00}%d\n\
		{FFFFFF}Cash: {00FF00}$%d\n\
		{FFFFFF}Kills: {00FF00}%d\n\
		{FFFFFF}Deaths: {00FF00}%d\n\
		{FFFFFF}K/D Ratio: {00FF00}%.2f\n\
		{FFFFFF}Admin Level: {FF6347}%s\n\
		{FFFFFF}VIP Level: {FFD700}%s",
		score, cash, kills, deaths, kd, adminLevelName, vipLevelName);

	new title[] = "Player Statistics";
	new button[] = "Close";

	Dialog_Show(playerid, PlayerStats, t_DIALOG_STYLE:DIALOG_STYLE_MSGBOX, title, info, button, "");
	return 1;
}

Dialog:PlayerStats(playerid, response, listitem, inputtext[])
{
	return 1;
}

CMD:myhighscores(playerid, params[])
{
	new killstreak = GetPlayerHighestKillStreak(playerid);

	new info[128];
	format(info, sizeof info, "{FFFFFF}Highest Killstreak: {00FF00}%d", killstreak);

	new title[] = "My High Scores";
	new button[] = "Close";

	Dialog_Show(playerid, MyHighScores, t_DIALOG_STYLE:DIALOG_STYLE_MSGBOX, title, info, button, "");
	return 1;
}

Dialog:MyHighScores(playerid, response, listitem, inputtext[])
{
	return 1;
}