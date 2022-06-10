// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    level._pipe_fx_time = 25;
    var_0 = getentarray( "pipe_shootable", "targetname" );

    if ( !var_0.size )
        return;

    level._pipes = spawnstruct();
    level._pipes.num_pipe_fx = 0;
    var_0 thread precacheFX();
    var_0 thread methodsInit();
    waittillframeend;
    common_scripts\utility::array_thread( var_0, ::pipesetup );
}

pipesetup()
{
    self setcandamage( 1 );
    self setcanradiusdamage( 0 );
    self.pipe_fx_array = [];
    var_0 = undefined;

    if ( isdefined( self.target ) )
    {
        var_0 = common_scripts\utility::getstruct( self.target, "targetname" );
        self.A = var_0.origin;
        var_1 = anglestoforward( var_0.angles );
        var_1 *= 128;
        self.B = self.A + var_1;
    }
    else
    {
        var_1 = anglestoforward( self.angles );
        var_2 = var_1 * 64;
        self.A = self.origin + var_2;
        var_2 = var_1 * -64;
        self.B = self.origin + var_2;
    }

    thread pipe_wait_loop();
}

pipe_wait_loop()
{
    var_0 = ( 0, 0, 0 );
    var_1 = 0;
    var_2 = 4;

    for (;;)
    {
        self waittill( "damage",  var_3, var_4, var_5, var_0, var_6  );

        if ( var_1 )
        {
            if ( randomint( 100 ) <= 33 )
                continue;
        }

        var_1 = 1;
        var_7 = pipe_logic( var_5, var_0, var_6, var_4 );

        if ( var_7 )
            var_2--;

        if ( var_2 <= 0 )
            break;
    }

    self setcandamage( 0 );
}

pipe_logic( var_0, var_1, var_2, var_3 )
{
    if ( level._pipes.num_pipe_fx > 8 )
        return 0;

    if ( !isdefined( level._pipes._pipe_methods[var_2] ) )
        var_1 = pipe_calc_nofx( var_1, var_2 );
    else
        var_1 = self [[ level._pipes._pipe_methods[var_2] ]]( var_1, var_2 );

    if ( !isdefined( var_1 ) )
        return 0;

    if ( isdefined( var_3.classname ) && var_3.classname == "worldspawn" )
        return 0;

    foreach ( var_5 in self.pipe_fx_array )
    {
        if ( distancesquared( var_1, var_5.origin ) < 25 )
            return 0;
    }

    var_7 = vectorfromlinetopoint( self.A, self.B, var_1 );
    thread pipefx( var_1, var_7, var_3 );
    return 1;
}

pipefx( var_0, var_1, var_2 )
{
    var_3 = level._pipes.fx_time[self.script_noteworthy];
    var_4 = int( level._pipe_fx_time / var_3 );
    var_5 = level._pipes._sound[self.script_noteworthy + "_hit"];
    var_6 = level._pipes._sound[self.script_noteworthy + "_loop"];
    var_7 = level._pipes._sound[self.script_noteworthy + "_end"];
    var_8 = spawn( "script_origin", var_0 );
    var_8 hide();
    var_8 playsound( var_5 );
    var_8 playloopsound( var_6 );
    self.pipe_fx_array[self.pipe_fx_array.size] = var_8;
    level._pipes.num_pipe_fx++;

    if ( common_scripts\utility::isSP() || self.script_noteworthy != "steam" )
        thread pipe_damage( var_0, var_1, var_2, var_8 );

    playfx( level._pipes._effect[self.script_noteworthy], var_0, var_1 );
    wait(var_3);

    for ( var_4--; level._pipes.num_pipe_fx <= 8 && var_4 > 0; var_4-- )
    {
        playfx( level._pipes._effect[self.script_noteworthy], var_0, var_1 );
        wait(var_3);
    }

    var_8 playsound( var_7 );
    wait 0.5;
    var_8 stoploopsound( var_6 );
    var_8 delete();
    self.pipe_fx_array = common_scripts\utility::array_removeUndefined( self.pipe_fx_array );
    level._pipes.num_pipe_fx--;
}

pipe_damage( var_0, var_1, var_2, var_3 )
{
    if ( !allow_pipe_damage() )
        return;

    var_3 endon( "death" );
    var_4 = var_3.origin + vectornormalize( var_1 ) * 40;
    var_5 = level._pipes._dmg[self.script_noteworthy];

    for (;;)
    {
        if ( !isdefined( self.damageOwner ) )
            self radiusdamage( var_4, 36, var_5, var_5 * 0.75, undefined, "MOD_TRIGGER_HURT" );
        else
            self radiusdamage( var_4, 36, var_5, var_5 * 0.75, var_2, "MOD_TRIGGER_HURT" );

        wait 0.4;
    }
}

allow_pipe_damage()
{
    if ( !common_scripts\utility::isSP() )
        return 0;

    if ( !isdefined( level.pipesDamage ) )
        return 1;

    return level.pipesDamage;
}

methodsInit()
{
    level._pipes._pipe_methods = [];
    level._pipes._pipe_methods["MOD_UNKNOWN"] = ::pipe_calc_splash;
    level._pipes._pipe_methods["MOD_PISTOL_BULLET"] = ::pipe_calc_ballistic;
    level._pipes._pipe_methods["MOD_RIFLE_BULLET"] = ::pipe_calc_ballistic;
    level._pipes._pipe_methods["MOD_GRENADE"] = ::pipe_calc_splash;
    level._pipes._pipe_methods["MOD_GRENADE_SPLASH"] = ::pipe_calc_splash;
    level._pipes._pipe_methods["MOD_PROJECTILE"] = ::pipe_calc_splash;
    level._pipes._pipe_methods["MOD_PROJECTILE_SPLASH"] = ::pipe_calc_splash;
    level._pipes._pipe_methods["MOD_TRIGGER_HURT"] = ::pipe_calc_splash;
    level._pipes._pipe_methods["MOD_EXPLOSIVE"] = ::pipe_calc_splash;
    level._pipes._pipe_methods["MOD_EXPLOSIVE_BULLET"] = ::pipe_calc_splash;
}

pipe_calc_ballistic( var_0, var_1 )
{
    return var_0;
}

pipe_calc_splash( var_0, var_1 )
{
    var_2 = vectornormalize( vectorfromlinetopoint( self.A, self.B, var_0 ) );
    var_0 = pointonsegmentnearesttopoint( self.A, self.B, var_0 );
    return var_0 + var_2 * 4;
}

pipe_calc_nofx( var_0, var_1 )
{
    return undefined;
}

precacheFX()
{
    var_0 = 0;
    var_1 = 0;

    foreach ( var_3 in self )
    {
        if ( var_3.script_noteworthy == "water" )
            var_3.script_noteworthy = "steam";

        if ( var_3.script_noteworthy == "steam" )
        {
            var_3 willneverchange();
            var_0 = 1;
            continue;
        }

        if ( var_3.script_noteworthy == "fire" )
        {
            var_3 willneverchange();
            var_1 = 1;
            continue;
        }
    }

    if ( var_0 )
    {
        level._pipes._effect["steam"] = loadfx( "impacts/pipe_steam" );
        level._pipes._sound["steam_hit"] = "mtl_steam_pipe_hit";
        level._pipes._sound["steam_loop"] = "mtl_steam_pipe_hiss_loop";
        level._pipes._sound["steam_end"] = "mtl_steam_pipe_hiss_loop_end";
        level._pipes.fx_time["steam"] = 3;
        level._pipes._dmg["steam"] = 5;
    }

    if ( var_1 )
    {
        level._pipes._effect["fire"] = loadfx( "impacts/pipe_fire" );
        level._pipes._sound["fire_hit"] = "mtl_gas_pipe_hit";
        level._pipes._sound["fire_loop"] = "mtl_gas_pipe_flame_loop";
        level._pipes._sound["fire_end"] = "mtl_gas_pipe_flame_end";
        level._pipes.fx_time["fire"] = 3;
        level._pipes._dmg["fire"] = 5;
    }
}
