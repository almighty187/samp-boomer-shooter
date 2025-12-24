/* Libraries */
#include <open.mp>
#include <Pawn.CMD>
#include <sscanf2>
#include <a_mysql>
#include <samp_bcrypt>
#include <easyDialog>

/* Modules */
#include "modules/utilities.pwn"
#include "modules/anticheat.pwn"
#include "modules/damage.pwn"
#include "modules/spawn.pwn"
#include "modules/player.pwn"
#include "modules/powerups.pwn"
#include "modules/admin.pwn"
#include "modules/database.pwn"

/* Server Versioning */
#define SERVER_VERSION_MAJOR 1
#define SERVER_VERSION_MINOR 2
#define SERVER_VERSION_PATCH 1

SetRandomPassword()
{
	new serverPassword[20];

	CreateRandomString(serverPassword, 10);
	strins(serverPassword, "password ", 0);
	
	SendRconCommand(serverPassword);
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

	// load whatever needs loading dynamically, then unlock the server
	InitializePowerups();

	SendRconCommand("password 0");
	AddPlayerClass(285, 0.0, 0.0, 0.0, 0.0, WEAPON_FIST, 0, WEAPON_FIST, 0, WEAPON_FIST, 0);
}