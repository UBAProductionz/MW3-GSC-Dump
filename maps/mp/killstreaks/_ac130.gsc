// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.ac130_use_duration = 40;
    level.ac130_num_flares = 2;
    makedvarserverinfo( "ui_ac130usetime", level.ac130_use_duration );
    precacheshader( "black" );
    precachestring( &"AC130_HUD_FLIR" );
    precachestring( &"AC130_HUD_OPTICS" );
    precachemenu( "ac130timer" );
    precachemodel( "vehicle_ac130_coop" );
    precacheitem( "ac130_25mm_mp" );
    precacheitem( "ac130_40mm_mp" );
    precacheitem( "ac130_105mm_mp" );
    precacheminimapicon( "compass_objpoint_ac130_friendly" );
    precacheminimapicon( "compass_objpoint_ac130_enemy" );
    precacheshellshock( "ac130" );
    angelFlarePrecache();
    level._effect["cloud"] = loadfx( "misc/ac130_cloud" );
    level._effect["beacon"] = loadfx( "misc/ir_beacon_coop" );
    level._effect["ac130_explode"] = loadfx( "explosions/aerial_explosion_ac130_coop" );
    level._effect["ac130_flare"] = loadfx( "misc/flares_cobra" );
    level._effect["ac130_light_red"] = loadfx( "misc/aircraft_light_wingtip_red" );
    level._effect["ac130_light_white_blink"] = loadfx( "misc/aircraft_light_white_blink" );
    level._effect["ac130_light_red_blink"] = loadfx( "misc/aircraft_light_red_blink" );
    level._effect["ac130_engineeffect"] = loadfx( "fire/jet_engine_ac130" );
    level._effect["coop_muzzleflash_105mm"] = loadfx( "muzzleflashes/ac130_105mm" );
    level._effect["coop_muzzleflash_40mm"] = loadfx( "muzzleflashes/ac130_40mm" );
    level.radioForcedTransmissionQueue = [];
    level.enemiesKilledInTimeWindow = 0;
    level.lastRadioTransmission = gettime();
    level.color["white"] = ( 1, 1, 1 );
    level.color["red"] = ( 1, 0, 0 );
    level.color["blue"] = ( 0.1, 0.3, 1 );
    level.cosine = [];
    level.cosine["45"] = cos( 45 );
    level.cosine["5"] = cos( 5 );
    level.HUDItem = [];
    level.physicsSphereRadius["ac130_25mm_mp"] = 60;
    level.physicsSphereRadius["ac130_40mm_mp"] = 600;
    level.physicsSphereRadius["ac130_105mm_mp"] = 1000;
    level.physicsSphereForce["ac130_25mm_mp"] = 0;
    level.physicsSphereForce["ac130_40mm_mp"] = 3.0;
    level.physicsSphereForce["ac130_105mm_mp"] = 6.0;
    level.weaponReloadTime["ac130_25mm_mp"] = 1.5;
    level.weaponReloadTime["ac130_40mm_mp"] = 3.0;
    level.weaponReloadTime["ac130_105mm_mp"] = 5.0;
    level.ac130_Speed["move"] = 250;
    level.ac130_Speed["rotate"] = 70;
    common_scripts\utility::flag_init( "allow_context_sensative_dialog" );
    common_scripts\utility::flag_set( "allow_context_sensative_dialog" );
    var_0 = getentarray( "minimap_corner", "targetname" );
    var_1 = ( 0, 0, 0 );

    if ( var_0.size )
        var_1 = maps\mp\gametypes\_spawnlogic::findBoxCenter( var_0[0].origin, var_0[1].origin );

    level.ac130 = spawn( "script_model", var_1 );
    level.ac130 setmodel( "c130_zoomrig" );
    level.ac130.angles = ( 0, 115, 0 );
    level.ac130.owner = undefined;
    level.ac130.thermal_vision = "ac130_thermal_mp";
    level.ac130.enhanced_vision = "ac130_enhanced_mp";
    level.ac130.targetname = "ac130rig_script_model";
    level.ac130 hide();
    level.ac130InUse = 0;
    init_sounds();
    thread rotatePlane( "on" );
    thread ac130_spawn();
    thread onPlayerConnect();
    thread handleIncomingStinger();
    thread handleIncomingSAM();
    level.killstreakFuncs["ac130"] = ::tryUseAC130;
    level.ac130Queue = [];
}

tryUseAC130( var_0 )
{
    if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }

    if ( isdefined( level.ac130player ) || level.ac130InUse )
    {
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        return 0;
    }

    if ( maps\mp\_utility::isUsingRemote() )
        return 0;

    if ( maps\mp\_utility::isAirDenied() )
        return 0;

    if ( maps\mp\_utility::isEMPed() )
        return 0;

    maps\mp\_utility::setUsingRemote( "ac130" );
    var_1 = maps\mp\killstreaks\_killstreaks::initRideKillstreak();

    if ( var_1 != "success" )
    {
        if ( var_1 != "disconnect" )
            maps\mp\_utility::clearUsingRemote();

        return 0;
    }

    var_1 = setAC130Player( self );

    if ( isdefined( var_1 ) && var_1 )
    {
        maps\mp\_matchdata::logKillstreakEvent( "ac130", self.origin );
        level.ac130.planemodel.crashed = undefined;
        level.ac130InUse = 1;
    }
    else
        maps\mp\_utility::clearUsingRemote();

    return isdefined( var_1 ) && var_1;
}

init_sounds()
{
    setac130ambience( "ambient_ac130_int1" );
    level.scr_sound["foo"]["bar"] = "";
    add_context_sensative_dialog( "ai", "in_sight", 0, "ac130_fco_moreenemy" );
    add_context_sensative_dialog( "ai", "in_sight", 1, "ac130_fco_getthatguy" );
    add_context_sensative_dialog( "ai", "in_sight", 2, "ac130_fco_guymovin" );
    add_context_sensative_dialog( "ai", "in_sight", 3, "ac130_fco_getperson" );
    add_context_sensative_dialog( "ai", "in_sight", 4, "ac130_fco_guyrunnin" );
    add_context_sensative_dialog( "ai", "in_sight", 5, "ac130_fco_gotarunner" );
    add_context_sensative_dialog( "ai", "in_sight", 6, "ac130_fco_backonthose" );
    add_context_sensative_dialog( "ai", "in_sight", 7, "ac130_fco_gonnagethim" );
    add_context_sensative_dialog( "ai", "in_sight", 8, "ac130_fco_personnelthere" );
    add_context_sensative_dialog( "ai", "in_sight", 9, "ac130_fco_nailthoseguys" );
    add_context_sensative_dialog( "ai", "in_sight", 11, "ac130_fco_lightemup" );
    add_context_sensative_dialog( "ai", "in_sight", 12, "ac130_fco_takehimout" );
    add_context_sensative_dialog( "ai", "in_sight", 14, "ac130_plt_yeahcleared" );
    add_context_sensative_dialog( "ai", "in_sight", 15, "ac130_plt_copysmoke" );
    add_context_sensative_dialog( "ai", "in_sight", 16, "ac130_fco_rightthere" );
    add_context_sensative_dialog( "ai", "in_sight", 17, "ac130_fco_tracking" );
    add_context_sensative_dialog( "ai", "wounded_crawl", 0, "ac130_fco_movingagain" );
    add_context_sensative_timeout( "ai", "wounded_crawl", undefined, 6 );
    add_context_sensative_dialog( "ai", "wounded_pain", 0, "ac130_fco_doveonground" );
    add_context_sensative_dialog( "ai", "wounded_pain", 1, "ac130_fco_knockedwind" );
    add_context_sensative_dialog( "ai", "wounded_pain", 2, "ac130_fco_downstillmoving" );
    add_context_sensative_dialog( "ai", "wounded_pain", 3, "ac130_fco_gettinbackup" );
    add_context_sensative_dialog( "ai", "wounded_pain", 4, "ac130_fco_yepstillmoving" );
    add_context_sensative_dialog( "ai", "wounded_pain", 5, "ac130_fco_stillmoving" );
    add_context_sensative_timeout( "ai", "wounded_pain", undefined, 12 );
    add_context_sensative_dialog( "weapons", "105mm_ready", 0, "ac130_gnr_gunready1" );
    add_context_sensative_dialog( "weapons", "105mm_fired", 0, "ac130_gnr_shot1" );
    add_context_sensative_dialog( "plane", "rolling_in", 0, "ac130_plt_rollinin" );
    add_context_sensative_dialog( "explosion", "secondary", 0, "ac130_nav_secondaries1" );
    add_context_sensative_dialog( "explosion", "secondary", 1, "ac130_tvo_directsecondary1" );
    add_context_sensative_dialog( "explosion", "secondary", 1, "ac130_tvo_directsecondary2" );
    add_context_sensative_timeout( "explosion", "secondary", undefined, 7 );
    add_context_sensative_dialog( "kill", "single", 0, "ac130_plt_gottahurt" );
    add_context_sensative_dialog( "kill", "single", 1, "ac130_fco_iseepieces" );
    add_context_sensative_dialog( "kill", "single", 2, "ac130_fco_oopsiedaisy" );
    add_context_sensative_dialog( "kill", "single", 3, "ac130_fco_goodkill" );
    add_context_sensative_dialog( "kill", "single", 4, "ac130_fco_yougothim" );
    add_context_sensative_dialog( "kill", "single", 5, "ac130_fco_yougothim2" );
    add_context_sensative_dialog( "kill", "single", 6, "ac130_fco_thatsahit" );
    add_context_sensative_dialog( "kill", "single", 7, "ac130_fco_directhit" );
    add_context_sensative_dialog( "kill", "single", 8, "ac130_fco_rightontarget" );
    add_context_sensative_dialog( "kill", "single", 9, "ac130_fco_okyougothim" );
    add_context_sensative_dialog( "kill", "single", 10, "ac130_fco_within2feet" );
    add_context_sensative_dialog( "kill", "small_group", 0, "ac130_fco_nice" );
    add_context_sensative_dialog( "kill", "small_group", 1, "ac130_fco_directhits" );
    add_context_sensative_dialog( "kill", "small_group", 2, "ac130_fco_iseepieces" );
    add_context_sensative_dialog( "kill", "small_group", 3, "ac130_fco_goodkill" );
    add_context_sensative_dialog( "kill", "small_group", 4, "ac130_fco_yougothim" );
    add_context_sensative_dialog( "kill", "small_group", 5, "ac130_fco_yougothim2" );
    add_context_sensative_dialog( "kill", "small_group", 6, "ac130_fco_thatsahit" );
    add_context_sensative_dialog( "kill", "small_group", 7, "ac130_fco_directhit" );
    add_context_sensative_dialog( "kill", "small_group", 8, "ac130_fco_rightontarget" );
    add_context_sensative_dialog( "kill", "small_group", 9, "ac130_fco_okyougothim" );
    add_context_sensative_dialog( "misc", "action", 0, "ac130_plt_scanrange" );
    add_context_sensative_timeout( "misc", "action", 0, 70 );
    add_context_sensative_dialog( "misc", "action", 1, "ac130_plt_cleanup" );
    add_context_sensative_timeout( "misc", "action", 1, 80 );
    add_context_sensative_dialog( "misc", "action", 2, "ac130_plt_targetreset" );
    add_context_sensative_timeout( "misc", "action", 2, 55 );
    add_context_sensative_dialog( "misc", "action", 3, "ac130_plt_azimuthsweep" );
    add_context_sensative_timeout( "misc", "action", 3, 100 );
}

add_context_sensative_dialog( var_0, var_1, var_2, var_3 )
{
    var_4 = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + var_3;
    var_4 = maps\mp\gametypes\_teams::getTeamVoicePrefix( "axis" ) + var_3;

    if ( !isdefined( level.scr_sound[var_0] ) || !isdefined( level.scr_sound[var_0][var_1] ) || !isdefined( level.scr_sound[var_0][var_1][var_2] ) )
    {
        level.scr_sound[var_0][var_1][var_2] = spawnstruct();
        level.scr_sound[var_0][var_1][var_2].played = 0;
        level.scr_sound[var_0][var_1][var_2].sounds = [];
    }

    var_5 = level.scr_sound[var_0][var_1][var_2].sounds.size;
    level.scr_sound[var_0][var_1][var_2].sounds[var_5] = var_3;
}

add_context_sensative_timeout( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( level.context_sensative_dialog_timeouts ) )
        level.context_sensative_dialog_timeouts = [];

    var_4 = 0;

    if ( !isdefined( level.context_sensative_dialog_timeouts[var_0] ) )
        var_4 = 1;
    else if ( !isdefined( level.context_sensative_dialog_timeouts[var_0][var_1] ) )
        var_4 = 1;

    if ( var_4 )
        level.context_sensative_dialog_timeouts[var_0][var_1] = spawnstruct();

    if ( isdefined( var_2 ) )
    {
        level.context_sensative_dialog_timeouts[var_0][var_1].groups = [];
        level.context_sensative_dialog_timeouts[var_0][var_1].groups[string( var_2 )] = spawnstruct();
        level.context_sensative_dialog_timeouts[var_0][var_1].groups[string( var_2 )].v["timeoutDuration"] = var_3 * 1000;
        level.context_sensative_dialog_timeouts[var_0][var_1].groups[string( var_2 )].v["lastPlayed"] = var_3 * -1000;
    }
    else
    {
        level.context_sensative_dialog_timeouts[var_0][var_1].v["timeoutDuration"] = var_3 * 1000;
        level.context_sensative_dialog_timeouts[var_0][var_1].v["lastPlayed"] = var_3 * -1000;
    }
}

play_sound_on_entity( var_0 )
{
    maps\mp\_utility::play_sound_on_tag( var_0 );
}

within_fov( var_0, var_1, var_2, var_3 )
{
    var_4 = vectornormalize( var_2 - var_0 );
    var_5 = anglestoforward( var_1 );
    var_6 = vectordot( var_5, var_4 );
    return var_6 >= var_3;
}

array_remove_nokeys( var_0, var_1 )
{
    var_2 = [];

    for ( var_3 = 0; var_3 < var_0.size; var_3++ )
    {
        if ( var_0[var_3] != var_1 )
            var_2[var_2.size] = var_0[var_3];
    }

    return var_2;
}

array_remove_index( var_0, var_1 )
{
    var_2 = [];
    var_3 = getarraykeys( var_0 );

    for ( var_4 = var_3.size - 1; var_4 >= 0; var_4-- )
    {
        if ( var_3[var_4] != var_1 )
            var_2[var_2.size] = var_0[var_3[var_4]];
    }

    return var_2;
}

string( var_0 )
{
    return "" + var_0;
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0 thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );

    for (;;)
        self waittill( "spawned_player" );
}

deleteOnAC130PlayerRemoved()
{
    level waittill( "ac130player_removed" );
    self delete();
}

setAC130Player( var_0 )
{
    self endon( "ac130player_removed" );

    if ( isdefined( level.ac130player ) )
        return 0;

    level.ac130player = var_0;
    level.ac130.owner = var_0;
    level.ac130.planemodel show();
    level.ac130.planemodel thread playAC130Effects();
    level.ac130.incomingMissile = 0;
    level.ac130.planemodel playloopsound( "veh_ac130_ext_dist" );
    level.ac130.planemodel thread damageTracker();
    var_1 = spawnplane( var_0, "script_model", level.ac130.planemodel.origin, "compass_objpoint_ac130_friendly", "compass_objpoint_ac130_enemy" );
    var_1 notsolid();
    var_1 linkto( level.ac130, "tag_player", ( 0, 80, 32 ), ( 0, -90, 0 ) );
    var_1 thread deleteOnAC130PlayerRemoved();
    var_0 startac130();
    var_0 openmenu( "ac130timer" );
    level.ac130.numFlares = level.ac130_num_flares;
    thread maps\mp\_utility::teamPlayerCardSplash( "used_ac130", var_0 );
    var_0 thread waitSetThermal( 1.0 );
    var_0 thread maps\mp\_utility::reinitializethermal( level.ac130.planemodel );

    if ( getdvarint( "camera_thirdPerson" ) )
        var_0 maps\mp\_utility::setThirdPersonDOF( 0 );

    var_0 maps\mp\_utility::_giveWeapon( "ac130_105mm_mp" );
    var_0 maps\mp\_utility::_giveWeapon( "ac130_40mm_mp" );
    var_0 maps\mp\_utility::_giveWeapon( "ac130_25mm_mp" );
    var_0 switchtoweapon( "ac130_105mm_mp" );
    var_0 setplayerdata( "ac130Ammo105mm", var_0 getweaponammoclip( "ac130_105mm_mp" ) );
    var_0 setplayerdata( "ac130Ammo40mm", var_0 getweaponammoclip( "ac130_40mm_mp" ) );
    var_0 setplayerdata( "ac130Ammo25mm", var_0 getweaponammoclip( "ac130_25mm_mp" ) );
    var_0 thread overlay( var_0 );
    var_0 thread attachPlayer( var_0 );
    var_0 thread changeWeapons();
    var_0 thread weaponFiredThread();
    var_0 thread context_Sensative_Dialog();
    var_0 thread shotFired();
    var_0 thread clouds();
    var_0 thread removeAC130PlayerAfterTime( level.ac130_use_duration * var_0.killStreakScaler );
    var_0 thread removeAC130PlayerOnDisconnect();
    var_0 thread removeAC130PlayerOnChangeTeams();
    var_0 thread removeAC130PlayerOnSpectate();
    var_0 thread removeAC130PlayerOnCrash();
    var_0 thread removeAC130PlayerOnGameCleanup();
    thread AC130_AltScene();
    return 1;
}

waitSetThermal( var_0 )
{
    self endon( "disconnect" );
    level endon( "ac130player_removed" );
    wait(var_0);
    self visionsetthermalforplayer( game["thermal_vision"], 0 );
    self thermalvisionfofoverlayon();
    thread thermalVision();
}

playAC130Effects()
{
    wait 0.05;
    playfxontag( level._effect["ac130_light_red_blink"], self, "tag_light_belly" );
    playfxontag( level._effect["ac130_engineeffect"], self, "tag_body" );
    wait 0.5;
    playfxontag( level._effect["ac130_light_white_blink"], self, "tag_light_tail" );
    playfxontag( level._effect["ac130_light_red"], self, "tag_light_top" );
}

AC130_AltScene()
{
    foreach ( var_1 in level.players )
    {
        if ( var_1 != level.ac130player && var_1.team == level.ac130player.team )
            var_1 thread maps\mp\_utility::setAltSceneObj( level.ac130.cameraModel, "tag_origin", 20 );
    }
}

removeAC130PlayerOnGameEnd()
{
    self endon( "ac130player_removed" );
    level waittill( "game_ended" );
    level thread removeAC130Player( self, 0 );
}

removeAC130PlayerOnGameCleanup()
{
    self endon( "ac130player_removed" );
    level waittill( "game_cleanup" );
    level thread removeAC130Player( self, 0 );
}

removeAC130PlayerOnDeath()
{
    self endon( "ac130player_removed" );
    self waittill( "death" );
    level thread removeAC130Player( self, 0 );
}

removeAC130PlayerOnCrash()
{
    self endon( "ac130player_removed" );
    level.ac130.planemodel waittill( "crashing" );
    level thread removeAC130Player( self, 0 );
}

removeAC130PlayerOnDisconnect()
{
    self endon( "ac130player_removed" );
    self waittill( "disconnect" );
    level thread removeAC130Player( self, 1 );
}

removeAC130PlayerOnChangeTeams()
{
    self endon( "ac130player_removed" );
    self waittill( "joined_team" );
    level thread removeAC130Player( self, 0 );
}

removeAC130PlayerOnSpectate()
{
    self endon( "ac130player_removed" );
    common_scripts\utility::waittill_any( "joined_spectators", "spawned" );
    level thread removeAC130Player( self, 0 );
}

removeAC130PlayerAfterTime( var_0 )
{
    self endon( "ac130player_removed" );
    var_1 = var_0;
    setdvar( "ui_ac130usetime", var_1 );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_1 );
    level thread removeAC130Player( self, 0 );
}

removeAC130Player( var_0, var_1 )
{
    var_0 notify( "ac130player_removed" );
    level notify( "ac130player_removed" );
    level.ac130.cameraModel notify( "death" );
    waittillframeend;

    if ( !var_1 )
    {
        var_0 maps\mp\_utility::clearUsingRemote();
        var_0 stoplocalsound( "missile_incoming" );
        var_0 show();
        var_0 unlink();
        var_0 thermalvisionoff();
        var_0 thermalvisionfofoverlayoff();
        var_0 visionsetthermalforplayer( level.ac130.thermal_vision, 0 );
        var_0.lastvisionsetthermal = level.ac130.thermal_vision;
        var_0 setblurforplayer( 0, 0 );
        var_0 stopac130();

        if ( getdvarint( "camera_thirdPerson" ) )
            var_0 maps\mp\_utility::setThirdPersonDOF( 1 );

        var_2 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( "ac130" );
        var_0 takeweapon( var_2 );
        var_0 takeweapon( "ac130_105mm_mp" );
        var_0 takeweapon( "ac130_40mm_mp" );
        var_0 takeweapon( "ac130_25mm_mp" );

        if ( isdefined( var_0.darkScreenOverlay ) )
            var_0.darkScreenOverlay destroy();

        var_3 = getarraykeys( level.HUDItem );

        foreach ( var_5 in var_3 )
        {
            level.HUDItem[var_5] destroy();
            level.HUDItem[var_5] = undefined;
        }
    }

    wait 0.5;
    level.ac130.planemodel playsound( "veh_ac130_ext_dist_fade" );
    wait 0.5;
    level.ac130player = undefined;
    level.ac130.planemodel hide();
    level.ac130.planemodel stoploopsound();

    if ( isdefined( level.ac130.planemodel.crashed ) )
    {
        level.ac130InUse = 0;
        return;
    }

    var_7 = spawn( "script_model", level.ac130.planemodel gettagorigin( "tag_origin" ) );
    var_7.angles = level.ac130.planemodel.angles;
    var_7 setmodel( "vehicle_ac130_coop" );
    var_8 = var_7.origin + anglestoright( var_7.angles ) * 20000;
    var_7 thread playAC130Effects();
    var_7 moveto( var_8, 40.0, 0.0, 0.0 );
    var_7 thread deployFlares( 1 );
    wait 5.0;
    var_7 thread deployFlares( 1 );
    wait 5.0;
    var_7 thread deployFlares( 1 );
    level.ac130InUse = 0;
    wait 30.0;
    var_7 delete();
}

damageTracker()
{
    self endon( "death" );
    self endon( "crashing" );
    level endon( "game_ended" );
    level endon( "ac130player_removed" );
    self.health = 999999;
    self.maxHealth = 1000;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( isdefined( level.ac130player ) && level.teamBased && isplayer( var_1 ) && var_1.team == level.ac130player.team && !isdefined( level.nukeDetonated ) )
            continue;

        if ( var_4 == "MOD_RIFLE_BULLET" || var_4 == "MOD_PISTOL_BULLET" || var_4 == "MOD_EXPLOSIVE_BULLET" )
            continue;

        self.wasDamaged = 1;
        var_10 = var_0;

        if ( isplayer( var_1 ) )
            var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "ac130" );

        maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_9, level.ac130 );

        if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
            var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "ac130" );

        self.damagetaken = self.damagetaken + var_10;

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isplayer( var_1 ) )
            {
                thread maps\mp\gametypes\_missions::vehicleKilled( level.ac130player, self, undefined, var_1, var_0, var_4, var_9 );
                thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_ac130", var_1 );
                var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 400, var_9, var_4 );
                var_1 notify( "destroyed_killstreak" );
            }

            level thread crashPlane( 10.0 );
        }
    }
}

ac130_spawn()
{
    wait 0.05;
    var_0 = spawn( "script_model", level.ac130 gettagorigin( "tag_player" ) );
    var_0 setmodel( "vehicle_ac130_coop" );
    var_0.targetname = "vehicle_ac130_coop";
    var_0 setcandamage( 1 );
    var_0.maxHealth = 1000;
    var_0.health = var_0.maxHealth;
    var_0 linkto( level.ac130, "tag_player", ( 0, 80, 32 ), ( -25, 0, 0 ) );
    level.ac130.planemodel = var_0;
    level.ac130.planemodel hide();
    var_1 = spawn( "script_model", level.ac130 gettagorigin( "tag_player" ) );
    var_1 setmodel( "tag_origin" );
    var_1 hide();
    var_1.targetname = "ac130CameraModel";
    var_1 linkto( level.ac130, "tag_player", ( 0, 0, 32 ), ( -25, 0, 0 ) );
    level.ac130.cameraModel = var_1;
    level.ac130player = level.players[0];
}

overlay( var_0 )
{
    level.HUDItem = [];
    level.HUDItem["thermal_vision"] = newclienthudelem( var_0 );
    level.HUDItem["thermal_vision"].x = 200;
    level.HUDItem["thermal_vision"].y = 0;
    level.HUDItem["thermal_vision"].alignx = "left";
    level.HUDItem["thermal_vision"].aligny = "top";
    level.HUDItem["thermal_vision"].horzalign = "left";
    level.HUDItem["thermal_vision"].vertalign = "top";
    level.HUDItem["thermal_vision"].fontScale = 2.5;
    level.HUDItem["thermal_vision"] settext( &"AC130_HUD_FLIR" );
    level.HUDItem["thermal_vision"].alpha = 1.0;
    level.HUDItem["enhanced_vision"] = newclienthudelem( var_0 );
    level.HUDItem["enhanced_vision"].x = -200;
    level.HUDItem["enhanced_vision"].y = 0;
    level.HUDItem["enhanced_vision"].alignx = "right";
    level.HUDItem["enhanced_vision"].aligny = "top";
    level.HUDItem["enhanced_vision"].horzalign = "right";
    level.HUDItem["enhanced_vision"].vertalign = "top";
    level.HUDItem["enhanced_vision"].fontScale = 2.5;
    level.HUDItem["enhanced_vision"] settext( &"AC130_HUD_OPTICS" );
    level.HUDItem["enhanced_vision"].alpha = 1.0;
    var_0 thread overlay_coords();
    var_0 setblurforplayer( 1.2, 0 );
}

overlay_coords()
{
    self endon( "ac130player_removed" );
    level.HUDItem["coord1_posx"] = newclienthudelem( self );
    level.HUDItem["coord1_posx"].x = 60;
    level.HUDItem["coord1_posx"].y = 100;
    level.HUDItem["coord1_posx"].alignx = "right";
    level.HUDItem["coord1_posx"].aligny = "middle";
    level.HUDItem["coord1_posx"].horzalign = "center";
    level.HUDItem["coord1_posx"].vertalign = "middle";
    level.HUDItem["coord1_posx"].fontScale = 1.0;
    level.HUDItem["coord1_posx"].alpha = 1.0;
    level.HUDItem["coord1_posy"] = newclienthudelem( self );
    level.HUDItem["coord1_posy"].x = 100;
    level.HUDItem["coord1_posy"].y = 100;
    level.HUDItem["coord1_posy"].alignx = "right";
    level.HUDItem["coord1_posy"].aligny = "middle";
    level.HUDItem["coord1_posy"].horzalign = "center";
    level.HUDItem["coord1_posy"].vertalign = "middle";
    level.HUDItem["coord1_posy"].fontScale = 1.0;
    level.HUDItem["coord1_posy"].alpha = 1.0;
    level.HUDItem["coord1_posz"] = newclienthudelem( self );
    level.HUDItem["coord1_posz"].x = 140;
    level.HUDItem["coord1_posz"].y = 100;
    level.HUDItem["coord1_posz"].alignx = "right";
    level.HUDItem["coord1_posz"].aligny = "middle";
    level.HUDItem["coord1_posz"].horzalign = "center";
    level.HUDItem["coord1_posz"].vertalign = "middle";
    level.HUDItem["coord1_posz"].fontScale = 1.0;
    level.HUDItem["coord1_posz"].alpha = 1.0;
    level.HUDItem["coord2_posx"] = newclienthudelem( self );
    level.HUDItem["coord2_posx"].x = 60;
    level.HUDItem["coord2_posx"].y = 110;
    level.HUDItem["coord2_posx"].alignx = "right";
    level.HUDItem["coord2_posx"].aligny = "middle";
    level.HUDItem["coord2_posx"].horzalign = "center";
    level.HUDItem["coord2_posx"].vertalign = "middle";
    level.HUDItem["coord2_posx"].fontScale = 1.0;
    level.HUDItem["coord2_posx"].alpha = 1.0;
    level.HUDItem["coord2_posy"] = newclienthudelem( self );
    level.HUDItem["coord2_posy"].x = 100;
    level.HUDItem["coord2_posy"].y = 110;
    level.HUDItem["coord2_posy"].alignx = "right";
    level.HUDItem["coord2_posy"].aligny = "middle";
    level.HUDItem["coord2_posy"].horzalign = "center";
    level.HUDItem["coord2_posy"].vertalign = "middle";
    level.HUDItem["coord2_posy"].fontScale = 1.0;
    level.HUDItem["coord2_posy"].alpha = 1.0;
    level.HUDItem["coord2_posz"] = newclienthudelem( self );
    level.HUDItem["coord2_posz"].x = 140;
    level.HUDItem["coord2_posz"].y = 110;
    level.HUDItem["coord2_posz"].alignx = "right";
    level.HUDItem["coord2_posz"].aligny = "middle";
    level.HUDItem["coord2_posz"].horzalign = "center";
    level.HUDItem["coord2_posz"].vertalign = "middle";
    level.HUDItem["coord2_posz"].fontScale = 1.0;
    level.HUDItem["coord2_posz"].alpha = 1.0;
    level.HUDItem["coord3_posx"] = newclienthudelem( self );
    level.HUDItem["coord3_posx"].x = -120;
    level.HUDItem["coord3_posx"].y = 100;
    level.HUDItem["coord3_posx"].alignx = "right";
    level.HUDItem["coord3_posx"].aligny = "middle";
    level.HUDItem["coord3_posx"].horzalign = "center";
    level.HUDItem["coord3_posx"].vertalign = "middle";
    level.HUDItem["coord3_posx"].fontScale = 1.0;
    level.HUDItem["coord3_posx"].alpha = 1.0;
    level.HUDItem["coord3_posy"] = newclienthudelem( self );
    level.HUDItem["coord3_posy"].x = -80;
    level.HUDItem["coord3_posy"].y = 100;
    level.HUDItem["coord3_posy"].alignx = "right";
    level.HUDItem["coord3_posy"].aligny = "middle";
    level.HUDItem["coord3_posy"].horzalign = "center";
    level.HUDItem["coord3_posy"].vertalign = "middle";
    level.HUDItem["coord3_posy"].fontScale = 1.0;
    level.HUDItem["coord3_posy"].alpha = 1.0;
    level.HUDItem["coord3_posz"] = newclienthudelem( self );
    level.HUDItem["coord3_posz"].x = -40;
    level.HUDItem["coord3_posz"].y = 100;
    level.HUDItem["coord3_posz"].alignx = "right";
    level.HUDItem["coord3_posz"].aligny = "middle";
    level.HUDItem["coord3_posz"].horzalign = "center";
    level.HUDItem["coord3_posz"].vertalign = "middle";
    level.HUDItem["coord3_posz"].fontScale = 1.0;
    level.HUDItem["coord3_posz"].alpha = 1.0;
    wait 0.05;
    thread updateAimingCoords();

    for (;;)
    {
        level.HUDItem["coord1_posx"] setvalue( abs( level.ac130.planemodel.origin[0] ) );
        level.HUDItem["coord1_posy"] setvalue( abs( level.ac130.planemodel.origin[1] ) );
        level.HUDItem["coord1_posz"] setvalue( abs( level.ac130.planemodel.origin[2] ) );
        level.HUDItem["coord2_posx"] setvalue( abs( self.origin[0] ) );
        level.HUDItem["coord2_posy"] setvalue( abs( self.origin[1] ) );
        level.HUDItem["coord2_posz"] setvalue( abs( self.origin[2] ) );
        wait 0.5;
    }
}

updateAimingCoords()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        var_0 = self geteye();
        var_1 = self getplayerangles();
        var_2 = anglestoforward( var_1 );
        var_3 = var_0 + var_2 * 15000;
        var_4 = physicstrace( var_0, var_3 );
        level.HUDItem["coord3_posx"] setvalue( abs( var_4[0] ) );
        level.HUDItem["coord3_posy"] setvalue( abs( var_4[1] ) );
        level.HUDItem["coord3_posz"] setvalue( abs( var_4[2] ) );
        wait 0.05;
    }
}

ac130ShellShock()
{
    self endon( "ac130player_removed" );
    level endon( "post_effects_disabled" );
    var_0 = 5;

    for (;;)
    {
        self shellshock( "ac130", var_0 );
        wait(var_0);
    }
}

rotatePlane( var_0 )
{
    level notify( "stop_rotatePlane_thread" );
    level endon( "stop_rotatePlane_thread" );

    if ( var_0 == "on" )
    {
        var_1 = 10;
        var_2 = level.ac130_Speed["rotate"] / 360 * var_1;
        level.ac130 rotateyaw( level.ac130.angles[2] + var_1, var_2, var_2, 0 );

        for (;;)
        {
            level.ac130 rotateyaw( 360, level.ac130_Speed["rotate"] );
            wait(level.ac130_Speed["rotate"]);
        }
    }
    else if ( var_0 == "off" )
    {
        var_3 = 10;
        var_2 = level.ac130_Speed["rotate"] / 360 * var_3;
        level.ac130 rotateyaw( level.ac130.angles[2] + var_3, var_2, 0, var_2 );
    }
}

attachPlayer( var_0 )
{
    self playerlinkweaponviewtodelta( level.ac130, "tag_player", 1.0, 35, 35, 35, 35 );
    self setplayerangles( level.ac130 gettagangles( "tag_player" ) );
}

changeWeapons()
{
    self endon( "ac130player_removed" );
    wait 0.05;
    self enableweapons();

    for (;;)
    {
        self waittill( "weapon_change",  var_0  );
        thread play_sound_on_entity( "ac130_weapon_switch" );
    }
}

weaponFiredThread()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        self waittill( "weapon_fired" );
        var_0 = self getcurrentweapon();

        switch ( var_0 )
        {
            case "ac130_105mm_mp":
                thread gun_fired_and_ready_105mm();
                earthquake( 0.2, 1, level.ac130.planemodel.origin, 1000 );
                self setplayerdata( "ac130Ammo105mm", self getweaponammoclip( var_0 ) );
                break;
            case "ac130_40mm_mp":
                earthquake( 0.1, 0.5, level.ac130.planemodel.origin, 1000 );
                self setplayerdata( "ac130Ammo40mm", self getweaponammoclip( var_0 ) );
                break;
            case "ac130_25mm_mp":
                self setplayerdata( "ac130Ammo25mm", self getweaponammoclip( var_0 ) );
                break;
        }

        if ( self getweaponammoclip( var_0 ) )
            continue;

        thread weaponReload( var_0 );
    }
}

weaponReload( var_0 )
{
    self endon( "ac130player_removed" );
    wait(level.weaponReloadTime[var_0]);
    self setweaponammoclip( var_0, 9999 );

    switch ( var_0 )
    {
        case "ac130_105mm_mp":
            self setplayerdata( "ac130Ammo105mm", self getweaponammoclip( var_0 ) );
            break;
        case "ac130_40mm_mp":
            self setplayerdata( "ac130Ammo40mm", self getweaponammoclip( var_0 ) );
            break;
        case "ac130_25mm_mp":
            self setplayerdata( "ac130Ammo25mm", self getweaponammoclip( var_0 ) );
            break;
    }

    if ( self getcurrentweapon() == var_0 )
    {
        self takeweapon( var_0 );
        maps\mp\_utility::_giveWeapon( var_0 );
        self switchtoweapon( var_0 );
    }
}

thermalVision()
{
    self endon( "ac130player_removed" );

    if ( maps\mp\_utility::getIntProperty( "ac130_thermal_enabled", 1 ) == 0 )
        return;

    var_0 = 0;
    self thermalvisionoff();
    self visionsetthermalforplayer( level.ac130.enhanced_vision, 1 );
    self.lastvisionsetthermal = level.ac130.enhanced_vision;
    level.HUDItem["thermal_vision"].alpha = 0.25;
    level.HUDItem["enhanced_vision"].alpha = 1.0;
    self notifyonplayercommand( "switch thermal", "+usereload" );
    self notifyonplayercommand( "switch thermal", "+activate" );

    for (;;)
    {
        self waittill( "switch thermal" );

        if ( !var_0 )
        {
            self thermalvisionon();
            self visionsetthermalforplayer( level.ac130.thermal_vision, 0.62 );
            self.lastvisionsetthermal = level.ac130.thermal_vision;
            level.HUDItem["thermal_vision"].alpha = 1.0;
            level.HUDItem["enhanced_vision"].alpha = 0.25;
        }
        else
        {
            self thermalvisionoff();
            self visionsetthermalforplayer( level.ac130.enhanced_vision, 0.51 );
            self.lastvisionsetthermal = level.ac130.enhanced_vision;
            level.HUDItem["thermal_vision"].alpha = 0.25;
            level.HUDItem["enhanced_vision"].alpha = 1.0;
        }

        var_0 = !var_0;
    }
}

clouds()
{
    self endon( "ac130player_removed" );
    wait 6;
    clouds_create();

    for (;;)
    {
        wait(randomfloatrange( 40, 80 ));
        clouds_create();
    }
}

clouds_create()
{
    if ( isdefined( level.playerWeapon ) && issubstr( tolower( level.playerWeapon ), "25" ) )
        return;

    playfxontagforclients( level._effect["cloud"], level.ac130, "tag_player", level.ac130player );
}

gun_fired_and_ready_105mm()
{
    self endon( "ac130player_removed" );
    level notify( "gun_fired_and_ready_105mm" );
    level endon( "gun_fired_and_ready_105mm" );
    wait 0.5;

    if ( randomint( 2 ) == 0 )
        thread context_Sensative_Dialog_Play_Random_Group_Sound( "weapons", "105mm_fired" );

    wait 5.0;
    thread context_Sensative_Dialog_Play_Random_Group_Sound( "weapons", "105mm_ready" );
}

shotFired()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        self waittill( "projectile_impact",  var_0, var_1, var_2  );

        if ( issubstr( tolower( var_0 ), "105" ) )
        {
            earthquake( 0.4, 1.0, var_1, 3500 );
            thread shotFiredDarkScreenOverlay();
        }
        else if ( issubstr( tolower( var_0 ), "40" ) )
            earthquake( 0.2, 0.5, var_1, 2000 );

        if ( maps\mp\_utility::getIntProperty( "ac130_ragdoll_deaths", 0 ) )
            thread shotFiredPhysicsSphere( var_1, var_0 );

        wait 0.05;
    }
}

shotFiredPhysicsSphere( var_0, var_1 )
{
    wait 0.1;
    physicsexplosionsphere( var_0, level.physicsSphereRadius[var_1], level.physicsSphereRadius[var_1] / 2, level.physicsSphereForce[var_1] );
}

shotFiredDarkScreenOverlay()
{
    self endon( "ac130player_removed" );
    self notify( "darkScreenOverlay" );
    self endon( "darkScreenOverlay" );

    if ( !isdefined( self.darkScreenOverlay ) )
    {
        self.darkScreenOverlay = newclienthudelem( self );
        self.darkScreenOverlay.x = 0;
        self.darkScreenOverlay.y = 0;
        self.darkScreenOverlay.alignx = "left";
        self.darkScreenOverlay.aligny = "top";
        self.darkScreenOverlay.horzalign = "fullscreen";
        self.darkScreenOverlay.vertalign = "fullscreen";
        self.darkScreenOverlay setshader( "black", 640, 480 );
        self.darkScreenOverlay.sort = -10;
        self.darkScreenOverlay.alpha = 0.0;
    }

    self.darkScreenOverlay.alpha = 0.0;
    self.darkScreenOverlay fadeovertime( 0.2 );
    self.darkScreenOverlay.alpha = 0.6;
    wait 0.4;
    self.darkScreenOverlay fadeovertime( 0.8 );
    self.darkScreenOverlay.alpha = 0.0;
}

add_beacon_effect()
{
    self endon( "death" );
    var_0 = 0.75;
    wait(randomfloat( 3.0 ));

    for (;;)
    {
        if ( level.ac130player )
            playfxontagforclients( level._effect["beacon"], self, "j_spine4", level.ac130player );

        wait(var_0);
    }
}

context_Sensative_Dialog()
{
    thread enemy_killed_thread();
    thread context_Sensative_Dialog_Guy_In_Sight();
    thread context_Sensative_Dialog_Guy_Crawling();
    thread context_Sensative_Dialog_Guy_Pain();
    thread context_Sensative_Dialog_Secondary_Explosion_Vehicle();
    thread context_Sensative_Dialog_Kill_Thread();
    thread context_Sensative_Dialog_Locations();
    thread context_Sensative_Dialog_Filler();
}

context_Sensative_Dialog_Guy_In_Sight()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        if ( context_Sensative_Dialog_Guy_In_Sight_Check() )
            thread context_Sensative_Dialog_Play_Random_Group_Sound( "ai", "in_sight" );

        wait(randomfloatrange( 1, 3 ));
    }
}

context_Sensative_Dialog_Guy_In_Sight_Check()
{
    var_0 = [];

    for ( var_1 = 0; var_1 < var_0.size; var_1++ )
    {
        if ( !isdefined( var_0[var_1] ) )
            continue;

        if ( !isalive( var_0[var_1] ) )
            continue;

        if ( within_fov( level.ac130player geteye(), level.ac130player getplayerangles(), var_0[var_1].origin, level.cosine["5"] ) )
            return 1;

        wait 0.05;
    }

    return 0;
}

context_Sensative_Dialog_Guy_Crawling()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        level waittill( "ai_crawling",  var_0  );
        thread context_Sensative_Dialog_Play_Random_Group_Sound( "ai", "wounded_crawl" );
    }
}

context_Sensative_Dialog_Guy_Pain()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        level waittill( "ai_pain",  var_0  );
        thread context_Sensative_Dialog_Play_Random_Group_Sound( "ai", "wounded_pain" );
    }
}

context_Sensative_Dialog_Secondary_Explosion_Vehicle()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        level waittill( "player_destroyed_car",  var_0, var_1  );
        wait 1;
        thread context_Sensative_Dialog_Play_Random_Group_Sound( "explosion", "secondary" );
    }
}

enemy_killed_thread()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        level waittill( "ai_killed",  var_0  );
        thread context_Sensative_Dialog_Kill( var_0, level.ac130player );
    }
}

context_Sensative_Dialog_Kill( var_0, var_1 )
{
    if ( !isdefined( var_1 ) )
        return;

    if ( !isplayer( var_1 ) )
        return;

    level.enemiesKilledInTimeWindow++;
    level notify( "enemy_killed" );
}

context_Sensative_Dialog_Kill_Thread()
{
    self endon( "ac130player_removed" );
    var_0 = 1;

    for (;;)
    {
        level waittill( "enemy_killed" );
        wait(var_0);
        var_1 = "kill";
        var_2 = undefined;

        if ( level.enemiesKilledInTimeWindow >= 2 )
            var_2 = "small_group";
        else
        {
            var_2 = "single";

            if ( randomint( 3 ) != 1 )
            {
                level.enemiesKilledInTimeWindow = 0;
                continue;
            }
        }

        level.enemiesKilledInTimeWindow = 0;
        thread context_Sensative_Dialog_Play_Random_Group_Sound( var_1, var_2, 1 );
    }
}

context_Sensative_Dialog_Locations()
{
    common_scripts\utility::array_thread( getentarray( "context_dialog_car", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "car" );
    common_scripts\utility::array_thread( getentarray( "context_dialog_truck", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "truck" );
    common_scripts\utility::array_thread( getentarray( "context_dialog_building", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "building" );
    common_scripts\utility::array_thread( getentarray( "context_dialog_wall", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "wall" );
    common_scripts\utility::array_thread( getentarray( "context_dialog_field", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "field" );
    common_scripts\utility::array_thread( getentarray( "context_dialog_road", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "road" );
    common_scripts\utility::array_thread( getentarray( "context_dialog_church", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "church" );
    common_scripts\utility::array_thread( getentarray( "context_dialog_ditch", "targetname" ), ::context_Sensative_Dialog_Locations_Add_Notify_Event, "ditch" );
    thread context_Sensative_Dialog_Locations_Thread();
}

context_Sensative_Dialog_Locations_Thread()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        level waittill( "context_location",  var_0  );

        if ( !isdefined( var_0 ) )
            continue;

        if ( !common_scripts\utility::flag( "allow_context_sensative_dialog" ) )
            continue;

        thread context_Sensative_Dialog_Play_Random_Group_Sound( "location", var_0 );
        wait(5 + randomfloat( 10 ));
    }
}

context_Sensative_Dialog_Locations_Add_Notify_Event( var_0 )
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        self waittill( "trigger",  var_1  );

        if ( !isdefined( var_1 ) )
            continue;

        if ( !isdefined( var_1.team ) || var_1.team != "axis" )
            continue;

        level notify( "context_location",  var_0  );
        wait 5;
    }
}

context_Sensative_Dialog_VehicleSpawn( var_0 )
{
    if ( var_0.script_team != "axis" )
        return;

    thread context_Sensative_Dialog_VehicleDeath( var_0 );
    var_0 endon( "death" );

    while ( !within_fov( level.ac130player geteye(), level.ac130player getplayerangles(), var_0.origin, level.cosine["45"] ) )
        wait 0.5;

    context_Sensative_Dialog_Play_Random_Group_Sound( "vehicle", "incoming" );
}

context_Sensative_Dialog_VehicleDeath( var_0 )
{
    var_0 waittill( "death" );
    thread context_Sensative_Dialog_Play_Random_Group_Sound( "vehicle", "death" );
}

context_Sensative_Dialog_Filler()
{
    self endon( "ac130player_removed" );

    for (;;)
    {
        if ( isdefined( level.radio_in_use ) && level.radio_in_use == 1 )
            level waittill( "radio_not_in_use" );

        var_0 = gettime();

        if ( var_0 - level.lastRadioTransmission >= 3000 )
        {
            level.lastRadioTransmission = var_0;
            thread context_Sensative_Dialog_Play_Random_Group_Sound( "misc", "action" );
        }

        wait 0.25;
    }
}

context_Sensative_Dialog_Play_Random_Group_Sound( var_0, var_1, var_2 )
{
    level endon( "ac130player_removed" );

    if ( !isdefined( var_2 ) )
        var_2 = 0;

    if ( !common_scripts\utility::flag( "allow_context_sensative_dialog" ) )
    {
        if ( var_2 )
            common_scripts\utility::flag_wait( "allow_context_sensative_dialog" );
        else
            return;
    }

    var_3 = undefined;
    var_4 = randomint( level.scr_sound[var_0][var_1].size );

    if ( level.scr_sound[var_0][var_1][var_4].played == 1 )
    {
        for ( var_5 = 0; var_5 < level.scr_sound[var_0][var_1].size; var_5++ )
        {
            var_4++;

            if ( var_4 >= level.scr_sound[var_0][var_1].size )
                var_4 = 0;

            if ( level.scr_sound[var_0][var_1][var_4].played == 1 )
                continue;

            var_3 = var_4;
            break;
        }

        if ( !isdefined( var_3 ) )
        {
            for ( var_5 = 0; var_5 < level.scr_sound[var_0][var_1].size; var_5++ )
                level.scr_sound[var_0][var_1][var_5].played = 0;

            var_3 = randomint( level.scr_sound[var_0][var_1].size );
        }
    }
    else
        var_3 = var_4;

    if ( context_Sensative_Dialog_Timedout( var_0, var_1, var_3 ) )
        return;

    level.scr_sound[var_0][var_1][var_3].played = 1;
    var_6 = randomint( level.scr_sound[var_0][var_1][var_3].size );
    playSoundOverRadio( level.scr_sound[var_0][var_1][var_3].sounds[var_6], var_2 );
}

context_Sensative_Dialog_Timedout( var_0, var_1, var_2 )
{
    if ( !isdefined( level.context_sensative_dialog_timeouts ) )
        return 0;

    if ( !isdefined( level.context_sensative_dialog_timeouts[var_0] ) )
        return 0;

    if ( !isdefined( level.context_sensative_dialog_timeouts[var_0][var_1] ) )
        return 0;

    if ( isdefined( level.context_sensative_dialog_timeouts[var_0][var_1].groups ) && isdefined( level.context_sensative_dialog_timeouts[var_0][var_1].groups[string( var_2 )] ) )
    {
        var_3 = gettime();

        if ( var_3 - level.context_sensative_dialog_timeouts[var_0][var_1].groups[string( var_2 )].v["lastPlayed"] < level.context_sensative_dialog_timeouts[var_0][var_1].groups[string( var_2 )].v["timeoutDuration"] )
            return 1;

        level.context_sensative_dialog_timeouts[var_0][var_1].groups[string( var_2 )].v["lastPlayed"] = var_3;
    }
    else if ( isdefined( level.context_sensative_dialog_timeouts[var_0][var_1].v ) )
    {
        var_3 = gettime();

        if ( var_3 - level.context_sensative_dialog_timeouts[var_0][var_1].v["lastPlayed"] < level.context_sensative_dialog_timeouts[var_0][var_1].v["timeoutDuration"] )
            return 1;

        level.context_sensative_dialog_timeouts[var_0][var_1].v["lastPlayed"] = var_3;
    }

    return 0;
}

playSoundOverRadio( var_0, var_1, var_2 )
{
    if ( !isdefined( level.radio_in_use ) )
        level.radio_in_use = 0;

    if ( !isdefined( var_1 ) )
        var_1 = 0;

    if ( !isdefined( var_2 ) )
        var_2 = 0;

    var_2 *= 1000;
    var_3 = gettime();
    var_4 = 0;
    var_4 = playAliasOverRadio( var_0 );

    if ( var_4 )
        return;

    if ( !var_1 )
        return;

    level.radioForcedTransmissionQueue[level.radioForcedTransmissionQueue.size] = var_0;

    while ( !var_4 )
    {
        if ( level.radio_in_use )
            level waittill( "radio_not_in_use" );

        if ( var_2 > 0 && gettime() - var_3 > var_2 )
            break;

        if ( !isdefined( level.ac130player ) )
            break;

        var_4 = playAliasOverRadio( level.radioForcedTransmissionQueue[0] );

        if ( !level.radio_in_use && isdefined( level.ac130player ) && !var_4 )
        {

        }
    }

    level.radioForcedTransmissionQueue = array_remove_index( level.radioForcedTransmissionQueue, 0 );
}

playAliasOverRadio( var_0 )
{
    if ( level.radio_in_use )
        return 0;

    if ( !isdefined( level.ac130player ) )
        return 0;

    level.radio_in_use = 1;

    if ( self.team == "allies" || self.team == "axis" )
    {
        var_0 = maps\mp\gametypes\_teams::getTeamVoicePrefix( self.team ) + var_0;
        level.ac130player playlocalsound( var_0 );
    }

    wait 4.0;
    level.radio_in_use = 0;
    level.lastRadioTransmission = gettime();
    level notify( "radio_not_in_use" );
    return 1;
}

debug_circle( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    var_6 = 16;
    var_7 = 360 / var_6;
    var_8 = [];

    for ( var_9 = 0; var_9 < var_6; var_9++ )
    {
        var_10 = var_7 * var_9;
        var_11 = cos( var_10 ) * var_1;
        var_12 = sin( var_10 ) * var_1;
        var_13 = var_0[0] + var_11;
        var_14 = var_0[1] + var_12;
        var_15 = var_0[2];
        var_8[var_8.size] = ( var_13, var_14, var_15 );
    }

    if ( isdefined( var_4 ) )
        wait(var_4);

    thread debug_circle_drawlines( var_8, var_2, var_3, var_5, var_0 );
}

debug_circle_drawlines( var_0, var_1, var_2, var_3, var_4 )
{
    if ( !isdefined( var_3 ) )
        var_3 = 0;

    if ( !isdefined( var_4 ) )
        var_3 = 0;

    for ( var_5 = 0; var_5 < var_0.size; var_5++ )
    {
        var_6 = var_0[var_5];

        if ( var_5 + 1 >= var_0.size )
            var_7 = var_0[0];
        else
            var_7 = var_0[var_5 + 1];

        thread debug_line( var_6, var_7, var_1, var_2 );

        if ( var_3 )
            thread debug_line( var_4, var_6, var_1, var_2 );
    }
}

debug_line( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( var_3 ) )
        var_3 = ( 1, 1, 1 );

    for ( var_4 = 0; var_4 < var_2 * 20; var_4++ )
        wait 0.05;
}

handleIncomingStinger()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "stinger_fired",  var_0, var_1, var_2  );

        if ( !isdefined( var_2 ) || var_2 != level.ac130.planemodel )
            continue;

        var_1 thread stingerProximityDetonate( var_0, var_0.team );
    }
}

deleteAfterTime( var_0 )
{
    wait(var_0);
    self delete();
}

stingerProximityDetonate( var_0, var_1 )
{
    self endon( "death" );

    if ( isdefined( level.ac130player ) )
        level.ac130player playlocalsound( "missile_incoming" );

    level.ac130.incomingMissile = 1;
    var_2 = level.ac130.planemodel;
    self missile_settargetent( var_2 );
    var_3 = 0;
    var_4 = var_2 getpointinbounds( 0, 0, 0 );
    var_5 = distance( self.origin, var_4 );
    var_6 = vectornormalize( var_4 - self.origin );

    for (;;)
    {
        if ( !isdefined( level.ac130player ) || isdefined( level.ac130.planemodel.crashed ) && level.ac130.planemodel.crashed == 1 )
        {
            self missile_settargetpos( level.ac130.origin + ( 0, 0, 100000 ) );
            return;
        }

        var_4 = var_2 getpointinbounds( 0, 0, 0 );
        var_7 = distance( self.origin, var_4 );

        if ( var_7 < 3000 && var_2 == level.ac130.planemodel && level.ac130.numFlares > 0 )
        {
            level.ac130.numFlares--;
            var_8 = var_2 deployFlares();
            self missile_settargetent( var_8 );
            var_2 = var_8;

            if ( isdefined( level.ac130player ) )
                level.ac130player stoplocalsound( "missile_incoming" );

            return;
        }

        if ( var_7 < var_5 )
        {
            var_9 = ( var_5 - var_7 ) * 20;
            var_10 = var_7 / var_9;

            if ( var_10 < 1.5 && !var_3 && var_2 == level.ac130.planemodel )
            {
                if ( isdefined( level.ac130player ) )
                    level.ac130player playlocalsound( "fasten_seatbelts" );

                var_3 = 1;
            }

            var_5 = var_7;
        }

        var_11 = vectornormalize( var_4 - self.origin );

        if ( vectordot( var_11, var_6 ) < 0 )
        {
            if ( isdefined( level.ac130player ) )
            {
                level.ac130player stoplocalsound( "missile_incoming" );

                if ( level.ac130player.team != var_1 )
                    radiusdamage( self.origin, 1000, 1000, 1000, var_0, "MOD_EXPLOSIVE", "stinger_mp" );
            }

            self hide();
            wait 0.05;
            self delete();
        }
        else
            var_6 = var_11;

        wait 0.05;
    }
}

handleIncomingSAM()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "sam_fired",  var_0, var_1, var_2  );

        if ( !isdefined( var_2 ) || var_2 != level.ac130.planemodel )
            continue;

        level thread samProximityDetonate( var_0, var_0.team, var_1 );
    }
}

samProximityDetonate( var_0, var_1, var_2 )
{
    if ( isdefined( level.ac130player ) )
        level.ac130player playlocalsound( "missile_incoming" );

    level.ac130.incomingMissile = 1;
    var_3 = level.ac130.planemodel;
    var_4 = 0;
    var_5 = [];
    var_6 = var_3 getpointinbounds( 0, 0, 0 );

    for ( var_7 = 0; var_7 < var_2.size; var_7++ )
    {
        if ( isdefined( var_2[var_7] ) )
        {
            var_5[var_7] = distance( var_2[var_7].origin, var_6 );
            var_2[var_7].lastVecToTarget = vectornormalize( var_6 - var_2[var_7].origin );
            continue;
        }

        var_5[var_7] = undefined;
    }

    for (;;)
    {
        if ( !isdefined( level.ac130player ) || isdefined( level.ac130.planemodel.crashed ) && level.ac130.planemodel.crashed == 1 )
        {
            for ( var_7 = 0; var_7 < var_2.size; var_7++ )
            {
                if ( isdefined( var_2[var_7] ) )
                    var_2[var_7] missile_settargetpos( level.ac130.origin + ( 0, 0, 100000 ) );
            }

            return;
        }

        var_6 = var_3 getpointinbounds( 0, 0, 0 );
        var_8 = [];

        for ( var_7 = 0; var_7 < var_2.size; var_7++ )
        {
            if ( isdefined( var_2[var_7] ) )
                var_8[var_7] = distance( var_2[var_7].origin, var_6 );
        }

        if ( !isdefined( level.ac130player ) )
            return;

        for ( var_7 = 0; var_7 < var_8.size; var_7++ )
        {
            if ( isdefined( var_8[var_7] ) )
            {
                if ( var_8[var_7] < 3000 && var_3 == level.ac130.planemodel && level.ac130.numFlares > 0 )
                {
                    level.ac130.numFlares--;
                    var_9 = var_3 deployFlares();

                    for ( var_10 = 0; var_10 < var_2.size; var_10++ )
                    {
                        if ( isdefined( var_2[var_10] ) )
                            var_2[var_10] missile_settargetent( var_9 );
                    }

                    if ( isdefined( level.ac130player ) )
                        level.ac130player stoplocalsound( "missile_incoming" );

                    return;
                }

                if ( var_8[var_7] < var_5[var_7] )
                {
                    var_11 = ( var_5[var_7] - var_8[var_7] ) * 20;
                    var_12 = var_8[var_7] / var_11;

                    if ( var_12 < 1.5 && !var_4 && var_3 == level.ac130.planemodel )
                    {
                        if ( isdefined( level.ac130player ) )
                            level.ac130player playlocalsound( "fasten_seatbelts" );

                        var_4 = 1;
                    }

                    var_5[var_7] = var_8[var_7];
                }

                var_13 = vectornormalize( var_6 - var_2[var_7].origin );

                if ( vectordot( var_13, var_2[var_7].lastVecToTarget ) < 0 )
                {
                    if ( isdefined( level.ac130player ) )
                    {
                        level.ac130player stoplocalsound( "missile_incoming" );

                        if ( level.teamBased )
                        {
                            if ( level.ac130player.team != var_1 )
                                radiusdamage( var_2[var_7].origin, 1000, 1000, 1000, var_0, "MOD_EXPLOSIVE", "sam_projectile_mp" );
                        }
                        else
                            radiusdamage( var_2[var_7].origin, 1000, 1000, 1000, var_0, "MOD_EXPLOSIVE", "sam_projectile_mp" );
                    }

                    var_2[var_7] hide();
                    wait 0.05;
                    var_2[var_7] delete();
                }
            }
        }

        wait 0.05;
    }
}

crashPlane( var_0 )
{
    level.ac130.planemodel notify( "crashing" );
    level.ac130.planemodel.crashed = 1;
    playfxontag( level._effect["ac130_explode"], level.ac130.planemodel, "tag_deathfx" );
    wait 0.25;
    level.ac130.planemodel hide();
}

playFlareFx( var_0 )
{
    for ( var_1 = 0; var_1 < var_0; var_1++ )
    {
        thread angel_flare();
        wait(randomfloatrange( 0.1, 0.25 ));
    }
}

deployFlares( var_0 )
{
    self playsound( "ac130_flare_burst" );

    if ( !isdefined( var_0 ) )
    {
        var_1 = spawn( "script_origin", level.ac130.planemodel.origin );
        var_1.angles = level.ac130.planemodel.angles;
        var_1 movegravity( ( 0, 0, 0 ), 5.0 );
        thread playFlareFx( 10 );
        var_1 thread deleteAfterTime( 5.0 );
        return var_1;
    }
    else
        thread playFlareFx( 5 );
}

angelFlarePrecache()
{
    precachemodel( "angel_flare_rig" );
    precachempanim( "ac130_angel_flares01" );
    precachempanim( "ac130_angel_flares02" );
    precachempanim( "ac130_angel_flares03" );
    level._effect["angel_flare_geotrail"] = loadfx( "smoke/angel_flare_geotrail" );
    level._effect["angel_flare_swirl"] = loadfx( "smoke/angel_flare_swirl_runner" );
}

angel_flare()
{
    var_0 = spawn( "script_model", self.origin );
    var_0 setmodel( "angel_flare_rig" );
    var_0.origin = self gettagorigin( "tag_flash_flares" );
    var_0.angles = self gettagangles( "tag_flash_flares" );
    var_0.angles = ( var_0.angles[0], var_0.angles[1] + 180, var_0.angles[2] + -90 );
    var_1 = level._effect["angel_flare_geotrail"];
    var_0 scriptmodelplayanim( "ac130_angel_flares0" + ( randomint( 3 ) + 1 ) );
    wait 0.1;
    playfxontag( var_1, var_0, "flare_left_top" );
    playfxontag( var_1, var_0, "flare_right_top" );
    wait 0.05;
    playfxontag( var_1, var_0, "flare_left_bot" );
    playfxontag( var_1, var_0, "flare_right_bot" );
    wait 3.0;
    stopfxontag( var_1, var_0, "flare_left_top" );
    stopfxontag( var_1, var_0, "flare_right_top" );
    stopfxontag( var_1, var_0, "flare_left_bot" );
    stopfxontag( var_1, var_0, "flare_right_bot" );
    var_0 delete();
}
