#include <YSI_Coding\y_hooks>

#define DEFAULT_HEALTH 150.0

#define ARENA_NONE 0
#define ARENA_1 1
#define ARENA_2 2

#define TEAM_NONE 0
#define TEAM_ATTACKERS 1
#define TEAM_DEFENDERS 2

#define SKIN_ATTACKER 170
#define SKIN_DEFENDER 177

static enum E_PLAYER_SPAWN_DATA
{
	E_PLAYER_ARENA,
	E_PLAYER_TEAM
}

static PlayerSpawnData[MAX_PLAYERS][E_PLAYER_SPAWN_DATA];

static Float:g_LobbySpawn[4] = {-2638.2590, 1406.6942, 906.4609, 87.4998};

static Float:g_Arena1_AttackerSpawns[][4] =
{
	{-1425.2196, 81.6086, 1031.1018, 320.5571},
	{-1425.4335, 131.3056, 1030.8605, 225.2384}
};

static Float:g_Arena1_DefenderSpawns[][4] =
{
	{-1375.4576, 131.4744, 1030.8530, 124.5565},
	{-1375.2388, 81.4462, 1030.8574, 43.0889}
};

static Float:g_Arena2_AttackerSpawns[][4] =
{
	{-1131.3463, 1057.6323, 1346.4154, 270.2466}
};

static Float:g_Arena2_DefenderSpawns[][4] =
{
	{-974.4493, 1061.2172, 1345.6754, 89.6251}
};


/*
GiveRandomWeapon(playerid)
{
	new t_WEAPON:randomWeapon = t_WEAPON:RandomRange(WEAPON_COLT45, WEAPON_SNIPER);

	if (randomWeapon == WEAPON_SAWEDOFF || randomWeapon == WEAPON_SHOTGSPA)
	{
		randomWeapon = WEAPON_SHOTGUN;
	}

	GivePlayerServerWeapon(playerid, t_WEAPON:randomWeapon, 9999);
}
*/

SetPlayerSkills(playerid)
{
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 200);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 200);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 200);
}

SpawnPlayerInLobby(playerid)
{
	SetPlayerInterior(playerid, 3);
	SetPlayerPos(playerid, g_LobbySpawn[0], g_LobbySpawn[1], g_LobbySpawn[2]);
	SetPlayerFacingAngle(playerid, g_LobbySpawn[3]);
	SetCameraBehindPlayer(playerid);
}

SetPlayerSpawn(playerid)
{
	new arena = PlayerSpawnData[playerid][E_PLAYER_ARENA];
	new team = PlayerSpawnData[playerid][E_PLAYER_TEAM];

	if (arena == ARENA_NONE)
	{
		SpawnPlayerInLobby(playerid);
		return;
	}

	SetPlayerSkills(playerid);

	if (arena == ARENA_1)
	{
		SetPlayerInterior(playerid, 1);

		if (team == TEAM_ATTACKERS)
		{
			new randomSpawnPoint = random(sizeof g_Arena1_AttackerSpawns);
			SetPlayerPos(playerid, g_Arena1_AttackerSpawns[randomSpawnPoint][0], g_Arena1_AttackerSpawns[randomSpawnPoint][1], g_Arena1_AttackerSpawns[randomSpawnPoint][2]);
			SetPlayerFacingAngle(playerid, g_Arena1_AttackerSpawns[randomSpawnPoint][3]);
		}
		else if (team == TEAM_DEFENDERS)
		{
			new randomSpawnPoint = random(sizeof g_Arena1_DefenderSpawns);
			SetPlayerPos(playerid, g_Arena1_DefenderSpawns[randomSpawnPoint][0], g_Arena1_DefenderSpawns[randomSpawnPoint][1], g_Arena1_DefenderSpawns[randomSpawnPoint][2]);
			SetPlayerFacingAngle(playerid, g_Arena1_DefenderSpawns[randomSpawnPoint][3]);
		}
	}
	else if (arena == ARENA_2)
	{
		SetPlayerInterior(playerid, 10);

		if (team == TEAM_ATTACKERS)
		{
			new randomSpawnPoint = random(sizeof g_Arena2_AttackerSpawns);
			SetPlayerPos(playerid, g_Arena2_AttackerSpawns[randomSpawnPoint][0], g_Arena2_AttackerSpawns[randomSpawnPoint][1], g_Arena2_AttackerSpawns[randomSpawnPoint][2]);
			SetPlayerFacingAngle(playerid, g_Arena2_AttackerSpawns[randomSpawnPoint][3]);
		}
		else if (team == TEAM_DEFENDERS)
		{
			new randomSpawnPoint = random(sizeof g_Arena2_DefenderSpawns);
			SetPlayerPos(playerid, g_Arena2_DefenderSpawns[randomSpawnPoint][0], g_Arena2_DefenderSpawns[randomSpawnPoint][1], g_Arena2_DefenderSpawns[randomSpawnPoint][2]);
			SetPlayerFacingAngle(playerid, g_Arena2_DefenderSpawns[randomSpawnPoint][3]);
		}
	}

	SetCameraBehindPlayer(playerid);
}


hook OnPlayerSpawn(playerid)
{
	new arena = PlayerSpawnData[playerid][E_PLAYER_ARENA];
	new team = PlayerSpawnData[playerid][E_PLAYER_TEAM];

	SetPlayerSpawn(playerid);

	ServerSetHealth(playerid, DEFAULT_HEALTH);
	ResetPlayerWeapons(playerid);
	ResetPlayerServerWeapons(playerid);

	if (arena != ARENA_NONE)
	{
		if (team == TEAM_ATTACKERS)
		{
			SetPlayerSkin(playerid, SKIN_ATTACKER);
			SetPlayerColor(playerid, 0xFF0000FF);
			SetPlayerTeam(playerid, TEAM_ATTACKERS);
		}
		else if (team == TEAM_DEFENDERS)
		{
			SetPlayerSkin(playerid, SKIN_DEFENDER);
			SetPlayerColor(playerid, 0x0000FFFF);
			SetPlayerTeam(playerid, TEAM_DEFENDERS);
		}

		GivePlayerServerWeapon(playerid, WEAPON_DEAGLE, 9999);
	}
	else
	{
		SetPlayerSkin(playerid, 0);
		SetPlayerColor(playerid, 0xFFFFFFFF);
		SetPlayerTeam(playerid, TEAM_NONE);
	}
}

hook OnPlayerDeath(playerid)
{
	SpawnPlayer(playerid);
	return 1;
}

hook OnPlayerConnect(playerid)
{
	PlayerSpawnData[playerid][E_PLAYER_ARENA] = ARENA_NONE;
	PlayerSpawnData[playerid][E_PLAYER_TEAM] = TEAM_NONE;
	SetSpawnInfo(playerid, 1, 285, 0.0, 0.0, 0.0, 0.0, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
	return 1;
}

Dialog:ArenaSelect(playerid, response, listitem, inputtext[])
{
	if (!response)
		return 1;

	if (listitem == 0)
	{
		PlayerSpawnData[playerid][E_PLAYER_ARENA] = ARENA_1;
	}
	else if (listitem == 1)
	{
		PlayerSpawnData[playerid][E_PLAYER_ARENA] = ARENA_2;
	}

	new title[] = "Select Team";
	new info[] = "{FF0000}Attackers\n{0000FF}Defenders";
	new button1[] = "Select";
	new button2[] = "Back";

	Dialog_Show(playerid, TeamSelect, DIALOG_STYLE_LIST, title, info, button1, button2);
	return 1;
}

Dialog:TeamSelect(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		PlayerSpawnData[playerid][E_PLAYER_ARENA] = ARENA_NONE;

		new title[] = "Select Arena";
		new info[] = "Arena 1 - Custom Stadium\nArena 2 - RC Battlefield";
		new button1[] = "Select";
		new button2[] = "Cancel";

		Dialog_Show(playerid, ArenaSelect, DIALOG_STYLE_LIST, title, info, button1, button2);
		return 1;
	}

	new message[64];

	if (listitem == 0)
	{
		PlayerSpawnData[playerid][E_PLAYER_TEAM] = TEAM_ATTACKERS;
		format(message, sizeof message, "You have joined the Attackers team.");
	}
	else if (listitem == 1)
	{
		PlayerSpawnData[playerid][E_PLAYER_TEAM] = TEAM_DEFENDERS;
		format(message, sizeof message, "You have joined the Defenders team.");
	}

	SendClientMessage(playerid, COLOR_GREY, message);
	SpawnPlayer(playerid);
	return 1;
}

CMD:arenas(playerid, params[])
{
	new title[] = "Select Arena";
	new info[] = "Arena 1 - Custom Stadium\nArena 2 - RC Battlefield";
	new button1[] = "Select";
	new button2[] = "Cancel";

	Dialog_Show(playerid, ArenaSelect, DIALOG_STYLE_LIST, title, info, button1, button2);
	return 1;
}

CMD:lobby(playerid, params[])
{
	PlayerSpawnData[playerid][E_PLAYER_ARENA] = ARENA_NONE;
	PlayerSpawnData[playerid][E_PLAYER_TEAM] = TEAM_NONE;
	SendClientMessage(playerid, COLOR_GREY, "You have teleported back to the lobby.");
	SpawnPlayer(playerid);
	return 1;
}