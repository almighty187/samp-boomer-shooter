#include <YSI_Coding\y_hooks>

static t_WEAPON:g_PlayerCurrentWeapon[MAX_PLAYERS] = {WEAPON_FIST, ...};
static t_WEAPON:g_PlayerWeaponInventory[MAX_PLAYERS][13];

bool:DoesPlayerHaveWeapon(playerid, t_WEAPON:weaponid)
{
	new weaponSlot = GetWeaponSlot(weaponid);

	return (g_PlayerWeaponInventory[playerid][weaponSlot] == weaponid);
}


OnPlayerWeaponChange(playerid, t_WEAPON:newWeapon)
{
	if (!DoesPlayerHaveWeapon(playerid, newWeapon))
	{
		new playerName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playerName, sizeof playerName);

		printf("Player [%d] %s has a weapon they shouldn't have.", playerid, playerName);
		return;
	}

	g_PlayerCurrentWeapon[playerid] = newWeapon;
}

GivePlayerServerWeapon(playerid, t_WEAPON:weaponid, ammo)
{
	new weaponSlot = GetWeaponSlot(weaponid);
	g_PlayerWeaponInventory[playerid][weaponSlot] = weaponid;

	GivePlayerWeapon(playerid, weaponid, ammo);
}

hook OnPlayerUpdate(playerid)
{
	new t_WEAPON:currentWeapon = GetPlayerWeapon(playerid);

	if (currentWeapon != g_PlayerCurrentWeapon[playerid])
	{
		OnPlayerWeaponChange(playerid, currentWeapon);
	}

	return 1;
}