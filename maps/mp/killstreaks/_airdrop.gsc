// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precachevehicle( "littlebird_mp" );
    precachemodel( "com_plasticcase_friendly" );
    precachemodel( "com_plasticcase_enemy" );
    precachemodel( "com_plasticcase_trap_friendly" );
    precachemodel( "com_plasticcase_trap_bombsquad" );
    precachemodel( "vehicle_little_bird_armed" );
    precachemodel( "vehicle_ac130_low_mp" );
    precachemodel( "sentry_minigun_folded" );
    precachestring( &"PLATFORM_GET_RANDOM" );
    precachestring( &"PLATFORM_GET_KILLSTREAK" );
    precachestring( &"PLATFORM_CALL_NUKE" );
    precachestring( &"MP_CAPTURING_CRATE" );
    precacheshader( "compassping_friendly_mp" );
    precacheshader( "compassping_enemy" );
    precacheitem( "airdrop_trap_explosive_mp" );
    precachemodel( maps\mp\gametypes\_teams::getTeamCrateModel( "allies" ) );
    precachemodel( maps\mp\gametypes\_teams::getTeamCrateModel( "axis" ) );
    precachemodel( "prop_suitcase_bomb" );
    precacheshader( maps\mp\gametypes\_teams::getTeamHudIcon( "allies" ) );
    precacheshader( maps\mp\gametypes\_teams::getTeamHudIcon( "axis" ) );
    precacheshader( "waypoint_ammo_friendly" );
    precacheshader( "compass_objpoint_ammo_friendly" );
    precacheshader( "compass_objpoint_trap_friendly" );
    precacheshader( "compass_objpoint_ammo_enemy" );
    precacheminimapicon( "compass_objpoint_c130_friendly" );
    precacheminimapicon( "compass_objpoint_c130_enemy" );
    game["strings"]["ammo_hint"] = &"MP_AMMO_PICKUP";
    game["strings"]["explosive_ammo_hint"] = &"MP_EXPLOSIVE_AMMO_PICKUP";
    game["strings"]["uav_hint"] = &"MP_UAV_PICKUP";
    game["strings"]["counter_uav_hint"] = &"MP_COUNTER_UAV_PICKUP";
    game["strings"]["sentry_hint"] = &"MP_SENTRY_PICKUP";
    game["strings"]["juggernaut_hint"] = &"MP_JUGGERNAUT_PICKUP";
    game["strings"]["airdrop_juggernaut_hint"] = &"MP_JUGGERNAUT_PICKUP";
    game["strings"]["airdrop_juggernaut_def_hint"] = &"MP_JUGGERNAUT_PICKUP";
    game["strings"]["airdrop_juggernaut_gl_hint"] = &"MP_JUGGERNAUT_PICKUP";
    game["strings"]["airdrop_juggernaut_recon_hint"] = &"MP_JUGGERNAUT_PICKUP";
    game["strings"]["trophy_hint"] = &"MP_PICKUP_TROPHY";
    game["strings"]["predator_missile_hint"] = &"MP_PREDATOR_MISSILE_PICKUP";
    game["strings"]["airstrike_hint"] = &"MP_AIRSTRIKE_PICKUP";
    game["strings"]["precision_airstrike_hint"] = &"MP_PRECISION_AIRSTRIKE_PICKUP";
    game["strings"]["harrier_airstrike_hint"] = &"MP_HARRIER_AIRSTRIKE_PICKUP";
    game["strings"]["helicopter_hint"] = &"MP_HELICOPTER_PICKUP";
    game["strings"]["helicopter_flares_hint"] = &"MP_HELICOPTER_FLARES_PICKUP";
    game["strings"]["stealth_airstrike_hint"] = &"MP_STEALTH_AIRSTRIKE_PICKUP";
    game["strings"]["helicopter_minigun_hint"] = &"MP_HELICOPTER_MINIGUN_PICKUP";
    game["strings"]["ac130_hint"] = &"MP_AC130_PICKUP";
    game["strings"]["emp_hint"] = &"MP_EMP_PICKUP";
    game["strings"]["littlebird_support_hint"] = &"MP_LITTLEBIRD_SUPPORT_PICKUP";
    game["strings"]["littlebird_flock_hint"] = &"MP_LITTLEBIRD_FLOCK_PICKUP";
    game["strings"]["uav_strike_hint"] = &"MP_UAV_STRIKE_PICKUP";
    game["strings"]["light_armor_hint"] = &"MP_LIGHT_ARMOR_PICKUP";
    game["strings"]["minigun_turret_hint"] = &"MP_MINIGUN_TURRET_PICKUP";
    game["strings"]["team_ammo_refill_hint"] = &"MP_TEAM_AMMO_REFILL_PICKUP";
    game["strings"]["deployable_vest_hint"] = &"MP_DEPLOYABLE_VEST_PICKUP";
    game["strings"]["deployable_exp_ammo_hint"] = &"MP_DEPLOYABLE_EXP_AMMO_PICKUP";
    game["strings"]["gl_turret_hint"] = &"MP_GL_TURRET_PICKUP";
    game["strings"]["directional_uav_hint"] = &"MP_DIRECTIONAL_UAV_PICKUP";
    game["strings"]["ims_hint"] = &"MP_IMS_PICKUP";
    game["strings"]["heli_sniper_hint"] = &"MP_HELI_SNIPER_PICKUP";
    game["strings"]["heli_minigunner_hint"] = &"MP_HELI_MINIGUNNER_PICKUP";
    game["strings"]["remote_mortar_hint"] = &"MP_REMOTE_MORTAR_PICKUP";
    game["strings"]["remote_uav_hint"] = &"MP_REMOTE_UAV_PICKUP";
    game["strings"]["littlebird_support_hint"] = &"MP_LITTLEBIRD_SUPPORT_PICKUP";
    game["strings"]["osprey_gunner_hint"] = &"MP_OSPREY_GUNNER_PICKUP";
    game["strings"]["remote_tank_hint"] = &"MP_REMOTE_TANK_PICKUP";
    game["strings"]["triple_uav_hint"] = &"MP_TRIPLE_UAV_PICKUP";
    game["strings"]["remote_mg_turret_hint"] = &"MP_REMOTE_MG_TURRET_PICKUP";
    game["strings"]["sam_turret_hint"] = &"MP_SAM_TURRET_PICKUP";
    game["strings"]["escort_airdrop_hint"] = &"MP_ESCORT_AIRDROP_PICKUP";
    level.airDropCrates = getentarray( "care_package", "targetname" );
    level.oldAirDropCrates = getentarray( "airdrop_crate", "targetname" );

    if ( !level.airDropCrates.size )
    {
        level.airDropCrates = level.oldAirDropCrates;
        level.airDropCrateCollision = getent( level.airDropCrates[0].target, "targetname" );
    }
    else
    {
        foreach ( var_1 in level.oldAirDropCrates )
            var_1 deleteCrate();

        level.airDropCrateCollision = getent( level.airDropCrates[0].target, "targetname" );
        level.oldAirDropCrates = getentarray( "airdrop_crate", "targetname" );
    }

    if ( level.airDropCrates.size )
    {
        foreach ( var_1 in level.airDropCrates )
            var_1 deleteCrate();
    }

    level.numDropCrates = 0;
    level.killstreakFuncs["airdrop_assault"] = ::tryUseAssaultAirdrop;
    level.killstreakFuncs["airdrop_support"] = ::tryUseSupportAirdrop;
    level.killstreakFuncs["airdrop_mega"] = ::tryUseMegaAirdrop;
    level.killstreakFuncs["airdrop_predator_missile"] = ::tryUseAirdropPredatorMissile;
    level.killstreakFuncs["airdrop_sentry_minigun"] = ::tryUseAirdropSentryMinigun;
    level.killstreakFuncs["airdrop_juggernaut"] = ::tryUseJuggernautAirdrop;
    level.killstreakFuncs["airdrop_juggernaut_def"] = ::tryUseJuggernautDefAirdrop;
    level.killstreakFuncs["airdrop_juggernaut_gl"] = ::tryUseJuggernautGLAirdrop;
    level.killstreakFuncs["airdrop_juggernaut_recon"] = ::tryUseJuggernautReconAirdrop;
    level.killstreakFuncs["airdrop_trophy"] = ::tryUseTrophyAirdrop;
    level.killstreakFuncs["airdrop_trap"] = ::tryUseAirdropTrap;
    level.killstreakFuncs["airdrop_remote_tank"] = ::tryUseAirdropRemoteTank;
    level.killstreakFuncs["ammo"] = ::tryUseAmmo;
    level.killstreakFuncs["explosive_ammo"] = ::tryUseExplosiveAmmo;
    level.killstreakFuncs["explosive_ammo_2"] = ::tryUseExplosiveAmmo;
    level.killstreakFuncs["light_armor"] = ::tryUseLightArmor;
    level.littleBirds = [];
    level.crateTypes = [];
    addCrateType( "airdrop_assault", "uav", 10, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "ims", 20, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "predator_missile", 20, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "sentry", 20, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "precision_airstrike", 6, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "helicopter", 4, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "littlebird_support", 4, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "littlebird_flock", 4, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "remote_mortar", 3, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "remote_tank", 3, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "helicopter_flares", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "ac130", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_assault", "airdrop_juggernaut", 1, ::juggernautCrateThink );
    addCrateType( "airdrop_assault", "osprey_gunner", 1, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "uav", 10, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "ims", 20, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "predator_missile", 20, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "sentry", 20, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "precision_airstrike", 8, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "littlebird_flock", 8, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "remote_mortar", 5, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "remote_tank", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "helicopter_flares", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_osprey_gunner", "airdrop_juggernaut", 1, ::juggernautCrateThink );
    addCrateType( "airdrop_osprey_gunner", "ac130", 1, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "uav", 9, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "counter_uav", 9, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "deployable_vest", 8, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "sam_turret", 6, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "remote_uav", 5, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "remote_mg_turret", 5, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "stealth_airstrike", 4, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "triple_uav", 3, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "airdrop_juggernaut_recon", 2, ::juggernautCrateThink );
    addCrateType( "airdrop_support", "escort_airdrop", 1, ::killstreakCrateThink );
    addCrateType( "airdrop_support", "emp", 1, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "airdrop_trap", 10, ::trapCrateThink );
    addCrateType( "airdrop_escort", "uav", 8, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "counter_uav", 8, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "deployable_vest", 7, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "sentry", 7, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "ims", 7, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "sam_turret", 6, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "stealth_airstrike", 5, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "airdrop_juggernaut_recon", 5, ::juggernautCrateThink );
    addCrateType( "airdrop_escort", "remote_uav", 5, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "triple_uav", 3, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "remote_mg_turret", 3, ::killstreakCrateThink );
    addCrateType( "airdrop_escort", "emp", 1, ::killstreakCrateThink );
    addCrateType( "airdrop_trapcontents", "ims", 6, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "predator_missile", 7, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "sentry", 7, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "precision_airstrike", 7, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "helicopter", 8, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "littlebird_support", 8, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "littlebird_flock", 8, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "remote_mortar", 9, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "remote_tank", 9, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "helicopter_flares", 10, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "ac130", 10, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "airdrop_juggernaut", 10, ::trapNullFunc );
    addCrateType( "airdrop_trapcontents", "osprey_gunner", 10, ::trapNullFunc );
    addCrateType( "airdrop_grnd", "uav", 25, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "counter_uav", 25, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "deployable_vest", 21, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "sentry", 21, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "remote_mg_turret", 17, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "ims", 17, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "triple_uav", 13, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "predator_missile", 13, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "airdrop_trap", 11, ::trapCrateThink );
    addCrateType( "airdrop_grnd", "precision_airstrike", 9, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "stealth_airstrike", 9, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "helicopter", 9, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "remote_tank", 7, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "sam_turret", 7, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "remote_uav", 7, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "littlebird_support", 4, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "airdrop_juggernaut_recon", 4, ::juggernautCrateThink );
    addCrateType( "airdrop_grnd", "littlebird_flock", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "helicopter_flares", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "remote_mortar", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "ac130", 2, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "airdrop_juggernaut", 1, ::juggernautCrateThink );
    addCrateType( "airdrop_grnd", "osprey_gunner", 1, ::killstreakCrateThink );
    addCrateType( "airdrop_grnd", "emp", 1, ::killstreakCrateThink );
    addCrateType( "airdrop_sentry_minigun", "sentry", 100, ::killstreakCrateThink );
    addCrateType( "airdrop_juggernaut", "airdrop_juggernaut", 100, ::juggernautCrateThink );
    addCrateType( "airdrop_juggernaut_recon", "airdrop_juggernaut_recon", 100, ::juggernautCrateThink );
    addCrateType( "airdrop_trophy", "airdrop_trophy", 100, ::trophyCrateThink );
    addCrateType( "airdrop_trap", "airdrop_trap", 100, ::trapCrateThink );
    addCrateType( "littlebird_support", "littlebird_support", 100, ::killstreakCrateThink );
    addCrateType( "airdrop_remote_tank", "remote_tank", 100, ::killstreakCrateThink );

    foreach ( var_10, var_6 in level.crateTypes )
    {
        level.crateMaxVal[var_10] = 0;

        foreach ( var_9, var_8 in level.crateTypes[var_10] )
        {
            if ( !var_8 )
                continue;

            level.crateMaxVal[var_10] = level.crateMaxVal[var_10] + var_8;
            level.crateTypes[var_10][var_9] = level.crateMaxVal[var_10];
        }
    }

    var_11 = getentarray( "mp_tdm_spawn", "classname" );
    var_12 = undefined;

    foreach ( var_14 in var_11 )
    {
        if ( !isdefined( var_12 ) || var_14.origin[2] < var_12.origin[2] )
            var_12 = var_14;
    }

    level.lowSpawn = var_12;
}

addCrateType( var_0, var_1, var_2, var_3 )
{
    level.crateTypes[var_0][var_1] = var_2;
    level.crateFuncs[var_0][var_1] = var_3;
}

getRandomCrateType( var_0 )
{
    var_1 = randomint( level.crateMaxVal[var_0] );

    if ( isdefined( self.owner ) && self.owner maps\mp\_utility::_hasPerk( "specialty_luckycharm" ) )
        var_2 = 1;
    else
        var_2 = 0;

    var_3 = undefined;

    foreach ( var_6, var_5 in level.crateTypes[var_0] )
    {
        if ( !var_5 )
            continue;

        var_3 = var_6;

        if ( var_5 > var_1 )
        {
            if ( var_2 )
            {
                var_2 = 0;
                continue;
            }

            break;
        }
    }

    return var_3;
}

getCrateTypeForDropType( var_0 )
{
    switch ( var_0 )
    {
        case "airdrop_sentry_minigun":
            return "sentry";
        case "airdrop_predator_missile":
            return "predator_missile";
        case "airdrop_juggernaut":
            return "airdrop_juggernaut";
        case "airdrop_juggernaut_def":
            return "airdrop_juggernaut_def";
        case "airdrop_juggernaut_gl":
            return "airdrop_juggernaut_gl";
        case "airdrop_juggernaut_recon":
            return "airdrop_juggernaut_recon";
        case "airdrop_trap":
            return "airdrop_trap";
        case "airdrop_trophy":
            return "airdrop_trophy";
        case "airdrop_remote_tank":
            return "remote_tank";
        case "airdrop_grnd":
        case "airdrop_assault":
        case "airdrop_support":
        case "airdrop_mega":
        case "airdrop_escort":
        case "airdrop_grnd_mega":
        default:
            return getRandomCrateType( var_0 );
    }
}

drawLine( var_0, var_1, var_2 )
{
    var_3 = int( var_2 * 20 );

    for ( var_4 = 0; var_4 < var_3; var_4++ )
        wait 0.05;
}

tryUseAssaultAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_assault" );
}

tryUseSupportAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_support" );
}

tryUseAirdropPredatorMissile( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_predator_missile" );
}

tryUseAirdropSentryMinigun( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_sentry_minigun" );
}

tryUseJuggernautAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_juggernaut" );
}

tryUseJuggernautGLAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_juggernaut_gl" );
}

tryUseJuggernautReconAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_juggernaut_recon" );
}

tryUseJuggernautDefAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_juggernaut_def" );
}

tryUseTrophyAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_trophy" );
}

tryUseMegaAirdrop( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_mega" );
}

tryUseAirdropTrap( var_0, var_1 )
{
    if ( tryUseAirdrop( var_0, var_1, "airdrop_trap" ) )
    {
        if ( level.teamBased )
            thread maps\mp\_utility::leaderDialog( level.otherTeam[self.team] + "_enemy_airdrop_assault_inbound", level.otherTeam[self.team] );
        else
        {
            var_2[0] = self;
            thread maps\mp\_utility::leaderDialog( level.otherTeam[self.team] + "_enemy_airdrop_assault_inbound", undefined, undefined, var_2 );
        }

        return 1;
    }
    else
        return 0;
}

tryUseAirdropRemoteTank( var_0, var_1 )
{
    return tryUseAirdrop( var_0, var_1, "airdrop_remote_tank" );
}

tryUseAmmo( var_0 )
{
    if ( maps\mp\_utility::isJuggernaut() )
        return 0;
    else
    {
        refillAmmo( 1 );
        return 1;
    }
}

tryUseExplosiveAmmo( var_0 )
{
    if ( maps\mp\_utility::isJuggernaut() )
        return 0;
    else
    {
        refillAmmo( 0 );
        maps\mp\_utility::givePerk( "specialty_explosivebullets", 0 );
        return 1;
    }
}

tryUseLightArmor( var_0 )
{
    if ( maps\mp\_utility::isJuggernaut() )
        return 0;
    else
    {
        thread maps\mp\perks\_perkfunctions::giveLightArmor();
        return 1;
    }
}

tryUseAirdrop( var_0, var_1, var_2 )
{
    var_3 = undefined;

    if ( !isdefined( var_2 ) )
        var_2 = "airdrop_assault";

    var_4 = 1;

    if ( ( level.littleBirds.size >= 4 || level.fauxVehicleCount >= 4 ) && var_2 != "airdrop_mega" && !issubstr( tolower( var_2 ), "juggernaut" ) )
    {
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        return 0;
    }
    else if ( maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount + var_4 >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        return 0;
    }
    else if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }
    else if ( maps\mp\_utility::isUsingRemote() )
        return 0;
    else if ( !maps\mp\_utility::validateUseStreak() )
        return 0;

    if ( var_2 != "airdrop_mega" && !issubstr( tolower( var_2 ), "juggernaut" ) )
        thread watchDisconnect();

    if ( !issubstr( var_2, "juggernaut" ) )
        maps\mp\_utility::incrementFauxVehicleCount();

    var_3 = beginAirdropViaMarker( var_0, var_1, var_2 );

    if ( !isdefined( var_3 ) || !var_3 )
    {
        self notify( "markerDetermined" );
        maps\mp\_utility::decrementFauxVehicleCount();
        return 0;
    }

    if ( var_2 == "airdrop_mega" )
        thread maps\mp\_utility::teamPlayerCardSplash( "used_airdrop_mega", self );

    self notify( "markerDetermined" );
    maps\mp\_matchdata::logKillstreakEvent( var_2, self.origin );
    return 1;
}

watchDisconnect()
{
    self endon( "markerDetermined" );
    self waittill( "disconnect" );
    return;
}

beginAirdropViaMarker( var_0, var_1, var_2 )
{
    self notify( "beginAirdropViaMarker" );
    self endon( "beginAirdropViaMarker" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.threwAirDropMarker = undefined;
    self.threwairdropmarkerindex = undefined;
    thread watchAirDropWeaponChange( var_0, var_1, var_2 );
    thread watchAirDropMarkerUsage( var_0, var_1, var_2 );
    thread watchAirDropMarker( var_0, var_1, var_2 );
    var_3 = common_scripts\utility::waittill_any_return( "notAirDropWeapon", "markerDetermined" );

    if ( isdefined( var_3 ) && var_3 == "markerDetermined" )
        return 1;
    else if ( !isdefined( var_3 ) && isdefined( self.threwAirDropMarker ) )
        return 1;

    return 0;
}

watchAirDropWeaponChange( var_0, var_1, var_2 )
{
    level endon( "game_ended" );
    self notify( "watchAirDropWeaponChange" );
    self endon( "watchAirDropWeaponChange" );
    self endon( "disconnect" );
    self endon( "markerDetermined" );

    while ( maps\mp\_utility::isChangingWeapon() )
        wait 0.05;

    var_3 = self getcurrentweapon();

    if ( isAirdropMarker( var_3 ) )
        var_4 = var_3;
    else
        var_4 = undefined;

    while ( isAirdropMarker( var_3 ) )
    {
        self waittill( "weapon_change",  var_3  );

        if ( isAirdropMarker( var_3 ) )
            var_4 = var_3;
    }

    if ( isdefined( self.threwAirDropMarker ) )
    {
        var_5 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( self.pers["killstreaks"][self.threwairdropmarkerindex].streakName );
        self takeweapon( var_5 );
        self notify( "markerDetermined" );
    }
    else
        self notify( "notAirDropWeapon" );
}

watchAirDropMarkerUsage( var_0, var_1, var_2 )
{
    level endon( "game_ended" );
    self notify( "watchAirDropMarkerUsage" );
    self endon( "watchAirDropMarkerUsage" );
    self endon( "disconnect" );
    self endon( "markerDetermined" );

    for (;;)
    {
        self waittill( "grenade_pullback",  var_3  );

        if ( !isAirdropMarker( var_3 ) )
            continue;

        common_scripts\utility::_disableUsability();
        beginAirDropMarkerTracking();
    }
}

watchAirDropMarker( var_0, var_1, var_2 )
{
    level endon( "game_ended" );
    self notify( "watchAirDropMarker" );
    self endon( "watchAirDropMarker" );
    self endon( "disconnect" );
    self endon( "markerDetermined" );

    for (;;)
    {
        self waittill( "grenade_fire",  var_3, var_4  );

        if ( !isAirdropMarker( var_4 ) )
            continue;

        self.threwAirDropMarker = 1;
        self.threwairdropmarkerindex = self.killstreakIndexWeapon;
        var_3 thread airdropDetonateOnStuck();
        var_3.owner = self;
        var_3.weaponName = var_4;
        var_3 thread airDropMarkerActivate( var_2 );
    }
}

beginAirDropMarkerTracking()
{
    level endon( "game_ended" );
    self notify( "beginAirDropMarkerTracking" );
    self endon( "beginAirDropMarkerTracking" );
    self endon( "death" );
    self endon( "disconnect" );
    common_scripts\utility::waittill_any( "grenade_fire", "weapon_change" );
    common_scripts\utility::_enableUsability();
}

airDropMarkerActivate( var_0, var_1 )
{
    level endon( "game_ended" );
    self notify( "airDropMarkerActivate" );
    self endon( "airDropMarkerActivate" );
    self waittill( "explode",  var_2  );
    var_3 = self.owner;

    if ( !isdefined( var_3 ) )
        return;

    if ( var_3 maps\mp\_utility::isEMPed() )
        return;

    if ( var_3 maps\mp\_utility::isAirDenied() )
        return;

    if ( issubstr( tolower( var_0 ), "escort_airdrop" ) && isdefined( level.chopper ) )
        return;

    wait 0.05;

    if ( issubstr( tolower( var_0 ), "juggernaut" ) )
        level doC130FlyBy( var_3, var_2, randomfloat( 360 ), var_0 );
    else if ( issubstr( tolower( var_0 ), "escort_airdrop" ) )
        var_3 maps\mp\killstreaks\_escortairdrop::finishSupportEscortUsage( var_1, var_2, randomfloat( 360 ), "escort_airdrop" );
    else
        level doFlyBy( var_3, var_2, randomfloat( 360 ), var_0 );
}

initAirDropCrate()
{
    self.inUse = 0;
    self hide();

    if ( isdefined( self.target ) )
    {
        self.collision = getent( self.target, "targetname" );
        self.collision notsolid();
    }
    else
        self.collision = undefined;
}

deleteOnOwnerDeath( var_0 )
{
    wait 0.25;
    self linkto( var_0, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    var_0 waittill( "death" );
    self delete();
}

crateTeamModelUpdater()
{
    self endon( "death" );
    self hide();

    foreach ( var_1 in level.players )
    {
        if ( var_1.team != "spectator" )
            self showtoplayer( var_1 );
    }

    for (;;)
    {
        level waittill( "joined_team" );
        self hide();

        foreach ( var_1 in level.players )
        {
            if ( var_1.team != "spectator" )
                self showtoplayer( var_1 );
        }
    }
}

crateModelTeamUpdater( var_0 )
{
    self endon( "death" );
    self hide();

    foreach ( var_2 in level.players )
    {
        if ( var_2.team == var_0 )
            self showtoplayer( var_2 );
    }

    for (;;)
    {
        level waittill( "joined_team" );
        self hide();

        foreach ( var_2 in level.players )
        {
            if ( var_2.team == var_0 )
                self showtoplayer( var_2 );
        }
    }
}

crateModelPlayerUpdater( var_0, var_1 )
{
    self endon( "death" );
    self hide();

    foreach ( var_3 in level.players )
    {
        if ( var_1 && isdefined( var_0 ) && var_3 != var_0 )
            continue;

        if ( !var_1 && isdefined( var_0 ) && var_3 == var_0 )
            continue;

        self showtoplayer( var_3 );
    }

    for (;;)
    {
        level waittill( "joined_team" );
        self hide();

        foreach ( var_3 in level.players )
        {
            if ( var_1 && isdefined( var_0 ) && var_3 != var_0 )
                continue;

            if ( !var_1 && isdefined( var_0 ) && var_3 == var_0 )
                continue;

            self showtoplayer( var_3 );
        }
    }
}

crateUseTeamUpdater( var_0 )
{
    self endon( "death" );

    for (;;)
    {
        setUsableByTeam( var_0 );
        level waittill( "joined_team" );
    }
}

crateUseJuggernautUpdater()
{
    if ( !issubstr( self.crateType, "juggernaut" ) )
        return;

    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "juggernaut_equipped",  var_0  );
        self disableplayeruse( var_0 );
        thread crateUsePostJuggernautUpdater( var_0 );
    }
}

crateUsePostJuggernautUpdater( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    var_0 waittill( "death" );
    self enableplayeruse( var_0 );
}

createAirDropCrate( var_0, var_1, var_2, var_3 )
{
    var_4 = spawn( "script_model", var_3 );
    var_4.curProgress = 0;
    var_4.useTime = 0;
    var_4.useRate = 0;
    var_4.team = self.team;

    if ( isdefined( var_0 ) )
        var_4.owner = var_0;
    else
        var_4.owner = undefined;

    var_4.crateType = var_2;
    var_4.dropType = var_1;
    var_4.targetname = "care_package";
    var_4 setmodel( maps\mp\gametypes\_teams::getTeamCrateModel( var_4.team ) );
    var_4 thread crateTeamModelUpdater();
    var_5 = "com_plasticcase_friendly";

    if ( var_2 == "airdrop_trap" )
    {
        var_5 = "com_plasticcase_trap_friendly";
        var_4 thread trap_createBombSquadModel();
    }

    var_4.friendlyModel = spawn( "script_model", var_3 );
    var_4.friendlyModel setmodel( var_5 );
    var_4.enemyModel = spawn( "script_model", var_3 );
    var_4.enemyModel setmodel( "com_plasticcase_enemy" );
    var_4.friendlyModel thread deleteOnOwnerDeath( var_4 );

    if ( level.teamBased )
        var_4.friendlyModel thread crateModelTeamUpdater( var_4.team );
    else
        var_4.friendlyModel thread crateModelPlayerUpdater( var_0, 1 );

    var_4.enemyModel thread deleteOnOwnerDeath( var_4 );

    if ( level.teamBased )
        var_4.enemyModel thread crateModelTeamUpdater( level.otherTeam[var_4.team] );
    else
        var_4.enemyModel thread crateModelPlayerUpdater( var_0, 0 );

    var_4.inUse = 0;
    var_4 clonebrushmodeltoscriptmodel( level.airDropCrateCollision );
    var_4.killCamEnt = spawn( "script_model", var_4.origin + ( 0, 0, 300 ) );
    var_4.killCamEnt setscriptmoverkillcam( "explosive" );
    var_4.killCamEnt linkto( var_4 );
    level.numDropCrates++;
    var_4 thread dropCrateExistence();
    return var_4;
}

dropCrateExistence()
{
    level endon( "game_ended" );
    self waittill( "death" );
    level.numDropCrates--;
}

trap_createBombSquadModel()
{
    var_0 = spawn( "script_model", self.origin );
    var_0.angles = self.angles;
    var_0 hide();
    var_1 = level.otherTeam[self.team];
    var_0 thread maps\mp\gametypes\_weapons::bombSquadVisibilityUpdater( var_1, self.owner );
    var_0 setmodel( "com_plasticcase_trap_bombsquad" );
    var_0 linkto( self );
    var_0 setcontents( 0 );
    self waittill( "death" );
    var_0 delete();
}

crateSetupForUse( var_0, var_1, var_2 )
{
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( var_0 );
    self makeusable();
    self.mode = var_1;

    if ( level.teamBased || isdefined( self.owner ) )
    {
        var_3 = maps\mp\gametypes\_gameobjects::getNextObjID();
        objective_add( var_3, "invisible", ( 0, 0, 0 ) );
        objective_position( var_3, self.origin );
        objective_state( var_3, "active" );
        var_4 = "compass_objpoint_ammo_friendly";

        if ( var_1 == "trap" )
            var_4 = "compass_objpoint_trap_friendly";

        objective_icon( var_3, var_4 );

        if ( !level.teamBased && isdefined( self.owner ) )
            objective_playerteam( var_3, self.owner getentitynumber() );
        else
            objective_team( var_3, self.team );

        self.objIdFriendly = var_3;
    }

    var_3 = maps\mp\gametypes\_gameobjects::getNextObjID();
    objective_add( var_3, "invisible", ( 0, 0, 0 ) );
    objective_position( var_3, self.origin );
    objective_state( var_3, "active" );
    objective_icon( var_3, "compass_objpoint_ammo_enemy" );

    if ( !level.teamBased && isdefined( self.owner ) )
        objective_playerenemyteam( var_3, self.owner getentitynumber() );
    else
        objective_team( var_3, level.otherTeam[self.team] );

    self.objIdEnemy = var_3;

    if ( var_1 == "trap" )
        thread crateUseTeamUpdater( maps\mp\_utility::getOtherTeam( self.team ) );
    else
    {
        thread crateUseTeamUpdater();

        if ( issubstr( self.crateType, "juggernaut" ) )
        {
            foreach ( var_6 in level.players )
            {
                if ( var_6 maps\mp\_utility::isJuggernaut() )
                    thread crateUsePostJuggernautUpdater( var_6 );
            }
        }

        if ( level.teamBased )
            maps\mp\_entityheadicons::setHeadIcon( self.team, var_2, ( 0, 0, 24 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
        else if ( isdefined( self.owner ) )
            maps\mp\_entityheadicons::setHeadIcon( self.owner, var_2, ( 0, 0, 24 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
    }

    thread crateUseJuggernautUpdater();
}

setUsableByTeam( var_0 )
{
    foreach ( var_2 in level.players )
    {
        if ( issubstr( self.crateType, "juggernaut" ) && var_2 maps\mp\_utility::isJuggernaut() )
        {
            self disableplayeruse( var_2 );
            continue;
        }

        if ( !level.teamBased && self.mode == "trap" )
        {
            if ( isdefined( self.owner ) && var_2 == self.owner )
                self disableplayeruse( var_2 );
            else
                self enableplayeruse( var_2 );

            continue;
        }

        if ( !isdefined( var_0 ) || var_0 == var_2.team )
        {
            self enableplayeruse( var_2 );
            continue;
        }

        self disableplayeruse( var_2 );
    }
}

dropTheCrate( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    var_9 = [];
    self.owner endon( "disconnect" );

    if ( !isdefined( var_4 ) )
    {
        if ( isdefined( var_7 ) )
        {
            var_10 = undefined;
            var_11 = undefined;

            for ( var_12 = 0; var_12 < 100; var_12++ )
            {
                var_11 = getCrateTypeForDropType( var_1 );
                var_10 = 0;

                for ( var_13 = 0; var_13 < var_7.size; var_13++ )
                {
                    if ( var_11 == var_7[var_13] )
                    {
                        var_10 = 1;
                        break;
                    }
                }

                if ( var_10 == 0 )
                    break;
            }

            if ( var_10 == 1 )
                var_11 = getCrateTypeForDropType( var_1 );
        }
        else
            var_11 = getCrateTypeForDropType( var_1 );
    }
    else
        var_11 = var_4;

    if ( !isdefined( var_6 ) )
        var_6 = ( randomint( 5 ), randomint( 5 ), randomint( 5 ) );

    var_9 = createAirDropCrate( self.owner, var_1, var_11, var_5 );

    switch ( var_1 )
    {
        case "airdrop_juggernaut":
        case "airdrop_juggernaut_recon":
        case "airdrop_mega":
        case "nuke_drop":
            var_9 linkto( self, "tag_ground", ( 64, 32, -128 ), ( 0, 0, 0 ) );
            break;
        case "airdrop_osprey_gunner":
        case "airdrop_escort":
            var_9 linkto( self, var_8, ( 0, 0, 0 ), ( 0, 0, 0 ) );
            break;
        default:
            var_9 linkto( self, "tag_ground", ( 32, 0, 5 ), ( 0, 0, 0 ) );
            break;
    }

    var_9.angles = ( 0, 0, 0 );
    var_9 show();
    var_14 = self.veh_speed;
    thread waitForDropCrateMsg( var_9, var_6, var_1, var_11 );
    return var_11;
}

waitForDropCrateMsg( var_0, var_1, var_2, var_3 )
{
    self waittill( "drop_crate" );
    var_0 unlink();
    var_0 physicslaunchserver( ( 0, 0, 0 ), var_1 );
    var_0 thread physicsWaiter( var_2, var_3 );

    if ( isdefined( var_0.killCamEnt ) )
    {
        var_0.killCamEnt unlink();
        var_4 = bullettrace( var_0.origin, var_0.origin + ( 0, 0, -10000 ), 0, var_0 );
        var_5 = distance( var_0.origin, var_4["position"] );
        var_6 = var_5 / 800;
        var_0.killCamEnt moveto( var_4["position"] + ( 0, 0, 300 ), var_6 );
    }
}

physicsWaiter( var_0, var_1 )
{
    self waittill( "physics_finished" );
    self thread [[ level.crateFuncs[var_0][var_1] ]]( var_0 );
    level thread dropTimeOut( self, self.owner, var_1 );
    var_2 = getentarray( "trigger_hurt", "classname" );

    foreach ( var_4 in var_2 )
    {
        if ( self.friendlyModel istouching( var_4 ) )
        {
            deleteCrate();
            return;
        }
    }

    if ( abs( self.origin[2] - level.lowSpawn.origin[2] ) > 3000 )
        deleteCrate();
}

dropTimeOut( var_0, var_1, var_2 )
{
    level endon( "game_ended" );
    var_0 endon( "death" );

    if ( var_0.dropType == "nuke_drop" )
        return;

    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( 90.0 );

    while ( var_0.curProgress != 0 )
        wait 1;

    var_0 deleteCrate();
}

getPathStart( var_0, var_1 )
{
    var_2 = 100;
    var_3 = 15000;
    var_4 = ( 0, var_1, 0 );
    var_5 = var_0 + anglestoforward( var_4 ) * ( -1 * var_3 );
    var_5 += ( ( randomfloat( 2 ) - 1 ) * var_2, ( randomfloat( 2 ) - 1 ) * var_2, 0 );
    return var_5;
}

getPathEnd( var_0, var_1 )
{
    var_2 = 150;
    var_3 = 15000;
    var_4 = ( 0, var_1, 0 );
    var_5 = var_0 + anglestoforward( var_4 + ( 0, 90, 0 ) ) * var_3;
    var_5 += ( ( randomfloat( 2 ) - 1 ) * var_2, ( randomfloat( 2 ) - 1 ) * var_2, 0 );
    return var_5;
}

getFlyHeightOffset( var_0 )
{
    var_1 = 850;
    var_2 = getent( "airstrikeheight", "targetname" );

    if ( !isdefined( var_2 ) )
    {
        if ( isdefined( level.airstrikeHeightScale ) )
        {
            if ( level.airstrikeHeightScale > 2 )
            {
                var_1 = 1500;
                return var_1 * level.airstrikeHeightScale;
            }

            return var_1 * level.airstrikeHeightScale + 256 + var_0[2];
        }
        else
            return var_1 + var_0[2];
    }
    else
        return var_2.origin[2];
}

doFlyBy( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( !isdefined( var_0 ) )
        return;

    var_6 = getFlyHeightOffset( var_1 );

    if ( isdefined( var_4 ) )
        var_6 += var_4;

    foreach ( var_8 in level.littleBirds )
    {
        if ( isdefined( var_8.dropType ) )
            var_6 += 128;
    }

    var_10 = var_1 * ( 1, 1, 0 ) + ( 0, 0, var_6 );
    var_11 = getPathStart( var_10, var_2 );
    var_12 = getPathEnd( var_10, var_2 );
    var_10 += anglestoforward( ( 0, var_2, 0 ) ) * -50;
    var_13 = heliSetup( var_0, var_11, var_10 );
    var_13 endon( "death" );

    if ( !isdefined( var_5 ) )
        var_5 = undefined;

    var_13.dropType = var_3;
    var_13 setvehgoalpos( var_10, 1 );
    var_13 thread dropTheCrate( var_1, var_3, var_6, 0, var_5, var_11 );
    wait 2;
    var_13 vehicle_setspeed( 75, 40 );
    var_13 setyawspeed( 180, 180, 180, 0.3 );
    var_13 waittill( "goal" );
    wait 0.1;
    var_13 notify( "drop_crate" );
    var_13 setvehgoalpos( var_12, 1 );
    var_13 vehicle_setspeed( 300, 75 );
    var_13.leaving = 1;
    var_13 waittill( "goal" );
    var_13 notify( "leaving" );
    var_13 notify( "delete" );
    maps\mp\_utility::decrementFauxVehicleCount();
    var_13 delete();
}

doMegaFlyBy( var_0, var_1, var_2, var_3 )
{
    level thread doFlyBy( var_0, var_1, var_2, var_3, 0 );
    wait(randomintrange( 1, 2 ));
    level thread doFlyBy( var_0, var_1 + ( 128, 128, 0 ), var_2, var_3, 128 );
    wait(randomintrange( 1, 2 ));
    level thread doFlyBy( var_0, var_1 + ( 172, 256, 0 ), var_2, var_3, 256 );
    wait(randomintrange( 1, 2 ));
    level thread doFlyBy( var_0, var_1 + ( 64, 0, 0 ), var_2, var_3, 0 );
}

doC130FlyBy( var_0, var_1, var_2, var_3 )
{
    var_4 = 18000;
    var_5 = 3000;
    var_6 = vectortoyaw( var_1 - var_0.origin );
    var_7 = ( 0, var_6, 0 );
    var_8 = getFlyHeightOffset( var_1 );
    var_9 = var_1 + anglestoforward( var_7 ) * ( -1 * var_4 );
    var_9 = var_9 * ( 1, 1, 0 ) + ( 0, 0, var_8 );
    var_10 = var_1 + anglestoforward( var_7 ) * var_4;
    var_10 = var_10 * ( 1, 1, 0 ) + ( 0, 0, var_8 );
    var_11 = length( var_9 - var_10 );
    var_12 = var_11 / var_5;
    var_13 = c130Setup( var_0, var_9, var_10 );
    var_13.veh_speed = var_5;
    var_13.dropType = var_3;
    var_13 playloopsound( "veh_ac130_dist_loop" );
    var_13.angles = var_7;
    var_14 = anglestoforward( var_7 );
    var_13 moveto( var_10, var_12, 0, 0 );
    var_15 = distance2d( var_13.origin, var_1 );
    var_16 = 0;

    for (;;)
    {
        var_17 = distance2d( var_13.origin, var_1 );

        if ( var_17 < var_15 )
            var_15 = var_17;
        else if ( var_17 > var_15 )
            break;

        if ( var_17 < 320 )
            break;
        else if ( var_17 < 768 )
        {
            earthquake( 0.15, 1.5, var_1, 1500 );

            if ( !var_16 )
            {
                var_13 playsound( "veh_ac130_sonic_boom" );
                var_16 = 1;
            }
        }

        wait 0.05;
    }

    wait 0.05;
    var_18 = ( 0.25, 0, 0 );
    var_19[0] = var_13 thread dropTheCrate( var_1, var_3, var_8, 0, undefined, var_9, var_18 );
    wait 0.05;
    var_13 notify( "drop_crate" );
    var_20 = var_1 + anglestoforward( var_7 ) * ( var_4 * 1.5 );
    var_13 moveto( var_20, var_12 / 2, 0, 0 );
    wait 6;
    var_13 delete();
}

doMegaC130FlyBy( var_0, var_1, var_2, var_3, var_4 )
{
    var_5 = 24000;
    var_6 = 2000;
    var_7 = vectortoyaw( var_1 - var_0.origin );
    var_8 = ( 0, var_7, 0 );
    var_9 = anglestoforward( var_8 );

    if ( isdefined( var_4 ) )
        var_1 += var_9 * var_4;

    var_10 = getFlyHeightOffset( var_1 );
    var_11 = var_1 + anglestoforward( var_8 ) * ( -1 * var_5 );
    var_11 = var_11 * ( 1, 1, 0 ) + ( 0, 0, var_10 );
    var_12 = var_1 + anglestoforward( var_8 ) * var_5;
    var_12 = var_12 * ( 1, 1, 0 ) + ( 0, 0, var_10 );
    var_13 = length( var_11 - var_12 );
    var_14 = var_13 / var_6;
    var_15 = c130Setup( var_0, var_11, var_12 );
    var_15.veh_speed = var_6;
    var_15.dropType = var_3;
    var_15 playloopsound( "veh_ac130_dist_loop" );
    var_15.angles = var_8;
    var_9 = anglestoforward( var_8 );
    var_15 moveto( var_12, var_14, 0, 0 );
    var_16 = distance2d( var_15.origin, var_1 );
    var_17 = 0;

    for (;;)
    {
        var_18 = distance2d( var_15.origin, var_1 );

        if ( var_18 < var_16 )
            var_16 = var_18;
        else if ( var_18 > var_16 )
            break;

        if ( var_18 < 256 )
            break;
        else if ( var_18 < 768 )
        {
            earthquake( 0.15, 1.5, var_1, 1500 );

            if ( !var_17 )
            {
                var_15 playsound( "veh_ac130_sonic_boom" );
                var_17 = 1;
            }
        }

        wait 0.05;
    }

    wait 0.05;
    var_19[0] = var_15 thread dropTheCrate( var_1, var_3, var_10, 0, undefined, var_11 );
    wait 0.05;
    var_15 notify( "drop_crate" );
    wait 0.05;
    var_19[1] = var_15 thread dropTheCrate( var_1, var_3, var_10, 0, undefined, var_11, undefined, var_19 );
    wait 0.05;
    var_15 notify( "drop_crate" );
    wait 0.05;
    var_19[2] = var_15 thread dropTheCrate( var_1, var_3, var_10, 0, undefined, var_11, undefined, var_19 );
    wait 0.05;
    var_15 notify( "drop_crate" );
    wait 0.05;
    var_19[3] = var_15 thread dropTheCrate( var_1, var_3, var_10, 0, undefined, var_11, undefined, var_19 );
    wait 0.05;
    var_15 notify( "drop_crate" );
    wait 4;
    var_15 delete();
}

dropNuke( var_0, var_1, var_2 )
{
    var_3 = 24000;
    var_4 = 2000;
    var_5 = randomint( 360 );
    var_6 = ( 0, var_5, 0 );
    var_7 = getFlyHeightOffset( var_0 );
    var_8 = var_0 + anglestoforward( var_6 ) * ( -1 * var_3 );
    var_8 = var_8 * ( 1, 1, 0 ) + ( 0, 0, var_7 );
    var_9 = var_0 + anglestoforward( var_6 ) * var_3;
    var_9 = var_9 * ( 1, 1, 0 ) + ( 0, 0, var_7 );
    var_10 = length( var_8 - var_9 );
    var_11 = var_10 / var_4;
    var_12 = c130Setup( var_1, var_8, var_9 );
    var_12.veh_speed = var_4;
    var_12.dropType = var_2;
    var_12 playloopsound( "veh_ac130_dist_loop" );
    var_12.angles = var_6;
    var_13 = anglestoforward( var_6 );
    var_12 moveto( var_9, var_11, 0, 0 );
    var_14 = 0;
    var_15 = distance2d( var_12.origin, var_0 );

    for (;;)
    {
        var_16 = distance2d( var_12.origin, var_0 );

        if ( var_16 < var_15 )
            var_15 = var_16;
        else if ( var_16 > var_15 )
            break;

        if ( var_16 < 256 )
            break;
        else if ( var_16 < 768 )
        {
            earthquake( 0.15, 1.5, var_0, 1500 );

            if ( !var_14 )
            {
                var_12 playsound( "veh_ac130_sonic_boom" );
                var_14 = 1;
            }
        }

        wait 0.05;
    }

    var_12 thread dropTheCrate( var_0, var_2, var_7, 0, "nuke", var_8 );
    wait 0.05;
    var_12 notify( "drop_crate" );
    wait 4;
    var_12 delete();
}

stopLoopAfter( var_0 )
{
    self endon( "death" );
    wait(var_0);
    self stoploopsound();
}

playloopOnEnt( var_0 )
{
    var_1 = spawn( "script_origin", ( 0, 0, 0 ) );
    var_1 hide();
    var_1 endon( "death" );
    thread common_scripts\utility::delete_on_death( var_1 );
    var_1.origin = self.origin;
    var_1.angles = self.angles;
    var_1 linkto( self );
    var_1 playloopsound( var_0 );
    self waittill( "stop sound" + var_0 );
    var_1 stoploopsound( var_0 );
    var_1 delete();
}

c130Setup( var_0, var_1, var_2 )
{
    var_3 = vectortoangles( var_2 - var_1 );
    var_4 = spawnplane( var_0, "script_model", var_1, "compass_objpoint_c130_friendly", "compass_objpoint_c130_enemy" );
    var_4 setmodel( "vehicle_ac130_low_mp" );

    if ( !isdefined( var_4 ) )
        return;

    var_4.owner = var_0;
    var_4.team = var_0.team;
    level.c130 = var_4;
    return var_4;
}

heliSetup( var_0, var_1, var_2 )
{
    var_3 = vectortoangles( var_2 - var_1 );
    var_4 = spawnhelicopter( var_0, var_1, var_3, "littlebird_mp", "vehicle_little_bird_armed" );

    if ( !isdefined( var_4 ) )
        return;

    var_4 maps\mp\killstreaks\_helicopter::addToLittleBirdList();
    var_4 thread maps\mp\killstreaks\_helicopter::removeFromLittleBirdListOnDeath();
    var_4.health = 999999;
    var_4.maxHealth = 500;
    var_4.damagetaken = 0;
    var_4 setcandamage( 1 );
    var_4.owner = var_0;
    var_4.team = var_0.team;
    var_4.isAirdrop = 1;
    var_4 thread watchTimeOut();
    var_4 thread heli_existence();
    var_4 thread heliDestroyed();
    var_4 thread heli_handleDamage();
    var_4 setmaxpitchroll( 45, 85 );
    var_4 vehicle_setspeed( 250, 175 );
    var_4.heliType = "airdrop";
    var_4.specialDamageCallback = ::Callback_VehicleDamage;
    return var_4;
}

watchTimeOut()
{
    level endon( "game_ended" );
    self endon( "leaving" );
    self endon( "helicopter_gone" );
    self endon( "death" );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( 25.0 );
    self notify( "death" );
}

heli_existence()
{
    common_scripts\utility::waittill_any( "crashing", "leaving" );
    self notify( "helicopter_gone" );
}

heli_handleDamage()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( isdefined( self.specialDamageCallback ) )
            self [[ self.specialDamageCallback ]]( undefined, var_1, var_0, var_8, var_4, var_9, var_3, var_2, undefined, undefined, var_5, var_7 );
    }
}

Callback_VehicleDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 )
{
    if ( isdefined( self.alreadyDead ) && self.alreadyDead )
        return;

    if ( !isdefined( var_1 ) || var_1 == self )
        return;

    if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_1 ) )
        return;

    if ( isdefined( var_3 ) && var_3 & level.iDFLAGS_PENETRATION )
        self.wasDamagedFromBulletPenetration = 1;

    self.wasDamaged = 1;
    var_12 = var_2;

    if ( isplayer( var_1 ) )
    {
        var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "helicopter" );

        if ( var_4 == "MOD_RIFLE_BULLET" || var_4 == "MOD_PISTOL_BULLET" )
        {
            if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                var_12 += var_2 * level.armorPiercingMod;
        }
    }

    if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
        var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "helicopter" );

    if ( isdefined( var_5 ) )
    {
        switch ( var_5 )
        {
            case "ac130_105mm_mp":
            case "ac130_40mm_mp":
            case "remotemissile_projectile_mp":
            case "stinger_mp":
            case "javelin_mp":
            case "remote_mortar_missile_mp":
                self.largeProjectileDamage = 1;
                var_12 = self.maxHealth + 1;
                break;
            case "sam_projectile_mp":
                self.largeProjectileDamage = 1;
                var_12 = self.maxHealth * 0.5;
                break;
            case "emp_grenade_mp":
                self.largeProjectileDamage = 0;
                var_12 = self.maxHealth + 1;
                break;
        }

        maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_5, self );
    }

    self.damagetaken = self.damagetaken + var_12;

    if ( self.damagetaken >= self.maxHealth )
    {
        if ( isplayer( var_1 ) && ( !isdefined( self.owner ) || var_1 != self.owner ) )
        {
            self.alreadyDead = 1;
            var_1 notify( "destroyed_helicopter" );
            var_1 notify( "destroyed_killstreak",  var_5  );
            thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_helicopter", var_1 );
            var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 300, var_5, var_4 );
            var_1 thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DESTROYED_HELICOPTER" );
            thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, var_1, var_2, var_4, var_5 );
        }

        self notify( "death" );
    }
}

heliDestroyed()
{
    self endon( "leaving" );
    self endon( "helicopter_gone" );
    self waittill( "death" );

    if ( !isdefined( self ) )
        return;

    self vehicle_setspeed( 25, 5 );
    thread lbSpin( randomintrange( 180, 220 ) );
    wait(randomfloatrange( 0.5, 1.5 ));
    self notify( "drop_crate" );
    lbExplode();
}

lbExplode()
{
    var_0 = self.origin + ( 0, 0, 1 ) - self.origin;
    playfx( level.chopper_fx["explode"]["death"]["cobra"], self.origin, var_0 );
    self playsound( "cobra_helicopter_crash" );
    self notify( "explode" );
    maps\mp\_utility::decrementFauxVehicleCount();
    self delete();
}

lbSpin( var_0 )
{
    self endon( "explode" );
    playfxontag( level.chopper_fx["explode"]["medium"], self, "tail_rotor_jnt" );
    playfxontag( level.chopper_fx["fire"]["trail"]["medium"], self, "tail_rotor_jnt" );
    self setyawspeed( var_0, var_0, var_0 );

    while ( isdefined( self ) )
    {
        self settargetyaw( self.angles[1] + var_0 * 0.9 );
        wait 1;
    }
}

nukeCaptureThink()
{
    while ( isdefined( self ) )
    {
        self waittill( "trigger",  var_0  );

        if ( !var_0 isonground() )
            continue;

        if ( !useHoldThink( var_0 ) )
            continue;

        self notify( "captured",  var_0  );
    }
}

crateOtherCaptureThink( var_0 )
{
    while ( isdefined( self ) )
    {
        self waittill( "trigger",  var_1  );

        if ( isdefined( self.owner ) && var_1 == self.owner )
            continue;

        if ( !validateOpenConditions( var_1 ) )
            continue;

        var_1.isCapturingCrate = 1;
        var_2 = createUseEnt();
        var_3 = var_2 useHoldThink( var_1, undefined, var_0 );

        if ( isdefined( var_2 ) )
            var_2 delete();

        if ( !var_3 )
        {
            var_1.isCapturingCrate = 0;
            continue;
        }

        var_1.isCapturingCrate = 0;
        self notify( "captured",  var_1  );
    }
}

crateOwnerCaptureThink( var_0 )
{
    while ( isdefined( self ) )
    {
        self waittill( "trigger",  var_1  );

        if ( isdefined( self.owner ) && var_1 != self.owner )
            continue;

        if ( !validateOpenConditions( var_1 ) )
            continue;

        var_1.isCapturingCrate = 1;

        if ( !useHoldThink( var_1, 500, var_0 ) )
        {
            var_1.isCapturingCrate = 0;
            continue;
        }

        var_1.isCapturingCrate = 0;
        self notify( "captured",  var_1  );
    }
}

validateOpenConditions( var_0 )
{
    if ( ( self.crateType == "airdrop_juggernaut_def" || self.crateType == "airdrop_juggernaut" ) && var_0 maps\mp\_utility::isJuggernaut() )
        return 0;

    var_1 = var_0 getcurrentweapon();

    if ( maps\mp\_utility::isKillstreakWeapon( var_1 ) && !issubstr( var_1, "jugg_mp" ) )
        return 0;

    if ( isdefined( var_0.changingWeapon ) && maps\mp\_utility::isKillstreakWeapon( var_0.changingWeapon ) && !issubstr( var_0.changingWeapon, "jugg_mp" ) )
        return 0;

    return 1;
}

killstreakCrateThink( var_0 )
{
    self endon( "death" );

    if ( isdefined( game["strings"][self.crateType + "_hint"] ) )
        var_1 = game["strings"][self.crateType + "_hint"];
    else
        var_1 = &"PLATFORM_GET_KILLSTREAK";

    crateSetupForUse( var_1, "all", maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( self.crateType ) );
    thread crateOtherCaptureThink();
    thread crateOwnerCaptureThink();

    for (;;)
    {
        self waittill( "captured",  var_2  );

        if ( isdefined( self.owner ) && var_2 != self.owner )
        {
            if ( !level.teamBased || var_2.team != self.team )
            {
                switch ( var_0 )
                {
                    case "airdrop_assault":
                    case "airdrop_support":
                    case "airdrop_osprey_gunner":
                    case "airdrop_escort":
                        var_2 thread maps\mp\gametypes\_missions::genericChallenge( "hijacker_airdrop" );
                        var_2 thread hijackNotify( self, "airdrop" );
                        break;
                    case "airdrop_sentry_minigun":
                        var_2 thread maps\mp\gametypes\_missions::genericChallenge( "hijacker_airdrop" );
                        var_2 thread hijackNotify( self, "sentry" );
                        break;
                    case "airdrop_remote_tank":
                        var_2 thread maps\mp\gametypes\_missions::genericChallenge( "hijacker_airdrop" );
                        var_2 thread hijackNotify( self, "remote_tank" );
                        break;
                    case "airdrop_mega":
                        var_2 thread maps\mp\gametypes\_missions::genericChallenge( "hijacker_airdrop_mega" );
                        var_2 thread hijackNotify( self, "emergency_airdrop" );
                        break;
                }
            }
            else
            {
                self.owner thread maps\mp\gametypes\_rank::giveRankXP( "killstreak_giveaway", int( maps\mp\killstreaks\_killstreaks::getStreakCost( self.crateType ) / 10 * 50 ) );
                self.owner thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "sharepackage", int( maps\mp\killstreaks\_killstreaks::getStreakCost( self.crateType ) / 10 * 50 ) );
            }
        }

        var_2 playlocalsound( "ammo_crate_use" );
        var_2 thread maps\mp\killstreaks\_killstreaks::giveKillstreak( self.crateType, 0, 0, self.owner );
        deleteCrate();
    }
}

nukeCrateThink( var_0 )
{
    self endon( "death" );
    crateSetupForUse( &"PLATFORM_CALL_NUKE", "nukeDrop", maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( self.crateType ) );
    thread nukeCaptureThink();

    for (;;)
    {
        self waittill( "captured",  var_1  );
        var_1 thread [[ level.killstreakFuncs[self.crateType] ]]( level.gtnw );
        level notify( "nukeCaptured",  var_1  );

        if ( isdefined( level.gtnw ) && level.gtnw )
            var_1.capturedNuke = 1;

        var_1 playlocalsound( "ammo_crate_use" );
        deleteCrate();
    }
}

trophyCrateThink( var_0 )
{
    self endon( "death" );
    crateSetupForUse( game["strings"]["trophy_hint"], "all", maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( self.crateType ) );
    thread crateOtherCaptureThink();
    thread crateOwnerCaptureThink();

    for (;;)
    {
        self waittill( "captured",  var_1  );

        if ( isdefined( self.owner ) && var_1 != self.owner )
        {
            if ( !level.teamBased || var_1.team != self.team )
                var_1 thread hijackNotify( self, "trophy" );
            else
            {
                self.owner thread maps\mp\gametypes\_rank::giveRankXP( "killstreak_giveaway", int( maps\mp\killstreaks\_killstreaks::getStreakCost( "airdrop_trophy" ) / 10 ) * 50 );
                self.owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( "giveaway_trophy", var_1 );
            }
        }

        var_1 playlocalsound( "ammo_crate_use" );
        var_1 thread giveLocalTrophy( var_0 );
        deleteCrate();
    }
}

juggernautCrateThink( var_0 )
{
    self endon( "death" );
    crateSetupForUse( game["strings"]["juggernaut_hint"], "all", maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( self.crateType ) );
    thread crateOtherCaptureThink();
    thread crateOwnerCaptureThink();

    for (;;)
    {
        self waittill( "captured",  var_1  );

        if ( isdefined( self.owner ) && var_1 != self.owner )
        {
            if ( !level.teamBased || var_1.team != self.team )
                var_1 thread hijackNotify( self, "juggernaut" );
            else
            {
                self.owner thread maps\mp\gametypes\_rank::giveRankXP( "killstreak_giveaway", int( maps\mp\killstreaks\_killstreaks::getStreakCost( self.crateType ) / 10 ) * 50 );
                self.owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( "giveaway_juggernaut", var_1 );
            }
        }

        var_1 playlocalsound( "ammo_crate_use" );
        var_2 = "juggernaut";

        switch ( self.crateType )
        {
            case "airdrop_juggernaut":
                var_2 = "juggernaut";
                break;
            case "airdrop_juggernaut_recon":
                var_2 = "juggernaut_recon";
                break;
        }

        var_1 thread maps\mp\killstreaks\_juggernaut::giveJuggernaut( var_2 );
        deleteCrate();
    }
}

sentryCrateThink( var_0 )
{
    self endon( "death" );
    crateSetupForUse( game["strings"]["sentry_hint"], "all", maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( self.crateType ) );
    thread crateOtherCaptureThink();
    thread crateOwnerCaptureThink();

    for (;;)
    {
        self waittill( "captured",  var_1  );

        if ( isdefined( self.owner ) && var_1 != self.owner )
        {
            if ( !level.teamBased || var_1.team != self.team )
            {
                if ( issubstr( var_0, "airdrop_sentry" ) )
                    var_1 thread hijackNotify( self, "sentry" );
                else
                    var_1 thread hijackNotify( self, "emergency_airdrop" );
            }
            else
            {
                self.owner thread maps\mp\gametypes\_rank::giveRankXP( "killstreak_giveaway", int( maps\mp\killstreaks\_killstreaks::getStreakCost( "sentry" ) / 10 ) * 50 );
                self.owner maps\mp\gametypes\_hud_message::playerCardSplashNotify( "giveaway_sentry", var_1 );
            }
        }

        var_1 playlocalsound( "ammo_crate_use" );
        var_1 thread sentryUseTracker();
        deleteCrate();
    }
}

trapNullFunc()
{

}

trapCrateThink( var_0 )
{
    self endon( "death" );
    var_1 = getRandomCrateType( "airdrop_trapcontents" );
    crateSetupForUse( game["strings"][var_1 + "_hint"], "trap", "none" );
    self.bomb = spawn( "script_model", self.origin );
    var_2 = bullettrace( self.bomb.origin, self.bomb.origin + ( 100, 100, 128 ), 0, self.bomb );
    self.bomb.killCamEnt = spawn( "script_model", var_2["position"] );
    self.bomb.killCamEnt setscriptmoverkillcam( "explosive" );
    thread crateOtherCaptureThink();

    for (;;)
    {
        self waittill( "captured",  var_3  );
        var_3 thread detonateTrap( self.bomb, self, self.owner );
    }
}

detonateTrap( var_0, var_1, var_2 )
{
    var_1 endon( "death" );
    var_0 rotatevelocity( ( 0, 300, 0 ), 3 );
    var_0 setmodel( "prop_suitcase_bomb" );
    var_3 = var_1.origin;
    thread common_scripts\utility::play_sound_in_space( "boobytrap_crate_lock", var_3 );
    wait 1.0;
    var_4 = var_3 + ( 0, 0, 1 ) - var_3;
    playfx( level.chopper_fx["explode"]["death"]["cobra"], var_3, var_4 );
    thread common_scripts\utility::play_sound_in_space( "cobra_helicopter_crash", var_3 );

    if ( isdefined( var_2 ) )
        var_0 radiusdamage( var_3, 400, 200, 50, var_2, "MOD_EXPLOSIVE", "airdrop_trap_explosive_mp" );
    else
        var_0 radiusdamage( var_3, 400, 200, 50, undefined, "MOD_EXPLOSIVE", "airdrop_trap_explosive_mp" );

    var_1 deleteCrate();
}

deleteCrate()
{
    if ( isdefined( self.objIdFriendly ) )
        maps\mp\_utility::_objective_delete( self.objIdFriendly );

    if ( isdefined( self.objIdEnemy ) )
        maps\mp\_utility::_objective_delete( self.objIdEnemy );

    if ( isdefined( self.bomb ) && isdefined( self.bomb.killCamEnt ) )
        self.bomb.killCamEnt delete();

    if ( isdefined( self.bomb ) )
        self.bomb delete();

    if ( isdefined( self.killCamEnt ) )
        self.killCamEnt delete();

    self delete();
}

sentryUseTracker()
{
    if ( !maps\mp\killstreaks\_autosentry::giveSentry( "sentry_minigun" ) )
        maps\mp\killstreaks\_killstreaks::giveKillstreak( "sentry" );
}

giveLocalTrophy( var_0 )
{
    self.activeTrophy = 1;
    self.trophyAmmo = 6;
    thread personalTrophyActive();
}

hijackNotify( var_0, var_1 )
{
    self notify( "hijacker",  var_1, var_0.owner  );
}

refillAmmo( var_0 )
{
    var_1 = self getweaponslistall();

    if ( var_0 )
    {
        if ( maps\mp\_utility::_hasPerk( "specialty_tacticalinsertion" ) && self getammocount( "flare_mp" ) < 1 )
            maps\mp\_utility::givePerk( "specialty_tacticalinsertion", 0 );

        if ( maps\mp\_utility::_hasPerk( "specialty_scrambler" ) && self getammocount( "scrambler_mp" ) < 1 )
            maps\mp\_utility::givePerk( "specialty_scrambler", 0 );

        if ( maps\mp\_utility::_hasPerk( "specialty_portable_radar" ) && self getammocount( "portable_radar_mp" ) < 1 )
            maps\mp\_utility::givePerk( "specialty_portable_radar", 0 );
    }

    foreach ( var_3 in var_1 )
    {
        if ( issubstr( var_3, "grenade" ) || getsubstr( var_3, 0, 2 ) == "gl" )
        {
            if ( !var_0 || self getammocount( var_3 ) >= 1 )
                continue;
        }

        self givemaxammo( var_3 );
    }
}

useHoldThink( var_0, var_1, var_2 )
{
    var_0 playerlinkto( self );
    var_0 playerlinkedoffsetenable();
    var_0 common_scripts\utility::_disableWeapon();
    self.curProgress = 0;
    self.inUse = 1;
    self.useRate = 0;

    if ( isdefined( var_1 ) )
        self.useTime = var_1;
    else
        self.useTime = 3000;

    var_0 thread personalUseBar( self, var_2 );
    var_3 = useHoldThinkLoop( var_0 );

    if ( isalive( var_0 ) )
    {
        var_0 common_scripts\utility::_enableWeapon();
        var_0 unlink();
    }

    if ( !isdefined( self ) )
        return 0;

    self.inUse = 0;
    self.curProgress = 0;
    return var_3;
}

personalUseBar( var_0, var_1 )
{
    self endon( "disconnect" );
    var_2 = maps\mp\gametypes\_hud_util::createPrimaryProgressBar( 0, 25 );
    var_3 = maps\mp\gametypes\_hud_util::createPrimaryProgressBarText( 0, 25 );

    if ( !isdefined( var_1 ) )
        var_1 = &"MP_CAPTURING_CRATE";

    var_3 settext( var_1 );
    var_4 = -1;

    while ( maps\mp\_utility::isReallyAlive( self ) && isdefined( var_0 ) && var_0.inUse && !level.gameEnded )
    {
        if ( var_4 != var_0.useRate )
        {
            if ( var_0.curProgress > var_0.useTime )
                var_0.curProgress = var_0.useTime;

            var_2 maps\mp\gametypes\_hud_util::updateBar( var_0.curProgress / var_0.useTime, 1000 / var_0.useTime * var_0.useRate );

            if ( !var_0.useRate )
            {
                var_2 maps\mp\gametypes\_hud_util::hideElem();
                var_3 maps\mp\gametypes\_hud_util::hideElem();
            }
            else
            {
                var_2 maps\mp\gametypes\_hud_util::showElem();
                var_3 maps\mp\gametypes\_hud_util::showElem();
            }
        }

        var_4 = var_0.useRate;
        wait 0.05;
    }

    var_2 maps\mp\gametypes\_hud_util::destroyElem();
    var_3 maps\mp\gametypes\_hud_util::destroyElem();
}

useHoldThinkLoop( var_0 )
{
    while ( !level.gameEnded && isdefined( self ) && maps\mp\_utility::isReallyAlive( var_0 ) && var_0 usebuttonpressed() && self.curProgress < self.useTime )
    {
        self.curProgress = self.curProgress + 50 * self.useRate;

        if ( isdefined( self.objectiveScaler ) )
            self.useRate = 1 * self.objectiveScaler;
        else
            self.useRate = 1;

        if ( self.curProgress >= self.useTime )
            return maps\mp\_utility::isReallyAlive( var_0 );

        wait 0.05;
    }

    return 0;
}

isAirdropMarker( var_0 )
{
    switch ( var_0 )
    {
        case "airdrop_marker_mp":
        case "airdrop_mega_marker_mp":
        case "airdrop_sentry_marker_mp":
        case "airdrop_juggernaut_mp":
        case "airdrop_juggernaut_def_mp":
        case "airdrop_tank_marker_mp":
        case "airdrop_trap_marker_mp":
        case "airdrop_escort_marker_mp":
            return 1;
        default:
            return 0;
    }
}

createUseEnt()
{
    var_0 = spawn( "script_origin", self.origin );
    var_0.curProgress = 0;
    var_0.useTime = 0;
    var_0.useRate = 3000;
    var_0.inUse = 0;
    var_0 thread deleteUseEnt( self );
    return var_0;
}

deleteUseEnt( var_0 )
{
    self endon( "death" );
    var_0 waittill( "death" );
    self delete();
}

airdropDetonateOnStuck()
{
    self endon( "death" );
    self waittill( "missile_stuck" );
    self detonate();
}

projectileExplode( var_0 )
{
    self endon( "death" );
    var_1 = var_0.origin;
    var_2 = var_0.model;
    var_3 = var_0.angles;
    var_0 delete();
    playfx( level.mine_explode, var_1, anglestoforward( var_3 ), anglestoup( var_3 ) );
    radiusdamage( var_1, 65, 75, 10, self );
}

personalTrophyActive()
{
    self endon( "disconnect" );
    self endon( "death" );
    var_0 = self.origin;

    for (;;)
    {
        if ( !isdefined( level.grenades ) || level.grenades.size < 1 )
        {
            wait 0.05;
            continue;
        }

        var_1 = maps\mp\_utility::combineArrays( level.grenades, level.missiles );

        foreach ( var_3 in var_1 )
        {
            wait 0.05;

            if ( !isdefined( var_3 ) )
                continue;

            if ( var_3 == self )
                continue;

            if ( isdefined( var_3.weaponName ) && var_3.weaponName == "trophy_mp" )
                continue;

            if ( var_3.model == "weapon_parabolic_knife" )
                continue;

            if ( !isdefined( var_3.owner ) )
                var_3.owner = getmissileowner( var_3 );

            if ( isdefined( var_3.owner ) && level.teamBased && var_3.owner.team == self.team )
                continue;

            var_4 = distancesquared( var_3.origin, self.origin );

            if ( var_4 < 147456 )
            {
                if ( bullettracepassed( var_3.origin, self.origin, 0, self ) )
                {
                    playfx( level.sentry_fire, self.origin + ( 0, 0, 32 ), var_3.origin - self.origin, anglestoup( self.angles ) );
                    thread projectileExplode( var_3 );
                    self.trophyAmmo--;

                    if ( self.trophyAmmo <= 0 )
                        return;
                }
            }
        }
    }
}
