// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.destructibleSpawnedEntsLimit = 50;
    level.destructibleSpawnedEnts = [];
    level.currentCarAlarms = 0;
    level.commonStartTime = gettime();

    if ( !isdefined( level.fast_destructible_explode ) )
        level.fast_destructible_explode = 0;

    if ( !isdefined( level.func ) )
        level.func = [];

    var_0 = 1;

    if ( var_0 )
        find_destructibles();

    var_1 = getentarray( "delete_on_load", "targetname" );

    foreach ( var_3 in var_1 )
        var_3 delete();

    init_destroyed_count();
    init_destructible_frame_queue();
}

warn_about_old_destructible()
{
    wait 1;
    var_0 = getentarray( "destructible", "targetname" );

    if ( var_0.size != 0 )
    {
        foreach ( var_2 in var_0 )
        {

        }
    }
}

find_destructibles()
{
    var_0 = [];

    switch ( getdvar( "mapname" ) )
    {
        case "mp_interchange":
            var_0[var_0.size] = ( 4172.8, -1887, 345.9 );
            var_0[var_0.size] = ( 4070.5, -2049.2, 349.2 );
            var_0[var_0.size] = ( 3333.3, -1743.4, 345.6 );
            var_0[var_0.size] = ( 3503.7, -1634.5, 345.6 );
            var_0[var_0.size] = ( 2852.6, -1220.7, 345.6 );
            var_0[var_0.size] = ( 2451.2, -1034.6, 345.6 );
            var_0[var_0.size] = ( 1719.8, -711, 328.5 );
            var_0[var_0.size] = ( 2920.1, -3423.3, 416.6 );
            var_0[var_0.size] = ( 2694.9, -3433, 414.4 );
            var_0[var_0.size] = ( 1497.2, -2220.9, 449.5 );
            var_0[var_0.size] = ( 1276.2, -1882.9, 403 );
            var_0[var_0.size] = ( 845.6, -1766.3, 400.6 );
            var_0[var_0.size] = ( -2038.3, 613, 378 );
            var_0[var_0.size] = ( -2966.6, 1288.5, 378 );
            var_0[var_0.size] = ( -1347.8, 2905.9, 445.9 );
            var_0[var_0.size] = ( -1030.6, 2989.5, 445.5 );
            var_0[var_0.size] = ( -29.3, 695.7, 349 );
            var_0[var_0.size] = ( 1418.6, 311.3, 602.1 );
            var_0[var_0.size] = ( 1662.3, 687.5, 599.9 );
            var_0[var_0.size] = ( 2061.6, 643.2, 597.7 );
            var_0[var_0.size] = ( 2096, 1042.5, 580.4 );
            var_0[var_0.size] = ( 3.4, -912.9, 646.9 );
            break;
    }

    var_1 = [];

    foreach ( var_3 in level.struct )
    {
        if ( isdefined( var_3.script_noteworthy ) && var_3.script_noteworthy == "destructible_dot" )
            var_1[var_1.size] = var_3;
    }

    var_5 = getentarray( "destructible_vehicle", "targetname" );

    foreach ( var_7 in var_5 )
    {
        switch ( getdvar( "mapname" ) )
        {
            case "mp_interchange":
                if ( var_7.origin[2] > 150.0 )
                {
                    var_8 = 0;

                    foreach ( var_10 in var_0 )
                    {
                        if ( int( var_7.origin[0] ) == int( var_10[0] ) && int( var_7.origin[1] ) == int( var_10[1] ) && int( var_7.origin[2] ) == int( var_10[2] ) )
                        {
                            var_8 = 1;
                            break;
                        }
                    }

                    if ( var_8 )
                        continue;
                }

                break;
        }

        var_7 setup_destructibles();
        var_7 setup_destructible_dots( var_1 );
    }

    var_13 = getentarray( "destructible_toy", "targetname" );

    foreach ( var_15 in var_13 )
    {
        var_15 setup_destructibles();
        var_15 setup_destructible_dots( var_1 );
    }
}

setup_destructible_dots( var_0 )
{
    var_1 = self.destructibleInfo;

    foreach ( var_3 in var_0 )
    {
        if ( isdefined( level.destructible_type[var_1].destructible_dots ) )
            return;

        if ( isdefined( var_3._unk_field_ID5711 ) && issubstr( var_3._unk_field_ID5711, "destructible_type" ) && issubstr( var_3._unk_field_ID5711, self.destructible_type ) )
        {
            if ( distancesquared( self.origin, var_3.origin ) < 1 )
            {
                var_4 = getentarray( var_3.target, "targetname" );
                level.destructible_type[var_1].destructible_dots = [];

                foreach ( var_6 in var_4 )
                {
                    var_7 = var_6._unk_field_ID5797;

                    if ( !isdefined( level.destructible_type[var_1].destructible_dots[var_7] ) )
                        level.destructible_type[var_1].destructible_dots[var_7] = [];

                    var_8 = level.destructible_type[var_1].destructible_dots[var_7].size;
                    level.destructible_type[var_1].destructible_dots[var_7][var_8]["classname"] = var_6.classname;
                    level.destructible_type[var_1].destructible_dots[var_7][var_8]["origin"] = var_6.origin;
                    var_9 = common_scripts\utility::ter_op( isdefined( var_6.spawnflags ), var_6.spawnflags, 0 );
                    level.destructible_type[var_1].destructible_dots[var_7][var_8]["spawnflags"] = var_9;

                    switch ( var_6.classname )
                    {
                        case "trigger_radius":
                            level.destructible_type[var_1].destructible_dots[var_7][var_8]["radius"] = var_6.height;
                            level.destructible_type[var_1].destructible_dots[var_7][var_8]["height"] = var_6.height;
                            break;
                    }

                    endswitch( 2 )  case "trigger_radius" loc_4F2 default loc_527
                    var_6 delete();
                }

                break;
            }
        }
    }
}

setup_destructibles( var_0 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 0;

    var_1 = undefined;
    self.modeldummyon = 0;
    add_damage_owner_recorder();
    self.destructibleInfo = common_scripts\_destructible_types::makeType( self.destructible_type );

    if ( self.destructibleInfo < 0 )
        return;

    if ( !var_0 )
        precache_destructibles();

    add_destructible_fx();

    if ( isdefined( level.destructible_type[self.destructibleInfo].parts ) )
    {
        self.destructible_parts = [];

        for ( var_3 = 0; var_3 < level.destructible_type[self.destructibleInfo].parts.size; var_3++ )
        {
            self.destructible_parts[var_3] = spawnstruct();
            self.destructible_parts[var_3].v["currentState"] = 0;

            if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_3][0].v["health"] ) )
                self.destructible_parts[var_3].v["health"] = level.destructible_type[self.destructibleInfo].parts[var_3][0].v["health"];

            if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_3][0].v["random_dynamic_attachment_1"] ) )
            {
                var_4 = randomint( level.destructible_type[self.destructibleInfo].parts[var_3][0].v["random_dynamic_attachment_1"].size );
                var_5 = level.destructible_type[self.destructibleInfo].parts[var_3][0].v["random_dynamic_attachment_tag"][var_4];
                var_6 = level.destructible_type[self.destructibleInfo].parts[var_3][0].v["random_dynamic_attachment_1"][var_4];
                var_7 = level.destructible_type[self.destructibleInfo].parts[var_3][0].v["random_dynamic_attachment_2"][var_4];
                var_8 = level.destructible_type[self.destructibleInfo].parts[var_3][0].v["clipToRemove"][var_4];
                thread do_random_dynamic_attachment( var_5, var_6, var_7, var_8 );
            }

            if ( var_3 == 0 )
                continue;

            var_9 = level.destructible_type[self.destructibleInfo].parts[var_3][0].v["modelName"];
            var_10 = level.destructible_type[self.destructibleInfo].parts[var_3][0].v["tagName"];

            for ( var_11 = 1; isdefined( level.destructible_type[self.destructibleInfo].parts[var_3][var_11] ); var_11++ )
            {
                var_12 = level.destructible_type[self.destructibleInfo].parts[var_3][var_11].v["tagName"];
                var_13 = level.destructible_type[self.destructibleInfo].parts[var_3][var_11].v["modelName"];

                if ( isdefined( var_12 ) && var_12 != var_10 )
                {
                    hideapart( var_12 );

                    if ( self.modeldummyon )
                        self.modeldummy hideapart( var_12 );
                }
            }
        }
    }

    if ( isdefined( self.target ) )
        thread destructible_handles_collision_brushes();

    if ( self.code_classname != "script_vehicle" )
        self setcandamage( 1 );

    if ( common_scripts\utility::isSP() )
        thread connectTraverses();

    thread destructible_think();
}

destructible_create( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( !isdefined( level.destructible_type ) )
        level.destructible_type = [];

    var_6 = level.destructible_type.size;
    var_6 = level.destructible_type.size;
    level.destructible_type[var_6] = spawnstruct();
    level.destructible_type[var_6].v["type"] = var_0;
    level.destructible_type[var_6].parts = [];
    level.destructible_type[var_6].parts[0][0] = spawnstruct();
    level.destructible_type[var_6].parts[0][0].v["modelName"] = self.model;
    level.destructible_type[var_6].parts[0][0].v["tagName"] = var_1;
    level.destructible_type[var_6].parts[0][0].v["health"] = var_2;
    level.destructible_type[var_6].parts[0][0].v["validAttackers"] = var_3;
    level.destructible_type[var_6].parts[0][0].v["validDamageZone"] = var_4;
    level.destructible_type[var_6].parts[0][0].v["validDamageCause"] = var_5;
    level.destructible_type[var_6].parts[0][0].v["godModeAllowed"] = 1;
    level.destructible_type[var_6].parts[0][0].v["rotateTo"] = self.angles;
    level.destructible_type[var_6].parts[0][0].v["vehicle_exclude_anim"] = 0;
}

destructible_part( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    var_10 = level.destructible_type.size - 1;
    var_11 = level.destructible_type[var_10].parts.size;
    var_12 = 0;
    destructible_info( var_11, var_12, var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, undefined, var_9 );
}

destructible_state( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    var_8 = level.destructible_type.size - 1;
    var_9 = level.destructible_type[var_8].parts.size - 1;
    var_10 = level.destructible_type[var_8].parts[var_9].size;

    if ( !isdefined( var_0 ) && var_9 == 0 )
        var_0 = level.destructible_type[var_8].parts[var_9][0].v["tagName"];

    destructible_info( var_9, var_10, var_0, var_1, var_2, var_3, var_4, var_5, undefined, undefined, var_6, var_7 );
}

destructible_fx( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( !isdefined( var_2 ) )
        var_2 = 1;

    if ( !isdefined( var_4 ) )
        var_4 = 0;

    if ( !isdefined( var_5 ) )
        var_5 = 0;

    var_6 = level.destructible_type.size - 1;
    var_7 = level.destructible_type[var_6].parts.size - 1;
    var_8 = level.destructible_type[var_6].parts[var_7].size - 1;
    var_9 = 0;

    if ( isdefined( level.destructible_type[var_6].parts[var_7][var_8].v["fx_filename"] ) )
    {
        if ( isdefined( level.destructible_type[var_6].parts[var_7][var_8].v["fx_filename"][var_4] ) )
            var_9 = level.destructible_type[var_6].parts[var_7][var_8].v["fx_filename"][var_4].size;
    }

    if ( isdefined( var_3 ) )
        level.destructible_type[var_6].parts[var_7][var_8].v["fx_valid_damagetype"][var_4][var_9] = var_3;

    level.destructible_type[var_6].parts[var_7][var_8].v["fx_filename"][var_4][var_9] = var_1;
    level.destructible_type[var_6].parts[var_7][var_8].v["fx_tag"][var_4][var_9] = var_0;
    level.destructible_type[var_6].parts[var_7][var_8].v["fx_useTagAngles"][var_4][var_9] = var_2;
    level.destructible_type[var_6].parts[var_7][var_8].v["fx_cost"][var_4][var_9] = var_5;
}

destructible_createdot_predefined( var_0 )
{
    var_1 = level.destructible_type.size - 1;
    var_2 = level.destructible_type[var_1].parts.size - 1;
    var_3 = level.destructible_type[var_1].parts[var_2].size - 1;

    if ( !isdefined( level.destructible_type[var_1].parts[var_2][var_3].v["dot"] ) )
        level.destructible_type[var_1].parts[var_2][var_3].v["dot"] = [];

    var_4 = level.destructible_type[var_1].parts[var_2][var_3].v["dot"].size;
    var_5 = createdot();
    var_5.type = "predefined";
    var_5.index = var_0;
    level.destructible_type[var_1].parts[var_2][var_3].v["dot"][var_4] = var_5;
}

destructible_createdot_radius( var_0, var_1, var_2, var_3 )
{
    var_4 = level.destructible_type.size - 1;
    var_5 = level.destructible_type[var_4].parts.size - 1;
    var_6 = level.destructible_type[var_4].parts[var_5].size - 1;

    if ( !isdefined( level.destructible_type[var_4].parts[var_5][var_6].v["dot"] ) )
        level.destructible_type[var_4].parts[var_5][var_6].v["dot"] = [];

    var_7 = level.destructible_type[var_4].parts[var_5][var_6].v["dot"].size;
    var_8 = createdot_radius( ( 0, 0, 0 ), var_1, var_2, var_3 );
    var_8.tag = var_0;
    level.destructible_type[var_4].parts[var_5][var_6].v["dot"][var_7] = var_8;
}

destructible_setdot_ontick( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    var_8 = level.destructible_type.size - 1;
    var_9 = level.destructible_type[var_8].parts.size - 1;
    var_10 = level.destructible_type[var_8].parts[var_9].size - 1;
    var_11 = level.destructible_type[var_8].parts[var_9][var_10].v["dot"].size - 1;
    var_12 = level.destructible_type[var_8].parts[var_9][var_10].v["dot"][var_11];
    var_12 setdot_ontick( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 );
    initdot( var_6 );
}

destructible_setdot_ontickfunc( var_0, var_1, var_2 )
{
    var_3 = level.destructible_type.size - 1;
    var_4 = level.destructible_type[var_3].parts.size - 1;
    var_5 = level.destructible_type[var_3].parts[var_4].size - 1;
    var_6 = level.destructible_type[var_3].parts[var_4][var_5].v["dot"].size - 1;
    var_7 = level.destructible_type[var_3].parts[var_4][var_5].v["dot"][var_6];
    var_8 = var_7.ticks.size;
    var_7.ticks[var_8].onenterfunc = var_0;
    var_7.ticks[var_8].onexitfunc = var_1;
    var_7.ticks[var_8].ondeathfunc = var_2;
}

destructible_builddot_ontick( var_0, var_1 )
{
    var_2 = level.destructible_type.size - 1;
    var_3 = level.destructible_type[var_2].parts.size - 1;
    var_4 = level.destructible_type[var_2].parts[var_3].size - 1;
    var_5 = level.destructible_type[var_2].parts[var_3][var_4].v["dot"].size - 1;
    var_6 = level.destructible_type[var_2].parts[var_3][var_4].v["dot"][var_5];
    var_6 builddot_ontick( var_0, var_1 );
}

destructible_builddot_startloop( var_0 )
{
    var_1 = level.destructible_type.size - 1;
    var_2 = level.destructible_type[var_1].parts.size - 1;
    var_3 = level.destructible_type[var_1].parts[var_2].size - 1;
    var_4 = level.destructible_type[var_1].parts[var_2][var_3].v["dot"].size - 1;
    var_5 = level.destructible_type[var_1].parts[var_2][var_3].v["dot"][var_4];
    var_5 builddot_startloop( var_0 );
}

destructible_builddot_damage( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    var_6 = level.destructible_type.size - 1;
    var_7 = level.destructible_type[var_6].parts.size - 1;
    var_8 = level.destructible_type[var_6].parts[var_7].size - 1;
    var_9 = level.destructible_type[var_6].parts[var_7][var_8].v["dot"].size - 1;
    var_10 = level.destructible_type[var_6].parts[var_7][var_8].v["dot"][var_9];
    var_10 builddot_damage( var_0, var_1, var_2, var_3, var_4, var_5 );
}

destructible_builddot_wait( var_0 )
{
    var_1 = level.destructible_type.size - 1;
    var_2 = level.destructible_type[var_1].parts.size - 1;
    var_3 = level.destructible_type[var_1].parts[var_2].size - 1;
    var_4 = level.destructible_type[var_1].parts[var_2][var_3].v["dot"].size - 1;
    var_5 = level.destructible_type[var_1].parts[var_2][var_3].v["dot"][var_4];
    var_5 builddot_wait( var_0 );
}

destructible_loopfx( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( var_3 ) )
        var_3 = 0;

    var_4 = level.destructible_type.size - 1;
    var_5 = level.destructible_type[var_4].parts.size - 1;
    var_6 = level.destructible_type[var_4].parts[var_5].size - 1;
    var_7 = 0;

    if ( isdefined( level.destructible_type[var_4].parts[var_5][var_6].v["loopfx_filename"] ) )
        var_7 = level.destructible_type[var_4].parts[var_5][var_6].v["loopfx_filename"].size;

    level.destructible_type[var_4].parts[var_5][var_6].v["loopfx_filename"][var_7] = var_1;
    level.destructible_type[var_4].parts[var_5][var_6].v["loopfx_tag"][var_7] = var_0;
    level.destructible_type[var_4].parts[var_5][var_6].v["loopfx_rate"][var_7] = var_2;
    level.destructible_type[var_4].parts[var_5][var_6].v["loopfx_cost"][var_7] = var_3;
}

destructible_healthdrain( var_0, var_1, var_2, var_3 )
{
    var_4 = level.destructible_type.size - 1;
    var_5 = level.destructible_type[var_4].parts.size - 1;
    var_6 = level.destructible_type[var_4].parts[var_5].size - 1;
    level.destructible_type[var_4].parts[var_5][var_6].v["healthdrain_amount"] = var_0;
    level.destructible_type[var_4].parts[var_5][var_6].v["healthdrain_interval"] = var_1;
    level.destructible_type[var_4].parts[var_5][var_6].v["badplace_radius"] = var_2;
    level.destructible_type[var_4].parts[var_5][var_6].v["badplace_team"] = var_3;
}

destructible_sound( var_0, var_1, var_2 )
{
    var_3 = level.destructible_type.size - 1;
    var_4 = level.destructible_type[var_3].parts.size - 1;
    var_5 = level.destructible_type[var_3].parts[var_4].size - 1;

    if ( !isdefined( var_2 ) )
        var_2 = 0;

    if ( !isdefined( level.destructible_type[var_3].parts[var_4][var_5].v["sound"] ) )
    {
        level.destructible_type[var_3].parts[var_4][var_5].v["sound"] = [];
        level.destructible_type[var_3].parts[var_4][var_5].v["soundCause"] = [];
    }

    if ( !isdefined( level.destructible_type[var_3].parts[var_4][var_5].v["sound"][var_2] ) )
    {
        level.destructible_type[var_3].parts[var_4][var_5].v["sound"][var_2] = [];
        level.destructible_type[var_3].parts[var_4][var_5].v["soundCause"][var_2] = [];
    }

    var_6 = level.destructible_type[var_3].parts[var_4][var_5].v["sound"][var_2].size;
    level.destructible_type[var_3].parts[var_4][var_5].v["sound"][var_2][var_6] = var_0;
    level.destructible_type[var_3].parts[var_4][var_5].v["soundCause"][var_2][var_6] = var_1;

    if ( getdvarint( "precache_destructible", 1 ) )
    {
        precachesound( var_0 );
        var_7 = level.destructible_type[var_3].parts[var_4][var_5].v["tagName"];

        if ( isdefined( var_7 ) )
            precachetag( var_7 );
    }
}

destructible_loopsound( var_0, var_1 )
{
    var_2 = level.destructible_type.size - 1;
    var_3 = level.destructible_type[var_2].parts.size - 1;
    var_4 = level.destructible_type[var_2].parts[var_3].size - 1;

    if ( !isdefined( level.destructible_type[var_2].parts[var_3][var_4].v["loopsound"] ) )
    {
        level.destructible_type[var_2].parts[var_3][var_4].v["loopsound"] = [];
        level.destructible_type[var_2].parts[var_3][var_4].v["loopsoundCause"] = [];
    }

    var_5 = level.destructible_type[var_2].parts[var_3][var_4].v["loopsound"].size;
    level.destructible_type[var_2].parts[var_3][var_4].v["loopsound"][var_5] = var_0;
    level.destructible_type[var_2].parts[var_3][var_4].v["loopsoundCause"][var_5] = var_1;

    if ( getdvarint( "precache_destructible", 1 ) )
    {
        precachesound( var_0 );
        var_6 = level.destructible_type[var_2].parts[var_3][var_4].v["tagName"];

        if ( isdefined( var_6 ) )
            precachetag( var_6 );
    }
}

destructible_anim( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    if ( !isdefined( var_3 ) )
        var_3 = 0;

    if ( !isdefined( var_4 ) )
        var_4 = 0;

    var_9 = [];
    var_9["anim"] = var_0;
    var_9["animTree"] = var_1;
    var_9["animType"] = var_2;
    var_9["vehicle_exclude_anim"] = var_3;
    var_9["groupNum"] = var_4;
    var_9["mpAnim"] = var_5;
    var_9["maxStartDelay"] = var_6;
    var_9["animRateMin"] = var_7;
    var_9["animRateMax"] = var_8;
    add_array_to_destructible( "animation", var_9 );
}

destructible_spotlight( var_0 )
{
    var_1 = [];
    var_1["spotlight_tag"] = var_0;
    var_1["spotlight_fx"] = "spotlight_fx";
    var_1["spotlight_brightness"] = 0.85;
    var_1["randomly_flip"] = 1;
    var_2 = [];
    var_2["r_spotlightendradius"] = 1200;
    var_2["r_spotlightstartradius"] = 50;
    var_1["dvars"] = var_2;
    add_keypairs_to_destructible( var_1 );
}

add_key_to_destructible( var_0, var_1 )
{
    var_2 = [];
    var_2[var_0] = var_1;
    add_keypairs_to_destructible( var_2 );
}

add_keypairs_to_destructible( var_0 )
{
    var_1 = level.destructible_type.size - 1;
    var_2 = level.destructible_type[var_1].parts.size - 1;
    var_3 = level.destructible_type[var_1].parts[var_2].size - 1;

    foreach ( var_6, var_5 in var_0 )
        level.destructible_type[var_1].parts[var_2][var_3].v[var_6] = var_5;
}

add_array_to_destructible( var_0, var_1 )
{
    var_2 = level.destructible_type.size - 1;
    var_3 = level.destructible_type[var_2].parts.size - 1;
    var_4 = level.destructible_type[var_2].parts[var_3].size - 1;
    var_5 = level.destructible_type[var_2].parts[var_3][var_4].v;

    if ( !isdefined( var_5[var_0] ) )
        var_5[var_0] = [];

    var_5[var_0][var_5[var_0].size] = var_1;
    level.destructible_type[var_2].parts[var_3][var_4].v = var_5;
}

destructible_car_alarm()
{
    var_0 = level.destructible_type.size - 1;
    var_1 = level.destructible_type[var_0].parts.size - 1;
    var_2 = level.destructible_type[var_0].parts[var_1].size - 1;
    level.destructible_type[var_0].parts[var_1][var_2].v["triggerCarAlarm"] = 1;
}

destructible_lights_out( var_0 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 256;

    var_1 = level.destructible_type.size - 1;
    var_2 = level.destructible_type[var_1].parts.size - 1;
    var_3 = level.destructible_type[var_1].parts[var_2].size - 1;
    level.destructible_type[var_1].parts[var_2][var_3].v["break_nearby_lights"] = var_0;
}

random_dynamic_attachment( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( var_2 ) )
        var_2 = "";

    var_4 = level.destructible_type.size - 1;
    var_5 = level.destructible_type[var_4].parts.size - 1;
    var_6 = 0;

    if ( !isdefined( level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_1"] ) )
    {
        level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_1"] = [];
        level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_2"] = [];
        level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_tag"] = [];
    }

    var_7 = level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_1"].size;
    level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_1"][var_7] = var_1;
    level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_2"][var_7] = var_2;
    level.destructible_type[var_4].parts[var_5][var_6].v["random_dynamic_attachment_tag"][var_7] = var_0;
    level.destructible_type[var_4].parts[var_5][var_6].v["clipToRemove"][var_7] = var_3;
}

destructible_physics( var_0, var_1 )
{
    var_2 = level.destructible_type.size - 1;
    var_3 = level.destructible_type[var_2].parts.size - 1;
    var_4 = level.destructible_type[var_2].parts[var_3].size - 1;

    if ( !isdefined( level.destructible_type[var_2].parts[var_3][var_4].v["physics"] ) )
    {
        level.destructible_type[var_2].parts[var_3][var_4].v["physics"] = [];
        level.destructible_type[var_2].parts[var_3][var_4].v["physics_tagName"] = [];
        level.destructible_type[var_2].parts[var_3][var_4].v["physics_velocity"] = [];
    }

    var_5 = level.destructible_type[var_2].parts[var_3][var_4].v["physics"].size;
    level.destructible_type[var_2].parts[var_3][var_4].v["physics"][var_5] = 1;
    level.destructible_type[var_2].parts[var_3][var_4].v["physics_tagName"][var_5] = var_0;
    level.destructible_type[var_2].parts[var_3][var_4].v["physics_velocity"][var_5] = var_1;
}

destructible_splash_damage_scaler( var_0 )
{
    var_1 = level.destructible_type.size - 1;
    var_2 = level.destructible_type[var_1].parts.size - 1;
    var_3 = level.destructible_type[var_1].parts[var_2].size - 1;
    level.destructible_type[var_1].parts[var_2][var_3].v["splash_damage_scaler"] = var_0;
}

destructible_explode( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 )
{
    var_12 = level.destructible_type.size - 1;
    var_13 = level.destructible_type[var_12].parts.size - 1;
    var_14 = level.destructible_type[var_12].parts[var_13].size - 1;

    if ( common_scripts\utility::isSP() )
        level.destructible_type[var_12].parts[var_13][var_14].v["explode_range"] = var_2;
    else
        level.destructible_type[var_12].parts[var_13][var_14].v["explode_range"] = var_3;

    level.destructible_type[var_12].parts[var_13][var_14].v["explode"] = 1;
    level.destructible_type[var_12].parts[var_13][var_14].v["explode_force_min"] = var_0;
    level.destructible_type[var_12].parts[var_13][var_14].v["explode_force_max"] = var_1;
    level.destructible_type[var_12].parts[var_13][var_14].v["explode_mindamage"] = var_4;
    level.destructible_type[var_12].parts[var_13][var_14].v["explode_maxdamage"] = var_5;
    level.destructible_type[var_12].parts[var_13][var_14].v["continueDamage"] = var_6;
    level.destructible_type[var_12].parts[var_13][var_14].v["originOffset"] = var_7;
    level.destructible_type[var_12].parts[var_13][var_14].v["earthQuakeScale"] = var_8;
    level.destructible_type[var_12].parts[var_13][var_14].v["earthQuakeRadius"] = var_9;
    level.destructible_type[var_12].parts[var_13][var_14].v["originOffset3d"] = var_10;
    level.destructible_type[var_12].parts[var_13][var_14].v["delaytime"] = var_11;
}

destructible_info( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11, var_12 )
{
    if ( isdefined( var_3 ) )
        var_3 = tolower( var_3 );

    var_13 = level.destructible_type.size - 1;
    level.destructible_type[var_13].parts[var_0][var_1] = spawnstruct();
    level.destructible_type[var_13].parts[var_0][var_1].v["modelName"] = var_3;
    level.destructible_type[var_13].parts[var_0][var_1].v["tagName"] = var_2;
    level.destructible_type[var_13].parts[var_0][var_1].v["health"] = var_4;
    level.destructible_type[var_13].parts[var_0][var_1].v["validAttackers"] = var_5;
    level.destructible_type[var_13].parts[var_0][var_1].v["validDamageZone"] = var_6;
    level.destructible_type[var_13].parts[var_0][var_1].v["validDamageCause"] = var_7;
    level.destructible_type[var_13].parts[var_0][var_1].v["alsoDamageParent"] = var_8;
    level.destructible_type[var_13].parts[var_0][var_1].v["physicsOnExplosion"] = var_9;
    level.destructible_type[var_13].parts[var_0][var_1].v["grenadeImpactDeath"] = var_10;
    level.destructible_type[var_13].parts[var_0][var_1].v["godModeAllowed"] = 0;
    level.destructible_type[var_13].parts[var_0][var_1].v["splashRotation"] = var_11;
    level.destructible_type[var_13].parts[var_0][var_1].v["receiveDamageFromParent"] = var_12;
}

precache_destructibles()
{
    if ( !isdefined( level.destructible_type[self.destructibleInfo].parts ) )
        return;

    for ( var_0 = 0; var_0 < level.destructible_type[self.destructibleInfo].parts.size; var_0++ )
    {
        for ( var_1 = 0; var_1 < level.destructible_type[self.destructibleInfo].parts[var_0].size; var_1++ )
        {
            if ( level.destructible_type[self.destructibleInfo].parts[var_0].size <= var_1 )
                continue;

            if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["modelName"] ) )
                precachemodel( level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["modelName"] );

            if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["animation"] ) )
            {
                var_2 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["animation"];

                foreach ( var_4 in var_2 )
                {
                    if ( isdefined( var_4["mpAnim"] ) )
                        common_scripts\utility::noself_func( "precacheMpAnim", var_4["mpAnim"] );
                }
            }

            if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["random_dynamic_attachment_1"] ) )
            {
                foreach ( var_7 in level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["random_dynamic_attachment_1"] )
                {
                    if ( isdefined( var_7 ) && var_7 != "" )
                    {
                        precachemodel( var_7 );
                        precachemodel( var_7 + "_destroy" );
                    }
                }

                foreach ( var_7 in level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["random_dynamic_attachment_2"] )
                {
                    if ( isdefined( var_7 ) && var_7 != "" )
                    {
                        precachemodel( var_7 );
                        precachemodel( var_7 + "_destroy" );
                    }
                }
            }
        }
    }
}

add_destructible_fx()
{
    if ( !isdefined( level.destructible_type[self.destructibleInfo].parts ) )
        return;

    for ( var_0 = 0; var_0 < level.destructible_type[self.destructibleInfo].parts.size; var_0++ )
    {
        for ( var_1 = 0; var_1 < level.destructible_type[self.destructibleInfo].parts[var_0].size; var_1++ )
        {
            if ( level.destructible_type[self.destructibleInfo].parts[var_0].size <= var_1 )
                continue;

            var_2 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1];

            if ( isdefined( var_2.v["fx_filename"] ) )
            {
                for ( var_3 = 0; var_3 < var_2.v["fx_filename"].size; var_3++ )
                {
                    var_4 = var_2.v["fx_filename"][var_3];

                    if ( isdefined( var_4 ) )
                    {
                        if ( isdefined( var_2.v["fx"] ) && isdefined( var_2.v["fx"][var_3] ) && var_2.v["fx"][var_3].size == var_4.size )
                            continue;

                        foreach ( var_9, var_6 in var_4 )
                        {
                            var_7 = common_scripts\utility::_loadfx( var_6 );
                            var_2.v["fx"][var_3][var_9] = var_7;

                            if ( getdvarint( "precache_destructible", 1 ) )
                            {
                                var_8 = var_2.v["fx_tag"][var_3][var_9];

                                if ( isdefined( var_8 ) )
                                    precachefxontag( var_7, var_8 );
                            }
                        }
                    }
                }
            }

            var_10 = var_2.v["loopfx_filename"];

            if ( isdefined( var_10 ) )
            {
                if ( isdefined( var_2.v["loopfx"] ) && var_2.v["loopfx"].size == var_10.size )
                    continue;

                foreach ( var_9, var_12 in var_10 )
                {
                    var_13 = common_scripts\utility::_loadfx( var_12 );
                    var_2.v["loopfx"][var_9] = var_13;

                    if ( getdvarint( "precache_destructible", 1 ) )
                    {
                        var_14 = var_2.v["loopfx_tag"][var_9];
                        precachefxontag( var_13, var_14 );
                    }
                }
            }
        }
    }
}

canDamageDestructible( var_0 )
{
    foreach ( var_2 in self.destructibles )
    {
        if ( var_2 == var_0 )
            return 1;
    }

    return 0;
}

destructible_think()
{
    var_0 = 0;
    var_1 = self.model;
    var_2 = undefined;
    var_3 = self.origin;
    var_4 = undefined;
    var_5 = undefined;
    var_6 = undefined;
    destructible_update_part( var_0, var_1, var_2, var_3, var_4, var_5, var_6 );
    self endon( "stop_taking_damage" );

    for (;;)
    {
        var_0 = undefined;
        var_5 = undefined;
        var_4 = undefined;
        var_3 = undefined;
        var_7 = undefined;
        var_1 = undefined;
        var_2 = undefined;
        var_8 = undefined;
        var_9 = undefined;
        self waittill( "damage",  var_0, var_5, var_4, var_3, var_7, var_1, var_2, var_8, var_9  );

        if ( !isdefined( var_0 ) )
            continue;

        if ( isdefined( var_5 ) && isdefined( var_5.type ) && var_5.type == "soft_landing" && !var_5 canDamageDestructible( self ) )
            continue;

        if ( common_scripts\utility::isSP() )
            var_0 *= 0.5;
        else
            var_0 *= 1.0;

        if ( var_0 <= 0 )
            continue;

        if ( common_scripts\utility::isSP() )
        {
            if ( isdefined( var_5 ) && isplayer( var_5 ) )
                self.damageOwner = var_5;
        }
        else if ( isdefined( var_5 ) && isplayer( var_5 ) )
            self.damageOwner = var_5;
        else if ( isdefined( var_5 ) && isdefined( var_5.gunner ) && isplayer( var_5.gunner ) )
            self.damageOwner = var_5.gunner;

        var_7 = getDamageType( var_7 );

        if ( is_shotgun_damage( var_5, var_7 ) )
        {
            if ( common_scripts\utility::isSP() )
                var_0 *= 8.0;
            else
                var_0 *= 4.0;
        }

        if ( !isdefined( var_1 ) || var_1 == "" )
            var_1 = self.model;

        if ( isdefined( var_2 ) && var_2 == "" )
        {
            if ( isdefined( var_8 ) && var_8 != "" && var_8 != "tag_body" && var_8 != "body_animate_jnt" )
                var_2 = var_8;
            else
                var_2 = undefined;

            var_10 = level.destructible_type[self.destructibleInfo].parts[0][0].v["tagName"];

            if ( isdefined( var_10 ) && isdefined( var_8 ) && var_10 == var_8 )
                var_2 = undefined;
        }

        if ( var_7 == "splash" )
        {
            if ( isdefined( level.destructible_type[self.destructibleInfo].parts[0][0].v["splash_damage_scaler"] ) )
                var_0 *= level.destructible_type[self.destructibleInfo].parts[0][0].v["splash_damage_scaler"];
            else if ( common_scripts\utility::isSP() )
                var_0 *= 9.0;
            else
                var_0 *= 13.0;

            destructible_splash_damage( int( var_0 ), var_3, var_4, var_5, var_7 );
            continue;
        }

        thread destructible_update_part( int( var_0 ), var_1, var_2, var_3, var_4, var_5, var_7 );
    }
}

is_shotgun_damage( var_0, var_1 )
{
    if ( var_1 != "bullet" )
        return 0;

    if ( !isdefined( var_0 ) )
        return 0;

    var_2 = undefined;

    if ( isplayer( var_0 ) )
        var_2 = var_0 getcurrentweapon();
    else if ( isdefined( level.enable_ai_shotgun_destructible_damage ) && level.enable_ai_shotgun_destructible_damage )
    {
        if ( isdefined( var_0.weapon ) )
            var_2 = var_0.weapon;
    }

    if ( !isdefined( var_2 ) )
        return 0;

    var_3 = weaponclass( var_2 );

    if ( isdefined( var_3 ) && var_3 == "spread" )
        return 1;

    return 0;
}

getPartAndStateIndex( var_0, var_1 )
{
    var_2 = spawnstruct();
    var_2.v = [];
    var_3 = -1;
    var_4 = -1;

    if ( tolower( var_0 ) == tolower( self.model ) && !isdefined( var_1 ) )
    {
        var_0 = self.model;
        var_1 = undefined;
        var_3 = 0;
        var_4 = 0;
    }

    for ( var_5 = 0; var_5 < level.destructible_type[self.destructibleInfo].parts.size; var_5++ )
    {
        var_4 = self.destructible_parts[var_5].v["currentState"];

        if ( level.destructible_type[self.destructibleInfo].parts[var_5].size <= var_4 )
            continue;

        if ( !isdefined( var_1 ) )
            continue;

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_5][var_4].v["tagName"] ) )
        {
            var_6 = level.destructible_type[self.destructibleInfo].parts[var_5][var_4].v["tagName"];

            if ( tolower( var_6 ) == tolower( var_1 ) )
            {
                var_3 = var_5;
                break;
            }
        }
    }

    var_2.v["stateIndex"] = var_4;
    var_2.v["partIndex"] = var_3;
    return var_2;
}

destructible_update_part( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    if ( !isdefined( self.destructible_parts ) )
        return;

    if ( self.destructible_parts.size == 0 )
        return;

    if ( level.fast_destructible_explode )
        self endon( "destroyed" );

    var_8 = getPartAndStateIndex( var_1, var_2 );
    var_9 = var_8.v["stateIndex"];
    var_10 = var_8.v["partIndex"];

    if ( var_10 < 0 )
        return;

    var_11 = var_9;
    var_12 = 0;
    var_13 = 0;

    for (;;)
    {
        var_9 = self.destructible_parts[var_10].v["currentState"];

        if ( !isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_9] ) )
            break;

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][0].v["alsoDamageParent"] ) )
        {
            if ( getDamageType( var_6 ) != "splash" )
            {
                var_14 = level.destructible_type[self.destructibleInfo].parts[var_10][0].v["alsoDamageParent"];
                var_15 = int( var_0 * var_14 );
                thread notifyDamageAfterFrame( var_15, var_5, var_4, var_3, var_6, "", "" );
            }
        }

        if ( getDamageType( var_6 ) != "splash" )
        {
            foreach ( var_17 in level.destructible_type[self.destructibleInfo].parts )
            {
                if ( !isdefined( var_17[0].v["receiveDamageFromParent"] ) )
                    continue;

                if ( !isdefined( var_17[0].v["tagName"] ) )
                    continue;

                var_14 = var_17[0].v["receiveDamageFromParent"];
                var_18 = int( var_0 * var_14 );
                var_19 = var_17[0].v["tagName"];
                thread notifyDamageAfterFrame( var_18, var_5, var_4, var_3, var_6, "", var_19 );
            }
        }

        if ( !isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_9].v["health"] ) )
            break;

        if ( !isdefined( self.destructible_parts[var_10].v["health"] ) )
            break;

        if ( var_12 )
            self.destructible_parts[var_10].v["health"] = level.destructible_type[self.destructibleInfo].parts[var_10][var_9].v["health"];

        var_12 = 0;

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_9].v["grenadeImpactDeath"] ) && var_6 == "impact" )
            var_0 = 100000000;

        var_21 = self.destructible_parts[var_10].v["health"];
        var_22 = isAttackerValid( var_10, var_9, var_5 );

        if ( var_22 )
        {
            var_23 = isValidDamageCause( var_10, var_9, var_6 );

            if ( var_23 )
            {
                if ( isdefined( var_5 ) )
                {
                    if ( isplayer( var_5 ) )
                        self.player_damage = self.player_damage + var_0;
                    else if ( var_5 != self )
                        self.non_player_damage = self.non_player_damage + var_0;
                }

                if ( isdefined( var_6 ) )
                {
                    if ( var_6 == "melee" || var_6 == "impact" )
                        var_0 = 100000;
                }

                self.destructible_parts[var_10].v["health"] = self.destructible_parts[var_10].v["health"] - var_0;
            }
        }

        if ( self.destructible_parts[var_10].v["health"] > 0 )
            return;

        if ( isdefined( var_7 ) )
        {
            var_7.v["fxcost"] = get_part_FX_cost_for_action_state( var_10, self.destructible_parts[var_10].v["currentState"] );
            add_destructible_to_frame_queue( self, var_7, var_0 );

            if ( !isdefined( self.waiting_for_queue ) )
                self.waiting_for_queue = 1;
            else
                self.waiting_for_queue++;

            self waittill( "queue_processed",  var_24  );
            self.waiting_for_queue--;

            if ( self.waiting_for_queue == 0 )
                self.waiting_for_queue = undefined;

            if ( !var_24 )
            {
                self.destructible_parts[var_10].v["health"] = var_21;
                return;
            }
        }

        var_0 = int( abs( self.destructible_parts[var_10].v["health"] ) );

        if ( var_0 < 0 )
            return;

        self.destructible_parts[var_10].v["currentState"]++;
        var_9 = self.destructible_parts[var_10].v["currentState"];
        var_25 = var_9 - 1;
        var_26 = undefined;

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25] ) )
            var_26 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v;

        var_27 = undefined;

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_9] ) )
            var_27 = level.destructible_type[self.destructibleInfo].parts[var_10][var_9].v;

        if ( !isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25] ) )
            return;

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["explode"] ) )
            self.exploding = 1;

        if ( isdefined( self.loopingSoundStopNotifies ) && isdefined( self.loopingSoundStopNotifies[toString( var_10 )] ) )
        {
            for ( var_28 = 0; var_28 < self.loopingSoundStopNotifies[toString( var_10 )].size; var_28++ )
            {
                self notify( self.loopingSoundStopNotifies[toString( var_10 )][var_28] );

                if ( common_scripts\utility::isSP() && self.modeldummyon )
                    self.modeldummy notify( self.loopingSoundStopNotifies[toString( var_10 )][var_28] );
            }

            self.loopingSoundStopNotifies[toString( var_10 )] = undefined;
        }

        if ( isdefined( var_26["break_nearby_lights"] ) )
            destructible_get_my_breakable_light( var_26["break_nearby_lights"] );

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_9] ) )
        {
            if ( var_10 == 0 )
            {
                var_29 = var_27["modelName"];

                if ( isdefined( var_29 ) && var_29 != self.model )
                {
                    self setmodel( var_29 );

                    if ( common_scripts\utility::isSP() && self.modeldummyon )
                        self.modeldummy setmodel( var_29 );

                    destructible_splash_rotatation( var_27 );
                }
            }
            else
            {
                hideapart( var_2 );

                if ( common_scripts\utility::isSP() && self.modeldummyon )
                    self.modeldummy hideapart( var_2 );

                var_2 = var_27["tagName"];

                if ( isdefined( var_2 ) )
                {
                    showapart( var_2 );

                    if ( common_scripts\utility::isSP() && self.modeldummyon )
                        self.modeldummy showapart( var_2 );
                }
            }
        }

        var_30 = get_dummy();

        if ( isdefined( self.exploding ) )
            clear_anims( var_30 );

        var_31 = destructible_animation_think( var_26, var_30, var_6, var_10 );
        var_31 = destructible_fx_think( var_26, var_30, var_6, var_10, var_31 );
        var_31 = destructible_sound_think( var_26, var_30, var_6, var_31 );

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopfx"] ) )
        {
            var_32 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopfx_filename"].size;

            if ( var_32 > 0 )
                self notify( "FX_State_Change" + var_10 );

            for ( var_33 = 0; var_33 < var_32; var_33++ )
            {
                var_34 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopfx"][var_33];
                var_35 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopfx_tag"][var_33];
                var_36 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopfx_rate"][var_33];
                thread loopfx_onTag( var_34, var_35, var_36, var_10 );
            }
        }

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopsound"] ) )
        {
            for ( var_28 = 0; var_28 < level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopsound"].size; var_28++ )
            {
                var_37 = isValidSoundCause( "loopsoundCause", var_26, var_28, var_6 );

                if ( var_37 )
                {
                    var_38 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["loopsound"][var_28];
                    var_39 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["tagName"];
                    thread play_loop_sound_on_destructible( var_38, var_39 );

                    if ( !isdefined( self.loopingSoundStopNotifies ) )
                        self.loopingSoundStopNotifies = [];

                    if ( !isdefined( self.loopingSoundStopNotifies[toString( var_10 )] ) )
                        self.loopingSoundStopNotifies[toString( var_10 )] = [];

                    var_40 = self.loopingSoundStopNotifies[toString( var_10 )].size;
                    self.loopingSoundStopNotifies[toString( var_10 )][var_40] = "stop sound" + var_38;
                }
            }
        }

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["triggerCarAlarm"] ) )
            thread do_car_alarm();

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["break_nearby_lights"] ) )
            thread break_nearest_light();

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["healthdrain_amount"] ) )
        {
            self notify( "Health_Drain_State_Change" + var_10 );
            var_41 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["healthdrain_amount"];
            var_42 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["healthdrain_interval"];
            var_43 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["modelName"];
            var_44 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["tagName"];
            var_45 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["badplace_radius"];
            var_46 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["badplace_team"];

            if ( var_41 > 0 )
                thread health_drain( var_41, var_42, var_10, var_43, var_44, var_45, var_46 );
        }

        var_47 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["dot"];

        if ( isdefined( var_47 ) )
        {
            foreach ( var_49 in var_47 )
            {
                var_50 = var_49.index;

                if ( var_49.type == "predefined" && isdefined( var_50 ) )
                {
                    var_51 = [];

                    foreach ( var_53 in level.destructible_type[self.destructibleInfo].destructible_dots[var_50] )
                    {
                        var_54 = var_53["classname"];
                        var_55 = undefined;

                        switch ( var_54 )
                        {
                            case "trigger_radius":
                                var_56 = var_53["origin"];
                                var_57 = var_53["spawnflags"];
                                var_58 = var_53["radius"];
                                var_59 = var_53["height"];
                                var_55 = createdot_radius( self.origin + var_56, var_57, var_58, var_59 );
                                var_55.ticks = var_49.ticks;
                                var_51[var_51.size] = var_55;
                                continue;
                        }

                        endswitch( 2 )  case "trigger_radius" loc_2B6A default loc_2BAE
                    }

                    level thread startdot_group( var_51 );
                    continue;
                }

                if ( isdefined( var_49 ) )
                {
                    if ( isdefined( var_49.tag ) )
                        var_49 setdot_origin( self gettagorigin( var_49.tag ) );

                    level thread startdot_group( [ var_49 ] );
                }
            }

            var_47 = undefined;
        }

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["explode"] ) )
        {
            var_13 = 1;
            var_62 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["explode_force_min"];
            var_63 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["explode_force_max"];
            var_64 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["explode_range"];
            var_65 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["explode_mindamage"];
            var_66 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["explode_maxdamage"];
            var_67 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["continueDamage"];
            var_68 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["originOffset"];
            var_69 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["earthQuakeScale"];
            var_70 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["earthQuakeRadius"];
            var_71 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["originOffset3d"];
            var_72 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["delaytime"];

            if ( isdefined( var_5 ) && var_5 != self )
            {
                self.attacker = var_5;

                if ( self.code_classname == "script_vehicle" )
                    self.damage_type = var_6;
            }

            thread explode( var_10, var_62, var_63, var_64, var_65, var_66, var_67, var_68, var_69, var_70, var_5, var_71, var_72 );
        }

        var_73 = undefined;

        if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["physics"] ) )
        {
            for ( var_28 = 0; var_28 < level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["physics"].size; var_28++ )
            {
                var_73 = undefined;
                var_74 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["physics_tagName"][var_28];
                var_75 = level.destructible_type[self.destructibleInfo].parts[var_10][var_25].v["physics_velocity"][var_28];
                var_76 = undefined;

                if ( isdefined( var_75 ) )
                {
                    var_77 = undefined;

                    if ( isdefined( var_74 ) )
                        var_77 = self gettagangles( var_74 );
                    else if ( isdefined( var_2 ) )
                        var_77 = self gettagangles( var_2 );

                    var_73 = undefined;

                    if ( isdefined( var_74 ) )
                        var_73 = self gettagorigin( var_74 );
                    else if ( isdefined( var_2 ) )
                        var_73 = self gettagorigin( var_2 );

                    var_78 = var_75[0] - 5 + randomfloat( 10 );
                    var_79 = var_75[1] - 5 + randomfloat( 10 );
                    var_80 = var_75[2] - 5 + randomfloat( 10 );
                    var_81 = anglestoforward( var_77 ) * var_78 * randomfloatrange( 80, 110 );
                    var_82 = anglestoright( var_77 ) * var_79 * randomfloatrange( 80, 110 );
                    var_83 = anglestoup( var_77 ) * var_80 * randomfloatrange( 80, 110 );
                    var_76 = var_81 + var_82 + var_83;
                }
                else
                {
                    var_76 = var_3;
                    var_84 = ( 0, 0, 0 );

                    if ( isdefined( var_5 ) )
                    {
                        var_84 = var_5.origin;
                        var_76 = vectornormalize( var_3 - var_84 );
                        var_76 *= 200;
                    }
                }

                if ( isdefined( var_74 ) )
                {
                    var_85 = undefined;

                    for ( var_86 = 0; var_86 < level.destructible_type[self.destructibleInfo].parts.size; var_86++ )
                    {
                        if ( !isdefined( level.destructible_type[self.destructibleInfo].parts[var_86][0].v["tagName"] ) )
                            continue;

                        if ( level.destructible_type[self.destructibleInfo].parts[var_86][0].v["tagName"] != var_74 )
                            continue;

                        var_85 = var_86;
                        break;
                    }

                    if ( isdefined( var_73 ) )
                        thread physics_launch( var_85, 0, var_73, var_76 );
                    else
                        thread physics_launch( var_85, 0, var_3, var_76 );

                    continue;
                }

                if ( isdefined( var_73 ) )
                    thread physics_launch( var_10, var_25, var_73, var_76 );
                else
                    thread physics_launch( var_10, var_25, var_3, var_76 );

                return;
            }
        }

        var_12 = 1;
    }
}

destructible_splash_rotatation( var_0 )
{
    var_1 = var_0["splashRotation"];
    var_2 = var_0["rotateTo"];

    if ( !isdefined( var_2 ) )
        return;

    if ( !isdefined( var_1 ) )
        return;

    if ( !var_1 )
        return;

    self.angles = ( self.angles[0], var_2[1], self.angles[2] );
}

damage_not( var_0 )
{
    var_1 = strtok( var_0, " " );
    var_2 = strtok( "splash melee bullet splash impact unknown", " " );
    var_3 = "";

    foreach ( var_6, var_5 in var_1 )
        var_2 = common_scripts\utility::array_remove( var_2, var_5 );

    foreach ( var_8 in var_2 )
        var_3 += ( var_8 + " " );

    return var_3;
}

destructible_splash_damage( var_0, var_1, var_2, var_3, var_4 )
{
    if ( var_0 <= 0 )
        return;

    if ( isdefined( self.exploded ) )
        return;

    if ( !isdefined( level.destructible_type[self.destructibleInfo].parts ) )
        return;

    var_5 = getAllActiveParts( var_2 );

    if ( var_5.size <= 0 )
        return;

    var_5 = setDistanceOnParts( var_5, var_1 );
    var_6 = getLowestPartDistance( var_5 );

    foreach ( var_8 in var_5 )
    {
        var_9 = var_8.v["distance"] * 1.4;
        var_10 = var_0 - ( var_9 - var_6 );

        if ( var_10 <= 0 )
            continue;

        if ( isdefined( self.exploded ) )
            continue;

        thread destructible_update_part( var_10, var_8.v["modelName"], var_8.v["tagName"], var_1, var_2, var_3, var_4, var_8 );
    }
}

getAllActiveParts( var_0 )
{
    var_1 = [];

    if ( !isdefined( level.destructible_type[self.destructibleInfo].parts ) )
        return var_1;

    for ( var_2 = 0; var_2 < level.destructible_type[self.destructibleInfo].parts.size; var_2++ )
    {
        var_3 = var_2;
        var_4 = self.destructible_parts[var_3].v["currentState"];

        for ( var_5 = 0; var_5 < level.destructible_type[self.destructibleInfo].parts[var_3].size; var_5++ )
        {
            var_6 = level.destructible_type[self.destructibleInfo].parts[var_3][var_5].v["splashRotation"];

            if ( isdefined( var_6 ) && var_6 )
            {
                var_7 = vectortoangles( var_0 );
                var_8 = var_7[1] - 90;
                level.destructible_type[self.destructibleInfo].parts[var_3][var_5].v["rotateTo"] = ( 0, var_8, 0 );
            }
        }

        if ( !isdefined( level.destructible_type[self.destructibleInfo].parts[var_3][var_4] ) )
            continue;

        var_9 = level.destructible_type[self.destructibleInfo].parts[var_3][var_4].v["tagName"];

        if ( !isdefined( var_9 ) )
            var_9 = "";

        if ( var_9 == "" )
            continue;

        var_10 = level.destructible_type[self.destructibleInfo].parts[var_3][var_4].v["modelName"];

        if ( !isdefined( var_10 ) )
            var_10 = "";

        var_11 = var_1.size;
        var_1[var_11] = spawnstruct();
        var_1[var_11].v["modelName"] = var_10;
        var_1[var_11].v["tagName"] = var_9;
    }

    return var_1;
}

setDistanceOnParts( var_0, var_1 )
{
    for ( var_2 = 0; var_2 < var_0.size; var_2++ )
    {
        var_3 = distance( var_1, self gettagorigin( var_0[var_2].v["tagName"] ) );
        var_0[var_2].v["distance"] = var_3;
    }

    return var_0;
}

getLowestPartDistance( var_0 )
{
    var_1 = undefined;

    foreach ( var_3 in var_0 )
    {
        var_4 = var_3.v["distance"];

        if ( !isdefined( var_1 ) )
            var_1 = var_4;

        if ( var_4 < var_1 )
            var_1 = var_4;
    }

    return var_1;
}

isValidSoundCause( var_0, var_1, var_2, var_3, var_4 )
{
    if ( isdefined( var_4 ) )
        var_5 = var_1[var_0][var_4][var_2];
    else
        var_5 = var_1[var_0][var_2];

    if ( !isdefined( var_5 ) )
        return 1;

    if ( var_5 == var_3 )
        return 1;

    return 0;
}

isAttackerValid( var_0, var_1, var_2 )
{
    if ( isdefined( self.forceExploding ) )
        return 1;

    if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["explode"] ) )
    {
        if ( isdefined( self.dontAllowExplode ) )
            return 0;
    }

    if ( !isdefined( var_2 ) )
        return 1;

    if ( var_2 == self )
        return 1;

    var_3 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["validAttackers"];

    if ( !isdefined( var_3 ) )
        return 1;

    if ( var_3 == "no_player" )
    {
        if ( !isplayer( var_2 ) )
            return 1;

        if ( !isdefined( var_2.damageIsFromPlayer ) )
            return 1;

        if ( var_2.damageIsFromPlayer == 0 )
            return 1;
    }
    else if ( var_3 == "player_only" )
    {
        if ( isplayer( var_2 ) )
            return 1;

        if ( isdefined( var_2.damageIsFromPlayer ) && var_2.damageIsFromPlayer )
            return 1;
    }
    else if ( var_3 == "no_ai" && isdefined( level.isAIfunc ) )
    {
        if ( ![[ level.isAIfunc ]]( var_2 ) )
            return 1;
    }
    else if ( var_3 == "ai_only" && isdefined( level.isAIfunc ) )
    {
        if ( [[ level.isAIfunc ]]( var_2 ) )
            return 1;
    }
    else
    {

    }

    return 0;
}

isValidDamageCause( var_0, var_1, var_2 )
{
    if ( !isdefined( var_2 ) )
        return 1;

    var_3 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["godModeAllowed"];

    if ( var_3 && ( isdefined( self.godmode ) && self.godmode || isdefined( self.script_bulletshield ) && self.script_bulletshield && var_2 == "bullet" ) )
        return 0;

    var_4 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["validDamageCause"];

    if ( !isdefined( var_4 ) )
        return 1;

    if ( var_4 == "splash" && var_2 != "splash" )
        return 0;

    if ( var_4 == "no_splash" && var_2 == "splash" )
        return 0;

    if ( var_4 == "no_melee" && var_2 == "melee" || var_2 == "impact" )
        return 0;

    return 1;
}

getDamageType( var_0 )
{
    if ( !isdefined( var_0 ) )
        return "unknown";

    var_0 = tolower( var_0 );

    switch ( var_0 )
    {
        case "melee":
        case "mod_melee":
        case "mod_crush":
            return "melee";
        case "bullet":
        case "mod_pistol_bullet":
        case "mod_rifle_bullet":
            return "bullet";
        case "splash":
        case "mod_grenade":
        case "mod_grenade_splash":
        case "mod_projectile":
        case "mod_projectile_splash":
        case "mod_explosive":
            return "splash";
        case "mod_impact":
            return "impact";
        case "unknown":
            return "unknown";
        default:
            return "unknown";
    }
}

damage_mirror( var_0, var_1, var_2 )
{
    self notify( "stop_damage_mirror" );
    self endon( "stop_damage_mirror" );
    var_0 endon( "stop_taking_damage" );
    self setcandamage( 1 );

    for (;;)
    {
        self waittill( "damage",  var_3, var_4, var_5, var_6, var_7  );
        var_0 notify( "damage",  var_3, var_4, var_5, var_6, var_7, var_1, var_2  );
        var_3 = undefined;
        var_4 = undefined;
        var_5 = undefined;
        var_6 = undefined;
        var_7 = undefined;
    }
}

add_damage_owner_recorder()
{
    self.player_damage = 0;
    self.non_player_damage = 0;
    self.car_damage_owner_recorder = 1;
}

loopfx_onTag( var_0, var_1, var_2, var_3 )
{
    self endon( "FX_State_Change" + var_3 );
    self endon( "delete_destructible" );
    level endon( "putout_fires" );

    while ( isdefined( self ) )
    {
        var_4 = get_dummy();
        playfxontag( var_0, var_4, var_1 );
        wait(var_2);
    }
}

health_drain( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    self endon( "Health_Drain_State_Change" + var_2 );
    level endon( "putout_fires" );
    self endon( "destroyed" );

    if ( isdefined( var_5 ) && isdefined( level.destructible_badplace_radius_multiplier ) )
        var_5 *= level.destructible_badplace_radius_multiplier;

    if ( isdefined( var_0 ) && isdefined( level.destructible_health_drain_amount_multiplier ) )
        var_0 *= level.destructible_health_drain_amount_multiplier;

    wait(var_1);
    self.healthDrain = 1;
    var_7 = undefined;

    if ( isdefined( level.disable_destructible_bad_places ) && level.disable_destructible_bad_places )
        var_5 = undefined;

    if ( isdefined( var_5 ) && isdefined( var_6 ) && common_scripts\utility::isSP() )
    {
        var_7 = "" + gettime();

        if ( !isdefined( self.disableBadPlace ) )
        {
            if ( isdefined( self.script_radius ) )
                var_5 = self.script_radius;

            if ( var_6 == "both" )
                call [[ level.badplace_cylinder_func ]]( var_7, 0, self.origin, var_5, 128, "allies", "bad_guys" );
            else
                call [[ level.badplace_cylinder_func ]]( var_7, 0, self.origin, var_5, 128, var_6 );

            thread badplace_remove( var_7 );
        }
    }

    while ( isdefined( self ) && self.destructible_parts[var_2].v["health"] > 0 )
    {
        self notify( "damage",  var_0, self, ( 0, 0, 0 ), ( 0, 0, 0 ), "MOD_UNKNOWN", var_3, var_4  );
        wait(var_1);
    }

    self notify( "remove_badplace" );
}

badplace_remove( var_0 )
{
    common_scripts\utility::waittill_any( "destroyed", "remove_badplace" );
    call [[ level.badplace_delete_func ]]( var_0 );
}

physics_launch( var_0, var_1, var_2, var_3 )
{
    var_4 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["modelName"];
    var_5 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v["tagName"];
    hideapart( var_5 );

    if ( level.destructibleSpawnedEnts.size >= level.destructibleSpawnedEntsLimit )
        physics_object_remove( level.destructibleSpawnedEnts[0] );

    var_6 = spawn( "script_model", self gettagorigin( var_5 ) );
    var_6.angles = self gettagangles( var_5 );
    var_6 setmodel( var_4 );
    level.destructibleSpawnedEnts[level.destructibleSpawnedEnts.size] = var_6;
    var_6 physicslaunchclient( var_2, var_3 );
}

physics_object_remove( var_0 )
{
    var_1 = [];

    for ( var_2 = 0; var_2 < level.destructibleSpawnedEnts.size; var_2++ )
    {
        if ( level.destructibleSpawnedEnts[var_2] == var_0 )
            continue;

        var_1[var_1.size] = level.destructibleSpawnedEnts[var_2];
    }

    level.destructibleSpawnedEnts = var_1;

    if ( isdefined( var_0 ) )
        var_0 delete();
}

explode( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11, var_12 )
{
    if ( isdefined( var_3 ) && isdefined( level.destructible_explosion_radius_multiplier ) )
        var_3 *= level.destructible_explosion_radius_multiplier;

    if ( !isdefined( var_7 ) )
        var_7 = 80;

    if ( !isdefined( var_11 ) )
        var_11 = ( 0, 0, 0 );

    if ( !isdefined( var_6 ) || isdefined( var_6 ) && !var_6 )
    {
        if ( isdefined( self.exploded ) )
            return;

        self.exploded = 1;
    }

    if ( !isdefined( var_12 ) )
        var_12 = 0;

    self notify( "exploded",  var_10  );
    level notify( "destructible_exploded" );

    if ( self.code_classname == "script_vehicle" )
        self notify( "death",  var_10, self.damage_type  );

    if ( common_scripts\utility::isSP() )
        thread disconnectTraverses();

    if ( !level.fast_destructible_explode )
        wait 0.05;

    if ( !isdefined( self ) )
        return;

    var_13 = self.destructible_parts[var_0].v["currentState"];
    var_14 = undefined;

    if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_0][var_13] ) )
        var_14 = level.destructible_type[self.destructibleInfo].parts[var_0][var_13].v["tagName"];

    if ( isdefined( var_14 ) )
        var_15 = self gettagorigin( var_14 );
    else
        var_15 = self.origin;

    self notify( "damage",  var_5, self, ( 0, 0, 0 ), var_15, "MOD_EXPLOSIVE", "", ""  );
    self notify( "stop_car_alarm" );
    waittillframeend;

    if ( isdefined( level.destructible_type[self.destructibleInfo].parts ) )
    {
        for ( var_16 = level.destructible_type[self.destructibleInfo].parts.size - 1; var_16 >= 0; var_16-- )
        {
            if ( var_16 == var_0 )
                continue;

            var_17 = self.destructible_parts[var_16].v["currentState"];

            if ( var_17 >= level.destructible_type[self.destructibleInfo].parts[var_16].size )
                var_17 = level.destructible_type[self.destructibleInfo].parts[var_16].size - 1;

            var_18 = level.destructible_type[self.destructibleInfo].parts[var_16][var_17].v["modelName"];
            var_14 = level.destructible_type[self.destructibleInfo].parts[var_16][var_17].v["tagName"];

            if ( !isdefined( var_18 ) )
                continue;

            if ( !isdefined( var_14 ) )
                continue;

            if ( isdefined( level.destructible_type[self.destructibleInfo].parts[var_16][0].v["physicsOnExplosion"] ) )
            {
                if ( level.destructible_type[self.destructibleInfo].parts[var_16][0].v["physicsOnExplosion"] > 0 )
                {
                    var_19 = level.destructible_type[self.destructibleInfo].parts[var_16][0].v["physicsOnExplosion"];
                    var_20 = self gettagorigin( var_14 );
                    var_21 = vectornormalize( var_20 - var_15 );
                    var_21 *= ( randomfloatrange( var_1, var_2 ) * var_19 );
                    thread physics_launch( var_16, var_17, var_20, var_21 );
                    continue;
                }
            }
        }
    }

    var_22 = !isdefined( var_6 ) || isdefined( var_6 ) && !var_6;

    if ( var_22 )
        self notify( "stop_taking_damage" );

    if ( !level.fast_destructible_explode )
        wait 0.05;

    if ( !isdefined( self ) )
        return;

    var_23 = var_15 + ( 0, 0, var_7 ) + var_11;
    var_24 = getsubstr( level.destructible_type[self.destructibleInfo].v["type"], 0, 7 ) == "vehicle";

    if ( var_24 )
    {
        anim.lastCarExplosionTime = gettime();
        anim.lastCarExplosionDamageLocation = var_23;
        anim.lastCarExplosionLocation = var_15;
        anim.lastCarExplosionRange = var_3;
    }

    level thread set_disable_friendlyfire_value_delayed( 1 );

    if ( var_12 > 0 )
        wait(var_12);

    if ( isdefined( level.destructible_protection_func ) )
        thread [[ level.destructible_protection_func ]]();

    if ( common_scripts\utility::isSP() )
    {
        if ( level.gameskill == 0 && !player_touching_post_clip() )
            self radiusdamage( var_23, var_3, var_5, var_4, self, "MOD_RIFLE_BULLET" );
        else
            self radiusdamage( var_23, var_3, var_5, var_4, self );

        if ( isdefined( self.damageOwner ) && var_24 )
        {
            self.damageOwner notify( "destroyed_car" );
            level notify( "player_destroyed_car",  self.damageOwner, var_23  );
        }
    }
    else
    {
        var_25 = "destructible_toy";

        if ( var_24 )
            var_25 = "destructible_car";

        if ( !isdefined( self.damageOwner ) )
            self radiusdamage( var_23, var_3, var_5, var_4, self, "MOD_EXPLOSIVE", var_25 );
        else
        {
            self radiusdamage( var_23, var_3, var_5, var_4, self.damageOwner, "MOD_EXPLOSIVE", var_25 );

            if ( var_24 )
            {
                self.damageOwner notify( "destroyed_car" );
                level notify( "player_destroyed_car",  self.damageOwner, var_23  );
            }
        }
    }

    if ( isdefined( var_8 ) && isdefined( var_9 ) )
        earthquake( var_8, 2.0, var_23, var_9 );

    level thread set_disable_friendlyfire_value_delayed( 0, 0.05 );
    var_26 = 0.01;
    var_27 = var_3 * var_26;
    var_3 *= 0.99;
    physicsexplosionsphere( var_23, var_3, 0, var_27 );

    if ( var_22 )
    {
        self setcandamage( 0 );
        thread cleanupVars();
    }

    self notify( "destroyed" );
}

cleanupVars()
{
    wait 0.05;

    while ( isdefined( self ) && isdefined( self.waiting_for_queue ) )
    {
        self waittill( "queue_processed" );
        wait 0.05;
    }

    if ( !isdefined( self ) )
        return;

    self.animsapplied = undefined;
    self.attacker = undefined;
    self.car_damage_owner_recorder = undefined;
    self.caralarm = undefined;
    self.damageOwner = undefined;
    self.destructible_parts = undefined;
    self.destructible_type = undefined;
    self.destructibleInfo = undefined;
    self.healthDrain = undefined;
    self.non_player_damage = undefined;
    self.player_damage = undefined;

    if ( !isdefined( level.destructible_cleans_up_more ) )
        return;

    self.script_noflip = undefined;
    self.exploding = undefined;
    self.loopingSoundStopNotifies = undefined;
    self.car_alarm_org = undefined;
}

set_disable_friendlyfire_value_delayed( var_0, var_1 )
{
    level notify( "set_disable_friendlyfire_value_delayed" );
    level endon( "set_disable_friendlyfire_value_delayed" );

    if ( isdefined( var_1 ) )
        wait(var_1);

    level.friendlyFireDisabledForDestructible = var_0;
}

connectTraverses()
{
    var_0 = get_traverse_disconnect_brush();

    if ( !isdefined( var_0 ) )
        return;

    var_0 call [[ level.connectPathsFunction ]]();
    var_0.origin = var_0.origin - ( 0, 0, 10000 );
}

disconnectTraverses()
{
    var_0 = get_traverse_disconnect_brush();

    if ( !isdefined( var_0 ) )
        return;

    var_0.origin = var_0.origin + ( 0, 0, 10000 );
    var_0 call [[ level.disconnectPathsFunction ]]();
    var_0.origin = var_0.origin - ( 0, 0, 10000 );
}

get_traverse_disconnect_brush()
{
    if ( !isdefined( self.target ) )
        return undefined;

    var_0 = getentarray( self.target, "targetname" );

    foreach ( var_2 in var_0 )
    {
        if ( isspawner( var_2 ) )
            continue;

        if ( isdefined( var_2.script_destruct_collision ) )
            continue;

        if ( var_2.code_classname == "light" )
            continue;

        if ( !var_2.spawnflags & 1 )
            continue;

        return var_2;
    }
}

hideapart( var_0 )
{
    self hidepart( var_0 );
}

showapart( var_0 )
{
    self showpart( var_0 );
}

disable_explosion()
{
    self.dontAllowExplode = 1;
}

force_explosion()
{
    self.dontAllowExplode = undefined;
    self.forceExploding = 1;
    self notify( "damage",  100000, self, self.origin, self.origin, "MOD_EXPLOSIVE", "", ""  );
}

get_dummy()
{
    if ( !common_scripts\utility::isSP() )
        return self;

    if ( self.modeldummyon )
        var_0 = self.modeldummy;
    else
        var_0 = self;

    return var_0;
}

play_loop_sound_on_destructible( var_0, var_1 )
{
    var_2 = get_dummy();
    var_3 = spawn( "script_origin", ( 0, 0, 0 ) );

    if ( isdefined( var_1 ) )
        var_3.origin = var_2 gettagorigin( var_1 );
    else
        var_3.origin = var_2.origin;

    var_3 playloopsound( var_0 );
    var_2 thread force_stop_sound( var_0 );
    var_2 waittill( "stop sound" + var_0 );

    if ( !isdefined( var_3 ) )
        return;

    var_3 stoploopsound( var_0 );
    var_3 delete();
}

force_stop_sound( var_0 )
{
    self endon( "stop sound" + var_0 );
    level waittill( "putout_fires" );
    self notify( "stop sound" + var_0 );
}

notifyDamageAfterFrame( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    if ( isdefined( level.notifyDamageAfterFrame ) )
        return;

    level.notifyDamageAfterFrame = 1;
    waittillframeend;

    if ( isdefined( self.exploded ) )
    {
        level.notifyDamageAfterFrame = undefined;
        return;
    }

    if ( common_scripts\utility::isSP() )
        var_0 /= 0.5;
    else
        var_0 /= 1.0;

    self notify( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6  );
    level.notifyDamageAfterFrame = undefined;
}

play_sound( var_0, var_1 )
{
    if ( isdefined( var_1 ) )
    {
        var_2 = spawn( "script_origin", self gettagorigin( var_1 ) );
        var_2 hide();
        var_2 linkto( self, var_1, ( 0, 0, 0 ), ( 0, 0, 0 ) );
    }
    else
    {
        var_2 = spawn( "script_origin", ( 0, 0, 0 ) );
        var_2 hide();
        var_2.origin = self.origin;
        var_2.angles = self.angles;
        var_2 linkto( self );
    }

    var_2 playsound( var_0 );
    wait 5.0;

    if ( isdefined( var_2 ) )
        var_2 delete();
}

toString( var_0 )
{
    return "" + var_0;
}

do_car_alarm()
{
    if ( isdefined( self.caralarm ) )
        return;

    self.caralarm = 1;

    if ( !should_do_car_alarm() )
        return;

    self.car_alarm_org = spawn( "script_model", self.origin );
    self.car_alarm_org hide();
    self.car_alarm_org playloopsound( "car_alarm" );
    level.currentCarAlarms++;
    thread car_alarm_timeout();
    self waittill( "stop_car_alarm" );
    level.lastCarAlarmTime = gettime();
    level.currentCarAlarms--;
    self.car_alarm_org stoploopsound( "car_alarm" );
    self.car_alarm_org delete();
}

car_alarm_timeout()
{
    self endon( "stop_car_alarm" );
    wait 25;

    if ( !isdefined( self ) )
        return;

    thread play_sound( "car_alarm_off" );
    self notify( "stop_car_alarm" );
}

should_do_car_alarm()
{
    if ( level.currentCarAlarms >= 2 )
        return 0;

    var_0 = undefined;

    if ( !isdefined( level.lastCarAlarmTime ) )
    {
        if ( common_scripts\utility::cointoss() )
            return 1;

        var_0 = gettime() - level.commonStartTime;
    }
    else
        var_0 = gettime() - level.lastCarAlarmTime;

    if ( level.currentCarAlarms == 0 && var_0 >= 120 )
        return 1;

    if ( randomint( 100 ) <= 33 )
        return 1;

    return 0;
}

do_random_dynamic_attachment( var_0, var_1, var_2, var_3 )
{
    var_4 = [];

    if ( common_scripts\utility::isSP() )
    {
        self attach( var_1, var_0, 0 );

        if ( isdefined( var_2 ) && var_2 != "" )
            self attach( var_2, var_0, 0 );
    }
    else
    {
        var_4[0] = spawn( "script_model", self gettagorigin( var_0 ) );
        var_4[0].angles = self gettagangles( var_0 );
        var_4[0] setmodel( var_1 );
        var_4[0] linkto( self, var_0 );

        if ( isdefined( var_2 ) && var_2 != "" )
        {
            var_4[1] = spawn( "script_model", self gettagorigin( var_0 ) );
            var_4[1].angles = self gettagangles( var_0 );
            var_4[1] setmodel( var_2 );
            var_4[1] linkto( self, var_0 );
        }
    }

    if ( isdefined( var_3 ) )
    {
        var_5 = self gettagorigin( var_0 );
        var_6 = get_closest_with_targetname( var_5, var_3 );

        if ( isdefined( var_6 ) )
            var_6 delete();
    }

    self waittill( "exploded" );

    if ( common_scripts\utility::isSP() )
    {
        self detach( var_1, var_0 );
        self attach( var_1 + "_destroy", var_0, 0 );

        if ( isdefined( var_2 ) && var_2 != "" )
        {
            self detach( var_2, var_0 );
            self attach( var_2 + "_destroy", var_0, 0 );
        }
    }
    else
    {
        var_4[0] setmodel( var_1 + "_destroy" );

        if ( isdefined( var_2 ) && var_2 != "" )
            var_4[1] setmodel( var_2 + "_destroy" );
    }
}

get_closest_with_targetname( var_0, var_1 )
{
    var_2 = undefined;
    var_3 = undefined;
    var_4 = getentarray( var_1, "targetname" );

    foreach ( var_6 in var_4 )
    {
        var_7 = distancesquared( var_0, var_6.origin );

        if ( !isdefined( var_2 ) || var_7 < var_2 )
        {
            var_2 = var_7;
            var_3 = var_6;
        }
    }

    return var_3;
}

player_touching_post_clip()
{
    var_0 = undefined;

    if ( !isdefined( self.target ) )
        return 0;

    var_1 = getentarray( self.target, "targetname" );

    foreach ( var_3 in var_1 )
    {
        if ( isdefined( var_3.script_destruct_collision ) && var_3.script_destruct_collision == "post" )
        {
            var_0 = var_3;
            break;
        }
    }

    if ( !isdefined( var_0 ) )
        return 0;

    var_5 = get_player_touching( var_0 );

    if ( isdefined( var_5 ) )
        return 1;

    return 0;
}

get_player_touching( var_0 )
{
    foreach ( var_2 in level.players )
    {
        if ( !isalive( var_2 ) )
            continue;

        if ( var_0 istouching( var_2 ) )
            return var_2;
    }

    return undefined;
}

is_so()
{
    return getdvar( "specialops" ) == "1";
}

destructible_handles_collision_brushes()
{
    var_0 = getentarray( self.target, "targetname" );
    var_1 = [];
    var_1["pre"] = ::collision_brush_pre_explosion;
    var_1["post"] = ::collision_brush_post_explosion;

    foreach ( var_3 in var_0 )
    {
        if ( !isdefined( var_3.script_destruct_collision ) )
            continue;

        self thread [[ var_1[var_3.script_destruct_collision] ]]( var_3 );
    }
}

collision_brush_pre_explosion( var_0 )
{
    waittillframeend;

    if ( common_scripts\utility::isSP() && var_0.spawnflags & 1 )
        var_0 call [[ level.disconnectPathsFunction ]]();

    self waittill( "exploded" );

    if ( common_scripts\utility::isSP() && var_0.spawnflags & 1 )
        var_0 call [[ level.connectPathsFunction ]]();

    var_0 delete();
}

collision_brush_post_explosion( var_0 )
{
    var_0 notsolid();

    if ( common_scripts\utility::isSP() && var_0.spawnflags & 1 )
        var_0 call [[ level.connectPathsFunction ]]();

    self waittill( "exploded" );
    waittillframeend;

    if ( common_scripts\utility::isSP() )
    {
        if ( var_0.spawnflags & 1 )
            var_0 call [[ level.disconnectPathsFunction ]]();

        if ( is_so() )
        {
            var_1 = get_player_touching( var_0 );

            if ( isdefined( var_1 ) )
                self thread [[ level.func_destructible_crush_player ]]( var_1 );
        }
        else
        {

        }
    }

    var_0 solid();
}

debug_player_in_post_clip( var_0 )
{

}

destructible_get_my_breakable_light( var_0 )
{
    var_1 = getentarray( "light_destructible", "targetname" );

    if ( common_scripts\utility::isSP() )
    {
        var_2 = getentarray( "light_destructible", "script_noteworthy" );
        var_1 = common_scripts\utility::array_combine( var_1, var_2 );
    }

    if ( !var_1.size )
        return;

    var_3 = var_0 * var_0;
    var_4 = undefined;

    foreach ( var_6 in var_1 )
    {
        var_7 = distancesquared( self.origin, var_6.origin );

        if ( var_7 < var_3 )
        {
            var_4 = var_6;
            var_3 = var_7;
        }
    }

    if ( !isdefined( var_4 ) )
        return;

    self.breakable_light = var_4;
}

break_nearest_light( var_0 )
{
    if ( !isdefined( self.breakable_light ) )
        return;

    self.breakable_light setlightintensity( 0 );
}

debug_radiusdamage_circle( var_0, var_1, var_2, var_3 )
{
    var_4 = 16;
    var_5 = 360 / var_4;
    var_6 = [];

    for ( var_7 = 0; var_7 < var_4; var_7++ )
    {
        var_8 = var_5 * var_7;
        var_9 = cos( var_8 ) * var_1;
        var_10 = sin( var_8 ) * var_1;
        var_11 = var_0[0] + var_9;
        var_12 = var_0[1] + var_10;
        var_13 = var_0[2];
        var_6[var_6.size] = ( var_11, var_12, var_13 );
    }

    thread debug_circle_drawlines( var_6, 5.0, ( 1, 0, 0 ), var_0 );
    var_6 = [];

    for ( var_7 = 0; var_7 < var_4; var_7++ )
    {
        var_8 = var_5 * var_7;
        var_9 = cos( var_8 ) * var_1;
        var_10 = sin( var_8 ) * var_1;
        var_11 = var_0[0];
        var_12 = var_0[1] + var_9;
        var_13 = var_0[2] + var_10;
        var_6[var_6.size] = ( var_11, var_12, var_13 );
    }

    thread debug_circle_drawlines( var_6, 5.0, ( 1, 0, 0 ), var_0 );
    var_6 = [];

    for ( var_7 = 0; var_7 < var_4; var_7++ )
    {
        var_8 = var_5 * var_7;
        var_9 = cos( var_8 ) * var_1;
        var_10 = sin( var_8 ) * var_1;
        var_11 = var_0[0] + var_10;
        var_12 = var_0[1];
        var_13 = var_0[2] + var_9;
        var_6[var_6.size] = ( var_11, var_12, var_13 );
    }

    thread debug_circle_drawlines( var_6, 5.0, ( 1, 0, 0 ), var_0 );
}

debug_circle_drawlines( var_0, var_1, var_2, var_3 )
{
    for ( var_4 = 0; var_4 < var_0.size; var_4++ )
    {
        var_5 = var_0[var_4];

        if ( var_4 + 1 >= var_0.size )
            var_6 = var_0[0];
        else
            var_6 = var_0[var_4 + 1];

        thread debug_line( var_5, var_6, var_1, var_2 );
        thread debug_line( var_3, var_5, var_1, var_2 );
    }
}

debug_line( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( var_3 ) )
        var_3 = ( 1, 1, 1 );

    for ( var_4 = 0; var_4 < var_2 * 20; var_4++ )
        wait 0.05;
}

spotlight_tag_origin_cleanup( var_0 )
{
    var_0 endon( "death" );
    level waittill( "new_destructible_spotlight" );
    var_0 delete();
}

spotlight_fizzles_out( var_0, var_1, var_2, var_3, var_4 )
{
    level endon( "new_destructible_spotlight" );
    thread spotlight_tag_origin_cleanup( var_4 );
    var_5 = var_0["spotlight_brightness"];
    common_scripts\utility::noself_func( "setsaveddvar", "r_spotlightbrightness", var_5 );
    wait(randomfloatrange( 2, 5 ));
    var_6 = randomintrange( 5, 11 );

    for ( var_7 = 0; var_7 < var_6; var_7++ )
    {
        common_scripts\utility::noself_func( "setsaveddvar", "r_spotlightbrightness", var_5 * 0.65 );
        wait 0.05;
        common_scripts\utility::noself_func( "setsaveddvar", "r_spotlightbrightness", var_5 );
        wait 0.05;
    }

    destructible_fx_think( var_0, var_1, var_2, var_3 );
    level.destructible_spotlight delete();
    var_4 delete();
}

destructible_spotlight_think( var_0, var_1, var_2, var_3 )
{
    if ( !common_scripts\utility::isSP() )
        return;

    if ( !isdefined( self.breakable_light ) )
        return;

    var_1 common_scripts\utility::self_func( "startignoringspotLight" );

    foreach ( var_6, var_5 in var_0["dvars"] )
        common_scripts\utility::noself_func( "setsaveddvar", var_6, var_5 );

    if ( !isdefined( level.destructible_spotlight ) )
    {
        level.destructible_spotlight = common_scripts\utility::spawn_tag_origin();
        var_7 = common_scripts\utility::getfx( var_0["spotlight_fx"] );
        playfxontag( var_7, level.destructible_spotlight, "tag_origin" );
    }

    level notify( "new_destructible_spotlight" );
    level.destructible_spotlight unlink();
    var_8 = common_scripts\utility::spawn_tag_origin();
    var_8 linkto( self, var_0["spotlight_tag"], ( 0, 0, 0 ), ( 0, 0, 0 ) );
    level.destructible_spotlight.origin = self.breakable_light.origin;
    level.destructible_spotlight.angles = self.breakable_light.angles;
    level.destructible_spotlight thread spotlight_fizzles_out( var_0, var_1, var_2, var_3, var_8 );
    wait 0.05;

    if ( isdefined( var_8 ) )
        level.destructible_spotlight linkto( var_8 );
}

is_valid_damagetype( var_0, var_1, var_2, var_3 )
{
    var_4 = undefined;

    if ( isdefined( var_1["fx_valid_damagetype"] ) )
        var_4 = var_1["fx_valid_damagetype"][var_3][var_2];

    if ( !isdefined( var_4 ) )
        return 1;

    return issubstr( var_4, var_0 );
}

destructible_sound_think( var_0, var_1, var_2, var_3 )
{
    if ( isdefined( self.exploded ) )
        return undefined;

    if ( !isdefined( var_0["sound"] ) )
        return undefined;

    if ( !isdefined( var_3 ) )
        var_3 = 0;

    for ( var_4 = 0; var_4 < var_0["sound"][var_3].size; var_4++ )
    {
        var_5 = isValidSoundCause( "soundCause", var_0, var_4, var_2, var_3 );

        if ( !var_5 )
            continue;

        var_6 = var_0["sound"][var_3][var_4];
        var_7 = var_0["tagName"];
        var_1 thread play_sound( var_6, var_7 );
    }

    return var_3;
}

destructible_fx_think( var_0, var_1, var_2, var_3, var_4 )
{
    if ( !isdefined( var_0["fx"] ) )
        return undefined;

    if ( !isdefined( var_4 ) )
        var_4 = randomint( var_0["fx_filename"].size );

    if ( !isdefined( var_0["fx"][var_4] ) )
        var_4 = randomint( var_0["fx_filename"].size );

    var_5 = var_0["fx_filename"][var_4].size;

    for ( var_6 = 0; var_6 < var_5; var_6++ )
    {
        if ( !is_valid_damagetype( var_2, var_0, var_6, var_4 ) )
            continue;

        var_7 = var_0["fx"][var_4][var_6];

        if ( isdefined( var_0["fx_tag"][var_4][var_6] ) )
        {
            var_8 = var_0["fx_tag"][var_4][var_6];
            self notify( "FX_State_Change" + var_3 );

            if ( var_0["fx_useTagAngles"][var_4][var_6] )
                playfxontag( var_7, var_1, var_8 );
            else
            {
                var_9 = var_1 gettagorigin( var_8 );
                var_10 = var_9 + ( 0, 0, 100 ) - var_9;
                playfx( var_7, var_9, var_10 );
            }

            continue;
        }

        var_9 = var_1.origin;
        var_10 = var_9 + ( 0, 0, 100 ) - var_9;
        playfx( var_7, var_9, var_10 );
    }

    return var_4;
}

destructible_animation_think( var_0, var_1, var_2, var_3 )
{
    if ( isdefined( self.exploded ) )
        return undefined;

    if ( !isdefined( var_0["animation"] ) )
        return undefined;

    if ( isdefined( self.no_destructible_animation ) )
        return undefined;

    if ( isdefined( var_0["randomly_flip"] ) && !isdefined( self.script_noflip ) )
    {
        if ( common_scripts\utility::cointoss() )
            self.angles = self.angles + ( 0, 180, 0 );
    }

    if ( isdefined( var_0["spotlight_tag"] ) )
    {
        thread destructible_spotlight_think( var_0, var_1, var_2, var_3 );
        wait 0.05;
    }

    var_4 = common_scripts\utility::random( var_0["animation"] );
    var_5 = var_4["anim"];
    var_6 = var_4["animTree"];
    var_7 = var_4["groupNum"];
    var_8 = var_4["mpAnim"];
    var_9 = var_4["maxStartDelay"];
    var_10 = var_4["animRateMin"];
    var_11 = var_4["animRateMax"];

    if ( !isdefined( var_10 ) )
        var_10 = 1.0;

    if ( !isdefined( var_11 ) )
        var_11 = 1.0;

    if ( var_10 == var_11 )
        var_12 = var_10;
    else
        var_12 = randomfloatrange( var_10, var_11 );

    var_13 = var_4["vehicle_exclude_anim"];

    if ( self.code_classname == "script_vehicle" && var_13 )
        return undefined;

    var_1 common_scripts\utility::self_func( "useanimtree", var_6 );
    var_14 = var_4["animType"];

    if ( !isdefined( self.animsapplied ) )
        self.animsapplied = [];

    self.animsapplied[self.animsapplied.size] = var_5;

    if ( isdefined( self.exploding ) )
        clear_anims( var_1 );

    if ( isdefined( var_9 ) && var_9 > 0 )
        wait(randomfloat( var_9 ));

    if ( !common_scripts\utility::isSP() )
    {
        if ( isdefined( var_8 ) )
            common_scripts\utility::self_func( "scriptModelPlayAnim", var_8 );

        return var_7;
    }

    if ( var_14 == "setanim" )
    {
        var_1 common_scripts\utility::self_func( "setanim", var_5, 1.0, 1.0, var_12 );
        return var_7;
    }

    if ( var_14 == "setanimknob" )
    {
        var_1 common_scripts\utility::self_func( "setanimknob", var_5, 1.0, 0, var_12 );
        return var_7;
    }

    return undefined;
}

clear_anims( var_0 )
{
    if ( isdefined( self.animsapplied ) )
    {
        foreach ( var_2 in self.animsapplied )
        {
            if ( common_scripts\utility::isSP() )
            {
                var_0 common_scripts\utility::self_func( "clearanim", var_2, 0 );
                continue;
            }

            var_0 common_scripts\utility::self_func( "scriptModelClearAnim" );
        }
    }
}

init_destroyed_count()
{
    level.destroyedCount = 0;
    level.destroyedCountTimeout = 0.5;

    if ( common_scripts\utility::isSP() )
        level.init_destroyed_count = 20;
    else
        level.init_destroyed_count = 2;
}

add_to_destroyed_count()
{
    level.destroyedCount++;
    wait(level.destroyedCountTimeout);
    level.destroyedCount--;
}

get_destroyed_count()
{
    return level.destroyedCount;
}

get_max_destroyed_count()
{
    return level.init_destroyed_count;
}

init_destructible_frame_queue()
{
    level.destructibleFrameQueue = [];
}

add_destructible_to_frame_queue( var_0, var_1, var_2 )
{
    var_3 = self getentitynumber();

    if ( !isdefined( level.destructibleFrameQueue[var_3] ) )
    {
        level.destructibleFrameQueue[var_3] = spawnstruct();
        level.destructibleFrameQueue[var_3].entNum = var_3;
        level.destructibleFrameQueue[var_3].destructible = var_0;
        level.destructibleFrameQueue[var_3].totalDamage = 0;
        level.destructibleFrameQueue[var_3].nearDistance = 9999999;
        level.destructibleFrameQueue[var_3].fxCost = 0;
    }

    level.destructibleFrameQueue[var_3].fxCost = level.destructibleFrameQueue[var_3].fxCost + var_1.v["fxcost"];
    level.destructibleFrameQueue[var_3].totalDamage = level.destructibleFrameQueue[var_3].totalDamage + var_2;

    if ( var_1.v["distance"] < level.destructibleFrameQueue[var_3].nearDistance )
        level.destructibleFrameQueue[var_3].nearDistance = var_1.v["distance"];

    thread handle_destructible_frame_queue();
}

handle_destructible_frame_queue()
{
    level notify( "handle_destructible_frame_queue" );
    level endon( "handle_destructible_frame_queue" );
    wait 0.05;
    var_0 = level.destructibleFrameQueue;
    level.destructibleFrameQueue = [];
    var_1 = sort_destructible_frame_queue( var_0 );

    for ( var_2 = 0; var_2 < var_1.size; var_2++ )
    {
        if ( get_destroyed_count() < get_max_destroyed_count() )
        {
            if ( var_1[var_2].fxCost )
                thread add_to_destroyed_count();

            var_1[var_2].destructible notify( "queue_processed",  1  );
            continue;
        }

        var_1[var_2].destructible notify( "queue_processed",  0  );
    }
}

sort_destructible_frame_queue( var_0 )
{
    var_1 = [];

    foreach ( var_3 in var_0 )
        var_1[var_1.size] = var_3;

    for ( var_5 = 1; var_5 < var_1.size; var_5++ )
    {
        var_6 = var_1[var_5];

        for ( var_7 = var_5 - 1; var_7 >= 0 && get_better_destructible( var_6, var_1[var_7] ) == var_6; var_7-- )
            var_1[var_7 + 1] = var_1[var_7];

        var_1[var_7 + 1] = var_6;
    }

    return var_1;
}

get_better_destructible( var_0, var_1 )
{
    if ( var_0.totalDamage > var_1.totalDamage )
        return var_0;
    else
        return var_1;
}

get_part_FX_cost_for_action_state( var_0, var_1 )
{
    var_2 = 0;

    if ( !isdefined( level.destructible_type[self.destructibleInfo].parts[var_0][var_1] ) )
        return var_2;

    var_3 = level.destructible_type[self.destructibleInfo].parts[var_0][var_1].v;

    if ( isdefined( var_3["fx"] ) )
    {
        foreach ( var_5 in var_3["fx_cost"] )
        {
            foreach ( var_7 in var_5 )
                var_2 += var_7;
        }
    }

    return var_2;
}

initdot( var_0 )
{
    if ( !common_scripts\utility::flag_exist( "FLAG_DOT_init" ) )
    {
        common_scripts\utility::flag_init( "FLAG_DOT_init" );
        common_scripts\utility::flag_set( "FLAG_DOT_init" );
    }

    var_0 = tolower( var_0 );

    switch ( var_0 )
    {
        case "poison":
            if ( !common_scripts\utility::flag_exist( "FLAG_DOT_poison_init" ) )
            {
                common_scripts\utility::flag_init( "FLAG_DOT_poison_init" );
                precacheshellshock( "mp_radiation_low" );
                precacheshellshock( "mp_radiation_med" );
                precacheshellshock( "mp_radiation_high" );
                common_scripts\utility::flag_set( "FLAG_DOT_poison_init" );
            }

            break;
    }

    endswitch( 2 )  case "poison" loc_4F5F default loc_4F96
}

createdot()
{
    var_0 = spawnstruct();
    var_0.ticks = [];
    return var_0;
}

createdot_radius( var_0, var_1, var_2, var_3 )
{
    var_4 = spawnstruct();
    var_4.type = "trigger_radius";
    var_4.origin = var_0;
    var_4.spawnflags = var_1;
    var_4.radius = var_2;
    var_4.minradius = var_2;
    var_4.maxradius = var_2;
    var_4.height = var_3;
    var_4.ticks = [];
    return var_4;
}

setdot_origin( var_0 )
{
    self.origin = var_0;
}

setdot_radius( var_0, var_1 )
{
    if ( isdefined( self.classname ) && self.classname != "trigger_radius" )
    {

    }

    if ( !isdefined( var_1 ) )
        var_1 = var_0;

    self.minradius = var_0;
    self.maxradius = var_1;
}

setdot_height( var_0, var_1 )
{
    if ( isdefined( self.classname ) && issubstr( self.classname, "trigger" ) )
        return;
}

setdot_ontick( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    if ( isdefined( var_0 ) )
    {

    }
    else
        var_0 = 0;

    var_6 = tolower( var_6 );
    var_7 = tolower( var_7 );
    var_8 = self.ticks.size;
    self.ticks[var_8] = spawnstruct();
    self.ticks[var_8].enable = 0;
    self.ticks[var_8].delay = var_0;
    self.ticks[var_8].interval = var_1;
    self.ticks[var_8].duration = var_2;
    self.ticks[var_8]._unk_field_ID10637 = var_3;
    self.ticks[var_8]._unk_field_ID10635 = var_4;

    switch ( var_5 )
    {
        case 0:
        case 1:
            break;
    }

    endswitch( 3 )  case 1 loc_50D9 case 0 loc_50D9 default loc_50DE
    self.ticks[var_8].falloff = var_5;
    self.ticks[var_8].startTime = 0;

    switch ( var_6 )
    {
        case "normal":
            break;
        case "poison":
            switch ( var_7 )
            {
                case "player":
                    self.ticks[var_8].type = var_6;
                    self.ticks[var_8].affected = var_7;
                    self.ticks[var_8].onenterfunc = ::onenterdot_poisondamageplayer;
                    self.ticks[var_8].onexitfunc = ::onexitdot_poisondamageplayer;
                    self.ticks[var_8].ondeathfunc = ::ondeathdot_poisondamageplayer;
                    break;
            }

            endswitch( 2 )  case "player" loc_511D default loc_5162
            break;
    }

    endswitch( 3 )  case "poison" loc_5117 case "normal" loc_5112 default loc_5178
}

builddot_ontick( var_0, var_1 )
{
    var_1 = tolower( var_1 );
    var_2 = self.ticks.size;
    self.ticks[var_2] = spawnstruct();
    self.ticks[var_2].duration = var_0;
    self.ticks[var_2].delay = 0;
    self.ticks[var_2].onenterfunc = ::onenterdot_buildfunc;
    self.ticks[var_2].onexitfunc = ::onexitdot_buildfunc;
    self.ticks[var_2].ondeathfunc = ::ondeathdot_buildfunc;

    switch ( var_1 )
    {
        case "player":
            self.ticks[var_2].affected = var_1;
            break;
    }

    endswitch( 2 )  case "player" loc_51F0 default loc_5200
}

builddot_startloop( var_0 )
{
    var_1 = self.ticks.size - 1;

    if ( !isdefined( self.ticks[var_1].statements ) )
        self.ticks[var_1].statements = [];

    var_2 = self.ticks[var_1].statements.size;
    self.ticks[var_1].statements = [];
    self.ticks[var_1].statements["vars"] = [];
    self.ticks[var_1].statements["vars"]["count"] = var_0;
}

builddot_damage( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    var_6 = self.ticks.size - 1;

    if ( !isdefined( self.ticks[var_6].statements["actions"] ) )
        self.ticks[var_6].statements["actions"] = [];

    var_7 = self.ticks[var_6].statements["actions"].size;
    self.ticks[var_6].statements["actions"][var_7] = [];
    self.ticks[var_6].statements["actions"][var_7]["vars"] = [ var_0, var_1, var_2, var_3, var_4, var_5 ];
    self.ticks[var_6].statements["actions"][var_7]["func"] = ::dobuilddot_damage;
}

builddot_wait( var_0 )
{
    var_1 = self.ticks.size - 1;

    if ( !isdefined( self.ticks[var_1].statements["actions"] ) )
        self.ticks[var_1].statements["actions"] = [];

    var_2 = self.ticks[var_1].statements["actions"].size;
    self.ticks[var_1].statements["actions"][var_2] = [];
    self.ticks[var_1].statements["actions"][var_2]["vars"] = [ var_0 ];
    self.ticks[var_1].statements["actions"][var_2]["func"] = ::dobuilddot_wait;
}

onenterdot_buildfunc( var_0, var_1 )
{
    var_2 = var_1 getentitynumber();
    var_1 endon( "death" );
    var_1 endon( "LISTEN_kill_tick_" + var_0 + "_" + var_2 );
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "death" );
    self endon( "LISTEN_exit_dot_" + var_2 );
    var_2 = undefined;
    var_3 = var_1.ticks[var_0].statements;

    if ( !isdefined( var_3 ) || !isdefined( var_3["vars"] ) || !isdefined( var_3["vars"]["count"] ) || !isdefined( var_3["actions"] ) )
        return;

    var_4 = var_3["vars"]["count"];
    var_5 = var_3["actions"];
    var_3 = undefined;

    for ( var_6 = 1; var_6 <= var_4 || var_4 == 0; var_6-- )
    {
        foreach ( var_8 in var_5 )
        {
            var_9 = var_8["vars"];
            var_10 = var_8["func"];
            self [[ var_10 ]]( var_0, var_1, var_9 );
        }
    }
}

onexitdot_buildfunc( var_0, var_1 )
{
    var_2 = var_1 getentitynumber();
    var_3 = self getentitynumber();
    var_1 notify( "LISTEN_kill_tick_" + var_0 + "_" + var_2 + "_" + var_3 );
}

ondeathdot_buildfunc( var_0, var_1 )
{

}

dobuilddot_damage( var_0, var_1, var_2 )
{
    var_3 = var_2[0];
    var_4 = var_2[1];
    var_5 = var_2[2];
    var_6 = var_2[3];
    var_7 = var_2[4];
    var_8 = var_2[5];
    self thread [[ level.callbackPlayerDamage ]]( var_1, var_1, var_4, var_6, var_7, var_8, var_1.origin, ( 0, 0, 0 ) - var_1.origin, "none", 0 );
}

dobuilddot_wait( var_0, var_1, var_2 )
{
    var_3 = var_1 getentitynumber();
    var_4 = self getentitynumber();
    var_1 endon( "death" );
    var_1 endon( "LISTEN_kill_tick_" + var_0 + "_" + var_3 );
    var_1 notify( "LISTEN_kill_tick_" + var_0 + "_" + var_3 + "_" + var_4 );
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "death" );
    self endon( "LISTEN_exit_dot_" + var_3 );
    var_3 = undefined;
    var_4 = undefined;
    wait(var_2[0]);
}

startdot_group( var_0 )
{
    var_1 = [];

    foreach ( var_3 in var_0 )
    {
        var_4 = undefined;

        switch ( var_3.type )
        {
            case "trigger_radius":
                var_4 = spawn( "trigger_radius", var_3.origin, var_3.spawnflags, var_3.radius, var_3.height );
                var_4.minradius = var_3.minradius;
                var_4.maxradius = var_3.maxradius;
                var_4.ticks = var_3.ticks;
                var_1[var_1.size] = var_4;
                break;
        }

        endswitch( 2 )  case "trigger_radius" loc_5586 default loc_55D0

        if ( isdefined( var_3.parent ) )
        {
            var_4 linkto( var_3.parent );
            var_3.parent._unk_field_ID25827 = var_4;
        }

        var_5 = var_4.ticks;

        foreach ( var_7 in var_5 )
            var_7.startTime = gettime();

        foreach ( var_7 in var_5 )
        {
            if ( !var_7.delay )
                var_7.enable = 1;
        }

        foreach ( var_7 in var_5 )
        {
            if ( issubstr( var_7.affected, "player" ) )
            {
                var_4.onplayer = 1;
                break;
            }
        }
    }

    foreach ( var_4 in var_1 )
    {
        var_4.dot_group = [];

        foreach ( var_16 in var_1 )
        {
            if ( var_4 == var_16 )
                continue;

            var_4.dot_group[var_4.dot_group.size] = var_16;
        }
    }

    foreach ( var_4 in var_1 )
    {
        if ( var_4.onplayer )
            var_4 thread startdot_player();
    }

    foreach ( var_4 in var_1 )
        var_4 thread monitordot();
}

startdot_player()
{
    thread triggerTouchThink( ::onenterdot_player, ::onexitdot_player );
}

monitordot()
{
    var_0 = gettime();

    while ( isdefined( self ) )
    {
        foreach ( var_4, var_2 in self.ticks )
        {
            if ( isdefined( var_2 ) && gettime() - var_0 >= var_2.duration * 1000 )
            {
                var_3 = self getentitynumber();
                self notify( "LISTEN_kill_tick_" + var_4 + "_" + var_3 );
                self.ticks[var_4] = undefined;
            }
        }

        if ( !self.ticks.size )
            break;

        wait 0.05;
    }

    if ( isdefined( self ) )
    {
        foreach ( var_2 in self.ticks )
            self [[ var_2.ondeathfunc ]]();

        self notify( "death" );
        self delete();
    }
}

onenterdot_player( var_0 )
{
    var_1 = var_0 getentitynumber();
    self notify( "LISTEN_enter_dot_" + var_1 );

    foreach ( var_4, var_3 in var_0.ticks )
    {
        if ( !var_3.enable )
            thread dodot_delayfunc( var_4, var_0, var_3.delay, var_3.onenterfunc );
    }

    foreach ( var_4, var_3 in var_0.ticks )
    {
        if ( var_3.enable && var_3.affected == "player" )
            self thread [[ var_3.onenterfunc ]]( var_4, var_0 );
    }
}

onexitdot_player( var_0 )
{
    var_1 = var_0 getentitynumber();
    self notify( "LISTEN_exit_dot_" + var_1 );

    foreach ( var_4, var_3 in var_0.ticks )
    {
        if ( var_3.enable && var_3.affected == "player" )
            self thread [[ var_3.onexitfunc ]]( var_4, var_0 );
    }
}

dodot_delayfunc( var_0, var_1, var_2, var_3 )
{
    var_4 = var_1 getentitynumber();
    var_5 = self getentitynumber();
    var_1 endon( "LISTEN_kill_tick_" + var_0 + "_" + var_4 + "_" + var_5 );
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "death" );
    self notify( "LISTEN_exit_dot_" + var_4 );
    var_4 = undefined;
    var_5 = undefined;
    wait(var_2);
    self thread [[ var_3 ]]( var_0, var_1 );
}

onenterdot_poisondamageplayer( var_0, var_1 )
{
    var_2 = var_1 getentitynumber();
    var_3 = self getentitynumber();
    var_1 endon( "death" );
    var_1 endon( "LISTEN_kill_tick_" + var_0 + "_" + var_2 );
    var_1 endon( "LISTEN_kill_tick_" + var_0 + "_" + var_2 + "_" + var_3 );
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "death" );
    self endon( "LISTEN_exit_dot_" + var_2 );

    if ( !isdefined( self.onenterdot_poisondamagecount ) )
        self.onenterdot_poisondamagecount = [];

    if ( !isdefined( self.onenterdot_poisondamagecount[var_0] ) )
        self.onenterdot_poisondamagecount[var_0] = [];

    self.onenterdot_poisondamagecount[var_0][var_2] = 0;
    var_4 = common_scripts\utility::ter_op( common_scripts\utility::isSP(), 1.5, 1 );

    while ( isdefined( var_1 ) && isdefined( var_1.ticks[var_0] ) )
    {
        self.onenterdot_poisondamagecount[var_0][var_2]++;

        switch ( self.onenterdot_poisondamagecount[var_0][var_2] )
        {
            case 1:
                self viewkick( 1, self.origin );
                break;
            case 3:
                self shellshock( "mp_radiation_low", 4 );
                dodot_poisondamage( var_1, var_4 * 2 );
                break;
            case 4:
                self shellshock( "mp_radiation_med", 5 );
                thread dodot_poisonblackout( var_0, var_1 );
                dodot_poisondamage( var_1, var_4 * 2 );
                break;
            case 6:
                self shellshock( "mp_radiation_high", 5 );
                dodot_poisondamage( var_1, var_4 * 2 );
                break;
            case 8:
                self shellshock( "mp_radiation_high", 5 );
                dodot_poisondamage( var_1, var_4 * 500 );
                break;
        }

        wait(var_1.ticks[var_0].interval);
    }
}

onexitdot_poisondamageplayer( var_0, var_1 )
{
    var_2 = var_1 getentitynumber();
    var_3 = self getentitynumber();
    var_4 = self.onenterdot_poisondamageoverlay;

    if ( isdefined( var_4 ) )
    {
        foreach ( var_7, var_6 in var_4 )
        {
            if ( isdefined( var_4[var_7] ) && isdefined( var_4[var_7][var_2] ) )
                var_4[var_7][var_2] thread dodot_fadeoutblackout( 0.1, 0 );
        }
    }

    var_1 notify( "LISTEN_kill_tick_" + var_0 + "_" + var_2 + "_" + var_3 );
}

ondeathdot_poisondamageplayer()
{
    var_0 = self getentitynumber();

    foreach ( var_2 in level.players )
    {
        var_3 = var_2.onenterdot_poisondamageoverlay;

        if ( isdefined( var_3 ) )
        {
            foreach ( var_6, var_5 in var_3 )
            {
                if ( isdefined( var_3[var_6] ) && isdefined( var_3[var_6][var_0] ) )
                    var_3[var_6][var_0] thread dodot_fadeoutblackoutanddestroy();
            }
        }
    }
}

dodot_poisondamage( var_0, var_1 )
{
    if ( common_scripts\utility::isSP() )
        return;

    self thread [[ level.callbackPlayerDamage ]]( var_0, var_0, var_1, 0, "MOD_SUICIDE", "claymore_mp", var_0.origin, ( 0, 0, 0 ) - var_0.origin, "none", 0 );
    return;
}

dodot_poisonblackout( var_0, var_1 )
{
    var_2 = var_1 getentitynumber();
    var_3 = self getentitynumber();
    var_1 endon( "death" );
    var_1 endon( "LISTEN_kill_tick_" + var_0 + "_" + var_2 );
    var_1 endon( "LISTEN_kill_tick_" + var_0 + "_" + var_2 + "_" + var_3 );
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "death" );
    self endon( "LISTEN_exit_dot_" + var_2 );

    if ( !isdefined( self.onenterdot_poisondamageoverlay ) )
        self.onenterdot_poisondamageoverlay = [];

    if ( !isdefined( self.onenterdot_poisondamageoverlay[var_0] ) )
        self.onenterdot_poisondamageoverlay[var_0] = [];

    if ( !isdefined( self.onenterdot_poisondamageoverlay[var_0][var_2] ) )
    {
        var_4 = newclienthudelem( self );
        var_4.x = 0;
        var_4.y = 0;
        var_4.alignx = "left";
        var_4.aligny = "top";
        var_4.horzalign = "fullscreen";
        var_4.vertalign = "fullscreen";
        var_4.alpha = 0;
        var_4 setshader( "black", 640, 480 );
        self.onenterdot_poisondamageoverlay[var_0][var_2] = var_4;
    }

    var_4 = self.onenterdot_poisondamageoverlay[var_0][var_2];
    var_5 = 1;
    var_6 = 2;
    var_7 = 0.25;
    var_8 = 1;
    var_9 = 5;
    var_10 = 100;
    var_11 = 0;

    for (;;)
    {
        while ( self.onenterdot_poisondamagecount[var_0][var_2] > 1 )
        {
            var_12 = var_10 - var_9;
            var_11 = ( self.onenterdot_poisondamagecount[var_0][var_2] - var_9 ) / var_12;

            if ( var_11 < 0 )
                var_11 = 0;
            else if ( var_11 > 1 )
                var_11 = 1;

            var_13 = var_6 - var_5;
            var_14 = var_5 + var_13 * ( 1 - var_11 );
            var_15 = var_8 - var_7;
            var_16 = var_7 + var_15 * var_11;
            var_17 = var_11 * 0.5;

            if ( var_11 == 1 )
                break;

            var_18 = var_14 / 2;
            var_4 dodot_fadeinblackout( var_18, var_16 );
            var_4 dodot_fadeoutblackout( var_18, var_17 );
            wait(var_11 * 0.5);
        }

        if ( var_11 == 1 )
            break;

        if ( var_4.alpha != 0 )
            var_4 dodot_fadeoutblackout( 1, 0 );

        wait 0.05;
    }

    var_4 dodot_fadeinblackout( 2, 0 );
}

dodot_fadeinblackout( var_0, var_1 )
{
    self fadeovertime( var_0 );
    self.alpha = var_1;
    var_1 = undefined;
    wait(var_0);
}

dodot_fadeoutblackout( var_0, var_1 )
{
    self fadeovertime( var_0 );
    self.alpha = var_1;
    var_1 = undefined;
    wait(var_0);
}

dodot_fadeoutblackoutanddestroy( var_0, var_1 )
{
    self fadeovertime( var_0 );
    self.alpha = var_1;
    var_1 = undefined;
    wait(var_0);
    self destroy();
}

triggerTouchThink( var_0, var_1 )
{
    level endon( "game_ended" );
    self endon( "death" );
    self.entNum = self getentitynumber();

    for (;;)
    {
        self waittill( "trigger",  var_2  );

        if ( !isplayer( var_2 ) && !isdefined( var_2.finished_spawning ) )
            continue;

        if ( !isalive( var_2 ) )
            continue;

        if ( !isdefined( var_2.touchTriggers[self.entNum] ) )
            var_2 thread playerTouchTriggerThink( self, var_0, var_1 );
    }
}

playerTouchTriggerThink( var_0, var_1, var_2 )
{
    var_0 endon( "death" );

    if ( !isplayer( self ) )
        self endon( "death" );

    if ( !common_scripts\utility::isSP() )
        var_3 = self.guid;
    else
        var_3 = "player" + gettime();

    var_0.touchList[var_3] = self;

    if ( isdefined( var_0.moveTracker ) )
        self.moveTrackers++;

    var_0 notify( "trigger_enter",  self  );
    self notify( "trigger_enter",  var_0  );
    var_4 = 1;

    foreach ( var_6 in var_0.dot_group )
    {
        foreach ( var_8 in self.touchTriggers )
        {
            if ( var_6 == var_8 )
                var_4 = 0;
        }
    }

    if ( var_4 && isdefined( var_1 ) )
        self thread [[ var_1 ]]( var_0 );

    self.touchTriggers[var_0.entNum] = var_0;

    while ( isalive( self ) && ( common_scripts\utility::isSP() || !level.gameEnded ) )
    {
        var_11 = 1;

        if ( self istouching( var_0 ) )
            wait 0.05;
        else
        {
            if ( !var_0.dot_group.size )
                var_11 = 0;

            foreach ( var_6 in var_0.dot_group )
            {
                if ( self istouching( var_6 ) )
                {
                    wait 0.05;
                    break;
                    continue;
                }

                var_11 = 0;
            }
        }

        if ( !var_11 )
            break;
    }

    if ( isdefined( self ) )
    {
        self.touchTriggers[var_0.entNum] = undefined;

        if ( isdefined( var_0.moveTracker ) )
            self.moveTrackers--;

        self notify( "trigger_leave",  var_0  );

        if ( var_4 && isdefined( var_2 ) )
            self thread [[ var_2 ]]( var_0 );
    }

    if ( !common_scripts\utility::isSP() && level.gameEnded )
        return;

    var_0.touchList[var_3] = undefined;
    var_0 notify( "trigger_leave",  self  );

    if ( !anythingTouchingTrigger( var_0 ) )
        var_0 notify( "trigger_empty" );
}

anythingTouchingTrigger( var_0 )
{
    return var_0.touchList.size;
}
