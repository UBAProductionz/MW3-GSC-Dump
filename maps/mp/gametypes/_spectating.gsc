// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.spectateOverride["allies"] = spawnstruct();
    level.spectateOverride["axis"] = spawnstruct();
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0 thread onJoinedTeam();
        var_0 thread onJoinedSpectators();
        var_0 thread onSpectatingClient();
    }
}

onJoinedTeam()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_team" );
        setSpectatePermissions();
    }
}

onJoinedSpectators()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_spectators" );
        setSpectatePermissions();
    }
}

onSpectatingClient()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spectating_cycle" );
        var_0 = self getspectatingplayer();

        if ( isdefined( var_0 ) )
            self setcarddisplayslot( var_0, 6 );
    }
}

updateSpectateSettings()
{
    level endon( "game_ended" );

    for ( var_0 = 0; var_0 < level.players.size; var_0++ )
        level.players[var_0] setSpectatePermissions();
}

getOtherTeam( var_0 )
{
    if ( var_0 == "axis" )
        return "allies";
    else if ( var_0 == "allies" )
        return "axis";
    else
        return "none";
}

setSpectatePermissions()
{
    var_0 = self.sessionteam;

    if ( level.gameEnded && gettime() - level.gameEndTime >= 2000 )
    {
        self allowspectateteam( "allies", 0 );
        self allowspectateteam( "axis", 0 );
        self allowspectateteam( "freelook", 0 );
        self allowspectateteam( "none", 1 );
        return;
    }

    var_1 = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "spectatetype" );

    switch ( var_1 )
    {
        case 0:
            self allowspectateteam( "allies", 0 );
            self allowspectateteam( "axis", 0 );
            self allowspectateteam( "freelook", 0 );
            self allowspectateteam( "none", 0 );
            break;
        case 1:
            if ( !level.teamBased )
            {
                self allowspectateteam( "allies", 1 );
                self allowspectateteam( "axis", 1 );
                self allowspectateteam( "none", 1 );
                self allowspectateteam( "freelook", 0 );
            }
            else if ( isdefined( var_0 ) && ( var_0 == "allies" || var_0 == "axis" ) )
            {
                self allowspectateteam( var_0, 1 );
                self allowspectateteam( getOtherTeam( var_0 ), 0 );
                self allowspectateteam( "freelook", 0 );
                self allowspectateteam( "none", 0 );
            }
            else
            {
                self allowspectateteam( "allies", 0 );
                self allowspectateteam( "axis", 0 );
                self allowspectateteam( "freelook", 0 );
                self allowspectateteam( "none", 0 );
            }

            break;
        case 2:
            self allowspectateteam( "allies", 1 );
            self allowspectateteam( "axis", 1 );
            self allowspectateteam( "freelook", 1 );
            self allowspectateteam( "none", 1 );
            break;
    }

    if ( isdefined( var_0 ) && ( var_0 == "axis" || var_0 == "allies" ) )
    {
        if ( isdefined( level.spectateOverride[var_0].allowFreeSpectate ) )
            self allowspectateteam( "freelook", 1 );

        if ( isdefined( level.spectateOverride[var_0].allowEnemySpectate ) )
            self allowspectateteam( getOtherTeam( var_0 ), 1 );
    }
}
