// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

menu( var_0 )
{
    return level.create_fx_menu == var_0;
}

setmenu( var_0 )
{
    level.create_fx_menu = var_0;
}

create_fx_menu()
{
    if ( common_scripts\_createfx::button_is_clicked( "escape", "x" ) )
        _exit_menu();
    else if ( menu( "creation" ) )
    {
        if ( common_scripts\_createfx::button_is_clicked( "1" ) )
        {
            setmenu( "create_oneshot" );
            draw_effects_list();
            return;
        }

        if ( common_scripts\_createfx::button_is_clicked( "2" ) )
        {
            setmenu( "create_loopfx" );
            draw_effects_list();
            return;
        }

        if ( common_scripts\_createfx::button_is_clicked( "3" ) )
        {
            setmenu( "create_loopsound" );
            var_0 = common_scripts\_createfx::createLoopSound();
            finish_creating_entity( var_0 );
            return;
        }

        if ( common_scripts\_createfx::button_is_clicked( "4" ) )
        {
            setmenu( "create_exploder" );
            var_0 = common_scripts\_createfx::createNewExploder();
            finish_creating_entity( var_0 );
            return;
        }

        if ( common_scripts\_createfx::button_is_clicked( "5" ) )
        {
            setmenu( "create_interval_sound" );
            var_0 = common_scripts\_createfx::createIntervalSound();
            finish_creating_entity( var_0 );
            return;
        }
    }
    else if ( menu( "create_oneshot" ) || menu( "create_loopfx" ) || menu( "change_fxid" ) )
    {
        if ( common_scripts\_createfx::button_is_clicked( "m" ) )
        {
            increment_list_offset();
            draw_effects_list();
        }

        menu_fx_creation();
    }
    else
    {
        if ( menu( "none" ) )
        {
            if ( common_scripts\_createfx::button_is_clicked( "m" ) )
                increment_list_offset();

            menu_change_selected_fx();

            if ( entities_are_selected() )
            {
                var_1 = get_last_selected_entity();

                if ( !isdefined( level.last_displayed_ent ) || var_1 != level.last_displayed_ent )
                {
                    display_fx_info( var_1 );
                    level.last_displayed_ent = var_1;
                }

                if ( common_scripts\_createfx::button_is_clicked( "a" ) )
                {
                    common_scripts\_createfx::clear_settable_fx();
                    setmenu( "add_options" );
                    return;
                }

                return;
            }

            return;
        }

        if ( menu( "add_options" ) )
        {
            if ( !entities_are_selected() )
            {
                common_scripts\_createfx::clear_fx_hudElements();
                setmenu( "none" );
                return;
            }

            display_fx_add_options( get_last_selected_entity() );

            if ( common_scripts\_createfx::button_is_clicked( "m" ) )
                increment_list_offset();
        }
    }
}

_exit_menu()
{
    common_scripts\_createfx::clear_fx_hudElements();
    common_scripts\_createfx::clear_entity_selection();
    common_scripts\_createfx::update_selected_entities();
    setmenu( "none" );
}

get_last_selected_entity()
{
    return level.selected_fx_ents[level.selected_fx_ents.size - 1];
}

menu_fx_creation()
{
    var_0 = 0;
    var_1 = undefined;
    var_2 = common_scripts\_createfx::func_get_level_fx();

    for ( var_3 = level.effect_list_offset; var_3 < var_2.size; var_3++ )
    {
        var_0 += 1;
        var_4 = var_0;

        if ( var_4 == 10 )
            var_4 = 0;

        if ( common_scripts\_createfx::button_is_clicked( var_4 + "" ) )
        {
            var_1 = var_2[var_3];
            break;
        }

        if ( var_0 > level.effect_list_offset_max )
            break;
    }

    if ( !isdefined( var_1 ) )
        return;

    if ( menu( "change_fxid" ) )
    {
        apply_option_to_selected_fx( get_option( "fxid" ), var_1 );
        level.effect_list_offset = 0;
        common_scripts\_createfx::clear_fx_hudElements();
        setmenu( "none" );
        return;
    }

    var_5 = undefined;

    if ( menu( "create_loopfx" ) )
        var_5 = common_scripts\utility::createLoopEffect( var_1 );

    if ( menu( "create_oneshot" ) )
        var_5 = common_scripts\utility::createOneshotEffect( var_1 );

    finish_creating_entity( var_5 );
}

finish_creating_entity( var_0 )
{
    var_0.v["angles"] = vectortoangles( var_0.v["origin"] + ( 0, 0, 100 ) - var_0.v["origin"] );
    var_0 common_scripts\_createfx::post_entity_creation_function();
    common_scripts\_createfx::clear_entity_selection();
    common_scripts\_createfx::select_last_entity();
    common_scripts\_createfx::move_selection_to_cursor();
    common_scripts\_createfx::update_selected_entities();
    setmenu( "none" );
}

menu_init()
{
    level.createFX_options = [];
    addOption( "string", "fxid", "The FX", "nil", "fx" );
    addOption( "float", "delay", "Repeat rate/start delay", 0.5, "fx" );
    addOption( "float", "fire_range", "Fire damage range", 0, "fx" );
    addOption( "string", "flag", "Flag", "nil", "exploder" );
    addOption( "string", "firefx", "2nd FX id", "nil", "exploder" );
    addOption( "float", "firefxdelay", "2nd FX id repeat rate", 0.5, "exploder" );
    addOption( "float", "firefxtimeout", "2nd FX timeout", 5, "exploder" );
    addOption( "string", "firefxsound", "2nd FX soundalias", "nil", "exploder" );
    addOption( "float", "damage", "Radius damage", 150, "exploder" );
    addOption( "float", "damage_radius", "Radius of radius damage", 250, "exploder" );
    addOption( "float", "delay_min", "Minimimum time between repeats", 1, "soundfx_interval" );
    addOption( "float", "delay_max", "Maximum time between repeats", 2, "soundfx_interval" );
    addOption( "int", "repeat", "Number of times to repeat", 5, "exploder" );
    addOption( "string", "exploder", "Exploder", "1", "exploder" );
    addOption( "string", "earthquake", "Earthquake", "nil", "exploder" );

    if ( !level.mp_createfx )
        addOption( "string", "rumble", "Rumble", "nil", "exploder" );

    addOption( "string", "ender", "Level notify for ending 2nd FX", "nil", "exploder" );
    addOption( "string", "soundalias", "Soundalias", "nil", "all" );
    addOption( "string", "loopsound", "Loopsound", "nil", "exploder" );

    if ( !level.mp_createfx )
        addOption( "int", "stoppable", "Can be stopped from script", "1", "all" );

    level.effect_list_offset = 0;
    level.effect_list_offset_max = 10;
    level.createfxMasks = [];
    level.createfxMasks["all"] = [];
    level.createfxMasks["all"]["exploder"] = 1;
    level.createfxMasks["all"]["oneshotfx"] = 1;
    level.createfxMasks["all"]["loopfx"] = 1;
    level.createfxMasks["all"]["soundfx"] = 1;
    level.createfxMasks["all"]["soundfx_interval"] = 1;
    level.createfxMasks["fx"] = [];
    level.createfxMasks["fx"]["exploder"] = 1;
    level.createfxMasks["fx"]["oneshotfx"] = 1;
    level.createfxMasks["fx"]["loopfx"] = 1;
    level.createfxMasks["exploder"] = [];
    level.createfxMasks["exploder"]["exploder"] = 1;
    level.createfxMasks["loopfx"] = [];
    level.createfxMasks["loopfx"]["loopfx"] = 1;
    level.createfxMasks["oneshotfx"] = [];
    level.createfxMasks["oneshotfx"]["oneshotfx"] = 1;
    level.createfxMasks["soundfx"] = [];
    level.createfxMasks["soundfx"]["soundalias"] = 1;
    level.createfxMasks["soundfx_interval"] = [];
    level.createfxMasks["soundfx_interval"]["soundfx_interval"] = 1;
}

get_last_selected_ent()
{
    return level.selected_fx_ents[level.selected_fx_ents.size - 1];
}

entities_are_selected()
{
    return level.selected_fx_ents.size > 0;
}

menu_change_selected_fx()
{
    if ( !level.selected_fx_ents.size )
        return;

    var_0 = 0;
    var_1 = 0;
    var_2 = get_last_selected_ent();

    for ( var_3 = 0; var_3 < level.createFX_options.size; var_3++ )
    {
        var_4 = level.createFX_options[var_3];

        if ( !isdefined( var_2.v[var_4["name"]] ) )
            continue;

        var_0++;

        if ( var_0 < level.effect_list_offset )
            continue;

        var_1++;
        var_5 = var_1;

        if ( var_5 == 10 )
            var_5 = 0;

        if ( common_scripts\_createfx::button_is_clicked( var_5 + "" ) )
        {
            prepare_option_for_change( var_4, var_1 );
            break;
        }

        if ( var_1 > level.effect_list_offset_max )
        {
            var_6 = 1;
            break;
        }
    }
}

prepare_option_for_change( var_0, var_1 )
{
    if ( var_0["name"] == "fxid" )
    {
        setmenu( "change_fxid" );
        draw_effects_list();
        return;
    }

    common_scripts\_createfx::createfx_centerprint( "To change " + var_0["description"] + " on selected entities, type /fx newvalue" );
    level.createfx_inputlocked = 1;
    set_option_index( var_0["name"] );
    setdvar( "fx", "nil" );
    level.createFxHudElements[var_1 + 3][0].color = ( 1, 1, 0 );
}

menu_fx_option_set()
{
    if ( getdvar( "fx" ) == "nil" )
        return;

    var_0 = get_selected_option();
    var_1 = undefined;

    if ( var_0["type"] == "string" )
        var_1 = getdvar( "fx" );

    if ( var_0["type"] == "int" )
        var_1 = getdvarint( "fx" );

    if ( var_0["type"] == "float" )
        var_1 = getdvarfloat( "fx" );

    apply_option_to_selected_fx( var_0, var_1 );
}

apply_option_to_selected_fx( var_0, var_1 )
{
    for ( var_2 = 0; var_2 < level.selected_fx_ents.size; var_2++ )
    {
        var_3 = level.selected_fx_ents[var_2];

        if ( mask( var_0["mask"], var_3.v["type"] ) )
            var_3.v[var_0["name"]] = var_1;
    }

    level.last_displayed_ent = undefined;
    common_scripts\_createfx::update_selected_entities();
    common_scripts\_createfx::clear_settable_fx();
}

set_option_index( var_0 )
{
    for ( var_1 = 0; var_1 < level.createFX_options.size; var_1++ )
    {
        if ( level.createFX_options[var_1]["name"] != var_0 )
            continue;

        level.selected_fx_option_index = var_1;
        return;
    }
}

get_selected_option()
{
    return level.createFX_options[level.selected_fx_option_index];
}

mask( var_0, var_1 )
{
    return isdefined( level.createfxMasks[var_0][var_1] );
}

addOption( var_0, var_1, var_2, var_3, var_4 )
{
    var_5 = [];
    var_5["type"] = var_0;
    var_5["name"] = var_1;
    var_5["description"] = var_2;
    var_5["default"] = var_3;
    var_5["mask"] = var_4;
    level.createFX_options[level.createFX_options.size] = var_5;
}

get_option( var_0 )
{
    for ( var_1 = 0; var_1 < level.createFX_options.size; var_1++ )
    {
        if ( level.createFX_options[var_1]["name"] == var_0 )
            return level.createFX_options[var_1];
    }
}

display_fx_info( var_0 )
{
    if ( !menu( "none" ) )
        return;

    common_scripts\_createfx::clear_fx_hudElements();
    common_scripts\_createfx::set_fx_hudElement( "Name: " + var_0.v["fxid"] );
    common_scripts\_createfx::set_fx_hudElement( "Type: " + var_0.v["type"] );
    common_scripts\_createfx::set_fx_hudElement( "Origin: " + var_0.v["origin"] );
    common_scripts\_createfx::set_fx_hudElement( "Angles: " + var_0.v["angles"] );

    if ( entities_are_selected() )
    {
        var_1 = 0;
        var_2 = 0;
        var_3 = 0;

        for ( var_4 = 0; var_4 < level.createFX_options.size; var_4++ )
        {
            var_5 = level.createFX_options[var_4];

            if ( !isdefined( var_0.v[var_5["name"]] ) )
                continue;

            var_1++;

            if ( var_1 < level.effect_list_offset )
                continue;

            var_2++;
            common_scripts\_createfx::set_fx_hudElement( var_2 + ". " + var_5["description"] + ": " + var_0.v[var_5["name"]] );

            if ( var_2 > level.effect_list_offset_max )
            {
                var_3 = 1;
                break;
            }
        }

        if ( var_1 > level.effect_list_offset_max )
            common_scripts\_createfx::set_fx_hudElement( "(m) More >" );

        common_scripts\_createfx::set_fx_hudElement( "(a) Add >" );
        common_scripts\_createfx::set_fx_hudElement( "(x) Exit >" );
    }
    else
    {
        var_1 = 0;
        var_3 = 0;

        for ( var_4 = 0; var_4 < level.createFX_options.size; var_4++ )
        {
            var_5 = level.createFX_options[var_4];

            if ( !isdefined( var_0.v[var_5["name"]] ) )
                continue;

            var_1++;
            common_scripts\_createfx::set_fx_hudElement( var_5["description"] + ": " + var_0.v[var_5["name"]] );

            if ( var_1 > level.createFx_hudElements )
                break;
        }
    }
}

display_fx_add_options( var_0 )
{
    common_scripts\_createfx::clear_fx_hudElements();
    common_scripts\_createfx::set_fx_hudElement( "Name: " + var_0.v["fxid"] );
    common_scripts\_createfx::set_fx_hudElement( "Type: " + var_0.v["type"] );
    common_scripts\_createfx::set_fx_hudElement( "Origin: " + var_0.v["origin"] );
    common_scripts\_createfx::set_fx_hudElement( "Angles: " + var_0.v["angles"] );
    var_1 = 0;
    var_2 = 0;
    var_3 = 0;

    if ( level.effect_list_offset >= level.createFX_options.size )
        level.effect_list_offset = 0;

    for ( var_4 = 0; var_4 < level.createFX_options.size; var_4++ )
    {
        var_5 = level.createFX_options[var_4];

        if ( isdefined( var_0.v[var_5["name"]] ) )
            continue;

        if ( !mask( var_5["mask"], var_0.v["type"] ) )
            continue;

        var_1++;

        if ( var_1 < level.effect_list_offset )
            continue;

        if ( var_2 >= level.effect_list_offset_max )
            continue;

        var_2++;
        var_6 = var_2;

        if ( var_6 == 10 )
            var_6 = 0;

        if ( common_scripts\_createfx::button_is_clicked( var_6 + "" ) )
        {
            add_option_to_selected_entities( var_5 );
            menuNone();
            level.last_displayed_ent = undefined;
            return;
        }

        common_scripts\_createfx::set_fx_hudElement( var_6 + ". " + var_5["description"] );
    }

    if ( var_1 > level.effect_list_offset_max )
        common_scripts\_createfx::set_fx_hudElement( "(m) More >" );

    common_scripts\_createfx::set_fx_hudElement( "(x) Exit >" );
}

add_option_to_selected_entities( var_0 )
{
    var_1 = undefined;

    for ( var_2 = 0; var_2 < level.selected_fx_ents.size; var_2++ )
    {
        var_3 = level.selected_fx_ents[var_2];

        if ( mask( var_0["mask"], var_3.v["type"] ) )
            var_3.v[var_0["name"]] = var_0["default"];
    }
}

menuNone()
{
    level.effect_list_offset = 0;
    common_scripts\_createfx::clear_fx_hudElements();
    setmenu( "none" );
}

draw_effects_list()
{
    common_scripts\_createfx::clear_fx_hudElements();
    common_scripts\_createfx::set_fx_hudElement( "Pick an effect:" );
    var_0 = 0;
    var_1 = 0;
    var_2 = common_scripts\_createfx::func_get_level_fx();

    if ( level.effect_list_offset >= var_2.size )
        level.effect_list_offset = 0;

    for ( var_3 = level.effect_list_offset; var_3 < var_2.size; var_3++ )
    {
        var_0 += 1;
        common_scripts\_createfx::set_fx_hudElement( var_0 + ". " + var_2[var_3] );

        if ( var_0 >= level.effect_list_offset_max )
        {
            var_1 = 1;
            break;
        }
    }

    if ( var_2.size > level.effect_list_offset_max )
        common_scripts\_createfx::set_fx_hudElement( "(m) More >" );
}

increment_list_offset()
{
    level.effect_list_offset = level.effect_list_offset + level.effect_list_offset_max;
}
