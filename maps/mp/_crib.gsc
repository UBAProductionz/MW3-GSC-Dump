// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precacheshellshock( "frag_grenade_mp" );
    radial_button_definitions();
    radial_init();
    view_path_setup();
    player_init();
}

radial_button_definitions()
{
    newRadialButtonGroup( "main", "player_view1_start", "player_view1_end" );
    var_0 = newRadialButton( "main", "Primary Weapon", "radial_weapons_primary", ::action_weapons_primary );
    var_1 = newRadialButton( "main", "Secondary Weapon", "radial_weapons_secondary", ::action_weapons_secondary );
    var_2 = newRadialButton( "main", "Gears", "radial_gears", ::action_gears );
    var_3 = newRadialButton( "main", "Kill Streaks", "radial_killstreaks", ::action_killstreak );
    var_4 = newRadialButton( "main", "Leaderboards", "radial_leaderboards", ::action_leaderboards );
    newRadialButtonGroup( "gears", "player_view2_start", "player_view2_end" );
    newRadialButtonGroup( "weapons_primary", "player_view3_start", "player_view3_end" );
    newRadialButtonGroup( "weapons_secondary", "player_view3_start", "player_view3_end" );
    newRadialButtonGroup( "killstreak", "player_view4_start", "player_view4_end" );
    newRadialButtonGroup( "leaderboards", "player_view5_start", "player_view5_end" );
}

radial_init()
{
    foreach ( var_1 in level.radial_button_group )
    {
        sort_buttons_by_angle( var_1 );

        for ( var_2 = 0; var_2 < var_1.size; var_2++ )
        {
            if ( isdefined( var_1[var_2 + 1] ) )
            {
                var_3 = getMidAngle( var_1[var_2].pos_angle, var_1[var_2 + 1].pos_angle );
                var_1[var_2].end_angle = var_3;
                var_1[var_2 + 1].start_angle = var_3;
                continue;
            }

            var_3 = getMidAngle( var_1[var_2].pos_angle, var_1[0].pos_angle ) + 180;

            if ( var_3 > 360 )
                var_3 -= 360;

            var_1[var_2].end_angle = var_3;
            var_1[0].start_angle = var_3;
        }
    }

    thread updateSelectedButton();
    thread watchSelectButtonPress();
    thread watchBackButtonPress();
    thread debug_toggle();
}

debug_toggle()
{
    level endon( "game_ended" );
    level.crib_debug = 1;

    for (;;)
    {
        if ( !isdefined( level.observer ) )
        {
            wait 0.05;
            continue;
        }

        var_0 = 1;

        while ( !level.observer buttonpressed( "BUTTON_Y" ) )
            wait 0.05;

        level.observer playsound( "mouse_click" );

        if ( var_0 )
        {
            level.crib_debug = level.crib_debug * -1;
            var_0 = 0;
        }

        while ( level.observer buttonpressed( "BUTTON_Y" ) )
            wait 0.05;
    }
}

player_init()
{
    level thread onPlayerConnect();
    level thread return_hud();
}

return_hud()
{
    level waittill( "game_ended" );
    setdvar( "cg_draw2d", 1 );
}

onPlayerConnect()
{
    level waittill( "connected",  var_0  );
    var_0 thread readyPlayer();
    var_0 waittill( "spawned_player" );
    wait 1;
    var_0 takeallweapons();
    setdvar( "cg_draw2d", 0 );

    if ( !isdefined( var_0 ) )
        return;
    else
        level.observer = var_0;

    var_0 thread get_right_stick_angle();
    zoom_to_radial_menu( "main" );
}

readyPlayer()
{
    self endon( "disconnect" );
    var_0 = "autoassign";

    while ( !isdefined( self.pers["team"] ) )
        wait 0.05;

    self notify( "menuresponse",  game["menu_team"], var_0  );
    wait 0.5;
    var_1 = getarraykeys( level.classMap );
    var_2 = [];

    for ( var_3 = 0; var_3 < var_1.size; var_3++ )
    {
        if ( !issubstr( var_1[var_3], "custom" ) )
            var_2[var_2.size] = var_1[var_3];
    }

    for (;;)
    {
        var_4 = var_2[0];
        self notify( "menuresponse",  "changeclass", var_4  );
        self waittill( "spawned_player" );
        wait 0.1;
    }
}

get_right_stick_angle()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
        var_0 = self getnormalizedmovement();
        var_1 = vectortoangles( var_0 );
        level.rs_angle = int( var_1[1] );
        wait 0.05;
    }
}

newRadialButtonGroup( var_0, var_1, var_2 )
{
    if ( isdefined( level.radial_button_group ) && level.radial_button_group.size )
    {

    }

    var_3 = getent( var_2, "targetname" );
    var_4 = vectornormalize( anglestoforward( var_3.angles ) ) * 40;
    level.radial_button_group[var_0] = [];
    level.radial_button_group_info[var_0]["view_start"] = var_1;
    level.radial_button_group_info[var_0]["view_pos"] = var_3.origin + var_4;
    level.radial_button_group_info[var_0]["player_view_pos"] = var_3.origin;
    level.radial_button_group_info[var_0]["view_angles"] = var_3.angles;
}

newRadialButton( var_0, var_1, var_2, var_3 )
{
    var_4 = getent( var_2, "targetname" );
    var_5 = getRadialAngleFromEnt( var_0, var_4 );
    var_6 = spawnstruct();
    var_6.pos = var_4.origin;
    var_6.label = var_1;
    var_6.font_size = 1;
    var_6.font_color = ( 0.5, 0.5, 1 );
    var_6.pos_angle = var_5;
    var_6.action_func = var_3;
    var_6.radius_pos = 8;
    level.radial_button_group[var_0][level.radial_button_group[var_0].size] = var_6;
    return var_6;
}

updateSelectedButton()
{
    level endon( "game_ended" );

    for (;;)
    {
        if ( !isdefined( level.radial_button_current_group ) )
        {
            wait 0.05;
            continue;
        }

        var_0 = level.active_button;

        foreach ( var_2 in level.radial_button_group[level.radial_button_current_group] )
        {
            if ( isInRange( var_2.start_angle, var_2.end_angle ) )
            {
                level.active_button = var_2;
                continue;
            }

            var_2.font_color = ( 0.5, 0.5, 1 );
        }

        if ( isdefined( level.active_button ) )
        {
            level.active_button.font_color = ( 1, 1, 0.5 );

            if ( isdefined( var_0 ) && var_0 != level.active_button )
                level.observer playsound( "mouse_over" );
        }

        wait 0.05;
    }
}

watchSelectButtonPress()
{
    level endon( "game_ended" );

    for (;;)
    {
        if ( !isdefined( level.observer ) )
        {
            wait 0.05;
            continue;
        }

        var_0 = 1;

        while ( !level.observer buttonpressed( "BUTTON_A" ) )
            wait 0.05;

        level.observer playsound( "mouse_click" );

        if ( isdefined( level.active_button ) && var_0 )
        {
            level.active_button notify( "select_button_pressed" );
            [[ level.active_button.action_func ]]();
            var_0 = 0;
        }

        while ( level.observer buttonpressed( "BUTTON_A" ) )
            wait 0.05;
    }
}

watchBackButtonPress()
{
    level endon( "game_ended" );

    for (;;)
    {
        if ( !isdefined( level.observer ) )
        {
            wait 0.05;
            continue;
        }

        var_0 = 1;

        while ( !level.observer buttonpressed( "BUTTON_X" ) )
            wait 0.05;

        level.observer playsound( "mouse_click" );

        if ( var_0 )
        {
            action_back();
            var_0 = 0;
        }

        while ( level.observer buttonpressed( "BUTTON_X" ) )
            wait 0.05;
    }
}

sort_buttons_by_angle( var_0 )
{
    for ( var_1 = 0; var_1 < var_0.size - 1; var_1++ )
    {
        for ( var_2 = 0; var_2 < var_0.size - 1 - var_1; var_2++ )
        {
            if ( var_0[var_2 + 1].pos_angle < var_0[var_2].pos_angle )
                button_switch( var_0[var_2], var_0[var_2 + 1] );
        }
    }
}

button_switch( var_0, var_1 )
{
    var_2 = var_0.pos;
    var_3 = var_0.label;
    var_4 = var_0.pos_angle;
    var_5 = var_0.action_func;
    var_6 = var_0.radius_pos;
    var_0.pos = var_1.pos;
    var_0.label = var_1.label;
    var_0.pos_angle = var_1.pos_angle;
    var_0.action_func = var_1.action_func;
    var_0.radius_pos = var_1.radius_pos;
    var_1.pos = var_2;
    var_1.label = var_3;
    var_1.pos_angle = var_4;
    var_1.action_func = var_5;
    var_1.radius_pos = var_6;
}

draw_radial_buttons( var_0 )
{
    foreach ( var_2 in level.radial_button_group[var_0] )
        var_2 thread draw_radial_button( var_0 );
}

draw_radial_button( var_0 )
{
    level endon( "game_ended" );
    self endon( "remove_button" );
    var_1 = level.radial_button_group_info[var_0]["view_pos"];
    var_2 = var_1 + radial_angle_to_vector( self.pos_angle, 4 );

    for (;;)
    {
        var_3 = ( 1, 0, 0 );

        if ( isInRange( self.start_angle, self.end_angle ) )
            var_3 = ( 1, 1, 0 );

        if ( isdefined( level.crib_debug ) && level.crib_debug > 0 )
            var_4 = var_1 + radial_angle_to_vector( level.rs_angle, 2 );

        wait 0.05;
    }
}

zoom_to_radial_menu( var_0, var_1 )
{
    level.active_button = undefined;

    if ( isdefined( level.radial_button_current_group ) && level.radial_button_current_group != "" )
        level.radial_button_previous_group = level.radial_button_current_group;
    else
    {
        level.radial_button_previous_group = "main";
        level.radial_button_current_group = "main";
    }

    foreach ( var_3 in level.radial_button_group[level.radial_button_previous_group] )
        var_3 notify( "remove_button" );

    if ( isdefined( var_1 ) && var_1 )
        level.observer go_path_by_targetname_reverse( level.radial_button_group_info[level.radial_button_previous_group]["view_start"], var_0 );
    else
        level.observer go_path_by_targetname( level.radial_button_group_info[var_0]["view_start"] );

    level thread draw_radial_buttons( var_0 );
    level.radial_button_current_group = var_0;
}

getRadialAngleFromEnt( var_0, var_1 )
{
    var_2 = level.radial_button_group_info[var_0]["view_angles"];
    var_3 = level.radial_button_group_info[var_0]["view_pos"];
    var_3 += vectornormalize( anglestoforward( var_2 ) ) * 40;
    var_4 = anglestoforward( var_2 );
    var_5 = vectornormalize( anglestoup( var_2 ) );
    var_6 = var_1.angles;
    var_7 = var_1.origin;
    var_8 = vectornormalize( vectorfromlinetopoint( var_3, var_3 + var_4, var_7 ) );
    var_9 = acos( vectordot( var_8, var_5 ) );

    if ( vectordot( anglestoright( var_2 ), var_8 ) < 0 )
        var_9 = 360 - var_9;

    return var_9;
}

radial_angle_to_vector( var_0, var_1 )
{
    var_2 = ( 270 - var_0, 0, 0 );
    var_3 = anglestoforward( var_2 );
    var_4 = vectornormalize( var_3 );
    var_5 = var_4 * var_1;
    return var_5;
}

getMidAngle( var_0, var_1 )
{
    var_2 = ( var_0 + var_1 + 720 ) / 2 - 360;
    return var_2;
}

isInRange( var_0, var_1 )
{
    var_2 = level.rs_angle > var_0 && level.rs_angle < 360;
    var_3 = level.rs_angle > 0 && level.rs_angle < var_1;

    if ( var_0 > var_1 )
        var_4 = var_2 || var_3;
    else
        var_4 = level.rs_angle > var_0 && level.rs_angle < var_1;

    return var_4;
}

action_back()
{
    if ( isdefined( level.radial_button_current_group ) && level.radial_button_current_group != "main" )
        zoom_to_radial_menu( "main", 1 );
    else
        return;
}

action_weapons_primary()
{
    iprintlnbold( "action_weapons_primary" );
    zoom_to_radial_menu( "weapons_primary" );
}

action_weapons_secondary()
{
    iprintlnbold( "action_weapons_secondary" );
    zoom_to_radial_menu( "weapons_secondary" );
}

action_gears()
{
    iprintlnbold( "action_gears" );
    zoom_to_radial_menu( "gears" );
}

action_killstreak()
{
    iprintlnbold( "action_killstreak" );
    zoom_to_radial_menu( "killstreak" );
}

action_leaderboards()
{
    iprintlnbold( "action_leaderboards" );
    zoom_to_radial_menu( "leaderboards" );
}

view_path_setup()
{
    level.view_paths = [];
    build_path_by_targetname( "player_view1_start" );
    build_path_by_targetname( "player_view2_start" );
    build_path_by_targetname( "player_view3_start" );
    build_path_by_targetname( "player_view4_start" );
    build_path_by_targetname( "player_view5_start" );
}

build_path_by_targetname( var_0 )
{
    level.view_paths[var_0] = [];
    var_1 = getent( var_0, "targetname" );

    for ( level.view_paths[var_0][level.view_paths[var_0].size] = var_1; isdefined( var_1 ) && isdefined( var_1.target ); var_1 = var_2 )
    {
        var_2 = getent( var_1.target, "targetname" );
        level.view_paths[var_0][level.view_paths[var_0].size] = var_2;
    }
}

go_path_by_targetname( var_0 )
{
    if ( !isdefined( level.dummy_mover ) )
    {
        var_1 = level.view_paths[var_0][0];
        level.dummy_mover = spawn( "script_model", var_1.origin );
        level.dummy_mover.angles = var_1.angles;
        self setorigin( level.dummy_mover.origin - ( 0, 0, 65 ) );
        self linkto( level.dummy_mover );
        wait 0.05;
        self setplayerangles( level.dummy_mover.angles );
        thread force_player_angles();
    }

    var_2 = 1;
    var_3 = abs( distance( level.dummy_mover.origin, level.view_paths[var_0][level.view_paths[var_0].size - 1].origin ) );
    var_2 *= var_3 / 1200;
    var_2 = max( var_2, 0.1 );
    var_4 = var_2;

    if ( !1 )
        var_4 *= ( var_2 * ( level.view_paths[var_0].size + 1 ) );

    thread blur_sine( 3, var_4 );

    foreach ( var_7, var_6 in level.view_paths[var_0] )
    {
        if ( 1 )
        {
            if ( var_7 != level.view_paths[var_0].size - 1 )
                continue;
        }

        level.dummy_mover moveto( var_6.origin, var_2, var_2 * 0.5, 0 );
        level.dummy_mover rotateto( var_6.angles, var_2, var_2 * 0.5, 0 );
        wait(var_2);
    }
}

go_path_by_targetname_reverse( var_0, var_1 )
{
    var_2 = 1;
    var_3 = abs( distance( level.dummy_mover.origin, level.radial_button_group_info[var_1]["player_view_pos"] ) );
    var_2 *= var_3 / 1200;
    var_2 = max( var_2, 0.1 );
    var_4 = var_2;

    if ( !1 )
        var_4 *= ( var_2 * ( level.view_paths[var_0].size + 1 ) );

    thread blur_sine( 3, var_4 );

    if ( !1 )
    {
        for ( var_5 = level.view_paths[var_0].size - 1; var_5 >= 0; var_5-- )
        {
            var_6 = level.view_paths[var_0][var_5];
            level.dummy_mover moveto( var_6.origin, var_2 );
            level.dummy_mover rotateto( var_6.angles, var_2 );
            wait(var_2);
        }
    }

    thread blur_sine( 3, var_2 );
    var_7 = level.radial_button_group_info[var_1]["player_view_pos"];
    var_8 = level.radial_button_group_info[var_1]["view_angles"];
    level.dummy_mover moveto( var_7, var_2, var_2 * 0.5, 0 );
    level.dummy_mover rotateto( var_8, var_2, var_2 * 0.5, 0 );
    wait(var_2);
}

travel_view_fx( var_0 )
{
    self setblurforplayer( 20, ( var_0 + 0.2 ) / 2 );
    self setblurforplayer( 0, ( var_0 + 0.2 ) / 2 );
    self shellshock( "frag_grenade_mp", var_0 + 0.2 );
}

blur_sine( var_0, var_1 )
{
    var_2 = int( var_1 / 0.05 );

    for ( var_3 = 0; var_3 < var_2; var_3++ )
    {
        var_4 = var_3 / var_2;
        var_5 = sin( 180 * var_4 );
        var_6 = var_0 * var_5;
        setdvar( "r_blur", var_6 );
        wait 0.05;
    }

    setdvar( "r_blur", 0 );
}

force_player_angles()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    level.dummy_mover endon( "remove_dummy" );

    for (;;)
    {
        self setplayerangles( level.dummy_mover.angles );
        wait 0.05;
    }
}
