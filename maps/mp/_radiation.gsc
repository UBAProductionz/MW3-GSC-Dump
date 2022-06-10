// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

radiation()
{
    precachestring( &"SCRIPT_RADIATION_DEATH" );
    var_0 = getentarray( "radiation", "targetname" );

    if ( var_0.size > 0 )
    {
        precacheshellshock( "mp_radiation_low" );
        precacheshellshock( "mp_radiation_med" );
        precacheshellshock( "mp_radiation_high" );

        foreach ( var_2 in var_0 )
            var_2 thread common_scripts\_dynamic_world::triggerTouchThink( ::playerEnterArea, ::playerLeaveArea );

        thread onPlayerConnect();
    }
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0.numAreas = 0;
    }
}

playerEnterArea( var_0 )
{
    self.numAreas++;

    if ( self.numAreas == 1 )
        radiationEffect();
}

playerLeaveArea( var_0 )
{
    self.numAreas--;

    if ( self.numAreas != 0 )
        return;

    self.poison = 0;
    self notify( "leftTrigger" );

    if ( isdefined( self.radiationOverlay ) )
        self.radiationOverlay fadeoutBlackOut( 0.1, 0 );
}

soundWatcher( var_0 )
{
    common_scripts\utility::waittill_any( "death", "leftTrigger" );
    self stoploopsound();
}

radiationEffect()
{
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "death" );
    self endon( "leftTrigger" );
    self.poison = 0;
    thread soundWatcher( self );

    for (;;)
    {
        self.poison++;

        switch ( self.poison )
        {
            case 1:
                self.radiationSound = "item_geigercouner_level2";
                self playloopsound( self.radiationSound );
                self viewkick( 1, self.origin );
                break;
            case 3:
                self shellshock( "mp_radiation_low", 4 );
                self.radiationSound = "item_geigercouner_level3";
                self stoploopsound();
                self playloopsound( self.radiationSound );
                self viewkick( 3, self.origin );
                doRadiationDamage( 15 );
                break;
            case 4:
                self shellshock( "mp_radiation_med", 5 );
                self.radiationSound = "item_geigercouner_level3";
                self stoploopsound();
                self playloopsound( self.radiationSound );
                self viewkick( 15, self.origin );
                thread blackout();
                doRadiationDamage( 25 );
                break;
            case 6:
                self shellshock( "mp_radiation_high", 5 );
                self.radiationSound = "item_geigercouner_level4";
                self stoploopsound();
                self playloopsound( self.radiationSound );
                self viewkick( 75, self.origin );
                doRadiationDamage( 45 );
                break;
            case 8:
                self shellshock( "mp_radiation_high", 5 );
                self.radiationSound = "item_geigercouner_level4";
                self stoploopsound();
                self playloopsound( self.radiationSound );
                self viewkick( 127, self.origin );
                doRadiationDamage( 175 );
                break;
        }

        wait 1;
    }

    wait 5;
}

blackout()
{
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "death" );
    self endon( "leftTrigger" );

    if ( !isdefined( self.radiationOverlay ) )
    {
        self.radiationOverlay = newclienthudelem( self );
        self.radiationOverlay.x = 0;
        self.radiationOverlay.y = 0;
        self.radiationOverlay setshader( "black", 640, 480 );
        self.radiationOverlay.alignx = "left";
        self.radiationOverlay.aligny = "top";
        self.radiationOverlay.horzalign = "fullscreen";
        self.radiationOverlay.vertalign = "fullscreen";
        self.radiationOverlay.alpha = 0;
    }

    var_0 = 1;
    var_1 = 2;
    var_2 = 0.25;
    var_3 = 1;
    var_4 = 5;
    var_5 = 100;
    var_6 = 0;

    for (;;)
    {
        while ( self.poison > 1 )
        {
            var_7 = var_5 - var_4;
            var_6 = ( self.poison - var_4 ) / var_7;

            if ( var_6 < 0 )
                var_6 = 0;
            else if ( var_6 > 1 )
                var_6 = 1;

            var_8 = var_1 - var_0;
            var_9 = var_0 + var_8 * ( 1 - var_6 );
            var_10 = var_3 - var_2;
            var_11 = var_2 + var_10 * var_6;
            var_12 = var_6 * 0.5;

            if ( var_6 == 1 )
                break;

            var_13 = var_9 / 2;
            self.radiationOverlay fadeinBlackOut( var_13, var_11 );
            self.radiationOverlay fadeoutBlackOut( var_13, var_12 );
            wait(var_6 * 0.5);
        }

        if ( var_6 == 1 )
            break;

        if ( self.radiationOverlay.alpha != 0 )
            self.radiationOverlay fadeoutBlackOut( 1, 0 );

        wait 0.05;
    }

    self.radiationOverlay fadeinBlackOut( 2, 0 );
}

doRadiationDamage( var_0 )
{
    self thread [[ level.callbackPlayerDamage ]]( self, self, var_0, 0, "MOD_SUICIDE", "claymore_mp", self.origin, ( 0, 0, 0 ) - self.origin, "none", 0 );
}

fadeinBlackOut( var_0, var_1 )
{
    self fadeovertime( var_0 );
    self.alpha = var_1;
    wait(var_0);
}

fadeoutBlackOut( var_0, var_1 )
{
    self fadeovertime( var_0 );
    self.alpha = var_1;
    wait(var_0);
}
