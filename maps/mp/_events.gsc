// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "execution", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "defender", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 25 );
    maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "double", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "triple", 75 );
    maps\mp\gametypes\_rank::registerScoreInfo( "multi", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 100 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "damage", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "heavy_damage", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "damaged", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "kill", 1 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "killed", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "healed", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "headshot", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "melee", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "backstab", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "longshot", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "assistedsuicide", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "defender", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "avenger", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "execution", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "comeback", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "revenge", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "buzzkill", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "double", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "triple", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "multi", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "assist", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "firstBlood", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "capture", 1 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "assistedCapture", 1 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "plant", 1 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "defuse", 1 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "vehicleDestroyed", 1 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "3streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "4streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "5streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "6streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "7streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "8streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "9streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "10streak", 0 );
    maps\mp\killstreaks\_killstreaks::registerAdrenalineInfo( "regen", 0 );
    precacheshader( "crosshair_red" );
    level._effect["money"] = loadfx( "props/cash_player_drop" );
    level.numKills = 0;
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0.killedPlayers = [];
        var_0.killedPlayersCurrent = [];
        var_0.killedBy = [];
        var_0.lastKilledBy = undefined;
        var_0.greatestUniquePlayerKills = 0;
        var_0.recentKillCount = 0;
        var_0.lastKillTime = 0;
        var_0.damagedPlayers = [];
        var_0 thread monitorCrateJacking();
        var_0 thread monitorObjectives();
        var_0 thread monitorHealed();
    }
}

damagedPlayer( var_0, var_1, var_2 )
{
    if ( var_1 < 50 && var_1 > 10 )
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "damage" );
    else
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "heavy_damage" );
}

killedPlayer( var_0, var_1, var_2, var_3 )
{
    var_4 = var_1.guid;
    var_5 = self.guid;
    var_6 = gettime();
    thread updateRecentKills( var_0 );
    self.lastKillTime = gettime();
    self.lastKilledPlayer = var_1;
    self.modifiers = [];
    level.numKills++;
    self.damagedPlayers[var_4] = undefined;

    if ( !maps\mp\_utility::isKillstreakWeapon( var_2 ) && !maps\mp\_utility::isJuggernaut() && !maps\mp\_utility::_hasPerk( "specialty_explosivebullets" ) )
    {
        if ( var_2 == "none" )
            return 0;

        if ( isdefined( self.pers["copyCatLoadout"] ) && isdefined( self.pers["copyCatLoadout"]["owner"] ) )
        {
            if ( var_1 == self.pers["copyCatLoadout"]["owner"] )
                self.modifiers["clonekill"] = 1;
        }

        if ( var_1.attackers.size == 1 && !isdefined( var_1.attackers[var_1.guid] ) )
        {
            var_10 = maps\mp\_utility::getWeaponClass( var_2 );

            if ( var_10 == "weapon_sniper" && var_3 != "MOD_MELEE" && gettime() == var_1.attackerData[self.guid].firstTimeDamaged )
            {
                self.modifiers["oneshotkill"] = 1;
                thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_ONE_SHOT_KILL" );
            }
        }

        if ( isdefined( var_1.throwingGrenade ) && var_1.throwingGrenade == "frag_grenade_mp" )
            self.modifiers["cooking"] = 1;

        if ( isdefined( self.assistedSuicide ) && self.assistedSuicide )
            assistedSuicide( var_0, var_2, var_3 );

        if ( level.numKills == 1 )
            firstBlood( var_0, var_2, var_3 );

        if ( self.pers["cur_death_streak"] > 3 )
            comeBack( var_0, var_2, var_3 );

        if ( var_3 == "MOD_HEAD_SHOT" )
        {
            if ( isdefined( var_1.laststand ) )
                execution( var_0, var_2, var_3 );
            else
                headShot( var_0, var_2, var_3 );
        }

        if ( isdefined( self.wasTI ) && self.wasTI && gettime() - self.spawnTime <= 5000 )
            self.modifiers["jackintheboxkill"] = 1;

        if ( !isalive( self ) && self.deathtime + 800 < gettime() )
            postDeathKill( var_0 );

        var_11 = 0;

        if ( level.teamBased && var_6 - var_1.lastKillTime < 500 )
        {
            if ( var_1.lastKilledPlayer != self )
                avengedPlayer( var_0, var_2, var_3 );
        }

        foreach ( var_14, var_13 in var_1.damagedPlayers )
        {
            if ( var_14 == self.guid )
                continue;

            if ( level.teamBased && var_6 - var_13 < 500 )
                defendedPlayer( var_0, var_2, var_3 );
        }

        if ( isdefined( var_1.attackerPosition ) )
            var_15 = var_1.attackerPosition;
        else
            var_15 = self.origin;

        if ( isLongShot( self, var_2, var_3, var_15, var_1 ) )
            thread longshot( var_0, var_2, var_3 );

        if ( var_1.pers["cur_kill_streak"] > 0 && isdefined( var_1.killstreaks[var_1.pers["cur_kill_streak"] + 1] ) )
            buzzKill( var_0, var_1, var_2, var_3 );

        thread checkMatchDataKills( var_0, var_1, var_2, var_3 );
    }

    if ( !isdefined( self.killedPlayers[var_4] ) )
        self.killedPlayers[var_4] = 0;

    if ( !isdefined( self.killedPlayersCurrent[var_4] ) )
        self.killedPlayersCurrent[var_4] = 0;

    if ( !isdefined( var_1.killedBy[var_5] ) )
        var_1.killedBy[var_5] = 0;

    self.killedPlayers[var_4]++;

    if ( self.killedPlayers[var_4] > self.greatestUniquePlayerKills )
        maps\mp\_utility::setPlayerStat( "killedsameplayer", self.killedPlayers[var_4] );

    self.killedPlayersCurrent[var_4]++;
    var_1.killedBy[var_5]++;
    var_1.lastKilledBy = self;
}

isLongShot( var_0, var_1, var_2, var_3, var_4 )
{
    if ( isalive( var_0 ) && !var_0 maps\mp\_utility::isUsingRemote() && ( var_2 == "MOD_RIFLE_BULLET" || var_2 == "MOD_PISTOL_BULLET" || var_2 == "MOD_HEAD_SHOT" ) && !maps\mp\_utility::isKillstreakWeapon( var_1 ) && !isdefined( var_0.assistedSuicide ) )
    {
        var_5 = maps\mp\_utility::getWeaponClass( var_1 );

        switch ( var_5 )
        {
            case "weapon_pistol":
                var_6 = 800;
                break;
            case "weapon_smg":
            case "weapon_machine_pistol":
                var_6 = 1200;
                break;
            case "weapon_assault":
            case "weapon_lmg":
                var_6 = 1500;
                break;
            case "weapon_sniper":
                var_6 = 2000;
                break;
            case "weapon_shotgun":
                var_6 = 500;
                break;
            case "weapon_projectile":
            default:
                var_6 = 1536;
                break;
        }

        if ( distance( var_3, var_4.origin ) > var_6 )
        {
            if ( var_0 isitemunlocked( "specialty_holdbreath" ) && var_0 maps\mp\_utility::_hasPerk( "specialty_holdbreath" ) )
                var_0 maps\mp\gametypes\_missions::processChallenge( "ch_longdistance" );

            return 1;
        }
    }

    return 0;
}

checkMatchDataKills( var_0, var_1, var_2, var_3 )
{
    var_4 = maps\mp\_utility::getWeaponClass( var_2 );
    var_5 = 0;
    thread camperCheck();

    if ( isdefined( self.lastKilledBy ) && self.lastKilledBy == var_1 )
    {
        self.lastKilledBy = undefined;
        revenge( var_0 );
        playfx( level._effect["money"], var_1 gettagorigin( "j_spine4" ) );
    }

    if ( var_1.iDFlags & level.iDFLAGS_PENETRATION )
        maps\mp\_utility::incPlayerStat( "bulletpenkills", 1 );

    if ( self.pers["rank"] < var_1.pers["rank"] )
        maps\mp\_utility::incPlayerStat( "higherrankkills", 1 );

    if ( self.pers["rank"] > var_1.pers["rank"] )
        maps\mp\_utility::incPlayerStat( "lowerrankkills", 1 );

    if ( isdefined( self.inFinalStand ) && self.inFinalStand )
        maps\mp\_utility::incPlayerStat( "laststandkills", 1 );

    if ( isdefined( var_1.inFinalStand ) && var_1.inFinalStand )
        maps\mp\_utility::incPlayerStat( "laststanderkills", 1 );

    if ( self getcurrentweapon() != self.primaryWeapon && self getcurrentweapon() != self.secondaryWeapon )
        maps\mp\_utility::incPlayerStat( "otherweaponkills", 1 );

    var_6 = gettime() - var_1.spawnTime;

    if ( !maps\mp\_utility::matchMakingGame() )
        var_1 maps\mp\_utility::setPlayerStatIfLower( "shortestlife", var_6 );

    var_1 maps\mp\_utility::setPlayerStatIfGreater( "longestlife", var_6 );

    if ( var_3 != "MOD_MELEE" )
    {
        switch ( var_4 )
        {
            case "weapon_smg":
            case "weapon_assault":
            case "weapon_sniper":
            case "weapon_lmg":
            case "weapon_shotgun":
            case "weapon_projectile":
            case "weapon_pistol":
                checkMatchDataWeaponKills( var_1, var_2, var_3, var_4 );
                break;
            case "weapon_grenade":
            case "weapon_explosive":
                checkMatchDataEquipmentKills( var_1, var_2, var_3 );
                break;
            default:
                break;
        }
    }
}

checkMatchDataWeaponKills( var_0, var_1, var_2, var_3 )
{
    var_4 = self;
    var_5 = undefined;
    var_6 = undefined;
    var_7 = undefined;

    switch ( var_3 )
    {
        case "weapon_pistol":
            var_5 = "pistolkills";
            var_6 = "pistolheadshots";
            break;
        case "weapon_smg":
            var_5 = "smgkills";
            var_6 = "smgheadshots";
            break;
        case "weapon_assault":
            var_5 = "arkills";
            var_6 = "arheadshots";
            break;
        case "weapon_projectile":
            if ( weaponclass( var_1 ) == "rocketlauncher" )
                var_5 = "rocketkills";

            break;
        case "weapon_sniper":
            var_5 = "sniperkills";
            var_6 = "sniperheadshots";
            break;
        case "weapon_shotgun":
            var_5 = "shotgunkills";
            var_6 = "shotgunheadshots";
            var_7 = "shotgundeaths";
            break;
        case "weapon_lmg":
            var_5 = "lmgkills";
            var_6 = "lmgheadshots";
            break;
        default:
            break;
    }

    if ( isdefined( var_5 ) )
        var_4 maps\mp\_utility::incPlayerStat( var_5, 1 );

    if ( isdefined( var_6 ) && var_2 == "MOD_HEAD_SHOT" )
        var_4 maps\mp\_utility::incPlayerStat( var_6, 1 );

    if ( isdefined( var_7 ) && !maps\mp\_utility::matchMakingGame() )
        var_0 maps\mp\_utility::incPlayerStat( var_7, 1 );

    if ( var_4 playerads() > 0.5 )
    {
        var_4 maps\mp\_utility::incPlayerStat( "adskills", 1 );

        if ( var_3 == "weapon_sniper" || issubstr( var_1, "acog" ) )
            var_4 maps\mp\_utility::incPlayerStat( "scopedkills", 1 );

        if ( issubstr( var_1, "thermal" ) )
            var_4 maps\mp\_utility::incPlayerStat( "thermalkills", 1 );
    }
    else
        var_4 maps\mp\_utility::incPlayerStat( "hipfirekills", 1 );
}

checkMatchDataEquipmentKills( var_0, var_1, var_2 )
{
    var_3 = self;

    switch ( var_1 )
    {
        case "frag_grenade_mp":
            var_3 maps\mp\_utility::incPlayerStat( "fragkills", 1 );
            var_3 maps\mp\_utility::incPlayerStat( "grenadekills", 1 );
            var_4 = 1;
            break;
        case "c4_mp":
            var_3 maps\mp\_utility::incPlayerStat( "c4kills", 1 );
            var_4 = 1;
            break;
        case "semtex_mp":
            var_3 maps\mp\_utility::incPlayerStat( "semtexkills", 1 );
            var_3 maps\mp\_utility::incPlayerStat( "grenadekills", 1 );
            var_4 = 1;
            break;
        case "claymore_mp":
            var_3 maps\mp\_utility::incPlayerStat( "claymorekills", 1 );
            var_4 = 1;
            break;
        case "throwingknife_mp":
            var_3 maps\mp\_utility::incPlayerStat( "throwingknifekills", 1 );
            thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_KNIFETHROW" );
            var_4 = 1;
            break;
        default:
            var_4 = 0;
            break;
    }

    if ( var_4 )
        var_3 maps\mp\_utility::incPlayerStat( "equipmentkills", 1 );
}

camperCheck()
{
    self.lastKillWasCamping = 0;

    if ( !isdefined( self.lastKillLocation ) )
    {
        self.lastKillLocation = self.origin;
        self.lastCampKillTime = gettime();
        return;
    }

    if ( distance( self.lastKillLocation, self.origin ) < 512 && gettime() - self.lastCampKillTime > 5000 )
    {
        maps\mp\_utility::incPlayerStat( "mostcamperkills", 1 );
        self.lastKillWasCamping = 1;
    }

    self.lastKillLocation = self.origin;
    self.lastCampKillTime = gettime();
}

consolation( var_0 )
{

}

proximityAssist( var_0 )
{
    self.modifiers["proximityAssist"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_PROXIMITYASSIST" );
    thread maps\mp\gametypes\_rank::giveRankXP( "proximityassist" );
}

proximityKill( var_0 )
{
    self.modifiers["proximityKill"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_PROXIMITYKILL" );
    thread maps\mp\gametypes\_rank::giveRankXP( "proximitykill" );
}

longshot( var_0, var_1, var_2 )
{
    self.modifiers["longshot"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_LONGSHOT" );
    thread maps\mp\gametypes\_rank::giveRankXP( "longshot", undefined, var_1, var_2 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "longshot" );
    maps\mp\_utility::incPlayerStat( "longshots", 1 );
    thread maps\mp\_matchdata::logKillEvent( var_0, "longshot" );
}

execution( var_0, var_1, var_2 )
{
    self.modifiers["execution"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_EXECUTION" );
    thread maps\mp\gametypes\_rank::giveRankXP( "execution", undefined, var_1, var_2 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "execution" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "execution" );
}

headShot( var_0, var_1, var_2 )
{
    self.modifiers["headshot"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_HEADSHOT" );
    thread maps\mp\gametypes\_rank::giveRankXP( "headshot", undefined, var_1, var_2 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "headshot" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "headshot" );
}

avengedPlayer( var_0, var_1, var_2 )
{
    self.modifiers["avenger"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_AVENGER" );
    thread maps\mp\gametypes\_rank::giveRankXP( "avenger", undefined, var_1, var_2 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "avenger" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "avenger" );
    maps\mp\_utility::incPlayerStat( "avengekills", 1 );
}

assistedSuicide( var_0, var_1, var_2 )
{
    self.modifiers["assistedsuicide"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_ASSISTEDSUICIDE" );
    thread maps\mp\gametypes\_rank::giveRankXP( "assistedsuicide", undefined, var_1, var_2 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "assistedsuicide" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "assistedsuicide" );
}

defendedPlayer( var_0, var_1, var_2 )
{
    self.modifiers["defender"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DEFENDER" );
    thread maps\mp\gametypes\_rank::giveRankXP( "defender", undefined, var_1, var_2 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "defender" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "defender" );
    maps\mp\_utility::incPlayerStat( "rescues", 1 );
}

postDeathKill( var_0 )
{
    self.modifiers["posthumous"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_POSTHUMOUS" );
    thread maps\mp\gametypes\_rank::giveRankXP( "posthumous" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "posthumous" );
}

backStab( var_0 )
{
    self iprintlnbold( "backstab" );
}

revenge( var_0 )
{
    self.modifiers["revenge"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_REVENGE" );
    thread maps\mp\gametypes\_rank::giveRankXP( "revenge" );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "revenge" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "revenge" );
    maps\mp\_utility::incPlayerStat( "revengekills", 1 );
}

multiKill( var_0, var_1 )
{
    if ( var_1 == 2 )
    {
        thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DOUBLEKILL" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "double" );
    }
    else if ( var_1 == 3 )
    {
        thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_TRIPLEKILL" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "triple" );
        thread maps\mp\_utility::teamPlayerCardSplash( "callout_3xkill", self );
    }
    else
    {
        thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_MULTIKILL" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "multi" );
        thread maps\mp\_utility::teamPlayerCardSplash( "callout_3xpluskill", self );
    }

    thread maps\mp\_matchdata::logMultiKill( var_0, var_1 );
    maps\mp\_utility::setPlayerStatIfGreater( "multikill", var_1 );
    maps\mp\_utility::incPlayerStat( "mostmultikills", 1 );
}

firstBlood( var_0, var_1, var_2 )
{
    self.modifiers["firstblood"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_FIRSTBLOOD" );
    thread maps\mp\gametypes\_rank::giveRankXP( "firstblood", undefined, var_1, var_2 );
    thread maps\mp\_matchdata::logKillEvent( var_0, "firstblood" );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "firstBlood" );
    thread maps\mp\_utility::teamPlayerCardSplash( "callout_firstblood", self );
}

winningShot( var_0 )
{

}

buzzKill( var_0, var_1, var_2, var_3 )
{
    self.modifiers["buzzkill"] = var_1.pers["cur_kill_streak"];
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_BUZZKILL" );
    thread maps\mp\gametypes\_rank::giveRankXP( "buzzkill", undefined, var_2, var_3 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "buzzkill" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "buzzkill" );
}

comeBack( var_0, var_1, var_2 )
{
    self.modifiers["comeback"] = 1;
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_COMEBACK" );
    thread maps\mp\gametypes\_rank::giveRankXP( "comeback", undefined, var_1, var_2 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "comeback" );
    thread maps\mp\_matchdata::logKillEvent( var_0, "comeback" );
    maps\mp\_utility::incPlayerStat( "comebacks", 1 );
}

disconnected()
{
    var_0 = self.guid;

    for ( var_1 = 0; var_1 < level.players.size; var_1++ )
    {
        if ( isdefined( level.players[var_1].killedPlayers[var_0] ) )
            level.players[var_1].killedPlayers[var_0] = undefined;

        if ( isdefined( level.players[var_1].killedPlayersCurrent[var_0] ) )
            level.players[var_1].killedPlayersCurrent[var_0] = undefined;

        if ( isdefined( level.players[var_1].killedBy[var_0] ) )
            level.players[var_1].killedBy[var_0] = undefined;
    }
}

monitorHealed()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "healed" );
        maps\mp\killstreaks\_killstreaks::giveAdrenaline( "healed" );
    }
}

updateRecentKills( var_0 )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self notify( "updateRecentKills" );
    self endon( "updateRecentKills" );
    self.recentKillCount++;
    wait 1.0;

    if ( self.recentKillCount > 1 )
        multiKill( var_0, self.recentKillCount );

    self.recentKillCount = 0;
}

monitorCrateJacking()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "hijacker",  var_0, var_1  );
        thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_HIJACKER" );
        thread maps\mp\gametypes\_rank::giveRankXP( "hijacker", 100 );
        var_2 = "hijacked_airdrop";
        var_3 = "ch_hijacker";

        switch ( var_0 )
        {
            case "sentry":
                var_2 = "hijacked_sentry";
                break;
            case "juggernaut":
                var_2 = "hijacked_juggernaut";
                break;
            case "remote_tank":
                var_2 = "hijacked_remote_tank";
                break;
            case "mega":
            case "emergency_airdrop":
                var_2 = "hijacked_emergency_airdrop";
                var_3 = "ch_newjack";
                break;
            default:
                break;
        }

        if ( isdefined( var_1 ) )
            var_1 maps\mp\gametypes\_hud_message::playerCardSplashNotify( var_2, self );

        self notify( "process",  var_3  );
    }
}

monitorObjectives()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "objective",  var_0  );

        if ( var_0 == "captured" )
        {
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "capture" );

            if ( isdefined( self.laststand ) && self.laststand )
            {
                thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "heroic", 100 );
                thread maps\mp\gametypes\_rank::giveRankXP( "reviver", 100 );
            }
        }

        if ( var_0 == "assistedCapture" )
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "assistedCapture" );

        if ( var_0 == "plant" )
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "plant" );

        if ( var_0 == "defuse" )
            maps\mp\killstreaks\_killstreaks::giveAdrenaline( "defuse" );
    }
}
