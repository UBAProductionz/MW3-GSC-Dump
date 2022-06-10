// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.softLandingTriggers = getentarray( "trigger_multiple_softlanding", "classname" );
    var_0 = getentarray( "destructible_vehicle", "targetname" );

    foreach ( var_2 in level.softLandingTriggers )
    {
        if ( var_2.script_type != "car" )
            continue;

        foreach ( var_4 in var_0 )
        {
            if ( distance( var_2.origin, var_4.origin ) > 64.0 )
                continue;

            var_2.destructible = var_4;
        }
    }

    thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0.softLanding = undefined;
        var_0 thread softLandingWaiter();
    }
}

playerEnterSoftLanding( var_0 )
{
    self.softLanding = var_0;
}

playerLeaveSoftLanding( var_0 )
{
    self.softLanding = undefined;
}

softLandingWaiter()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "soft_landing",  var_0, var_1  );

        if ( !isdefined( var_0.destructible ) )
            continue;
    }
}
