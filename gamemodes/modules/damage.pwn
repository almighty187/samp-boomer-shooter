#include <YSI_Coding\y_hooks>

#define MAX_HEALTH 200.0
#define BODY_PART_LEFT_LEG 7
#define BODY_PART_RIGHT_LEG 8
#define BODY_PART_HEAD 9

new static g_PlayerKillStreak[MAX_PLAYERS];
new static g_PlayerHighestKillStreak[MAX_PLAYERS];
new static g_PlayerKills[MAX_PLAYERS];
new static g_PlayerDeaths[MAX_PLAYERS];

CheckKillStreak(playerid)
{
	new streak = g_PlayerKillStreak[playerid];
	new playerName[MAX_PLAYER_NAME], message[128];
	GetPlayerName(playerid, playerName, sizeof playerName);

	switch(streak)
	{
		case 3:
		{
			format(message, sizeof message, "%s is on a Killing Spree! (%d kills)", playerName, streak);
			SendClientMessageToAll(0xFFFF00FF, message);
		}
		case 5:
		{
			format(message, sizeof message, "%s is on a Rampage! (%d kills)", playerName, streak);
			SendClientMessageToAll(0xFFAA00FF, message);
		}
		case 7:
		{
			format(message, sizeof message, "%s is Dominating! (%d kills)", playerName, streak);
			SendClientMessageToAll(0xFF8800FF, message);
		}
		case 10:
		{
			format(message, sizeof message, "%s is Unstoppable! (%d kills)", playerName, streak);
			SendClientMessageToAll(0xFF5500FF, message);
		}
		case 15:
		{
			format(message, sizeof message, "%s is GODLIKE! (%d kills)", playerName, streak);
			SendClientMessageToAll(0xFF0000FF, message);
		}
		case 20:
		{
			format(message, sizeof message, "%s is BEYOND GODLIKE! (%d kills)", playerName, streak);
			SendClientMessageToAll(0xFF0000FF, message);
		}
	}
}

GetPlayerHighestKillStreak(playerid)
{
	return g_PlayerHighestKillStreak[playerid];
}

SetPlayerHighestKillStreak(playerid, streak)
{
	g_PlayerHighestKillStreak[playerid] = streak;
}

GetPlayerKills(playerid)
{
	return g_PlayerKills[playerid];
}

SetPlayerKills(playerid, kills)
{
	g_PlayerKills[playerid] = kills;
}

GetPlayerDeaths(playerid)
{
	return g_PlayerDeaths[playerid];
}

SetPlayerDeaths(playerid, deaths)
{
	g_PlayerDeaths[playerid] = deaths;
}

Float:GetPlayerKDRatio(playerid)
{
	if (g_PlayerDeaths[playerid] == 0)
		return float(g_PlayerKills[playerid]);

	return float(g_PlayerKills[playerid]) / float(g_PlayerDeaths[playerid]);
}

PlayerKilledPlayer(playerid, killer, WEAPON:weaponid)
{
	new deathString[144],
		playerName[MAX_PLAYER_NAME],
		killerName[MAX_PLAYER_NAME],
		weaponName[16];

	GetPlayerName(playerid, playerName, sizeof playerName);
	GetPlayerName(killer, killerName, sizeof killerName);
	WC_GetWeaponName(weaponid, weaponName, sizeof weaponName);

	format(deathString, sizeof deathString, "%s has been killed by %s with a %s", playerName, killerName, weaponName);
	SendClientMessageToAll(0xFF0000FF, deathString);

	g_PlayerKillStreak[playerid] = 0;
	g_PlayerDeaths[playerid]++;

	AddPlayerScore(playerid, -1);

	AddPlayerScore(killer, 1);
	GivePlayerCash(killer, 100);

	g_PlayerKillStreak[killer]++;
	g_PlayerKills[killer]++;

	if (g_PlayerKillStreak[killer] > g_PlayerHighestKillStreak[killer])
	{
		g_PlayerHighestKillStreak[killer] = g_PlayerKillStreak[killer];
	}

	CheckKillStreak(killer);
}

hook OnPlayerConnect(playerid)
{
	SetPlayerHealth(playerid, 150.0);
	g_PlayerKillStreak[playerid] = 0;
	g_PlayerHighestKillStreak[playerid] = 0;
	g_PlayerKills[playerid] = 0;
	g_PlayerDeaths[playerid] = 0;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	if (killerid != INVALID_PLAYER_ID && killerid != playerid)
	{
		PlayerKilledPlayer(playerid, killerid, WEAPON:reason);
	}
	return 1;
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart)
{
	if (bodypart == BODY_PART_HEAD)
	{
		amount = floatmul(amount, 1.5);
	}

	return 1;
}
