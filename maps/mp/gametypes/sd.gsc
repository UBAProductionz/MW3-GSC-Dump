// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    if ( getdvar( "mapname" ) == "mp_background" )
        return;

    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::SetupCallbacks();
    maps\mp\gametypes\_globallogic::SetupCallbacks();

    if ( isusingmatchrulesdata() )
    {
        level.initializeMatchRules = ::initializeMatchRules;
        [[ level.initializeMatchRules ]]();
        level thread maps\mp\_utility::reInitializeMatchRulesOnMigration();
    }
    else
    {
        maps\mp\_utility::registerRoundSwitchDvar( level.gameType, 3, 0, 9 );
        maps\mp\_utility::registerTimeLimitDvar( level.gameType, 2.5 );
        maps\mp\_utility::registerScoreLimitDvar( level.gameType, 1 );
        maps\mp\_utility::registerRoundLimitDvar( level.gameType, 0 );
        maps\mp\_utility::registerWinLimitDvar( level.gameType, 4 );
        maps\mp\_utility::registerNumLivesDvar( level.gameType, 1 );
        maps\mp\_utility::registerHalfTimeDvar( level.gameType, 0 );
        level.matchRules_damageMultiplier = 0;
        level.matchRules_vampirism = 0;
    }

    level.objectiveBased = 1;
    level.teamBased = 1;
    level.onPrecacheGameType = ::onPrecacheGameType;
    level.onStartGameType = ::onStartGameType;
    level.getSpawnPoint = ::getSpawnPoint;
    level.onSpawnPlayer = ::onSpawnPlayer;
    level.onPlayerKilled = ::onPlayerKilled;
    level.onDeadEvent = ::onDeadEvent;
    level.onOneLeftEvent = ::onOneLeftEvent;
    level.onTimeLimit = ::onTimeLimit;
    level.onNormalDeath = ::onNormalDeath;
    level.initGametypeAwards = ::initGametypeAwards;

    if ( level.matchRules_damageMultiplier || level.matchRules_vampirism )
        level.modifyPlayerDamage = maps\mp\gametypes\_damage::gamemodeModifyPlayerDamage;

    game["dialog"]["gametype"] = "searchdestroy";

    if ( getdvarint( "g_hardcore" ) )
        game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
    else if ( getdvarint( "camera_thirdPerson" ) )
        game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
    else if ( getdvarint( "scr_diehard" ) )
        game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
    else if ( getdvarint( "scr_" + level.gameType + "_promode" ) )
        game["dialog"]["gametype"] += "_pro";

    game["dialog"]["offense_obj"] = "obj_destroy";
    game["dialog"]["defense_obj"] = "obj_defend";
    makedvarserverinfo( "ui_bomb_timer_endtime", -1 );
}

initializeMatchRules()
{
    maps\mp\_utility::setCommonRulesFromMatchRulesData();
    var_0 = getmatchrulesdata( "sdData", "roundLength" );
    setdynamicdvar( "scr_sd_timelimit", var_0 );
    maps\mp\_utility::registerTimeLimitDvar( "sd", var_0 );
    var_1 = getmatchrulesdata( "sdData", "roundSwitch" );
    setdynamicdvar( "scr_sd_roundswitch", var_1 );
    maps\mp\_utility::registerRoundSwitchDvar( "sd", var_1, 0, 9 );
    var_2 = getmatchrulesdata( "commonOption", "scoreLimit" );
    setdynamicdvar( "scr_sd_winlimit", var_2 );
    maps\mp\_utility::registerWinLimitDvar( "sd", var_2 );
    setdynamicdvar( "scr_sd_bombtimer", getmatchrulesdata( "sdData", "bombTimer" ) );
    setdynamicdvar( "scr_sd_planttime", getmatchrulesdata( "sdData", "plantTime" ) );
    setdynamicdvar( "scr_sd_defusetime", getmatchrulesdata( "sdData", "defuseTime" ) );
    setdynamicdvar( "scr_sd_multibomb", getmatchrulesdata( "sdData", "multiBomb" ) );
    setdynamicdvar( "scr_sd_roundlimit", 0 );
    maps\mp\_utility::registerRoundLimitDvar( "sd", 0 );
    setdynamicdvar( "scr_sd_scorelimit", 1 );
    maps\mp\_utility::registerScoreLimitDvar( "sd", 1 );
    setdynamicdvar( "scr_sd_halftime", 0 );
    maps\mp\_utility::registerHalfTimeDvar( "sd", 0 );
    setdynamicdvar( "scr_sd_promode", 0 );
}

onPrecacheGameType()
{
    game["bomb_dropped_sound"] = "mp_war_objective_lost";
    game["bomb_recovered_sound"] = "mp_war_objective_taken";
    precacheshader( "waypoint_bomb" );
    precacheshader( "hud_suitcase_bomb" );
    precacheshader( "waypoint_target" );
    precacheshader( "waypoint_target_a" );
    precacheshader( "waypoint_target_b" );
    precacheshader( "waypoint_defend" );
    precacheshader( "waypoint_defend_a" );
    precacheshader( "waypoint_defend_b" );
    precacheshader( "waypoint_defuse" );
    precacheshader( "waypoint_defuse_a" );
    precacheshader( "waypoint_defuse_b" );
    precacheshader( "waypoint_escort" );
    precachestring( &"MP_EXPLOSIVES_RECOVERED_BY" );
    precachestring( &"MP_EXPLOSIVES_DROPPED_BY" );
    precachestring( &"MP_EXPLOSIVES_PLANTED_BY" );
    precachestring( &"MP_EXPLOSIVES_DEFUSED_BY" );
    precachestring( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
    precachestring( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
    precachestring( &"MP_CANT_PLANT_WITHOUT_BOMB" );
    precachestring( &"MP_PLANTING_EXPLOSIVE" );
    precachestring( &"MP_DEFUSING_EXPLOSIVE" );
}

onStartGameType()
{
    if ( !isdefined( game["switchedsides"] ) )
        game["switchedsides"] = 0;

    if ( game["switchedsides"] )
    {
        var_0 = game["attackers"];
        var_1 = game["defenders"];
        game["attackers"] = var_1;
        game["defenders"] = var_0;
    }

    setclientnamemode( "manual_change" );
    game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED";
    game["strings"]["bomb_defused"] = &"MP_BOMB_DEFUSED";
    precachestring( game["strings"]["target_destroyed"] );
    precachestring( game["strings"]["bomb_defused"] );
    level._effect["bombexplosion"] = loadfx( "explosions/tanker_explosion" );
    maps\mp\_utility::setObjectiveText( game["attackers"], &"OBJECTIVES_SD_ATTACKER" );
    maps\mp\_utility::setObjectiveText( game["defenders"], &"OBJECTIVES_SD_DEFENDER" );

    if ( level.splitscreen )
    {
        maps\mp\_utility::setObjectiveScoreText( game["attackers"], &"OBJECTIVES_SD_ATTACKER" );
        maps\mp\_utility::setObjectiveScoreText( game["defenders"], &"OBJECTIVES_SD_DEFENDER" );
    }
    else
    {
        maps\mp\_utility::setObjectiveScoreText( game["attackers"], &"OBJECTIVES_SD_ATTACKER_SCORE" );
        maps\mp\_utility::setObjectiveScoreText( game["defenders"], &"OBJECTIVES_SD_DEFENDER_SCORE" );
    }

    maps\mp\_utility::setObjectiveHintText( game["attackers"], &"OBJECTIVES_SD_ATTACKER_HINT" );
    maps\mp\_utility::setObjectiveHintText( game["defenders"], &"OBJECTIVES_SD_DEFENDER_HINT" );
    level.spawnMins = ( 0, 0, 0 );
    level.spawnMaxs = ( 0, 0, 0 );
    maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_attacker" );
    maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_defender" );
    level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
    setmapcenter( level.mapCenter );
    var_2[0] = "sd";
    var_2[1] = "bombzone";
    var_2[2] = "blocker";
    maps\mp\gametypes\_gameobjects::main( var_2 );
    maps\mp\gametypes\_rank::registerScoreInfo( "win", 2 );
    maps\mp\gametypes\_rank::registerScoreInfo( "loss", 1 );
    maps\mp\gametypes\_rank::registerScoreInfo( "tie", 1.5 );
    maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
    maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
    maps\mp\gametypes\_rank::registerScoreInfo( "plant", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "defuse", 100 );
    thread updateGametypeDvars();
    setSpecialLoadout();
    thread bombs();
}

getSpawnPoint()
{
    if ( self.pers["team"] == game["attackers"] )
        var_0 = "mp_sd_spawn_attacker";
    else
        var_0 = "mp_sd_spawn_defender";

    var_1 = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( var_0 );
    var_2 = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( var_1 );
    return var_2;
}

onSpawnPlayer()
{
    self.isPlanting = 0;
    self.isDefusing = 0;
    self.isBombCarrier = 0;

    if ( level.multiBomb && !isdefined( self.carryIcon ) && self.pers["team"] == game["attackers"] && !level.bombPlanted )
    {
        if ( level.splitscreen )
        {
            self.carryIcon = maps\mp\gametypes\_hud_util::createIcon( "hud_suitcase_bomb", 33, 33 );
            self.carryIcon maps\mp\gametypes\_hud_util::setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", -50, -78 );
            self.carryIcon.alpha = 0.75;
        }
        else
        {
            self.carryIcon = maps\mp\gametypes\_hud_util::createIcon( "hud_suitcase_bomb", 50, 50 );
            self.carryIcon maps\mp\gametypes\_hud_util::setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", -50, -65 );
            self.carryIcon.alpha = 0.75;
        }

        self.carryIcon.hidewheninmenu = 1;
        thread hideCarryIconOnGameEnd();
    }

    level notify( "spawned_player" );
}

hideCarryIconOnGameEnd()
{
    self endon( "disconnect" );
    level waittill( "game_ended" );

    if ( isdefined( self.carryIcon ) )
        self.carryIcon.alpha = 0;
}

onPlayerKilled( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    thread checkAllowSpectating();
}

checkAllowSpectating()
{
    wait 0.05;
    var_0 = 0;

    if ( !level.aliveCount[game["attackers"]] )
    {
        level.spectateOverride[game["attackers"]].allowEnemySpectate = 1;
        var_0 = 1;
    }

    if ( !level.aliveCount[game["defenders"]] )
    {
        level.spectateOverride[game["defenders"]].allowEnemySpectate = 1;
        var_0 = 1;
    }

    if ( var_0 )
        maps\mp\gametypes\_spectating::updateSpectateSettings();
}

sd_endGame( var_0, var_1 )
{
    level.finalKillCam_winner = var_0;

    if ( var_1 == game["strings"]["target_destroyed"] || var_1 == game["strings"]["bomb_defused"] )
    {
        var_2 = 1;

        foreach ( var_4 in level.bombZones )
        {
            if ( isdefined( level.finalKillCam_killCamEntityIndex[var_0] ) && level.finalKillCam_killCamEntityIndex[var_0] == var_4.killCamEntNum )
            {
                var_2 = 0;
                break;
            }
        }

        if ( var_2 )
            maps\mp\gametypes\_damage::eraseFinalKillCam();
    }

    thread maps\mp\gametypes\_gamelogic::endGame( var_0, var_1 );
}

onDeadEvent( var_0 )
{
    if ( level.bombexploded || level.bombDefused )
        return;

    if ( var_0 == "all" )
    {
        if ( level.bombPlanted )
            sd_endGame( game["attackers"], game["strings"][game["defenders"] + "_eliminated"] );
        else
            sd_endGame( game["defenders"], game["strings"][game["attackers"] + "_eliminated"] );
    }
    else if ( var_0 == game["attackers"] )
    {
        if ( level.bombPlanted )
            return;

        level thread sd_endGame( game["defenders"], game["strings"][game["attackers"] + "_eliminated"] );
    }
    else if ( var_0 == game["defenders"] )
        level thread sd_endGame( game["attackers"], game["strings"][game["defenders"] + "_eliminated"] );
}

onOneLeftEvent( var_0 )
{
    if ( level.bombexploded || level.bombDefused )
        return;

    var_1 = maps\mp\_utility::getLastLivingPlayer( var_0 );
    var_1 thread giveLastOnTeamWarning();
}

onNormalDeath( var_0, var_1, var_2 )
{
    var_3 = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
    var_4 = var_0.team;

    if ( game["state"] == "postgame" && ( var_0.team == game["defenders"] || !level.bombPlanted ) )
        var_1.finalKill = 1;

    if ( var_0.isPlanting )
    {
        thread maps\mp\_matchdata::logKillEvent( var_2, "planting" );
        var_1 maps\mp\_utility::incPersStat( "defends", 1 );
        var_1 maps\mp\gametypes\_persistence::statSetChild( "round", "defends", var_1.pers["defends"] );
    }
    else if ( var_0.isBombCarrier )
    {
        var_1 maps\mp\_utility::incPlayerStat( "bombcarrierkills", 1 );
        thread maps\mp\_matchdata::logKillEvent( var_2, "carrying" );
    }
    else if ( var_0.isDefusing )
    {
        thread maps\mp\_matchdata::logKillEvent( var_2, "defusing" );
        var_1 maps\mp\_utility::incPersStat( "defends", 1 );
        var_1 maps\mp\gametypes\_persistence::statSetChild( "round", "defends", var_1.pers["defends"] );
    }

    if ( var_1.isBombCarrier )
        var_1 maps\mp\_utility::incPlayerStat( "killsasbombcarrier", 1 );
}

giveLastOnTeamWarning()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    maps\mp\_utility::waitTillRecoveredHealth( 3 );
    var_0 = maps\mp\_utility::getOtherTeam( self.pers["team"] );
    level thread maps\mp\_utility::teamPlayerCardSplash( "callout_lastteammemberalive", self, self.pers["team"] );
    level thread maps\mp\_utility::teamPlayerCardSplash( "callout_lastenemyalive", self, var_0 );
    level notify( "last_alive",  self  );
    maps\mp\gametypes\_missions::lastManSD();
}

onTimeLimit()
{
    sd_endGame( game["defenders"], game["strings"]["time_limit_reached"] );
}

updateGametypeDvars()
{
    level.plantTime = maps\mp\_utility::dvarFloatValue( "planttime", 5, 0, 20 );
    level.defuseTime = maps\mp\_utility::dvarFloatValue( "defusetime", 5, 0, 20 );
    level.bombTimer = maps\mp\_utility::dvarFloatValue( "bombtimer", 45, 1, 300 );
    level.multiBomb = maps\mp\_utility::dvarIntValue( "multibomb", 0, 0, 1 );
}

removeBombZoneC( var_0 )
{
    var_1 = [];
    var_2 = getentarray( "script_brushmodel", "classname" );

    foreach ( var_4 in var_2 )
    {
        if ( isdefined( var_4.script_gameobjectname ) && var_4.script_gameobjectname == "bombzone" )
        {
            foreach ( var_6 in var_0 )
            {
                if ( distance( var_4.origin, var_6.origin ) < 100 && issubstr( tolower( var_6.script_label ), "c" ) )
                {
                    var_6.relatedBrushModel = var_4;
                    var_1[var_1.size] = var_6;
                    break;
                }
            }
        }
    }

    foreach ( var_10 in var_1 )
    {
        var_10.relatedBrushModel delete();
        var_11 = getentarray( var_10.target, "targetname" );

        foreach ( var_13 in var_11 )
            var_13 delete();

        var_10 delete();
    }

    return common_scripts\utility::array_removeUndefined( var_0 );
}

bombs()
{
    level.bombPlanted = 0;
    level.bombDefused = 0;
    level.bombexploded = 0;
    var_0 = getent( "sd_bomb_pickup_trig", "targetname" );

    if ( !isdefined( var_0 ) )
    {
        common_scripts\utility::error( "No sd_bomb_pickup_trig trigger found in map." );
        return;
    }

    var_1[0] = getent( "sd_bomb", "targetname" );

    if ( !isdefined( var_1[0] ) )
    {
        common_scripts\utility::error( "No sd_bomb script_model found in map." );
        return;
    }

    precachemodel( "prop_suitcase_bomb" );
    var_1[0] setmodel( "prop_suitcase_bomb" );

    if ( !level.multiBomb )
    {
        level.sdBomb = maps\mp\gametypes\_gameobjects::createCarryObject( game["attackers"], var_0, var_1, ( 0, 0, 32 ) );
        level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "friendly" );
        level.sdBomb maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_bomb" );
        level.sdBomb maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
        level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
        level.sdBomb maps\mp\gametypes\_gameobjects::setCarryIcon( "hud_suitcase_bomb" );
        level.sdBomb.allowWeapons = 1;
        level.sdBomb.onPickup = ::onPickup;
        level.sdBomb.onDrop = ::onDrop;
    }
    else
    {
        var_0 delete();
        var_1[0] delete();
    }

    level.bombZones = [];
    var_2 = getentarray( "bombzone", "targetname" );
    var_2 = removeBombZoneC( var_2 );

    for ( var_3 = 0; var_3 < var_2.size; var_3++ )
    {
        var_0 = var_2[var_3];
        var_1 = getentarray( var_2[var_3].target, "targetname" );
        var_4 = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], var_0, var_1, ( 0, 0, 64 ) );
        var_4 maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
        var_4 maps\mp\gametypes\_gameobjects::setUseTime( level.plantTime );
        var_4 maps\mp\gametypes\_gameobjects::setUseText( &"MP_PLANTING_EXPLOSIVE" );
        var_4 maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );

        if ( !level.multiBomb )
            var_4 maps\mp\gametypes\_gameobjects::setKeyObject( level.sdBomb );

        var_5 = var_4 maps\mp\gametypes\_gameobjects::getLabel();
        var_4.label = var_5;
        var_4 maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defend" + var_5 );
        var_4 maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + var_5 );
        var_4 maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_target" + var_5 );
        var_4 maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_target" + var_5 );
        var_4 maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
        var_4.onBeginUse = ::onBeginUse;
        var_4.onEndUse = ::onEndUse;
        var_4.onUse = ::onUsePlantObject;
        var_4.onCantUse = ::onCantUse;
        var_4.useWeapon = "briefcase_bomb_mp";

        for ( var_6 = 0; var_6 < var_1.size; var_6++ )
        {
            if ( isdefined( var_1[var_6].script_exploder ) )
            {
                var_4.exploderIndex = var_1[var_6].script_exploder;
                var_1[var_6] thread setupKillCamEnt( var_4 );
                break;
            }
        }

        level.bombZones[level.bombZones.size] = var_4;
        var_4.bombDefuseTrig = getent( var_1[0].target, "targetname" );
        var_4.bombDefuseTrig.origin = var_4.bombDefuseTrig.origin + ( 0, 0, -10000 );
        var_4.bombDefuseTrig.label = var_5;
    }

    for ( var_3 = 0; var_3 < level.bombZones.size; var_3++ )
    {
        var_7 = [];

        for ( var_8 = 0; var_8 < level.bombZones.size; var_8++ )
        {
            if ( var_8 != var_3 )
                var_7[var_7.size] = level.bombZones[var_8];
        }

        level.bombZones[var_3].otherBombZones = var_7;
    }
}

setupKillCamEnt( var_0 )
{
    var_1 = spawn( "script_origin", self.origin );
    var_1.angles = self.angles;
    var_1 rotateyaw( -45, 0.05 );
    wait 0.05;
    var_2 = self.origin + ( 0, 0, 5 );
    var_3 = self.origin + anglestoforward( var_1.angles ) * 100 + ( 0, 0, 128 );
    var_4 = bullettrace( var_2, var_3, 0, self );
    self.killCamEnt = spawn( "script_model", var_4["position"] );
    self.killCamEnt setscriptmoverkillcam( "explosive" );
    var_0.killCamEntNum = self.killCamEnt getentitynumber();
    var_1 delete();
}

onBeginUse( var_0 )
{
    if ( maps\mp\gametypes\_gameobjects::isFriendlyTeam( var_0.pers["team"] ) )
    {
        var_0 playsound( "mp_bomb_defuse" );
        var_0.isDefusing = 1;

        if ( isdefined( level.sdBombModel ) )
            level.sdBombModel hide();
    }
    else
    {
        var_0.isPlanting = 1;

        if ( level.multiBomb )
        {
            for ( var_1 = 0; var_1 < self.otherBombZones.size; var_1++ )
            {
                self.otherBombZones[var_1] maps\mp\gametypes\_gameobjects::allowUse( "none" );
                self.otherBombZones[var_1] maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
            }
        }
    }
}

onEndUse( var_0, var_1, var_2 )
{
    if ( !isdefined( var_1 ) )
        return;

    if ( isalive( var_1 ) )
    {
        var_1.isDefusing = 0;
        var_1.isPlanting = 0;
    }

    if ( maps\mp\gametypes\_gameobjects::isFriendlyTeam( var_1.pers["team"] ) )
    {
        if ( isdefined( level.sdBombModel ) && !var_2 )
            level.sdBombModel show();
    }
    else if ( level.multiBomb && !var_2 )
    {
        for ( var_3 = 0; var_3 < self.otherBombZones.size; var_3++ )
        {
            self.otherBombZones[var_3] maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
            self.otherBombZones[var_3] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
        }
    }
}

onCantUse( var_0 )
{
    var_0 iprintlnbold( &"MP_CANT_PLANT_WITHOUT_BOMB" );
}

onUsePlantObject( var_0 )
{
    if ( !maps\mp\gametypes\_gameobjects::isFriendlyTeam( var_0.pers["team"] ) )
    {
        level thread bombPlanted( self, var_0 );

        for ( var_1 = 0; var_1 < level.bombZones.size; var_1++ )
        {
            if ( level.bombZones[var_1] == self )
                continue;

            level.bombZones[var_1] maps\mp\gametypes\_gameobjects::disableObject();
        }

        var_0 playsound( "mp_bomb_plant" );
        var_0 notify( "bomb_planted" );
        var_0 notify( "objective",  "plant"  );
        var_0 maps\mp\_utility::incPersStat( "plants", 1 );
        var_0 maps\mp\gametypes\_persistence::statSetChild( "round", "plants", var_0.pers["plants"] );

        if ( isdefined( level.sd_loadout ) && isdefined( level.sd_loadout[var_0.team] ) )
            var_0 thread removeBombCarrierClass();

        maps\mp\_utility::leaderDialog( "bomb_planted" );
        level thread maps\mp\_utility::teamPlayerCardSplash( "callout_bombplanted", var_0 );
        level.bombOwner = var_0;
        var_0 thread maps\mp\gametypes\_hud_message::splashNotify( "plant", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
        var_0 thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
        var_0.bombPlantedTime = gettime();
        maps\mp\gametypes\_gamescore::givePlayerScore( "plant", var_0 );
        var_0 thread maps\mp\_matchdata::logGameEvent( "plant", var_0.origin );
    }
}

applyBombCarrierClass()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    if ( isdefined( self.isCarrying ) && self.isCarrying == 1 )
    {
        self notify( "force_cancel_placement" );
        wait 0.05;
    }

    if ( maps\mp\_utility::isJuggernaut() )
    {
        self notify( "lost_juggernaut" );
        wait 0.05;
    }

    self.pers["gamemodeLoadout"] = level.sd_loadout[self.team];
    var_0 = spawn( "script_model", self.origin );
    var_0.angles = self.angles;
    var_0.playerSpawnPos = self.origin;
    var_0.notti = 1;
    self.setSpawnpoint = var_0;
    self.gamemode_chosenclass = self.class;
    self.pers["class"] = "gamemode";
    self.pers["lastClass"] = "gamemode";
    self.class = "gamemode";
    self.lastClass = "gamemode";
    self notify( "faux_spawn" );
    self.gameobject_fauxspawn = 1;
    self.faux_spawn_stance = self getstance();
    thread maps\mp\gametypes\_playerlogic::spawnPlayer( 1 );
}

removeBombCarrierClass()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    if ( isdefined( self.isCarrying ) && self.isCarrying == 1 )
    {
        self notify( "force_cancel_placement" );
        wait 0.05;
    }

    if ( maps\mp\_utility::isJuggernaut() )
    {
        self notify( "lost_juggernaut" );
        wait 0.05;
    }

    self.pers["gamemodeLoadout"] = undefined;
    var_0 = spawn( "script_model", self.origin );
    var_0.angles = self.angles;
    var_0.playerSpawnPos = self.origin;
    var_0.notti = 1;
    self.setSpawnpoint = var_0;
    self notify( "faux_spawn" );
    self.faux_spawn_stance = self getstance();
    thread maps\mp\gametypes\_playerlogic::spawnPlayer( 1 );
}

onUseDefuseObject( var_0 )
{
    var_0 notify( "bomb_defused" );
    var_0 notify( "objective",  "defuse"  );
    level thread bombDefused();
    maps\mp\gametypes\_gameobjects::disableObject();
    maps\mp\_utility::leaderDialog( "bomb_defused" );
    level thread maps\mp\_utility::teamPlayerCardSplash( "callout_bombdefused", var_0 );

    if ( isdefined( level.bombOwner ) && level.bombOwner.bombPlantedTime + 3000 + level.defuseTime * 1000 > gettime() && maps\mp\_utility::isReallyAlive( level.bombOwner ) )
        var_0 thread maps\mp\gametypes\_hud_message::splashNotify( "ninja_defuse", maps\mp\gametypes\_rank::getScoreInfoValue( "defuse" ) );
    else
        var_0 thread maps\mp\gametypes\_hud_message::splashNotify( "defuse", maps\mp\gametypes\_rank::getScoreInfoValue( "defuse" ) );

    var_0 thread maps\mp\gametypes\_rank::giveRankXP( "defuse" );
    maps\mp\gametypes\_gamescore::givePlayerScore( "defuse", var_0 );
    var_0 maps\mp\_utility::incPersStat( "defuses", 1 );
    var_0 maps\mp\gametypes\_persistence::statSetChild( "round", "defuses", var_0.pers["defuses"] );
    var_0 thread maps\mp\_matchdata::logGameEvent( "defuse", var_0.origin );
}

onDrop( var_0 )
{
    maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_bomb" );
    maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
    maps\mp\_utility::playSoundOnPlayers( game["bomb_dropped_sound"], game["attackers"] );
}

onPickup( var_0 )
{
    var_0.isBombCarrier = 1;
    var_0 maps\mp\_utility::incPlayerStat( "bombscarried", 1 );
    var_0 thread maps\mp\_matchdata::logGameEvent( "pickup", var_0.origin );
    maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_escort" );
    maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_escort" );

    if ( isdefined( level.sd_loadout ) && isdefined( level.sd_loadout[var_0.team] ) )
        var_0 thread applyBombCarrierClass();

    if ( !level.bombDefused )
    {
        maps\mp\_utility::teamPlayerCardSplash( "callout_bombtaken", var_0, var_0.team );
        maps\mp\_utility::leaderDialog( "bomb_taken", var_0.pers["team"] );
    }

    maps\mp\_utility::playSoundOnPlayers( game["bomb_recovered_sound"], game["attackers"] );
}

onReset()
{

}

bombPlanted( var_0, var_1 )
{
    maps\mp\gametypes\_gamelogic::pauseTimer();
    level.bombPlanted = 1;
    var_0.visuals[0] thread maps\mp\gametypes\_gamelogic::playTickingSound();
    level.tickingObject = var_0.visuals[0];
    level.timeLimitOverride = 1;
    setgameendtime( int( gettime() + level.bombTimer * 1000 ) );
    setdvar( "ui_bomb_timer", 1 );

    if ( !level.multiBomb )
    {
        level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
        level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
        level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
        level.sdBombModel = level.sdBomb.visuals[0];
    }
    else
    {
        for ( var_2 = 0; var_2 < level.players.size; var_2++ )
        {
            if ( isdefined( level.players[var_2].carryIcon ) )
                level.players[var_2].carryIcon maps\mp\gametypes\_hud_util::destroyElem();
        }

        var_3 = bullettrace( var_1.origin + ( 0, 0, 20 ), var_1.origin - ( 0, 0, 2000 ), 0, var_1 );
        var_4 = randomfloat( 360 );
        var_5 = ( cos( var_4 ), sin( var_4 ), 0 );
        var_5 = vectornormalize( var_5 - var_3["normal"] * vectordot( var_5, var_3["normal"] ) );
        var_6 = vectortoangles( var_5 );
        level.sdBombModel = spawn( "script_model", var_3["position"] );
        level.sdBombModel.angles = var_6;
        level.sdBombModel setmodel( "prop_suitcase_bomb" );
    }

    var_0 maps\mp\gametypes\_gameobjects::allowUse( "none" );
    var_0 maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
    var_7 = var_0 maps\mp\gametypes\_gameobjects::getLabel();
    var_8 = var_0.bombDefuseTrig;
    var_8.origin = level.sdBombModel.origin;
    var_9 = [];
    var_10 = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], var_8, var_9, ( 0, 0, 32 ) );
    var_10 maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
    var_10 maps\mp\gametypes\_gameobjects::setUseTime( level.defuseTime );
    var_10 maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE" );
    var_10 maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
    var_10 maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
    var_10 maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defuse" + var_7 );
    var_10 maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_defend" + var_7 );
    var_10 maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defuse" + var_7 );
    var_10 maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend" + var_7 );
    var_10.label = var_7;
    var_10.onBeginUse = ::onBeginUse;
    var_10.onEndUse = ::onEndUse;
    var_10.onUse = ::onUseDefuseObject;
    var_10.useWeapon = "briefcase_bomb_defuse_mp";
    BombTimerWait();
    setdvar( "ui_bomb_timer", 0 );
    var_0.visuals[0] maps\mp\gametypes\_gamelogic::stopTickingSound();

    if ( level.gameEnded || level.bombDefused )
        return;

    level.bombexploded = 1;
    var_11 = level.sdBombModel.origin;
    level.sdBombModel hide();

    if ( isdefined( var_1 ) )
    {
        var_0.visuals[0] radiusdamage( var_11, 512, 200, 20, var_1, "MOD_EXPLOSIVE", "bomb_site_mp" );
        var_1 maps\mp\_utility::incPersStat( "destructions", 1 );
        var_1 maps\mp\gametypes\_persistence::statSetChild( "round", "destructions", var_1.pers["destructions"] );
    }
    else
        var_0.visuals[0] radiusdamage( var_11, 512, 200, 20, undefined, "MOD_EXPLOSIVE", "bomb_site_mp" );

    var_12 = randomfloat( 360 );
    var_13 = spawnfx( level._effect["bombexplosion"], var_11 + ( 0, 0, 50 ), ( 0, 0, 1 ), ( cos( var_12 ), sin( var_12 ), 0 ) );
    triggerfx( var_13 );
    playrumbleonposition( "grenade_rumble", var_11 );
    earthquake( 0.75, 2.0, var_11, 2000 );
    thread maps\mp\_utility::playSoundinSpace( "exp_suitcase_bomb_main", var_11 );

    if ( isdefined( var_0.exploderIndex ) )
        common_scripts\utility::exploder( var_0.exploderIndex );

    for ( var_2 = 0; var_2 < level.bombZones.size; var_2++ )
        level.bombZones[var_2] maps\mp\gametypes\_gameobjects::disableObject();

    var_10 maps\mp\gametypes\_gameobjects::disableObject();
    setgameendtime( 0 );
    wait 3;
    sd_endGame( game["attackers"], game["strings"]["target_destroyed"] );
}

BombTimerWait()
{
    level endon( "game_ended" );
    level endon( "bomb_defused" );
    var_0 = level.bombTimer * 1000 + gettime();
    setdvar( "ui_bomb_timer_endtime", var_0 );
    level thread handleHostMigration( var_0 );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithGameEndTimeUpdate( level.bombTimer );
}

handleHostMigration( var_0 )
{
    level endon( "game_ended" );
    level endon( "bomb_defused" );
    level endon( "game_ended" );
    level endon( "disconnect" );
    level waittill( "host_migration_begin" );
    var_1 = maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

    if ( var_1 > 0 )
        setdvar( "ui_bomb_timer_endtime", var_0 + var_1 );
}

bombDefused()
{
    level.tickingObject maps\mp\gametypes\_gamelogic::stopTickingSound();
    level.bombDefused = 1;
    setdvar( "ui_bomb_timer", 0 );
    level notify( "bomb_defused" );
    wait 1.5;
    setgameendtime( 0 );
    sd_endGame( game["defenders"], game["strings"]["bomb_defused"] );
}

initGametypeAwards()
{
    maps\mp\_awards::initStatAward( "targetsdestroyed", 0, maps\mp\_awards::highestWins );
    maps\mp\_awards::initStatAward( "bombsplanted", 0, maps\mp\_awards::highestWins );
    maps\mp\_awards::initStatAward( "bombsdefused", 0, maps\mp\_awards::highestWins );
    maps\mp\_awards::initStatAward( "bombcarrierkills", 0, maps\mp\_awards::highestWins );
    maps\mp\_awards::initStatAward( "bombscarried", 0, maps\mp\_awards::highestWins );
    maps\mp\_awards::initStatAward( "killsasbombcarrier", 0, maps\mp\_awards::highestWins );
}

setSpecialLoadout()
{
    if ( isusingmatchrulesdata() && getmatchrulesdata( "defaultClasses", "axis", 5, "class", "inUse" ) )
        level.sd_loadout[game["attackers"]] = maps\mp\_utility::GetMatchRulesSpecialClass( "axis", 5 );
}
