// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.ospreySettings = [];
    level.ospreySettings["escort_airdrop"] = spawnstruct();
    level.ospreySettings["escort_airdrop"].vehicle = "osprey_mp";
    level.ospreySettings["escort_airdrop"].modelBase = "vehicle_v22_osprey_body_mp";
    level.ospreySettings["escort_airdrop"].modelBlades = "vehicle_v22_osprey_blades_mp";
    level.ospreySettings["escort_airdrop"].tagHatchL = "tag_le_door_attach";
    level.ospreySettings["escort_airdrop"].tagHatchR = "tag_ri_door_attach";
    level.ospreySettings["escort_airdrop"].tagDropCrates = "tag_turret_attach";
    level.ospreySettings["escort_airdrop"].prompt = &"MP_DEFEND_AIRDROP_PACKAGES";
    level.ospreySettings["escort_airdrop"].name = &"KILLSTREAKS_ESCORT_AIRDROP";
    level.ospreySettings["escort_airdrop"].weaponinfo = "osprey_minigun_mp";
    level.ospreySettings["escort_airdrop"].heliType = "osprey";
    level.ospreySettings["escort_airdrop"].dropType = "airdrop_escort";
    level.ospreySettings["escort_airdrop"].maxHealth = level.heli_maxhealth * 2;
    level.ospreySettings["escort_airdrop"].timeOut = 60.0;
    level.ospreySettings["osprey_gunner"] = spawnstruct();
    level.ospreySettings["osprey_gunner"].vehicle = "osprey_player_mp";
    level.ospreySettings["osprey_gunner"].modelBase = "vehicle_v22_osprey_body_mp";
    level.ospreySettings["osprey_gunner"].modelBlades = "vehicle_v22_osprey_blades_mp";
    level.ospreySettings["osprey_gunner"].tagHatchL = "tag_le_door_attach";
    level.ospreySettings["osprey_gunner"].tagHatchR = "tag_ri_door_attach";
    level.ospreySettings["osprey_gunner"].tagDropCrates = "tag_turret_attach";
    level.ospreySettings["osprey_gunner"].prompt = &"MP_DEFEND_AIRDROP_PACKAGES";
    level.ospreySettings["osprey_gunner"].name = &"KILLSTREAKS_OSPREY_GUNNER";
    level.ospreySettings["osprey_gunner"].weaponinfo = "osprey_player_minigun_mp";
    level.ospreySettings["osprey_gunner"].heliType = "osprey_gunner";
    level.ospreySettings["osprey_gunner"].dropType = "airdrop_osprey_gunner";
    level.ospreySettings["osprey_gunner"].maxHealth = level.heli_maxhealth * 2;
    level.ospreySettings["osprey_gunner"].timeOut = 75.0;

    foreach ( var_1 in level.ospreySettings )
    {
        precachevehicle( var_1.vehicle );
        precacheitem( var_1.weaponinfo );
        precachemodel( var_1.modelBase );
        precachemodel( var_1.modelBlades );
        precachestring( var_1.prompt );
        precachestring( var_1.name );
        level.chopper_fx["explode"]["death"][var_1.modelBase] = loadfx( "explosions/helicopter_explosion_osprey" );
        level.chopper_fx["explode"]["air_death"][var_1.modelBase] = loadfx( "explosions/helicopter_explosion_osprey_air_mp" );
        level.chopper_fx["anim"]["blades_anim_up"][var_1.modelBase] = loadfx( "props/osprey_blades_anim_up" );
        level.chopper_fx["anim"]["blades_anim_down"][var_1.modelBase] = loadfx( "props/osprey_blades_anim_down" );
        level.chopper_fx["anim"]["blades_static_up"][var_1.modelBase] = loadfx( "props/osprey_blades_up" );
        level.chopper_fx["anim"]["blades_static_down"][var_1.modelBase] = loadfx( "props/osprey_blades_default" );
        level.chopper_fx["anim"]["hatch_left_static_up"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_left_default" );
        level.chopper_fx["anim"]["hatch_left_anim_down"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_left_anim_open" );
        level.chopper_fx["anim"]["hatch_left_static_down"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_left_up" );
        level.chopper_fx["anim"]["hatch_left_anim_up"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_left_anim_close" );
        level.chopper_fx["anim"]["hatch_right_static_up"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_right_default" );
        level.chopper_fx["anim"]["hatch_right_anim_down"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_right_anim_open" );
        level.chopper_fx["anim"]["hatch_right_static_down"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_right_up" );
        level.chopper_fx["anim"]["hatch_right_anim_up"][var_1.modelBase] = loadfx( "props/osprey_bottom_door_right_anim_close" );
    }

    level.air_support_locs = [];
    level.killstreakFuncs["escort_airdrop"] = ::tryUseEscortAirdrop;
    level.killstreakFuncs["osprey_gunner"] = ::tryUseOspreyGunner;
}

tryUseEscortAirdrop( var_0, var_1 )
{
    var_2 = 1;

    if ( isdefined( self.laststand ) && !maps\mp\_utility::_hasPerk( "specialty_finalstand" ) )
    {
        self iprintlnbold( &"MP_UNAVILABLE_IN_LASTSTAND" );
        return 0;
    }
    else if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }
    else if ( isdefined( level.chopper ) )
    {
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        return 0;
    }
    else if ( maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount + var_2 >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        return 0;
    }
    else if ( maps\mp\_utility::isUsingRemote() )
        return 0;

    if ( maps\mp\_utility::isAirDenied() )
        return 0;

    if ( maps\mp\_utility::isEMPed() )
        return 0;

    maps\mp\_utility::incrementFauxVehicleCount();
    var_4 = maps\mp\killstreaks\_airdrop::beginAirdropViaMarker( var_0, var_1, "escort_airdrop" );

    if ( !isdefined( var_4 ) || !var_4 )
    {
        self notify( "markerDetermined" );
        maps\mp\_utility::decrementFauxVehicleCount();
        return 0;
    }

    maps\mp\_matchdata::logKillstreakEvent( "escort_airdrop", self.origin );
    return 1;
}

tryUseOspreyGunner( var_0, var_1 )
{
    var_2 = 1;

    if ( isdefined( self.laststand ) && !maps\mp\_utility::_hasPerk( "specialty_finalstand" ) )
    {
        self iprintlnbold( &"MP_UNAVILABLE_IN_LASTSTAND" );
        return 0;
    }
    else if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }
    else if ( isdefined( level.chopper ) )
    {
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        return 0;
    }
    else if ( maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount + var_2 >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        return 0;
    }
    else if ( maps\mp\_utility::isUsingRemote() )
        return 0;

    if ( maps\mp\_utility::isAirDenied() )
        return 0;

    if ( maps\mp\_utility::isEMPed() )
        return 0;

    maps\mp\_utility::incrementFauxVehicleCount();
    var_4 = selectDropLocation( var_0, "osprey_gunner", "compass_objpoint_osprey_friendly", "compass_objpoint_osprey_enemy", &"MP_SELECT_MOBILE_MORTAR_LOCATION" );

    if ( !isdefined( var_4 ) || !var_4 )
    {
        maps\mp\_utility::decrementFauxVehicleCount();
        return 0;
    }

    maps\mp\_matchdata::logKillstreakEvent( "osprey_gunner", self.origin );
    return 1;
}

finishSupportEscortUsage( var_0, var_1, var_2, var_3 )
{
    self notify( "used" );
    var_4 = ( 0, var_2, 0 );
    var_5 = 12000;
    var_6 = getent( "airstrikeheight", "targetname" );
    var_7 = var_6.origin[2];
    var_8 = level.heli_start_nodes[randomint( level.heli_start_nodes.size )];
    var_9 = var_8.origin;
    var_10 = ( var_1[0], var_1[1], var_7 );
    var_11 = var_1 + anglestoforward( var_4 ) * var_5;
    var_12 = vectortoangles( var_10 - var_9 );
    var_13 = var_1;
    var_1 = ( var_1[0], var_1[1], var_7 );
    var_14 = createAirship( self, var_0, var_9, var_12, var_1, var_3 );
    var_9 = var_8;
    useSupportEscortAirdrop( var_0, var_14, var_9, var_10, var_11, var_7, var_13 );
}

finishOspreyGunnerUsage( var_0, var_1, var_2, var_3 )
{
    self notify( "used" );
    var_4 = ( 0, var_2, 0 );
    var_5 = 12000;
    var_6 = getent( "airstrikeheight", "targetname" );
    var_7 = var_6.origin[2];
    var_8 = level.heli_start_nodes[randomint( level.heli_start_nodes.size )];
    var_9 = var_8.origin;
    var_10 = ( var_1[0], var_1[1], var_7 );
    var_11 = var_1 + anglestoforward( var_4 ) * var_5;
    var_12 = vectortoangles( var_10 - var_9 );
    var_1 = ( var_1[0], var_1[1], var_7 );
    var_13 = createAirship( self, var_0, var_9, var_12, var_1, var_3 );
    var_9 = var_8;
    useOspreyGunner( var_0, var_13, var_9, var_10, var_11, var_7 );
}

stopSelectionWatcher()
{
    self waittill( "stop_location_selection",  var_0  );

    switch ( var_0 )
    {
        case "disconnect":
        case "death":
        case "cancel_location":
        case "weapon_change":
        case "emp":
            self notify( "customCancelLocation" );
            break;
    }
}

selectDropLocation( var_0, var_1, var_2, var_3, var_4 )
{
    self endon( "customCancelLocation" );
    var_5 = undefined;
    var_6 = level.mapSize / 6.46875;

    if ( level.splitscreen )
        var_6 *= 1.5;

    maps\mp\_utility::_beginLocationSelection( var_1, "map_artillery_selector", 0, 500 );
    thread stopSelectionWatcher();
    self waittill( "confirm_location",  var_7, var_8  );
    maps\mp\_utility::stopLocationSelection( 0 );
    maps\mp\_utility::setUsingRemote( var_1 );
    var_9 = maps\mp\killstreaks\_killstreaks::initRideKillstreak( var_1 );

    if ( var_9 != "success" )
    {
        if ( var_9 != "disconnect" )
            maps\mp\_utility::clearUsingRemote();

        return 0;
    }

    if ( isdefined( level.chopper ) )
    {
        maps\mp\_utility::clearUsingRemote();
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        return 0;
    }
    else if ( maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        maps\mp\_utility::clearUsingRemote();
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        return 0;
    }

    thread finishOspreyGunnerUsage( var_0, var_7, var_8, var_1 );
    return 1;
}

showIcons( var_0, var_1, var_2, var_3 )
{
    var_4 = maps\mp\gametypes\_hud_util::createFontString( "bigfixed", 0.5 );
    var_4 maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, -150 );
    var_4 settext( var_2 );
    self.locationObjectives = [];

    for ( var_5 = 0; var_5 < var_3; var_5++ )
    {
        self.locationObjectives[var_5] = maps\mp\gametypes\_gameobjects::getNextObjID();
        objective_add( self.locationObjectives[var_5], "invisible", ( 0, 0, 0 ) );
        objective_position( self.locationObjectives[var_5], level.air_support_locs[level.script][var_5]["origin"] );
        objective_state( self.locationObjectives[var_5], "active" );
        objective_player( self.locationObjectives[var_5], self getentitynumber() );

        if ( level.air_support_locs[level.script][var_5]["in_use"] == 1 )
        {
            objective_icon( self.locationObjectives[var_5], var_1 );
            continue;
        }

        objective_icon( self.locationObjectives[var_5], var_0 );
    }

    common_scripts\utility::waittill_any( "cancel_location", "picked_location", "stop_location_selection" );
    var_4 maps\mp\gametypes\_hud_util::destroyElem();

    for ( var_5 = 0; var_5 < var_3; var_5++ )
        maps\mp\_utility::_objective_delete( self.locationObjectives[var_5] );
}

createAirship( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    var_6 = spawnhelicopter( var_0, var_2, var_3, level.ospreySettings[var_5].vehicle, level.ospreySettings[var_5].modelBase );

    if ( !isdefined( var_6 ) )
        return undefined;

    var_6.ospreyType = var_5;
    var_6.heli_type = level.ospreySettings[var_5].modelBase;
    var_6.heliType = level.ospreySettings[var_5].heliType;
    var_6.attractor = missile_createattractorent( var_6, level.heli_attract_strength , level.heli_attract_range );
    var_6.lifeId = var_1;
    var_6.team = var_0.pers["team"];
    var_6.pers["team"] = var_0.pers["team"];
    var_6.owner = var_0;
    var_6.maxHealth = level.ospreySettings[var_5].maxHealth;
    var_6.zOffset = ( 0, 0, 0 );
    var_6.targeting_delay = level.heli_targeting_delay;
    var_6.primaryTarget = undefined;
    var_6.secondaryTarget = undefined;
    var_6.attacker = undefined;
    var_6.currentstate = "ok";
    var_6.dropType = level.ospreySettings[var_5].dropType;
    level.chopper = var_6;
    var_6 maps\mp\killstreaks\_helicopter::addToHeliList();
    var_6 thread maps\mp\killstreaks\_helicopter::heli_flares_monitor();
    var_6 thread maps\mp\killstreaks\_helicopter::heli_leave_on_disconnect( var_0 );
    var_6 thread maps\mp\killstreaks\_helicopter::heli_leave_on_changeTeams( var_0 );
    var_6 thread maps\mp\killstreaks\_helicopter::heli_leave_on_gameended( var_0 );
    var_7 = level.ospreySettings[var_5].timeOut;
    var_6 thread maps\mp\killstreaks\_helicopter::heli_leave_on_timeout( var_7 );
    var_6 thread maps\mp\killstreaks\_helicopter::heli_damage_monitor();
    var_6 thread maps\mp\killstreaks\_helicopter::heli_health();
    var_6 thread maps\mp\killstreaks\_helicopter::heli_existance();
    var_6 thread airshipFX();
    var_6 thread airshipfxonconnect();

    if ( var_5 == "escort_airdrop" )
    {
        var_8 = var_6.origin + ( anglestoforward( var_6.angles ) * -200 + anglestoright( var_6.angles ) * -200 ) + ( 0, 0, 200 );
        var_6.killCamEnt = spawn( "script_model", var_8 );
        var_6.killCamEnt setscriptmoverkillcam( "explosive" );
        var_6.killCamEnt linkto( var_6, "tag_origin" );
    }

    return var_6;
}

airshipFX()
{
    self endon( "death" );
    wait 0.05;
    playfxontag( level.chopper_fx["light"]["tail"], self, "tag_light_tail" );
    wait 0.05;
    playfxontag( level.chopper_fx["light"]["belly"], self, "tag_light_belly" );
    wait 0.05;
    playfxontag( level.chopper_fx["anim"]["blades_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH" );
    wait 0.05;
    playfxontag( level.chopper_fx["anim"]["hatch_left_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL );
    wait 0.05;
    playfxontag( level.chopper_fx["anim"]["hatch_right_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR );
}

airshipfxonconnect()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "connected",  var_0  );
        thread airshipfxonclient( var_0 );
    }
}

airshipfxonclient( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    wait 0.05;
    playfxontagforclients( level.chopper_fx["light"]["tail"], self, "tag_light_tail", var_0 );
    wait 0.05;
    playfxontagforclients( level.chopper_fx["light"]["belly"], self, "tag_light_belly", var_0 );

    if ( isdefined( self.propsstate ) )
    {
        if ( self.propsstate == "up" )
        {
            wait 0.05;
            playfxontagforclients( level.chopper_fx["anim"]["blades_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH", var_0 );
        }
        else
        {
            wait 0.05;
            playfxontagforclients( level.chopper_fx["anim"]["blades_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH", var_0 );
        }
    }
    else
    {
        wait 0.05;
        playfxontagforclients( level.chopper_fx["anim"]["blades_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH", var_0 );
    }

    if ( isdefined( self.hatchstate ) )
    {
        if ( self.hatchstate == "down" )
        {
            wait 0.05;
            playfxontagforclients( level.chopper_fx["anim"]["hatch_left_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL, var_0 );
            wait 0.05;
            playfxontagforclients( level.chopper_fx["anim"]["hatch_right_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR, var_0 );
        }
        else
        {
            wait 0.05;
            playfxontagforclients( level.chopper_fx["anim"]["hatch_left_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL, var_0 );
            wait 0.05;
            playfxontagforclients( level.chopper_fx["anim"]["hatch_right_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR, var_0 );
        }
    }
    else
    {
        wait 0.05;
        playfxontagforclients( level.chopper_fx["anim"]["hatch_left_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL, var_0 );
        wait 0.05;
        playfxontagforclients( level.chopper_fx["anim"]["hatch_right_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR, var_0 );
    }
}

useSupportEscortAirdrop( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    var_1 thread airshipFlyDefense( self, var_2, var_3, var_4, var_5, var_6 );
}

useOspreyGunner( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    thread rideGunner( var_0, var_1 );
    var_1 thread airshipFlyGunner( self, var_2, var_3, var_4, var_5 );
}

rideGunner( var_0, var_1 )
{
    self endon( "disconnect" );
    var_1 endon( "helicopter_done" );
    thread maps\mp\_utility::teamPlayerCardSplash( "used_osprey_gunner", self );
    maps\mp\_utility::_giveWeapon( "heli_remote_mp" );
    self switchtoweapon( "heli_remote_mp" );

    if ( getdvarint( "camera_thirdPerson" ) )
        maps\mp\_utility::setThirdPersonDOF( 0 );

    var_1 vehicleturretcontrolon( self );
    self playerlinkweaponviewtodelta( var_1, "tag_player", 1.0, 0, 0, 0, 0, 1 );
    self setplayerangles( var_1 gettagangles( "tag_player" ) );
    var_1 thread maps\mp\killstreaks\_helicopter::heli_targeting();
    thread maps\mp\killstreaks\_helicopter::weaponLockThink( var_1 );
    var_1.gunner = self;
    self.heliRideLifeId = var_0;
    thread endRideOnAirshipDone( var_1 );
    thread waitSetThermal( 1.0, var_1 );
    thread maps\mp\_utility::reinitializethermal( var_1 );

    for (;;)
    {
        var_1 waittill( "turret_fire" );
        var_1 fireweapon();
        earthquake( 0.2, 1, var_1.origin, 1000 );
    }
}

waitSetThermal( var_0, var_1 )
{
    self endon( "disconnect" );
    var_1 endon( "death" );
    var_1 endon( "helicopter_done" );
    var_1 endon( "crashing" );
    var_1 endon( "leaving" );
    wait(var_0);
    self visionsetthermalforplayer( level.ac130.enhanced_vision, 0 );
    self.lastvisionsetthermal = level.ac130.enhanced_vision;
    self thermalvisionon();
    self thermalvisionfofoverlayon();
    thread maps\mp\killstreaks\_helicopter::thermalVision( var_1 );
}

showDefendPrompt( var_0 )
{
    self endon( "disconnect" );
    var_0 endon( "helicopter_done" );
    self.escort_prompt = maps\mp\gametypes\_hud_util::createFontString( "bigfixed", 1.5 );
    self.escort_prompt maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, -150 );
    self.escort_prompt settext( level.ospreySettings[var_0.ospreyType].prompt );
    wait 6;

    if ( isdefined( self.escort_prompt ) )
        self.escort_prompt maps\mp\gametypes\_hud_util::destroyElem();
}

airShipPitchPropsUp()
{
    self endon( "crashing" );
    self endon( "death" );
    stopfxontag( level.chopper_fx["anim"]["blades_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH" );
    playfxontag( level.chopper_fx["anim"]["blades_anim_up"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH" );
    wait 1.0;

    if ( isdefined( self ) )
    {
        playfxontag( level.chopper_fx["anim"]["blades_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH" );
        self.propsstate = "up";
    }
}

airShipPitchPropsDown()
{
    self endon( "crashing" );
    self endon( "death" );
    stopfxontag( level.chopper_fx["anim"]["blades_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH" );
    playfxontag( level.chopper_fx["anim"]["blades_anim_down"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH" );
    wait 1.0;

    if ( isdefined( self ) )
    {
        playfxontag( level.chopper_fx["anim"]["blades_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, "TAG_BLADES_ATTACH" );
        self.propsstate = "down";
    }
}

airShipPitchHatchUp()
{
    self endon( "crashing" );
    self endon( "death" );
    stopfxontag( level.chopper_fx["anim"]["hatch_left_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL );
    playfxontag( level.chopper_fx["anim"]["hatch_left_anim_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL );
    stopfxontag( level.chopper_fx["anim"]["hatch_right_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR );
    playfxontag( level.chopper_fx["anim"]["hatch_right_anim_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR );
    wait 1.0;

    if ( isdefined( self ) )
    {
        playfxontag( level.chopper_fx["anim"]["hatch_left_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL );
        playfxontag( level.chopper_fx["anim"]["hatch_right_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR );
        self.hatchstate = "up";
    }
}

airShipPitchHatchDown()
{
    self endon( "crashing" );
    self endon( "death" );
    stopfxontag( level.chopper_fx["anim"]["hatch_left_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL );
    playfxontag( level.chopper_fx["anim"]["hatch_left_anim_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL );
    stopfxontag( level.chopper_fx["anim"]["hatch_right_static_up"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR );
    playfxontag( level.chopper_fx["anim"]["hatch_right_anim_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR );
    wait 1.0;

    if ( isdefined( self ) )
    {
        playfxontag( level.chopper_fx["anim"]["hatch_left_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchL );
        playfxontag( level.chopper_fx["anim"]["hatch_right_static_down"][level.ospreySettings[self.ospreyType].modelBase], self, level.ospreySettings[self.ospreyType].tagHatchR );
        self.hatchstate = "down";
    }

    self notify( "hatch_down" );
}

getBestHeight( var_0 )
{
    self endon( "helicopter_removed" );
    self endon( "heightReturned" );
    var_1 = getent( "airstrikeheight", "targetname" );

    if ( isdefined( var_1 ) )
        var_2 = var_1.origin[2];
    else if ( isdefined( level.airstrikeHeightScale ) )
        var_2 = 850 * level.airstrikeHeightScale;
    else
        var_2 = 850;

    self.bestHeight = var_2;
    var_3 = 200;
    var_4 = 0;
    var_5 = 0;

    for ( var_6 = 0; var_6 < 125; var_6++ )
    {
        wait 0.05;
        var_7 = var_6 % 8;
        var_8 = var_6 * 3;

        switch ( var_7 )
        {
            case 0:
                var_4 = var_8;
                var_5 = var_8;
                break;
            case 1:
                var_4 = var_8 * -1;
                var_5 = var_8 * -1;
                break;
            case 2:
                var_4 = var_8 * -1;
                var_5 = var_8;
                break;
            case 3:
                var_4 = var_8;
                var_5 = var_8 * -1;
                break;
            case 4:
                var_4 = 0;
                var_5 = var_8 * -1;
                break;
            case 5:
                var_4 = var_8 * -1;
                var_5 = 0;
                break;
            case 6:
                var_4 = var_8;
                var_5 = 0;
                break;
            case 7:
                var_4 = 0;
                var_5 = var_8;
                break;
            default:
                break;
        }

        var_9 = bullettrace( var_0 + ( var_4, var_5, 1000 ), var_0 + ( var_4, var_5, -10000 ), 1, self );

        if ( var_9["position"][2] > var_3 )
            var_3 = var_9["position"][2];
    }

    self.bestHeight = var_3 + 300;

    switch ( getdvar( "mapname" ) )
    {
        case "mp_morningwood":
            self.bestHeight = self.bestHeight + 600;
            break;
        case "mp_overwatch":
            var_10 = level.spawnpoints;
            var_11 = var_10[0];
            var_12 = var_10[0];

            foreach ( var_14 in var_10 )
            {
                if ( var_14.origin[2] < var_11.origin[2] )
                    var_11 = var_14;

                if ( var_14.origin[2] > var_12.origin[2] )
                    var_12 = var_14;
            }

            if ( var_3 < var_11.origin[2] - 100 )
                self.bestHeight = var_12.origin[2] + 900;

            break;
    }
}

airshipFlyDefense( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    self notify( "airshipFlyDefense" );
    self endon( "airshipFlyDefense" );
    self endon( "helicopter_removed" );
    self endon( "death" );
    self endon( "leaving" );
    thread getBestHeight( var_2 );
    maps\mp\killstreaks\_helicopter::heli_fly_simple_path( var_1 );
    self.pathGoal = var_2;
    var_6 = self.angles;
    self setyawspeed( 30, 30, 30, 0.3 );
    var_7 = self.origin;
    var_8 = self.angles[1];
    var_9 = self.angles[0];
    self.timeOut = level.ospreySettings[self.ospreyType].timeOut;
    self setvehgoalpos( var_2, 1 );
    var_10 = gettime();
    self waittill( "goal" );
    var_11 = ( gettime() - var_10 ) * 0.001;
    self.timeOut = self.timeOut - var_11;
    thread airShipPitchPropsUp();
    var_12 = var_2 * ( 1, 1, 0 );
    var_12 += ( 0, 0, self.bestHeight );
    self vehicle_setspeed( 25, 10, 10 );
    self setyawspeed( 20, 10, 10, 0.3 );
    self setvehgoalpos( var_12, 1 );
    var_10 = gettime();
    self waittill( "goal" );
    var_11 = ( gettime() - var_10 ) * 0.001;
    self.timeOut = self.timeOut - var_11;
    self sethoverparams( 65, 50, 50 );
    ospreyDropCratesLowImpulse( 1, level.ospreySettings[self.ospreyType].tagDropCrates, var_12 );
    thread killGuysNearCrates( var_5 );
    self waittill( "leaving" );
    self notify( "osprey_leaving" );
    thread airShipPitchPropsDown();
}

wait_and_delete( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    wait(var_0);
    self delete();
}

killGuysNearCrates( var_0 )
{
    self endon( "osprey_leaving" );
    self endon( "helicopter_removed" );
    self endon( "death" );
    var_1 = var_0;

    for (;;)
    {
        foreach ( var_3 in level.players )
        {
            wait 0.05;

            if ( !isdefined( self ) )
                return;

            if ( !isdefined( var_3 ) )
                continue;

            if ( !maps\mp\_utility::isReallyAlive( var_3 ) )
                continue;

            if ( level.teamBased && var_3.team == self.team )
                continue;

            if ( isdefined( self.owner ) && var_3 == self.owner )
                continue;

            if ( var_3 maps\mp\_utility::_hasPerk( "specialty_blindeye" ) )
                continue;

            if ( distancesquared( var_1, var_3.origin ) > 500000 )
                continue;

            thread aiShootPlayer( var_3, var_1 );
            waitForConfirmation();
        }
    }
}

aiShootPlayer( var_0, var_1 )
{
    self notify( "aiShootPlayer" );
    self endon( "aiShootPlayer" );
    self endon( "helicopter_removed" );
    self endon( "leaving" );
    var_0 endon( "death" );
    self setturrettargetent( var_0 );
    self setlookatent( var_0 );
    thread targetDeathWaiter( var_0 );
    var_2 = 6;
    var_3 = 2;

    for (;;)
    {
        var_2--;
        self fireweapon( "tag_flash", var_0 );
        wait 0.15;

        if ( var_2 <= 0 )
        {
            var_3--;
            var_2 = 6;

            if ( distancesquared( var_0.origin, var_1 ) > 500000 || var_3 <= 0 || !maps\mp\_utility::isReallyAlive( var_0 ) )
            {
                self notify( "abandon_target" );
                return;
            }

            wait 1;
        }
    }
}

targetDeathWaiter( var_0 )
{
    self endon( "abandon_target" );
    self endon( "leaving" );
    self endon( "helicopter_removed" );
    var_0 waittill( "death" );
    self notify( "target_killed" );
}

waitForConfirmation()
{
    self endon( "helicopter_removed" );
    self endon( "leaving" );
    self endon( "target_killed" );
    self endon( "abandon_target" );

    for (;;)
        wait 0.05;
}

airshipFlyGunner( var_0, var_1, var_2, var_3, var_4 )
{
    self notify( "airshipFlyGunner" );
    self endon( "airshipFlyGunner" );
    self endon( "helicopter_removed" );
    self endon( "death" );
    self endon( "leaving" );
    thread getBestHeight( var_2 );
    maps\mp\killstreaks\_helicopter::heli_fly_simple_path( var_1 );
    thread maps\mp\killstreaks\_helicopter::heli_leave_on_timeout( level.ospreySettings[self.ospreyType].timeOut );
    var_5 = self.angles;
    self setyawspeed( 30, 30, 30, 0.3 );
    var_6 = self.origin;
    var_7 = self.angles[1];
    var_8 = self.angles[0];
    self.timeOut = level.ospreySettings[self.ospreyType].timeOut;
    self setvehgoalpos( var_2, 1 );
    var_9 = gettime();
    self waittill( "goal" );
    var_10 = ( gettime() - var_9 ) * 0.001;
    self.timeOut = self.timeOut - var_10;
    thread airShipPitchPropsUp();
    var_11 = var_2 * ( 1, 1, 0 );
    var_11 += ( 0, 0, self.bestHeight );
    self vehicle_setspeed( 25, 10, 10 );
    self setyawspeed( 20, 10, 10, 0.3 );
    self setvehgoalpos( var_11, 1 );
    var_9 = gettime();
    self waittill( "goal" );
    var_10 = ( gettime() - var_9 ) * 0.001;
    self.timeOut = self.timeOut - var_10;
    ospreyDropCrates( 1, level.ospreySettings[self.ospreyType].tagDropCrates, var_11 );
    var_12 = 1.0;

    if ( isdefined( var_0 ) )
        var_0 common_scripts\utility::waittill_any_timeout( var_12, "disconnect" );

    self.timeOut = self.timeOut - var_12;
    self setvehgoalpos( var_2, 1 );
    var_9 = gettime();
    self waittill( "goal" );
    var_10 = ( gettime() - var_9 ) * 0.001;
    self.timeOut = self.timeOut - var_10;
    var_13 = getentarray( "heli_attack_area", "targetname" );
    var_14 = level.heli_loop_nodes[randomint( level.heli_loop_nodes.size )];

    if ( var_13.size )
        thread maps\mp\killstreaks\_helicopter::heli_fly_well( var_13 );
    else
        thread maps\mp\killstreaks\_helicopter::heli_fly_loop_path( var_14 );

    self waittill( "leaving" );
    thread airShipPitchPropsDown();
}

ospreyDropCratesLowImpulse( var_0, var_1, var_2 )
{
    thread airShipPitchHatchDown();
    self waittill( "hatch_down" );
    var_3[0] = thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomint( 10 ), randomint( 10 ), randomint( 10 ) ), undefined, var_1 );
    wait 0.05;
    self notify( "drop_crate" );
    wait(var_0);
    var_3[1] = thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomint( 100 ), randomint( 100 ), randomint( 100 ) ), var_3, var_1 );
    wait 0.05;
    self notify( "drop_crate" );
    wait(var_0);
    var_3[2] = thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomint( 50 ), randomint( 50 ), randomint( 50 ) ), var_3, var_1 );
    wait 0.05;
    self notify( "drop_crate" );
    wait(var_0);
    var_3[3] = thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomintrange( -100, 0 ), randomintrange( -100, 0 ), randomintrange( -100, 0 ) ), var_3, var_1 );
    wait 0.05;
    self notify( "drop_crate" );
    wait(var_0);
    thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomintrange( -50, 0 ), randomintrange( -50, 0 ), randomintrange( -50, 0 ) ), var_3, var_1 );
    wait 0.05;
    self notify( "drop_crate" );
    wait 1.0;
    thread airShipPitchHatchUp();
}

ospreyDropCrates( var_0, var_1, var_2 )
{
    thread airShipPitchHatchDown();
    self waittill( "hatch_down" );
    var_3[0] = thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomint( 10 ), randomint( 10 ), randomint( 10 ) ), undefined, var_1 );
    wait 0.05;
    self.timeOut = self.timeOut - 0.05;
    self notify( "drop_crate" );
    wait(var_0);
    self.timeOut = self.timeOut - var_0;
    var_3[1] = thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomint( 100 ), randomint( 100 ), randomint( 100 ) ), var_3, var_1 );
    wait 0.05;
    self.timeOut = self.timeOut - 0.05;
    self notify( "drop_crate" );
    wait(var_0);
    self.timeOut = self.timeOut - var_0;
    var_3[2] = thread maps\mp\killstreaks\_airdrop::dropTheCrate( undefined, self.dropType, undefined, 0, undefined, self.origin, ( randomint( 50 ), randomint( 50 ), randomint( 50 ) ), var_3, var_1 );
    wait 0.05;
    self.timeOut = self.timeOut - 0.05;
    self notify( "drop_crate" );
    wait 1.0;
    thread airShipPitchHatchUp();
}

endRide( var_0 )
{
    if ( isdefined( self.escort_prompt ) )
        self.escort_prompt maps\mp\gametypes\_hud_util::destroyElem();

    self remotecamerasoundscapeoff();
    self thermalvisionoff();
    self thermalvisionfofoverlayoff();
    self unlink();
    maps\mp\_utility::clearUsingRemote();

    if ( getdvarint( "camera_thirdPerson" ) )
        maps\mp\_utility::setThirdPersonDOF( 1 );

    self visionsetthermalforplayer( game["thermal_vision"], 0 );

    if ( isdefined( var_0 ) )
        var_0 vehicleturretcontroloff( self );

    self notify( "heliPlayer_removed" );
    self switchtoweapon( common_scripts\utility::getLastWeapon() );
    self takeweapon( "heli_remote_mp" );
}

endRideOnAirshipDone( var_0 )
{
    self endon( "disconnect" );
    var_0 waittill( "helicopter_done" );
    endRide( var_0 );
}
