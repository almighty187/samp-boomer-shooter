#include <YSI_Coding\y_hooks>

#define MAX_HEALTH 200
#define BODY_PART_LEFT_LEG 7
#define BODY_PART_RIGHT_LEG 8
#define BODY_PART_HEAD 9

new static Float:g_PlayerHealth[MAX_PLAYERS] = {150.0, ...};
new static g_PlayerKillStreak[MAX_PLAYERS];
new static g_PlayerHighestKillStreak[MAX_PLAYERS];
new static Float:g_WeaponDamages[] = 
{
	0.0, // Fist
	0.0, // Brass
	0.0, // Golf
	0.0, // Nite
	0.0, // Knife
	0.0, // Bat
	0.0, // Shovel
	0.0, // Pool
	0.0, // Katana
	0.0, // Chainsaw
	0.0, // Dildo
	0.0, // Dildo
	0.0, // Vibe
	0.0, // Vibe
	0.0, // Flowers
	0.0, // Cane
	0.0, // Grenade
	0.0, // Tear
	0.0, // Molotov
	0.0, // n/a
	0.0, // n/a
	0.0, // n/a
	25.0, // Colt
	25.0, // Silenced
	45.0, // Deagle
	1.0, // Shotgun, different calculation.
	1.0, // Sawnoff, different calculation.
	1.0, // SPAS12, different calculation.
	25.0, // MAC10
	25.0, // MP5
	40.0, // AK47
	35.0, // M4
	25.0, // Tec9
	70.0, // Rifle
	500.0, // Sniper
	0.0, // RPG
	0.0, // HS
	0.0, // Flame
	0.0, // Minigun
	0.0, // Satchel
	0.0, // Detonator
	0.0, // Spray
	0.0, // Fire-Ext
	0.0, // Cam
	0.0, // Goggles
	0.0, // Goggles
	0.0, // Para
};

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

PlayerKilledPlayer(playerid, killer, t_WEAPON:weaponid)
{
	new deathString[144],
		playerName[MAX_PLAYER_NAME],
		killerName[MAX_PLAYER_NAME],
		weaponName[16];

	GetPlayerName(playerid, playerName, sizeof playerName);
	GetPlayerName(killer, killerName, sizeof killerName);
	GetWeaponName(weaponid, weaponName, sizeof weaponName);

	format(deathString, sizeof deathString, "%s has been killed by %s with a %s", playerName, killerName, weaponName);
	SendClientMessageToAll(0xFF0000FF, deathString);

	g_PlayerKillStreak[playerid] = 0;

	AddPlayerScore(playerid, -1);

	AddPlayerScore(killer, 1);
	GivePlayerCash(killer, 100);

	g_PlayerKillStreak[killer]++;

	if (g_PlayerKillStreak[killer] > g_PlayerHighestKillStreak[killer])
	{
		g_PlayerHighestKillStreak[killer] = g_PlayerKillStreak[killer];
	}

	CheckKillStreak(killer);
}

ServerSetHealth(playerid, Float:health)
{
	g_PlayerHealth[playerid] = FloatClamp(health, 0.0, MAX_HEALTH);
	SetPlayerHealth(playerid, health);
}

ServerGiveHealth(playerid, Float:health)
{
	new Float:newHealth = floatadd(g_PlayerHealth[playerid], health);

	g_PlayerHealth[playerid] = FloatClamp(newHealth, 0.0, MAX_HEALTH);
	SetPlayerHealth(playerid, g_PlayerHealth[playerid]);
}

bool:IsBulletWeapon(t_WEAPON:weaponid)
{
	return ((weaponid >= WEAPON_COLT45 && weaponid <= WEAPON_SNIPER) || weaponid == WEAPON_MINIGUN);
}

Float:ServerGetPlayerHealth(playerid)
{
	return g_PlayerHealth[playerid];
}

Float:CalculateShotgunDamage(Float:amount)
{
	return floatadd(amount, 35.0);
}

Float:GetWeaponDamage(t_WEAPON:weaponid, Float:amount)
{
	new Float:calculatedAmount = 0.0;

	if (weaponid < WEAPON_FIST || weaponid > WEAPON_PARACHUTE)
	{
		calculatedAmount = 0.0;
	}
	else if (weaponid >= WEAPON_SHOTGUN && weaponid <= WEAPON_SHOTGSPA)
	{
		calculatedAmount = CalculateShotgunDamage(amount);
	}
	else
	{
		calculatedAmount = g_WeaponDamages[weaponid];
	}

	return calculatedAmount;
}

Float:AdjustDamageByBodypart(Float:amount, bodypart)
{
	new Float:adjustedDamge = amount;

	if(bodypart == BODY_PART_HEAD)
	{
		adjustedDamge = floatmul(amount, 1.5);
	}	
	else if(bodypart == BODY_PART_RIGHT_LEG || bodypart == BODY_PART_LEFT_LEG)
	{	
		adjustedDamge = floatmul(amount, 0.5);
	}

	return adjustedDamge;
}

hook OnPlayerConnect(playerid)
{
	ServerSetHealth(playerid, 150.0);
	g_PlayerKillStreak[playerid] = 0;
	g_PlayerHighestKillStreak[playerid] = 0;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, t_WEAPON:weaponid, bodypart)
{
	new Float:adjustedAmount = GetWeaponDamage(weaponid, amount),
		Float:damagedPlayerHealth = ServerGetPlayerHealth(damagedid),
		Float:currentPlayerHealth = ServerGetPlayerHealth(playerid);

	if (currentPlayerHealth <= 0.0 || damagedPlayerHealth <= 0.0 || !DoesPlayerHaveWeapon(playerid, weaponid))
	{
		return 1;
	}

	if (IsBulletWeapon(weaponid))
	{
		adjustedAmount = AdjustDamageByBodypart(adjustedAmount, bodypart);
	}

	new Float:newDamagedPlayerHealth = floatsub(damagedPlayerHealth, adjustedAmount);
	ServerSetHealth(damagedid, newDamagedPlayerHealth);

	if (newDamagedPlayerHealth <= 0.0)
	{
		PlayerKilledPlayer(damagedid, playerid, weaponid);
	}
	return 1;
}