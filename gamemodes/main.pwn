/* Libraries */
#include <open.mp>
#include <Pawn.CMD>
#include <sscanf2>
#include <a_mysql>
#include <samp_bcrypt>
#include <easyDialog>
#include <PawnPlus>
#include <eSelection>
#include <streamer>
#include <weapon-config>

/* Modules */
#include "modules/utilities.pwn"
#include "modules/admin.pwn"
#include "modules/vip.pwn"
#include "modules/anticheat.pwn"
#include "modules/damage.pwn"
#include "modules/spawn.pwn"
#include "modules/player.pwn"
#include "modules/powerups.pwn"
#include "modules/database.pwn"

/* Server Versioning */
#define SERVER_VERSION_MAJOR 1
#define SERVER_VERSION_MINOR 3
#define SERVER_VERSION_PATCH 0

SetRandomPassword()
{
	new serverPassword[20];

	CreateRandomString(serverPassword, 10);
	strins(serverPassword, "password ", 0);
	
	SendRconCommand(serverPassword);
}

ConfigureWeaponDamage()
{
	// Melee weapons
	SetWeaponDamage(WEAPON_BRASSKNUCKLE, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_GOLFCLUB, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_NITESTICK, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_KNIFE, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_BAT, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_SHOVEL, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_POOLSTICK, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_KATANA, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_CHAINSAW, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_DILDO, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_DILDO2, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_VIBRATOR, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_VIBRATOR2, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_FLOWER, DAMAGE_TYPE_STATIC, 1.0);
	SetWeaponDamage(WEAPON_CANE, DAMAGE_TYPE_STATIC, 1.0);

	// Pistols
	SetWeaponDamage(WEAPON_COLT45, DAMAGE_TYPE_STATIC, 8.25);
	SetWeaponDamage(WEAPON_SILENCED, DAMAGE_TYPE_STATIC, 13.2);
	SetWeaponDamage(WEAPON_DEAGLE, DAMAGE_TYPE_STATIC, 46.2);

	// Shotguns
	SetWeaponDamage(WEAPON_SHOTGUN, DAMAGE_TYPE_STATIC, 3.3);
	SetWeaponDamage(WEAPON_SAWEDOFF, DAMAGE_TYPE_STATIC, 3.3);
	SetWeaponDamage(WEAPON_SHOTGSPA, DAMAGE_TYPE_STATIC, 3.96);

	// SMGs
	SetWeaponDamage(WEAPON_UZI, DAMAGE_TYPE_STATIC, 6.6);
	SetWeaponDamage(WEAPON_MP5, DAMAGE_TYPE_STATIC, 8.25);
	SetWeaponDamage(WEAPON_TEC9, DAMAGE_TYPE_STATIC, 6.6);

	// Assault Rifles
	SetWeaponDamage(WEAPON_AK47, DAMAGE_TYPE_STATIC, 9.9);
	SetWeaponDamage(WEAPON_M4, DAMAGE_TYPE_STATIC, 9.9);

	// Rifles
	SetWeaponDamage(WEAPON_RIFLE, DAMAGE_TYPE_STATIC, 24.75);
	SetWeaponDamage(WEAPON_SNIPER, DAMAGE_TYPE_STATIC, 41.25);

	// Heavy weapons
	SetWeaponDamage(WEAPON_ROCKETLAUNCHER, DAMAGE_TYPE_STATIC, 82.5);
	SetWeaponDamage(WEAPON_HEATSEEKER, DAMAGE_TYPE_STATIC, 82.5);
	SetWeaponDamage(WEAPON_FLAMETHROWER, DAMAGE_TYPE_STATIC, 6.6);
	SetWeaponDamage(WEAPON_MINIGUN, DAMAGE_TYPE_STATIC, 46.2);

	// Thrown weapons
	SetWeaponDamage(WEAPON_GRENADE, DAMAGE_TYPE_STATIC, 82.5);
	SetWeaponDamage(WEAPON_TEARGAS, DAMAGE_TYPE_STATIC, 0.0);
	SetWeaponDamage(WEAPON_MOLTOV, DAMAGE_TYPE_STATIC, 1.0);

	printf("[Weapon-Config] All weapons configured");
}

public OnGameModeInit()
{
	new year = 1900,
		month = 1,
		day = 1,
		version[16];

	format(version, sizeof version, "QUAKE %02d.%02d.%02d", SERVER_VERSION_MAJOR, SERVER_VERSION_MINOR, SERVER_VERSION_PATCH);
	SetGameModeText(version);

	SetRandomPassword();

	getdate(year, month, day);
	printf("Server starting at %02d/%02d/%d", day, month, year);

	ConfigureWeaponDamage();

	// load whatever needs loading dynamically, then unlock the server
	InitializePowerups();

	SendRconCommand("password 0");
	AddPlayerClass(285, 0.0, 0.0, 0.0, 0.0, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);

	return 1;
}