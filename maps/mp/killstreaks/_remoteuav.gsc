// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precachemodel( "vehicle_remote_uav" );
    precachemodel( "test_vehicle_little_bird_toy_placement" );
    precachemodel( "test_vehicle_little_bird_toy_placement_failed" );

    if ( level.console )
        precachevehicle( "remote_uav_mp" );
    else
        precachevehicle( "remote_uav_mp_pc" );

    precacheitem( "uav_remote_mp" );
    precacheitem( "killstreak_remote_uav_mp" );
    precacheshader( "veh_hud_target" );
    precacheshader( "veh_hud_target_marked" );
    precacheshader( "veh_hud_target_unmarked" );
    precacheshader( "compassping_sentry_enemy" );
    precacheshader( "compassping_enemy_uav" );
    precacheshader( "hud_fofbox_hostile_vehicle" );
    precacherumble( "damage_light" );
    precachestring( &"MP_REMOTE_UAV_PLACE" );
    precachestring( &"MP_REMOTE_UAV_CANNOT_PLACE" );
    precachestring( &"SPLASHES_DESTROYED_REMOTE_UAV" );
    precachestring( &"SPLASHES_MARKED_BY_REMOTE_UAV" );
    precachestring( &"SPLASHES_REMOTE_UAV_MARKED" );
    precachestring( &"SPLASHES_TURRET_MARKED_BY_REMOTE_UAV" );
    precachestring( &"SPLASHES_REMOTE_UAV_ASSIST" );
    level.RemoteUAV_fx["hit"] = loadfx( "impacts/large_metal_painted_hit" );
    level.RemoteUAV_fx["smoke"] = loadfx( "smoke/remote_heli_damage_smoke_runner" );
    level.RemoteUAV_fx["explode"] = loadfx( "explosions/bouncing_betty_explosion" );
    level.RemoteUAV_fx["missile_explode"] = loadfx( "explosions/stinger_explosion" );
    level.RemoteUAV_dialog["launch"][0] = "ac130_plt_yeahcleared";
    level.RemoteUAV_dialog["launch"][1] = "ac130_plt_rollinin";
    level.RemoteUAV_dialog["launch"][2] = "ac130_plt_scanrange";
    level.RemoteUAV_dialog["out_of_range"][0] = "ac130_plt_cleanup";
    level.RemoteUAV_dialog["out_of_range"][1] = "ac130_plt_targetreset";
    level.RemoteUAV_dialog["track"][0] = "ac130_fco_moreenemy";
    level.RemoteUAV_dialog["track"][1] = "ac130_fco_getthatguy";
    level.RemoteUAV_dialog["track"][2] = "ac130_fco_guymovin";
    level.RemoteUAV_dialog["track"][3] = "ac130_fco_getperson";
    level.RemoteUAV_dialog["track"][4] = "ac130_fco_guyrunnin";
    level.RemoteUAV_dialog["track"][5] = "ac130_fco_gotarunner";
    level.RemoteUAV_dialog["track"][6] = "ac130_fco_backonthose";
    level.RemoteUAV_dialog["track"][7] = "ac130_fco_gonnagethim";
    level.RemoteUAV_dialog["track"][8] = "ac130_fco_personnelthere";
    level.RemoteUAV_dialog["track"][9] = "ac130_fco_rightthere";
    level.RemoteUAV_dialog["track"][10] = "ac130_fco_tracking";
    level.RemoteUAV_dialog["tag"][0] = "ac130_fco_nice";
    level.RemoteUAV_dialog["tag"][1] = "ac130_fco_yougothim";
    level.RemoteUAV_dialog["tag"][2] = "ac130_fco_yougothim2";
    level.RemoteUAV_dialog["tag"][3] = "ac130_fco_okyougothim";
    level.RemoteUAV_dialog["assist"][0] = "ac130_fco_goodkill";
    level.RemoteUAV_dialog["assist"][1] = "ac130_fco_thatsahit";
    level.RemoteUAV_dialog["assist"][2] = "ac130_fco_directhit";
    level.RemoteUAV_dialog["assist"][3] = "ac130_fco_rightontarget";
    level.RemoteUAV_lastDialogTime = 0;
    level.RemoteUAV_noDeployZones = getentarray( "no_vehicles", "targetname" );
    level.killstreakFuncs["remote_uav"] = ::useRemoteUAV;
    level.remote_uav = [];
}

useRemoteUAV( var_0 )
{
    return tryUseRemoteUAV( var_0, "remote_uav" );
}

teamHasRemoteUAV( var_0 )
{
    if ( level.gameType == "dm" )
    {
        if ( isdefined( level.remote_uav[var_0] ) || isdefined( level.remote_uav[level.otherTeam[var_0]] ) )
            return 1;
        else
            return 0;
    }
    else if ( isdefined( level.remote_uav[var_0] ) )
        return 1;
    else
        return 0;
}

tryUseRemoteUAV( var_0, var_1 )
{
    common_scripts\utility::_disableUsability();

    if ( maps\mp\_utility::isUsingRemote() || self isusingturret() || isdefined( level.nukeIncoming ) )
    {
        common_scripts\utility::_enableUsability();
        return 0;
    }

    var_2 = 1;

    if ( teamHasRemoteUAV( self.team ) || level.littleBirds.size >= 4 )
    {
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        common_scripts\utility::_enableUsability();
        return 0;
    }
    else if ( maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount + var_2 >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        common_scripts\utility::_enableUsability();
        return 0;
    }

    self setplayerdata( "reconDroneState", "staticAlpha", 0 );
    self setplayerdata( "reconDroneState", "incomingMissile", 0 );
    maps\mp\_utility::incrementFauxVehicleCount();
    var_3 = giveCarryRemoteUAV( var_0, var_1 );

    if ( var_3 )
    {
        maps\mp\_matchdata::logKillstreakEvent( var_1, self.origin );
        thread maps\mp\_utility::teamPlayerCardSplash( "used_remote_uav", self );
    }
    else
        maps\mp\_utility::decrementFauxVehicleCount();

    self.isCarrying = 0;
    return var_3;
}

giveCarryRemoteUAV( var_0, var_1 )
{
    var_2 = createCarryRemoteUAV( var_1, self );
    self takeweapon( "killstreak_uav_mp" );
    maps\mp\_utility::_giveWeapon( "killstreak_remote_uav_mp" );
    self switchtoweaponimmediate( "killstreak_remote_uav_mp" );
    setCarryingRemoteUAV( var_2 );

    if ( isalive( self ) && isdefined( var_2 ) )
    {
        var_3 = var_2.origin;
        var_4 = self.angles;
        var_2.carriedRemoteUAV delete();
        var_2 delete();
        var_5 = startRemoteUAV( var_0, var_1, var_3, var_4 );
    }
    else
    {
        var_5 = 0;

        if ( isalive( self ) )
        {
            self takeweapon( "killstreak_remote_uav_mp" );
            maps\mp\_utility::_giveWeapon( "killstreak_uav_mp" );
        }
    }

    return var_5;
}

createCarryRemoteUAV( var_0, var_1 )
{
    var_2 = var_1.origin + anglestoforward( var_1.angles ) * 4 + anglestoup( var_1.angles ) * 50;
    var_3 = spawnturret( "misc_turret", var_2, "sentry_minigun_mp" );
    var_3.origin = var_2;
    var_3.angles = var_1.angles;
    var_3.sentryType = "sentry_minigun";
    var_3.canBePlaced = 1;
    var_3 setturretmodechangewait( 1 );
    var_3 setmode( "sentry_offline" );
    var_3 makeunusable();
    var_3 maketurretinoperable();
    var_3.owner = var_1;
    var_3 setsentryowner( var_3.owner );
    var_3.scale = 3;
    var_3.inHeliProximity = 0;
    var_3 thread carryRemoteUAV_handleExistence();
    var_3.rangeTrigger = getent( "remote_uav_range", "targetname" );

    if ( !isdefined( var_3.rangeTrigger ) )
    {
        var_4 = getent( "airstrikeheight", "targetname" );
        var_3.maxHeight = var_4.origin[2];
        var_3.maxDistance = 3600;
    }

    var_3.carriedRemoteUAV = spawn( "script_origin", var_3.origin );
    var_3.carriedRemoteUAV.angles = var_3.angles;
    var_3.carriedRemoteUAV.origin = var_3.origin;
    var_3.carriedRemoteUAV linkto( var_3 );
    var_3.carriedRemoteUAV playloopsound( "recondrone_idle_high" );
    return var_3;
}

setCarryingRemoteUAV( var_0 )
{
    var_0 thread carryRemoteUAV_setCarried( self );
    self notifyonplayercommand( "place_carryRemoteUAV", "+attack" );
    self notifyonplayercommand( "place_carryRemoteUAV", "+attack_akimbo_accessible" );
    self notifyonplayercommand( "cancel_carryRemoteUAV", "+actionslot 4" );

    if ( !level.console )
    {
        self notifyonplayercommand( "cancel_carryRemoteUAV", "+actionslot 5" );
        self notifyonplayercommand( "cancel_carryRemoteUAV", "+actionslot 6" );
        self notifyonplayercommand( "cancel_carryRemoteUAV", "+actionslot 7" );
    }

    for (;;)
    {
        var_1 = local_waittill_any_return( "place_carryRemoteUAV", "cancel_carryRemoteUAV", "weapon_switch_started", "force_cancel_placement", "death", "disconnect" );
        self forceusehintoff();

        if ( var_1 != "place_carryRemoteUAV" )
        {
            carryremoteuav_delete( var_0 );
            break;
        }

        if ( !var_0.canBePlaced )
        {
            if ( self.team != "spectator" )
                self forceusehinton( &"MP_REMOTE_UAV_CANNOT_PLACE" );

            continue;
        }

        if ( isdefined( level.nukeIncoming ) || maps\mp\_utility::isEMPed() || teamHasRemoteUAV( self.team ) || maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount >= maps\mp\_utility::maxVehiclesAllowed() )
        {
            if ( isdefined( level.nukeIncoming ) || maps\mp\_utility::isEMPed() )
                self iprintlnbold( &"MP_UNAVAILABLE_FOR_N_WHEN_EMP", level.empTimeRemaining );
            else
                self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );

            carryremoteuav_delete( var_0 );
            break;
        }

        self.isCarrying = 0;
        var_0.carriedBy = undefined;
        var_0 playsound( "sentry_gun_plant" );
        var_0 notify( "placed" );
        break;
    }
}

local_waittill_any_return( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( ( !isdefined( var_0 ) || var_0 != "death" ) && ( !isdefined( var_1 ) || var_1 != "death" ) && ( !isdefined( var_2 ) || var_2 != "death" ) && ( !isdefined( var_3 ) || var_3 != "death" ) && ( !isdefined( var_4 ) || var_4 != "death" ) )
        self endon( "death" );

    var_6 = spawnstruct();

    if ( isdefined( var_0 ) )
        thread common_scripts\utility::waittill_string( var_0, var_6 );

    if ( isdefined( var_1 ) )
        thread common_scripts\utility::waittill_string( var_1, var_6 );

    if ( isdefined( var_2 ) )
        thread common_scripts\utility::waittill_string( var_2, var_6 );

    if ( isdefined( var_3 ) )
        thread common_scripts\utility::waittill_string( var_3, var_6 );

    if ( isdefined( var_4 ) )
        thread common_scripts\utility::waittill_string( var_4, var_6 );

    if ( isdefined( var_5 ) )
        thread common_scripts\utility::waittill_string( var_5, var_6 );

    var_6 waittill( "returned",  var_7  );
    var_6 notify( "die" );
    return var_7;
}

carryRemoteUAV_setCarried( var_0 )
{
    self setcandamage( 0 );
    self setsentrycarrier( var_0 );
    self setcontents( 0 );
    self.carriedBy = var_0;
    var_0.isCarrying = 1;
    var_0 thread updateCarryRemoteUAVPlacement( self );
    self notify( "carried" );
}

carryremoteuav_delete( var_0 )
{
    self.isCarrying = 0;

    if ( isdefined( var_0 ) )
    {
        if ( isdefined( var_0.carriedRemoteUAV ) )
            var_0.carriedRemoteUAV delete();

        var_0 delete();
    }
}

isInRemoteNoDeploy()
{
    if ( isdefined( level.RemoteUAV_noDeployZones ) && level.RemoteUAV_noDeployZones.size )
    {
        foreach ( var_1 in level.RemoteUAV_noDeployZones )
        {
            if ( self istouching( var_1 ) )
                return 1;
        }
    }

    return 0;
}

updateCarryRemoteUAVPlacement( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 endon( "placed" );
    var_0 endon( "death" );
    var_0.canBePlaced = 1;
    var_1 = -1;
    common_scripts\utility::_enableUsability();

    for (;;)
    {
        var_2 = 18;

        switch ( self getstance() )
        {
            case "stand":
                var_2 = 40;
                break;
            case "crouch":
                var_2 = 25;
                break;
            case "prone":
                var_2 = 10;
                break;
        }

        var_3 = self canplayerplacetank( 22, 22, 50, var_2, 0, 0 );
        var_0.origin = var_3["origin"] + anglestoup( self.angles ) * 27;
        var_0.angles = var_3["angles"];
        var_0.canBePlaced = self isonground() && var_3["result"] && var_0 remoteUAV_in_range() && !var_0 isInRemoteNoDeploy();

        if ( var_0.canBePlaced != var_1 )
        {
            if ( var_0.canBePlaced )
            {
                if ( self.team != "spectator" )
                    self forceusehinton( &"MP_REMOTE_UAV_PLACE" );

                if ( self attackbuttonpressed() )
                    self notify( "place_carryRemoteUAV" );
            }
            else if ( self.team != "spectator" )
                self forceusehinton( &"MP_REMOTE_UAV_CANNOT_PLACE" );
        }

        var_1 = var_0.canBePlaced;
        wait 0.05;
    }
}

carryRemoteUAV_handleExistence()
{
    level endon( "game_ended" );
    self.owner endon( "place_carryRemoteUAV" );
    self.owner endon( "cancel_carryRemoteUAV" );
    self.owner common_scripts\utility::waittill_any( "death", "disconnect", "joined_team", "joined_spectators" );

    if ( isdefined( self ) )
    {
        if ( isdefined( self.carriedRemoteUAV ) )
            self.carriedRemoteUAV delete();

        self delete();
    }
}

removeRemoteWeapon()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    wait 0.7;
}

startRemoteUAV( var_0, var_1, var_2, var_3 )
{
    lockPlayerForRemoteUAVLaunch();
    maps\mp\_utility::setUsingRemote( var_1 );
    maps\mp\_utility::_giveWeapon( "uav_remote_mp" );
    self switchtoweaponimmediate( "uav_remote_mp" );
    self visionsetnakedforplayer( "black_bw", 0.0 );
    var_4 = maps\mp\killstreaks\_killstreaks::initRideKillstreak( "remote_uav" );

    if ( var_4 != "success" )
    {
        if ( var_4 != "disconnect" )
        {
            self notify( "remoteuav_unlock" );
            self takeweapon( "uav_remote_mp" );
            maps\mp\_utility::clearUsingRemote();
        }

        return 0;
    }

    if ( teamHasRemoteUAV( self.team ) || maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        self notify( "remoteuav_unlock" );
        self takeweapon( "uav_remote_mp" );
        maps\mp\_utility::clearUsingRemote();
        return 0;
    }

    self notify( "remoteuav_unlock" );
    var_5 = createRemoteUAV( var_0, self, var_1, var_2, var_3 );

    if ( isdefined( var_5 ) )
    {
        thread remoteUAV_Ride( var_0, var_5, var_1 );
        return 1;
    }
    else
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        self takeweapon( "uav_remote_mp" );
        maps\mp\_utility::clearUsingRemote();
        return 0;
    }
}

remoteUAV_clearRideIntro()
{
    if ( isdefined( level.nukeDetonated ) )
        self visionsetnakedforplayer( level.nukeVisionSet, 0 );
    else
        self visionsetnakedforplayer( "", 0 );
}

lockPlayerForRemoteUAVLaunch()
{
    var_0 = spawn( "script_origin", self.origin );
    var_0 hide();
    self playerlinkto( var_0 );
    thread clearPlayerLockFromRemoteUAVLaunch( var_0 );
}

clearPlayerLockFromRemoteUAVLaunch( var_0 )
{
    level endon( "game_ended" );
    var_1 = common_scripts\utility::waittill_any_return( "disconnect", "death", "remoteuav_unlock" );

    if ( var_1 != "disconnect" )
        self unlink();

    var_0 delete();
}

createRemoteUAV( var_0, var_1, var_2, var_3, var_4 )
{
    if ( level.console )
        var_5 = spawnhelicopter( var_1, var_3, var_4, "remote_uav_mp", "vehicle_remote_uav" );
    else
        var_5 = spawnhelicopter( var_1, var_3, var_4, "remote_uav_mp_pc", "vehicle_remote_uav" );

    if ( !isdefined( var_5 ) )
        return undefined;

    var_5 maps\mp\killstreaks\_helicopter::addToLittleBirdList();
    var_5 thread maps\mp\killstreaks\_helicopter::removeFromLittleBirdListOnDeath();
    var_5 makevehiclesolidcapsule( 18, -9, 18 );
    var_5.lifeId = var_0;
    var_5.team = var_1.team;
    var_5.pers["team"] = var_1.team;
    var_5.owner = var_1;
    var_5.health = 999999;
    var_5.maxHealth = 250;
    var_5.damagetaken = 0;
    var_5.destroyed = 0;
    var_5 setcandamage( 1 );
    var_5.specialDamageCallback = ::Callback_VehicleDamage;
    var_5.scrambler = spawn( "script_model", var_3 );
    var_5.scrambler linkto( var_5, "tag_origin", ( 0, 0, -160 ), ( 0, 0, 0 ) );
    var_5.scrambler makescrambler( var_1 );
    var_5.smoking = 0;
    var_5.inHeliProximity = 0;
    var_5.heliType = "remote_uav";
    var_5.markedPlayers = [];
    var_5 thread remoteUAV_light_fx();
    var_5 thread remoteUAV_explode_on_disconnect();
    var_5 thread remoteUAV_explode_on_changeTeams();
    var_5 thread remoteUAV_explode_on_death();
    var_5 thread remoteUAV_clear_marked_on_gameEnded();
    var_5 thread remoteUAV_leave_on_timeout();
    var_5 thread remoteUAV_watch_distance();
    var_5 thread remoteUAV_watchHeliProximity();
    var_5 thread remoteUAV_handleDamage();
    var_5.numFlares = 2;
    var_5.hasIncoming = 0;
    var_5.incomingMissiles = [];
    var_5 thread remoteUAV_clearIncomingWarning();
    var_5 thread remoteUAV_handleIncomingStinger();
    var_5 thread remoteUAV_handleIncomingSAM();
    level.remote_uav[var_5.team] = var_5;
    return var_5;
}

remoteUAV_Ride( var_0, var_1, var_2 )
{
    var_1.playerLinked = 1;
    self.restoreAngles = self.angles;

    if ( getdvarint( "camera_thirdPerson" ) )
        maps\mp\_utility::setThirdPersonDOF( 0 );

    if ( maps\mp\_utility::isJuggernaut() && isdefined( self.juggernautOverlay ) )
        self.juggernautOverlay.alpha = 0;

    if ( isdefined( self.hasLightArmor ) && isdefined( self.combatHighOverlay ) )
        self.combatHighOverlay.alpha = 0;

    self cameralinkto( var_1, "tag_origin" );
    self remotecontrolvehicle( var_1 );
    thread remoteUAV_playerExit( var_1 );
    thread remoteUAV_Track( var_1 );
    thread remoteUAV_Fire( var_1 );
    self.remote_uav_rideLifeId = var_0;
    self.remoteUAV = var_1;
    thread remoteUAV_delayLaunchDialog( var_1 );
    self visionsetnakedforplayer( "black_bw", 0.0 );

    if ( isdefined( level.nukeDetonated ) )
        self visionsetnakedforplayer( level.nukeVisionSet, 1 );
    else
        self visionsetnakedforplayer( "", 1 );
}

remoteUAV_delayLaunchDialog( var_0 )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    var_0 endon( "death" );
    var_0 endon( "end_remote" );
    var_0 endon( "end_launch_dialog" );
    wait 3;
    RemoteUAV_dialog( "launch" );
}

remoteUAV_endride( var_0 )
{
    if ( isdefined( var_0 ) )
    {
        var_0.playerLinked = 0;
        var_0 notify( "end_remote" );
        maps\mp\_utility::clearUsingRemote();

        if ( getdvarint( "camera_thirdPerson" ) )
            maps\mp\_utility::setThirdPersonDOF( 1 );

        if ( maps\mp\_utility::isJuggernaut() && isdefined( self.juggernautOverlay ) )
            self.juggernautOverlay.alpha = 1;

        if ( isdefined( self.hasLightArmor ) && isdefined( self.combatHighOverlay ) )
            self.combatHighOverlay.alpha = 1;

        self cameraunlink( var_0 );
        self remotecontrolvehicleoff( var_0 );
        self thermalvisionoff();
        self setplayerangles( self.restoreAngles );
        var_1 = common_scripts\utility::getLastWeapon();

        if ( !self hasweapon( var_1 ) && maps\mp\_utility::isReallyAlive( self ) )
            var_1 = maps\mp\killstreaks\_killstreaks::getFirstPrimaryWeapon();

        self switchtoweapon( var_1 );
        self takeweapon( "uav_remote_mp" );
        thread remoteUAV_freezeBuffer();
    }

    self.remoteUAV = undefined;
}

remoteUAV_freezeBuffer()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    maps\mp\_utility::freezeControlsWrapper( 1 );
    wait 0.5;
    maps\mp\_utility::freezeControlsWrapper( 0 );
}

remoteUAV_playerExit( var_0 )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    var_0 endon( "death" );
    var_0 endon( "end_remote" );
    wait 2;

    for (;;)
    {
        var_1 = 0;

        while ( self usebuttonpressed() )
        {
            var_1 += 0.05;

            if ( var_1 > 0.75 )
            {
                var_0 thread remoteUAV_leave();
                return;
            }

            wait 0.05;
        }

        wait 0.05;
    }
}

remoteUAV_Track( var_0 )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    var_0 endon( "death" );
    var_0 endon( "end_remote" );
    var_0.lastTrackingDialogTime = 0;
    self.lockedTarget = undefined;
    self weaponlockfree();
    wait 1;

    for (;;)
    {
        var_1 = var_0 gettagorigin( "tag_turret" );
        var_2 = anglestoforward( self getplayerangles() );
        var_3 = var_1 + var_2 * 1024;
        var_4 = bullettrace( var_1, var_3, 1, var_0 );

        if ( isdefined( var_4["position"] ) )
            var_5 = var_4["position"];
        else
        {
            var_5 = var_3;
            var_4["endpos"] = var_3;
        }

        var_0.trace = var_4;
        var_6 = remoteUAV_trackEntities( var_0, level.players, var_5 );
        var_7 = remoteUAV_trackEntities( var_0, level.turrets, var_5 );
        var_8 = undefined;

        if ( level.teamBased )
            var_8 = remoteUAV_trackEntities( var_0, level.uavmodels[level.otherTeam[self.team]], var_5 );
        else
            var_8 = remoteUAV_trackEntities( var_0, level.uavmodels, var_5 );

        var_9 = undefined;

        if ( isdefined( var_6 ) )
            var_9 = var_6;
        else if ( isdefined( var_7 ) )
            var_9 = var_7;
        else if ( isdefined( var_8 ) )
            var_9 = var_8;

        if ( isdefined( var_9 ) )
        {
            if ( !isdefined( self.lockedTarget ) || isdefined( self.lockedTarget ) && self.lockedTarget != var_9 )
            {
                self weaponlockfinalize( var_9 );
                self.lockedTarget = var_9;

                if ( isdefined( var_6 ) )
                {
                    var_0 notify( "end_launch_dialog" );
                    RemoteUAV_dialog( "track" );
                }
            }
        }
        else
        {
            self weaponlockfree();
            self.lockedTarget = undefined;
        }

        wait 0.05;
    }
}

remoteUAV_trackEntities( var_0, var_1, var_2 )
{
    level endon( "game_ended" );
    var_3 = undefined;

    foreach ( var_5 in var_1 )
    {
        if ( level.teamBased && ( !isdefined( var_5.team ) || var_5.team == self.team ) )
            continue;

        if ( isplayer( var_5 ) )
        {
            if ( !maps\mp\_utility::isReallyAlive( var_5 ) )
                continue;

            if ( var_5 == self )
                continue;

            var_6 = var_5.guid;
        }
        else
            var_6 = var_5.birthtime;

        if ( isdefined( var_5.sentryType ) || isdefined( var_5.turretType ) )
        {
            var_7 = ( 0, 0, 32 );
            var_8 = "hud_fofbox_hostile_vehicle";
        }
        else if ( isdefined( var_5.uavType ) )
        {
            var_7 = ( 0, 0, -52 );
            var_8 = "hud_fofbox_hostile_vehicle";
        }
        else
        {
            var_7 = ( 0, 0, 26 );
            var_8 = "veh_hud_target_unmarked";
        }

        if ( isdefined( var_5.UAVRemoteMarkedBy ) )
        {
            if ( !isdefined( var_0.markedPlayers[var_6] ) )
            {
                var_0.markedPlayers[var_6] = [];
                var_0.markedPlayers[var_6]["player"] = var_5;
                var_0.markedPlayers[var_6]["icon"] = var_5 maps\mp\_entityheadicons::setHeadIcon( self, "veh_hud_target_marked", var_7, 10, 10, 0, 0.05, 0, 0, 0, 0 );
                var_0.markedPlayers[var_6]["icon"].shader = "veh_hud_target_marked";

                if ( !isdefined( var_5.sentryType ) || !isdefined( var_5.turretType ) )
                    var_0.markedPlayers[var_6]["icon"] settargetent( var_5 );
            }
            else if ( isdefined( var_0.markedPlayers[var_6] ) && isdefined( var_0.markedPlayers[var_6]["icon"] ) && isdefined( var_0.markedPlayers[var_6]["icon"].shader ) && var_0.markedPlayers[var_6]["icon"].shader != "veh_hud_target_marked" )
            {
                var_0.markedPlayers[var_6]["icon"].shader = "veh_hud_target_marked";
                var_0.markedPlayers[var_6]["icon"] setshader( "veh_hud_target_marked", 10, 10 );
                var_0.markedPlayers[var_6]["icon"] setwaypoint( 0, 0, 0, 0 );
            }

            continue;
        }

        if ( isplayer( var_5 ) )
        {
            var_9 = isdefined( var_5.spawnTime ) && ( gettime() - var_5.spawnTime ) / 1000 <= 5;
            var_10 = var_5 maps\mp\_utility::_hasPerk( "specialty_blindeye" );
            var_11 = 0;
            var_12 = 0;
        }
        else
        {
            var_9 = 0;
            var_10 = 0;
            var_11 = isdefined( var_5.carriedBy );
            var_12 = isdefined( var_5.isLeaving ) && var_5.isLeaving == 1;
        }

        if ( !isdefined( var_0.markedPlayers[var_6] ) && !var_9 && !var_10 && !var_11 && !var_12 )
        {
            var_0.markedPlayers[var_6] = [];
            var_0.markedPlayers[var_6]["player"] = var_5;
            var_0.markedPlayers[var_6]["icon"] = var_5 maps\mp\_entityheadicons::setHeadIcon( self, var_8, var_7, 10, 10, 0, 0.05, 0, 0, 0, 0 );
            var_0.markedPlayers[var_6]["icon"].shader = var_8;

            if ( !isdefined( var_5.sentryType ) || !isdefined( var_5.turretType ) )
                var_0.markedPlayers[var_6]["icon"] settargetent( var_5 );
        }

        if ( ( !isdefined( var_3 ) || var_3 != var_5 ) && ( isdefined( var_0.trace["entity"] ) && var_0.trace["entity"] == var_5 && !var_11 && !var_12 ) || distance( var_5.origin, var_2 ) < 200 * var_0.trace["fraction"] && !var_9 && !var_11 && !var_12 || !var_12 && remoteUAV_canTargetUAV( var_0, var_5 ) )
        {
            var_13 = bullettrace( var_0.origin, var_5.origin + ( 0, 0, 32 ), 1, var_0 );

            if ( isdefined( var_13["entity"] ) && var_13["entity"] == var_5 || var_13["fraction"] == 1 )
            {
                self playlocalsound( "recondrone_lockon" );
                var_3 = var_5;
            }
        }
    }

    return var_3;
}

remoteUAV_canTargetUAV( var_0, var_1 )
{
    if ( isdefined( var_1.uavType ) )
    {
        var_2 = anglestoforward( self getplayerangles() );
        var_3 = vectornormalize( var_1.origin - var_0 gettagorigin( "tag_turret" ) );
        var_4 = vectordot( var_2, var_3 );

        if ( var_4 > 0.985 )
            return 1;
    }

    return 0;
}

remoteUAV_Fire( var_0 )
{
    self endon( "disconnect" );
    var_0 endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "end_remote" );
    wait 1;
    self notifyonplayercommand( "remoteUAV_tag", "+attack" );
    self notifyonplayercommand( "remoteUAV_tag", "+attack_akimbo_accessible" );

    for (;;)
    {
        self waittill( "remoteUAV_tag" );

        if ( isdefined( self.lockedTarget ) )
        {
            self playlocalsound( "recondrone_tag" );
            maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "" );
            thread remoteUAV_markPlayer( self.lockedTarget );
            thread remoteUAV_Rumble( var_0, 3 );
            wait 0.25;
            continue;
        }

        wait 0.05;
    }
}

remoteUAV_Rumble( var_0, var_1 )
{
    self endon( "disconnect" );
    var_0 endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "end_remote" );
    var_0 notify( "end_rumble" );
    var_0 endon( "end_rumble" );

    for ( var_2 = 0; var_2 < var_1; var_2++ )
    {
        self playrumbleonentity( "damage_heavy" );
        wait 0.05;
    }
}

remoteUAV_markPlayer( var_0 )
{
    level endon( "game_ended" );
    var_0.UAVRemoteMarkedBy = self;

    if ( isplayer( var_0 ) && !var_0 maps\mp\_utility::isUsingRemote() )
    {
        var_0 playlocalsound( "player_hit_while_ads_hurt" );
        var_0 thread maps\mp\_flashgrenades::applyFlash( 2.0, 1.0 );
        var_0 thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_MARKED_BY_REMOTE_UAV" );
    }
    else if ( isdefined( var_0.uavType ) )
        var_0.birth_time = var_0.birthtime;
    else if ( isdefined( var_0.owner ) && isalive( var_0.owner ) )
        var_0.owner thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_TURRET_MARKED_BY_REMOTE_UAV" );

    RemoteUAV_dialog( "tag" );
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_REMOTE_UAV_MARKED" );

    if ( level.gameType != "dm" )
    {
        if ( isplayer( var_0 ) )
        {
            maps\mp\gametypes\_gamescore::givePlayerScore( "kill", self, undefined, 1 );
            thread maps\mp\gametypes\_rank::giveRankXP( "kill" );
        }
    }

    if ( isplayer( var_0 ) )
        var_0 setperk( "specialty_radarblip", 1, 0 );
    else
    {
        if ( isdefined( var_0.uavType ) )
            var_1 = "compassping_enemy_uav";
        else
            var_1 = "compassping_sentry_enemy";

        if ( level.teamBased )
        {
            var_2 = maps\mp\gametypes\_gameobjects::getNextObjID();
            objective_add( var_2, "invisible", ( 0, 0, 0 ) );
            objective_onentity( var_2, var_0 );
            objective_state( var_2, "active" );
            objective_team( var_2, self.team );
            objective_icon( var_2, var_1 );
            var_0.remoteUAVMarkedObjID01 = var_2;
        }
        else
        {
            var_2 = maps\mp\gametypes\_gameobjects::getNextObjID();
            objective_add( var_2, "invisible", ( 0, 0, 0 ) );
            objective_onentity( var_2, var_0 );
            objective_state( var_2, "active" );
            objective_team( var_2, level.otherTeam[self.team] );
            objective_icon( var_2, var_1 );
            var_0.remoteUAVMarkedObjID02 = var_2;
            var_2 = maps\mp\gametypes\_gameobjects::getNextObjID();
            objective_add( var_2, "invisible", ( 0, 0, 0 ) );
            objective_onentity( var_2, var_0 );
            objective_state( var_2, "active" );
            objective_team( var_2, self.team );
            objective_icon( var_2, var_1 );
            var_0.remoteUAVMarkedObjID03 = var_2;
        }
    }

    var_0 thread remoteUAV_unmarkRemovedPlayer( self.remoteUAV );
}

remoteUAV_processTaggedAssist( var_0 )
{
    RemoteUAV_dialog( "assist" );
    thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_REMOTE_UAV_ASSIST" );

    if ( level.gameType != "dm" )
    {
        self.taggedassist = 1;

        if ( isdefined( var_0 ) )
            thread maps\mp\gametypes\_gamescore::processAssist( var_0 );
        else
        {
            maps\mp\gametypes\_gamescore::givePlayerScore( "assist", self, undefined, 1 );
            thread maps\mp\gametypes\_rank::giveRankXP( "assist" );
        }
    }
}

remoteUAV_unmarkRemovedPlayer( var_0 )
{
    level endon( "game_ended" );
    var_1 = common_scripts\utility::waittill_any_return( "death", "disconnect", "carried", "leaving" );

    if ( var_1 == "leaving" || !isdefined( self.uavType ) )
        self.UAVRemoteMarkedBy = undefined;

    if ( isdefined( var_0 ) )
    {
        if ( isplayer( self ) )
            var_2 = self.guid;
        else if ( isdefined( self.birthtime ) )
            var_2 = self.birthtime;
        else
            var_2 = self.birth_time;

        if ( var_1 == "carried" || var_1 == "leaving" )
        {
            var_0.markedPlayers[var_2]["icon"] destroy();
            var_0.markedPlayers[var_2]["icon"] = undefined;
        }

        if ( isdefined( var_2 ) && isdefined( var_0.markedPlayers[var_2] ) )
        {
            var_0.markedPlayers[var_2] = undefined;
            var_0.markedPlayers = common_scripts\utility::array_removeUndefined( var_0.markedPlayers );
        }
    }

    if ( isplayer( self ) )
        self unsetperk( "specialty_radarblip", 1 );
    else
    {
        if ( isdefined( self.remoteUAVMarkedObjID01 ) )
            maps\mp\_utility::_objective_delete( self.remoteUAVMarkedObjID01 );

        if ( isdefined( self.remoteUAVMarkedObjID02 ) )
            maps\mp\_utility::_objective_delete( self.remoteUAVMarkedObjID02 );

        if ( isdefined( self.remoteUAVMarkedObjID03 ) )
            maps\mp\_utility::_objective_delete( self.remoteUAVMarkedObjID03 );
    }
}

remoteUAV_clearMarkedForOwner()
{
    foreach ( var_1 in self.markedPlayers )
    {
        if ( isdefined( var_1["icon"] ) )
        {
            var_1["icon"] destroy();
            var_1["icon"] = undefined;
        }
    }

    self.markedPlayers = undefined;
}

remoteUAV_operationRumble( var_0 )
{
    self endon( "disconnect" );
    var_0 endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "end_remote" );

    for (;;)
    {
        self playrumbleonentity( "damage_light" );
        wait 0.5;
    }
}

remoteUAV_watch_distance()
{
    self endon( "death" );
    self.rangeTrigger = getent( "remote_uav_range", "targetname" );

    if ( !isdefined( self.rangeTrigger ) )
    {
        var_0 = getent( "airstrikeheight", "targetname" );
        self.maxHeight = var_0.origin[2];
        self.maxDistance = 12800;
    }

    self.centerRef = spawn( "script_model", level.mapCenter );
    var_1 = self.origin;
    self.rangeCountdownActive = 0;

    for (;;)
    {
        if ( !remoteUAV_in_range() )
        {
            var_2 = 0;

            while ( !remoteUAV_in_range() )
            {
                self.owner RemoteUAV_dialog( "out_of_range" );

                if ( !self.rangeCountdownActive )
                {
                    self.rangeCountdownActive = 1;
                    thread remoteUAV_rangeCountdown();
                }

                if ( isdefined( self.heliInProximity ) )
                {
                    var_3 = distance( self.origin, self.heliInProximity.origin );
                    var_2 = 1 - ( var_3 - 150 ) / 150;
                }
                else
                {
                    var_3 = distance( self.origin, var_1 );
                    var_2 = min( 1, var_3 / 200 );
                }

                self.owner setplayerdata( "reconDroneState", "staticAlpha", var_2 );
                wait 0.05;
            }

            self notify( "in_range" );
            self.rangeCountdownActive = 0;
            thread remoteUAV_staticFade( var_2 );
        }

        var_1 = self.origin;
        wait 0.05;
    }
}

remoteUAV_in_range()
{
    if ( isdefined( self.rangeTrigger ) )
    {
        if ( !self istouching( self.rangeTrigger ) && !self.inHeliProximity )
            return 1;
    }
    else if ( distance2d( self.origin, level.mapCenter ) < self.maxDistance && self.origin[2] < self.maxHeight && !self.inHeliProximity )
        return 1;

    return 0;
}

remoteUAV_staticFade( var_0 )
{
    self endon( "death" );

    while ( remoteUAV_in_range() )
    {
        var_0 -= 0.05;

        if ( var_0 < 0 )
        {
            self.owner setplayerdata( "reconDroneState", "staticAlpha", 0 );
            break;
        }

        self.owner setplayerdata( "reconDroneState", "staticAlpha", var_0 );
        wait 0.05;
    }
}

remoteUAV_rangeCountdown()
{
    self endon( "death" );
    self endon( "in_range" );

    if ( isdefined( self.heliInProximity ) )
        var_0 = 3;
    else
        var_0 = 6;

    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_0 );
    self notify( "death" );
}

remoteUAV_explode_on_disconnect()
{
    self endon( "death" );
    self.owner waittill( "disconnect" );
    self notify( "death" );
}

remoteUAV_explode_on_changeTeams()
{
    self endon( "death" );
    self.owner common_scripts\utility::waittill_any( "joined_team", "joined_spectators" );
    self notify( "death" );
}

remoteUAV_clear_marked_on_gameEnded()
{
    self endon( "death" );
    level waittill( "game_ended" );
    remoteUAV_clearMarkedForOwner();
}

remoteUAV_leave_on_timeout()
{
    self endon( "death" );
    var_0 = 60.0;
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_0 );
    thread remoteUAV_leave();
}

remoteUAV_leave()
{
    level endon( "game_ended" );
    self endon( "death" );
    self notify( "leaving" );
    self.owner remoteUAV_endride( self );
    self notify( "death" );
}

remoteUAV_explode_on_death()
{
    level endon( "game_ended" );
    self waittill( "death" );
    self playsound( "recondrone_destroyed" );
    playfx( level.RemoteUAV_fx["explode"], self.origin );
    remoteUAV_cleanup();
}

remoteUAV_cleanup()
{
    if ( self.playerLinked == 1 && isdefined( self.owner ) )
        self.owner remoteUAV_endride( self );

    if ( isdefined( self.scrambler ) )
        self.scrambler delete();

    if ( isdefined( self.centerRef ) )
        self.centerRef delete();

    remoteUAV_clearMarkedForOwner();
    stopfxontag( level.RemoteUAV_fx["smoke"], self, "tag_origin" );
    level.remote_uav[self.team] = undefined;
    maps\mp\_utility::decrementFauxVehicleCount();
    self delete();
}

remoteUAV_light_fx()
{
    playfxontag( level.chopper_fx["light"]["belly"], self, "tag_light_nose" );
    wait 0.05;
    playfxontag( level.chopper_fx["light"]["tail"], self, "tag_light_tail1" );
}

RemoteUAV_dialog( var_0 )
{
    if ( var_0 == "tag" )
        var_1 = 1000;
    else
        var_1 = 5000;

    if ( gettime() - level.RemoteUAV_lastDialogTime < var_1 )
        return;

    level.RemoteUAV_lastDialogTime = gettime();
    var_2 = randomint( level.RemoteUAV_dialog[var_0].size );
    var_3 = level.RemoteUAV_dialog[var_0][var_2];
    var_4 = maps\mp\gametypes\_teams::getTeamVoicePrefix( self.team ) + var_3;
    self playlocalsound( var_4 );
}

remoteUAV_handleIncomingStinger()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "end_remote" );

    for (;;)
    {
        level waittill( "stinger_fired",  var_0, var_1, var_2  );

        if ( !isdefined( var_1 ) || !isdefined( var_2 ) || var_2 != self )
            continue;

        self.owner playlocalsound( "javelin_clu_lock" );
        self.owner setplayerdata( "reconDroneState", "incomingMissile", 1 );
        self.hasIncoming = 1;
        self.incomingMissiles[self.incomingMissiles.size] = var_1;
        var_1.owner = var_0;
        var_1 thread watchStingerProximity( var_2 );
    }
}

remoteUAV_handleIncomingSAM()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "end_remote" );

    for (;;)
    {
        level waittill( "sam_fired",  var_0, var_1, var_2  );

        if ( !isdefined( var_2 ) || var_2 != self )
            continue;

        var_3 = 0;

        foreach ( var_5 in var_1 )
        {
            if ( isdefined( var_5 ) )
            {
                self.incomingMissiles[self.incomingMissiles.size] = var_5;
                var_5.owner = var_0;
                var_3++;
            }
        }

        if ( var_3 )
        {
            self.owner playlocalsound( "javelin_clu_lock" );
            self.owner setplayerdata( "reconDroneState", "incomingMissile", 1 );
            self.hasIncoming = 1;
            level thread watchSAMProximity( var_2, var_1 );
        }
    }
}

watchStingerProximity( var_0 )
{
    level endon( "game_ended" );
    self endon( "death" );
    self missile_settargetent( var_0 );
    var_1 = vectornormalize( var_0.origin - self.origin );

    while ( isdefined( var_0 ) )
    {
        var_2 = var_0 getpointinbounds( 0, 0, 0 );
        var_3 = distance( self.origin, var_2 );

        if ( var_0.numFlares > 0 && var_3 < 4000 )
        {
            var_4 = var_0 deployFlares();
            self missile_settargetent( var_4 );
            return;
        }
        else
        {
            var_5 = vectornormalize( var_0.origin - self.origin );

            if ( vectordot( var_5, var_1 ) < 0 )
            {
                self playsound( "exp_stinger_armor_destroy" );
                playfx( level.RemoteUAV_fx["missile_explode"], self.origin );

                if ( isdefined( self.owner ) )
                    radiusdamage( self.origin, 400, 1000, 1000, self.owner, "MOD_EXPLOSIVE", "stinger_mp" );
                else
                    radiusdamage( self.origin, 400, 1000, 1000, undefined, "MOD_EXPLOSIVE", "stinger_mp" );

                self hide();
                wait 0.05;
                self delete();
            }
            else
                var_1 = var_5;
        }

        wait 0.05;
    }
}

watchSAMProximity( var_0, var_1 )
{
    level endon( "game_ended" );
    var_0 endon( "death" );

    foreach ( var_3 in var_1 )
    {
        if ( isdefined( var_3 ) )
        {
            var_3 missile_settargetent( var_0 );
            var_3.lastVecToTarget = vectornormalize( var_0.origin - var_3.origin );
        }
    }

    while ( var_1.size && isdefined( var_0 ) )
    {
        var_5 = var_0 getpointinbounds( 0, 0, 0 );

        foreach ( var_3 in var_1 )
        {
            if ( isdefined( var_3 ) )
            {
                if ( isdefined( self.markForDetete ) )
                {
                    self delete();
                    continue;
                }

                if ( var_0.numFlares > 0 )
                {
                    var_7 = distance( var_3.origin, var_5 );

                    if ( var_7 < 4000 )
                    {
                        var_8 = var_0 deployFlares();

                        foreach ( var_10 in var_1 )
                        {
                            if ( isdefined( var_10 ) )
                                var_10 missile_settargetent( var_8 );
                        }

                        return;
                    }

                    continue;
                }

                var_12 = vectornormalize( var_0.origin - var_3.origin );

                if ( vectordot( var_12, var_3.lastVecToTarget ) < 0 )
                {
                    var_3 playsound( "exp_stinger_armor_destroy" );
                    playfx( level.RemoteUAV_fx["missile_explode"], var_3.origin );

                    if ( isdefined( var_3.owner ) )
                        radiusdamage( var_3.origin, 400, 1000, 1000, var_3.owner, "MOD_EXPLOSIVE", "stinger_mp" );
                    else
                        radiusdamage( var_3.origin, 400, 1000, 1000, undefined, "MOD_EXPLOSIVE", "stinger_mp" );

                    var_3 hide();
                    var_3.markForDetete = 1;
                }
                else
                    var_3.lastVecToTarget = var_12;
            }
        }

        var_1 = common_scripts\utility::array_removeUndefined( var_1 );
        wait 0.05;
    }
}

deployFlares()
{
    self.numFlares--;
    self.owner thread remoteUAV_Rumble( self, 6 );
    self playsound( "WEAP_SHOTGUNATTACH_FIRE_NPC" );
    thread playFlareFx();
    var_0 = self.origin + ( 0, 0, -100 );
    var_1 = spawn( "script_origin", var_0 );
    var_1.angles = self.angles;
    var_1 movegravity( ( 0, 0, -1 ), 5.0 );
    var_1 thread deleteAfterTime( 5.0 );
    return var_1;
}

playFlareFx()
{
    for ( var_0 = 0; var_0 < 5; var_0++ )
    {
        if ( !isdefined( self ) )
            return;

        playfxontag( level._effect["ac130_flare"], self, "TAG_FLARE" );
        wait 0.15;
    }
}

deleteAfterTime( var_0 )
{
    wait(var_0);
    self delete();
}

remoteUAV_clearIncomingWarning()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "end_remote" );

    for (;;)
    {
        var_0 = 0;

        for ( var_1 = 0; var_1 < self.incomingMissiles.size; var_1++ )
        {
            if ( isdefined( self.incomingMissiles[var_1] ) && missile_isIncoming( self.incomingMissiles[var_1], self ) )
                var_0++;
        }

        if ( self.hasIncoming && !var_0 )
        {
            self.hasIncoming = 0;
            self.owner setplayerdata( "reconDroneState", "incomingMissile", 0 );
        }

        self.incomingMissiles = common_scripts\utility::array_removeUndefined( self.incomingMissiles );
        wait 0.05;
    }
}

missile_isIncoming( var_0, var_1 )
{
    var_2 = vectornormalize( var_1.origin - var_0.origin );
    var_3 = anglestoforward( var_0.angles );
    return vectordot( var_2, var_3 ) > 0;
}

remoteUAV_watchHeliProximity()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "end_remote" );

    for (;;)
    {
        var_0 = 0;

        foreach ( var_2 in level.helis )
        {
            if ( distance( var_2.origin, self.origin ) < 300 )
            {
                var_0 = 1;
                self.heliInProximity = var_2;
            }
        }

        foreach ( var_5 in level.littleBirds )
        {
            if ( var_5 != self && ( !isdefined( var_5.heliType ) || var_5.heliType != "remote_uav" ) && distance( var_5.origin, self.origin ) < 300 )
            {
                var_0 = 1;
                self.heliInProximity = var_5;
            }
        }

        if ( !self.inHeliProximity && var_0 )
            self.inHeliProximity = 1;
        else if ( self.inHeliProximity && !var_0 )
        {
            self.inHeliProximity = 0;
            self.heliInProximity = undefined;
        }

        wait 0.05;
    }
}

remoteUAV_handleDamage()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "end_remote" );

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( isdefined( self.specialDamageCallback ) )
            self [[ self.specialDamageCallback ]]( undefined, var_1, var_0, var_8, var_4, var_9, var_3, var_2, undefined, undefined, var_5, var_7 );
    }
}

Callback_VehicleDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 )
{
    if ( self.destroyed == 1 )
        return;

    var_12 = self.team;

    if ( isdefined( var_1.team ) )
        var_13 = var_1.team;
    else
        var_13 = "none";

    if ( !isdefined( var_1 ) || var_1 != self.owner && level.teamBased && var_13 == var_12 )
        return;

    if ( isdefined( var_3 ) && var_3 & level.iDFLAGS_PENETRATION )
        self.wasDamagedFromBulletPenetration = 1;

    var_14 = var_2;

    if ( isplayer( var_1 ) )
    {
        var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "remote_uav" );

        if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
            var_14 = var_2 * level.armorPiercingMod;
    }

    if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
        var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "remote_uav" );

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
                var_14 = self.maxHealth + 1;
                break;
            case "emp_grenade_mp":
            case "bomb_site_mp":
                self.largeProjectileDamage = 0;
                var_14 = self.maxHealth + 1;
                break;
        }

        maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_5, self );
    }

    if ( isdefined( var_4 ) && var_4 == "MOD_MELEE" )
        var_14 = self.maxHealth + 1;

    self.damagetaken = self.damagetaken + var_14;
    playfxontagforclients( level.RemoteUAV_fx["hit"], self, "tag_origin", self.owner );
    self playsound( "recondrone_damaged" );

    if ( self.smoking == 0 && self.damagetaken >= self.maxHealth / 2 )
    {
        self.smoking = 1;
        playfxontag( level.RemoteUAV_fx["smoke"], self, "tag_origin" );
    }

    if ( self.damagetaken >= self.maxHealth && ( level.teamBased && var_12 != var_13 || !level.teamBased ) )
    {
        self.destroyed = 1;
        var_15 = undefined;

        if ( isdefined( var_1.owner ) && ( !isdefined( self.owner ) || var_1.owner != self.owner ) )
            var_15 = var_1.owner;
        else if ( !isdefined( self.owner ) || var_1 != self.owner )
            var_15 = var_1;

        if ( !isdefined( var_1.owner ) && var_1.classname == "script_vehicle" )
            var_15 = undefined;

        if ( isdefined( var_1.class ) && var_1.class == "worldspawn" )
            var_15 = undefined;

        if ( var_1.classname == "trigger_hurt" )
            var_15 = undefined;

        if ( isdefined( var_15 ) )
        {
            var_15 notify( "destroyed_killstreak",  var_5  );
            thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_remote_uav", var_15 );
            var_15 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 50, var_5, var_4 );
            var_15 thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DESTROYED_REMOTE_UAV" );
            thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, var_15, var_2, var_4, var_5 );
        }

        self notify( "death" );
    }
}
