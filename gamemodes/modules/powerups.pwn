#define MAX_POWERUPS 9
#define POWERUP_RESPAWN_TIME 10000

static enum E_POWERUP
{
	E_POWERUP_PILLS,
	E_POWERUP_SMALL_HP,
	E_POWERUP_SHOTGUN,
	E_POWERUP_MP5,
	E_POWERUP_AK,
	E_POWERUP_M4
}

static Float:g_PowerupSpawnPoints[MAX_POWERUPS][3] =
{
	{-1401.5225, 106.5447, 1032.2734},
	{-1390.5679, 119.9218, 1033.7361},
	{-1404.3005, 103.9492, 1028.3132},
	{-1412.3938, 119.8759, 1031.6266},
	{-1397.1062, 81.6770, 1031.9216},
	{-1384.6807, 107.6085, 1029.4020},
	{-1401.0372, 91.4395, 1030.5170},
	{-1417.9301, 105.8470, 1030.0526},
	{-1402.5482, 120.5742, 1029.8455}
};

static enum E_POWERUP_DATA
{
	E_POWERUP_PICKUP,
	E_POWERUP:E_POWERUP_TYPE,
	E_POWERUP_RESPAWN_TIMER
}

static g_Powerups[MAX_POWERUPS][E_POWERUP_DATA];

forward RespawnPowerup(powerup);
public RespawnPowerup(powerup)
{
	KillTimer(g_Powerups[powerup][E_POWERUP_RESPAWN_TIMER]);

	new powerupModelId = GetPowerupModelId(g_Powerups[powerup][E_POWERUP_TYPE]);
	g_Powerups[powerup][E_POWERUP_PICKUP] = CreatePickup(powerupModelId, 2, g_PowerupSpawnPoints[powerup][0], g_PowerupSpawnPoints[powerup][1], g_PowerupSpawnPoints[powerup][2]);
}

InitializePowerups()
{
	CreatePowerup(0, E_POWERUP:E_POWERUP_PILLS);
	CreatePowerup(1, E_POWERUP:E_POWERUP_SHOTGUN);
	CreatePowerup(2, E_POWERUP:E_POWERUP_MP5);
	CreatePowerup(3, E_POWERUP:E_POWERUP_AK);
	CreatePowerup(4, E_POWERUP:E_POWERUP_M4);
	CreatePowerup(5, E_POWERUP:E_POWERUP_SMALL_HP);
	CreatePowerup(6, E_POWERUP:E_POWERUP_SMALL_HP);
	CreatePowerup(7, E_POWERUP:E_POWERUP_SMALL_HP);
	CreatePowerup(8, E_POWERUP:E_POWERUP_SMALL_HP);
}

GetPowerupModelId(E_POWERUP:type)
{
	new model = 1241;

	switch(type)
	{
		case E_POWERUP_PILLS:
		{
			model = 1241;
		}
		case E_POWERUP_SMALL_HP:
		{
			model = 1240;
		}
		case E_POWERUP_SHOTGUN:
		{
			model = 349;
		}
		case E_POWERUP_MP5:
		{
			model = 353;
		}
		case E_POWERUP_AK:
		{
			model = 355;
		}
		case E_POWERUP_M4:
		{
			model = 356;
		}
	}

	return model;
}

CreatePowerup(id, E_POWERUP:type)
{
	new powerupModelId = GetPowerupModelId(type);

	g_Powerups[id][E_POWERUP_TYPE] = type;
	g_Powerups[id][E_POWERUP_PICKUP] = CreatePickup(powerupModelId, 2, g_PowerupSpawnPoints[id][0], g_PowerupSpawnPoints[id][1], g_PowerupSpawnPoints[id][2]);
}

OnPickupPowerup(playerid, powerup)
{
	DestroyPickup(g_Powerups[powerup][E_POWERUP_PICKUP]);

	switch (g_Powerups[powerup][E_POWERUP_TYPE])
	{
		case E_POWERUP_PILLS:
		{
			ServerSetHealth(playerid, 200);
		}
		case E_POWERUP_SMALL_HP:
		{
			ServerGiveHealth(playerid, 10);
		}
		case E_POWERUP_SHOTGUN:
		{
			GivePlayerServerWeapon(playerid, WEAPON_SHOTGUN, 9999);
		}
		case E_POWERUP_MP5:
		{
			GivePlayerServerWeapon(playerid, WEAPON_MP5, 9999);
		}
		case E_POWERUP_AK:
		{
			GivePlayerServerWeapon(playerid, WEAPON_AK47, 9999);
		}
		case E_POWERUP_M4:
		{
			GivePlayerServerWeapon(playerid, WEAPON_M4, 9999);
		}
	}

	PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
	g_Powerups[powerup][E_POWERUP_RESPAWN_TIMER] = SetTimerEx("RespawnPowerup", POWERUP_RESPAWN_TIME, false, "i", powerup);
}

hook OnPlayerPickUpPickup(playerid, pickupid)
{
	for (new i = 0; i < sizeof g_Powerups; i++)
	{
		if (pickupid == g_Powerups[i][E_POWERUP_PICKUP])
		{
			OnPickupPowerup(playerid, i);
			break;
		}
	}
}