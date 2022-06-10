// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level thread onPlayerConnect();
    level thread onPlayerDisconnect();
    level.gamemode = "13";

    switch ( level.gameType )
    {
        case "war":
            var_0 = getdvarint( "party_maxplayers" );

            if ( var_0 == 4 )
                level.gamemode = "2";
            else if ( var_0 == 2 )
                level.gamemode = "1";
            else if ( level.hardcoreMode )
                level.gamemode = "3";
            else
                level.gamemode = "0";

            break;
        case "dm":
            if ( level.hardcoreMode )
                level.gamemode = "5";
            else
                level.gamemode = "4";

            break;
        case "sd":
            if ( level.hardcoreMode )
                level.gamemode = "7";
            else
                level.gamemode = "6";

            break;
        case "dom":
            if ( level.hardcoreMode )
                level.gamemode = "9";
            else
                level.gamemode = "8";

            break;
        case "dd":
            level.gamemode = "10";
            break;
        case "grnd":
            level.gamemode = "11";
            break;
        case "conf":
            level.gamemode = "12";
            break;
    }
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0.connectTime = gettime();
        var_0.targets = [];
        var_0 thread onWeaponFired();
        var_0 thread onDeath();
    }
}

onPlayerDisconnect()
{
    for (;;)
    {
        level waittill( "disconnected",  var_0  );
        var_0.targets = [];
    }
}

onWeaponFired()
{
    level endon( "game_ended" );
    self endon( "disconnected" );

    for (;;)
        self waittill( "weapon_fired" );
}

onDeath()
{
    level endon( "game_ended" );
    self endon( "disconnected" );

    for (;;)
        self waittill( "death" );
}

processKill( var_0, var_1 )
{
    updateskill( var_0, var_1, level.gamemode, 1.0 );
}
