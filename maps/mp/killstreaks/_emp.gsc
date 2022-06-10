// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level._effect["emp_flash"] = loadfx( "explosions/emp_flash_mp" );
    level.teamEMPed["allies"] = 0;
    level.teamEMPed["axis"] = 0;
    level.EMPPlayer = undefined;
    level.empTimeout = 60.0;
    level.empTimeRemaining = int( level.empTimeout );

    if ( level.teamBased )
        level thread EMP_TeamTracker();
    else
        level thread EMP_PlayerTracker();

    level.killstreakFuncs["emp"] = ::EMP_Use;
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0 thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        if ( level.teamBased && level.teamEMPed[self.team] || !level.teamBased && isdefined( level.EMPPlayer ) && level.EMPPlayer != self )
            self setempjammed( 1 );
    }
}

EMP_Use( var_0 )
{
    if ( !maps\mp\_utility::validateUseStreak() )
        return 0;

    var_1 = self.pers["team"];
    var_2 = level.otherTeam[var_1];

    if ( level.teamBased )
        thread EMP_JamTeam( var_2 );
    else
        thread EMP_JamPlayers( self );

    maps\mp\_matchdata::logKillstreakEvent( "emp", self.origin );
    self notify( "used_emp" );
    return 1;
}

EMP_JamTeam( var_0 )
{
    level endon( "game_ended" );
    thread maps\mp\_utility::teamPlayerCardSplash( "used_emp", self );
    level notify( "EMP_JamTeam" + var_0 );
    level endon( "EMP_JamTeam" + var_0 );

    foreach ( var_2 in level.players )
    {
        var_2 playlocalsound( "emp_activate" );

        if ( var_2.team != var_0 )
            continue;

        if ( var_2 maps\mp\_utility::_hasPerk( "specialty_localjammer" ) )
            var_2 radarjamoff();
    }

    visionsetnaked( "coup_sunblind", 0.1 );
    thread empEffects();
    wait 0.1;
    visionsetnaked( "coup_sunblind", 0 );

    if ( isdefined( level.nukeDetonated ) )
        visionsetnaked( level.nukeVisionSet, 3.0 );
    else
        visionsetnaked( "", 3.0 );

    level.teamEMPed[var_0] = 1;
    level notify( "emp_update" );
    level destroyActiveVehicles( self, var_0 );
    level thread keepEMPTimeRemaining();
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( level.empTimeout );
    level.teamEMPed[var_0] = 0;

    foreach ( var_2 in level.players )
    {
        if ( var_2.team != var_0 )
            continue;

        if ( var_2 maps\mp\_utility::_hasPerk( "specialty_localjammer" ) )
            var_2 radarjamon();
    }

    level notify( "emp_update" );
}

EMP_JamPlayers( var_0 )
{
    level notify( "EMP_JamPlayers" );
    level endon( "EMP_JamPlayers" );

    foreach ( var_2 in level.players )
    {
        var_2 playlocalsound( "emp_activate" );

        if ( var_2 == var_0 )
            continue;

        if ( var_2 maps\mp\_utility::_hasPerk( "specialty_localjammer" ) )
            var_2 radarjamoff();
    }

    visionsetnaked( "coup_sunblind", 0.1 );
    thread empEffects();
    wait 0.1;
    visionsetnaked( "coup_sunblind", 0 );

    if ( isdefined( level.nukeDetonated ) )
        visionsetnaked( level.nukeVisionSet, 3.0 );
    else
        visionsetnaked( "", 3.0 );

    level notify( "emp_update" );
    level.EMPPlayer = var_0;
    level.EMPPlayer thread empPlayerFFADisconnect();
    level destroyActiveVehicles( var_0 );
    level notify( "emp_update" );
    level thread keepEMPTimeRemaining();
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( level.empTimeout );

    foreach ( var_2 in level.players )
    {
        if ( var_2 == var_0 )
            continue;

        if ( var_2 maps\mp\_utility::_hasPerk( "specialty_localjammer" ) )
            var_2 radarjamon();
    }

    level.EMPPlayer = undefined;
    level notify( "emp_update" );
    level notify( "emp_ended" );
}

keepEMPTimeRemaining()
{
    level notify( "keepEMPTimeRemaining" );
    level endon( "keepEMPTimeRemaining" );
    level endon( "emp_ended" );

    for ( level.empTimeRemaining = int( level.empTimeout ); level.empTimeRemaining; level.empTimeRemaining-- )
        wait 1.0;
}

empPlayerFFADisconnect()
{
    level endon( "EMP_JamPlayers" );
    level endon( "emp_ended" );
    self waittill( "disconnect" );
    level notify( "emp_update" );
}

empEffects()
{
    foreach ( var_1 in level.players )
    {
        var_2 = anglestoforward( var_1.angles );
        var_2 = ( var_2[0], var_2[1], 0 );
        var_2 = vectornormalize( var_2 );
        var_3 = 20000;
        var_4 = spawn( "script_model", var_1.origin + ( 0, 0, 8000 ) + var_2 * var_3 );
        var_4 setmodel( "tag_origin" );
        var_4.angles = var_4.angles + ( 270, 0, 0 );
        var_4 thread empEffect( var_1 );
    }
}

empEffect( var_0 )
{
    var_0 endon( "disconnect" );
    wait 0.5;
    playfxontagforclients( level._effect["emp_flash"], self, "tag_origin", var_0 );
}

EMP_TeamTracker()
{
    level endon( "game_ended" );

    for (;;)
    {
        level common_scripts\utility::waittill_either( "joined_team", "emp_update" );

        foreach ( var_1 in level.players )
        {
            if ( var_1.team == "spectator" )
                continue;

            if ( !level.teamEMPed[var_1.team] && !var_1 maps\mp\_utility::isEMPed() )
            {
                var_1 setempjammed( 0 );
                continue;
            }

            var_1 setempjammed( 1 );
        }
    }
}

EMP_PlayerTracker()
{
    level endon( "game_ended" );

    for (;;)
    {
        level common_scripts\utility::waittill_either( "joined_team", "emp_update" );

        foreach ( var_1 in level.players )
        {
            if ( var_1.team == "spectator" )
                continue;

            if ( isdefined( level.EMPPlayer ) && level.EMPPlayer != var_1 )
            {
                var_1 setempjammed( 1 );
                continue;
            }

            if ( !var_1 maps\mp\_utility::isEMPed() )
                var_1 setempjammed( 0 );
        }
    }
}

destroyActiveVehicles( var_0, var_1 )
{
    thread destroyactivehelis( var_0, var_1 );
    thread destroyactivelittlebirds( var_0, var_1 );
    thread destroyactiveturrets( var_0, var_1 );
    thread destroyactiverockets( var_0, var_1 );
    thread destroyactiveuavs( var_0, var_1 );
    thread destroyactiveimss( var_0, var_1 );
    thread destroyactiveugvs( var_0, var_1 );
    thread destroyactiveac130( var_0, var_1 );
}

destroyactivehelis( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;

    foreach ( var_12 in level.helis )
    {
        if ( level.teamBased && isdefined( var_1 ) )
        {
            if ( isdefined( var_12.team ) && var_12.team != var_1 )
                continue;
        }
        else if ( isdefined( var_12.owner ) && var_12.owner == var_0 )
            continue;

        var_12 notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
        wait 0.05;
    }
}

destroyactivelittlebirds( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;

    foreach ( var_12 in level.littleBirds )
    {
        if ( level.teamBased && isdefined( var_1 ) )
        {
            if ( isdefined( var_12.team ) && var_12.team != var_1 )
                continue;
        }
        else if ( isdefined( var_12.owner ) && var_12.owner == var_0 )
            continue;

        var_12 notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
        wait 0.05;
    }
}

destroyactiveturrets( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;

    foreach ( var_12 in level.turrets )
    {
        if ( level.teamBased && isdefined( var_1 ) )
        {
            if ( isdefined( var_12.team ) && var_12.team != var_1 )
                continue;
        }
        else if ( isdefined( var_12.owner ) && var_12.owner == var_0 )
            continue;

        var_12 notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
        wait 0.05;
    }
}

destroyactiverockets( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;

    foreach ( var_12 in level.rockets )
    {
        if ( level.teamBased && isdefined( var_1 ) )
        {
            if ( isdefined( var_12.team ) && var_12.team != var_1 )
                continue;
        }
        else if ( isdefined( var_12.owner ) && var_12.owner == var_0 )
            continue;

        playfx( level.remotemissile_fx["explode"], var_12.origin );
        var_12 delete();
        wait 0.05;
    }
}

destroyactiveuavs( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;
    var_11 = level.uavmodels;

    if ( level.teamBased && isdefined( var_1 ) )
        var_11 = level.uavmodels[var_1];

    foreach ( var_13 in var_11 )
    {
        if ( level.teamBased && isdefined( var_1 ) )
        {

        }
        else if ( isdefined( var_13.owner ) && var_13.owner == var_0 )
            continue;

        var_13 notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
        wait 0.05;
    }
}

destroyactiveimss( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;

    foreach ( var_12 in level.ims )
    {
        if ( level.teamBased && isdefined( var_1 ) )
        {
            if ( isdefined( var_12.team ) && var_12.team != var_1 )
                continue;
        }
        else if ( isdefined( var_12.owner ) && var_12.owner == var_0 )
            continue;

        var_12 notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
        wait 0.05;
    }
}

destroyactiveugvs( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;

    foreach ( var_12 in level.ugvs )
    {
        if ( level.teamBased && isdefined( var_1 ) )
        {
            if ( isdefined( var_12.team ) && var_12.team != var_1 )
                continue;
        }
        else if ( isdefined( var_12.owner ) && var_12.owner == var_0 )
            continue;

        var_12 notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
        wait 0.05;
    }
}

destroyactiveac130( var_0, var_1 )
{
    var_2 = "MOD_EXPLOSIVE";
    var_3 = "killstreak_emp_mp";
    var_4 = 5000;
    var_5 = ( 0, 0, 0 );
    var_6 = ( 0, 0, 0 );
    var_7 = "";
    var_8 = "";
    var_9 = "";
    var_10 = undefined;

    if ( level.teamBased && isdefined( var_1 ) )
    {
        if ( isdefined( level.ac130player ) && isdefined( level.ac130player.team ) && level.ac130player.team == var_1 )
            level.ac130.planemodel notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
    }
    else if ( isdefined( level.ac130player ) )
    {
        if ( !isdefined( level.ac130.owner ) || isdefined( level.ac130.owner ) && level.ac130.owner != var_0 )
            level.ac130.planemodel notify( "damage",  var_4, var_0, var_5, var_6, var_2, var_7, var_8, var_9, var_10, var_3  );
    }
}
