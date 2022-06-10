// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    precacheshellshock( "flashbang_mp" );
}

startMonitoringFlash()
{
    thread monitorFlash();
}

stopMonitoringFlash( var_0 )
{
    self notify( "stop_monitoring_flash" );
}

flashRumbleLoop( var_0 )
{
    self endon( "stop_monitoring_flash" );
    self endon( "flash_rumble_loop" );
    self notify( "flash_rumble_loop" );
    var_1 = gettime() + var_0 * 1000;

    while ( gettime() < var_1 )
    {
        self playrumbleonentity( "damage_heavy" );
        wait 0.05;
    }
}

monitorFlash()
{
    self endon( "disconnect" );
    self.flashEndTime = 0;

    for (;;)
    {
        self waittill( "flashbang",  var_0, var_1, var_2, var_3  );

        if ( !isalive( self ) )
            continue;

        if ( isdefined( self.usingRemote ) )
            continue;

        var_4 = 0;
        var_5 = 1;

        if ( var_2 < 0.25 )
            var_2 = 0.25;
        else if ( var_2 > 0.8 )
            var_2 = 1;

        var_6 = var_1 * var_2 * 5.5;

        if ( isdefined( self.stunScaler ) )
            var_6 *= self.stunScaler;

        if ( var_6 < 0.25 )
            continue;

        var_7 = undefined;

        if ( var_6 > 2 )
            var_7 = 0.75;
        else
            var_7 = 0.25;

        if ( level.teamBased && isdefined( var_3 ) && isdefined( var_3.pers["team"] ) && var_3.pers["team"] == self.pers["team"] && var_3 != self )
        {
            if ( level.friendlyfire == 0 )
                continue;
            else if ( level.friendlyfire == 1 )
            {

            }
            else if ( level.friendlyfire == 2 )
            {
                var_6 *= 0.5;
                var_7 *= 0.5;
                var_5 = 0;
                var_4 = 1;
            }
            else if ( level.friendlyfire == 3 )
            {
                var_6 *= 0.5;
                var_7 *= 0.5;
                var_4 = 1;
            }
        }
        else if ( isdefined( var_3 ) )
        {
            var_3 notify( "flash_hit" );

            if ( var_3 != self )
                var_3 maps\mp\gametypes\_missions::processChallenge( "ch_indecentexposure" );
        }

        if ( var_5 && isdefined( self ) )
        {
            thread applyFlash( var_6, var_7 );

            if ( isdefined( var_3 ) && var_3 != self )
            {
                var_3 thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "flash" );
                var_8 = self;

                if ( isplayer( var_3 ) && var_3 isitemunlocked( "specialty_paint" ) && var_3 maps\mp\_utility::_hasPerk( "specialty_paint" ) )
                {
                    if ( !var_8 maps\mp\perks\_perkfunctions::isPainted() )
                        var_3 maps\mp\gametypes\_missions::processChallenge( "ch_paint_pro" );

                    var_8 thread maps\mp\perks\_perkfunctions::setPainted();
                }
            }
        }

        if ( var_4 && isdefined( var_3 ) )
            var_3 thread applyFlash( var_6, var_7 );
    }
}

applyFlash( var_0, var_1 )
{
    if ( !isdefined( self.flashDuration ) || var_0 > self.flashDuration )
        self.flashDuration = var_0;

    if ( !isdefined( self.flashRumbleDuration ) || var_1 > self.flashRumbleDuration )
        self.flashRumbleDuration = var_1;

    wait 0.05;

    if ( isdefined( self.flashDuration ) )
    {
        self shellshock( "flashbang_mp", self.flashDuration );
        self.flashEndTime = gettime() + self.flashDuration * 1000;
    }

    if ( isdefined( self.flashRumbleDuration ) )
        thread flashRumbleLoop( self.flashRumbleDuration );

    self.flashDuration = undefined;
    self.flashRumbleDuration = undefined;
}

isFlashbanged()
{
    return isdefined( self.flashEndTime ) && gettime() < self.flashEndTime;
}
