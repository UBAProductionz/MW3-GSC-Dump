// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( !isdefined( game["gamestarted"] ) )
    {
        setmatchdatadef( "mp/matchdata.def" );
        setmatchdata( "map", level.script );

        if ( level.hardcoreMode )
        {
            var_0 = level.gameType + " hc";
            setmatchdata( "gametype", var_0 );
        }
        else
            setmatchdata( "gametype", level.gameType );

        setmatchdata( "buildVersion", getbuildversion() );
        setmatchdata( "buildNumber", getbuildnumber() );
        setmatchdata( "dateTime", getsystemtime() );
        setmatchdataid();
    }

    level.MaxLives = 285;
    level.MaxNameLength = 26;
    level.MaxEvents = 150;
    level.MaxKillstreaks = 125;
    level.MaxLogClients = 30;
    level.MaxNumChallengesPerPlayer = 10;
    level.MaxNumAwardsPerPlayer = 10;
    level thread gameEndListener();
    level thread endOfGameSummaryLogger();
}

getMatchDateTime()
{
    return getmatchdata( "dateTime" );
}

logKillstreakEvent( var_0, var_1 )
{
    if ( !canLogClient( self ) || !canLogKillstreak() )
        return;

    var_2 = getmatchdata( "killstreakCount" );
    setmatchdata( "killstreakCount", var_2 + 1 );
    setmatchdata( "killstreaks", var_2, "eventType", var_0 );
    setmatchdata( "killstreaks", var_2, "player", self.clientid );
    setmatchdata( "killstreaks", var_2, "eventTime", gettime() );
    setmatchdata( "killstreaks", var_2, "eventPos", 0, int( var_1[0] ) );
    setmatchdata( "killstreaks", var_2, "eventPos", 1, int( var_1[1] ) );
    setmatchdata( "killstreaks", var_2, "eventPos", 2, int( var_1[2] ) );
}

logGameEvent( var_0, var_1 )
{
    if ( !canLogClient( self ) || !canLogEvent() )
        return;

    var_2 = getmatchdata( "eventCount" );
    setmatchdata( "eventCount", var_2 + 1 );
    setmatchdata( "events", var_2, "eventType", var_0 );
    setmatchdata( "events", var_2, "player", self.clientid );
    setmatchdata( "events", var_2, "eventTime", gettime() );
    setmatchdata( "events", var_2, "eventPos", 0, int( var_1[0] ) );
    setmatchdata( "events", var_2, "eventPos", 1, int( var_1[1] ) );
    setmatchdata( "events", var_2, "eventPos", 2, int( var_1[2] ) );
}

logKillEvent( var_0, var_1 )
{
    if ( !canLogLife( var_0 ) )
        return;

    setmatchdata( "lives", var_0, "modifiers", var_1, 1 );
}

logMultiKill( var_0, var_1 )
{
    if ( !canLogLife( var_0 ) )
        return;

    setmatchdata( "lives", var_0, "multikill", var_1 );
}

logPlayerLife( var_0 )
{
    if ( !canLogClient( self ) || !canLogLife( var_0 ) )
        return;

    setmatchdata( "lives", var_0, "player", self.clientid );
    setmatchdata( "lives", var_0, "spawnPos", 0, int( self.spawnPos[0] ) );
    setmatchdata( "lives", var_0, "spawnPos", 1, int( self.spawnPos[1] ) );
    setmatchdata( "lives", var_0, "spawnPos", 2, int( self.spawnPos[2] ) );
    setmatchdata( "lives", var_0, "wasTacticalInsertion", self.wasTI );
    setmatchdata( "lives", var_0, "team", self.team );
    setmatchdata( "lives", var_0, "spawnTime", self.spawnTime );
    setmatchdata( "lives", var_0, "duration", gettime() - self.spawnTime );
    logLoadout( var_0 );
}

logPlayerXP( var_0, var_1 )
{
    if ( !canLogClient( self ) )
        return;

    setmatchdata( "players", self.clientid, var_1, var_0 );
}

logLoadout( var_0 )
{
    if ( !canLogClient( self ) || !canLogLife( var_0 ) || self.curClass == "gamemode" )
        return;

    var_1 = self.curClass;

    if ( var_1 == "copycat" )
    {
        var_2 = self.pers["copyCatLoadout"];
        var_3 = var_2["loadoutPrimary"];
        var_4 = var_2["loadoutPrimaryAttachment"];
        var_5 = var_2["loadoutPrimaryAttachment2"];
        var_6 = var_2["loadoutPrimaryCamo"];
        var_7 = var_2["loadoutPrimaryBuff"];
        var_8 = var_2["loadoutSecondary"];
        var_9 = var_2["loadoutSecondaryAttachment"];
        var_10 = var_2["loadoutSecondaryAttachment2"];
        var_11 = var_2["loadoutSecondaryCamo"];
        var_12 = var_2["loadoutSecondaryBuff"];
        var_13 = var_2["loadoutEquipment"];
        var_14 = var_2["loadoutPerk1"];
        var_15 = var_2["loadoutPerk2"];
        var_16 = var_2["loadoutPerk3"];
        var_17 = var_2["loadoutOffhand"];
        var_18 = var_2["loadoutDeathstreak"];
        var_19 = var_2["loadoutStreakType"];
        var_20 = var_2["loadoutKillstreak1"];
        var_21 = var_2["loadoutKillstreak2"];
        var_22 = var_2["loadoutKillstreak3"];
    }
    else if ( issubstr( var_1, "custom" ) )
    {
        var_23 = maps\mp\gametypes\_class::getClassIndex( var_1 );
        var_3 = maps\mp\gametypes\_class::cac_getWeapon( var_23, 0 );
        var_4 = maps\mp\gametypes\_class::cac_getWeaponAttachment( var_23, 0 );
        var_5 = maps\mp\gametypes\_class::cac_getWeaponAttachmentTwo( var_23, 0 );
        var_8 = maps\mp\gametypes\_class::cac_getWeapon( var_23, 1 );
        var_9 = maps\mp\gametypes\_class::cac_getWeaponAttachment( var_23, 1 );
        var_10 = maps\mp\gametypes\_class::cac_getWeaponAttachmentTwo( var_23, 1 );
        var_17 = maps\mp\gametypes\_class::cac_getOffhand( var_23 );
        var_13 = maps\mp\gametypes\_class::cac_getPerk( var_23, 0 );
        var_14 = maps\mp\gametypes\_class::cac_getPerk( var_23, 1 );
        var_15 = maps\mp\gametypes\_class::cac_getPerk( var_23, 2 );
        var_16 = maps\mp\gametypes\_class::cac_getPerk( var_23, 3 );
        var_19 = maps\mp\gametypes\_class::cac_getPerk( var_23, 5 );
        var_18 = maps\mp\gametypes\_class::cac_getDeathstreak( var_23 );
        var_7 = maps\mp\gametypes\_class::cac_getWeaponBuff( var_23, 0 );
        var_12 = maps\mp\gametypes\_class::cac_getWeaponBuff( var_23, 1 );
        var_20 = maps\mp\gametypes\_class::cac_getKillstreak( var_23, var_19, 0 );
        var_21 = maps\mp\gametypes\_class::cac_getKillstreak( var_23, var_19, 1 );
        var_22 = maps\mp\gametypes\_class::cac_getKillstreak( var_23, var_19, 2 );
    }
    else
    {
        var_23 = maps\mp\gametypes\_class::getClassIndex( var_1 );
        var_3 = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, var_23, 0 );
        var_4 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, var_23, 0, 0 );
        var_5 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, var_23, 0, 1 );
        var_8 = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, var_23, 1 );
        var_9 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, var_23, 1, 0 );
        var_10 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, var_23, 1, 1 );
        var_17 = maps\mp\gametypes\_class::table_getOffhand( level.classTableName, var_23 );
        var_13 = maps\mp\gametypes\_class::table_getEquipment( level.classTableName, var_23, 0 );
        var_14 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, var_23, 1 );
        var_15 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, var_23, 2 );
        var_16 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, var_23, 3 );
        var_19 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, var_23, 5 );
        var_18 = maps\mp\gametypes\_class::table_getDeathstreak( level.classTableName, var_23 );
        var_7 = maps\mp\gametypes\_class::table_getWeaponBuff( level.classTableName, var_23, 0 );
        var_12 = maps\mp\gametypes\_class::table_getWeaponBuff( level.classTableName, var_23, 1 );
        var_20 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, var_23, 1 );
        var_21 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, var_23, 2 );
        var_22 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, var_23, 3 );
    }

    var_4 = maps\mp\_utility::validateAttachment( var_4 );
    var_5 = maps\mp\_utility::validateAttachment( var_5 );
    var_9 = maps\mp\_utility::validateAttachment( var_9 );
    var_10 = maps\mp\_utility::validateAttachment( var_10 );
    setmatchdata( "lives", var_0, "primaryWeapon", var_3 );
    setmatchdata( "lives", var_0, "primaryAttachments", 0, var_4 );
    setmatchdata( "lives", var_0, "primaryAttachments", 1, var_5 );
    setmatchdata( "lives", var_0, "secondaryWeapon", var_8 );
    setmatchdata( "lives", var_0, "secondaryAttachments", 0, var_9 );
    setmatchdata( "lives", var_0, "secondaryAttachments", 1, var_9 );
    setmatchdata( "lives", var_0, "offhandWeapon", var_17 );
    setmatchdata( "lives", var_0, "equipment", var_13 );
    setmatchdata( "lives", var_0, "perks", 0, var_14 );
    setmatchdata( "lives", var_0, "perks", 1, var_15 );
    setmatchdata( "lives", var_0, "perks", 2, var_16 );
    setmatchdata( "lives", var_0, "strikePackage", var_19 );
    setmatchdata( "lives", var_0, "deathstreak", var_18 );
    setmatchdata( "lives", var_0, "weaponBuff", 0, var_7 );
    setmatchdata( "lives", var_0, "weaponBuff", 1, var_12 );

    switch ( var_19 )
    {
        case "streaktype_assault":
            setmatchdata( "lives", var_0, "assaultStreaks", 0, var_20 );
            setmatchdata( "lives", var_0, "assaultStreaks", 1, var_21 );
            setmatchdata( "lives", var_0, "assaultStreaks", 2, var_22 );
            break;
        case "streaktype_support":
            setmatchdata( "lives", var_0, "defenseStreaks", 0, var_20 );
            setmatchdata( "lives", var_0, "defenseStreaks", 1, var_21 );
            setmatchdata( "lives", var_0, "defenseStreaks", 2, var_22 );
            break;
        case "streaktype_specialist":
            setmatchdata( "lives", var_0, "specialistStreaks", 0, var_20 );
            setmatchdata( "lives", var_0, "specialistStreaks", 1, var_21 );
            setmatchdata( "lives", var_0, "specialistStreaks", 2, var_22 );
            break;
        case "none":
            break;
    }
}

logPlayerDeath( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    if ( !canLogClient( self ) || isplayer( var_1 ) && !canLogClient( var_1 ) || !canLogLife( var_0 ) )
        return;

    if ( var_0 >= level.MaxLives )
        return;

    if ( var_4 == "none" )
    {
        var_7 = "none";
        var_8 = "none";
    }
    else
    {
        var_7 = weaponinventorytype( var_4 );
        var_8 = weaponclass( var_4 );
    }

    if ( issubstr( var_4, "destructible" ) )
        var_4 = "destructible";

    if ( isdefined( var_7 ) && ( var_7 == "primary" || var_7 == "altmode" ) && ( var_8 == "pistol" || var_8 == "smg" || var_8 == "rifle" || var_8 == "spread" || var_8 == "mg" || var_8 == "grenade" || var_8 == "rocketlauncher" || var_8 == "sniper" ) )
    {
        var_9 = undefined;

        if ( var_7 == "altmode" )
        {
            var_9 = var_4;
            var_4 = var_5;
            setmatchdata( "lives", var_0, "altMode", 1 );
        }

        var_10 = strtok( var_4, "_" );

        if ( var_10[0] == "iw5" )
        {
            var_15 = var_10[0] + "_" + var_10[1];
            setmatchdata( "lives", var_0, "weapon", var_15 );

            if ( isdefined( var_10[3] ) && issubstr( var_10[3], "scope" ) && issubstr( var_10[3], "vz" ) )
                var_10[3] = "vzscope";

            if ( isdefined( var_10[4] ) && issubstr( var_10[4], "scope" ) && issubstr( var_10[4], "vz" ) )
                var_10[4] = "vzscope";

            if ( isdefined( var_10[3] ) && issubstr( var_10[3], "scope" ) && !issubstr( var_10[3], "vz" ) )
                var_10[3] = undefined;

            if ( isdefined( var_10[4] ) && issubstr( var_10[4], "scope" ) && !issubstr( var_10[4], "vz" ) )
                var_10[4] = undefined;

            if ( isdefined( var_10[3] ) && maps\mp\_utility::isAttachment( var_10[3] ) )
            {
                var_16 = maps\mp\_utility::validateAttachment( var_10[3] );
                setmatchdata( "lives", var_0, "attachments", 0, var_16 );
            }

            if ( isdefined( var_10[4] ) && maps\mp\_utility::isAttachment( var_10[4] ) )
            {
                var_16 = maps\mp\_utility::validateAttachment( var_10[4] );
                setmatchdata( "lives", var_0, "attachments", 1, var_16 );
            }
        }
        else if ( var_10[0] == "alt" )
        {
            var_15 = var_10[1] + "_" + var_10[2];
            setmatchdata( "lives", var_0, "weapon", var_15 );

            if ( isdefined( var_10[4] ) && maps\mp\_utility::isAttachment( var_10[4] ) )
            {
                var_16 = maps\mp\_utility::validateAttachment( var_10[4] );
                setmatchdata( "lives", var_0, "attachments", 0, var_16 );
            }

            if ( isdefined( var_10[5] ) && maps\mp\_utility::isAttachment( var_10[5] ) )
            {
                var_16 = maps\mp\_utility::validateAttachment( var_10[5] );
                setmatchdata( "lives", var_0, "attachments", 1, var_16 );
            }
        }
        else
        {
            var_10[var_10.size - 1] = undefined;
            setmatchdata( "lives", var_0, "weapon", var_10[0] );

            if ( isdefined( var_10[1] ) && var_7 != "altmode" )
            {
                var_16 = maps\mp\_utility::validateAttachment( var_10[1] );
                setmatchdata( "lives", var_0, "attachments", 0, var_16 );
            }

            if ( isdefined( var_10[2] ) && var_7 != "altmode" )
            {
                var_16 = maps\mp\_utility::validateAttachment( var_10[2] );
                setmatchdata( "lives", var_0, "attachments", 1, var_16 );
            }
        }
    }
    else if ( var_7 == "item" || var_7 == "offhand" )
    {
        var_17 = maps\mp\_utility::strip_suffix( var_4, "_mp" );
        setmatchdata( "lives", var_0, "weapon", var_17 );
    }
    else
        setmatchdata( "lives", var_0, "weapon", var_4 );

    if ( maps\mp\_utility::isKillstreakWeapon( var_4 ) )
        setmatchdata( "lives", var_0, "modifiers", "killstreak", 1 );

    setmatchdata( "lives", var_0, "mod", var_3 );

    if ( isplayer( var_1 ) )
    {
        setmatchdata( "lives", var_0, "attacker", var_1.clientid );
        setmatchdata( "lives", var_0, "attackerPos", 0, int( var_1.origin[0] ) );
        setmatchdata( "lives", var_0, "attackerPos", 1, int( var_1.origin[1] ) );
        setmatchdata( "lives", var_0, "attackerPos", 2, int( var_1.origin[2] ) );
        var_18 = anglestoforward( ( 0, self.angles[1], 0 ) );
        var_19 = self.origin - var_1.origin;
        var_19 = vectornormalize( ( var_19[0], var_19[1], 0 ) );
        setmatchdata( "lives", var_0, "dotOfDeath", vectordot( var_18, var_19 ) );

        if ( var_1 maps\mp\_utility::isJuggernaut() )
            setmatchdata( "lives", var_0, "attackerIsJuggernaut", 1 );
    }
    else
    {
        setmatchdata( "lives", var_0, "attacker", 255 );
        setmatchdata( "lives", var_0, "attackerPos", 0, int( self.origin[0] ) );
        setmatchdata( "lives", var_0, "attackerPos", 1, int( self.origin[1] ) );
        setmatchdata( "lives", var_0, "attackerPos", 2, int( self.origin[2] ) );
    }

    setmatchdata( "lives", var_0, "player", self.clientid );
    setmatchdata( "lives", var_0, "deathPos", 0, int( self.origin[0] ) );
    setmatchdata( "lives", var_0, "deathPos", 1, int( self.origin[1] ) );
    setmatchdata( "lives", var_0, "deathPos", 2, int( self.origin[2] ) );
    setmatchdata( "lives", var_0, "deathAngles", 0, int( self.angles[0] ) );
    setmatchdata( "lives", var_0, "deathAngles", 1, int( self.angles[1] ) );
    setmatchdata( "lives", var_0, "deathAngles", 2, int( self.angles[2] ) );
}

logPlayerData()
{
    if ( !canLogClient( self ) )
        return;

    setmatchdata( "players", self.clientid, "score", maps\mp\_utility::getPersStat( "score" ) );

    if ( maps\mp\_utility::getPersStat( "assists" ) > 255 )
        setmatchdata( "players", self.clientid, "assists", 255 );
    else
        setmatchdata( "players", self.clientid, "assists", maps\mp\_utility::getPersStat( "assists" ) );

    if ( maps\mp\_utility::getPersStat( "longestStreak" ) > 255 )
        setmatchdata( "players", self.clientid, "longestStreak", 255 );
    else
        setmatchdata( "players", self.clientid, "longestStreak", maps\mp\_utility::getPersStat( "longestStreak" ) );
}

endOfGameSummaryLogger()
{
    level waittill( "game_ended" );

    foreach ( var_1 in level.players )
    {
        wait 0.05;

        if ( !isdefined( var_1 ) )
            continue;

        if ( isdefined( var_1.weaponsUsed ) )
        {
            var_1 doubleBubbleSort();
            var_2 = 0;

            if ( var_1.weaponsUsed.size > 3 )
            {
                for ( var_3 = var_1.weaponsUsed.size - 1; var_3 > var_1.weaponsUsed.size - 3; var_3-- )
                {
                    var_1 setplayerdata( "round", "weaponsUsed", var_2, var_1.weaponsUsed[var_3] );
                    var_1 setplayerdata( "round", "weaponXpEarned", var_2, var_1.weaponXpEarned[var_3] );
                    var_2++;
                }
            }
            else
            {
                for ( var_3 = var_1.weaponsUsed.size - 1; var_3 >= 0; var_3-- )
                {
                    var_1 setplayerdata( "round", "weaponsUsed", var_2, var_1.weaponsUsed[var_3] );
                    var_1 setplayerdata( "round", "weaponXpEarned", var_2, var_1.weaponXpEarned[var_3] );
                    var_2++;
                }
            }
        }
        else
        {
            var_1 setplayerdata( "round", "weaponsUsed", 0, "none" );
            var_1 setplayerdata( "round", "weaponsUsed", 1, "none" );
            var_1 setplayerdata( "round", "weaponsUsed", 2, "none" );
            var_1 setplayerdata( "round", "weaponXpEarned", 0, 0 );
            var_1 setplayerdata( "round", "weaponXpEarned", 1, 0 );
            var_1 setplayerdata( "round", "weaponXpEarned", 2, 0 );
        }

        if ( isdefined( var_1.challengesCompleted ) )
            var_1 setplayerdata( "round", "challengeNumCompleted", var_1.challengesCompleted.size );
        else
            var_1 setplayerdata( "round", "challengeNumCompleted", 0 );

        for ( var_3 = 0; var_3 < 20; var_3++ )
        {
            if ( isdefined( var_1.challengesCompleted ) && isdefined( var_1.challengesCompleted[var_3] ) && var_1.challengesCompleted[var_3] != "ch_prestige" && !issubstr( var_1.challengesCompleted[var_3], "_daily" ) && !issubstr( var_1.challengesCompleted[var_3], "_weekly" ) )
            {
                var_1 setplayerdata( "round", "challengesCompleted", var_3, var_1.challengesCompleted[var_3] );
                continue;
            }

            var_1 setplayerdata( "round", "challengesCompleted", var_3, "" );
        }
    }
}

doubleBubbleSort()
{
    var_0 = self.weaponXpEarned;
    var_1 = self.weaponXpEarned.size;

    for ( var_2 = var_1 - 1; var_2 > 0; var_2-- )
    {
        for ( var_3 = 1; var_3 <= var_2; var_3++ )
        {
            if ( var_0[var_3 - 1] < var_0[var_3] )
            {
                var_4 = self.weaponsUsed[var_3];
                self.weaponsUsed[var_3] = self.weaponsUsed[var_3 - 1];
                self.weaponsUsed[var_3 - 1] = var_4;
                var_5 = self.weaponXpEarned[var_3];
                self.weaponXpEarned[var_3] = self.weaponXpEarned[var_3 - 1];
                self.weaponXpEarned[var_3 - 1] = var_5;
                var_0 = self.weaponXpEarned;
            }
        }
    }
}

gameEndListener()
{
    level waittill( "game_ended" );

    foreach ( var_1 in level.players )
    {
        var_1 logPlayerData();

        if ( !isalive( var_1 ) )
            continue;

        var_2 = maps\mp\_utility::getNextLifeId();
        var_1 logPlayerLife( var_2 );
    }
}

canLogClient( var_0 )
{
    return var_0.clientid < level.MaxLogClients;
}

canLogEvent()
{
    return getmatchdata( "eventCount" ) < level.MaxEvents;
}

canLogKillstreak()
{
    return getmatchdata( "killstreakCount" ) < level.MaxKillstreaks;
}

canLogLife( var_0 )
{
    return getmatchdata( "lifeCount" ) < level.MaxLives;
}

logWeaponStat( var_0, var_1, var_2 )
{
    if ( !canLogClient( self ) )
        return;

    if ( maps\mp\_utility::isKillstreakWeapon( var_0 ) )
        return;

    var_3 = getmatchdata( "players", self.clientid, "weaponStats", var_0, var_1 );

    if ( var_1 == "kills" || var_1 == "deaths" || var_1 == "headShots" )
    {
        if ( var_3 + var_2 > 255 )
            setmatchdata( "players", self.clientid, "weaponStats", var_0, var_1, 255 );
        else
            setmatchdata( "players", self.clientid, "weaponStats", var_0, var_1, var_3 + var_2 );
    }

    setmatchdata( "players", self.clientid, "weaponStats", var_0, var_1, var_3 + var_2 );
}

logAttachmentStat( var_0, var_1, var_2 )
{
    if ( !canLogClient( self ) )
        return;

    var_3 = getmatchdata( "players", self.clientid, "attachmentsStats", var_0, var_1 );
    setmatchdata( "players", self.clientid, "attachmentsStats", var_0, var_1, var_3 + var_2 );
}

buildBaseWeaponList()
{
    var_0 = [];
    var_1 = 149;

    for ( var_2 = 0; var_2 <= var_1; var_2++ )
    {
        var_3 = tablelookup( "mp/statstable.csv", 0, var_2, 4 );

        if ( var_3 == "" )
            continue;

        if ( !issubstr( tablelookup( "mp/statsTable.csv", 0, var_2, 2 ), "weapon_" ) )
            continue;

        if ( tablelookup( "mp/statsTable.csv", 0, var_2, 2 ) == "weapon_other" )
            continue;

        var_0[var_0.size] = var_3;
    }

    return var_0;
}

logChallenge( var_0, var_1 )
{
    if ( !canLogClient( self ) )
        return;

    if ( issubstr( var_0, "_daily" ) || issubstr( var_0, "_weekly" ) )
        return;

    var_2 = getmatchdata( "players", self.clientid, "challengeCount" );

    if ( var_2 < level.MaxNumChallengesPerPlayer )
    {
        setmatchdata( "players", self.clientid, "challenge", var_2, var_0 );
        setmatchdata( "players", self.clientid, "tier", var_2, var_1 );
        setmatchdata( "players", self.clientid, "challengeCount", var_2 + 1 );
    }
}

logAward( var_0 )
{
    if ( !canLogClient( self ) )
        return;

    var_1 = getmatchdata( "players", self.clientid, "awardCount" );

    if ( var_1 < level.MaxNumAwardsPerPlayer )
    {
        setmatchdata( "players", self.clientid, "awards", var_1, var_0 );
        setmatchdata( "players", self.clientid, "awardCount", var_1 + 1 );
    }
}

logKillsConfirmed()
{
    if ( !canLogClient( self ) )
        return;

    setmatchdata( "players", self.clientid, "killsConfirmed", self.pers["confirmed"] );
}

logKillsDenied()
{
    if ( !canLogClient( self ) )
        return;

    setmatchdata( "players", self.clientid, "killsDenied", self.pers["denied"] );
}
