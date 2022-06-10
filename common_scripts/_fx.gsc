// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

initFX()
{
    if ( !isdefined( level.func ) )
        level.func = [];

    if ( !isdefined( level.func["create_triggerfx"] ) )
        level.func["create_triggerfx"] = ::create_triggerfx;

    common_scripts\utility::create_lock( "createfx_looper", 20 );
    level.exploderFunction = common_scripts\utility::exploder_before_load;
    waittillframeend;
    waittillframeend;
    level.exploderFunction = common_scripts\utility::exploder_after_load;
    level.server_culled_sounds = 0;

    if ( getdvarint( "serverCulledSounds" ) == 1 )
        level.server_culled_sounds = 1;

    if ( level.createFX_enabled )
        level.server_culled_sounds = 0;

    if ( level.createFX_enabled )
        level waittill( "createfx_common_done" );

    if ( isdefined( level.delay_createfx_seconds ) )
        wait(level.delay_createfx_seconds);

    for ( var_0 = 0; var_0 < level.createFXent.size; var_0++ )
    {
        var_1 = level.createFXent[var_0];
        var_1 common_scripts\_createfx::set_forward_and_up_vectors();

        if ( var_1.v["type"] == "loopfx" )
            var_1 thread loopfxthread();

        if ( var_1.v["type"] == "oneshotfx" )
            var_1 thread OneShotfxthread();

        if ( var_1.v["type"] == "soundfx" )
            var_1 thread create_loopsound();

        if ( var_1.v["type"] == "soundfx_interval" )
            var_1 thread create_interval_sound();
    }
}

print_org( var_0, var_1, var_2, var_3 )
{
    if ( getdvar( "debug" ) == "1" )
        return;
}

OneShotfx( var_0, var_1, var_2, var_3 )
{

}

exploderfx( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11, var_12, var_13, var_14, var_15, var_16, var_17 )
{
    if ( 1 )
    {
        var_18 = common_scripts\utility::createExploder( var_1 );
        var_18.v["origin"] = var_2;
        var_18.v["angles"] = ( 0, 0, 0 );

        if ( isdefined( var_4 ) )
            var_18.v["angles"] = vectortoangles( var_4 - var_2 );

        var_18.v["delay"] = var_3;
        var_18.v["exploder"] = var_0;

        if ( isdefined( level.createFXexploders ) )
        {
            var_19 = level.createFXexploders[var_18.v["exploder"]];

            if ( !isdefined( var_19 ) )
                var_19 = [];

            var_19[var_19.size] = var_18;
            level.createFXexploders[var_18.v["exploder"]] = var_19;
        }

        return;
    }

    var_20 = spawn( "script_origin", ( 0, 0, 0 ) );
    var_20.origin = var_2;
    var_20.angles = vectortoangles( var_4 - var_2 );
    var_20.script_exploder = var_0;
    var_20.script_fxid = var_1;
    var_20.script_delay = var_3;
    var_20.script_firefx = var_5;
    var_20.script_firefxdelay = var_6;
    var_20.script_firefxsound = var_7;
    var_20.script_sound = var_8;
    var_20.script_earthquake = var_9;
    var_20.script_damage = var_10;
    var_20.script_radius = var_15;
    var_20.script_soundalias = var_11;
    var_20.script_firefxtimeout = var_16;
    var_20.script_repeat = var_12;
    var_20.script_delay_min = var_13;
    var_20.script_delay_max = var_14;
    var_20.script_exploder_group = var_17;
    var_21 = anglestoforward( var_20.angles );
    var_21 *= 150;
    var_20.targetPos = var_2 + var_21;

    if ( !isdefined( level._script_exploders ) )
        level._script_exploders = [];

    level._script_exploders[level._script_exploders.size] = var_20;
    common_scripts\_createfx::createfx_showOrigin( var_1, var_2, var_3, var_4, "exploderfx", var_20, undefined, var_5, var_6, var_7, var_8, var_9, var_10, var_11, var_12, var_13, var_14, var_15, var_16 );
}

loopfx( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    var_7 = common_scripts\utility::createLoopEffect( var_0 );
    var_7.v["origin"] = var_1;
    var_7.v["angles"] = ( 0, 0, 0 );

    if ( isdefined( var_3 ) )
        var_7.v["angles"] = vectortoangles( var_3 - var_1 );

    var_7.v["delay"] = var_2;
}

create_looper()
{
    self.looper = playloopedfx( level._effect[self.v["fxid"]], self.v["delay"], self.v["origin"], 0, self.v["forward"], self.v["up"] );
    create_loopsound();
}

create_loopsound()
{
    self notify( "stop_loop" );

    if ( isdefined( self.v["soundalias"] ) && self.v["soundalias"] != "nil" )
    {
        if ( isdefined( self.v["stopable"] ) && self.v["stopable"] )
        {
            if ( isdefined( self.looper ) )
                self.looper thread common_scripts\utility::loop_fx_sound( self.v["soundalias"], self.v["origin"], 0, "death" );
            else
                thread common_scripts\utility::loop_fx_sound( self.v["soundalias"], self.v["origin"], 0, "stop_loop" );
        }
        else if ( isdefined( self.looper ) )
            self.looper thread common_scripts\utility::loop_fx_sound( self.v["soundalias"], self.v["origin"], 0 );
        else
        {
            var_0 = 0;

            if ( level.server_culled_sounds == 1 && isdefined( self.v["server_culled"] ) )
                var_0 = self.v["server_culled"];

            thread common_scripts\utility::loop_fx_sound( self.v["soundalias"], self.v["origin"], var_0 );
        }
    }
}

create_interval_sound()
{
    self notify( "stop_loop" );

    if ( !isdefined( self.v["soundalias"] ) )
        return;

    if ( self.v["soundalias"] == "nil" )
        return;

    var_0 = undefined;
    var_1 = self;

    if ( isdefined( self.v["stopable"] ) && self.v["stopable"] || level.createFX_enabled )
    {
        if ( isdefined( self.looper ) )
        {
            var_1 = self.looper;
            var_0 = "death";
        }
        else
            var_0 = "stop_loop";
    }

    var_1 thread common_scripts\utility::loop_fx_sound_interval( self.v["soundalias"], self.v["origin"], var_0, undefined, self.v["delay_min"], self.v["delay_max"] );
}

loopfxthread()
{
    common_scripts\utility::waitframe();

    if ( isdefined( self.fxStart ) )
        level waittill( "start fx" + self.fxStart );

    for (;;)
    {
        create_looper();

        if ( isdefined( self.timeOut ) )
            thread loopfxStop( self.timeOut );

        if ( isdefined( self.fxStop ) )
            level waittill( "stop fx" + self.fxStop );
        else
            return;

        if ( isdefined( self.looper ) )
            self.looper delete();

        if ( isdefined( self.fxStart ) )
        {
            level waittill( "start fx" + self.fxStart );
            continue;
        }

        return;
    }
}

loopfxChangeID( var_0 )
{
    self endon( "death" );
    var_0 waittill( "effect id changed",  var_1  );
}

loopfxChangeOrg( var_0 )
{
    self endon( "death" );

    for (;;)
    {
        var_0 waittill( "effect org changed",  var_1  );
        self.origin = var_1;
    }
}

loopfxChangeDelay( var_0 )
{
    self endon( "death" );
    var_0 waittill( "effect delay changed",  var_1  );
}

loopfxDeletion( var_0 )
{
    self endon( "death" );
    var_0 waittill( "effect deleted" );
    self delete();
}

loopfxStop( var_0 )
{
    self endon( "death" );
    wait(var_0);
    self.looper delete();
}

loopSound( var_0, var_1, var_2 )
{
    level thread loopSoundthread( var_0, var_1, var_2 );
}

loopSoundthread( var_0, var_1, var_2 )
{
    var_3 = spawn( "script_origin", var_1 );
    var_3.origin = var_1;
    var_3 playloopsound( var_0 );
}

gunfireloopfx( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    thread gunfireloopfxthread( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 );
}

gunfireloopfxthread( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    level endon( "stop all gunfireloopfx" );
    common_scripts\utility::waitframe();

    if ( var_7 < var_6 )
    {
        var_8 = var_7;
        var_7 = var_6;
        var_6 = var_8;
    }

    var_9 = var_6;
    var_10 = var_7 - var_6;

    if ( var_5 < var_4 )
    {
        var_8 = var_5;
        var_5 = var_4;
        var_4 = var_8;
    }

    var_11 = var_4;
    var_12 = var_5 - var_4;

    if ( var_3 < var_2 )
    {
        var_8 = var_3;
        var_3 = var_2;
        var_2 = var_8;
    }

    var_13 = var_2;
    var_14 = var_3 - var_2;
    var_15 = spawnfx( level._effect[var_0], var_1 );

    if ( !level.createFX_enabled )
        var_15 willneverchange();

    for (;;)
    {
        var_16 = var_13 + randomint( var_14 );

        for ( var_17 = 0; var_17 < var_16; var_17++ )
        {
            triggerfx( var_15 );
            wait(var_11 + randomfloat( var_12 ));
        }

        wait(var_9 + randomfloat( var_10 ));
    }
}

gunfireloopfxVec( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    thread gunfireloopfxVecthread( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 );
}

gunfireloopfxVecthread( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    level endon( "stop all gunfireloopfx" );
    common_scripts\utility::waitframe();

    if ( var_8 < var_7 )
    {
        var_9 = var_8;
        var_8 = var_7;
        var_7 = var_9;
    }

    var_10 = var_7;
    var_11 = var_8 - var_7;

    if ( var_6 < var_5 )
    {
        var_9 = var_6;
        var_6 = var_5;
        var_5 = var_9;
    }

    var_12 = var_5;
    var_13 = var_6 - var_5;

    if ( var_4 < var_3 )
    {
        var_9 = var_4;
        var_4 = var_3;
        var_3 = var_9;
    }

    var_14 = var_3;
    var_15 = var_4 - var_3;
    var_2 = vectornormalize( var_2 - var_1 );
    var_16 = spawnfx( level._effect[var_0], var_1, var_2 );

    if ( !level.createFX_enabled )
        var_16 willneverchange();

    for (;;)
    {
        var_17 = var_14 + randomint( var_15 );

        for ( var_18 = 0; var_18 < int( var_17 / level.fxfireloopmod ); var_18++ )
        {
            triggerfx( var_16 );
            var_19 = ( var_12 + randomfloat( var_13 ) ) * level.fxfireloopmod;

            if ( var_19 < 0.05 )
                var_19 = 0.05;

            wait(var_19);
        }

        wait(var_12 + randomfloat( var_13 ));
        wait(var_10 + randomfloat( var_11 ));
    }
}

setfireloopmod( var_0 )
{
    level.fxfireloopmod = 1 / var_0;
}

setup_fx()
{
    if ( !isdefined( self.script_fxid ) || !isdefined( self.script_fxcommand ) || !isdefined( self.script_delay ) )
        return;

    if ( isdefined( self.model ) )
    {
        if ( self.model == "toilet" )
        {
            thread burnville_paratrooper_hack();
            return;
        }
    }

    var_0 = undefined;

    if ( isdefined( self.target ) )
    {
        var_1 = getent( self.target, "targetname" );

        if ( isdefined( var_1 ) )
            var_0 = var_1.origin;
    }

    var_2 = undefined;

    if ( isdefined( self.script_fxstart ) )
        var_2 = self.script_fxstart;

    var_3 = undefined;

    if ( isdefined( self.script_fxstop ) )
        var_3 = self.script_fxstop;

    if ( self.script_fxcommand == "OneShotfx" )
        OneShotfx( self.script_fxid, self.origin, self.script_delay, var_0 );

    if ( self.script_fxcommand == "loopfx" )
        loopfx( self.script_fxid, self.origin, self.script_delay, var_0, var_2, var_3 );

    if ( self.script_fxcommand == "loopsound" )
        loopSound( self.script_fxid, self.origin, self.script_delay );

    self delete();
}

burnville_paratrooper_hack()
{
    var_0 = ( 0, 0, self.angles[1] );
    var_1 = level._effect[self.script_fxid];
    var_2 = self.origin;
    wait 1;
    level thread burnville_paratrooper_hack_loop( var_0, var_2, var_1 );
    self delete();
}

burnville_paratrooper_hack_loop( var_0, var_1, var_2 )
{
    for (;;)
    {
        playfx( var_2, var_1 );
        wait(30 + randomfloat( 40 ));
    }
}

create_triggerfx()
{
    if ( !verify_effects_assignment( self.v["fxid"] ) )
        return;

    self.looper = spawnfx( level._effect[self.v["fxid"]], self.v["origin"], self.v["forward"], self.v["up"] );
    triggerfx( self.looper, self.v["delay"] );

    if ( !level.createFX_enabled )
        self.looper willneverchange();

    create_loopsound();
}

verify_effects_assignment( var_0 )
{
    if ( isdefined( level._effect[var_0] ) )
        return 1;

    if ( !isdefined( level._missing_FX ) )
        level._missing_FX = [];

    level._missing_FX[self.v["fxid"]] = var_0;
    verify_effects_assignment_print( var_0 );
    return 0;
}

verify_effects_assignment_print( var_0 )
{
    level notify( "verify_effects_assignment_print" );
    level endon( "verify_effects_assignment_print" );
    wait 0.05;
    var_1 = getarraykeys( level._missing_FX );

    foreach ( var_3 in var_1 )
    {

    }
}

OneShotfxthread()
{
    common_scripts\utility::waitframe();

    if ( self.v["delay"] > 0 )
        wait(self.v["delay"]);

    [[ level.func["create_triggerfx"] ]]();
}
