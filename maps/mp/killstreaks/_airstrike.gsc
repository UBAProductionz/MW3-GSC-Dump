// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precachelocationselector( "map_artillery_selector" );
    precachestring( &"KILLSTREAKS_PRECISION_AIRSTRIKE" );
    precachestring( &"KILLSTREAKS_STEALTH_AIRSTRIKE" );
    precachestring( &"KILLSTREAKS_HARRIER_AIRSTRIKE" );
    precacheitem( "stealth_bomb_mp" );
    precacheitem( "artillery_mp" );
    precacheitem( "harrier_missile_mp" );
    precachemodel( "vehicle_av8b_harrier_jet_mp" );
    precachemodel( "vehicle_av8b_harrier_jet_opfor_mp" );
    precachemodel( "weapon_minigun" );
    precachemodel( "vehicle_b2_bomber" );
    precachevehicle( "harrier_mp" );
    precacheturret( "harrier_FFAR_mp" );
    precacheminimapicon( "compass_objpoint_airstrike_friendly" );
    precacheminimapicon( "compass_objpoint_airstrike_busy" );
    precacheminimapicon( "compass_objpoint_b2_airstrike_friendly" );
    precacheminimapicon( "compass_objpoint_b2_airstrike_enemy" );
    precacheminimapicon( "hud_minimap_harrier_green" );
    precacheminimapicon( "hud_minimap_harrier_red" );
    level.onfirefx = loadfx( "fire/fire_smoke_trail_L" );
    level.airstrikefx = loadfx( "explosions/clusterbomb" );
    level.airstrikessfx = loadfx( "explosions/clusterbomb_no_fount" );
    level.airstrikeexplosion = loadfx( "explosions/clusterbomb_exp_direct_runner" );
    level.mortareffect = loadfx( "explosions/clusterbomb_exp_direct_runner_stealth" );
    level.bombstrike = loadfx( "explosions/wall_explosion_pm_a" );
    level.stealthbombfx = loadfx( "explosions/stealth_bomb_mp" );
    level.airPlane = [];
    level.harriers = [];
    level.planes = 0;
    level.harrier_smoke = loadfx( "fire/jet_afterburner_harrier_damaged" );
    level.harrier_deathfx = loadfx( "explosions/aerial_explosion_harrier" );
    level.harrier_afterburnerfx = loadfx( "fire/jet_afterburner_harrier" );
    level.fx_airstrike_afterburner = loadfx( "fire/jet_afterburner" );
    level.fx_airstrike_contrail = loadfx( "smoke/jet_contrail" );
    level.dangerMaxRadius["stealth_airstrike"] = 900;
    level.dangerMinRadius["stealth_airstrike"] = 750;
    level.dangerForwardPush["stealth_airstrike"] = 1;
    level.dangerOvalScale["stealth_airstrike"] = 6.0;
    level.dangerMaxRadius["airstrike"] = 550;
    level.dangerMinRadius["airstrike"] = 300;
    level.dangerForwardPush["airstrike"] = 1.5;
    level.dangerOvalScale["airstrike"] = 6.0;
    level.dangerMaxRadius["precision_airstrike"] = 550;
    level.dangerMinRadius["precision_airstrike"] = 300;
    level.dangerForwardPush["precision_airstrike"] = 2.0;
    level.dangerOvalScale["precision_airstrike"] = 6.0;
    level.dangerMaxRadius["harrier_airstrike"] = 550;
    level.dangerMinRadius["harrier_airstrike"] = 300;
    level.dangerForwardPush["harrier_airstrike"] = 1.5;
    level.dangerOvalScale["harrier_airstrike"] = 6.0;
    level.artilleryDangerCenters = [];
    level.killstreakFuncs["airstrike"] = ::tryUseDefaultAirstrike;
    level.killstreakFuncs["precision_airstrike"] = ::tryUsePrecisionAirstrike;
    level.killstreakFuncs["super_airstrike"] = ::tryUseSuperAirstrike;
    level.killstreakFuncs["harrier_airstrike"] = ::tryUseHarrierAirstrike;
    level.killstreakFuncs["stealth_airstrike"] = ::tryUseStealthAirstrike;
    level.planes = [];
}

tryUseDefaultAirstrike( var_0 )
{
    return tryUseAirstrike( var_0, "airstrike" );
}

tryUsePrecisionAirstrike( var_0 )
{
    return tryUseAirstrike( var_0, "precision_airstrike" );
}

tryUseSuperAirstrike( var_0 )
{
    return tryUseAirstrike( var_0, "super_airstrike" );
}

tryUseHarrierAirstrike( var_0 )
{
    return tryUseAirstrike( var_0, "harrier_airstrike" );
}

tryUseStealthAirstrike( var_0 )
{
    return tryUseAirstrike( var_0, "stealth_airstrike" );
}

tryUseAirstrike( var_0, var_1 )
{
    if ( !maps\mp\_utility::validateUseStreak() )
        return 0;

    if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }

    if ( maps\mp\_utility::isUsingRemote() )
        return 0;

    switch ( var_1 )
    {
        case "precision_airstrike":
            break;
        case "stealth_airstrike":
            break;
        case "harrier_airstrike":
            if ( level.planes > 1 )
            {
                self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
                return 0;
            }

            break;
        case "super_airstrike":
            break;
    }

    var_2 = selectAirstrikeLocation( var_0, var_1 );

    if ( !isdefined( var_2 ) || !var_2 )
        return 0;

    return 1;
}

doAirstrike( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( var_5 == "harrier_airstrike" )
        level.planes++;

    if ( isdefined( level.airstrikeInProgress ) )
    {
        while ( isdefined( level.airstrikeInProgress ) )
            level waittill( "begin_airstrike" );

        level.airstrikeInProgress = 1;
        wait 2.0;
    }

    if ( !isdefined( var_3 ) )
    {
        if ( var_5 == "harrier_airstrike" )
            level.planes--;

        return;
    }

    level.airstrikeInProgress = 1;
    var_6 = 17 + randomint( 3 );
    var_7 = bullettrace( var_1, var_1 + ( 0, 0, -1e+06 ), 0, undefined );
    var_8 = var_7["position"];
    var_9 = spawnstruct();
    var_9.origin = var_8;
    var_9.forward = anglestoforward( ( 0, var_2, 0 ) );
    var_9.streakName = var_5;
    level.artilleryDangerCenters[level.artilleryDangerCenters.size] = var_9;
    var_10 = callStrike( var_0, var_3, var_8, var_2, var_5 );
    wait 1.0;
    level.airstrikeInProgress = undefined;
    var_3 notify( "begin_airstrike" );
    level notify( "begin_airstrike" );
    wait 7.5;
    var_11 = 0;
    var_12 = [];

    for ( var_13 = 0; var_13 < level.artilleryDangerCenters.size; var_13++ )
    {
        if ( !var_11 && level.artilleryDangerCenters[var_13].origin == var_8 )
        {
            var_11 = 1;
            continue;
        }

        var_12[var_12.size] = level.artilleryDangerCenters[var_13];
    }

    level.artilleryDangerCenters = var_12;

    if ( var_5 != "harrier_airstrike" )
        return;

    while ( isdefined( var_10 ) )
        wait 0.1;

    level.planes--;
}

clearProgress( var_0 )
{
    wait 2.0;
    level.airstrikeInProgress = undefined;
}

getAirstrikeDanger( var_0 )
{
    var_1 = 0;

    for ( var_2 = 0; var_2 < level.artilleryDangerCenters.size; var_2++ )
    {
        var_3 = level.artilleryDangerCenters[var_2].origin;
        var_4 = level.artilleryDangerCenters[var_2].forward;
        var_5 = level.artilleryDangerCenters[var_2].streakName;
        var_1 += getSingleAirstrikeDanger( var_0, var_3, var_4, var_5 );
    }

    return var_1;
}

getSingleAirstrikeDanger( var_0, var_1, var_2, var_3 )
{
    var_4 = var_1 + level.dangerForwardPush[var_3] * level.dangerMaxRadius[var_3] * var_2;
    var_5 = var_0 - var_4;
    var_5 = ( var_5[0], var_5[1], 0 );
    var_6 = vectordot( var_5, var_2 ) * var_2;
    var_7 = var_5 - var_6;
    var_8 = var_7 + var_6 / level.dangerOvalScale[var_3];
    var_9 = lengthsquared( var_8 );

    if ( var_9 > level.dangerMaxRadius[var_3] * level.dangerMaxRadius[var_3] )
        return 0;

    if ( var_9 < level.dangerMinRadius[var_3] * level.dangerMinRadius[var_3] )
        return 1;

    var_10 = sqrt( var_9 );
    var_11 = ( var_10 - level.dangerMinRadius[var_3] ) / ( level.dangerMaxRadius[var_3] - level.dangerMinRadius[var_3] );
    return 1 - var_11;
}

pointIsInAirstrikeArea( var_0, var_1, var_2, var_3 )
{
    return distance2d( var_0, var_1 ) <= level.dangerMaxRadius[var_3] * 1.25;
}

losRadiusDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    var_7 = maps\mp\gametypes\_weapons::getDamageableEnts( var_0, var_1, 1 );
    glassradiusdamage( var_0, var_1, var_2, var_3 );

    for ( var_8 = 0; var_8 < var_7.size; var_8++ )
    {
        if ( var_7[var_8].entity == self )
            continue;

        var_9 = distance( var_0, var_7[var_8].damageCenter );

        if ( var_7[var_8].isPlayer || isdefined( var_7[var_8].isSentry ) && var_7[var_8].isSentry )
        {
            var_10 = !bullettracepassed( var_7[var_8].entity.origin, var_7[var_8].entity.origin + ( 0, 0, 130 ), 0, undefined );

            if ( var_10 )
            {
                var_10 = !bullettracepassed( var_7[var_8].entity.origin + ( 0, 0, 130 ), var_0 + ( 0, 0, 114 ), 0, undefined );

                if ( var_10 )
                {
                    var_9 *= 4;

                    if ( var_9 > var_1 )
                        continue;
                }
            }
        }

        var_7[var_8].damage = int( var_2 + ( var_3 - var_2 ) * var_9 / var_1 );
        var_7[var_8].pos = var_0;
        var_7[var_8].damageOwner = var_4;
        var_7[var_8].eInflictor = var_5;
        level.airStrikeDamagedEnts[level.airStrikeDamagedEntsCount] = var_7[var_8];
        level.airStrikeDamagedEntsCount++;
    }

    thread airstrikeDamageEntsThread( var_6 );
}

airstrikeDamageEntsThread( var_0 )
{
    self notify( "airstrikeDamageEntsThread" );
    self endon( "airstrikeDamageEntsThread" );

    while ( level.airstrikeDamagedEntsIndex < level.airStrikeDamagedEntsCount )
    {
        if ( !isdefined( level.airStrikeDamagedEnts[level.airstrikeDamagedEntsIndex] ) )
        {

        }
        else
        {
            var_1 = level.airStrikeDamagedEnts[level.airstrikeDamagedEntsIndex];

            if ( !isdefined( var_1.entity ) )
            {

            }
            else if ( !var_1.isPlayer || isalive( var_1.entity ) )
            {
                var_1 maps\mp\gametypes\_weapons::damageEnt( var_1.eInflictor, var_1.damageOwner, var_1.damage, "MOD_PROJECTILE_SPLASH", var_0, var_1.pos, vectornormalize( var_1.damageCenter - var_1.pos ) );
                level.airStrikeDamagedEnts[level.airstrikeDamagedEntsIndex] = undefined;

                if ( var_1.isPlayer )
                    wait 0.05;
            }
            else
                level.airStrikeDamagedEnts[level.airstrikeDamagedEntsIndex] = undefined;
        }

        level.airstrikeDamagedEntsIndex++;
    }
}

radiusArtilleryShellshock( var_0, var_1, var_2, var_3, var_4 )
{
    var_5 = level.players;

    foreach ( var_7 in level.players )
    {
        if ( !isalive( var_7 ) )
            continue;

        if ( var_7.team == var_4 || var_7.team == "spectator" )
            continue;

        var_8 = var_7.origin + ( 0, 0, 32 );
        var_9 = distance( var_0, var_8 );

        if ( var_9 > var_1 )
            continue;

        var_10 = int( var_2 + ( var_3 - var_2 ) * var_9 / var_1 );
        var_7 thread artilleryShellshock( "default", var_10 );
    }
}

artilleryShellshock( var_0, var_1 )
{
    self endon( "disconnect" );

    if ( isdefined( self.beingArtilleryShellshocked ) && self.beingArtilleryShellshocked )
        return;

    self.beingArtilleryShellshocked = 1;
    self shellshock( var_0, var_1 );
    wait(var_1 + 1);
    self.beingArtilleryShellshocked = 0;
}

doBomberStrike( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    if ( !isdefined( var_1 ) )
        return;

    var_10 = 100;
    var_11 = 150;
    var_12 = var_4 + ( ( randomfloat( 2 ) - 1 ) * var_10, ( randomfloat( 2 ) - 1 ) * var_10, 0 );
    var_13 = var_5 + ( ( randomfloat( 2 ) - 1 ) * var_11, ( randomfloat( 2 ) - 1 ) * var_11, 0 );
    var_14 = spawnplane( var_1, "script_model", var_12, "compass_objpoint_b2_airstrike_friendly", "compass_objpoint_b2_airstrike_enemy" );
    addPlaneToList( var_14 );
    var_14 thread handleDeath();
    var_14 playloopsound( "veh_b2_dist_loop" );
    var_14 setmodel( "vehicle_b2_bomber" );
    var_14 thread handleEMP( var_1 );
    var_14.lifeId = var_0;
    var_14.angles = var_8;
    var_15 = anglestoforward( var_8 );
    var_14 moveto( var_13, var_7, 0, 0 );
    thread stealthBomber_killCam( var_14, var_13, var_7, var_9 );
    thread bomberDropBombs( var_14, var_3, var_1 );
    var_14 endon( "death" );
    wait(var_7 * 0.65);
    removePlaneFromList( var_14 );
    var_14 notify( "delete" );
    var_14 delete();
}

bomberDropBombs( var_0, var_1, var_2 )
{
    var_0 endon( "death" );

    while ( !targetIsClose( var_0, var_1, 5000 ) )
        wait 0.05;

    var_3 = 1;
    var_4 = 0;
    var_0 notify( "start_bombing" );
    var_0 thread playBombFx();

    for ( var_5 = targetGetDist( var_0, var_1 ); var_5 < 5000; var_5 = targetGetDist( var_0, var_1 ) )
    {
        if ( var_5 < 1500 && !var_4 )
        {
            var_0 playsound( "veh_b2_sonic_boom" );
            var_4 = 1;
        }

        var_3 = !var_3;

        if ( var_5 < 4500 )
            var_0 thread callStrike_bomb( var_0.origin, var_2, ( 0, 0, 0 ), var_3 );

        wait 0.1;
    }

    var_0 notify( "stop_bombing" );
}

playBombFx()
{
    self endon( "stop_bombing" );
    self endon( "death" );

    for (;;)
    {
        playfxontag( level.stealthbombfx, self, "tag_left_alamo_missile" );
        playfxontag( level.stealthbombfx, self, "tag_right_alamo_missile" );
        wait 0.5;
    }
}

stealthBomber_killCam( var_0, var_1, var_2, var_3 )
{
    var_0 waittill( "start_bombing" );
    var_4 = anglestoforward( var_0.angles );
    var_5 = spawn( "script_model", var_0.origin + ( 0, 0, 100 ) - var_4 * 200 );
    var_0.killCamEnt = var_5;
    var_0.killCamEnt setscriptmoverkillcam( "airstrike" );
    var_0.airstrikeType = var_3;
    var_5.startTime = gettime();
    var_5 thread deleteAfterTime( 15.0 );
    var_5 linkto( var_0, "tag_origin", ( -256, 768, 768 ), ( 0, 0, 0 ) );
}

callStrike_bomb( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( var_1 ) || var_1 maps\mp\_utility::isEMPed() || var_1 maps\mp\_utility::isAirDenied() )
    {
        self notify( "stop_bombing" );
        return;
    }

    var_4 = 512;
    var_5 = ( 0, randomint( 360 ), 0 );
    var_6 = var_0 + anglestoforward( var_5 ) * randomfloat( var_4 );
    var_7 = bullettrace( var_6, var_6 + ( 0, 0, -10000 ), 0, undefined );
    var_6 = var_7["position"];
    var_8 = distance( var_0, var_6 );
    var_9 = tolower( getdvar( "mapname" ) );
    var_10 = var_9 == "mp_crosswalk_ss" || var_9 == "mp_restrepo_ss";

    if ( var_8 > 5000 && !var_10 )
        return;

    wait(0.85 * var_8 / 2000);

    if ( !isdefined( var_1 ) || var_1 maps\mp\_utility::isEMPed() || var_1 maps\mp\_utility::isAirDenied() )
    {
        self notify( "stop_bombing" );
        return;
    }

    if ( var_3 )
    {
        playfx( level.mortareffect, var_6 );
        playrumbleonposition( "grenade_rumble", var_6 );
        earthquake( 1.0, 0.6, var_6, 2000 );
    }

    thread maps\mp\_utility::playSoundinSpace( "exp_airstrike_bomb", var_6 );
    radiusArtilleryShellshock( var_6, 512, 8, 4, var_1.team );
    losRadiusDamage( var_6 + ( 0, 0, 16 ), 896, 300, 50, var_1, self, "stealth_bomb_mp" );
}

doPlaneStrike( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    if ( !isdefined( var_1 ) )
        return;

    var_10 = 100;
    var_11 = 150;
    var_12 = var_4 + ( ( randomfloat( 2 ) - 1 ) * var_10, ( randomfloat( 2 ) - 1 ) * var_10, 0 );
    var_13 = var_5 + ( ( randomfloat( 2 ) - 1 ) * var_11, ( randomfloat( 2 ) - 1 ) * var_11, 0 );

    if ( var_9 == "harrier_airstrike" )
        var_14 = spawnplane( var_1, "script_model", var_12, "hud_minimap_harrier_green", "hud_minimap_harrier_red" );
    else
        var_14 = spawnplane( var_1, "script_model", var_12, "compass_objpoint_airstrike_friendly", "compass_objpoint_airstrike_busy" );

    addPlaneToList( var_14 );
    var_14 thread handleDeath();

    if ( var_9 == "harrier_airstrike" )
    {
        if ( var_1.team == "allies" )
            var_14 setmodel( "vehicle_av8b_harrier_jet_mp" );
        else
            var_14 setmodel( "vehicle_av8b_harrier_jet_opfor_mp" );
    }
    else
        var_14 setmodel( "vehicle_mig29_desert" );

    var_14 playloopsound( "veh_mig29_dist_loop" );
    var_14 thread handleEMP( var_1 );
    var_14.lifeId = var_0;
    var_14.angles = var_8;
    var_15 = anglestoforward( var_8 );
    var_14 thread playPlaneFx();
    var_14 moveto( var_13, var_7, 0, 0 );
    thread callStrike_bombEffect( var_14, var_13, var_7, var_6 - 1.0, var_1, var_2, var_9 );
    var_14 endon( "death" );
    wait(var_7);
    removePlaneFromList( var_14 );
    var_14 notify( "delete" );
    var_14 delete();
}

handleDeath()
{
    level endon( "game_ended" );
    self endon( "delete" );
    self waittill( "death" );
    var_0 = anglestoforward( self.angles ) * 200;
    playfx( level.harrier_deathfx, self.origin, var_0 );
    removePlaneFromList( self );
    self delete();
}

addPlaneToList( var_0 )
{
    level.planes[level.planes.size] = var_0;
}

removePlaneFromList( var_0 )
{
    for ( var_1 = 0; var_1 < level.planes.size; var_1++ )
    {
        if ( isdefined( level.planes[var_1] ) && level.planes[var_1] == var_0 )
            level.planes[var_1] = undefined;
    }
}

callStrike_bombEffect( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    var_0 endon( "death" );
    wait(var_3);

    if ( !isdefined( var_4 ) || var_4 maps\mp\_utility::isEMPed() || var_4 maps\mp\_utility::isAirDenied() )
        return;

    var_0 playsound( "veh_mig29_sonic_boom" );
    var_7 = anglestoforward( var_0.angles );
    var_8 = spawnbomb( var_0.origin, var_0.angles );
    var_8 movegravity( anglestoforward( var_0.angles ) * 4666.67, 3.0 );
    var_8.lifeId = var_5;
    var_9 = spawn( "script_model", var_0.origin + ( 0, 0, 100 ) - var_7 * 200 );
    var_8.killCamEnt = var_9;
    var_8.killCamEnt setscriptmoverkillcam( "airstrike" );
    var_8.airstrikeType = var_6;
    var_9.startTime = gettime();
    var_9 thread deleteAfterTime( 15.0 );
    var_9.angles = var_7;
    var_9 moveto( var_1 + ( 0, 0, 100 ), var_2, 0, 0 );
    wait 0.4;
    var_9 moveto( var_9.origin + var_7 * 4000, 1, 0, 0 );
    wait 0.45;
    var_9 moveto( var_9.origin + ( var_7 + ( 0, 0, -0.2 ) ) * 3500, 2, 0, 0 );
    wait 0.15;
    var_10 = spawn( "script_model", var_8.origin );
    var_10 setmodel( "tag_origin" );
    var_10.origin = var_8.origin;
    var_10.angles = var_8.angles;
    var_8 setmodel( "tag_origin" );
    wait 0.1;
    var_11 = var_10.origin;
    var_12 = var_10.angles;

    if ( level.splitscreen )
        playfxontag( level.airstrikessfx, var_10, "tag_origin" );
    else
        playfxontag( level.airstrikefx, var_10, "tag_origin" );

    wait 0.05;
    var_9 moveto( var_9.origin + ( var_7 + ( 0, 0, -0.25 ) ) * 2500, 2, 0, 0 );
    wait 0.25;
    var_9 moveto( var_9.origin + ( var_7 + ( 0, 0, -0.35 ) ) * 2000, 2, 0, 0 );
    wait 0.2;
    var_9 moveto( var_9.origin + ( var_7 + ( 0, 0, -0.45 ) ) * 1500, 2, 0, 0 );
    wait 0.5;
    var_13 = 12;
    var_14 = 5;
    var_15 = 55;
    var_16 = ( var_15 - var_14 ) / var_13;
    var_17 = ( 0, 0, 0 );

    for ( var_18 = 0; var_18 < var_13; var_18++ )
    {
        var_19 = anglestoforward( var_12 + ( var_15 - var_16 * var_18, randomint( 10 ) - 5, 0 ) );
        var_20 = var_11 + var_19 * 10000;
        var_21 = bullettrace( var_11, var_20, 0, undefined );
        var_22 = var_21["position"];
        var_17 += var_22;
        playfx( level.airstrikeexplosion, var_22 );
        thread losRadiusDamage( var_22 + ( 0, 0, 16 ), 512, 200, 30, var_4, var_8, "artillery_mp" );

        if ( var_18 % 3 == 0 )
        {
            thread maps\mp\_utility::playSoundinSpace( "exp_airstrike_bomb", var_22 );
            playrumbleonposition( "artillery_rumble", var_22 );
            earthquake( 0.7, 0.75, var_22, 1000 );
        }

        wait 0.05;
    }

    var_17 = var_17 / var_13 + ( 0, 0, 128 );
    var_9 moveto( var_8.killCamEnt.origin * 0.35 + var_17 * 0.65, 1.5, 0, 0.5 );
    wait 5.0;
    var_10 delete();
    var_8 delete();
}

spawnbomb( var_0, var_1 )
{
    var_2 = spawn( "script_model", var_0 );
    var_2.angles = var_1;
    var_2 setmodel( "projectile_cbu97_clusterbomb" );
    return var_2;
}

deleteAfterTime( var_0 )
{
    self endon( "death" );
    wait 10.0;
    self delete();
}

playPlaneFx()
{
    self endon( "death" );
    wait 0.5;
    playfxontag( level.fx_airstrike_afterburner, self, "tag_engine_right" );
    wait 0.5;
    playfxontag( level.fx_airstrike_afterburner, self, "tag_engine_left" );
    wait 0.5;
    playfxontag( level.fx_airstrike_contrail, self, "tag_right_wingtip" );
    wait 0.5;
    playfxontag( level.fx_airstrike_contrail, self, "tag_left_wingtip" );
}

callStrike( var_0, var_1, var_2, var_3, var_4 )
{
    var_5 = undefined;
    var_6 = 0;
    var_7 = ( 0, var_3, 0 );
    var_5 = getent( "airstrikeheight", "targetname" );

    if ( var_4 == "stealth_airstrike" )
    {
        thread maps\mp\_utility::teamPlayerCardSplash( "used_stealth_airstrike", var_1, var_1.team );
        var_8 = 12000;
        var_9 = 2000;

        if ( !isdefined( var_5 ) )
        {
            var_10 = 950;
            var_6 = 1500;

            if ( isdefined( level.airstrikeHeightScale ) )
                var_10 *= level.airstrikeHeightScale;
        }
        else
        {
            var_10 = var_5.origin[2];

            if ( getdvar( "mapname" ) == "mp_exchange" )
                var_10 += 1024;

            var_6 = getExplodeDistance( var_10 );
        }
    }
    else
    {
        var_8 = 24000;
        var_9 = 7000;

        if ( !isdefined( var_5 ) )
        {
            var_10 = 850;
            var_6 = 1500;

            if ( isdefined( level.airstrikeHeightScale ) )
                var_10 *= level.airstrikeHeightScale;
        }
        else
        {
            var_10 = var_5.origin[2];
            var_6 = getExplodeDistance( var_10 );
        }
    }

    var_11 = var_2 + anglestoforward( var_7 ) * ( -1 * var_8 );

    if ( isdefined( var_5 ) )
        var_11 *= ( 1, 1, 0 );

    var_11 += ( 0, 0, var_10 );

    if ( var_4 == "stealth_airstrike" )
        var_12 = var_2 + anglestoforward( var_7 ) * ( var_8 * 4 );
    else
        var_12 = var_2 + anglestoforward( var_7 ) * var_8;

    if ( isdefined( var_5 ) )
        var_12 *= ( 1, 1, 0 );

    var_12 += ( 0, 0, var_10 );
    var_13 = length( var_11 - var_12 );
    var_14 = var_13 / var_9;
    var_13 = abs( var_13 / 2 + var_6 );
    var_15 = var_13 / var_9;
    var_1 endon( "disconnect" );
    var_16 = var_0;
    level.airStrikeDamagedEnts = [];
    level.airStrikeDamagedEntsCount = 0;
    level.airstrikeDamagedEntsIndex = 0;

    if ( var_4 == "harrier_airstrike" )
    {
        level thread doPlaneStrike( var_0, var_1, var_16, var_2, var_11 + ( 0, 0, randomint( 500 ) ), var_12 + ( 0, 0, randomint( 500 ) ), var_15, var_14, var_7, var_4 );
        wait(randomfloatrange( 1.5, 2.5 ));
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
        level thread doPlaneStrike( var_0, var_1, var_16, var_2, var_11 + ( 0, 0, randomint( 200 ) ), var_12 + ( 0, 0, randomint( 200 ) ), var_15, var_14, var_7, var_4 );
        wait(randomfloatrange( 1.5, 2.5 ));
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
        var_17 = maps\mp\killstreaks\_harrier::beginHarrier( var_0, var_11, var_2 );
        var_1 thread maps\mp\killstreaks\_harrier::defendLocation( var_17 );
        return var_17;
    }
    else if ( var_4 == "stealth_airstrike" )
        level thread doBomberStrike( var_0, var_1, var_16, var_2, var_11 + ( 0, 0, randomint( 1000 ) ), var_12 + ( 0, 0, randomint( 1000 ) ), var_15, var_14, var_7, var_4 );
    else
    {
        level thread doPlaneStrike( var_0, var_1, var_16, var_2, var_11 + ( 0, 0, randomint( 500 ) ), var_12 + ( 0, 0, randomint( 500 ) ), var_15, var_14, var_7, var_4 );
        wait(randomfloatrange( 1.5, 2.5 ));
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
        level thread doPlaneStrike( var_0, var_1, var_16, var_2, var_11 + ( 0, 0, randomint( 200 ) ), var_12 + ( 0, 0, randomint( 200 ) ), var_15, var_14, var_7, var_4 );
        wait(randomfloatrange( 1.5, 2.5 ));
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
        level thread doPlaneStrike( var_0, var_1, var_16, var_2, var_11 + ( 0, 0, randomint( 200 ) ), var_12 + ( 0, 0, randomint( 200 ) ), var_15, var_14, var_7, var_4 );

        if ( var_4 == "super_airstrike" )
        {
            wait(randomfloatrange( 2.5, 3.5 ));
            maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
            level thread doPlaneStrike( var_0, var_1, var_16, var_2, var_11 + ( 0, 0, randomint( 200 ) ), var_12 + ( 0, 0, randomint( 200 ) ), var_15, var_14, var_7, var_4 );
        }
    }
}

getExplodeDistance( var_0 )
{
    var_1 = 850;
    var_2 = 1500;
    var_3 = var_1 / var_0;
    var_4 = var_3 * var_2;
    return var_4;
}

targetGetDist( var_0, var_1 )
{
    var_2 = targetIsInFront( var_0, var_1 );

    if ( var_2 )
        var_3 = 1;
    else
        var_3 = -1;

    var_4 = common_scripts\utility::flat_origin( var_0.origin );
    var_5 = var_4 + anglestoforward( common_scripts\utility::flat_angle( var_0.angles ) ) * ( var_3 * 100000 );
    var_6 = pointonsegmentnearesttopoint( var_4, var_5, var_1 );
    var_7 = distance( var_4, var_6 );
    return var_7;
}

targetIsClose( var_0, var_1, var_2 )
{
    if ( !isdefined( var_2 ) )
        var_2 = 3000;

    var_3 = targetIsInFront( var_0, var_1 );

    if ( var_3 )
        var_4 = 1;
    else
        var_4 = -1;

    var_5 = common_scripts\utility::flat_origin( var_0.origin );
    var_6 = var_5 + anglestoforward( common_scripts\utility::flat_angle( var_0.angles ) ) * ( var_4 * 100000 );
    var_7 = pointonsegmentnearesttopoint( var_5, var_6, var_1 );
    var_8 = distance( var_5, var_7 );

    if ( var_8 < var_2 )
        return 1;
    else
        return 0;
}

targetIsInFront( var_0, var_1 )
{
    var_2 = anglestoforward( common_scripts\utility::flat_angle( var_0.angles ) );
    var_3 = vectornormalize( common_scripts\utility::flat_origin( var_1 ) - var_0.origin );
    var_4 = vectordot( var_2, var_3 );

    if ( var_4 > 0 )
        return 1;
    else
        return 0;
}

waitForAirstrikeCancel()
{
    self waittill( "cancel_location" );
    self setblurforplayer( 0, 0.3 );
}

selectAirstrikeLocation( var_0, var_1 )
{
    var_2 = level.mapSize / 6.46875;

    if ( level.splitscreen )
        var_2 *= 1.5;

    var_3 = 0;

    switch ( var_1 )
    {
        case "precision_airstrike":
            var_3 = 1;
            self playlocalsound( game["voice"][self.team] + "KS_hqr_airstrike" );
            break;
        case "stealth_airstrike":
            var_3 = 1;
            self playlocalsound( game["voice"][self.team] + "KS_hqr_bomber" );
            break;
    }

    maps\mp\_utility::_beginLocationSelection( var_1, "map_artillery_selector", var_3, var_2 );
    self endon( "stop_location_selection" );
    self waittill( "confirm_location",  var_4, var_5  );

    if ( !var_3 )
        var_5 = randomint( 360 );

    self setblurforplayer( 0, 0.3 );

    if ( var_1 == "harrier_airstrike" && level.planes > 1 )
    {
        self notify( "cancel_location" );
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        return 0;
    }

    thread airstrikeMadeSelectionVO( var_1 );
    maps\mp\_matchdata::logKillstreakEvent( var_1, var_4 );
    thread finishAirstrikeUsage( var_0, var_4, var_5, var_1 );
    return 1;
}

finishAirstrikeUsage( var_0, var_1, var_2, var_3 )
{
    self notify( "used" );
    var_4 = bullettrace( level.mapCenter + ( 0, 0, 1e+06 ), level.mapCenter, 0, undefined );
    var_1 = ( var_1[0], var_1[1], var_4["position"][2] - 514 );
    thread doAirstrike( var_0, var_1, var_2, self, self.pers["team"], var_3 );
}

useAirstrike( var_0, var_1, var_2 )
{

}

handleEMP( var_0 )
{
    self endon( "death" );

    if ( var_0 maps\mp\_utility::isEMPed() )
    {
        self notify( "death" );
        return;
    }

    for (;;)
    {
        level waittill( "emp_update" );

        if ( !var_0 maps\mp\_utility::isEMPed() )
            continue;

        self notify( "death" );
    }
}

airstrikeMadeSelectionVO( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );

    switch ( var_0 )
    {
        case "precision_airstrike":
            self playlocalsound( game["voice"][self.team] + "KS_ast_inbound" );
            break;
        case "stealth_airstrike":
            self playlocalsound( game["voice"][self.team] + "KS_bmb_inbound" );
            break;
    }
}
