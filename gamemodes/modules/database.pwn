#include <YSI_Coding\y_hooks>

#define DIALOG_REGISTER 1000
#define DIALOG_LOGIN 1001

static MySQL:g_SQL;

static enum E_PLAYER_DATABASE
{
	E_PLAYER_DB_ID,
	bool:E_PLAYER_LOGGED_IN
}

static PlayerDatabase[MAX_PLAYERS][E_PLAYER_DATABASE];
static PlayerWeapons[MAX_PLAYERS][13][2];
static PlayerInputPassword[MAX_PLAYERS][65];

static g_MySQLHost[64];
static g_MySQLUser[64];
static g_MySQLPass[64];
static g_MySQLDB[64];
static g_MySQLPort;

LoadMySQLConfig()
{
	new File:file = fopen("mysql.ini", io_read);

	if (!file)
	{
		file = fopen("../mysql.ini", io_read);

		if (!file)
		{
			printf("[MySQL] Failed to load mysql.ini, using defaults");
			printf("[MySQL] Host: %s, User: %s, DB: %s, Port: %d", g_MySQLHost, g_MySQLUser, g_MySQLDB, g_MySQLPort);
			return 0;
		}
	}

	new line[128], key[32], value[96];

	while (fread(file, line))
	{
		if (line[0] == '\0' || line[0] == '#' || line[0] == ';')
			continue;

		new pos = strfind(line, "=");
		if (pos == -1)
			continue;

		strmid(key, line, 0, pos);
		strmid(value, line, pos + 1, strlen(line));

		for (new i = 0; i < strlen(key); i++)
		{
			if (key[i] == ' ' || key[i] == '\t')
			{
				strdel(key, i, i + 1);
				i--;
			}
		}

		for (new i = 0; i < strlen(value); i++)
		{
			if (value[i] == ' ' || value[i] == '\t' || value[i] == '\r' || value[i] == '\n')
			{
				strdel(value, i, i + 1);
				i--;
			}
		}

		if (!strcmp(key, "host", true))
			format(g_MySQLHost, sizeof g_MySQLHost, "%s", value);
		else if (!strcmp(key, "user", true))
			format(g_MySQLUser, sizeof g_MySQLUser, "%s", value);
		else if (!strcmp(key, "password", true))
			format(g_MySQLPass, sizeof g_MySQLPass, "%s", value);
		else if (!strcmp(key, "database", true))
			format(g_MySQLDB, sizeof g_MySQLDB, "%s", value);
		else if (!strcmp(key, "port", true))
			g_MySQLPort = strval(value);
	}

	fclose(file);
	printf("[MySQL] Configuration loaded from mysql.ini");
	return 1;
}

ConnectDatabase()
{
	LoadMySQLConfig();

	g_SQL = mysql_connect(g_MySQLHost, g_MySQLUser, g_MySQLPass, g_MySQLDB);

	if (g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
	{
		printf("[MySQL] Connection failed!");
		return 0;
	}

	printf("[MySQL] Connected to database '%s' at %s:%d", g_MySQLDB, g_MySQLHost, g_MySQLPort);
	CreateTables();
	return 1;
}

CreateTables()
{
	mysql_tquery(g_SQL, "CREATE TABLE IF NOT EXISTS `accounts` (\
		`id` INT NOT NULL AUTO_INCREMENT,\
		`username` VARCHAR(24) NOT NULL,\
		`password` VARCHAR(61) NOT NULL,\
		`admin_level` INT DEFAULT 0,\
		`cash` INT DEFAULT 0,\
		`score` INT DEFAULT 0,\
		`highest_killstreak` INT DEFAULT 0,\
		`health` FLOAT DEFAULT 150.0,\
		`pos_x` FLOAT DEFAULT -1401.5,\
		`pos_y` FLOAT DEFAULT 106.5,\
		`pos_z` FLOAT DEFAULT 1032.2,\
		`interior` INT DEFAULT 1,\
		`virtualworld` INT DEFAULT 0,\
		`weapons` VARCHAR(256) DEFAULT '',\
		`last_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\
		PRIMARY KEY (`id`),\
		UNIQUE KEY `username` (`username`)\
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

	printf("[MySQL] Tables created/verified");
}

ResetPlayerDatabaseData(playerid)
{
	PlayerDatabase[playerid][E_PLAYER_DB_ID] = 0;
	PlayerDatabase[playerid][E_PLAYER_LOGGED_IN] = false;
	PlayerInputPassword[playerid][0] = '\0';

	for (new i = 0; i < 13; i++)
	{
		PlayerWeapons[playerid][i][0] = 0;
		PlayerWeapons[playerid][i][1] = 0;
	}
}

bool:IsPlayerLoggedIn(playerid)
{
	return PlayerDatabase[playerid][E_PLAYER_LOGGED_IN];
}

ShowLoginDialog(playerid)
{
	new playerName[MAX_PLAYER_NAME], dialogString[256];
	GetPlayerName(playerid, playerName, sizeof playerName);

	format(dialogString, sizeof dialogString,
		"{FFFFFF}Welcome to {FF0000}QUAKE{FFFFFF}, %s!\n\n\
		This account is {00FF00}registered{FFFFFF}.\n\
		Please enter your password below to login:",
		playerName);

	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Account Login", dialogString, "Login", "Quit");
}

ShowRegisterDialog(playerid)
{
	new playerName[MAX_PLAYER_NAME], dialogString[256];
	GetPlayerName(playerid, playerName, sizeof playerName);

	format(dialogString, sizeof dialogString,
		"{FFFFFF}Welcome to {FF0000}QUAKE{FFFFFF}, %s!\n\n\
		This account is {FF0000}not registered{FFFFFF}.\n\
		Please enter a password below to create your account:",
		playerName);

	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Account Registration", dialogString, "Register", "Quit");
}

forward OnAccountCheck(playerid);
public OnAccountCheck(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof playerName);

	if (cache_num_rows() > 0)
	{
		ShowLoginDialog(playerid);
	}
	else
	{
		ShowRegisterDialog(playerid);
	}

	return 1;
}

forward OnPasswordHashed(playerid);
public OnPasswordHashed(playerid)
{
	new playerName[MAX_PLAYER_NAME], hashedPassword[BCRYPT_HASH_LENGTH], query[256];
	GetPlayerName(playerid, playerName, sizeof playerName);
	bcrypt_get_hash(hashedPassword);

	mysql_format(g_SQL, query, sizeof query,
		"INSERT INTO `accounts` (`username`, `password`) VALUES ('%e', '%e')",
		playerName, hashedPassword);

	mysql_tquery(g_SQL, query, "OnAccountRegistered", "i", playerid);
}

forward OnAccountRegistered(playerid);
public OnAccountRegistered(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	PlayerDatabase[playerid][E_PLAYER_DB_ID] = cache_insert_id();
	PlayerDatabase[playerid][E_PLAYER_LOGGED_IN] = true;

	SendClientMessage(playerid, 0x00FF00FF, "Account successfully registered! You are now logged in.");

	TogglePlayerSpectating(playerid, false);
	SpawnPlayer(playerid);

	return 1;
}

forward OnAccountDataLoaded(playerid);
public OnAccountDataLoaded(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	if (cache_num_rows() == 0)
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
			"Account Login",
			"{FFFFFF}Welcome to {FF0000}QUAKE{FFFFFF}!\n\n\
			{FF0000}Account not found!{FFFFFF}\n\
			Please try again:",
			"Login", "Quit");
		return 1;
	}

	new storedHash[BCRYPT_HASH_LENGTH];
	cache_get_value_name(0, "password", storedHash, sizeof storedHash);

	bcrypt_verify(playerid, "OnPasswordVerified", PlayerInputPassword[playerid], storedHash);
	return 1;
}

forward OnPasswordVerified(playerid, bool:success);
public OnPasswordVerified(playerid, bool:success)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	if (!success)
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
			"Account Login",
			"{FFFFFF}Welcome to {FF0000}QUAKE{FFFFFF}!\n\n\
			{FF0000}Incorrect password!{FFFFFF}\n\
			Please try again:",
			"Login", "Quit");
		return 1;
	}

	new playerName[MAX_PLAYER_NAME], query[256];
	GetPlayerName(playerid, playerName, sizeof playerName);

	mysql_format(g_SQL, query, sizeof query,
		"SELECT * FROM `accounts` WHERE `username` = '%e' LIMIT 1",
		playerName);

	mysql_tquery(g_SQL, query, "OnPlayerDataLoaded", "i", playerid);
	return 1;
}

forward OnPlayerDataLoaded(playerid);
public OnPlayerDataLoaded(playerid)
{
	if (!IsPlayerConnected(playerid))
		return 0;

	cache_get_value_name_int(0, "id", PlayerDatabase[playerid][E_PLAYER_DB_ID]);
	PlayerDatabase[playerid][E_PLAYER_LOGGED_IN] = true;

	new adminLevel, cash, score, highestKillstreak;
	new Float:health, Float:x, Float:y, Float:z;
	new interior, virtualworld;

	cache_get_value_name_int(0, "admin_level", adminLevel);
	cache_get_value_name_int(0, "cash", cash);
	cache_get_value_name_int(0, "score", score);
	cache_get_value_name_int(0, "highest_killstreak", highestKillstreak);
	cache_get_value_name_float(0, "health", health);
	cache_get_value_name_float(0, "pos_x", x);
	cache_get_value_name_float(0, "pos_y", y);
	cache_get_value_name_float(0, "pos_z", z);
	cache_get_value_name_int(0, "interior", interior);
	cache_get_value_name_int(0, "virtualworld", virtualworld);

	new weaponsData[256];
	cache_get_value_name(0, "weapons", weaponsData, sizeof weaponsData);

	if (strlen(weaponsData) > 0)
	{
		new weaponPairs[13][16];
		new pairCount = strexplode(weaponPairs, weaponsData, ",", 13, 16);

		for (new i = 0; i < pairCount && i < 13; i++)
		{
			new weaponInfo[2][8];
			strexplode(weaponInfo, weaponPairs[i], ":", 2, 8);

			PlayerWeapons[playerid][i][0] = strval(weaponInfo[0]);
			PlayerWeapons[playerid][i][1] = strval(weaponInfo[1]);
		}
	}

	SetPlayerAdminLevel(playerid, adminLevel);
	SetPlayerCash(playerid, cash);
	AddPlayerScore(playerid, score);
	SetPlayerHighestKillStreak(playerid, highestKillstreak);

	SendClientMessage(playerid, 0xFFFFFFFF, "Successfully logged in! Welcome back.");

	TogglePlayerSpectating(playerid, false);
	SpawnPlayer(playerid);

	SetPlayerPos(playerid, x, y, z);
	SetPlayerInterior(playerid, interior);
	SetPlayerVirtualWorld(playerid, virtualworld);
	ServerSetHealth(playerid, health);

	for (new i = 0; i < 13; i++)
	{
		if (PlayerWeapons[playerid][i][0] > 0)
		{
			GivePlayerServerWeapon(playerid, t_WEAPON:PlayerWeapons[playerid][i][0], PlayerWeapons[playerid][i][1]);
		}
	}

	return 1;
}

strexplode(dest[][], const source[], const delimiter[] = " ", maxStrings = sizeof dest, maxLength = 32)
{
	new index = 0, lastPos = 0, length = strlen(source);

	for (new i = 0; i < length; i++)
	{
		if (source[i] == delimiter[0])
		{
			if (index >= maxStrings)
				break;

			strmid(dest[index], source, lastPos, i, maxLength);
			lastPos = i + 1;
			index++;
		}
	}

	if (lastPos < length && index < maxStrings)
	{
		strmid(dest[index], source, lastPos, length, maxLength);
		index++;
	}

	return index;
}

SavePlayerAccount(playerid)
{
	if (!IsPlayerLoggedIn(playerid))
		return 0;

	new Float:x, Float:y, Float:z, Float:health;
	GetPlayerPos(playerid, x, y, z);
	health = ServerGetPlayerHealth(playerid);

	new interior = GetPlayerInterior(playerid);
	new virtualworld = GetPlayerVirtualWorld(playerid);

	new weaponsData[256], weaponPair[16];
	for (new i = 0; i < 13; i++)
	{
		new t_WEAPON:weaponid, ammo;
		GetPlayerWeaponData(playerid, t_WEAPON_SLOT:i, weaponid, ammo);

		if (weaponid > WEAPON_FIST && ammo > 0)
		{
			format(weaponPair, sizeof weaponPair, "%d:%d,", _:weaponid, ammo);
			strcat(weaponsData, weaponPair);
		}
	}

	if (strlen(weaponsData) > 0)
		weaponsData[strlen(weaponsData) - 1] = '\0';

	new query[512];
	mysql_format(g_SQL, query, sizeof query,
		"UPDATE `accounts` SET \
		`admin_level` = %d, \
		`cash` = %d, \
		`score` = %d, \
		`highest_killstreak` = %d, \
		`health` = %f, \
		`pos_x` = %f, \
		`pos_y` = %f, \
		`pos_z` = %f, \
		`interior` = %d, \
		`virtualworld` = %d, \
		`weapons` = '%e' \
		WHERE `id` = %d",
		GetPlayerAdminLevel(playerid),
		GetPlayerCash(playerid),
		GetPlayerServerScore(playerid),
		GetPlayerHighestKillStreak(playerid),
		health,
		x, y, z,
		interior,
		virtualworld,
		weaponsData,
		PlayerDatabase[playerid][E_PLAYER_DB_ID]
	);

	mysql_tquery(g_SQL, query);
	return 1;
}

hook OnGameModeInit()
{
	ConnectDatabase();
}

hook OnGameModeExit()
{
	mysql_close(g_SQL);
}

hook OnPlayerConnect(playerid)
{
	ResetPlayerDatabaseData(playerid);

	TogglePlayerSpectating(playerid, true);

	new playerName[MAX_PLAYER_NAME], query[128];
	GetPlayerName(playerid, playerName, sizeof playerName);

	mysql_format(g_SQL, query, sizeof query, "SELECT `id` FROM `accounts` WHERE `username` = '%e' LIMIT 1", playerName);
	mysql_tquery(g_SQL, query, "OnAccountCheck", "i", playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
	SavePlayerAccount(playerid);
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if (dialogid == DIALOG_REGISTER)
	{
		if (!response)
			return Kick(playerid);

		if (strlen(inputtext) < 4 || strlen(inputtext) > 32)
		{
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
				"Account Registration",
				"{FFFFFF}Welcome to {FF0000}QUAKE{FFFFFF}!\n\n\
				{FF0000}Password must be between 4 and 32 characters!{FFFFFF}\n\
				Please enter a password below to create your account:",
				"Register", "Quit");
			return 1;
		}

		format(PlayerInputPassword[playerid], 65, "%s", inputtext);
		bcrypt_hash(playerid, "OnPasswordHashed", inputtext, BCRYPT_COST);
		return 1;
	}

	if (dialogid == DIALOG_LOGIN)
	{
		if (!response)
			return Kick(playerid);

		format(PlayerInputPassword[playerid], 65, "%s", inputtext);

		new playerName[MAX_PLAYER_NAME], query[256];
		GetPlayerName(playerid, playerName, sizeof playerName);

		mysql_format(g_SQL, query, sizeof query,
			"SELECT * FROM `accounts` WHERE `username` = '%e' LIMIT 1",
			playerName);

		mysql_tquery(g_SQL, query, "OnAccountDataLoaded", "i", playerid);
		return 1;
	}

	return 0;
}