// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    var_0 = getdvar( "mapname" );

    if ( var_0 == "mp_suburbia" )
    {
        level.missileRemoteLaunchVert = 7000;
        level.missileRemoteLaunchHorz = 10000;
        level.missileRemoteLaunchTargetDist = 2000;
    }
    else if ( var_0 == "mp_mainstreet" )
    {
        level.missileRemoteLaunchVert = 7000;
        level.missileRemoteLaunchHorz = 10000;
        level.missileRemoteLaunchTargetDist = 2000;
    }
    else
    {
        level.missileRemoteLaunchVert = 14000;
        level.missileRemoteLaunchHorz = 7000;
        level.missileRemoteLaunchTargetDist = 1500;
    }

    precacheitem( "remotemissile_projectile_mp" );
    precacheshader( "ac130_overlay_grain" );
    level.rockets = [];
    level.killstreakFuncs["predator_missile"] = ::tryUsePredatorMissile;
    level.missilesForSightTraces = [];
    level.remotemissile_fx["explode"] = loadfx( "explosions/aerial_explosion" );
}

tryUsePredatorMissile( var_0 )
{
    if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }

    maps\mp\_utility::setUsingRemote( "remotemissile" );
    var_1 = maps\mp\killstreaks\_killstreaks::initRideKillstreak();

    if ( var_1 != "success" )
    {
        if ( var_1 != "disconnect" )
            maps\mp\_utility::clearUsingRemote();

        return 0;
    }

    level thread _fire( var_0, self );
    return 1;
}

getBestSpawnPoint( var_0 )
{
    var_1 = [];

    foreach ( var_3 in var_0 )
    {
        var_3.validPlayers = [];
        var_3.spawnScore = 0;
    }

    foreach ( var_6 in level.players )
    {
        if ( !maps\mp\_utility::isReallyAlive( var_6 ) )
            continue;

        if ( var_6.team == self.team )
            continue;

        if ( var_6.team == "spectator" )
            continue;

        var_7 = 999999999;
        var_8 = undefined;

        foreach ( var_3 in var_0 )
        {
            var_3.validPlayers[var_3.validPlayers.size] = var_6;
            var_10 = distance2d( var_3.targetEnt.origin, var_6.origin );

            if ( var_10 <= var_7 )
            {
                var_7 = var_10;
                var_8 = var_3;
            }
        }

        var_8.spawnScore = var_8.spawnScore + 2;
    }

    var_13 = var_0[0];

    foreach ( var_3 in var_0 )
    {
        foreach ( var_6 in var_3.validPlayers )
        {
            var_3.spawnScore = var_3.spawnScore + 1;

            if ( bullettracepassed( var_6.origin + ( 0, 0, 32 ), var_3.origin, 0, var_6 ) )
                var_3.spawnScore = var_3.spawnScore + 3;

            if ( var_3.spawnScore > var_13.spawnScore )
            {
                var_13 = var_3;
                continue;
            }

            if ( var_3.spawnScore == var_13.spawnScore )
            {
                if ( common_scripts\utility::cointoss() )
                    var_13 = var_3;
            }
        }
    }

    return var_13;
}

drawLine( var_0, var_1, var_2, var_3 )
{
    var_4 = int( var_2 * 20 );

    for ( var_5 = 0; var_5 < var_4; var_5++ )
        wait 0.05;
}

_fire( var_0, var_1 )
{
    var_2 = getentarray( "remoteMissileSpawn", "targetname" );

    foreach ( var_4 in var_2 )
    {
        if ( isdefined( var_4.target ) )
            var_4.targetEnt = getent( var_4.target, "targetname" );
    }

    if ( var_2.size > 0 )
        var_6 = var_1 getBestSpawnPoint( var_2 );
    else
        var_6 = undefined;

    if ( isdefined( var_6 ) )
    {
        var_7 = var_6.origin;
        var_8 = var_6.targetEnt.origin;
        var_9 = vectornormalize( var_7 - var_8 );
        var_7 = var_9 * 14000 + var_8;
        var_10 = magicbullet( "remotemissile_projectile_mp", var_7, var_8, var_1 );
    }
    else
    {
        var_11 = ( 0, 0, level.missileRemoteLaunchVert );
        var_12 = level.missileRemoteLaunchHorz;
        var_13 = level.missileRemoteLaunchTargetDist;
        var_14 = anglestoforward( var_1.angles );
        var_7 = var_1.origin + var_11 + var_14 * var_12 * -1;
        var_8 = var_1.origin + var_14 * var_13;
        var_10 = magicbullet( "remotemissile_projectile_mp", var_7, var_8, var_1 );
    }

    if ( !isdefined( var_10 ) )
    {
        var_1 maps\mp\_utility::clearUsingRemote();
        return;
    }

    var_10 thread maps\mp\gametypes\_weapons::AddMissileToSightTraces( var_1.team );
    var_10 thread _fire_noplayer();
    var_10.lifeId = var_0;
    var_10.type = "remote";
    MissileEyes( var_1, var_10 );
}

_fire_noplayer()
{
    self endon( "death" );
    self endon( "deleted" );
    self setcandamage( 1 );

    for (;;)
        self waittill( "damage" );
}

MissileEyes( var_0, var_1 )
{
    var_0 endon( "joined_team" );
    var_0 endon( "joined_spectators" );
    var_1 thread Rocket_CleanupOnDeath();
    var_0 thread Player_CleanupOnGameEnded( var_1 );
    var_0 thread Player_CleanupOnTeamChange( var_1 );
    var_0 visionsetmissilecamforplayer( "black_bw", 0 );
    var_0 endon( "disconnect" );

    if ( isdefined( var_1 ) )
    {
        var_0 visionsetmissilecamforplayer( game["thermal_vision"], 1.0 );
        var_0 thermalvisionon();
        var_0 thread delayedFOFOverlay();
        var_0 cameralinkto( var_1, "tag_origin" );
        var_0 controlslinkto( var_1 );

        if ( getdvarint( "camera_thirdPerson" ) )
            var_0 maps\mp\_utility::setThirdPersonDOF( 0 );

        var_1 waittill( "death" );
        var_0 thermalvisionoff();

        if ( isdefined( var_1 ) )
            var_0 maps\mp\_matchdata::logKillstreakEvent( "predator_missile", var_1.origin );

        var_0 controlsunlink();
        var_0 maps\mp\_utility::freezeControlsWrapper( 1 );

        if ( !level.gameEnded || isdefined( var_0.finalKill ) )
            var_0 thread staticEffect( 0.5 );

        wait 0.5;
        var_0 thermalvisionfofoverlayoff();
        var_0 cameraunlink();

        if ( getdvarint( "camera_thirdPerson" ) )
            var_0 maps\mp\_utility::setThirdPersonDOF( 1 );
    }

    var_0 maps\mp\_utility::clearUsingRemote();
}

delayedFOFOverlay()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    wait 0.15;
    self thermalvisionfofoverlayon();
}

staticEffect( var_0 )
{
    self endon( "disconnect" );
    var_1 = newclienthudelem( self );
    var_1.horzalign = "fullscreen";
    var_1.vertalign = "fullscreen";
    var_1 setshader( "white", 640, 480 );
    var_1.archive = 1;
    var_1.sort = 10;
    var_2 = newclienthudelem( self );
    var_2.horzalign = "fullscreen";
    var_2.vertalign = "fullscreen";
    var_2 setshader( "ac130_overlay_grain", 640, 480 );
    var_2.archive = 1;
    var_2.sort = 20;
    wait(var_0);
    var_2 destroy();
    var_1 destroy();
}

Player_CleanupOnTeamChange( var_0 )
{
    var_0 endon( "death" );
    self endon( "disconnect" );
    common_scripts\utility::waittill_any( "joined_team", "joined_spectators" );

    if ( self.team != "spectator" )
    {
        self thermalvisionfofoverlayoff();
        self controlsunlink();
        self cameraunlink();

        if ( getdvarint( "camera_thirdPerson" ) )
            maps\mp\_utility::setThirdPersonDOF( 1 );
    }

    maps\mp\_utility::clearUsingRemote();
    level.remoteMissileInProgress = undefined;
}

Rocket_CleanupOnDeath()
{
    var_0 = self getentitynumber();
    level.rockets[var_0] = self;
    self waittill( "death" );
    level.rockets[var_0] = undefined;
}

Player_CleanupOnGameEnded( var_0 )
{
    var_0 endon( "death" );
    self endon( "death" );
    level waittill( "game_ended" );
    self thermalvisionfofoverlayoff();
    self controlsunlink();
    self cameraunlink();

    if ( getdvarint( "camera_thirdPerson" ) )
        maps\mp\_utility::setThirdPersonDOF( 1 );
}
