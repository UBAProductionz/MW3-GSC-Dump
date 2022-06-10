// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

TimeUntilWaveSpawn( var_0 )
{
    if ( !self.hasSpawned )
        return 0;

    var_1 = gettime() + var_0 * 1000;
    var_2 = level.lastWave[self.pers["team"]];
    var_3 = level.waveDelay[self.pers["team"]] * 1000;
    var_4 = ( var_1 - var_2 ) / var_3;
    var_5 = ceil( var_4 );
    var_6 = var_2 + var_5 * var_3;

    if ( isdefined( self.respawnTimerStartTime ) )
    {
        var_7 = ( gettime() - self.respawnTimerStartTime ) / 1000.0;

        if ( self.respawnTimerStartTime < var_2 )
            return 0;
    }

    if ( isdefined( self.waveSpawnIndex ) )
        var_6 += 50 * self.waveSpawnIndex;

    return ( var_6 - gettime() ) / 1000;
}

TeamKillDelay()
{
    var_0 = self.pers["teamkills"];

    if ( level.maxAllowedTeamKills < 0 || var_0 <= level.maxAllowedTeamKills )
        return 0;

    var_1 = var_0 - level.maxAllowedTeamKills;
    return maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillspawndelay" ) * var_1;
}

TimeUntilSpawn( var_0 )
{
    if ( level.inGracePeriod && !self.hasSpawned || level.gameEnded )
        return 0;

    var_1 = 0;

    if ( self.hasSpawned )
    {
        var_2 = self [[ level.onRespawnDelay ]]();

        if ( isdefined( var_2 ) )
            var_1 = var_2;
        else
            var_1 = getdvarint( "scr_" + level.gameType + "_playerrespawndelay" );

        if ( var_0 && isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
            var_1 += TeamKillDelay();

        if ( isdefined( self.respawnTimerStartTime ) )
        {
            var_3 = ( gettime() - self.respawnTimerStartTime ) / 1000.0;
            var_1 -= var_3;

            if ( var_1 < 0 )
                var_1 = 0;
        }

        if ( isdefined( self.setSpawnpoint ) )
            var_1 += level.tiSpawnDelay;
    }

    var_4 = getdvarint( "scr_" + level.gameType + "_waverespawndelay" ) > 0;

    if ( var_4 )
        return TimeUntilWaveSpawn( var_1 );

    return var_1;
}

maySpawn()
{
    if ( maps\mp\_utility::getGametypeNumLives() || isdefined( level.disableSpawning ) )
    {
        if ( isdefined( level.disableSpawning ) && level.disableSpawning )
            return 0;

        if ( isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
            return 0;

        if ( !self.pers["lives"] && maps\mp\_utility::gameHasStarted() )
            return 0;
        else if ( maps\mp\_utility::gameHasStarted() )
        {
            if ( !level.inGracePeriod && !self.hasSpawned )
                return 0;
        }
    }

    return 1;
}

spawnClient()
{
    if ( isdefined( self.addToTeam ) )
    {
        maps\mp\gametypes\_menus::addToTeam( self.addToTeam );
        self.addToTeam = undefined;
    }

    if ( !maySpawn() )
    {
        var_0 = self.origin;
        var_1 = self.angles;
        self notify( "attempted_spawn" );

        if ( isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
        {
            self.pers["teamkills"] = max( self.pers["teamkills"] - 1, 0 );
            maps\mp\_utility::setLowerMessage( "friendly_fire", &"MP_FRIENDLY_FIRE_WILL_NOT" );

            if ( !self.hasSpawned && self.pers["teamkills"] <= level.maxAllowedTeamKills )
                self.pers["teamKillPunish"] = 0;
        }
        else if ( maps\mp\_utility::isRoundBased() && !maps\mp\_utility::isLastRound() )
        {
            maps\mp\_utility::setLowerMessage( "spawn_info", game["strings"]["spawn_next_round"] );
            thread removeSpawnMessageShortly( 3.0 );
        }

        if ( self.sessionstate != "spectator" )
            var_0 += ( 0, 0, 60 );

        thread spawnSpectator( var_0, var_1 );
        return;
    }

    if ( self.waitingToSpawn )
        return;

    self.waitingToSpawn = 1;
    waitAndSpawnClient();

    if ( isdefined( self ) )
        self.waitingToSpawn = 0;
}

waitAndSpawnClient()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );
    level endon( "game_ended" );
    self notify( "attempted_spawn" );
    var_0 = 0;

    if ( isdefined( self.pers["teamKillPunish"] ) && self.pers["teamKillPunish"] )
    {
        var_1 = TeamKillDelay();

        if ( var_1 > 0 )
        {
            maps\mp\_utility::setLowerMessage( "friendly_fire", &"MP_FRIENDLY_FIRE_WILL_NOT", var_1, 1, 1 );
            thread respawn_asSpectator( self.origin + ( 0, 0, 60 ), self.angles );
            var_0 = 1;
            wait(var_1);
            maps\mp\_utility::clearLowerMessage( "friendly_fire" );
            self.respawnTimerStartTime = gettime();
        }

        self.pers["teamKillPunish"] = 0;
    }
    else if ( TeamKillDelay() )
        self.pers["teamkills"] = max( self.pers["teamkills"] - 1, 0 );

    if ( maps\mp\_utility::isUsingRemote() )
    {
        self.spawningAfterRemoteDeath = 1;
        self waittill( "stopped_using_remote" );
    }

    if ( !isdefined( self.waveSpawnIndex ) && isdefined( level.wavePlayerSpawnIndex[self.team] ) )
    {
        self.waveSpawnIndex = level.wavePlayerSpawnIndex[self.team];
        level.wavePlayerSpawnIndex[self.team]++;
    }

    var_2 = TimeUntilSpawn( 0 );
    thread predictAboutToSpawnPlayerOverTime( var_2 );

    if ( var_2 > 0 )
    {
        maps\mp\_utility::setLowerMessage( "spawn_info", game["strings"]["waiting_to_spawn"], var_2, 1, 1 );

        if ( !var_0 )
            thread respawn_asSpectator( self.origin + ( 0, 0, 60 ), self.angles );

        var_0 = 1;
        maps\mp\_utility::waitForTimeOrNotify( var_2, "force_spawn" );
        self notify( "stop_wait_safe_spawn_button" );
    }

    var_3 = getdvarint( "scr_" + level.gameType + "_waverespawndelay" ) > 0;

    if ( maps\mp\gametypes\_tweakables::getTweakableValue( "player", "forcerespawn" ) == 0 && self.hasSpawned && !var_3 && !self.wantSafeSpawn )
    {
        maps\mp\_utility::setLowerMessage( "spawn_info", game["strings"]["press_to_spawn"], undefined, undefined, undefined, undefined, undefined, undefined, 1 );

        if ( !var_0 )
            thread respawn_asSpectator( self.origin + ( 0, 0, 60 ), self.angles );

        var_0 = 1;
        waitRespawnButton();
    }

    self.waitingToSpawn = 0;
    maps\mp\_utility::clearLowerMessage( "spawn_info" );
    self.waveSpawnIndex = undefined;
    thread spawnPlayer();
}

waitRespawnButton()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );

    for (;;)
    {
        if ( self usebuttonpressed() )
            break;

        wait 0.05;
    }
}

removeSpawnMessageShortly( var_0 )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    waittillframeend;
    self endon( "end_respawn" );
    wait(var_0);
    maps\mp\_utility::clearLowerMessage( "spawn_info" );
}

lastStandRespawnPlayer()
{
    self laststandrevive();

    if ( maps\mp\_utility::_hasPerk( "specialty_finalstand" ) && !level.dieHardMode )
        maps\mp\_utility::_unsetPerk( "specialty_finalstand" );

    if ( level.dieHardMode )
        self.headicon = "";

    self setstance( "crouch" );
    self.revived = 1;
    self notify( "revive" );

    if ( isdefined( self.standardmaxHealth ) )
        self.maxHealth = self.standardmaxHealth;

    self.health = self.maxHealth;
    common_scripts\utility::_enableUsability();

    if ( game["state"] == "postgame" )
        maps\mp\gametypes\_gamelogic::freezePlayerForRoundEnd();
}

getDeathSpawnPoint()
{
    var_0 = spawn( "script_origin", self.origin );
    var_0 hide();
    var_0.angles = self.angles;
    return var_0;
}

showSpawnNotifies()
{
    if ( isdefined( game["defcon"] ) )
        thread maps\mp\gametypes\_hud_message::defconSplashNotify( game["defcon"], 0 );

    if ( maps\mp\_utility::isRested() )
        thread maps\mp\gametypes\_hud_message::splashNotify( "rested" );
}

predictAboutToSpawnPlayerOverTime( var_0 )
{
    self endon( "disconnect" );
    self endon( "spawned" );
    self endon( "used_predicted_spawnpoint" );
    self notify( "predicting_about_to_spawn_player" );
    self endon( "predicting_about_to_spawn_player" );

    if ( var_0 <= 0 )
        return;

    if ( var_0 > 1.0 )
        wait(var_0 - 1.0);

    predictAboutToSpawnPlayer();
    self predictstreampos( self.predictedSpawnPoint.origin + ( 0, 0, 60 ), self.predictedSpawnPoint.angles );
    self.predictedSpawnPointTime = gettime();

    for ( var_1 = 0; var_1 < 30; var_1++ )
    {
        wait 0.4;
        var_2 = self.predictedSpawnPoint;
        predictAboutToSpawnPlayer();

        if ( self.predictedSpawnPoint != var_2 )
        {
            self predictstreampos( self.predictedSpawnPoint.origin + ( 0, 0, 60 ), self.predictedSpawnPoint.angles );
            self.predictedSpawnPointTime = gettime();
        }
    }
}

predictAboutToSpawnPlayer()
{
    if ( TimeUntilSpawn( 1 ) > 1.0 )
    {
        var_0 = "mp_global_intermission";
        var_1 = getentarray( var_0, "classname" );
        self.predictedSpawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( var_1 );
        return;
    }

    if ( isdefined( self.setSpawnpoint ) )
    {
        self.predictedSpawnPoint = self.setSpawnpoint;
        return;
    }

    var_2 = self [[ level.getSpawnPoint ]]();
    self.predictedSpawnPoint = var_2;
}

checkPredictedSpawnpointCorrectness( var_0 )
{
    self notify( "used_predicted_spawnpoint" );
    self.predictedSpawnPoint = undefined;
}

percentage( var_0, var_1 )
{
    return var_0 + " (" + int( var_0 / var_1 * 100 ) + "%)";
}

printPredictedSpawnpointCorrectness()
{

}

getSpawnOrigin( var_0 )
{
    if ( !positionwouldtelefrag( var_0.origin ) )
        return var_0.origin;

    if ( !isdefined( var_0.alternates ) )
        return var_0.origin;

    foreach ( var_2 in var_0.alternates )
    {
        if ( !positionwouldtelefrag( var_2 ) )
            return var_2;
    }

    return var_0.origin;
}

tiValidationCheck()
{
    if ( !isdefined( self.setSpawnpoint ) )
        return 0;

    var_0 = getentarray( "care_package", "targetname" );

    foreach ( var_2 in var_0 )
    {
        if ( distance( var_2.origin, self.setSpawnpoint.playerSpawnPos ) > 64 )
            continue;

        if ( isdefined( var_2.owner ) )
            maps\mp\gametypes\_hud_message::playerCardSplashNotify( "destroyed_insertion", var_2.owner );

        maps\mp\perks\_perkfunctions::deleteTI( self.setSpawnpoint );
        return 0;
    }

    return 1;
}

spawnPlayer( var_0 )
{
    self endon( "disconnect" );
    self endon( "joined_spectators" );
    self notify( "spawned" );
    self notify( "end_respawn" );

    if ( !isdefined( var_0 ) )
        var_0 = 0;

    if ( isdefined( self.setSpawnpoint ) && ( isdefined( self.setSpawnpoint.notti ) || tiValidationCheck() ) )
    {
        var_1 = self.setSpawnpoint;

        if ( !isdefined( self.setSpawnpoint.notti ) )
        {
            self playlocalsound( "tactical_spawn" );

            if ( level.teamBased )
                self playsoundtoteam( "tactical_spawn", level.otherTeam[self.team] );
            else
                self playsound( "tactical_spawn" );
        }

        foreach ( var_3 in level.ugvs )
        {
            if ( distancesquared( var_3.origin, var_1.playerSpawnPos ) < 1024 )
                var_3 notify( "damage",  5000, var_3.owner, ( 0, 0, 0 ), ( 0, 0, 0 ), "MOD_EXPLOSIVE", "", "", "", undefined, "killstreak_emp_mp"  );
        }

        var_5 = self.setSpawnpoint.playerSpawnPos;
        var_6 = self.setSpawnpoint.angles;

        if ( isdefined( self.setSpawnpoint.enemyTrigger ) )
            self.setSpawnpoint.enemyTrigger delete();

        self.setSpawnpoint delete();
        var_1 = undefined;
    }
    else
    {
        var_1 = self [[ level.getSpawnPoint ]]();
        var_5 = var_1.origin;
        var_6 = var_1.angles;
    }

    setSpawnVariables();
    var_7 = self.hasSpawned;
    self.fauxDead = undefined;

    if ( !var_0 )
    {
        self.killsThisLife = [];
        updateSessionState( "playing", "" );
        maps\mp\_utility::ClearKillcamState();
        self.cancelKillcam = 1;
        self openmenu( "killedby_card_hide" );
        self.maxHealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" );
        self.health = self.maxHealth;
        self.friendlydamage = undefined;
        self.hasSpawned = 1;
        self.spawnTime = gettime();
        self.wasTI = !isdefined( var_1 );
        self.afk = 0;
        self.damagedPlayers = [];
        self.killStreakScaler = 1;
        self.xpScaler = 1;
        self.objectiveScaler = 1;
        self.clampedHealth = undefined;
        self.shieldDamage = 0;
        self.shieldBulletHits = 0;
        self.recentShieldXP = 0;
    }

    self.moveSpeedScaler = 1;
    self.inLastStand = 0;
    self.laststand = undefined;
    self.inFinalStand = undefined;
    self.inC4Death = undefined;
    self.disabledWeapon = 0;
    self.disabledWeaponSwitch = 0;
    self.disabledOffhandWeapons = 0;
    common_scripts\utility::resetUsability();

    if ( !var_0 )
    {
        self.avoidKillstreakOnSpawnTimer = 5.0;

        if ( self.pers["lives"] == maps\mp\_utility::getGametypeNumLives() )
            addToLivesCount();

        if ( self.pers["lives"] )
            self.pers["lives"]--;

        addToAliveCount();

        if ( !var_7 || maps\mp\_utility::gameHasStarted() || maps\mp\_utility::gameHasStarted() && level.inGracePeriod && self.hasDoneCombat )
            removeFromLivesCount();

        if ( !self.wasAliveAtMatchStart )
        {
            var_8 = 20;

            if ( maps\mp\_utility::getTimeLimit() > 0 && var_8 < maps\mp\_utility::getTimeLimit() * 60 / 4 )
                var_8 = maps\mp\_utility::getTimeLimit() * 60 / 4;

            if ( level.inGracePeriod || maps\mp\_utility::getTimePassed() < var_8 * 1000 )
                self.wasAliveAtMatchStart = 1;
        }
    }

    self setclientdvar( "cg_thirdPerson", "0" );
    self setdepthoffield( 0, 0, 512, 512, 4, 0 );
    self setclientdvar( "cg_fov", "65" );

    if ( isdefined( var_1 ) )
    {
        maps\mp\gametypes\_spawnlogic::finalizeSpawnpointChoice( var_1 );
        var_5 = getSpawnOrigin( var_1 );
        var_6 = var_1.angles;
    }
    else
        self.lastspawntime = gettime();

    self.spawnPos = var_5;
    self spawn( var_5, var_6 );

    if ( var_0 && isdefined( self.faux_spawn_stance ) )
    {
        self setstance( self.faux_spawn_stance );
        self.faux_spawn_stance = undefined;
    }

    [[ level.onSpawnPlayer ]]();

    if ( isdefined( var_1 ) )
        checkPredictedSpawnpointCorrectness( var_1.origin );

    if ( !var_0 )
        maps\mp\gametypes\_missions::playerSpawned();

    maps\mp\gametypes\_class::setClass( self.class );
    maps\mp\gametypes\_class::giveLoadout( self.team, self.class );

    if ( getdvarint( "camera_thirdPerson" ) )
        maps\mp\_utility::setThirdPersonDOF( 1 );

    if ( !maps\mp\_utility::gameFlag( "prematch_done" ) )
        maps\mp\_utility::freezeControlsWrapper( 1 );
    else
        maps\mp\_utility::freezeControlsWrapper( 0 );

    if ( !maps\mp\_utility::gameFlag( "prematch_done" ) || !var_7 && game["state"] == "playing" )
    {
        self setclientdvar( "scr_objectiveText", maps\mp\_utility::getObjectiveHintText( self.pers["team"] ) );
        var_9 = self.pers["team"];

        if ( game["status"] == "overtime" )
            thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"]["overtime"], game["strings"]["overtime_hint"], undefined, ( 1, 0, 0 ), "mp_last_stand" );
        else if ( maps\mp\_utility::getIntProperty( "useRelativeTeamColors", 0 ) )
            thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][var_9 + "_name"], undefined, game["icons"][var_9] + "_blue", game["colors"]["blue"] );
        else
            thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][var_9 + "_name"], undefined, game["icons"][var_9], game["colors"][var_9] );

        thread showSpawnNotifies();
    }

    if ( maps\mp\_utility::getIntProperty( "scr_showperksonspawn", 1 ) == 1 && game["state"] != "postgame" )
    {
        self openmenu( "perk_display" );
        thread hidePerksAfterTime( 4.0 );
        thread hidePerksOnDeath();
    }

    waittillframeend;
    self.spawningAfterRemoteDeath = undefined;
    self notify( "spawned_player" );
    level notify( "player_spawned",  self  );

    if ( game["state"] == "postgame" )
        maps\mp\gametypes\_gamelogic::freezePlayerForRoundEnd();
}

hidePerksAfterTime( var_0 )
{
    self endon( "disconnect" );
    self endon( "perks_hidden" );
    wait(var_0);
    self openmenu( "perk_hide" );
    self notify( "perks_hidden" );
}

hidePerksOnDeath()
{
    self endon( "disconnect" );
    self endon( "perks_hidden" );
    self waittill( "death" );
    self openmenu( "perk_hide" );
    self notify( "perks_hidden" );
}

hidePerksOnKill()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "perks_hidden" );
    self waittill( "killed_player" );
    self openmenu( "perk_hide" );
    self notify( "perks_hidden" );
}

spawnSpectator( var_0, var_1 )
{
    self notify( "spawned" );
    self notify( "end_respawn" );
    self notify( "joined_spectators" );
    in_spawnSpectator( var_0, var_1 );
}

respawn_asSpectator( var_0, var_1 )
{
    in_spawnSpectator( var_0, var_1 );
}

in_spawnSpectator( var_0, var_1 )
{
    setSpawnVariables();

    if ( isdefined( self.pers["team"] ) && self.pers["team"] == "spectator" && !level.gameEnded )
        maps\mp\_utility::clearLowerMessage( "spawn_info" );

    self.sessionstate = "spectator";
    maps\mp\_utility::ClearKillcamState();
    self.friendlydamage = undefined;

    if ( isdefined( self.pers["team"] ) && self.pers["team"] == "spectator" )
        self.statusicon = "";
    else
        self.statusicon = "hud_status_dead";

    maps\mp\gametypes\_spectating::setSpectatePermissions();
    onSpawnSpectator( var_0, var_1 );

    if ( level.teamBased && !level.splitscreen && !self issplitscreenplayer() )
        self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

getPlayerFromClientNum( var_0 )
{
    if ( var_0 < 0 )
        return undefined;

    for ( var_1 = 0; var_1 < level.players.size; var_1++ )
    {
        if ( level.players[var_1] getentitynumber() == var_0 )
            return level.players[var_1];
    }

    return undefined;
}

onSpawnSpectator( var_0, var_1 )
{
    if ( isdefined( var_0 ) && isdefined( var_1 ) )
    {
        self setspectatedefaults( var_0, var_1 );
        self spawn( var_0, var_1 );
        checkPredictedSpawnpointCorrectness( var_0 );
        return;
    }

    var_2 = "mp_global_intermission";
    var_3 = getentarray( var_2, "classname" );
    var_4 = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( var_3 );
    self setspectatedefaults( var_4.origin, var_4.angles );
    self spawn( var_4.origin, var_4.angles );
    checkPredictedSpawnpointCorrectness( var_4.origin );
}

spawnIntermission()
{
    self endon( "disconnect" );
    self notify( "spawned" );
    self notify( "end_respawn" );
    setSpawnVariables();
    self closepopupmenu();
    self closeingamemenu();
    maps\mp\_utility::clearLowerMessages();
    maps\mp\_utility::freezeControlsWrapper( 1 );
    self setclientdvar( "cg_everyoneHearsEveryone", 1 );

    if ( level.rankedmatch && ( self.postGamePromotion || self.pers["postGameChallenges"] ) )
    {
        if ( self.postGamePromotion )
            self playlocalsound( "mp_level_up" );
        else
            self playlocalsound( "mp_challenge_complete" );

        if ( self.postGamePromotion > level.postGameNotifies )
            level.postGameNotifies = 1;

        if ( self.pers["postGameChallenges"] > level.postGameNotifies )
            level.postGameNotifies = self.pers["postGameChallenges"];

        self closepopupmenu();
        self closeingamemenu();
        self openmenu( game["menu_endgameupdate"] );
        var_0 = 4.0 + min( self.pers["postGameChallenges"], 3 );

        while ( var_0 )
        {
            wait 0.25;
            var_0 -= 0.25;
            self openmenu( game["menu_endgameupdate"] );
        }

        self closemenu( game["menu_endgameupdate"] );
    }

    self.sessionstate = "intermission";
    maps\mp\_utility::ClearKillcamState();
    self.friendlydamage = undefined;
    var_1 = getentarray( "mp_global_intermission", "classname" );
    var_2 = var_1[0];
    self spawn( var_2.origin, var_2.angles );
    checkPredictedSpawnpointCorrectness( var_2.origin );
    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

spawnEndOfGame()
{
    if ( 1 )
    {
        maps\mp\_utility::freezeControlsWrapper( 1 );
        spawnSpectator();
        maps\mp\_utility::freezeControlsWrapper( 1 );
        return;
    }

    self notify( "spawned" );
    self notify( "end_respawn" );
    setSpawnVariables();
    self closepopupmenu();
    self closeingamemenu();
    maps\mp\_utility::clearLowerMessages();
    self setclientdvar( "cg_everyoneHearsEveryone", 1 );
    self.sessionstate = "dead";
    maps\mp\_utility::ClearKillcamState();
    self.friendlydamage = undefined;
    var_0 = getentarray( "mp_global_intermission", "classname" );
    var_1 = var_0[0];
    self spawn( var_1.origin, var_1.angles );
    checkPredictedSpawnpointCorrectness( var_1.origin );
    var_1 setmodel( "tag_origin" );
    self playerlinkto( var_1 );
    self playerhide();
    maps\mp\_utility::freezeControlsWrapper( 1 );
    self setdepthoffield( 0, 128, 512, 4000, 6, 1.8 );
}

setSpawnVariables()
{
    self stopshellshock();
    self stoprumble( "damage_heavy" );
}

notifyConnecting()
{
    waittillframeend;

    if ( isdefined( self ) )
        level notify( "connecting",  self  );
}

Callback_PlayerDisconnect()
{
    if ( !isdefined( self.connected ) )
        return;

    var_0 = getmatchdata( "gameLength" );
    var_0 += int( maps\mp\_utility::getSecondsPassed() );
    setmatchdata( "players", self.clientid, "disconnectTime", var_0 );

    if ( isdefined( self.pers["confirmed"] ) )
        maps\mp\_matchdata::logKillsConfirmed();

    if ( isdefined( self.pers["denied"] ) )
        maps\mp\_matchdata::logKillsDenied();

    removePlayerOnDisconnect();

    if ( !level.teamBased )
        game["roundsWon"][self.guid] = undefined;

    if ( level.splitscreen )
    {
        var_1 = level.players;

        if ( var_1.size <= 1 )
            level thread maps\mp\gametypes\_gamelogic::forceEnd();
    }

    if ( isdefined( self.score ) && isdefined( self.pers["team"] ) )
        setplayerteamrank( self, self.clientid, self.score - 5 * self.deaths );

    var_2 = self getentitynumber();
    var_3 = self.guid;
    logprint( "Q;" + var_3 + ";" + var_2 + ";" + self.name + "\n" );
    thread maps\mp\_events::disconnected();

    if ( level.gameEnded )
        maps\mp\gametypes\_gamescore::removeDisconnectedPlayerFromPlacement();

    if ( isdefined( self.team ) )
        removeFromTeamCount();

    if ( self.sessionstate == "playing" )
        removeFromAliveCount( 1 );
    else if ( self.sessionstate == "spectator" || self.sessionstate == "dead" )
        level thread maps\mp\gametypes\_gamelogic::updateGameEvents();
}

removePlayerOnDisconnect()
{
    var_0 = 0;

    for ( var_1 = 0; var_1 < level.players.size; var_1++ )
    {
        if ( level.players[var_1] == self )
        {
            for ( var_0 = 1; var_1 < level.players.size - 1; var_1++ )
                level.players[var_1] = level.players[var_1 + 1];

            level.players[var_1] = undefined;
            break;
        }
    }
}

initclientdvarssplitscreenspecific()
{
    if ( level.splitscreen || self issplitscreenplayer() )
        self setclientdvars( "cg_hudGrenadeIconHeight", "37.5", "cg_hudGrenadeIconWidth", "37.5", "cg_hudGrenadeIconOffset", "75", "cg_hudGrenadePointerHeight", "18", "cg_hudGrenadePointerWidth", "37.5", "cg_hudGrenadePointerPivot", "18 40.5", "cg_fovscale", "0.75" );
    else
        self setclientdvars( "cg_hudGrenadeIconHeight", "25", "cg_hudGrenadeIconWidth", "25", "cg_hudGrenadeIconOffset", "50", "cg_hudGrenadePointerHeight", "12", "cg_hudGrenadePointerWidth", "25", "cg_hudGrenadePointerPivot", "12 27", "cg_fovscale", "1" );
}

initClientDvars()
{
    makedvarserverinfo( "cg_drawTalk", 1 );
    makedvarserverinfo( "cg_drawCrosshair", 1 );
    makedvarserverinfo( "cg_drawCrosshairNames", 1 );
    makedvarserverinfo( "cg_hudGrenadeIconMaxRangeFrag", 250 );

    if ( level.hardcoreMode )
    {
        setdvar( "cg_drawTalk", 3 );
        setdvar( "cg_drawCrosshair", 0 );
        setdvar( "cg_drawCrosshairNames", 1 );
        setdvar( "cg_hudGrenadeIconMaxRangeFrag", 0 );
    }

    self setclientdvars( "cg_drawSpectatorMessages", 1, "g_compassShowEnemies", getdvar( "scr_game_forceuav" ), "cg_scoreboardPingGraph", 1 );
    initclientdvarssplitscreenspecific();

    if ( maps\mp\_utility::getGametypeNumLives() )
        self setclientdvars( "cg_deadChatWithDead", 1, "cg_deadChatWithTeam", 0, "cg_deadHearTeamLiving", 0, "cg_deadHearAllLiving", 0 );
    else
        self setclientdvars( "cg_deadChatWithDead", 0, "cg_deadChatWithTeam", 1, "cg_deadHearTeamLiving", 1, "cg_deadHearAllLiving", 0 );

    if ( level.teamBased )
        self setclientdvars( "cg_everyonehearseveryone", 0 );

    self setclientdvar( "ui_altscene", 0 );

    if ( getdvarint( "scr_hitloc_debug" ) )
    {
        for ( var_0 = 0; var_0 < 6; var_0++ )
            self setclientdvar( "ui_hitloc_" + var_0, "" );

        self.hitlocInited = 1;
    }
}

getLowestAvailableClientId()
{
    var_0 = 0;

    for ( var_1 = 0; var_1 < 30; var_1++ )
    {
        foreach ( var_3 in level.players )
        {
            if ( !isdefined( var_3 ) )
                continue;

            if ( var_3.clientid == var_1 )
            {
                var_0 = 1;
                break;
            }

            var_0 = 0;
        }

        if ( !var_0 )
            return var_1;
    }
}

Callback_PlayerConnect()
{
    thread notifyConnecting();
    self.statusicon = "hud_status_connecting";
    self waittill( "begin" );
    self.statusicon = "";
    var_0 = undefined;
    level notify( "connected",  self  );
    self.connected = 1;

    if ( self ishost() )
        level.player = self;

    if ( !level.splitscreen && !isdefined( self.pers["score"] ) )
        iprintln( &"MP_CONNECTED", self );

    self.usingOnlineDataOffline = self isusingonlinedataoffline();
    initClientDvars();
    initPlayerStats();

    if ( getdvar( "r_reflectionProbeGenerate" ) == "1" )
        level waittill( "eternity" );

    self.guid = self getguid();
    var_1 = 0;

    if ( !isdefined( self.pers["clientid"] ) )
    {
        if ( game["clientid"] >= 30 )
            self.pers["clientid"] = getLowestAvailableClientId();
        else
            self.pers["clientid"] = game["clientid"];

        if ( game["clientid"] < 30 )
            game["clientid"]++;

        var_1 = 1;
    }

    if ( var_1 )
        maps\mp\killstreaks\_killstreaks::resetAdrenaline();

    if ( !var_1 && isdefined( game[self.guid] ) && game[self.guid] )
        self.hasdoneanycombat = 1;

    self.clientid = self.pers["clientid"];
    self.pers["teamKillPunish"] = 0;
    logprint( "J;" + self.guid + ";" + self getentitynumber() + ";" + self.name + "\n" );

    if ( game["clientid"] <= 30 && game["clientid"] != getmatchdata( "playerCount" ) )
    {
        var_2 = 0;
        var_3 = 0;
        setmatchdata( "playerCount", game["clientid"] );
        setmatchdata( "players", self.clientid, "xuid", self getxuid() );
        setmatchdata( "players", self.clientid, "gamertag", self.name );
        var_3 = self getplayerdata( "connectionIDChunkLow" );
        var_2 = self getplayerdata( "connectionIDChunkHigh" );
        setmatchdata( "players", self.clientid, "connectionIDChunkLow", var_3 );
        setmatchdata( "players", self.clientid, "connectionIDChunkHigh", var_2 );
        setmatchclientip( self, self.clientid );
        var_4 = getmatchdata( "gameLength" );
        var_4 += int( maps\mp\_utility::getSecondsPassed() );
        setmatchdata( "players", self.clientid, "connectTime", var_4 );
        setmatchdata( "players", self.clientid, "startXp", self getplayerdata( "experience" ) );

        if ( maps\mp\_utility::matchMakingGame() && maps\mp\_utility::allowTeamChoice() )
            setmatchdata( "players", self.clientid, "team", self.sessionteam );
    }

    if ( !level.teamBased )
        game["roundsWon"][self.guid] = 0;

    self.leaderDialogQueue = [];
    self.leaderDialogActive = "";
    self.leaderDialogGroups = [];
    self.leaderDialogGroup = "";

    if ( !isdefined( self.pers["cur_kill_streak"] ) )
        self.pers["cur_kill_streak"] = 0;

    if ( !isdefined( self.pers["cur_death_streak"] ) )
        self.pers["cur_death_streak"] = 0;

    if ( !isdefined( self.pers["assistsToKill"] ) )
        self.pers["assistsToKill"] = 0;

    if ( !isdefined( self.pers["cur_kill_streak_for_nuke"] ) )
        self.pers["cur_kill_streak_for_nuke"] = 0;

    self.kill_streak = maps\mp\gametypes\_persistence::statGet( "killStreak" );
    self.lastGrenadeSuicideTime = -1;
    self.teamkillsThisRound = 0;
    self.hasSpawned = 0;
    self.waitingToSpawn = 0;
    self.wantSafeSpawn = 0;
    self.wasAliveAtMatchStart = 0;
    self.moveSpeedScaler = 1;
    self.killStreakScaler = 1;
    self.xpScaler = 1;
    self.objectiveScaler = 1;
    self.isSniper = 0;
    self.saved_actionSlotData = [];
    setRestXPGoal();

    for ( var_5 = 1; var_5 <= 4; var_5++ )
    {
        self.saved_actionSlotData[var_5] = spawnstruct();
        self.saved_actionSlotData[var_5].type = "";
        self.saved_actionSlotData[var_5].item = undefined;
    }

    if ( !level.console )
    {
        for ( var_5 = 5; var_5 <= 8; var_5++ )
        {
            self.saved_actionSlotData[var_5] = spawnstruct();
            self.saved_actionSlotData[var_5].type = "";
            self.saved_actionSlotData[var_5].item = undefined;
        }
    }

    thread maps\mp\_flashgrenades::monitorFlash();
    waittillframeend;
    level.players[level.players.size] = self;

    if ( level.teamBased )
        self updatescores();

    if ( game["state"] == "postgame" )
    {
        self.connectedPostGame = 1;

        if ( maps\mp\_utility::matchMakingGame() )
            maps\mp\gametypes\_menus::addToTeam( maps\mp\gametypes\_menus::getTeamAssignment(), 1 );
        else
            maps\mp\gametypes\_menus::addToTeam( "spectator", 1 );

        self setclientdvars( "cg_drawSpectatorMessages", 0 );
        spawnIntermission();
    }
    else
    {
        level endon( "game_ended" );

        if ( isdefined( level.hostMigrationTimer ) )
            thread maps\mp\gametypes\_hostmigration::hostMigrationTimerThink();

        if ( isdefined( level.OnPlayerConnectAudioInit ) )
            [[ level.OnPlayerConnectAudioInit ]]();

        if ( !isdefined( self.pers["team"] ) )
        {
            if ( maps\mp\_utility::matchMakingGame() )
            {
                thread spawnSpectator();
                self [[ level.autoassign ]]();
                thread kickIfDontSpawn();
                return;
            }
            else if ( maps\mp\_utility::allowTeamChoice() )
            {
                self [[ level.spectator ]]();
                maps\mp\gametypes\_menus::beginTeamChoice();
            }
            else
            {
                self [[ level.spectator ]]();
                self [[ level.autoassign ]]();
                return;
            }
        }
        else
        {
            maps\mp\gametypes\_menus::addToTeam( self.pers["team"], 1 );

            if ( maps\mp\_utility::isValidClass( self.pers["class"] ) )
            {
                thread spawnClient();
                return;
            }

            thread spawnSpectator();

            if ( self.pers["team"] == "spectator" )
            {
                if ( maps\mp\_utility::allowTeamChoice() )
                {
                    maps\mp\gametypes\_menus::beginTeamChoice();
                    return;
                }

                self [[ level.autoassign ]]();
                return;
                return;
            }

            maps\mp\gametypes\_menus::beginClassChoice();
        }
    }
}

Callback_PlayerMigrated()
{
    if ( isdefined( self.connected ) && self.connected )
    {
        maps\mp\_utility::updateObjectiveText();
        maps\mp\_utility::updateMainMenu();

        if ( level.teamBased )
            self updatescores();
    }

    if ( self ishost() )
        initclientdvarssplitscreenspecific();

    level.hostMigrationReturnedPlayerCount++;

    if ( level.hostMigrationReturnedPlayerCount >= level.players.size * 2 / 3 )
        level notify( "hostmigration_enoughplayers" );
}

AddLevelsToExperience( var_0, var_1 )
{
    var_2 = maps\mp\gametypes\_rank::getRankForXp( var_0 );
    var_3 = maps\mp\gametypes\_rank::getRankInfoMinXP( var_2 );
    var_4 = maps\mp\gametypes\_rank::getRankInfoMaxXp( var_2 );
    var_2 += ( var_0 - var_3 ) / ( var_4 - var_3 );
    var_2 += var_1;

    if ( var_2 < 0 )
    {
        var_2 = 0;
        var_5 = 0.0;
    }
    else if ( var_2 >= level.maxRank + 1.0 )
    {
        var_2 = level.maxRank;
        var_5 = 1.0;
    }
    else
    {
        var_5 = var_2 - floor( var_2 );
        var_2 = int( floor( var_2 ) );
    }

    var_3 = maps\mp\gametypes\_rank::getRankInfoMinXP( var_2 );
    var_4 = maps\mp\gametypes\_rank::getRankInfoMaxXp( var_2 );
    return int( var_5 * ( var_4 - var_3 ) ) + var_3;
}

GetRestXPCap( var_0 )
{
    var_1 = getdvarfloat( "scr_restxp_cap" );
    return AddLevelsToExperience( var_0, var_1 );
}

setRestXPGoal()
{
    if ( !getdvarint( "scr_restxp_enable" ) )
    {
        self setplayerdata( "restXPGoal", 0 );
        return;
    }

    var_0 = self getrestedtime();
    var_1 = var_0 / 3600;
    var_2 = self getplayerdata( "experience" );
    var_3 = getdvarfloat( "scr_restxp_minRestTime" );
    var_4 = getdvarfloat( "scr_restxp_levelsPerDay" ) / 24.0;
    var_5 = GetRestXPCap( var_2 );
    var_6 = self getplayerdata( "restXPGoal" );

    if ( var_6 < var_2 )
        var_6 = var_2;

    var_7 = var_6;
    var_8 = 0;

    if ( var_1 > var_3 )
    {
        var_8 = var_4 * var_1;
        var_6 = AddLevelsToExperience( var_6, var_8 );
    }

    var_9 = "";

    if ( var_6 >= var_5 )
    {
        var_6 = var_5;
        var_9 = " (hit cap)";
    }

    self setplayerdata( "restXPGoal", var_6 );
}

forceSpawn()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "spawned" );
    wait 60.0;

    if ( self.hasSpawned )
        return;

    if ( self.pers["team"] == "spectator" )
        return;

    if ( !maps\mp\_utility::isValidClass( self.pers["class"] ) )
    {
        self.pers["class"] = "CLASS_CUSTOM1";
        self.class = self.pers["class"];
    }

    maps\mp\_utility::closeMenus();
    thread spawnClient();
}

kickIfDontSpawn()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "spawned" );
    self endon( "attempted_spawn" );
    var_0 = getdvarfloat( "scr_kick_time", 90 );
    var_1 = getdvarfloat( "scr_kick_mintime", 45 );
    var_2 = gettime();

    if ( self ishost() )
        kickWait( 120 );
    else
        kickWait( var_0 );

    var_3 = ( gettime() - var_2 ) / 1000;

    if ( var_3 < var_0 - 0.1 && var_3 < var_1 )
        return;

    if ( self.hasSpawned )
        return;

    if ( self.pers["team"] == "spectator" )
        return;

    kick( self getentitynumber(), "EXE_PLAYERKICKED_INACTIVE" );
    level thread maps\mp\gametypes\_gamelogic::updateGameEvents();
}

kickWait( var_0 )
{
    level endon( "game_ended" );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_0 );
}

updateSessionState( var_0, var_1 )
{
    self.sessionstate = var_0;
    self.statusicon = var_1;
}

initPlayerStats()
{
    maps\mp\gametypes\_persistence::initBufferedStats();
    self.pers["lives"] = maps\mp\_utility::getGametypeNumLives();

    if ( !isdefined( self.pers["deaths"] ) )
    {
        maps\mp\_utility::initPersStat( "deaths" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "deaths", 0 );
    }

    self.deaths = maps\mp\_utility::getPersStat( "deaths" );

    if ( !isdefined( self.pers["score"] ) )
    {
        maps\mp\_utility::initPersStat( "score" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "score", 0 );
    }

    self.score = maps\mp\_utility::getPersStat( "score" );

    if ( !isdefined( self.pers["suicides"] ) )
        maps\mp\_utility::initPersStat( "suicides" );

    self.suicides = maps\mp\_utility::getPersStat( "suicides" );

    if ( !isdefined( self.pers["kills"] ) )
    {
        maps\mp\_utility::initPersStat( "kills" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "kills", 0 );
    }

    self.kills = maps\mp\_utility::getPersStat( "kills" );

    if ( !isdefined( self.pers["headshots"] ) )
        maps\mp\_utility::initPersStat( "headshots" );

    self.headshots = maps\mp\_utility::getPersStat( "headshots" );

    if ( !isdefined( self.pers["assists"] ) )
    {
        maps\mp\_utility::initPersStat( "assists" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "assists", 0 );
    }

    self.assists = maps\mp\_utility::getPersStat( "assists" );

    if ( !isdefined( self.pers["captures"] ) )
    {
        maps\mp\_utility::initPersStat( "captures" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "captures", 0 );
    }

    self.captures = maps\mp\_utility::getPersStat( "captures" );

    if ( !isdefined( self.pers["returns"] ) )
    {
        maps\mp\_utility::initPersStat( "returns" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "returns", 0 );
    }

    self.returns = maps\mp\_utility::getPersStat( "returns" );

    if ( !isdefined( self.pers["defends"] ) )
    {
        maps\mp\_utility::initPersStat( "defends" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "defends", 0 );
    }

    self.defends = maps\mp\_utility::getPersStat( "defends" );

    if ( !isdefined( self.pers["plants"] ) )
    {
        maps\mp\_utility::initPersStat( "plants" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "plants", 0 );
    }

    self.plants = maps\mp\_utility::getPersStat( "plants" );

    if ( !isdefined( self.pers["defuses"] ) )
    {
        maps\mp\_utility::initPersStat( "defuses" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "defuses", 0 );
    }

    self.defuses = maps\mp\_utility::getPersStat( "defuses" );

    if ( !isdefined( self.pers["destructions"] ) )
    {
        maps\mp\_utility::initPersStat( "destructions" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "destructions", 0 );
    }

    self.destructions = maps\mp\_utility::getPersStat( "destructions" );

    if ( !isdefined( self.pers["confirmed"] ) )
    {
        maps\mp\_utility::initPersStat( "confirmed" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "confirmed", 0 );
    }

    self.confirmed = maps\mp\_utility::getPersStat( "confirmed" );

    if ( !isdefined( self.pers["denied"] ) )
    {
        maps\mp\_utility::initPersStat( "denied" );
        maps\mp\gametypes\_persistence::statSetChild( "round", "denied", 0 );
    }

    self.denied = maps\mp\_utility::getPersStat( "denied" );

    if ( !isdefined( self.pers["teamkills"] ) )
        maps\mp\_utility::initPersStat( "teamkills" );

    if ( !isdefined( self.pers["teamKillPunish"] ) )
        self.pers["teamKillPunish"] = 0;

    maps\mp\_utility::initPersStat( "longestStreak" );
    self.pers["lives"] = maps\mp\_utility::getGametypeNumLives();
    maps\mp\gametypes\_persistence::statSetChild( "round", "killStreak", 0 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "loss", 0 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "win", 0 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "scoreboardType", "none" );
    maps\mp\gametypes\_persistence::statSetChildBuffered( "round", "timePlayed", 0 );
}

addToTeamCount()
{
    level.teamCount[self.team]++;
    maps\mp\gametypes\_gamelogic::updateGameEvents();
}

removeFromTeamCount()
{
    level.teamCount[self.team]--;
}

addToAliveCount()
{
    level.aliveCount[self.team]++;
    level.hasSpawned[self.team]++;

    if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
        level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];
}

removeFromAliveCount( var_0 )
{
    if ( isdefined( self.switching_teams ) || isdefined( var_0 ) )
    {
        removeAllFromLivesCount();

        if ( isdefined( self.switching_teams ) )
            self.pers["lives"] = 0;
    }

    level.aliveCount[self.team]--;
    return maps\mp\gametypes\_gamelogic::updateGameEvents();
}

addToLivesCount()
{
    level.livesCount[self.team] = level.livesCount[self.team] + self.pers["lives"];
}

removeFromLivesCount()
{
    level.livesCount[self.team]--;
    level.livesCount[self.team] = int( max( 0, level.livesCount[self.team] ) );
}

removeAllFromLivesCount()
{
    level.livesCount[self.team] = level.livesCount[self.team] - self.pers["lives"];
    level.livesCount[self.team] = int( max( 0, level.livesCount[self.team] ) );
}
