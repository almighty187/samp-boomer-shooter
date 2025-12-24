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

CMD:myhighscores(playerid, params[])
{
	new score = GetPlayerServerScore(playerid);
	new cash = GetPlayerCash(playerid);
	new killstreak = GetPlayerHighestKillStreak(playerid);

	new info[256];
	format(info, sizeof info, "{FFFFFF}Score: {00FF00}%d\n{FFFFFF}Cash: {00FF00}$%d\n{FFFFFF}Highest Killstreak: {00FF00}%d", score, cash, killstreak);

	new title[] = "My High Scores";
	new button[] = "Close";

	Dialog_Show(playerid, MyHighScores, DIALOG_STYLE_MSGBOX, title, info, button, "");
	return 1;
}

Dialog:MyHighScores(playerid, response, listitem, inputtext[])
{
	return 1;
}