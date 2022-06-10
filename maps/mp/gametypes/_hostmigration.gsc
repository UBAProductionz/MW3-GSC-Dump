// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

Callback_HostMigration()
{
    level.hostMigrationReturnedPlayerCount = 0;

    if ( level.gameEnded )
        return;

    level.hostMigrationTimer = 1;
    setdvar( "ui_inhostmigration", 1 );
    level notify( "host_migration_begin" );
    maps\mp\gametypes\_gamelogic::UpdateTimerPausedness();

    foreach ( var_1 in level.players )
        var_1 thread hostMigrationTimerThink();

    level endon( "host_migration_begin" );
    hostMigrationWait();
    level.hostMigrationTimer = undefined;
    setdvar( "ui_inhostmigration", 0 );
    level notify( "host_migration_end" );
    maps\mp\gametypes\_gamelogic::UpdateTimerPausedness();
    level thread maps\mp\gametypes\_gamelogic::updateGameEvents();
}

hostMigrationWait()
{
    level endon( "game_ended" );
    level.inGracePeriod = 25;
    thread maps\mp\gametypes\_gamelogic::matchStartTimer( "waiting_for_players", 20.0 );
    hostMigrationWaitForPlayers();
    level.inGracePeriod = 10;
    thread maps\mp\gametypes\_gamelogic::matchStartTimer( "match_resuming_in", 5.0 );
    wait 5;
    level.inGracePeriod = 0;
}

hostMigrationWaitForPlayers()
{
    level endon( "hostmigration_enoughplayers" );
    wait 15;
}

hostMigrationTimerThink_Internal()
{
    level endon( "host_migration_begin" );
    level endon( "host_migration_end" );
    self.hostMigrationControlsFrozen = 0;

    while ( !maps\mp\_utility::isReallyAlive( self ) )
        self waittill( "spawned" );

    self.hostMigrationControlsFrozen = 1;
    maps\mp\_utility::freezeControlsWrapper( 1 );
    level waittill( "host_migration_end" );
}

hostMigrationTimerThink()
{
    self endon( "disconnect" );
    self setclientdvar( "cg_scoreboardPingGraph", "0" );
    hostMigrationTimerThink_Internal();

    if ( self.hostMigrationControlsFrozen )
        maps\mp\_utility::freezeControlsWrapper( 0 );

    self setclientdvar( "cg_scoreboardPingGraph", "1" );
}

waitTillHostMigrationDone()
{
    if ( !isdefined( level.hostMigrationTimer ) )
        return 0;

    var_0 = gettime();
    level waittill( "host_migration_end" );
    return gettime() - var_0;
}

waitTillHostMigrationDone( var_0 )
{
    if ( isdefined( level.hostMigrationTimer ) )
        return;

    level endon( "host_migration_begin" );
    wait(var_0);
}

waitLongDurationWithHostMigrationPause( var_0 )
{
    if ( var_0 == 0 )
        return;

    var_1 = gettime();
    var_2 = gettime() + var_0 * 1000;

    while ( gettime() < var_2 )
    {
        waitTillHostMigrationDone( ( var_2 - gettime() ) / 1000 );

        if ( isdefined( level.hostMigrationTimer ) )
        {
            var_3 = waitTillHostMigrationDone();
            var_2 += var_3;
        }
    }

    waitTillHostMigrationDone();
    return gettime() - var_1;
}

waitLongDurationWithGameEndTimeUpdate( var_0 )
{
    if ( var_0 == 0 )
        return;

    var_1 = gettime();
    var_2 = gettime() + var_0 * 1000;

    while ( gettime() < var_2 )
    {
        waitTillHostMigrationDone( ( var_2 - gettime() ) / 1000 );

        while ( isdefined( level.hostMigrationTimer ) )
        {
            var_2 += 1000;
            setgameendtime( int( var_2 ) );
            wait 1;
        }
    }

    while ( isdefined( level.hostMigrationTimer ) )
    {
        var_2 += 1000;
        setgameendtime( int( var_2 ) );
        wait 1;
    }

    return gettime() - var_1;
}
