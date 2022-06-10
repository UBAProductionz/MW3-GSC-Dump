// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( !level.teamBased )
        return;

    precacheshader( "headicon_dead" );
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0.selfDeathIcons = [];
    }
}

updateDeathIconsEnabled()
{

}

addDeathIcon( var_0, var_1, var_2, var_3 )
{
    if ( !level.teamBased )
        return;

    var_4 = var_0.origin;
    var_1 endon( "spawned_player" );
    var_1 endon( "disconnect" );
    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();

    if ( getdvar( "ui_hud_showdeathicons" ) == "0" )
        return;

    if ( level.hardcoreMode )
        return;

    if ( isdefined( self.lastDeathIcon ) )
        self.lastDeathIcon destroy();

    var_5 = newteamhudelem( var_2 );
    var_5.x = var_4[0];
    var_5.y = var_4[1];
    var_5.z = var_4[2] + 54;
    var_5.alpha = 0.61;
    var_5.archived = 1;

    if ( level.splitscreen )
        var_5 setshader( "headicon_dead", 14, 14 );
    else
        var_5 setshader( "headicon_dead", 7, 7 );

    var_5 setwaypoint( 0 );
    self.lastDeathIcon = var_5;
    var_5 thread destroySlowly( var_3 );
}

destroySlowly( var_0 )
{
    self endon( "death" );
    wait(var_0);
    self fadeovertime( 1.0 );
    self.alpha = 0;
    wait 1.0;
    self destroy();
}
