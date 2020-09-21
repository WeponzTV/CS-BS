/*
	Script: Counter-Strike: Battleship
	Started: 7th September 2013
	Structure: pawn, foreach, sscanf2, zcmd, sii
	Lines: 2503
	Build: 2
	Credits: Weponz
*/
#include <a_samp> //Credits: SA:MP Team
#undef MAX_PLAYERS
#define MAX_PLAYERS 150
#include <foreach> //Credits: Y_Less
#include <sscanf2> //Credits: Y_Less
#include <zcmd> //Credits: ZeeX
#include <SII> //Credits: [DRuG]Slick

#define WHITE 0xFFFFFFAA
#define RED 0xFF0000FF
#define BLUE 0x0000FFFF
#define GREEN 0x33AA33AA
#define YELLOW 0xFFFF00FF
#define PINK 0xFF80C0FF
#define PURPLE 0x800080AA
#define LIGHTBLUE 0x0080C0FF
#define GREY 0xAFAFAFAA
#define ORANGE 0xFF8000FF

#define USER_FILE "CS-BS/accounts/%s.ini"

#define HOST_NAME "hostname Counter-Strike: Battleship [ENG/RUS]"
#define MODE_NAME "gamemodetext CS/WAR/DOGFIGHT"
#define MAP_NAME "mapname San Fierro Bay"

#define TEAM_COUNTER 0
#define TEAM_TERROR 1

#define PLAYER_LEVEL 0
#define VIP_LEVEL 1
#define ADMIN_LEVEL 2

#define CLASS_SELECTION_X -2476.7156
#define CLASS_SELECTION_Y 1544.5432
#define CLASS_SELECTION_Z 55.4610
#define CLASS_SELECTION_A 87.6057

#define ENGLISH 0
#define RUSSIAN 1

#define STAN_GUN_PICKUP 355
#define VIP_GUN_PICKUP 356
#define JETPACK_PICKUP 370
#define HEALTH_PICKUP 1240
#define ARMOUR_PICKUP 1242
#define ARROW_PICKUP 1318

#define VIP_GUN_ICON 6
#define STAN_GUN_ICON 18
#define SPAWN_ICON 19
#define HEALTH_ICON 21
#define ARMOUR_ICON 30
#define CLUB_ICON 48
#define ELEVATOR_ICON 56
#define JETPACK_ICON 37

#define LANGUAGE_DIALOG 0
#define REGISTER_DIALOG 1
#define LOGIN_DIALOG 2
#define RULES_DIALOG 3
#define CMDS_DIALOG 4
#define ACMDS_DIALOG 5
#define HELP_DIALOG 6
#define STATS_DIALOG 7
#define PASS_DIALOG 8
#define ELEVATOR_DIALOG1 9
#define ELEVATOR_DIALOG2 10

forward TurnOfAntiSpawnKill(playerid);
forward ScanForHackers();

new Text:text_draw[MAX_PLAYERS];

new anti_spawn_kill_timer[MAX_PLAYERS];

new ct_bridge_elevator1, ct_hanger_elevator1, ct_lowerdeck_elevator1, ct_bridge_elevator2, ct_hanger_elevator2, ct_lowerdeck_elevator2;
new club_entrance, club_roof, club_entrance_exit, club_roof_exit;
new jetpack1, jetpack2, jetpack3, jetpack4, jetpack5;
new terror_zone, counter_zone1, counter_zone2;
new ct_stan_guns1, ct_stan_guns2;
new ct_vip_guns1, ct_vip_guns2;
new t_stan_guns1, t_stan_guns2;
new t_vip_guns1, t_vip_guns2;
new health[16], armour[16];
new t_ship_ladder;

new gun_timer;

new GetPlayerClass[MAX_PLAYERS];
new GetPlayerLanguage[MAX_PLAYERS];
new GetPlayerPassFails[MAX_PLAYERS];
new GetPlayerWarnCount[MAX_PLAYERS];
new GetAdminTeamSkin[MAX_PLAYERS];
new GetPlayerStreakCount[MAX_PLAYERS];

new bool:IsPlayerRegistered[MAX_PLAYERS];
new bool:IsPlayerLoggedIn[MAX_PLAYERS];
new bool:IsAdminSpectating[MAX_PLAYERS];
new bool:IsAdminOnDuty[MAX_PLAYERS];
new bool:IsAntiSpawnKillOn[MAX_PLAYERS];

new bool:HasPlayerChangedClass[MAX_PLAYERS];

new BannableWeapons[] =
{
	1,//Brass Knuckles
    2,//Golf Club
    3,//Nightstick
    4,//Knife
    5,//Baseball Bat
    6,//Shovel
    7,//Pool Cue
    8,//Katana
    9,//Chainsaw
    10,//Purple Dildo
    11,//Small White Vibrator
    12,//Large White Vibrator
    13,//Silver Vibrator
    14,//Flowers
    15,//Cane
    17,//Tear Gas
    18,//Molotov Cocktail
    23,//Silenced 9mm
    25,//Shotgun
    26,//Sawnoff Shotgun
    27,//Combat Shotgun
    28,//Micro SMG/Uzi
    32,//Tec-9
	37,//Flamethrower
	38,//Minigun
	39,//Satchel Charge
	40,//Detonator
	41,//Spraycan
	42,//Fire Extinguisher
	43,//Camera
	44,//Nightvision Goggles
	45//Thermal Goggles
};

new Float:Random_Counter_Spawn[][4] =
{
    {-2303.3806, 1714.7681, 11.1563, 89.8459},
    {-2514.1428, 1780.7693, 11.2063, 359.1247}
};

new Float:Random_Terror_Spawn[][4] =
{
    {-2471.7043, 1538.5227, 33.2344, 0.4152},
    {-2366.7686, 1535.8488, 2.1172, 0.4275}
};

enum user_account
{
	user_pass,
	user_level,
	user_score,
    user_kills,
    user_deaths,
    user_streaks,
    user_banned
}
new AccountInfo[MAX_PLAYERS][user_account];

main()
{
	SendRconCommand(HOST_NAME);
	SendRconCommand(MODE_NAME);
	SendRconCommand(MAP_NAME);
}

stock udb_hash(buf[]) //Credits: DracoBlue
{
	new length=strlen(buf);
	new s1 = 1;
	new s2 = 0;
	new n;
	for (n=0; n<length; n++)
	{
		s1 = (s1 + buf[n]) % 65521;
		s2 = (s2 + s1) % 65521;
	}
	return (s2 << 16) + s1;
}

stock SetPlayerClass(playerid, classid)
{
	switch(classid)
	{
		case 0:
		{
		    GetPlayerClass[playerid] = TEAM_COUNTER;
		    GameTextForPlayer(playerid, "~b~Counter Terrorist", 3000, 6);
        }
		case 1:
		{
		    GetPlayerClass[playerid] = TEAM_COUNTER;
		    GameTextForPlayer(playerid, "~b~Counter Terrorist", 3000, 6);
        }
		case 2:
		{
		    GetPlayerClass[playerid] = TEAM_COUNTER;
		    GameTextForPlayer(playerid, "~b~Counter Terrorist", 3000, 6);
        }
		case 3:
		{
		    GetPlayerClass[playerid] = TEAM_COUNTER;
		    GameTextForPlayer(playerid, "~b~Counter Terrorist", 3000, 6);
        }
		case 4:
		{
		    GetPlayerClass[playerid] = TEAM_TERROR;
		    GameTextForPlayer(playerid, "~r~Terrorist", 3000, 6);
        }
		case 5:
		{
		    GetPlayerClass[playerid] = TEAM_TERROR;
		    GameTextForPlayer(playerid, "~r~Terrorist", 3000, 6);
        }
		case 6:
		{
		    GetPlayerClass[playerid] = TEAM_TERROR;
		    GameTextForPlayer(playerid, "~r~Terrorist", 3000, 6);
        }
		case 7:
		{
		    GetPlayerClass[playerid] = TEAM_TERROR;
		    GameTextForPlayer(playerid, "~r~Terrorist", 3000, 6);
        }
	}
	return 1;
}

stock SetPlayerSpawn(playerid)
{
	if(GetPlayerClass[playerid] == TEAM_COUNTER)
	{
		IsAntiSpawnKillOn[playerid] = true;
	    ResetPlayerMoney(playerid);
    	SetPlayerInterior(playerid, 0);
    	SetPlayerHealth(playerid, 9999);
    	SetPlayerArmour(playerid, 100);
    	SetPlayerWantedLevel(playerid, 0);
	    SetPlayerColor(playerid, BLUE);
	    SetPlayerTeam(playerid, TEAM_COUNTER);
	    new position = random(sizeof(Random_Counter_Spawn));
		SetPlayerPos(playerid, Random_Counter_Spawn[position][0], Random_Counter_Spawn[position][1], Random_Counter_Spawn[position][2]);
		SetPlayerFacingAngle(playerid, Random_Counter_Spawn[position][3]);
		GivePlayerStandardGuns(playerid);
		anti_spawn_kill_timer[playerid] = SetTimerEx("TurnOfAntiSpawnKill", 10000, false, "d", playerid);
		if(GetPlayerLanguage[playerid] == ENGLISH)
		{
		    SendClientMessage(playerid, GREEN, "Anti-Spawn Kill: ON [10 secs]");
		}
		else if(GetPlayerLanguage[playerid] == RUSSIAN)
		{
		    SendClientMessage(playerid, GREEN, "Анти-икру убийство: на [10 сек]");
		}
	    return 1;
	}
	else if(GetPlayerClass[playerid] == TEAM_TERROR)
	{
		IsAntiSpawnKillOn[playerid] = true;
	    ResetPlayerMoney(playerid);
    	SetPlayerInterior(playerid, 0);
    	SetPlayerHealth(playerid, 9999);
    	SetPlayerArmour(playerid, 100);
    	SetPlayerWantedLevel(playerid, 0);
	    SetPlayerColor(playerid, RED);
	    SetPlayerTeam(playerid, TEAM_TERROR);
	    new position = random(sizeof(Random_Terror_Spawn));
		SetPlayerPos(playerid, Random_Terror_Spawn[position][0], Random_Terror_Spawn[position][1], Random_Terror_Spawn[position][2]);
		SetPlayerFacingAngle(playerid, Random_Terror_Spawn[position][3]);
    	GivePlayerStandardGuns(playerid);
		anti_spawn_kill_timer[playerid] = SetTimerEx("TurnOfAntiSpawnKill", 10000, false, "d", playerid);
		if(GetPlayerLanguage[playerid] == ENGLISH)
		{
		    SendClientMessage(playerid, GREEN, "Anti-Spawn Kill: ON [10 secs]");
		}
		else if(GetPlayerLanguage[playerid] == RUSSIAN)
		{
		    SendClientMessage(playerid, GREEN, "Анти-икру убийство: на [10 сек]");
		}
	}
	return 1;
}

stock GivePlayerStandardGuns(playerid)
{
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 16, 10); //Grenades
	GivePlayerWeapon(playerid, 22, 250); //9mm
	GivePlayerWeapon(playerid, 29, 500); //MP5
	GivePlayerWeapon(playerid, 30, 500); //AK47
	GivePlayerWeapon(playerid, 33, 500); //Country Rifle
	GivePlayerWeapon(playerid, 35, 10); //RPG
	return 1;
}

stock GivePlayerVIPGuns(playerid)
{
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 16, 30); //Grenades
	GivePlayerWeapon(playerid, 24, 750); //Desert Eagle
	GivePlayerWeapon(playerid, 29, 1500); //MP5
	GivePlayerWeapon(playerid, 31, 1500); //M4
	GivePlayerWeapon(playerid, 34, 1500); //Sniper Rifle
	GivePlayerWeapon(playerid, 36, 30); //Heat Seaking RPG
	return 1;
}

stock GetUserName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

stock ShowRegisterDialog(playerid)
{
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
	    ShowPlayerDialog(playerid, REGISTER_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Account Register", "{FFFFFF}Please enter a password below to register an account:", "Register", "Quit");
	    return 1;
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
	    ShowPlayerDialog(playerid, REGISTER_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}счет Зарегистрироваться", "{FFFFFF}Пожалуйста, введите пароль ниже, чтобы зарегистрировать аккаунт:", "реестр", "выход");
	}
	return 1;
}

stock ShowLoginDialog(playerid)
{
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
	    ShowPlayerDialog(playerid, LOGIN_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Account Login", "{FFFFFF}Please enter your password below to login to your account:", "Login", "Quit");
	    return 1;
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
	    ShowPlayerDialog(playerid, LOGIN_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Вход в Аккаунт", "{FFFFFF}Пожалуйста, введите Ваш пароль для входа в Личный Кабинет:", "Войти", "выход");
	}
	return 1;
}

stock ShowRulesDialog(playerid)
{
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
	    ShowPlayerDialog(playerid, RULES_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}Server Rules", "{FFFFFF}Rule #1: DO NOT hack or cheat on this server. You WILL be automatically banned.\nRule #2: DO NOT camp the spawning locations or team kill. You WILL be kicked.\nRule #3: DO NOT flame, troll, or harass anybody. Respect everyone or you WILL be kicked.\nRule #4: DO NOT flood, spam, or advertise on this server. You WILL be kicked/banned.", "Accept", "Decline");
	    return 1;
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
	    ShowPlayerDialog(playerid, RULES_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}Правила сервера", "{FFFFFF}Правило #1: не взломать или обмануть на этом сервере. Вы будете автоматически запрещен.\nПравило #2: не лагеря местах нереста или убийств товарищей по команде. Вы будете ногами.\nПравило #3: не пламя, Тролль, или беспокоить никого. Все уважают, или вы будете ногами.\nПравило #4: не флудить, спама, или рекламировать на этом сервере. Вы будете ногами/запрещены.", "принимать", "Отклонить");
	}
	return 1;
}

stock GetPlayerFile(playerid)
{
	new file[32];
	format(file, sizeof(file), USER_FILE, GetUserName(playerid));
	return file;
}

stock LoadPlayerAccount(playerid)
{
	if(fexist(GetPlayerFile(playerid)))
	{
		if(INI_Open(GetPlayerFile(playerid)))
		{
		    AccountInfo[playerid][user_pass] = INI_ReadInt("pass");
		    AccountInfo[playerid][user_level] = INI_ReadInt("level");
		    AccountInfo[playerid][user_score] = INI_ReadInt("score");
		    SetPlayerScore(playerid, AccountInfo[playerid][user_score]);
		    AccountInfo[playerid][user_kills] = INI_ReadInt("kills");
		    AccountInfo[playerid][user_deaths] = INI_ReadInt("deaths");
		    AccountInfo[playerid][user_streaks] = INI_ReadInt("streaks");
		    AccountInfo[playerid][user_banned] = INI_ReadInt("banned");
		    INI_Close();
    	}
    }
	return 1;
}

stock SavePlayerAccount(playerid)
{
	if(IsPlayerLoggedIn[playerid] == true)
    {
        if(INI_Open(GetPlayerFile(playerid)))
		{
		    new score = GetPlayerScore(playerid);
		    INI_WriteInt("pass", AccountInfo[playerid][user_pass]);
		    INI_WriteInt("level", AccountInfo[playerid][user_level]);
		    INI_WriteInt("score", score);
		    INI_WriteInt("kills", AccountInfo[playerid][user_kills]);
		    INI_WriteInt("deaths", AccountInfo[playerid][user_deaths]);
		    INI_WriteInt("streaks", AccountInfo[playerid][user_streaks]);
		    INI_WriteInt("banned", AccountInfo[playerid][user_banned]);
		    INI_Save();
		    INI_Close();
	    }
    }
    return 1;
}

stock RegisterPlayer(playerid, password[])
{
    IsPlayerRegistered[playerid] = true;
    IsPlayerLoggedIn[playerid] = true;

    AccountInfo[playerid][user_pass] = udb_hash(password);
    AccountInfo[playerid][user_level] = PLAYER_LEVEL;
    AccountInfo[playerid][user_score] = 0;
    AccountInfo[playerid][user_kills] = 0;
    AccountInfo[playerid][user_deaths] = 0;
    AccountInfo[playerid][user_streaks] = 0;
    AccountInfo[playerid][user_banned] = 0;
    SavePlayerAccount(playerid);
    if(GetPlayerLanguage[playerid] == ENGLISH)
	{
		SendClientMessage(playerid, YELLOW, "Server: You have successfully registered an account.");
		SendClientMessage(playerid, WHITE, "Tip: Use /commands for the list of commands or /help for more details.");
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
		SendClientMessage(playerid, RED, "Сервер: Вы успешно зарегистрировали аккаунт.");
		SendClientMessage(playerid, WHITE, "Совет: Используйте /команды для списка команд или /помощь для более подробной информации.");
	}
	ShowRulesDialog(playerid);
    return 1;
}

stock LoginPlayer(playerid)
{
    IsPlayerRegistered[playerid] = true;
    IsPlayerLoggedIn[playerid] = true;
    LoadPlayerAccount(playerid);
    if(GetPlayerLanguage[playerid] == ENGLISH)
	{
		SendClientMessage(playerid, YELLOW, "Server: You have successfully logged into your account.");
		SendClientMessage(playerid, WHITE, "Tip: Use /cmds for the list of commands or /help for more details.");
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
		SendClientMessage(playerid, RED, "Сервер: Вы успешно вошли в свой аккаунт.");
		SendClientMessage(playerid, WHITE, "Совет: Используйте /cmds для списка команд или /help для более подробной информации.");
	}
	ShowRulesDialog(playerid);
    return 1;
}

stock CounterRadio(const string[])
{
	foreach(new id : Player)
	{
		if(GetPlayerState(id) != PLAYER_STATE_NONE)
		{
			if(GetPlayerClass[id] == TEAM_COUNTER)
			{
				SendClientMessage(id, BLUE, string);
			}
		}
	}
	return 1;
}

stock TerrorRadio(const string[])
{
	foreach(new id : Player)
	{
		if(GetPlayerState(id) != PLAYER_STATE_NONE)
		{
			if(GetPlayerClass[id] == TEAM_TERROR)
			{
				SendClientMessage(id, RED, string);
			}
		}
	}
	return 1;
}

stock AdminRadio(const string[])
{
	foreach(new id : Player)
	{
		if(GetPlayerState(id) != PLAYER_STATE_NONE)
		{
			if(AccountInfo[id][user_level] == ADMIN_LEVEL)
			{
				SendClientMessage(id, LIGHTBLUE, string);
			}
		}
	}
	return 1;
}

stock KickPlayer(playerid, const reason[])
{
	foreach(new id : Player)
	{
	    if(GetPlayerLanguage[id] == ENGLISH)
	    {
	        new string[128];
	    	GameTextForPlayer(playerid, "~r~Kicked!", 3000, 6);
	        format(string, sizeof(string), "Admin: %s (%d) has been kicked from the server. Reason: %s", GetUserName(playerid), playerid, reason);
	       	SendClientMessage(id, RED, string);
	    }
	    else if(GetPlayerLanguage[id] == RUSSIAN)
	    {
	        new string[128];
	    	GameTextForPlayer(playerid, "~r~Kicked!", 3000, 6);
	        format(string, sizeof(string), "Админ: %s (%d) нанесен удар с сервера. Причина: %s", GetUserName(playerid), playerid, reason);
	       	SendClientMessage(id, RED, string);
	    }
	}
	Kick(playerid);
	return 1;
}

stock ResetPlayerVariables(playerid)
{
	ResetPlayerMoney(playerid);

    GetPlayerPassFails[playerid] = 0;
	GetPlayerWarnCount[playerid] = 0;
	GetPlayerStreakCount[playerid] = 0;

    IsPlayerRegistered[playerid] = false;
    IsPlayerLoggedIn[playerid] = false;
    IsAdminSpectating[playerid] = false;
    IsAdminOnDuty[playerid] = false;
    IsAntiSpawnKillOn[playerid] = false;
    HasPlayerChangedClass[playerid] = false;

    GetPlayerLanguage[playerid] = ENGLISH;

    AccountInfo[playerid][user_level] = PLAYER_LEVEL;
    AccountInfo[playerid][user_score] = 0;
    AccountInfo[playerid][user_kills] = 0;
    AccountInfo[playerid][user_deaths] = 0;
    AccountInfo[playerid][user_streaks] = 0;
    AccountInfo[playerid][user_banned] = 0;
	return 1;
}

stock ConnectPlayer(playerid)
{
	new string[128];
	format(string, sizeof(string), "Join/вступать: %s (%d)", GetUserName(playerid), playerid);
	SendClientMessageToAll(GREY, string);
	return 1;
}

stock DisconnectPlayer(playerid)
{
	for(new loop; loop < 52; loop++)
	{
	    RemovePlayerMapIcon(playerid, loop);
	}
	new string[128];
	format(string, sizeof(string), "Disconnect/выключать: %s (%d)", GetUserName(playerid), playerid);
	SendClientMessageToAll(GREY, string);
	return 1;
}

stock GetTeamCount(teamid)
{
     new player_count = 0;
     foreach(new id : Player)
     {
           if(GetPlayerState(id) == PLAYER_STATE_NONE) continue;
           if(GetPlayerClass[id] != teamid) continue;
           player_count++;
     }
     return player_count;
}

stock AutoBanPlayer(playerid, reason[])
{
	new string[128], string2[128];
    foreach(new id : Player)
	{
	    if(GetPlayerLanguage[id] == ENGLISH)
	    {
	        format(string2, sizeof(string2), "Server: %s (%d) has been auto banned from the server. Reason: %s", GetUserName(playerid), playerid, reason);
	       	SendClientMessage(id, RED, string2);
	    }
	    else if(GetPlayerLanguage[id] == RUSSIAN)
	    {
	        format(string2, sizeof(string2), "Сервер: %s (%d) была запрещена авто с сервера. Причина: %s", GetUserName(playerid), playerid, reason);
	       	SendClientMessage(id, RED, string2);
	    }
	}
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
		GameTextForPlayer(playerid, "~r~Banned!", 3000, 6);
		format(string, sizeof(string), "Server: You have been banned by the server anti-cheat for: %s", reason);
		SendClientMessage(playerid, RED, string);
		SendClientMessage(playerid, RED, "Server: Although it is unlikely you will be unbanned, you may appeal at: csbs-samp.com");
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
		GameTextForPlayer(playerid, "~r~Banned!", 3000, 6);
		format(string, sizeof(string), "Сервер: Вы были запрещены на сервере античит для: %s", reason);
		SendClientMessage(playerid, RED, string);
		SendClientMessage(playerid, RED, "Сервер: Хотя вряд ли вы будете Разбанен, вы можете обжаловать в: csbs-samp.com");
	}
	AccountInfo[playerid][user_banned] = 1;
	SavePlayerAccount(playerid);
	BanEx(playerid, reason);
	return 1;
}

stock CheckIfPlayerBanned(playerid)
{
    LoadPlayerAccount(playerid);
    if(AccountInfo[playerid][user_banned] == 1) return KickPlayer(playerid, "Ban Evade/запрещение избегать");
    return 1;
}

stock CheckIfAccountExists(playerid)
{
	if(!fexist(GetPlayerFile(playerid)))
	{
	    ShowRegisterDialog(playerid);
	    return 1;
	}
	else
	{
	    ShowLoginDialog(playerid);
	}
	return 1;
}

stock IsVehicleEmpty(vehicleid)
{
	foreach(new id : Player)
	{
		if(IsPlayerInVehicle(id, vehicleid)) return 0;
	}
	return 1;
}

stock SendGlobalMessageToAll(fromid, fromlevel, fromteam, message[])
{
	new string[128];
	if(fromlevel == PLAYER_LEVEL)
	{
		foreach(new id : Player)
		{
			if(GetPlayerLanguage[id] == ENGLISH)
			{
			    if(fromteam == TEAM_COUNTER)
			    {
					format(string, sizeof(string), "Player %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, BLUE, string);
				}
				else if(fromteam == TEAM_TERROR)
			    {
					format(string, sizeof(string), "Player %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, RED, string);
				}
			}
			else if(GetPlayerLanguage[id] == RUSSIAN)
			{
				if(fromteam == TEAM_COUNTER)
			    {
					format(string, sizeof(string), "игрок %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, BLUE, string);
				}
				else if(fromteam == TEAM_TERROR)
			    {
					format(string, sizeof(string), "игрок %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, RED, string);
				}
			}
		}
	}
	else if(fromlevel == VIP_LEVEL)
	{
		foreach(new id : Player)
		{
			if(GetPlayerLanguage[id] == ENGLISH)
			{
			    if(fromteam == TEAM_COUNTER)
			    {
					format(string, sizeof(string), "V.I.P %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, BLUE, string);
				}
				else if(fromteam == TEAM_TERROR)
			    {
					format(string, sizeof(string), "V.I.P %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, RED, string);
				}
			}
			else if(GetPlayerLanguage[id] == RUSSIAN)
			{
				if(fromteam == TEAM_COUNTER)
			    {
					format(string, sizeof(string), "очень важное лицо %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, BLUE, string);
				}
				else if(fromteam == TEAM_TERROR)
			    {
					format(string, sizeof(string), "очень важное лицо %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, RED, string);
				}
			}
		}
	}
	else if(fromlevel == ADMIN_LEVEL)
	{
		foreach(new id : Player)
		{
			if(GetPlayerLanguage[id] == ENGLISH)
			{
			    if(fromteam == TEAM_COUNTER)
			    {
					format(string, sizeof(string), "Admin %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, BLUE, string);
				}
				else if(fromteam == TEAM_TERROR)
			    {
					format(string, sizeof(string), "Admin %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, RED, string);
				}
			}
			else if(GetPlayerLanguage[id] == RUSSIAN)
			{
				if(fromteam == TEAM_COUNTER)
			    {
					format(string, sizeof(string), "Админ %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, BLUE, string);
				}
				else if(fromteam == TEAM_TERROR)
			    {
					format(string, sizeof(string), "Админ %s (%d): {FFFFFF}%s", GetUserName(fromid), fromid, message);
					SendClientMessage(id, RED, string);
				}
			}
		}
	}
	return 1;
}

public OnGameModeInit()
{
    //Loading Data
   	AllowInteriorWeapons(0);
   	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetNameTagDrawDistance(40.0);

	//Counter Terrorist Class
	AddPlayerClass(287, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(286, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(285, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(179, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);

	//Terrorist Class
	AddPlayerClass(127, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(125, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(124, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(122, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z, CLASS_SELECTION_A, 0, 0, 0, 0, 0, 0);

	//Objects: 75
	CreateObject(10794,-2411.6999500,1580.3000500,3.5000000,0.0000000,0.0000000,0.0000000); //object(car_ship_04_sfse) (1)
	CreateObject(10795,-2413.9492200,1580.3037100,13.5000000,0.0000000,0.0000000,0.0000000); //object(car_ship_05_sfse) (1)
	CreateObject(5156,-2415.3999000,1580.8000500,12.6000000,0.0000000,0.0000000,0.0000000); //object(dk_cargoshp24d) (1)
	CreateObject(2937,-2437.1999500,1561.6200000,17.0000000,45.0000000,0.0000000,0.0000000); //object(kmb_plank) (1)
	CreateObject(2937,-2438.8994100,1563.2998000,17.4400000,328.9990000,0.0000000,0.0000000); //object(kmb_plank) (2)
	CreateObject(3279,-2511.0000000,1571.5999800,12.8000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (1)
	CreateObject(3279,-2392.8999000,1580.3000500,12.8000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (2)
	CreateObject(3279,-2365.1001000,1580.3000500,12.8000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (3)
	CreateObject(3934,-2333.0449200,1578.5087900,12.5982300,0.0000000,0.0000000,0.0000000); //object(helipad01) (5)
	CreateObject(3934,-2317.6001000,1580.5999800,14.2500000,0.0000000,0.0000000,0.0000000); //object(helipad01) (6)
	CreateObject(3934,-2454.1999500,1552.0999800,28.0000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (7)
	CreateObject(3279,-2455.6999500,1533.5999800,27.9000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (4)
	CreateObject(2937,-2417.3000500,1553.0999800,31.0000000,0.0000000,0.0000000,0.0000000); //object(kmb_plank) (3)
	CreateObject(2937,-2417.3000500,1555.4000200,31.0000000,0.0000000,0.0000000,0.0000000); //object(kmb_plank) (4)
	CreateObject(2937,-2417.3000500,1537.6999500,31.0000000,0.0000000,0.0000000,0.0000000); //object(kmb_plank) (5)
	CreateObject(2937,-2417.3000500,1539.9000200,31.0000000,0.0000000,0.0000000,0.0000000); //object(kmb_plank) (6)
	CreateObject(3934,-2391.3999000,1534.5999800,30.9000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (8)
	CreateObject(3279,-2397.1001000,1553.1999500,30.9000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (5)
	CreateObject(2937,-2392.5000000,1549.4000200,31.0000000,0.0000000,0.0000000,90.0000000); //object(kmb_plank) (8)
	CreateObject(2937,-2390.1999500,1549.4000200,31.0000000,0.0000000,0.0000000,90.0000000); //object(kmb_plank) (9)
	CreateObject(2937,-2385.8999000,1549.4000200,31.0000000,0.0000000,0.0000000,90.0000000); //object(kmb_plank) (10)
	CreateObject(2937,-2388.1001000,1549.4000200,31.0000000,0.0000000,0.0000000,90.0000000); //object(kmb_plank) (11)
	CreateObject(3279,-2349.0000000,1544.8000500,25.0000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (6)
	CreateObject(3934,-2312.6001000,1545.0000000,17.8000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (10)
	CreateObject(2937,-2417.6001000,1530.9000200,31.0000000,0.0000000,0.0000000,0.0000000); //object(kmb_plank) (12)
	CreateObject(2937,-2417.6001000,1533.1999500,31.0000000,0.0000000,0.0000000,0.0000000); //object(kmb_plank) (13)
	CreateObject(10771,-2508.6992200,1816.2998000,4.4000000,0.0000000,0.0000000,270.0000000); //object(carrier_hull_sfse) (1)
	CreateObject(11145,-2508.6933600,1881.0996100,3.4000000,0.0000000,0.0000000,270.0000000); //object(carrier_lowdeck_sfs) (1)
	CreateObject(10771,-2338.5996100,1720.1992200,4.4000000,0.0000000,0.0000000,0.0000000); //object(carrier_hull_sfse) (2)
	CreateObject(10770,-2516.1999500,1813.0999800,37.6000000,0.0000000,0.0000000,270.0000000); //object(carrier_bridge_sfse) (1)
	CreateObject(11146,-2508.1416000,1825.3000500,11.3000000,0.0000000,0.0000000,270.0000000); //object(carrier_hangar_sfs) (1)
	CreateObject(3115,-2508.6992200,1915.5996100,8.8000000,0.0000000,0.0000000,270.0000000); //object(carrier_lift1_sfse) (1)
	CreateObject(3114,-2495.8994100,1873.0000000,8.6000000,0.0000000,0.0000000,270.0000000); //object(carrier_lift2_sfse) (1)
	CreateObject(10772,-2337.1001000,1720.0999800,16.2000000,0.0000000,0.0000000,0.0000000); //object(carrier_lines_sfse) (2)
	CreateObject(10772,-2508.8999000,1814.9000200,16.2000000,0.0000000,0.0000000,269.9950000); //object(carrier_lines_sfse) (3)
	CreateObject(3934,-2486.1999500,1580.0999800,12.7000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (1)
	CreateObject(2944,-2508.6799300,1804.5770300,10.7700000,0.0000000,0.0000000,0.0000000); //object(freight_sfw_door) (1)
	CreateObject(2944,-2510.6499000,1807.1999500,17.7000000,0.0000000,0.0000000,0.0000000); //object(freight_sfw_door) (2)
	CreateObject(2944,-2514.5900900,1847.5300300,2.7300000,0.0000000,0.0000000,90.0000000); //object(freight_sfw_door) (3)
	CreateObject(2944,-2512.5500500,1799.2399900,10.7500000,0.0000000,0.0000000,90.0000000); //object(freight_sfw_door) (4)
	CreateObject(2944,-2520.1001000,1756.3000500,10.7000000,0.0000000,0.0000000,90.0000000); //object(freight_sfw_door) (5)
	CreateObject(3279,-2516.0000000,1843.4000200,19.2000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (7)
	CreateObject(3279,-2518.8999000,1901.6999500,16.2000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (8)
	CreateObject(3279,-2519.3999000,1773.0000000,16.2000000,0.0000000,0.0000000,0.0000000); //object(a51_spottower) (9)
	CreateObject(3934,-2517.1999500,1890.3000500,16.2000000,0.0000000,0.0000000,90.0000000); //object(helipad01) (2)
	CreateObject(3934,-2517.1999500,1874.0999800,16.2000000,0.0000000,0.0000000,90.0000000); //object(helipad01) (4)
	CreateObject(3934,-2517.1999500,1857.5000000,16.2000000,0.0000000,0.0000000,90.0000000); //object(helipad01) (9)
	CreateObject(3934,-2379.3000500,1553.1999500,30.9000000,0.0000000,0.0000000,225.0000000); //object(helipad01) (13)
	CreateObject(11145,-2402.0996100,1720.1992200,3.3000000,0.0000000,0.0000000,0.0000000); //object(carrier_lowdeck_sfs) (2)
	CreateObject(11146,-2347.5800800,1720.7587900,11.2500000,0.0000000,0.0000000,0.0000000); //object(carrier_hangar_sfs) (2)
	CreateObject(3115,-2437.3000500,1720.3000500,8.9000000,0.0000000,0.0000000,0.0000000); //object(carrier_lift1_sfse) (2)
	CreateObject(3114,-2395.3000500,1734.0999800,8.6000000,0.0000000,0.0000000,0.0000000); //object(carrier_lift2_sfse) (2)
	CreateObject(10770,-2335.3764600,1712.8000500,37.6500000,0.0000000,0.0000000,0.0000000); //object(carrier_bridge_sfse) (2)
	CreateObject(2944,-2368.5000000,1715.7199700,2.6600000,0.0000000,0.0000000,0.0000000); //object(freight_sfw_door) (6)
	CreateObject(2944,-2321.3698700,1717.7799100,10.7000000,0.0000000,0.0000000,0.0000000); //object(freight_sfw_door) (7)
	CreateObject(2944,-2278.6001000,1710.1999500,10.6500000,0.0000000,0.0000000,0.0000000); //object(freight_sfw_door) (8)
	CreateObject(2944,-2326.8501000,1720.2204600,10.7000000,0.0000000,0.0000000,90.0000000); //object(freight_sfw_door) (9)
	CreateObject(2944,-2329.5000000,1718.4499500,17.7000000,0.0000000,0.0000000,90.0000000); //object(freight_sfw_door) (10)
	CreateObject(3279,-2423.8999000,1710.0000000,16.2000000,0.0000000,0.0000000,90.0000000); //object(a51_spottower) (10)
	CreateObject(3279,-2365.5000000,1713.1999500,19.2000000,0.0000000,0.0000000,90.0000000); //object(a51_spottower) (11)
	CreateObject(3279,-2295.3999000,1709.6999500,16.2000000,0.0000000,0.0000000,90.0000000); //object(a51_spottower) (12)
	CreateObject(3934,-2412.3000500,1712.3000500,16.2000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (14)
	CreateObject(3934,-2395.3000500,1712.3000500,16.2000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (15)
	CreateObject(3934,-2379.1999500,1712.3000500,16.2000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (16)
	CreateObject(2934,-2438.1999500,1564.6999500,14.2000000,0.0000000,0.0000000,90.0000000); //object(kmb_container_red) (1)
	CreateObject(3800,-2438.1001000,1569.9000200,12.8000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (1)
	CreateObject(3800,-2438.1001000,1570.9000200,12.8000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (2)
	CreateObject(3800,-2439.1999500,1569.9000200,12.8000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (3)
	CreateObject(3800,-2439.1999500,1570.9000200,12.8000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (4)
	CreateObject(3800,-2439.1999500,1565.6999500,15.7000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (5)
	CreateObject(3800,-2438.1999500,1565.6999500,15.7000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (6)
	CreateObject(3800,-2438.1999500,1564.6999500,15.7000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (7)
	CreateObject(3800,-2439.1999500,1564.6999500,15.7000000,0.0000000,0.0000000,0.0000000); //object(acbox4_sfs) (8)
	CreateObject(2935,-2438.1999500,1567.8000500,14.2000000,0.0000000,0.0000000,90.0000000); //object(kmb_container_yel) (1)
	CreateObject(3934,-2426.8000500,1570.8000500,12.8000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (3)

	//All Tower Health/Armour Pickups: 24
	health[0] = CreatePickup(HEALTH_PICKUP, 1, -2457.6016, 1531.7642, 44.9781, 0);
	armour[0] = CreatePickup(ARMOUR_PICKUP, 1, -2454.2688, 1535.1587, 44.9781, 0);
	health[1] = CreatePickup(HEALTH_PICKUP, 1, -2398.6831, 1551.3640, 47.9781, 0);
	armour[1] = CreatePickup(ARMOUR_PICKUP, 1, -2395.5540, 1554.7454, 47.9781, 0);
	health[2] = CreatePickup(HEALTH_PICKUP, 1, -2350.5535, 1542.9728, 42.0781, 0);
	armour[2] = CreatePickup(ARMOUR_PICKUP, 1, -2347.4370, 1546.3248, 42.0781, 0);
	health[3] = CreatePickup(HEALTH_PICKUP, 1, -2366.7583, 1578.5167, 29.8781, 0);
	armour[3] = CreatePickup(ARMOUR_PICKUP, 1, -2363.5149, 1581.8929, 29.8781, 0);
	health[4] = CreatePickup(HEALTH_PICKUP, 1, -2394.6477, 1578.5126, 29.8781, 0);
	armour[4] = CreatePickup(ARMOUR_PICKUP, 1, -2391.2302, 1581.8912, 29.8781, 0);
	health[5] = CreatePickup(HEALTH_PICKUP, 1, -2512.7100, 1569.7821, 29.8781, 0);
	armour[5] = CreatePickup(ARMOUR_PICKUP, 1, -2509.3074, 1573.2391, 29.8781, 0);
	health[6] = CreatePickup(HEALTH_PICKUP, 1, -2293.6338, 1707.9882, 33.2781, 0);
	armour[6] = CreatePickup(ARMOUR_PICKUP, 1, -2296.8789, 1711.2480, 33.2781, 0);
	health[7] = CreatePickup(HEALTH_PICKUP, 1, -2363.7478, 1711.5134, 36.2781, 0);
	armour[7] = CreatePickup(ARMOUR_PICKUP, 1, -2367.1384, 1714.7758, 36.2781, 0);
	health[8] = CreatePickup(HEALTH_PICKUP, 1, -2422.1670, 1708.2833, 33.2781, 0);
	armour[8] = CreatePickup(ARMOUR_PICKUP, 1, -2425.4063, 1711.5789, 33.2781, 0);
	health[9] = CreatePickup(HEALTH_PICKUP, 1, -2521.0081, 1771.2976, 33.2781, 0);
	armour[9] = CreatePickup(ARMOUR_PICKUP, 1, -2517.9026, 1774.5646, 33.2781, 0);
	health[10] = CreatePickup(HEALTH_PICKUP, 1, -2517.5857, 1841.5084, 36.2781, 0);
	armour[10] = CreatePickup(ARMOUR_PICKUP, 1, -2514.4043, 1844.9338, 36.2781, 0);
	health[11] = CreatePickup(HEALTH_PICKUP, 1, -2520.5762, 1899.8770, 33.2781, 0);
	armour[11] = CreatePickup(ARMOUR_PICKUP, 1, -2517.2637, 1903.3325, 33.2781, 0);

	//Counter Terrorist Spawn Health/Armour Pickups: 4
	health[12] = CreatePickup(HEALTH_PICKUP, 1, -2303.1980, 1708.7576, 10.1563, 0); //Spawn 1
	armour[12] = CreatePickup(ARMOUR_PICKUP, 1, -2306.3113, 1708.7615, 10.1563, 0); //Spawn 1
	health[13] = CreatePickup(HEALTH_PICKUP, 1, -2520.1331, 1780.8385, 10.2063, 0); //Spawn 2
	armour[13] = CreatePickup(ARMOUR_PICKUP, 1, -2520.1379, 1784.0819, 10.2063, 0); //Spawn 2

	//Terrorist Spawn Health/Armour Pickups: 4
	health[14] = CreatePickup(HEALTH_PICKUP, 1, -2473.4900, 1544.3777, 33.2344, 0); //Spawn 1
	armour[14] = CreatePickup(ARMOUR_PICKUP, 1, -2475.1479, 1544.3777, 33.2344, 0); //Spawn 1
	health[15] = CreatePickup(HEALTH_PICKUP, 1, -2367.0916, 1554.3638, 2.1231, 0); //Spawn 2
	armour[15] = CreatePickup(ARMOUR_PICKUP, 1, -2368.8770, 1554.3417, 2.1172, 0); //Spawn 2

	//Counter Terrorist Standard/VIP Gun Pickups: 4
	ct_stan_guns1 = CreatePickup(STAN_GUN_PICKUP, 1, -2309.2517, 1708.7705, 10.1563, 0); //Spawn 1
	ct_vip_guns1 = CreatePickup(VIP_GUN_PICKUP, 1, -2312.2581, 1708.7771, 10.1563, 0); //Spawn 1
	ct_stan_guns2 = CreatePickup(STAN_GUN_PICKUP, 1, -2520.1299, 1787.0073, 10.2063, 0); //Spawn 2
	ct_vip_guns2 = CreatePickup(VIP_GUN_PICKUP, 1, -2520.1282, 1789.8271, 10.2063, 0); //Spawn 2

	//Terrorist Standard/VIP Gun Pickups: 4
	t_stan_guns1 = CreatePickup(STAN_GUN_PICKUP, 1, -2472.4333, 1553.3153, 33.2273, 0); //Spawn 1
	t_vip_guns1 = CreatePickup(VIP_GUN_PICKUP, 1, -2474.7649, 1553.3356, 33.2344, 0); //Spawn 1
	t_stan_guns2 = CreatePickup(STAN_GUN_PICKUP, 1, -2370.5952, 1554.3392, 2.1172, 0); //Spawn 2
	t_vip_guns2 = CreatePickup(VIP_GUN_PICKUP, 1, -2372.3828, 1554.3274, 2.1172, 0); //Spawn 2

	//Jetpack Pickups: 5
	jetpack1 = CreatePickup(JETPACK_PICKUP, 1, -2466.7468, 1536.2389, 23.6710, 0);
	jetpack2 = CreatePickup(JETPACK_PICKUP, 1, -2521.8140, 1580.2671, 13.7813, 0);
	jetpack3 = CreatePickup(JETPACK_PICKUP, 1, -2446.7942, 1720.1785, 10.2358, 0);
	jetpack4 = CreatePickup(JETPACK_PICKUP, 1, -2508.7197, 1924.7539, 10.1349, 0);
	jetpack5 = CreatePickup(JETPACK_PICKUP, 1, -2628.2942, 1406.1235, 7.0938, 0);

	//Club Pickups: 4
	club_entrance = CreatePickup(ARROW_PICKUP, 1, -2624.6321, 1412.7372, 7.0938, 0);
	club_roof = CreatePickup(ARROW_PICKUP, 1, -2661.4165, 1423.8345, 23.8984, 0);
	club_entrance_exit = CreatePickup(ARROW_PICKUP, 1, -2636.6787, 1402.4633, 906.4609, 0);
	club_roof_exit = CreatePickup(ARROW_PICKUP, 1, -2660.9561, 1417.3970, 922.1953, 0);

	//Terrorist Ship Ladder Pickup: 1
	t_ship_ladder = CreatePickup(ARROW_PICKUP, 1, -2328.9900, 1528.7606, -0.4317 + 0.5, 0);

	//Counter Terrorist Ship 1 Elevator Pickups: 3
	ct_bridge_elevator1 = CreatePickup(ARROW_PICKUP, 1, -2328.7563, 1718.8253, 17.1891, 0); //Ship 1
	ct_hanger_elevator1 = CreatePickup(ARROW_PICKUP, 1, -2326.1230, 1720.5868, 10.1957, 0); //Ship 1
	ct_lowerdeck_elevator1 = CreatePickup(ARROW_PICKUP, 1, -2368.9766, 1714.9348, 2.0906, 0); //Ship 1

	//Counter Terrorist Ship 2 Elevator Pickups: 3
	ct_bridge_elevator2 = CreatePickup(ARROW_PICKUP, 1, -2510.2771, 1806.4866, 17.1891, 0); //Ship 2
	ct_hanger_elevator2 = CreatePickup(ARROW_PICKUP, 1, -2508.3069, 1803.8606, 10.2428, 0); //Ship 2
	ct_lowerdeck_elevator2 = CreatePickup(ARROW_PICKUP, 1, -2513.9077, 1847.9034, 2.2245, 0); //Ship 2

	//3D Text Labels
	Create3DTextLabel("Standard Weapon Set/Стандартный набор оружия", LIGHTBLUE, -2309.2517, 1708.7705, 10.1563, 10.0, 0, 1); //Counter Terrorist Spawn 1
	Create3DTextLabel("V.I.P Weapon Set/V.I.P набор оружия", LIGHTBLUE, -2312.2581, 1708.7771, 10.1563, 10.0, 0, 1); //Counter Terrorist Spawn 1
	Create3DTextLabel("Standard Weapon Set/Стандартный набор оружия", LIGHTBLUE, -2520.1299, 1787.0073, 10.2063, 10.0, 0, 1); //Counter Terrorist Spawn 2
	Create3DTextLabel("V.I.P Weapon Set/V.I.P набор оружия", LIGHTBLUE, -2520.1282, 1789.8271, 10.2063, 10.0, 0, 1); //Counter Terrorist Spawn 2

	Create3DTextLabel("Standard Weapon Set/Стандартный набор оружия", LIGHTBLUE, -2472.4333, 1553.3153, 33.2273, 10.0, 0, 1); //Terrorist Spawn 1
	Create3DTextLabel("V.I.P Weapon Set/V.I.P набор оружия", LIGHTBLUE, -2474.7649, 1553.3356, 33.2344, 10.0, 0, 1); //Terrorist Spawn 1
	Create3DTextLabel("Standard Weapon Set/Стандартный набор оружия", LIGHTBLUE, -2370.5952, 1554.3392, 2.1172, 10.0, 0, 1); //Terrorist Spawn 2
	Create3DTextLabel("V.I.P Weapon Set/V.I.P набор оружия", LIGHTBLUE, -2372.3828, 1554.3274, 2.1172, 10.0, 0, 1); //Terrorist Spawn 2

	Create3DTextLabel("V.I.P Only!/V.I.P только!", LIGHTBLUE, -2466.7468, 1536.2389, 23.6710, 10.0, 0, 1);
	Create3DTextLabel("V.I.P Only!/V.I.P только!", LIGHTBLUE, -2521.8140, 1580.2671, 13.7813, 10.0, 0, 1);
	Create3DTextLabel("V.I.P Only!/V.I.P только!", LIGHTBLUE, -2446.7942, 1720.1785, 10.2358, 10.0, 0, 1);
	Create3DTextLabel("V.I.P Only!/V.I.P только!", LIGHTBLUE, -2508.7197, 1924.7539, 10.1349, 10.0, 0, 1);
	Create3DTextLabel("V.I.P Only!/V.I.P только!", LIGHTBLUE, -2628.2942, 1406.1235, 7.0938, 10.0, 0, 1);

	Create3DTextLabel("V.I.P Club/V.I.P клуб", LIGHTBLUE, -2624.6321, 1412.7372, 7.0938, 10.0, 0, 1);

	Create3DTextLabel("Ladder/лестница", LIGHTBLUE, -2328.9900, 1528.7606, -0.4317 + 0.5, 10.0, 0, 1);

	Create3DTextLabel("Bridge Elevator/шлюз Лифт", LIGHTBLUE, -2328.7563, 1718.8253, 17.1891, 10.0, 0, 1);
	Create3DTextLabel("Hanger Elevator/кронштейн Лифт", LIGHTBLUE, -2326.1230, 1720.5868, 10.1957, 10.0, 0, 1);
	Create3DTextLabel("Lower Deck Elevator/нижняя палуба Лифт", LIGHTBLUE, -2368.9766, 1714.9348, 2.0906, 10.0, 0, 1);
	Create3DTextLabel("Bridge Elevator/шлюз Лифт", LIGHTBLUE, -2510.2771, 1806.4866, 17.1891, 10.0, 0, 1);
	Create3DTextLabel("Hanger Elevator/кронштейн Лифт", LIGHTBLUE, -2508.3069, 1803.8606, 10.2428, 10.0, 0, 1);
	Create3DTextLabel("Lower Deck Elevator/нижняя палуба Лифт", LIGHTBLUE, -2513.9077, 1847.9034, 2.2245, 10.0, 0, 1);

	terror_zone = GangZoneCreate(-2524.5981, 1527.8569, -2299.5886, 1600.6257); //Terrorist(Red) Zone
	counter_zone1 = GangZoneCreate(-2450.7275, 1704.0090, -2226.5747, 1739.7152); //Counter Terrorist(Blue) Zone
	counter_zone2 = GangZoneCreate(-2524.8782, 1704.1730, -2490.3416, 1928.3651); //Counter Terrorist(Blue) Zone

	//Vehicles: 85 (6 Models)
	AddStaticVehicleEx(520,-2424.8999000,1592.1999500,14.7000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2424.8994100,1581.0000000,14.7000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2439.6001000,1581.0000000,14.7000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2439.6999500,1592.1999500,14.7000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2333.1001000,1574.3000500,14.7000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2333.1001000,1586.5999800,14.7000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(425,-2316.8999000,1580.5000000,16.1000000,90.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(447,-2406.3999000,1586.4000200,15.9000000,90.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(447,-2406.5000000,1574.1999500,15.9000000,90.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(520,-2461.6999500,1570.5000000,14.7000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2472.6999500,1570.5000000,14.7000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2484.1001000,1570.5000000,14.7000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2495.5000000,1570.5000000,14.7000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(447,-2350.8994100,1586.6992200,15.8000000,90.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(447,-2350.8999000,1574.3000500,15.9000000,90.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(520,-2410.2998000,1541.3994100,32.8000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2410.3000500,1556.8000500,32.8000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(425,-2391.5000000,1534.8000500,32.7000000,225.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(520,-2329.6999500,1538.0000000,18.2000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(425,-2311.3999000,1545.0999800,19.6000000,90.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(520,-2329.6999500,1551.8000500,18.2000000,180.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(473,-2425.8000500,1599.3000500,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2429.1001000,1599.3000500,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2432.6001000,1599.4000200,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2435.8999000,1599.5000000,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2422.6001000,1599.3000500,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2325.8999000,1531.9000200,0.0000000,180.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2322.6999500,1531.9000200,0.0000000,180.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2319.3000500,1531.8000500,0.0000000,180.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2316.0000000,1531.8000500,0.0000000,180.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2312.5000000,1531.8000500,0.0000000,180.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(425,-2517.3000500,1889.8000500,18.0000000,0.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(425,-2517.3000500,1873.5999800,18.0000000,0.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(425,-2517.3000500,1857.5000000,18.0000000,0.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(447,-2516.3999000,1832.0999800,23.3000000,270.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(447,-2516.3999000,1783.3000500,20.3000000,270.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(476,-2516.1999500,1749.6999500,18.4000000,270.0000000,215,142,300); //Rustler
	AddStaticVehicleEx(476,-2516.1999500,1737.0999800,18.4000000,270.0000000,215,142,300); //Rustler
	AddStaticVehicleEx(520,-2500.7998000,1766.8000500,11.1000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2514.5000000,1772.6999500,11.1000000,270.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2510.6001000,1752.0999800,11.1000000,315.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2500.7998000,1753.0000000,11.1000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2514.5000000,1762.9000200,11.1000000,270.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2500.7998000,1780.8000500,11.1000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2508.6001000,1913.0999800,11.0000000,180.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(473,-2499.3000500,1897.3000500,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2502.6999500,1897.3000500,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2505.8999000,1897.3000500,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2512.6001000,1901.5999800,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2516.1999500,1901.5999800,0.0000000,0.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(425,-2454.3000500,1552.5999800,29.8000000,180.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(425,-2377.8999000,1554.5000000,32.7000000,135.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(447,-2378.6999500,1586.1999500,15.9000000,90.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(447,-2378.6999500,1574.3000500,15.9000000,90.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(476,-2516.1999500,1762.5000000,18.4000000,270.0000000,215,142,300); //Rustler
	AddStaticVehicleEx(476,-2516.1999500,1724.3000500,18.4000000,270.0000000,215,142,300); //Rustler
	AddStaticVehicleEx(476,-2283.8994100,1713.2998000,18.4000000,0.0000000,19,69,300); //Rustler
	AddStaticVehicleEx(476,-2271.0000000,1713.3000500,18.4000000,0.0000000,19,69,300); //Rustler
	AddStaticVehicleEx(476,-2257.6999500,1713.3000500,18.4000000,0.0000000,19,69,300); //Rustler
	AddStaticVehicleEx(476,-2244.6001000,1713.3000500,18.4000000,0.0000000,19,69,300); //Rustler
	AddStaticVehicleEx(447,-2305.5000000,1712.9000200,20.3000000,0.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(447,-2354.5000000,1712.8000500,23.4000000,0.0000000,32,32,300); //Seasparrow
	AddStaticVehicleEx(425,-2395.8000500,1712.0000000,18.0000000,90.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(425,-2412.1999500,1712.0000000,18.0000000,90.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(425,-2379.6999500,1712.0000000,18.0000000,90.0000000,95,10,300); //Hunter
	AddStaticVehicleEx(520,-2433.6001000,1720.5000000,11.1000000,270.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2295.0000000,1715.4000200,11.1000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2284.8999000,1715.4000200,11.1000000,0.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2274.6001000,1718.0000000,11.1000000,45.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2276.3000500,1728.0000000,11.1000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2290.6001000,1728.0000000,11.1000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(520,-2304.5000000,1728.0000000,11.1000000,90.0000000,-1,-1,300); //Hydra
	AddStaticVehicleEx(473,-2419.0000000,1729.0999800,0.0000000,90.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2419.0000000,1726.0000000,0.0000000,90.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2419.0000000,1722.9000200,0.0000000,90.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2422.6001000,1716.0000000,0.0000000,90.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2422.6001000,1712.8000500,0.0000000,90.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2586.6999500,1428.9000200,0.0000000,270.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2586.6999500,1432.4000200,0.0000000,270.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2586.6999500,1435.9000200,0.0000000,270.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2586.6999500,1439.3000500,0.0000000,270.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(473,-2586.6999500,1442.6999500,0.0000000,270.0000000,158,164,300); //Dinghy
	AddStaticVehicleEx(487,-2637.0000000,1409.8000500,24.2000000,45.0000000,39,47,300); //Maverick
	AddStaticVehicleEx(487,-2643.0000000,1421.8000500,24.2000000,135.0000000,39,47,300); //Maverick
	AddStaticVehicleEx(425,-2426.8999000,1570.1999500,14.6000000,45.0000000,95,10,300); //Hunter

 	for(new id = 0; id < MAX_PLAYERS; id++)
	{
	    text_draw[id] = TextDrawCreate(18.000000, 428.000000, " ");
		TextDrawAlignment(text_draw[id], 0);
		TextDrawBackgroundColor(text_draw[id], 0x000000ff);
		TextDrawFont(text_draw[id], 2);
		TextDrawLetterSize(text_draw[id], 0.199999, 0.899999);
		TextDrawColor(text_draw[id], 0xffffffff);
		TextDrawSetOutline(text_draw[id], 1);
		TextDrawSetProportional(text_draw[id], 1);
		TextDrawSetShadow(text_draw[id], 1);
	}

	SetTimer("ScanForHackers", 1000, true);
	return 1;
}

public OnGameModeExit()
{
	KillTimer(gun_timer);
	foreach(new id : Player)
	{
    	SavePlayerAccount(id);
    	OnPlayerDisconnect(id, 0);
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
	SetPlayerClass(playerid, classid);
    SetPlayerPos(playerid, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z);
    SetPlayerFacingAngle(playerid, CLASS_SELECTION_A);
    SetPlayerCameraLookAt(playerid, CLASS_SELECTION_X, CLASS_SELECTION_Y, CLASS_SELECTION_Z);
    SetPlayerCameraPos(playerid, CLASS_SELECTION_X + (5 * floatsin(-CLASS_SELECTION_A, degrees)), CLASS_SELECTION_Y + (5 * floatcos(-CLASS_SELECTION_A, degrees)), CLASS_SELECTION_Z);
	return 1;
}

public OnPlayerConnect(playerid)
{
    if(strfind(GetUserName(playerid), ".", true) != -1) //Prevents file bugs
    {
        if(GetPlayerLanguage[playerid] == ENGLISH)
        {
            SendClientMessage(playerid, RED, "Server: Please remove the . from your username.");
        }
        else if(GetPlayerLanguage[playerid] == RUSSIAN)
        {
            SendClientMessage(playerid, RED, "Сервер: Убрать . с вашим именем пользователя");
        }
		return KickPlayer(playerid, "Name Rejected/Имя Отклонен");
    }

    CheckIfPlayerBanned(playerid);

	ResetPlayerVariables(playerid);

	TextDrawShowForPlayer(playerid, text_draw[playerid]);
	TextDrawSetString(text_draw[playerid], "Counter-Strike: Battleship - Build: 2");

	SetPlayerColor(playerid, GREY);
	SetPlayerInterior(playerid, 0);

	GangZoneShowForPlayer(playerid, terror_zone, RED);
	GangZoneShowForPlayer(playerid, counter_zone1, BLUE);
	GangZoneShowForPlayer(playerid, counter_zone2, BLUE);

	//Tower Health/Armour Icons: 24
	SetPlayerMapIcon(playerid, 0, -2457.6016, 1531.7642, 44.9781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 1, -2454.2688, 1535.1587, 44.9781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 2, -2398.6831, 1551.3640, 47.9781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 3, -2395.5540, 1554.7454, 47.9781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 4, -2350.5535, 1542.9728, 42.0781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 5, -2347.4370, 1546.3248, 42.0781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 6, -2366.7583, 1578.5167, 29.8781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 7, -2363.5149, 1581.8929, 29.8781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 8, -2394.6477, 1578.5126, 29.8781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 9, -2391.2302, 1581.8912, 29.8781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 10, -2512.7100, 1569.7821, 29.8781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 11, -2509.3074, 1573.2391, 29.8781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 12, -2293.6338, 1707.9882, 33.2781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 13, -2296.8789, 1711.2480, 33.2781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 14, -2363.7478, 1711.5134, 36.2781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 15, -2367.1384, 1714.7758, 36.2781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 16, -2422.1670, 1708.2833, 33.2781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 17, -2425.4063, 1711.5789, 33.2781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 18, -2521.0081, 1771.2976, 33.2781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 19, -2517.9026, 1774.5646, 33.2781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 20, -2517.5857, 1841.5084, 36.2781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 21, -2514.4043, 1844.9338, 36.2781, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 22, -2520.5762, 1899.8770, 33.2781, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 23, -2517.2637, 1903.3325, 33.2781, ARMOUR_ICON, 0, MAPICON_LOCAL);

	//Counter Terrorist Spawn Health/Armour Icons: 4
	SetPlayerMapIcon(playerid, 24, -2303.1980, 1708.7576, 10.1563, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 25, -2306.3113, 1708.7615, 10.1563, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 26, -2520.1331, 1780.8385, 10.2063, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 27, -2520.1379, 1784.0819, 10.2063, ARMOUR_ICON, 0, MAPICON_LOCAL);

	//Terrorist Spawn Health/Armour Icons: 4
	SetPlayerMapIcon(playerid, 28, -2473.4900, 1544.3777, 33.2344, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 29, -2475.1479, 1544.3777, 33.2344, ARMOUR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 30, -2367.0916, 1554.3638, 2.1231, HEALTH_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 31, -2368.8770, 1554.3417, 2.1172, ARMOUR_ICON, 0, MAPICON_LOCAL);

	//Counter Terrorist Standard/VIP Gun Icons: 4
	SetPlayerMapIcon(playerid, 32, -2309.2517, 1708.7705, 10.1563, STAN_GUN_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 33, -2312.2581, 1708.7771, 10.1563, VIP_GUN_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 34, -2520.1299, 1787.0073, 10.2063, STAN_GUN_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 35, -2520.1282, 1789.8271, 10.2063, VIP_GUN_ICON, 0, MAPICON_LOCAL);

	//Terrorist Standard/VIP Gun Icons: 4
	SetPlayerMapIcon(playerid, 36, -2472.4333, 1553.3153, 33.2273, STAN_GUN_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 37, -2474.7649, 1553.3356, 33.2344, VIP_GUN_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 38, -2370.5952, 1554.3392, 2.1172, STAN_GUN_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 39, -2372.3828, 1554.3274, 2.1172, VIP_GUN_ICON, 0, MAPICON_LOCAL);

	//Jetpack Icons: 5
	SetPlayerMapIcon(playerid, 40, -2466.7468, 1536.2389, 23.6710, JETPACK_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 41, -2521.8140, 1580.2671, 13.7813, JETPACK_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 42, -2446.7942, 1720.1785, 10.2358, JETPACK_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 43, -2508.7197, 1924.7539, 10.1349, JETPACK_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 44, -2628.2942, 1406.1235, 7.0938, JETPACK_ICON, 0, MAPICON_LOCAL);

	//Club Icon: 1
	SetPlayerMapIcon(playerid, 45, -2624.6321, 1412.7372, 7.0938, CLUB_ICON, 0, MAPICON_LOCAL);

	//Terrorist Ship Ladder Icon: 1
	SetPlayerMapIcon(playerid, 46, -2328.9900, 1528.7606, -0.4317, ELEVATOR_ICON, 0, MAPICON_LOCAL);

	//Counter Terrorist Ship Elevators Icons: 6
	SetPlayerMapIcon(playerid, 47, -2328.7563, 1718.8253, 17.1891, ELEVATOR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 48, -2326.1230, 1720.5868, 10.1957, ELEVATOR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 49, -2368.9766, 1714.9348, 2.0906, ELEVATOR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 50, -2510.2771, 1806.4866, 17.1891, ELEVATOR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 51, -2508.3069, 1803.8606, 10.2428, ELEVATOR_ICON, 0, MAPICON_LOCAL);
	SetPlayerMapIcon(playerid, 52, -2513.9077, 1847.9034, 2.2245, ELEVATOR_ICON, 0, MAPICON_LOCAL);

    ShowPlayerDialog(playerid, LANGUAGE_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Choose Language/Выберите язык", "{FFFFFF}English\nрусский", ">>", "");

    ConnectPlayer(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    TextDrawHideForPlayer(playerid, text_draw[playerid]);

    KillTimer(anti_spawn_kill_timer[playerid]);

	GangZoneHideForPlayer(playerid, terror_zone);
	GangZoneHideForPlayer(playerid, counter_zone1);
	GangZoneHideForPlayer(playerid, counter_zone2);

    SavePlayerAccount(playerid);
	ResetPlayerVariables(playerid);
    DisconnectPlayer(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerSpawn(playerid);
	if(IsAdminOnDuty[playerid] == true)
	{
        IsAdminOnDuty[playerid] = false;
	}

    new string[128];
    format(string, sizeof(string), "Counter-Strike: Battleship - Build: 2 - Score: %d - Kills: %d - Deaths: %d - Streaks: %d", GetPlayerScore(playerid), AccountInfo[playerid][user_kills], AccountInfo[playerid][user_deaths], AccountInfo[playerid][user_streaks]);
	TextDrawSetString(text_draw[playerid], string);
    SavePlayerAccount(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(gettime() - GetPVarInt(playerid, "GetPlayerLastDeath") < 1)
	{
		return Kick(playerid);
	}
	SetPVarInt(playerid, "GetPlayerLastDeath", gettime());

	if(HasPlayerChangedClass[playerid] == true)
	{
		HasPlayerChangedClass[playerid] = false;
		return ForceClassSelection(playerid);
	}

	GetPlayerStreakCount[playerid] = 0;

	if(killerid == INVALID_PLAYER_ID)
	{
		AccountInfo[playerid][user_deaths] = AccountInfo[playerid][user_deaths] +1;
		SetPlayerScore(playerid, GetPlayerScore(playerid) -1);
		SendDeathMessage(INVALID_PLAYER_ID, playerid, reason);
    	SavePlayerAccount(playerid);
		return 1;
	}
	GetPlayerStreakCount[killerid]++;
	if(GetPlayerClass[killerid] == TEAM_COUNTER && GetPlayerClass[playerid] == TEAM_COUNTER || GetPlayerClass[killerid] == TEAM_TERROR && GetPlayerClass[playerid] == TEAM_TERROR)
	{
	    if(GetPlayerLanguage[killerid] == ENGLISH)
		{
			SendClientMessage(playerid, RED, "Server: DO NOT kill your team members!");
			return 1;
		}
	    else if(GetPlayerLanguage[killerid] == RUSSIAN)
		{
			SendClientMessage(playerid, RED, "Сервер: не убивайте членов вашей команды!");
		}
		return 1;
	}
	AccountInfo[killerid][user_kills] = AccountInfo[killerid][user_kills] +1;
	AccountInfo[killerid][user_score] = AccountInfo[killerid][user_score] +1;
	SetPlayerScore(killerid, GetPlayerScore(killerid) +1);

	AccountInfo[playerid][user_deaths] = AccountInfo[playerid][user_deaths] +1;
 	AccountInfo[playerid][user_score] = AccountInfo[playerid][user_score] -1;
	SetPlayerScore(playerid, GetPlayerScore(playerid) -1);

	SendDeathMessage(killerid, playerid, reason);

	if(GetPlayerStreakCount[killerid] >= 3)
	{
	    new string[128], string2[128];
	    format(string, sizeof(string), "Kill Streak: %s (%d) has made %d kills in a row!", GetUserName(killerid), killerid, GetPlayerStreakCount[killerid]);
	    format(string2, sizeof(string2), "Убийств: %s (%d) составила %d убийств подряд!", GetUserName(killerid), killerid, GetPlayerStreakCount[killerid]);
	    SendClientMessageToAll(ORANGE, string);
	    SendClientMessageToAll(ORANGE, string2);
 		AccountInfo[killerid][user_streaks] = AccountInfo[killerid][user_streaks] +1;
		SetPlayerScore(killerid, GetPlayerScore(killerid) +1);
	}
    new string[128];
    format(string, sizeof(string), "Counter-Strike: Battleship - Build: 2 - Score: %d - Kills: %d - Deaths: %d - Streaks: %d", GetPlayerScore(killerid), AccountInfo[killerid][user_kills], AccountInfo[killerid][user_deaths], AccountInfo[killerid][user_streaks]);
	TextDrawSetString(text_draw[killerid], string);
    SavePlayerAccount(playerid);
	SavePlayerAccount(killerid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	SendGlobalMessageToAll(playerid, AccountInfo[playerid][user_level], GetPlayerClass[playerid], text);
	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
    if(IsPlayerRegistered[playerid] == false)
	{
		ShowRegisterDialog(playerid);
		return 0;
	}
    if(IsPlayerLoggedIn[playerid] == false)
	{
		ShowLoginDialog(playerid);
		return 0;
	}
	new CounterCount = GetTeamCount(TEAM_COUNTER);
 	new TerrorCount = GetTeamCount(TEAM_TERROR);
	if(GetPlayerClass[playerid] == TEAM_COUNTER)
	{
	    if(CounterCount > TerrorCount)
	    {
	        if(GetPlayerLanguage[playerid] == ENGLISH)
			{
				SendClientMessage(playerid, RED, "Error: Team MAXED OUT. Please choose Terrorist class.");
	            return 0;
			}
	        else if(GetPlayerLanguage[playerid] == RUSSIAN)
			{
				SendClientMessage(playerid, RED, "Ошибка: Команда превышен. Пожалуйста, выберите террористических класса.");
	            return 0;
			}
	    }
	}
	else if(GetPlayerClass[playerid] == TEAM_TERROR)
	{
	    if(TerrorCount > CounterCount)
	    {
	        if(GetPlayerLanguage[playerid] == ENGLISH)
			{
				SendClientMessage(playerid, RED, "Error: Team MAXED OUT. Please choose Counter-Terrorist class.");
	            return 0;
			}
	        else if(GetPlayerLanguage[playerid] == RUSSIAN)
			{
				SendClientMessage(playerid, RED, "Ошибка: Команда превышен. Пожалуйста, выберите контртеррористической класса.");
	            return 0;
			}
	    }
	}
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK && AccountInfo[playerid][user_level] == PLAYER_LEVEL)
    {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    }
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	for(new loop; loop < 16; loop++)
	{
	    if(pickupid == health[loop])
	    {
	        if(IsAdminOnDuty[playerid] == true) return 0;
	        SetPlayerHealth(playerid, 100);
	        break;
	    }
	    if(pickupid == armour[loop])
	    {
	        SetPlayerArmour(playerid, 100);
			break;
	    }
	}
	if(pickupid == jetpack1 || pickupid == jetpack2 || pickupid == jetpack3 || pickupid == jetpack4 || pickupid == jetpack5)
	{
	    if(AccountInfo[playerid][user_level] == VIP_LEVEL)
	    {
	        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	    }
	}
	if(pickupid == ct_vip_guns1 || pickupid == ct_vip_guns2 || pickupid == t_vip_guns1 || pickupid == t_vip_guns2)
	{
	    if(AccountInfo[playerid][user_level] == VIP_LEVEL)
	    {
	        GivePlayerVIPGuns(playerid);
	    }
	}
	if(pickupid == ct_stan_guns1 || pickupid == ct_stan_guns2)
	{
	    if(GetPlayerClass[playerid] == TEAM_COUNTER)
	    {
	        GivePlayerStandardGuns(playerid);
	    }
	}
	if(pickupid == t_stan_guns1 || pickupid == t_stan_guns2)
	{
	    if(GetPlayerClass[playerid] == TEAM_TERROR)
	    {
	        GivePlayerStandardGuns(playerid);
	    }
	}
	if(pickupid == club_entrance)
	{
	    if(AccountInfo[playerid][user_level] != PLAYER_LEVEL)
	    {
	        SetPlayerInterior(playerid, 3);
	        SetPlayerPos(playerid, -2636.8870, 1404.2625, 906.4609);
	        SetPlayerFacingAngle(playerid, 1.0194);
	    }
	}
	if(pickupid == club_roof)
	{
	    if(AccountInfo[playerid][user_level] != PLAYER_LEVEL)
	    {
	        SetPlayerInterior(playerid, 3);
	        SetPlayerPos(playerid, -2660.9922, 1414.1644, 922.1953);
	        SetPlayerFacingAngle(playerid, 179.7104);
	    }
	}
	if(pickupid == club_entrance_exit)
	{
	    if(AccountInfo[playerid][user_level] != PLAYER_LEVEL)
	    {
	     	SetPlayerInterior(playerid, 0);
	     	SetPlayerPos(playerid, -2623.9397, 1410.2275, 7.0938);
	     	SetPlayerFacingAngle(playerid, 197.0663);
     	}
	}
	if(pickupid == club_roof_exit)
	{
	    if(AccountInfo[playerid][user_level] != PLAYER_LEVEL)
	    {
		    SetPlayerInterior(playerid, 0);
	     	SetPlayerPos(playerid, -2661.8821, 1425.7184, 23.8984);
	     	SetPlayerFacingAngle(playerid, 12.3628);
     	}
	}
	if(pickupid == t_ship_ladder)
	{
     	SetPlayerPos(playerid, -2325.7664, 1532.6257, 17.3281);
     	SetPlayerFacingAngle(playerid, 359.5244);
	}
 	if(pickupid == ct_bridge_elevator1 || pickupid == ct_hanger_elevator1 || pickupid == ct_lowerdeck_elevator1)
 	{
 	    if(GetPlayerLanguage[playerid] == ENGLISH)
 	    {
 	        ShowPlayerDialog(playerid, ELEVATOR_DIALOG1, DIALOG_STYLE_LIST, "{FFFFFF}Carrier Elevator", "{FFFFFF}Bridge\nHanger\nLower Deck", "Select", "Cancel");
		}
 	    else if(GetPlayerLanguage[playerid] == RUSSIAN)
 	    {
 	        ShowPlayerDialog(playerid, ELEVATOR_DIALOG1, DIALOG_STYLE_LIST, "{FFFFFF}Перевозчик Лифт", "{FFFFFF}шлюз\nкронштейн\nнижняя палуба", "выбирать", "отменить");
		}
	}
 	if(pickupid == ct_bridge_elevator2 || pickupid == ct_hanger_elevator2 || pickupid == ct_lowerdeck_elevator2)
 	{
 	    if(GetPlayerLanguage[playerid] == ENGLISH)
 	    {
 	        ShowPlayerDialog(playerid, ELEVATOR_DIALOG2, DIALOG_STYLE_LIST, "{FFFFFF}Carrier Elevator", "{FFFFFF}Bridge\nHanger\nLower Deck", "Select", "Cancel");
		}
 	    else if(GetPlayerLanguage[playerid] == RUSSIAN)
 	    {
 	        ShowPlayerDialog(playerid, ELEVATOR_DIALOG2, DIALOG_STYLE_LIST, "{FFFFFF}Перевозчик Лифт", "{FFFFFF}шлюз\nкронштейн\nнижняя палуба", "выбирать", "отменить");
 	    }
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == LANGUAGE_DIALOG)
    {
        if(response)
        {
			switch(listitem)
			{
			    case 0: //English
			    {
			        GetPlayerLanguage[playerid] = ENGLISH;
			        CheckIfAccountExists(playerid);
			        return 1;
			    }
			    case 1: //Russian
			    {
			        GetPlayerLanguage[playerid] = RUSSIAN;
			        SendClientMessage(playerid, YELLOW, "Примечание: Этот сервер использует Google Translate."); //Note: This server uses Google Translate.
			        CheckIfAccountExists(playerid);
			        return 1;
			    }
			}
        }
        return 1;
	}
	if(dialogid == REGISTER_DIALOG)
    {
        if(response)
        {
            if(strlen(inputtext) < 3 || strlen(inputtext) > 24)
            {
                if(GetPlayerLanguage[playerid] == ENGLISH)
                {
                	SendClientMessage(playerid, RED, "Error: Your password MUST be between 3-24 characters.");
                }
                else if(GetPlayerLanguage[playerid] == RUSSIAN)
                {
                	SendClientMessage(playerid, RED, "Ошибка: Ваш пароль должен быть в пределах 3-24 символов.");
                }
                ShowRegisterDialog(playerid);
                return 1;
            }
            else if(strlen(inputtext) >= 3 && strlen(inputtext) <= 24)
            {
                RegisterPlayer(playerid, inputtext);
            }
            return 1;
        }
        else if(!response)
        {
            new string[128];
			if(GetPlayerLanguage[playerid] == ENGLISH)
   			{
            	SendClientMessage(playerid, RED, "Error: You MUST register an account before you can spawn.");
      		}
			else if(GetPlayerLanguage[playerid] == RUSSIAN)
			{
				SendClientMessage(playerid, RED, "Ошибка: Вы должны зарегистрироваться счета, перед нерест.");
            }
    		foreach(new id : Player)
			{
				if(GetPlayerLanguage[id] == ENGLISH)
				{
					format(string, sizeof(string), "Server: %s (%d) has been kicked from the server. Reason: Failed to Register", GetUserName(playerid), playerid);
					SendClientMessage(id, RED, string);
				}
				else if(GetPlayerLanguage[id] == RUSSIAN)
				{
					format(string, sizeof(string), "Сервер: %s (%d) нанесен удар с сервера. Причина: не удалось зарегистрировать", GetUserName(playerid), playerid);
					SendClientMessage(id, RED, string);
				}
			}
   			Kick(playerid);
        }
        return 1;
    }
    if(dialogid == LOGIN_DIALOG)
    {
        if(response)
        {
            if(!strlen(inputtext))
            {
	            if(GetPlayerLanguage[playerid] == ENGLISH)
	   			{
	            	SendClientMessage(playerid, RED, "Error: You MUST enter a password.");
	      		}
				else if(GetPlayerLanguage[playerid] == RUSSIAN)
				{
					SendClientMessage(playerid, RED, "Ошибка: Вы должны ввести пароль.");
	            }
	            ShowLoginDialog(playerid);
	            return 1;
            }
            LoadPlayerAccount(playerid);
            if(AccountInfo[playerid][user_pass] == udb_hash(inputtext))
			{
				LoginPlayer(playerid);
            }
            else
            {
                if(GetPlayerPassFails[playerid] < 3)
                {
	                if(GetPlayerLanguage[playerid] == ENGLISH)
		   			{
		            	SendClientMessage(playerid, RED, "Error: Incorrect password.");
		      		}
					else if(GetPlayerLanguage[playerid] == RUSSIAN)
					{
						SendClientMessage(playerid, RED, "Ошибка: неверный пароль.");
		            }
	                ShowLoginDialog(playerid);
	                GetPlayerPassFails[playerid]++;
                }
                else
                {
	                if(GetPlayerLanguage[playerid] == ENGLISH)
		   			{
		            	SendClientMessage(playerid, RED, "Error: Incorrect password x3.");
		      		}
					else if(GetPlayerLanguage[playerid] == RUSSIAN)
					{
						SendClientMessage(playerid, RED, "Ошибка: неверный пароль x3.");
		            }
			        foreach(new id : Player)
					{
					    new string[128];
					    if(GetPlayerLanguage[id] == ENGLISH)
					    {
					        format(string, sizeof(string), "Server: %s (%d) has been kicked from the server. Reason: Incorrect password x3", GetUserName(playerid), playerid);
					       	SendClientMessage(id, RED, string);
					    }
					    else if(GetPlayerLanguage[id] == RUSSIAN)
					    {
					        format(string, sizeof(string), "Сервер: %s (%d) нанесен удар с сервера. Причина: Неверный пароль x3", GetUserName(playerid), playerid);
					       	SendClientMessage(id, RED, string);
					    }
					}
			        Kick(playerid);
                }
            }
            return 1;
        }
        else if(!response)
        {
        	if(GetPlayerLanguage[playerid] == ENGLISH)
  			{
    			SendClientMessage(playerid, RED, "Error: You MUST login before you can spawn.");
	      	}
			else if(GetPlayerLanguage[playerid] == RUSSIAN)
			{
				SendClientMessage(playerid, RED, "Ошибка: Вы должны зарегистрироваться прежде чем вы сможете нерест.");
	        }
	        foreach(new id : Player)
			{
			    new string[128];
			    if(GetPlayerLanguage[id] == ENGLISH)
			    {
			        format(string, sizeof(string), "Server: %s (%d) has been kicked from the server. Reason: Failed to Login", GetUserName(playerid), playerid);
			       	SendClientMessage(id, RED, string);
			    }
			    else if(GetPlayerLanguage[id] == RUSSIAN)
			    {
			        format(string, sizeof(string), "Сервер: %s (%d) нанесен удар с сервера. Причина: не удалось Войти", GetUserName(playerid), playerid);
			       	SendClientMessage(id, RED, string);
			    }
			}
	        Kick(playerid);
        }
        return 1;
    }
    if(dialogid == RULES_DIALOG)
    {
        if(!response)
        {
			if(GetPlayerLanguage[playerid] == ENGLISH)
   			{
                SendClientMessage(playerid, RED, "Error: You MUST accept the server rules.");
            }
            else if(GetPlayerLanguage[playerid] == RUSSIAN)
            {
                SendClientMessage(playerid, RED, "Ошибка: Вы должны принять правила сервера.");
            }
	        foreach(new id : Player)
			{
			    new string[128];
			    if(GetPlayerLanguage[id] == ENGLISH)
			    {
			        format(string, sizeof(string), "Server: %s (%d) has been kicked from the server. Reason: Declined rules", GetUserName(playerid), playerid);
			       	SendClientMessage(id, RED, string);
			    }
			    else if(GetPlayerLanguage[id] == RUSSIAN)
			    {
			        format(string, sizeof(string), "Сервер: %s (%d) нанесен удар с сервера. Причина: Отклонено правил", GetUserName(playerid), playerid);
			       	SendClientMessage(id, RED, string);
			    }
			}
	        Kick(playerid);
		}
        return 1;
	}
    if(dialogid == PASS_DIALOG)
    {
        if(response)
        {
            if(!strlen(inputtext))
            {
	            if(GetPlayerLanguage[playerid] == ENGLISH)
	   			{
	            	SendClientMessage(playerid, RED, "Error: You MUST enter a password.");
	            	return cmd_pass(playerid, "");
	      		}
				else if(GetPlayerLanguage[playerid] == RUSSIAN)
				{
					SendClientMessage(playerid, RED, "Ошибка: Вы должны ввести пароль.");
	            	return cmd_pass(playerid, "");
	            }
	            return 1;
            }
            if(strlen(inputtext) < 3 || strlen(inputtext) > 24)
            {
                if(GetPlayerLanguage[playerid] == ENGLISH)
                {
                	SendClientMessage(playerid, RED, "Error: Your password MUST be between 3-24 characters.");
	            	return cmd_pass(playerid, "");
                }
                else if(GetPlayerLanguage[playerid] == RUSSIAN)
                {
                	SendClientMessage(playerid, RED, "Ошибка: Ваш пароль должен быть в пределах 3-24 символов.");
	            	return cmd_pass(playerid, "");
                }
            }
	        AccountInfo[playerid][user_pass] = udb_hash(inputtext);

	        SavePlayerAccount(playerid);

	        if(GetPlayerLanguage[playerid] == ENGLISH) return SendClientMessage(playerid, YELLOW, "Server: Your password has been changed.");
          	else if(GetPlayerLanguage[playerid] == RUSSIAN) return SendClientMessage(playerid, YELLOW, "Сервер: Ваш пароль был изменен.");
        }
        return 1;
	}
    if(dialogid == ELEVATOR_DIALOG1) //Ship 1
    {
        if(response)
        {
            switch(listitem)
            {
                case 0: //Bridge
                {
                    SetPlayerPos(playerid, -2328.7852, 1720.5139, 17.1891);
                    SetPlayerFacingAngle(playerid, 358.3528);
                    ShowPlayerDialog(playerid, 32768,0, " ", " ", " ", " ");
                    return 1;
                }
                case 1: //Hanger
                {
                    SetPlayerPos(playerid, -2326.2107, 1722.2156, 10.1563);
                    SetPlayerFacingAngle(playerid, 357.4128);
                    ShowPlayerDialog(playerid, 32768,0, " ", " ", " ", " ");
                    return 1;
                }
                case 2: //Lower Deck
                {
                    SetPlayerPos(playerid, -2371.0278, 1714.8348, 2.0812);
                    SetPlayerFacingAngle(playerid, 90.1602);
                    ShowPlayerDialog(playerid, 32768,0, " ", " ", " ", " ");
                    return 1;
                }
			}
        }
		return 1;
	}
    if(dialogid == ELEVATOR_DIALOG2) //Ship 2
    {
        if(response)
        {
            switch(listitem)
            {
                case 0: //Bridge
                {
                    SetPlayerPos(playerid, -2508.2852, 1806.4326, 17.1891);
                    SetPlayerFacingAngle(playerid, 270.8182);
                    ShowPlayerDialog(playerid, 32768,0, " ", " ", " ", " ");
                    return 1;
                }
                case 1: //Hanger
                {
                    SetPlayerPos(playerid, -2506.4263, 1803.8979, 10.2063);
                    SetPlayerFacingAngle(playerid, 269.6310);
                    ShowPlayerDialog(playerid, 32768,0, " ", " ", " ", " ");
                    return 1;
                }
                case 2: //Lower Deck
                {
                    SetPlayerPos(playerid, -2513.8660, 1849.9811, 2.1813);
                    SetPlayerFacingAngle(playerid, 358.3051);
                    ShowPlayerDialog(playerid, 32768,0, " ", " ", " ", " ");
                    return 1;
                }
			}
        }
	}
	return 0;
}

public TurnOfAntiSpawnKill(playerid)
{
	SetPlayerHealth(playerid, 100.00);
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
		SendClientMessage(playerid, RED, "Anti-Spawn Kill: OFF");
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
		SendClientMessage(playerid, RED, "Анти-икру убийство: от");
	}
	IsAntiSpawnKillOn[playerid] = false;
	return 1;
}

public ScanForHackers()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerLoggedIn[i] == true && GetPlayerState(i) == PLAYER_STATE_SPAWNED)
		{
			//Anti-Health Cheat
			new Float:hp;
			GetPlayerHealth(i, hp);
			if(hp > 100.00)
			{
			    if(IsAdminOnDuty[i] == true) continue;
			    if(IsAntiSpawnKillOn[i] == true) continue;
			    AutoBanPlayer(i, "Health Hacks/Здоровье хаки");
			    continue;
			}

			//Anti-Jetpack Cheat
			if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK)
			{
			    if(AccountInfo[i][user_level] == PLAYER_LEVEL)
			    {
				    AutoBanPlayer(i, "Jetpack Hacks/струяпакет хаки");
				    continue;
			    }
			}

			//Anti-Vehicle Health Cheat
			if(IsPlayerInAnyVehicle(i))
			{
				new Float:vhp;
				GetVehicleHealth(GetPlayerVehicleID(i), vhp);
				if(vhp > 1000.00)
				{
				    AutoBanPlayer(i, "Vehicle Health Hacks/Автомобиль Здоровье Хаки");
				    continue;
				}
			}

			//Anti-Weapon Cheat
			if(AccountInfo[i][user_level] != VIP_LEVEL)
			{
			    if(GetPlayerWeapon(i) == 24 || GetPlayerWeapon(i) == 31 || GetPlayerWeapon(i) == 34 || GetPlayerWeapon(i) == 36)
			    {
				    AutoBanPlayer(i, "Weapon Hacks/оружие хаки");
				    continue;
			    }
			}
			for(new w; w < sizeof(BannableWeapons); w++)
			{
				if(GetPlayerWeapon(i) == BannableWeapons[w])
				{
				    AutoBanPlayer(i, "Weapon Hacks/оружие хаки");
				    continue;
				}
			}

			//Anti-Ammo Cheat
			{
			    if(GetPlayerWeapon(i) == 16) //Grenades
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 31)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 22) //9mm
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 251)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 29) //MP5
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 1501)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 30) //AK47
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 501)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 33) //Country Rifle
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 501)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 35) //RPG
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 11)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 24) //Desert Eagle
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 751)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 31) //M4
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 1501)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 34) //Sniper
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 1501)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
				else if(GetPlayerWeapon(i) == 36) //Heat Seaking RPG
			    {
			    	new ammo = GetPlayerAmmo(i);
			    	if(ammo >= 31)
			    	{
			    	    AutoBanPlayer(i, "Ammo Hacks/Боеприпасы хаки");
			    	    continue;
			    	}
				}
			}
			//Anti-Money Cheat
			if(GetPlayerMoney(i) > 0)
			{
				AutoBanPlayer(i, "Money Hacks/деньги хаки");
				continue;
			}
		}
	}
	return 1;
}

CMD:cmds(playerid, params[])
{
	ShowPlayerDialog(playerid, CMDS_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}Server Commands/команды сервера", "{FFFFFF}/cmds /help /rules /stats /r /language /pass /report /changeteam", "Ok/хорошо", "");
	return true;
}

CMD:acmds(playerid, params[])
{
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	ShowPlayerDialog(playerid, ACMDS_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}Admin Commands/Админ Команды", "{FFFFFF}/acmds /a /kick /ban /unban /warn /explode /goto /get /(spec)off /duty /respawn /ann /jet", "Ok/хорошо", "");
	return true;
}

CMD:help(playerid, params[])
{
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
	    if(GetPlayerClass[playerid] == TEAM_COUNTER)
	    {
			ShowPlayerDialog(playerid, HELP_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}Server Help", "{FFFFFF}You're a Counter Terrorist, you need to defend the blue zone and attack the red zone. Your opponents are red color players(admins are purple).\nUse /stats to view player statistics. Use /pass to change your password. Use /report to report a player.\nUse /langauge to change the server language. Use /r to communicate with team members.", "Ok", "");
			return true;
		}
		else if(GetPlayerClass[playerid] == TEAM_TERROR)
	    {
			ShowPlayerDialog(playerid, HELP_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}Server Help", "{FFFFFF}You're a Terrorist, you need to defend the red zone and attack the blue zone. Your opponents are blue color players(admins are purple).\nUse /stats to view player statistics. Use /pass to change your password. Use /report to report a player.\nUse /langauge to change the server language. Use /r to communicate with team members.", "Ok", "");
		}
		return true;
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
		if(GetPlayerClass[playerid] == TEAM_COUNTER)
	    {
			ShowPlayerDialog(playerid, HELP_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}справке по серверу", "{FFFFFF}Ты контртеррористическая, необходимо защитить синюю зону и атаковать красной зоне. Ваши противники красных игроков цветом(админы фиолетовый).\nИспользуйте /stats чтобы посмотреть в статистике игроков. Использовать от /pass до смены пароля. Используйте /report сообщить игроку.\nИспользуйте /language изменить сервер языка. Используйте /r общаться с членами команды.", "хорошо", "");
			return true;
		}
		else if(GetPlayerClass[playerid] == TEAM_TERROR)
	    {
			ShowPlayerDialog(playerid, HELP_DIALOG, DIALOG_STYLE_MSGBOX, "{FFFFFF}справке по серверу", "{FFFFFF}Ты террорист, вы должны защищать красную зону и атаковать синей зоне. Ваши оппоненты синего цвета игроков(админы фиолетовый).\nИспользуйте /stats чтобы посмотреть в статистике игроков. Использовать от /pass до смены пароля. Используйте /report сообщить игроку.\nИспользуйте /language изменить сервер языка. Используйте /r общаться с членами команды.", "хорошо", "");
		}
	}
	return true;
}

CMD:rules(playerid, params[])
{
	ShowRulesDialog(playerid);
	return true;
}

CMD:stats(playerid, params[])
{
	if(IsPlayerLoggedIn[playerid] == false)
	{
		if(GetPlayerClass[playerid] == TEAM_COUNTER)
	    {
			SendClientMessage(playerid, RED, "Error: You MUST be logged in to use this command.");
			return true;
		}
		else if(GetPlayerClass[playerid] == TEAM_TERROR)
	    {
			SendClientMessage(playerid, RED, "Ошибка: Вы должны войти в систему, чтобы использовать эту команду.");
		}
		return true;
	}
	new string[128], string2[128], targetid;
	if(!sscanf(params, "u", targetid))
	{
	    if(GetPlayerLanguage[playerid] == ENGLISH)
	    {
			format(string, sizeof(string), "{FFFFFF}%s's Statistics", GetUserName(targetid));
			format(string2, sizeof(string2), "{FFFFFF}Score: %d\nKills: %d\nDeaths: %d\nStreaks: %d", GetPlayerScore(targetid), AccountInfo[targetid][user_kills], AccountInfo[targetid][user_deaths], AccountInfo[targetid][user_streaks]);
			ShowPlayerDialog(playerid, STATS_DIALOG, DIALOG_STYLE_MSGBOX, string, string2, "Ok", "");
			return true;
		}
		else if(GetPlayerLanguage[playerid] == RUSSIAN)
	    {
			format(string, sizeof(string), "{FFFFFF}%s Статистике", GetUserName(targetid));
			format(string2, sizeof(string2), "{FFFFFF}счет: %d\nУбийства: %d\nСмертей: %d\nполосы: %d", GetPlayerScore(targetid), AccountInfo[targetid][user_kills], AccountInfo[targetid][user_deaths], AccountInfo[targetid][user_streaks]);
			ShowPlayerDialog(playerid, STATS_DIALOG, DIALOG_STYLE_MSGBOX, string, string2, "хорошо", "");
	    }
	    return true;
	}
	else
	{
	    if(GetPlayerLanguage[playerid] == ENGLISH)
	    {
			format(string, sizeof(string), "{FFFFFF}%s's Statistics", GetUserName(playerid));
			format(string2, sizeof(string2), "{FFFFFF}Score: %d\nKills: %d\nDeaths: %d\nStreaks: %d", GetPlayerScore(playerid), AccountInfo[playerid][user_kills], AccountInfo[playerid][user_deaths], AccountInfo[playerid][user_streaks]);
			ShowPlayerDialog(playerid, STATS_DIALOG, DIALOG_STYLE_MSGBOX, string, string2, "Ok", "");
			return true;
		}
		else if(GetPlayerLanguage[playerid] == RUSSIAN)
	    {
			format(string, sizeof(string), "{FFFFFF}%s Статистике", GetUserName(playerid));
			format(string2, sizeof(string2), "{FFFFFF}счет: %d\nУбийства: %d\nСмертей: %d\nполосы: %d", GetPlayerScore(playerid), AccountInfo[playerid][user_kills], AccountInfo[playerid][user_deaths], AccountInfo[playerid][user_streaks]);
			ShowPlayerDialog(playerid, STATS_DIALOG, DIALOG_STYLE_MSGBOX, string, string2, "хорошо", "");
	    }
	}
	return true;
}

CMD:r(playerid, params[])
{
	new message[64], string[128];
	if(GetPlayerLanguage[playerid] == ENGLISH)
 	{
    	if(GetPlayerState(playerid) == PLAYER_STATE_NONE) return SendClientMessage(playerid, RED, "Error: You MUST be spawned to use this command.");
    	if(sscanf(params, "s[64]", message)) return SendClientMessage(playerid, RED, "Usage: /r [message]");
    	if(strlen(message) < 1 || strlen(message) > 64) return SendClientMessage(playerid, RED, "Error: Your message must be between 1-64 characters.");
		if(GetPlayerClass[playerid] == TEAM_COUNTER)
    	{
    	    format(string, sizeof(string), "%s @ radio: %s", GetUserName(playerid), message);
    	    CounterRadio(string);
    	    return true;
    	}
    	else if(GetPlayerClass[playerid] == TEAM_TERROR)
    	{
    	    format(string, sizeof(string), "%s @ radio: %s", GetUserName(playerid), message);
    	    TerrorRadio(string);
    	}
    	return true;
    }
    else if(GetPlayerLanguage[playerid] == RUSSIAN)
 	{
    	if(GetPlayerState(playerid) == PLAYER_STATE_NONE) return SendClientMessage(playerid, RED, "Ошибка: Вы должны быть порождены, чтобы использовать эту команду.");
    	if(sscanf(params, "s[64]", message)) return SendClientMessage(playerid, RED, "Использование: /r [сообщение]");
    	if(strlen(message) < 1 || strlen(message) > 64) return SendClientMessage(playerid, RED, "Ошибка: Ваше сообщение должно быть в пределах 1-64 символов.");
		if(GetPlayerClass[playerid] == TEAM_COUNTER)
    	{
    	    format(string, sizeof(string), "%s @ радио: %s", GetUserName(playerid), message);
    	    CounterRadio(string);
    	    return true;
    	}
    	else if(GetPlayerClass[playerid] == TEAM_TERROR)
    	{
    	    format(string, sizeof(string), "%s @ радио: %s", GetUserName(playerid), message);
    	    TerrorRadio(string);
    	}
	}
	return true;
}

CMD:language(playerid, params[])
{
    if(GetPlayerLanguage[playerid] == ENGLISH)
    {
        GetPlayerLanguage[playerid] = RUSSIAN;
        SendClientMessage(playerid, YELLOW, "Сервер: Язык сервера был установлен в русский.");
        return true;
    }
    else if(GetPlayerLanguage[playerid] == RUSSIAN)
    {
        GetPlayerLanguage[playerid] = ENGLISH;
        SendClientMessage(playerid, YELLOW, "Server: The server language has been set to English.");
    }
	return true;
}

CMD:pass(playerid, params[])
{
	if(IsPlayerLoggedIn[playerid] == false)
	{
		if(GetPlayerClass[playerid] == TEAM_COUNTER)
	    {
			SendClientMessage(playerid, RED, "Error: You MUST be logged in to use this command.");
			return true;
		}
		else if(GetPlayerClass[playerid] == TEAM_TERROR)
	    {
			SendClientMessage(playerid, RED, "Ошибка: Вы должны войти в систему, чтобы использовать эту команду.");
		}
		return true;
	}
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
		ShowPlayerDialog(playerid, PASS_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Change Password", "{FFFFFF}Please enter a new password below:", "Change", "Cancel");
		return true;
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
		ShowPlayerDialog(playerid, PASS_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Изменить пароль", "{FFFFFF}Пожалуйста, введите новый пароль в поле ниже:", "изменение", "отменить");
	}
	return true;
}

CMD:set(playerid, params[])
{
	new targetid, field[6];
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, WHITE, "SERVER: Unknown command.");
	if(sscanf(params, "us[6]", targetid, field)) return SendClientMessage(playerid, RED, "Usage: /set [name/id] [admin/vip]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
	if(!strcmp(field, "admin", true))
	{
	    if(AccountInfo[targetid][user_level] == VIP_LEVEL)
	    {
	        AccountInfo[targetid][user_level] = PLAYER_LEVEL;
		}
	    if(AccountInfo[targetid][user_level] == PLAYER_LEVEL)
	    {
		    AccountInfo[targetid][user_level] = ADMIN_LEVEL;
		    SavePlayerAccount(targetid);
		    new string[128];
		    format(string, sizeof(string), "Server: %s (%d) has been promoted to admin.", GetUserName(targetid), targetid);
		    SendClientMessage(playerid, WHITE, string);
		    SendClientMessage(targetid, YELLOW, "Admin: You have been promoted to admin!");
		    return true;
	    }
	    else if(AccountInfo[targetid][user_level] == ADMIN_LEVEL)
	    {
		    AccountInfo[targetid][user_level] = PLAYER_LEVEL;
		    SavePlayerAccount(targetid);
		    new string[128];
		    format(string, sizeof(string), "Server: %s (%d) has been demoted from admin.", GetUserName(targetid), targetid);
		    SendClientMessage(playerid, YELLOW, string);
		    SendClientMessage(targetid, RED, "Admin: You have been demoted from admin!");
	    }
	    return true;
	}
	if(!strcmp(field, "vip", true))
	{
		if(AccountInfo[targetid][user_level] == ADMIN_LEVEL)
	    {
	        AccountInfo[targetid][user_level] = PLAYER_LEVEL;
		}
	    if(AccountInfo[targetid][user_level] == PLAYER_LEVEL)
	    {
		    AccountInfo[targetid][user_level] = VIP_LEVEL;
		    SavePlayerAccount(targetid);
		    new string[128];
		    format(string, sizeof(string), "Server: %s (%d) has been promoted to vip.", GetUserName(targetid), targetid);
		    SendClientMessage(playerid, WHITE, string);
		    SendClientMessage(targetid, YELLOW, "Admin: You have been promoted to vip!");
		    return true;
	    }
	    else if(AccountInfo[targetid][user_level] == VIP_LEVEL)
	    {
		    AccountInfo[targetid][user_level] = PLAYER_LEVEL;
		    SavePlayerAccount(targetid);
		    new string[128];
		    format(string, sizeof(string), "Server: %s (%d) has been demoted from vip.", GetUserName(targetid), targetid);
		    SendClientMessage(playerid, YELLOW, string);
		    SendClientMessage(targetid, RED, "Admin: You have been demoted from vip!");
	    }
	}
	return true;
}

CMD:report(playerid, params[])
{
	new targetid, report[64], string[128];
	if(sscanf(params, "us[64]", targetid, report))
	{
		if(GetPlayerLanguage[playerid] == ENGLISH)
		{
			SendClientMessage(playerid, RED, "Usage: /report [name/id] [message]");
			return true;
		}
		else if(GetPlayerLanguage[playerid] == RUSSIAN)
		{
			SendClientMessage(playerid, RED, "Использование: /report [название] [сообщение]");
		}
		return true;
	}
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
	if(strlen(report) < 3 || strlen(report) > 64)
 	{
		if(GetPlayerLanguage[playerid] == ENGLISH)
		{
			SendClientMessage(playerid, RED, "Error: Your report MUST be between 3-64 characters.");
			return true;
		}
		else if(GetPlayerLanguage[playerid] == RUSSIAN)
		{
			SendClientMessage(playerid, RED, "Ошибка: Ваше сообщение должно быть в пределах 3-64 символов.");
		}
		return true;
  	}
  	format(string, sizeof(string), "Report: %s (%d) reported %s (%d) for: %s", GetUserName(playerid), playerid, GetUserName(targetid), targetid, report);
	AdminRadio(string);
	if(GetPlayerLanguage[playerid] == ENGLISH)
	{
		SendClientMessage(playerid, ORANGE, "Server: Your report has been sent to all online admins.");
		return true;
	}
	else if(GetPlayerLanguage[playerid] == RUSSIAN)
	{
		SendClientMessage(playerid, ORANGE, "Сервер: Ваш доклад был направлен ко всем онлайновым администраторов.");
	}
	return true;
}

CMD:a(playerid, params[])
{
	new message[80], string[128];
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(sscanf(params, "s[80]", message)) return SendClientMessage(playerid, RED, "Usage: /a [message]");
	if(!strlen(message)) return SendClientMessage(playerid, RED, "Error: You MUST enter a message.");
	if(strlen(message) < 1 || strlen(message) > 80) return SendClientMessage(playerid, RED, "Error: Your message MUST be between 1-80 characters.");
	format(string, sizeof(string), "Admin %s: %s", GetUserName(playerid), message);
	AdminRadio(string);
	return true;
}

CMD:kick(playerid, params[])
{
	new targetid, reason[32];
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(sscanf(params, "us[32]", targetid, reason)) return SendClientMessage(playerid, RED, "Usage: /kick [name/id] [reason]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
	if(!strlen(reason)) return SendClientMessage(playerid, RED, "Error: You MUST enter a reason.");
	if(strlen(reason) < 1 || strlen(reason) > 32) return SendClientMessage(playerid, RED, "Error: Your reason MUST be between 1-32 characters.");
	KickPlayer(targetid, reason);
 	return true;
}

CMD:ban(playerid, params[])
{
	new targetid, reason[32];
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(sscanf(params, "us[32]", targetid, reason)) return SendClientMessage(playerid, RED, "Usage: /ban [name/id] [reason]");
	if(AccountInfo[targetid][user_level] == ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: You cannot ban admins.");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
    if(GetPlayerState(targetid) == PLAYER_STATE_NONE) return SendClientMessage(playerid, RED, "Error: Player not spawned.");
	if(!strlen(reason)) return SendClientMessage(playerid, RED, "Error: You MUST enter a reason.");
	if(strlen(reason) < 1 || strlen(reason) > 32) return SendClientMessage(playerid, RED, "Error: Your reason MUST be between 1-32 characters.");

	AccountInfo[targetid][user_banned] = 1;
	SavePlayerAccount(targetid);

	new string[128];
	foreach(new id : Player)
	{
	    if(GetPlayerLanguage[id] == ENGLISH)
	    {
	        format(string, sizeof(string), "Admin: %s (%d) has been banned from the server. Reason: %s", GetUserName(targetid), targetid, reason);
	       	SendClientMessage(id, RED, string);
	    }
	    else if(GetPlayerLanguage[id] == RUSSIAN)
	    {
	        format(string, sizeof(string), "Админ: %s (%d) была запрещена с сервера. Причина: %s", GetUserName(targetid), targetid, reason);
	       	SendClientMessage(id, RED, string);
	    }
	}
	BanEx(targetid, reason);
	return true;
}

CMD:warn(playerid, params[])
{
	new targetid, reason[32], string[128], string2[128];
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(sscanf(params, "us[32]", targetid, reason)) return SendClientMessage(playerid, RED, "Usage: /warn [name/id] [reason]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
	if(!strlen(reason)) return SendClientMessage(playerid, RED, "Error: You MUST enter a reason.");
	if(strlen(reason) < 1 || strlen(reason) > 32) return SendClientMessage(playerid, RED, "Error: Your reason MUST be between 1-32 characters.");
    if(GetPlayerWarnCount[targetid] < 3)
    {
        GetPlayerWarnCount[targetid]++;
        if(GetPlayerLanguage[playerid] == ENGLISH)
        {
	       	format(string, sizeof(string), "Admin: You been warned by Admin %s for: %s [%d/3]", GetUserName(playerid), reason, GetPlayerWarnCount[playerid]);
	       	SendClientMessage(targetid, RED, string);
       	}
       	else if(GetPlayerLanguage[playerid] == RUSSIAN)
        {
	       	format(string, sizeof(string), "Admin: Вы были предупреждены Админ %s за: %s [%d/3]", GetUserName(playerid), reason, GetPlayerWarnCount[playerid]);
	       	SendClientMessage(targetid, RED, string);
       	}
       	format(string2, sizeof(string2), "Server: %s has been warned for: %s", GetUserName(targetid), reason);
       	SendClientMessage(playerid, ORANGE, string2);
		return true;
    }
    else if(GetPlayerWarnCount[targetid] == 3)
    {
        KickPlayer(targetid, "3 Warnings/Предупреждения");
    }
	return true;
}

CMD:explode(playerid, params[])
{
	new targetid, string[128];
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, RED, "Usage: /explode [name/id]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
	new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    CreateExplosion(x, y, z, 6, 5);
    CreateExplosion(x+2.5, y, z, 6, 2.5);
    CreateExplosion(x, y+2.5, z, 6, 2.5);
    CreateExplosion(x, y, z+2.5, 6, 2.5);
    SetPlayerHealth(targetid, 0.0);
	foreach(new id : Player)
	{
		if(GetPlayerLanguage[id] == ENGLISH)
		{
			format(string, sizeof(string), "Server: %s (%d) has died in an unknown explosion...", GetUserName(targetid), targetid);
			SendClientMessage(id, PINK, string);
		}
		else if(GetPlayerLanguage[id] == RUSSIAN)
		{
			format(string, sizeof(string), "Сервер: %s (%d) умер в неизвестном взрыв...", GetUserName(targetid), targetid);
			SendClientMessage(id, PINK, string);
		}
	}
	return true;
}

CMD:goto(playerid, params[])
{
	new targetid, Float:x, Float:y, Float:z;
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, RED, "Usage: /goto [name/id]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
	GetPlayerPos(targetid, x, y, z);
	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
	SetPlayerPos(playerid, x+2, y+2, z+1);
	return true;
}

CMD:get(playerid, params[])
{
	new targetid, Float:x, Float:y, Float:z;
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, RED, "Usage: /get [name/id]");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
	GetPlayerPos(playerid, x, y, z);
	SetPlayerInterior(targetid, GetPlayerInterior(playerid));
	SetPlayerPos(targetid, x+2, y+2, z+1);
	return true;
}

CMD:spec(playerid, params[])
{
    new targetid;
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, RED, "Usage: /spec [name/id]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, RED, "Error: Player not found.");
    if(GetPlayerState(targetid) == PLAYER_STATE_NONE) return SendClientMessage(playerid, RED, "Error: Player not spawned.");
    if(targetid == playerid) return SendClientMessage(playerid, RED, "Error: You cannot spectate yourself.");
    IsAdminSpectating[playerid] = true;
	TogglePlayerSpectating(playerid, true);
 	if(IsPlayerInAnyVehicle(targetid))
  	{
		SetPlayerInterior(playerid, GetPlayerInterior(targetid));
  		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
	    PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
    	return true;
    }
    else
    {
    	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
     	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
     	PlayerSpectatePlayer(playerid, targetid);
    }
    return true;
}

CMD:specoff(playerid, params[])
{
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(IsAdminSpectating[playerid] == false) return SendClientMessage(playerid, RED, "Error: You are not spectating anyone.");
	IsAdminSpectating[playerid] = false;
	TogglePlayerSpectating(playerid, false);
    return true;
}

CMD:duty(playerid, params[])
{
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	if(IsAntiSpawnKillOn[playerid] == true) return SendClientMessage(playerid, RED, "Error: You cannot use this command whilst in anti-spawn mode.");
	if(IsAdminOnDuty[playerid] == false)
	{
	    IsAdminOnDuty[playerid] = true;
	    GetAdminTeamSkin[playerid] = GetPlayerSkin(playerid);
	    SetPlayerSkin(playerid, 294);
	    SetPlayerColor(playerid, PURPLE);
	    SetPlayerHealth(playerid, 99999);
	    return true;
	}
	else if(IsAdminOnDuty[playerid] == true)
	{
	    if(GetPlayerClass[playerid] == TEAM_COUNTER)
	    {
	    	SetPlayerSkin(playerid, GetAdminTeamSkin[playerid]);
	        SetPlayerColor(playerid, BLUE);
	    	SetPlayerHealth(playerid, 100);
	    	IsAdminOnDuty[playerid] = false;
	    	return true;
	    }
	    else if(GetPlayerClass[playerid] == TEAM_TERROR)
	    {
	    	SetPlayerSkin(playerid, GetAdminTeamSkin[playerid]);
	        SetPlayerColor(playerid, RED);
	    	SetPlayerHealth(playerid, 100);
	    	IsAdminOnDuty[playerid] = false;
	    }
	}
	return true;
}

CMD:respawn(playerid, params[])
{
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");

	for(new v = 0; v < MAX_VEHICLES; v++)
	{
	    if(IsVehicleEmpty(v) == 1)
	    {
	        SetVehicleToRespawn(v);
		}
	}
	return true;
}

CMD:ann(playerid, params[])
{
    new message[32], string[128];
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
    if(sscanf(params, "s[32]", message)) return SendClientMessage(playerid, RED, "Usage: /ann [msg]");
    if(strlen(message) < 1 || strlen(message) > 32) return SendClientMessage(playerid, RED, "Error: Your message MUST be between 1-32 characters.");
	format(string, sizeof(string), "~w~%s", message);
 	GameTextForAll(string, 5000, 5);
	return true;
}


CMD:jet(playerid, params[])
{
	if(AccountInfo[playerid][user_level] < ADMIN_LEVEL) return SendClientMessage(playerid, RED, "Error: This is a restricted admin command.");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	return true;
}

CMD:changeteam(playerid, params[])
{
	new string[128];
    HasPlayerChangedClass[playerid] = true;
	SetPlayerHealth(playerid, 0);
	if(IsAntiSpawnKillOn[playerid] == true)
	{
	    IsAntiSpawnKillOn[playerid] = false;
	    KillTimer(anti_spawn_kill_timer[playerid]);
	}
	foreach(new id : Player)
	{
		if(GetPlayerLanguage[id] == ENGLISH)
		{
			format(string, sizeof(string), "Server: %s (%d) has changed team.", GetUserName(playerid), playerid);
			SendClientMessage(id, PINK, string);
		}
		else if(GetPlayerLanguage[id] == RUSSIAN)
		{
			format(string, sizeof(string), "Сервер: %s (%d) изменилась команда.", GetUserName(playerid), playerid);
			SendClientMessage(id, PINK, string);
		}
	}
	return true;
}
