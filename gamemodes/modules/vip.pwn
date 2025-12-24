#include <YSI_Coding\y_hooks>

enum E_VIP_LEVEL
{
	VIP_LEVEL_NONE,
	VIP_LEVEL_BRONZE,
	VIP_LEVEL_SILVER,
	VIP_LEVEL_GOLD
}

static E_VIP_LEVEL:VipLevel[MAX_PLAYERS];

bool:IsPlayerVipLevel(playerid, E_VIP_LEVEL:level = VIP_LEVEL_BRONZE)
{
	return (VipLevel[playerid] >= level);
}

E_VIP_LEVEL:GetPlayerVipLevel(playerid)
{
	return VipLevel[playerid];
}

SetPlayerVipLevel(playerid, E_VIP_LEVEL:level)
{
	new E_VIP_LEVEL:oldLevel = VipLevel[playerid];
	VipLevel[playerid] = level;

	if (level > VIP_LEVEL_NONE && oldLevel == VIP_LEVEL_NONE)
	{
		new playerName[MAX_PLAYER_NAME], levelName[32], message[144];
		GetPlayerName(playerid, playerName, sizeof playerName);
		GetVipLevelName(level, levelName);

		format(message, sizeof message, "> %s has logged in with %s VIP status", playerName, levelName);
		SendClientMessageToAll(0xFFD700FF, message);
	}
}

GetVipLevelName(E_VIP_LEVEL:level, destination[], size = sizeof destination)
{
	switch(level)
	{
		case VIP_LEVEL_BRONZE: format(destination, size, "Bronze");
		case VIP_LEVEL_SILVER: format(destination, size, "Silver");
		case VIP_LEVEL_GOLD: format(destination, size, "Gold");
		default: format(destination, size, "None");
	}
}

hook OnPlayerConnect(playerid)
{
	VipLevel[playerid] = VIP_LEVEL_NONE;
}

CMD:setvip(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_SENIOR))
		return SendClientMessage(playerid, COLOR_GREY, "You don't have permission to use this command.");

	new targetid, levelInput;
	if (sscanf(params, "ui", targetid, levelInput))
		return SendClientMessage(playerid, COLOR_GREY, "Usage: /setvip [playerid] [level 0-3]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_GREY, "Invalid player ID.");

	if (levelInput < _:VIP_LEVEL_NONE || levelInput > _:VIP_LEVEL_GOLD)
		return SendClientMessage(playerid, COLOR_GREY, "VIP level must be between 0 and 3.");

	new E_VIP_LEVEL:level = E_VIP_LEVEL:levelInput;
	SetPlayerVipLevel(targetid, level);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], levelName[32], message[144];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);
	GetVipLevelName(level, levelName);

	format(message, sizeof message, "%s has set %s's VIP level to %d (%s)", adminName, targetName, _:level, levelName);
	SendClientMessageToAll(0xFFD700FF, message);

	return 1;
}

CMD:vips(playerid, params[])
{
	new vipCount = 0, vipList[512], tempLine[64];

	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i) && GetPlayerVipLevel(i) > VIP_LEVEL_NONE)
		{
			new playerName[MAX_PLAYER_NAME], levelName[32];
			GetPlayerName(i, playerName, sizeof playerName);
			GetVipLevelName(GetPlayerVipLevel(i), levelName);

			format(tempLine, sizeof tempLine, "%s - %s VIP\n", playerName, levelName);
			strcat(vipList, tempLine);
			vipCount++;
		}
	}

	if (vipCount == 0)
		strcat(vipList, "No VIP players online");

	Dialog_Show(playerid, VipList, t_DIALOG_STYLE:DIALOG_STYLE_MSGBOX, "Online VIP Players", vipList, "Close", "");
	return 1;
}

Dialog:VipList(playerid, response, listitem, inputtext[])
{
	return 1;
}
