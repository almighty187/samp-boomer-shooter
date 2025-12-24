#include <YSI_Coding\y_hooks>

enum E_ADMIN_LEVEL
{
	ADMIN_LEVEL_NONE,
	ADMIN_LEVEL_MODERATOR,
	ADMIN_LEVEL_ADMIN,
	ADMIN_LEVEL_SENIOR,
	ADMIN_LEVEL_OWNER
}

static E_ADMIN_LEVEL:AdminLevel[MAX_PLAYERS];

bool:IsPlayerAdminLevel(playerid, E_ADMIN_LEVEL:level = ADMIN_LEVEL_MODERATOR)
{
	return (AdminLevel[playerid] >= level);
}

E_ADMIN_LEVEL:GetPlayerAdminLevel(playerid)
{
	return AdminLevel[playerid];
}

SetPlayerAdminLevel(playerid, E_ADMIN_LEVEL:level)
{
	new E_ADMIN_LEVEL:oldLevel = AdminLevel[playerid];
	AdminLevel[playerid] = level;

	if (level > ADMIN_LEVEL_NONE && oldLevel == ADMIN_LEVEL_NONE)
	{
		new playerName[MAX_PLAYER_NAME], levelName[32], message[144];
		GetPlayerName(playerid, playerName, sizeof playerName);
		GetAdminLevelName(level, levelName);

		format(message, sizeof message, "> %s has logged in as a Level %d Admin (%s)", playerName, _:level, levelName);
		SendMessageToAdmins(0xFFFF00FF, message, ADMIN_LEVEL_MODERATOR);
	}
}

GetAdminLevelName(E_ADMIN_LEVEL:level, destination[], size = sizeof destination)
{
	switch(level)
	{
		case ADMIN_LEVEL_MODERATOR: format(destination, size, "Moderator");
		case ADMIN_LEVEL_ADMIN: format(destination, size, "Administrator");
		case ADMIN_LEVEL_SENIOR: format(destination, size, "Senior Admin");
		case ADMIN_LEVEL_OWNER: format(destination, size, "Owner");
		default: format(destination, size, "None");
	}
}

SendMessageToAdmins(color, const message[], E_ADMIN_LEVEL:minLevel = ADMIN_LEVEL_MODERATOR)
{
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i) && IsPlayerAdminLevel(i, minLevel))
		{
			SendClientMessage(i, color, message);
		}
	}
}

hook OnPlayerConnect(playerid)
{
	AdminLevel[playerid] = ADMIN_LEVEL_NONE;
}

CMD:heal(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_MODERATOR))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /heal [playerid]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	ServerSetHealth(targetid, MAX_HEALTH);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[144];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "Admin %s has healed %s", adminName, targetName);
	SendClientMessageToAll(0xFF6347FF, message);

	return 1;
}

CMD:goto(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_MODERATOR))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /goto [playerid]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	if (targetid == playerid)
		return SendClientMessage(playerid, 0xAFAFAFFF, "You can't teleport to yourself.");

	new Float:x, Float:y, Float:z, interior;
	GetPlayerPos(targetid, x, y, z);
	interior = GetPlayerInterior(targetid);

	SetPlayerPos(playerid, x + 1.0, y + 1.0, z);
	SetPlayerInterior(playerid, interior);

	new targetName[MAX_PLAYER_NAME], message[128];
	GetPlayerName(targetid, targetName, sizeof targetName);
	format(message, sizeof message, "Teleported to %s", targetName);
	SendClientMessage(playerid, 0xFFFFFFFF, message);

	return 1;
}

CMD:gethere(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_MODERATOR))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /gethere [playerid]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	if (targetid == playerid)
		return SendClientMessage(playerid, 0xAFAFAFFF, "You can't teleport yourself to yourself.");

	new Float:x, Float:y, Float:z, interior;
	GetPlayerPos(playerid, x, y, z);
	interior = GetPlayerInterior(playerid);

	SetPlayerPos(targetid, x + 1.0, y + 1.0, z);
	SetPlayerInterior(targetid, interior);

	new targetName[MAX_PLAYER_NAME], message[128];
	GetPlayerName(targetid, targetName, sizeof targetName);
	format(message, sizeof message, "Brought %s to your location", targetName);
	SendClientMessage(playerid, 0xFFFFFFFF, message);

	return 1;
}

CMD:kick(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_ADMIN))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid, reason[64];
	if (sscanf(params, "us[64]", targetid, reason))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /kick [playerid] [reason]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	if (GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You can't kick an admin of equal or higher level.");

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[256];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "%s has been kicked by %s. Reason: %s", targetName, adminName, reason);
	SendClientMessageToAll(0xFF6347FF, message);

	SetTimerEx("DelayedKick", 500, false, "i", targetid);
	return 1;
}

forward DelayedKick(playerid);
public DelayedKick(playerid)
{
	Kick(playerid);
}

CMD:freeze(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_ADMIN))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /freeze [playerid]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	TogglePlayerControllable(targetid, false);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[128];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "Admin %s has frozen %s", adminName, targetName);
	SendClientMessageToAll(0xFF6347FF, message);

	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_ADMIN))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /unfreeze [playerid]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	TogglePlayerControllable(targetid, true);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[128];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "Admin %s has unfrozen %s", adminName, targetName);
	SendClientMessageToAll(0xFF6347FF, message);

	return 1;
}

CMD:slap(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_ADMIN))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid, Float:slapPower = 5.0;
	if (sscanf(params, "uF(5.0)", targetid, slapPower))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /slap [playerid] [power (default 5.0)]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	SetPlayerPos(targetid, x, y, z + slapPower);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[128];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "Admin %s has slapped %s", adminName, targetName);
	SendClientMessageToAll(0xFF6347FF, message);

	return 1;
}

CMD:ban(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_SENIOR))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid, reason[64];
	if (sscanf(params, "us[64]", targetid, reason))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /ban [playerid] [reason]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	if (GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You can't ban an admin of equal or higher level.");

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[256];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "%s has been banned by %s. Reason: %s", targetName, adminName, reason);
	SendClientMessageToAll(0xFF6347FF, message);

	Ban(targetid);
	return 1;
}

CMD:kill(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_SENIOR))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /kill [playerid]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	ServerSetHealth(targetid, 0.0);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[128];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "Admin %s has force-killed %s", adminName, targetName);
	SendClientMessageToAll(0xFF6347FF, message);

	return 1;
}

CMD:gotoco(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_SENIOR))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new Float:pos[3], interior, virtualworld;
	if (sscanf(params, "p<,>fffD(0)D(0)", pos[0], pos[1], pos[2], interior, virtualworld))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /gotoco [x,y,z,interior,virtualworld]");

	SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	SetPlayerInterior(playerid, interior);
	SetPlayerVirtualWorld(playerid, virtualworld);

	new message[128];
	format(message, sizeof message, "Teleported to coordinates: %.2f, %.2f, %.2f (Interior: %d, VW: %d)", pos[0], pos[1], pos[2], interior, virtualworld);
	SendClientMessage(playerid, 0xFFFFFFFF, message);

	return 1;
}

CMD:setadmin(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_OWNER))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	new targetid, levelInput;
	if (sscanf(params, "ui", targetid, levelInput))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /setadmin [playerid] [level 0-4]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Invalid player ID.");

	if (levelInput < _:ADMIN_LEVEL_NONE || levelInput > _:ADMIN_LEVEL_OWNER)
		return SendClientMessage(playerid, 0xAFAFAFFF, "Admin level must be between 0 and 4.");

	new E_ADMIN_LEVEL:level = E_ADMIN_LEVEL:levelInput;
	SetPlayerAdminLevel(targetid, level);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], levelName[32], message[144];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);
	GetAdminLevelName(level, levelName);

	format(message, sizeof message, "%s has set %s's admin level to %d (%s)", adminName, targetName, _:level, levelName);
	SendClientMessageToAll(0xFF6347FF, message);

	return 1;
}

CMD:ahelp(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_MODERATOR))
		return SendClientMessage(playerid, COLOR_GREY, "You don't have permission to use this command.");

	new info[1024];

	strcat(info, "{FFFFFF}=== Moderator (Level 1) ===\n");
	strcat(info, "/heal [playerid] - Heal a player\n");
	strcat(info, "/goto [playerid] - Teleport to a player\n");
	strcat(info, "/gethere [playerid] - Bring a player to you\n");
	strcat(info, "/a [message] - Admin chat\n\n");

	strcat(info, "{FFFFFF}=== Administrator (Level 2) ===\n");
	strcat(info, "/kick [playerid] [reason] - Kick a player\n");
	strcat(info, "/freeze [playerid] - Freeze a player\n");
	strcat(info, "/unfreeze [playerid] - Unfreeze a player\n");
	strcat(info, "/slap [playerid] [power] - Slap a player\n");
	strcat(info, "/setint [playerid] [interior] - Set player interior\n");
	strcat(info, "/setvw [playerid] [virtualworld] - Set player virtual world\n\n");

	strcat(info, "{FFFFFF}=== Senior Admin (Level 3) ===\n");
	strcat(info, "/ban [playerid] [reason] - Ban a player\n");
	strcat(info, "/kill [playerid] - Kill a player\n");
	strcat(info, "/gotoco [x,y,z,interior,vw] - Teleport to coordinates\n\n");

	strcat(info, "{FFFFFF}=== Owner (Level 4) ===\n");
	strcat(info, "/setadmin [playerid] [level] - Set admin level\n\n");

	new title[] = "Admin Commands";
	new button[] = "Close";
	Dialog_Show(playerid, AdminHelp, DIALOG_STYLE_MSGBOX, title, info, button, "");
	return 1;
}

Dialog:AdminHelp(playerid, response, listitem, inputtext[])
{
	return 1;
}

CMD:a(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_MODERATOR))
		return SendClientMessage(playerid, 0xAFAFAFFF, "You don't have permission to use this command.");

	if (isnull(params))
		return SendClientMessage(playerid, 0xAFAFAFFF, "Usage: /a [message]");

	new playerName[MAX_PLAYER_NAME], message[256];
	GetPlayerName(playerid, playerName, sizeof playerName);

	format(message, sizeof message, "[Adm Chat] %s: %s", playerName, params);
	SendMessageToAdmins(0xFF6347FF, message, ADMIN_LEVEL_MODERATOR);

	return 1;
}

CMD:setint(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_ADMIN))
		return SendClientMessage(playerid, COLOR_GREY, "You don't have permission to use this command.");

	new targetid, interior;
	if (sscanf(params, "ui", targetid, interior))
		return SendClientMessage(playerid, COLOR_GREY, "Usage: /setint [playerid] [interior]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_GREY, "Invalid player ID.");

	SetPlayerInterior(targetid, interior);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[144];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "Admin %s set %s's interior to %d", adminName, targetName, interior);
	SendClientMessageToAll(COLOR_LIGHTRED, message);

	return 1;
}

CMD:setvw(playerid, params[])
{
	if (!IsPlayerAdminLevel(playerid, ADMIN_LEVEL_ADMIN))
		return SendClientMessage(playerid, COLOR_GREY, "You don't have permission to use this command.");

	new targetid, virtualworld;
	if (sscanf(params, "ui", targetid, virtualworld))
		return SendClientMessage(playerid, COLOR_GREY, "Usage: /setvw [playerid] [virtualworld]");

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_GREY, "Invalid player ID.");

	SetPlayerVirtualWorld(targetid, virtualworld);

	new adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME], message[144];
	GetPlayerName(playerid, adminName, sizeof adminName);
	GetPlayerName(targetid, targetName, sizeof targetName);

	format(message, sizeof message, "Admin %s set %s's virtual world to %d", adminName, targetName, virtualworld);
	SendClientMessageToAll(COLOR_LIGHTRED, message);

	return 1;
}