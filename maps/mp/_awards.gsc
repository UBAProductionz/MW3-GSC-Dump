// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    initAwards();
    level thread onPlayerConnect();
    level thread monitorMovementDistance();
    level thread monitorEnemyDistance();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );

        if ( !isdefined( var_0.pers["stats"] ) )
            var_0.pers["stats"] = [];

        var_0.stats = var_0.pers["stats"];

        if ( !var_0.stats.size )
        {
            var_0 setplayerdata( "round", "awardCount", 0 );

            foreach ( var_3, var_2 in level.awards )
            {
                if ( isdefined( level.awards[var_3].defaultvalue ) )
                {
                    var_0 maps\mp\_utility::initPlayerStat( var_3, level.awards[var_3].defaultvalue );
                    continue;
                }

                var_0 maps\mp\_utility::initPlayerStat( var_3 );
            }
        }

        var_0.prevPos = var_0.origin;
        var_0.previousDeaths = 0;
        var_0.altitudePolls = 0;
        var_0.totalAltitudeSum = 0;
        var_0.usedWeapons = [];
        var_0 thread onPlayerSpawned();
        var_0 thread monitorPositionCamping();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );
        thread monitorReloads();
        thread monitorShotsFired();
        thread monitorSwaps();
        thread monitorExplosionsSurvived();
        thread monitorShieldBlocks();
        thread monitorFlashHits();
        thread monitorStunHits();
        thread monitorStanceTime();
    }
}

initAwards()
{
    if ( isdefined( level.initGametypeAwards ) )
        [[ level.initGametypeAwards ]]();

    initAwardFlag( "10kills", ::isAtleast, 10, "kills" );
    initAwardFlag( "1death", ::isAtleast, 1, "deaths" );
    initAwardFlag( "nodeaths", ::isAtMost, 0, "deaths" );
    initAwardFlag( "nokills", ::isAtMost, 0, "kills" );
    initMultiAward( "mvp", "kills", "deaths" );
    initMultiAward( "punisher", "kills", "killstreak" );
    initMultiAward( "overkill", "kills", "headshots" );
    initStatAward( "kdratio", 0, ::highestWins );
    initStatAward( "kills", 0, ::highestWins );
    initStatAward( "higherrankkills", 0, ::highestWins );
    initStatAward( "deaths", 0, ::lowestWithHalfPlayedTime );
    initStatAward( "killstreak", 0, ::highestWins );
    initStatAward( "headshots", 0, ::highestWins );
    initStatAward( "closertoenemies", 0, ::highestWins );
    initStatAward( "throwingknifekills", 0, ::highestWins );
    initStatAward( "grenadekills", 0, ::highestWins );
    initStatAward( "helicopters", 0, ::highestWins );
    initStatAward( "airstrikes", 0, ::highestWins );
    initStatAward( "uavs", 0, ::highestWins );
    initStatAward( "mostmultikills", 0, ::highestWins );
    initStatAward( "multikill", 0, ::highestWins );
    initStatAward( "knifekills", 0, ::highestWins );
    initStatAward( "flankkills", 0, ::highestWins );
    initStatAward( "bulletpenkills", 0, ::highestWins );
    initStatAward( "laststandkills", 0, ::highestWins );
    initStatAward( "laststanderkills", 0, ::highestWins );
    initStatAward( "assists", 0, ::highestWins );
    initStatAward( "c4kills", 0, ::highestWins );
    initStatAward( "claymorekills", 0, ::highestWins );
    initStatAward( "fragkills", 0, ::highestWins );
    initStatAward( "semtexkills", 0, ::highestWins );
    initStatAward( "explosionssurvived", 0, ::highestWins );
    initStatAward( "mosttacprevented", 0, ::highestWins );
    initStatAward( "avengekills", 0, ::highestWins );
    initStatAward( "rescues", 0, ::highestWins );
    initStatAward( "longshots", 0, ::highestWins );
    initStatAward( "adskills", 0, ::highestWins );
    initStatAward( "hipfirekills", 0, ::highestWins );
    initStatAward( "revengekills", 0, ::highestWins );
    initStatAward( "longestlife", 0, ::highestWins );
    initStatAward( "throwbacks", 0, ::highestWins );
    initStatAward( "otherweaponkills", 0, ::highestWins );
    initStatAward( "killedsameplayer", 0, ::highestWins, 2 );
    initStatAward( "mostweaponsused", 0, ::highestWins, 3 );
    initStatAward( "distancetraveled", 0, ::highestWins );
    initStatAward( "mostreloads", 0, ::highestWins );
    initStatAward( "mostswaps", 0, ::highestWins );
    initStat( "flankdeaths", 0 );
    initStatAward( "thermalkills", 0, ::highestWins );
    initStatAward( "mostcamperkills", 0, ::highestWins );
    initStatAward( "fbhits", 0, ::highestWins );
    initStatAward( "stunhits", 0, ::highestWins );
    initStatAward( "scopedkills", 0, ::highestWins );
    initStatAward( "arkills", 0, ::highestWins );
    initStatAward( "arheadshots", 0, ::highestWins );
    initStatAward( "lmgkills", 0, ::highestWins );
    initStatAward( "lmgheadshots", 0, ::highestWins );
    initStatAward( "sniperkills", 0, ::highestWins );
    initStatAward( "sniperheadshots", 0, ::highestWins );
    initStatAward( "shieldblocks", 0, ::highestWins );
    initStatAward( "shieldkills", 0, ::highestWins );
    initStatAward( "smgkills", 0, ::highestWins );
    initStatAward( "smgheadshots", 0, ::highestWins );
    initStatAward( "shotgunkills", 0, ::highestWins );
    initStatAward( "shotgunheadshots", 0, ::highestWins );
    initStatAward( "pistolkills", 0, ::highestWins );
    initStatAward( "pistolheadshots", 0, ::highestWins );
    initStatAward( "rocketkills", 0, ::highestWins );
    initStatAward( "equipmentkills", 0, ::highestWins );
    initStatAward( "mostclasseschanged", 0, ::highestWins );
    initStatAward( "lowerrankkills", 0, ::highestWins );
    initStatAward( "sprinttime", 0, ::highestWins, 1 );
    initStatAward( "crouchtime", 0, ::highestWins );
    initStatAward( "pronetime", 0, ::highestWins );
    initStatAward( "comebacks", 0, ::highestWins );
    initStatAward( "mostshotsfired", 0, ::highestWins );
    initStatAward( "timeinspot", 0, ::highestWins );
    initStatAward( "killcamtimewatched", 0, ::highestWins );
    initStatAward( "greatestavgalt", 0, ::highestWins );
    initStatAward( "leastavgalt", 9999999, ::lowestWins );
    initStatAward( "weaponxpearned", 0, ::highestWins );
    initStatAward( "assaultkillstreaksused", 0, ::highestWins );
    initStatAward( "supportkillstreaksused", 0, ::highestWins );
    initStatAward( "specialistkillstreaksearned", 0, ::highestWins );
    initStatAward( "killsconfirmed", 0, ::highestWins );
    initStatAward( "killsdenied", 0, ::highestWins );
    initStatAward( "holdingteamdefenderflag", 0, ::highestWins );
    initStatAward( "damagedone", 0, ::highestWins );
    initStatAward( "damagetaken", 0, ::lowestWins );

    if ( !maps\mp\_utility::matchMakingGame() )
    {
        initStatAward( "killcamskipped", 0, ::highestWins );
        initStatAward( "killsteals", 0, ::highestWins );

        if ( !maps\mp\_utility::getGametypeNumLives() )
            initStatAward( "deathstreak", 0, ::highestWins );

        initStatAward( "shortestlife", 9999999, ::lowestWins );
        initStatAward( "suicides", 0, ::highestWins );
        initStatAward( "mostff", 0, ::highestWins );
        initStatAward( "shotgundeaths", 0, ::highestWins );
        initStatAward( "shielddeaths", 0, ::highestWins );
        initStatAward( "flankdeaths", 0, ::highestWins );
    }
}

initBaseAward( var_0 )
{
    level.awards[var_0] = spawnstruct();
    level.awards[var_0].winners = [];
    level.awards[var_0].exclusive = 1;
}

initAwardProcess( var_0, var_1, var_2, var_3 )
{
    if ( isdefined( var_1 ) )
        level.awards[var_0].process = var_1;

    if ( isdefined( var_2 ) )
        level.awards[var_0].var1 = var_2;

    if ( isdefined( var_3 ) )
        level.awards[var_0].var2 = var_3;
}

initStat( var_0, var_1 )
{
    initBaseAward( var_0 );
    level.awards[var_0].defaultvalue = var_1;
    level.awards[var_0].type = "stat";
}

initStatAward( var_0, var_1, var_2, var_3, var_4 )
{
    initBaseAward( var_0 );
    initAwardProcess( var_0, var_2, var_3, var_4 );
    level.awards[var_0].defaultvalue = var_1;
    level.awards[var_0].type = "stat";
}

initDerivedAward( var_0, var_1, var_2, var_3 )
{
    initBaseAward( var_0 );
    initAwardProcess( var_0, var_1, var_2, var_3 );
    level.awards[var_0].type = "derived";
}

initAwardFlag( var_0, var_1, var_2, var_3 )
{
    initBaseAward( var_0 );
    initAwardProcess( var_0, var_1, var_2, var_3 );
    level.awards[var_0].type = "flag";
}

initMultiAward( var_0, var_1, var_2 )
{
    initBaseAward( var_0 );
    level.awards[var_0].award1_ref = var_1;
    level.awards[var_0].award2_ref = var_2;
    level.awards[var_0].type = "multi";
}

initThresholdAward( var_0, var_1, var_2, var_3 )
{
    initBaseAward( var_0 );
    initAwardProcess( var_0, var_1, var_2, var_3 );
    level.awards[var_0].type = "threshold";
}

setMatchRecordIfGreater( var_0 )
{
    var_1 = maps\mp\_utility::getPlayerStat( var_0 );
    var_2 = maps\mp\_utility::getPlayerStatTime( var_0 );
    var_3 = getAwardRecord( var_0 );
    var_4 = getAwardRecordTime( var_0 );

    if ( !isdefined( var_3 ) || var_1 > var_3 )
    {
        clearAwardWinners( var_0 );
        addAwardWinner( var_0, self.clientid );
        setAwardRecord( var_0, var_1, var_2 );
    }
    else if ( var_1 == var_3 )
    {
        if ( isAwardExclusive( var_0 ) )
        {
            if ( !isdefined( var_4 ) || var_2 < var_4 )
            {
                clearAwardWinners( var_0 );
                addAwardWinner( var_0, self.clientid );
                setAwardRecord( var_0, var_1, var_2 );
            }
        }
        else
            addAwardWinner( var_0, self.clientid );
    }
}

setMatchRecordIfLower( var_0 )
{
    var_1 = maps\mp\_utility::getPlayerStat( var_0 );
    var_2 = maps\mp\_utility::getPlayerStatTime( var_0 );
    var_3 = getAwardRecord( var_0 );
    var_4 = getAwardRecordTime( var_0 );

    if ( !isdefined( var_3 ) || var_1 < var_3 )
    {
        clearAwardWinners( var_0 );
        addAwardWinner( var_0, self.clientid );
        setAwardRecord( var_0, var_1, var_2 );
    }
    else if ( var_1 == var_3 )
    {
        if ( isAwardExclusive( var_0 ) )
        {
            if ( !isdefined( var_4 ) || var_2 < var_4 )
            {
                clearAwardWinners( var_0 );
                addAwardWinner( var_0, self.clientid );
                setAwardRecord( var_0, var_1, var_2 );
            }
        }
        else
            addAwardWinner( var_0, self.clientid );
    }
}

getDecodedRatio( var_0 )
{
    var_1 = getRatioLoVal( var_0 );
    var_2 = getRatioHiVal( var_0 );

    if ( !var_1 )
        return var_2 + 0.001;

    return var_2 / var_1;
}

setPersonalBestIfGreater( var_0 )
{
    var_1 = self getplayerdata( "bests", var_0 );
    var_2 = maps\mp\_utility::getPlayerStat( var_0 );

    if ( var_1 == 0 || var_2 > var_1 )
    {
        var_2 = getFormattedValue( var_0, var_2 );
        self setplayerdata( "bests", var_0, var_2 );
    }
}

setPersonalBestIfLower( var_0 )
{
    var_1 = self getplayerdata( "bests", var_0 );
    var_2 = maps\mp\_utility::getPlayerStat( var_0 );

    if ( var_1 == 0 || var_2 < var_1 )
    {
        var_2 = getFormattedValue( var_0, var_2 );
        self setplayerdata( "bests", var_0, var_2 );
    }
}

incPlayerRecord( var_0 )
{
    var_1 = self getplayerdata( "awards", var_0 );
    self setplayerdata( "awards", var_0, var_1 + 1 );
}

addAwardWinner( var_0, var_1 )
{
    foreach ( var_3 in level.awards[var_0].winners )
    {
        if ( var_3 == var_1 )
            return;
    }

    level.awards[var_0].winners[level.awards[var_0].winners.size] = var_1;
}

getAwardWinners( var_0 )
{
    return level.awards[var_0].winners;
}

clearAwardWinners( var_0 )
{
    level.awards[var_0].winners = [];
}

setAwardRecord( var_0, var_1, var_2 )
{
    level.awards[var_0].value = var_1;
    level.awards[var_0].time = var_2;
}

getAwardRecord( var_0 )
{
    return level.awards[var_0].value;
}

getAwardRecordTime( var_0 )
{
    return level.awards[var_0].time;
}

assignAwards()
{
    foreach ( var_1 in level.players )
    {
        if ( !var_1 maps\mp\_utility::rankingEnabled() )
            return;

        var_2 = var_1 maps\mp\_utility::getPlayerStat( "kills" );
        var_3 = var_1 maps\mp\_utility::getPlayerStat( "deaths" );

        if ( var_3 == 0 )
            var_3 = 1;

        var_1 maps\mp\_utility::setPlayerStat( "kdratio", var_2 / var_3 );

        if ( isalive( var_1 ) )
        {
            var_4 = gettime() - var_1.spawnTime;
            var_1 maps\mp\_utility::setPlayerStatIfGreater( "longestlife", var_4 );
        }
    }

    foreach ( var_11, var_7 in level.awards )
    {
        if ( !isdefined( level.awards[var_11].process ) )
            continue;

        var_8 = level.awards[var_11].process;
        var_9 = level.awards[var_11].var1;
        var_10 = level.awards[var_11].var2;

        if ( isdefined( var_9 ) && isdefined( var_10 ) )
        {
            [[ var_8 ]]( var_11, var_9, var_10 );
            continue;
        }

        if ( isdefined( var_9 ) )
        {
            [[ var_8 ]]( var_11, var_9 );
            continue;
        }

        [[ var_8 ]]( var_11 );
    }

    foreach ( var_11, var_7 in level.awards )
    {
        if ( !isMultiAward( var_11 ) )
            continue;

        var_13 = level.awards[var_11].award1_ref;
        var_14 = level.awards[var_11].award2_ref;
        var_15 = getAwardWinners( var_13 );
        var_16 = getAwardWinners( var_14 );

        if ( !isdefined( var_15 ) || !isdefined( var_16 ) )
            continue;

        foreach ( var_18 in var_15 )
        {
            foreach ( var_20 in var_16 )
            {
                if ( var_18 == var_20 )
                {
                    addAwardWinner( var_11, var_18 );
                    var_1 = maps\mp\_utility::playerForClientId( var_18 );
                    var_21 = var_1 maps\mp\_utility::getPlayerStat( var_13 );
                    var_22 = var_1 maps\mp\_utility::getPlayerStat( var_14 );
                    var_1 maps\mp\_utility::setPlayerStat( var_11, encodeRatio( var_21, var_22 ) );
                }
            }
        }
    }

    foreach ( var_11, var_7 in level.awards )
    {
        if ( !isAwardFlag( var_11 ) )
            assignAward( var_11 );
    }

    foreach ( var_1 in level.players )
    {
        var_27 = var_1 getplayerdata( "round", "awardCount" );

        for ( var_28 = 0; var_28 < var_27 && var_28 < 3; var_28++ )
        {
            var_7 = var_1 getplayerdata( "round", "awards", var_28, "award" );
            var_29 = var_1 getplayerdata( "round", "awards", var_28, "value" );
        }
    }
}

assignAward( var_0 )
{
    var_1 = getAwardWinners( var_0 );

    if ( !isdefined( var_1 ) )
        return;

    foreach ( var_3 in var_1 )
    {
        foreach ( var_5 in level.players )
        {
            if ( var_5.clientid == var_3 )
                var_5 giveAward( var_0 );
        }
    }
}

getAwardType( var_0 )
{
    if ( isdefined( level.awards[var_0].type ) )
        return level.awards[var_0].type;
    else
        return "none";
}

isMultiAward( var_0 )
{
    return getAwardType( var_0 ) == "multi";
}

isStatAward( var_0 )
{
    return getAwardType( var_0 ) == "stat";
}

isThresholdAward( var_0 )
{
    return getAwardType( var_0 ) == "threshold";
}

isAwardFlag( var_0 )
{
    return getAwardType( var_0 ) == "flag";
}

isAwardExclusive( var_0 )
{
    if ( isdefined( level.awards[var_0].exclusive ) )
        return level.awards[var_0].exclusive;
    else
        return 1;
}

hasDisplayValue( var_0 )
{
    var_1 = getAwardType( var_0 );

    switch ( var_1 )
    {
        case "derived":
            var_2 = 0;
            break;
        case "multi":
        case "stat":
        default:
            var_2 = 1;
            break;
    }

    return var_2;
}

giveAward( var_0 )
{
    var_1 = self getplayerdata( "round", "awardCount" );
    incPlayerRecord( var_0 );

    if ( hasDisplayValue( var_0 ) )
    {
        if ( isStatAward( var_0 ) )
        {

        }

        var_2 = maps\mp\_utility::getPlayerStat( var_0 );
    }
    else
        var_2 = 1;

    var_2 = getFormattedValue( var_0, var_2 );

    if ( var_1 < 5 )
    {
        self setplayerdata( "round", "awards", var_1, "award", var_0 );
        self setplayerdata( "round", "awards", var_1, "value", var_2 );
    }

    var_1++;
    self setplayerdata( "round", "awardCount", var_1 );
    maps\mp\_matchdata::logAward( var_0 );

    if ( var_1 == 1 )
        maps\mp\_highlights::giveHighlight( var_0, var_2 );
}

getFormattedValue( var_0, var_1 )
{
    var_2 = tablelookup( "mp/awardTable.csv", 1, var_0, 7 );

    switch ( var_2 )
    {
        case "float":
            var_1 = maps\mp\_utility::limitDecimalPlaces( var_1, 2 );
            var_1 *= 100;
            break;
        case "distance":
        case "none":
        case "count":
        case "time":
        case "multi":
        case "ratio":
        default:
            break;
    }

    var_1 = int( var_1 );
    return var_1;
}

highestWins( var_0, var_1 )
{
    foreach ( var_3 in level.players )
    {
        if ( var_3 maps\mp\_utility::rankingEnabled() && var_3 statValueChanged( var_0 ) && ( !isdefined( var_1 ) || var_3 maps\mp\_utility::getPlayerStat( var_0 ) >= var_1 ) )
        {
            var_3 setMatchRecordIfGreater( var_0 );

            if ( !isAwardFlag( var_0 ) )
                var_3 setPersonalBestIfGreater( var_0 );
        }
    }
}

lowestWins( var_0, var_1 )
{
    foreach ( var_3 in level.players )
    {
        if ( var_3 maps\mp\_utility::rankingEnabled() && var_3 statValueChanged( var_0 ) && ( !isdefined( var_1 ) || var_3 maps\mp\_utility::getPlayerStat( var_0 ) <= var_1 ) )
        {
            var_3 setMatchRecordIfLower( var_0 );

            if ( !isAwardFlag( var_0 ) )
                var_3 setPersonalBestIfLower( var_0 );
        }
    }
}

lowestWithHalfPlayedTime( var_0 )
{
    var_1 = maps\mp\_utility::getTimePassed() / 1000;
    var_2 = var_1 * 0.5;

    foreach ( var_4 in level.players )
    {
        if ( var_4.hasSpawned && var_4.timePlayed["total"] >= var_2 )
        {
            var_4 setMatchRecordIfLower( var_0 );

            if ( !isAwardFlag( var_0 ) )
                var_4 setPersonalBestIfLower( var_0 );
        }
    }
}

statValueChanged( var_0 )
{
    var_1 = maps\mp\_utility::getPlayerStat( var_0 );
    var_2 = level.awards[var_0].defaultvalue;

    if ( var_1 == var_2 )
        return 0;
    else
        return 1;
}

isAtleast( var_0, var_1, var_2 )
{
    foreach ( var_4 in level.players )
    {
        var_5 = var_4 maps\mp\_utility::getPlayerStat( var_2 );
        var_6 = var_5;

        if ( var_6 >= var_1 )
            addAwardWinner( var_0, var_4.clientid );

        if ( isThresholdAward( var_0 ) || isAwardFlag( var_0 ) )
            var_4 maps\mp\_utility::setPlayerStat( var_0, var_5 );
    }
}

isAtMost( var_0, var_1, var_2 )
{
    foreach ( var_4 in level.players )
    {
        var_5 = var_4 maps\mp\_utility::getPlayerStat( var_2 );

        if ( var_5 <= var_1 )
            addAwardWinner( var_0, var_4.clientid );
    }
}

isAtMostWithHalfPlayedTime( var_0, var_1, var_2 )
{
    var_3 = maps\mp\_utility::getTimePassed() / 1000;
    var_4 = var_3 * 0.5;

    foreach ( var_6 in level.players )
    {
        if ( var_6.hasSpawned && var_6.timePlayed["total"] >= var_4 )
        {
            var_7 = var_6 maps\mp\_utility::getPlayerStat( var_2 );

            if ( var_7 <= var_1 )
                addAwardWinner( var_0, var_6.clientid );
        }
    }
}

setRatio( var_0, var_1, var_2 )
{
    foreach ( var_4 in level.players )
    {
        var_5 = var_4 maps\mp\_utility::getPlayerStat( var_1 );
        var_6 = var_4 maps\mp\_utility::getPlayerStat( var_2 );

        if ( var_6 == 0 )
        {
            var_4 maps\mp\_utility::setPlayerStat( var_0, var_5 );
            continue;
        }

        var_7 = var_5 / var_6;
        var_4 maps\mp\_utility::setPlayerStat( var_0, var_7 );
    }
}

getKillstreakAwardRef( var_0 )
{
    switch ( var_0 )
    {
        case "uav":
        case "double_uav":
        case "triple_uav":
        case "counter_uav":
        case "uav_support":
            return "uavs";
        case "precision_airstrike":
        case "stealth_airstrike":
        case "harrier_airstrike":
        case "airstrike":
        case "super_airstrike":
            return "airstrikes";
        case "helicopter":
        case "helicopter_flares":
        case "littlebird_flock":
        case "littlebird_support":
        case "helicopter_minigun":
        case "helicopter_mk19":
        case "helicopter_blackbox":
            return "helicopters";
        default:
            return undefined;
    }
}

monitorReloads()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "reload" );
        maps\mp\_utility::incPlayerStat( "mostreloads", 1 );
    }
}

monitorShotsFired()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "weapon_fired" );
        maps\mp\_utility::incPlayerStat( "mostshotsfired", 1 );
    }
}

monitorSwaps()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );
    var_0 = "none";

    for (;;)
    {
        self waittill( "weapon_change",  var_1  );

        if ( var_0 == var_1 )
            continue;

        if ( var_1 == "none" )
            continue;

        if ( !maps\mp\gametypes\_weapons::isPrimaryWeapon( var_1 ) )
            continue;

        var_0 = var_1;
        maps\mp\_utility::incPlayerStat( "mostswaps", 1 );
        var_2 = 0;

        foreach ( var_4 in self.usedWeapons )
        {
            if ( var_1 == var_4 )
            {
                var_2 = 1;
                break;
            }
        }

        if ( !var_2 )
        {
            self.usedWeapons[self.usedWeapons.size] = var_1;
            maps\mp\_utility::incPlayerStat( "mostweaponsused", 1 );
        }
    }
}

monitorMovementDistance()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
        foreach ( var_1 in level.players )
        {
            if ( !isalive( var_1 ) )
                continue;

            if ( var_1.deaths != var_1.previousDeaths )
            {
                var_1.prevPos = var_1.origin;
                var_1.previousDeaths = var_1.deaths;
            }

            var_2 = distance( var_1.origin, var_1.prevPos );
            var_1 maps\mp\_utility::incPlayerStat( "distancetraveled", var_2 );
            var_1.prevPos = var_1.origin;
            var_1.altitudePolls++;
            var_1.totalAltitudeSum = var_1.totalAltitudeSum + var_1.origin[2];
            var_3 = var_1.totalAltitudeSum / var_1.altitudePolls;
            var_1 maps\mp\_utility::setPlayerStat( "leastavgalt", var_3 );
            var_1 maps\mp\_utility::setPlayerStat( "greatestavgalt", var_3 );
            wait 0.05;
        }

        wait 0.05;
    }
}

monitorPositionCamping()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    self.lastCampChecked = gettime();
    self.positionArray = [];
    var_0 = 512;

    for (;;)
    {
        if ( !isalive( self ) )
        {
            wait 0.5;
            self.lastCampChecked = gettime();
            self.positionArray = [];
            continue;
        }

        self.positionArray[self.positionArray.size] = self.origin;

        if ( gettime() - self.lastCampChecked >= 15000 )
        {
            if ( distance( self.positionArray[0], self.origin ) < var_0 && distance( self.positionArray[1], self.positionArray[0] ) < var_0 )
            {
                var_1 = gettime() - self.lastCampChecked;
                maps\mp\_utility::incPlayerStat( "timeinspot", var_1 );
            }

            self.positionArray = [];
            self.lastCampChecked = gettime();
        }

        wait 5;
    }
}

encodeRatio( var_0, var_1 )
{
    return var_0 + ( var_1 << 16 );
}

getRatioHiVal( var_0 )
{
    return var_0 & 65535;
}

getRatioLoVal( var_0 )
{
    return var_0 >> 16;
}

monitorEnemyDistance()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    while ( level.players.size < 3 )
        wait 1;

    for (;;)
    {
        foreach ( var_1 in level.players )
        {
            if ( !isdefined( var_1 ) )
                continue;

            if ( var_1.team == "spectator" )
                continue;

            if ( !isalive( var_1 ) )
                continue;

            var_2 = sortbydistance( level.players, var_1.origin );

            if ( !var_2.size )
            {
                wait 0.05;
                continue;
            }

            if ( var_2.size < 2 )
            {
                wait 0.05;
                continue;
            }

            if ( var_2[1].team != var_1.team )
                var_1 maps\mp\_utility::incPlayerStat( "closertoenemies", 0.05 );

            wait 0.05;
        }

        wait 0.05;
    }
}

monitorExplosionsSurvived()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "survived_explosion",  var_0  );

        if ( isdefined( var_0 ) && isplayer( var_0 ) && self == var_0 )
            continue;

        maps\mp\_utility::incPlayerStat( "explosionssurvived", 1 );
        wait 0.05;
    }
}

monitorShieldBlocks()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "shield_blocked" );
        maps\mp\_utility::incPlayerStat( "shieldblocks", 1 );
        wait 0.05;
    }
}

monitorFlashHits()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "flash_hit" );
        maps\mp\_utility::incPlayerStat( "fbhits", 1 );
        wait 0.05;
    }
}

monitorStunHits()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "stun_hit" );
        maps\mp\_utility::incPlayerStat( "stunhits", 1 );
        wait 0.05;
    }
}

monitorStanceTime()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        if ( self getstance() == "crouch" )
            maps\mp\_utility::incPlayerStat( "crouchtime", 500 );
        else if ( self getstance() == "prone" )
            maps\mp\_utility::incPlayerStat( "pronetime", 500 );

        wait 0.5;
    }
}
