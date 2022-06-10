// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precachestring( &"MP_WAR_RADAR_ACQUIRED" );
    precachestring( &"MP_WAR_RADAR_ACQUIRED_ENEMY" );
    precachestring( &"MP_WAR_RADAR_EXPIRED" );
    precachestring( &"MP_WAR_RADAR_EXPIRED_ENEMY" );
    precachestring( &"MP_WAR_COUNTER_RADAR_ACQUIRED" );
    precachestring( &"MP_WAR_COUNTER_RADAR_ACQUIRED_ENEMY" );
    precachestring( &"MP_WAR_COUNTER_RADAR_EXPIRED" );
    precachestring( &"MP_WAR_COUNTER_RADAR_EXPIRED_ENEMY" );
    precachestring( &"MP_LASE_TARGET_FOR_PREDATOR_STRIKE" );
    precachemodel( "vehicle_uav_static_mp" );
    precachemodel( "vehicle_phantom_ray" );
    precacheitem( "uav_strike_marker_mp" );
    precacheitem( "uav_strike_projectile_mp" );
    level.radarViewTime = 30;
    level.uavBlockTime = 30;
    level.uav_fx["explode"] = loadfx( "explosions/uav_advanced_death" );
    level.uav_fx["trail"] = loadfx( "smoke/advanced_uav_contrail" );
    level.killstreakFuncs["uav"] = ::tryUseUAV;
    level.killstreakFuncs["uav_support"] = ::tryUseUAVSupport;
    level.killstreakFuncs["uav_2"] = ::tryUseUAV;
    level.killstreakFuncs["double_uav"] = ::tryUseDoubleUAV;
    level.killstreakFuncs["triple_uav"] = ::tryUseTripleUAV;
    level.killstreakFuncs["counter_uav"] = ::tryUseCounterUAV;
    level.killstreakFuncs["uav_strike"] = ::tryUseUAVStrike;
    level.killstreakSetupFuncs["uav_strike"] = ::UAVStrikeSetup;
    level.killstreakFuncs["directional_uav"] = ::tryUseDirectionalUAV;
    level._effect["laserTarget"] = loadfx( "misc/laser_glow" );
    var_0 = getentarray( "minimap_corner", "targetname" );

    if ( var_0.size )
        var_1 = maps\mp\gametypes\_spawnlogic::findBoxCenter( var_0[0].origin, var_0[1].origin );
    else
        var_1 = ( 0, 0, 0 );

    level.UAVRig = spawn( "script_model", var_1 );
    level.UAVRig setmodel( "c130_zoomrig" );
    level.UAVRig.angles = ( 0, 115, 0 );
    level.UAVRig hide();
    level.UAVRig.targetname = "uavrig_script_model";
    level.UAVRig thread rotateUAVRig();

    if ( level.teamBased )
    {
        level.radarmode["allies"] = "normal_radar";
        level.radarmode["axis"] = "normal_radar";
        level.activeUAVs["allies"] = 0;
        level.activeUAVs["axis"] = 0;
        level.activeCounterUAVs["allies"] = 0;
        level.activeCounterUAVs["axis"] = 0;
        level.uavmodels["allies"] = [];
        level.uavmodels["axis"] = [];
    }
    else
    {
        level.radarmode = [];
        level.activeUAVs = [];
        level.activeCounterUAVs = [];
        level.uavmodels = [];
        level thread onPlayerConnect();
    }

    level thread UAVTracker();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        level.activeUAVs[var_0.guid] = 0;
        level.activeUAVs[var_0.guid + "_radarStrength"] = 0;
        level.activeCounterUAVs[var_0.guid] = 0;
        level.radarmode[var_0.guid] = "normal_radar";
    }
}

rotateUAVRig()
{
    for (;;)
    {
        self rotateyaw( -360, 60 );
        wait 60;
    }
}

launchUAV( var_0, var_1, var_2, var_3 )
{
    if ( var_3 == "counter_uav" )
        var_4 = 1;
    else
        var_4 = 0;

    var_5 = spawn( "script_model", level.UAVRig gettagorigin( "tag_origin" ) );
    var_5.value = 1;

    if ( var_3 == "double_uav" )
        var_5.value = 2;
    else if ( var_3 == "triple_uav" )
        var_5.value = 3;

    if ( var_5.value != 3 )
    {
        var_5 setmodel( "vehicle_uav_static_mp" );
        var_5 thread damageTracker( var_4, 0 );
    }
    else
    {
        var_5 setmodel( "vehicle_phantom_ray" );
        var_5 thread spawnFxDelay( level.uav_fx["trail"], "tag_jet_trail" );
        var_5 thread damageTracker( var_4, 1 );
    }

    var_5.team = var_1;
    var_5.owner = var_0;
    var_5.timeToAdd = 0;
    var_5 thread handleIncomingStinger();
    var_5 addUAVModel();
    var_6 = randomintrange( 3000, 5000 );

    if ( isdefined( level.spawnpoints ) )
        var_7 = level.spawnpoints;
    else
        var_7 = level.startSpawnPoints;

    var_8 = var_7[0];

    foreach ( var_10 in var_7 )
    {
        if ( var_10.origin[2] < var_8.origin[2] )
            var_8 = var_10;
    }

    var_12 = var_8.origin[2];
    var_13 = level.UAVRig.origin[2];

    if ( var_12 < 0 )
    {
        var_13 += var_12 * -1;
        var_12 = 0;
    }

    var_14 = var_13 - var_12;

    if ( var_14 + var_6 > 8100.0 )
        var_6 -= ( var_14 + var_6 - 8100.0 );

    var_15 = randomint( 360 );
    var_16 = randomint( 2000 ) + 5000;
    var_17 = cos( var_15 ) * var_16;
    var_18 = sin( var_15 ) * var_16;
    var_19 = vectornormalize( ( var_17, var_18, var_6 ) );
    var_19 *= randomintrange( 6000, 7000 );
    var_5 linkto( level.UAVRig, "tag_origin", var_19, ( 0, var_15 - 90, 0 ) );
    var_5 thread updateUAVModelVisibility();

    if ( var_4 )
    {
        var_5.uavType = "counter";
        var_5 addActiveCounterUAV();
    }
    else
    {
        var_5 addActiveUAV();
        var_5.uavType = "standard";
    }

    if ( isdefined( level.activeUAVs[var_1] ) )
    {
        foreach ( var_21 in level.uavmodels[var_1] )
        {
            if ( var_21 == var_5 )
                continue;

            if ( var_21.uavType == "counter" && var_4 )
            {
                var_21.timeToAdd = var_21.timeToAdd + 5;
                continue;
            }

            if ( var_21.uavType == "standard" && !var_4 )
                var_21.timeToAdd = var_21.timeToAdd + 5;
        }
    }

    level notify( "uav_update" );

    switch ( var_3 )
    {
        case "uav_strike":
            var_2 = 2;
            break;
        default:
            var_2 -= 7;
            break;
    }

    var_5 waittill_notify_or_timeout_hostmigration_pause( "death", var_2 );

    if ( var_5.damagetaken < var_5.maxHealth )
    {
        var_5 unlink();
        var_23 = var_5.origin + anglestoforward( var_5.angles ) * 20000;
        var_5 moveto( var_23, 60 );
        playfxontag( level._effect["ac130_engineeffect"], var_5, "tag_origin" );
        var_5 waittill_notify_or_timeout_hostmigration_pause( "death", 3 );

        if ( var_5.damagetaken < var_5.maxHealth )
        {
            var_5 notify( "leaving" );
            var_5.isLeaving = 1;
            var_5 moveto( var_23, 4, 4, 0.0 );
        }

        var_5 waittill_notify_or_timeout_hostmigration_pause( "death", 4 + var_5.timeToAdd );
    }

    if ( var_4 )
        var_5 removeActiveCounterUAV();
    else
        var_5 removeActiveUAV();

    var_5 delete();
    var_5 removeUAVModel();

    if ( var_3 == "directional_uav" )
    {
        var_0.radarshowenemydirection = 0;

        if ( level.teamBased )
        {
            foreach ( var_25 in level.players )
            {
                if ( var_25.pers["team"] == var_1 )
                    var_25.radarshowenemydirection = 0;
            }
        }
    }

    level notify( "uav_update" );
}

spawnFxDelay( var_0, var_1 )
{
    self endon( "death" );
    level endon( "game_ended" );
    wait 0.5;
    playfxontag( var_0, self, var_1 );
}

monitorUAVStrike()
{
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = common_scripts\utility::waittill_any_return( "death", "uav_strike_cancel", "uav_strike_successful" );

        if ( var_0 == "uav_strike_successful" )
        {
            return 1;
            continue;
        }

        return 0;
    }
}

showLazeMessage()
{
    var_0 = maps\mp\gametypes\_hud_util::createFontString( "bigfixed", 0.75 );
    var_0 maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, 150 );
    var_0 settext( &"MP_LASE_TARGET_FOR_PREDATOR_STRIKE" );
    common_scripts\utility::waittill_any_timeout( 4.0, "death", "uav_strike_cancel", "uav_strike_successful" );
    var_0 maps\mp\gametypes\_hud_util::destroyElem();
}

waitForLazeDiscard()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "uav_strike_used" );

    for (;;)
    {
        self waittill( "weapon_change",  var_0  );

        if ( var_0 != "uav_strike_marker_mp" )
        {
            self notify( "uav_strike_cancel" );
            break;
            continue;
        }

        wait 0.05;
    }
}

waitForLazedTarget()
{
    level endon( "game_ended" );
    self endon( "death" );
    thread showLazeMessage();
    thread waitForLazeDiscard();
    var_0 = common_scripts\utility::getLastWeapon();
    var_1 = undefined;
    var_2 = self getweaponslistprimaries();

    foreach ( var_4 in var_2 )
    {
        if ( var_4 != var_0 )
        {
            var_1 = var_4;
            self takeweapon( var_1 );
            break;
        }
    }

    maps\mp\_utility::_giveWeapon( "uav_strike_marker_mp" );
    self switchtoweapon( "uav_strike_marker_mp" );
    var_6 = undefined;

    for (;;)
    {
        var_7 = common_scripts\utility::waittill_any_return( "weapon_fired", "uav_strike_cancel" );

        if ( var_7 == "uav_strike_cancel" )
            break;

        var_8 = self geteye();
        var_9 = anglestoforward( self getplayerangles() );
        var_10 = var_8 + var_9 * 15000;
        var_6 = bullettrace( var_8, var_10, 1, self );

        if ( isdefined( var_6["position"] ) )
            break;
    }

    if ( isdefined( var_6 ) )
    {
        self notify( "uav_strike_used" );
        var_11 = var_6["position"];
        var_12 = spawnfx( level._effect["laserTarget"], var_11 );
        triggerfx( var_12 );
        var_12 thread waitFxEntDie();
        magicbullet( "uav_strike_projectile_mp", var_11 + ( 0, 0, 4000 ), var_11, self );
    }

    self takeweapon( "uav_strike_marker_mp" );

    if ( var_7 != "uav_strike_cancel" )
        self switchtoweapon( var_0 );

    if ( isdefined( var_1 ) )
        maps\mp\_utility::_giveWeapon( var_1 );

    if ( isdefined( var_6 ) )
        self notify( "uav_strike_successful" );
}

waitFxEntDie()
{
    wait 2;
    self delete();
}

waittill_notify_or_timeout_hostmigration_pause( var_0, var_1 )
{
    self endon( var_0 );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_1 );
}

updateUAVModelVisibility()
{
    self endon( "death" );

    for (;;)
    {
        level common_scripts\utility::waittill_either( "joined_team", "uav_update" );
        self hide();

        foreach ( var_1 in level.players )
        {
            if ( level.teamBased )
            {
                if ( var_1.team != self.team )
                    self showtoplayer( var_1 );

                continue;
            }

            if ( isdefined( self.owner ) && var_1 == self.owner )
                continue;

            self showtoplayer( var_1 );
        }
    }
}

damageTracker( var_0, var_1 )
{
    level endon( "game_ended" );
    self setcandamage( 1 );
    self.health = 999999;

    if ( var_1 )
        self.maxHealth = 2000;
    else
        self.maxHealth = 1000;

    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage",  var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11  );

        if ( !isplayer( var_3 ) )
        {
            if ( !isdefined( self ) )
                return;

            continue;
        }

        if ( isdefined( var_10 ) && var_10 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;
        var_12 = var_2;

        if ( isplayer( var_3 ) )
        {
            var_3 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "" );

            if ( var_6 == "MOD_RIFLE_BULLET" || var_6 == "MOD_PISTOL_BULLET" )
            {
                if ( var_3 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                    var_12 += var_2 * level.armorPiercingMod;
            }
        }

        if ( isdefined( var_11 ) )
        {
            switch ( var_11 )
            {
                case "stinger_mp":
                case "javelin_mp":
                    self.largeProjectileDamage = 1;
                    var_12 = self.maxHealth + 1;
                    break;
                case "sam_projectile_mp":
                    self.largeProjectileDamage = 1;
                    var_13 = 0.25;

                    if ( var_1 )
                        var_13 = 0.15;

                    var_12 = self.maxHealth * var_13;
                    break;
            }

            maps\mp\killstreaks\_killstreaks::killstreakhit( var_3, var_11, self );
        }

        self.damagetaken = self.damagetaken + var_12;

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isplayer( var_3 ) && ( !isdefined( self.owner ) || var_3 != self.owner ) )
            {
                self hide();
                var_14 = anglestoright( self.angles ) * 200;
                playfx( level.uav_fx["explode"], self.origin, var_14 );

                if ( isdefined( self.uavType ) && self.uavType == "remote_mortar" )
                    thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_remote_mortar", var_3 );
                else if ( var_0 )
                    thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_counter_uav", var_3 );
                else
                    thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_uav", var_3 );

                thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, var_3, var_2, var_6, var_11 );
                var_3 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 50, var_11, var_6 );
                var_3 notify( "destroyed_killstreak" );

                if ( isdefined( self.UAVRemoteMarkedBy ) && self.UAVRemoteMarkedBy != var_3 )
                    self.UAVRemoteMarkedBy thread maps\mp\killstreaks\_remoteuav::remoteUAV_processTaggedAssist();
            }

            self notify( "death" );
            return;
        }
    }
}

tryUseUAV( var_0 )
{
    return useUAV( "uav" );
}

tryUseUAVSupport( var_0 )
{
    return useUAV( "uav_support" );
}

tryUseDoubleUAV( var_0 )
{
    return useUAV( "double_uav" );
}

tryUseTripleUAV( var_0 )
{
    return useUAV( "triple_uav" );
}

tryUseCounterUAV( var_0 )
{
    return useUAV( "counter_uav" );
}

UAVStrikeSetup()
{
    self.usedStrikeUAV = 0;
}

tryUseUAVStrike( var_0 )
{
    if ( self.usedStrikeUAV == 0 )
    {
        self.usedStrikeUAV = 1;
        useUAV( "uav_strike" );
    }

    thread waitForLazedTarget();
    return monitorUAVStrike();
}

tryUseDirectionalUAV( var_0 )
{
    return useUAV( "directional_uav" );
}

useUAV( var_0 )
{
    if ( !maps\mp\_utility::validateUseStreak() )
        return 0;

    maps\mp\_matchdata::logKillstreakEvent( var_0, self.origin );
    var_1 = self.pers["team"];
    var_2 = level.radarViewTime;
    level thread launchUAV( self, var_1, var_2, var_0 );

    switch ( var_0 )
    {
        case "counter_uav":
            self notify( "used_counter_uav" );
            break;
        case "double_uav":
            self notify( "used_double_uav" );
            break;
        case "triple_uav":
            level thread maps\mp\_utility::teamPlayerCardSplash( "used_triple_uav", self, var_1 );
            self notify( "used_triple_uav" );
            break;
        case "directional_uav":
            self.radarshowenemydirection = 1;

            if ( level.teamBased )
            {
                foreach ( var_4 in level.players )
                {
                    if ( var_4.pers["team"] == var_1 )
                        var_4.radarshowenemydirection = 1;
                }
            }

            level thread maps\mp\_utility::teamPlayerCardSplash( "used_directional_uav", self, var_1 );
            self notify( "used_directional_uav" );
            break;
        default:
            self notify( "used_uav" );
            break;
    }

    return 1;
}

UAVTracker()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "uav_update" );

        if ( level.teamBased )
        {
            updateTeamUAVStatus( "allies" );
            updateTeamUAVStatus( "axis" );
            continue;
        }

        updatePlayersUAVStatus();
    }
}

_getRadarStrength( var_0 )
{
    var_1 = 0;
    var_2 = 0;

    foreach ( var_4 in level.uavmodels[var_0] )
    {
        if ( var_4.uavType == "counter" )
            continue;

        if ( var_4.uavType == "remote_mortar" )
            continue;

        var_1 += var_4.value;
    }

    foreach ( var_4 in level.uavmodels[level.otherTeam[var_0]] )
    {
        if ( var_4.uavType != "counter" )
            continue;

        var_2 += var_4.value;
    }

    if ( var_2 > 0 )
        var_8 = -3;
    else
        var_8 = var_1;

    var_9 = getuavstrengthmin();
    var_10 = getuavstrengthmax();

    if ( var_8 <= var_9 )
        var_8 = var_9;
    else if ( var_8 >= var_10 )
        var_8 = var_10;

    return var_8;
}

updateTeamUAVStatus( var_0 )
{
    var_1 = _getRadarStrength( var_0 );
    setteamradarstrength( var_0, var_1 );

    if ( var_1 >= getuavstrengthlevelneutral() )
        unblockteamradar( var_0 );
    else
        blockteamradar( var_0 );

    if ( var_1 <= getuavstrengthlevelneutral() )
    {
        setTeamRadarWrapper( var_0, 0 );
        updateTeamUAVType( var_0 );
        return;
    }

    if ( var_1 >= getuavstrengthlevelshowenemyfastsweep() )
        level.radarmode[var_0] = "fast_radar";
    else
        level.radarmode[var_0] = "normal_radar";

    updateTeamUAVType( var_0 );
    setTeamRadarWrapper( var_0, 1 );
}

updatePlayersUAVStatus()
{
    var_0 = getuavstrengthmin();
    var_1 = getuavstrengthmax();
    var_2 = getuavstrengthlevelshowenemydirectional();

    foreach ( var_4 in level.players )
    {
        var_5 = level.activeUAVs[var_4.guid + "_radarStrength"];

        foreach ( var_7 in level.players )
        {
            if ( var_7 == var_4 )
                continue;

            var_8 = level.activeCounterUAVs[var_7.guid];

            if ( var_8 > 0 )
            {
                var_5 = -3;
                break;
            }
        }

        if ( var_5 <= var_0 )
            var_5 = var_0;
        else if ( var_5 >= var_1 )
            var_5 = var_1;

        var_4.radarstrength = var_5;

        if ( var_5 >= getuavstrengthlevelneutral() )
            var_4.isradarblocked = 0;
        else
            var_4.isradarblocked = 1;

        if ( var_5 <= getuavstrengthlevelneutral() )
        {
            var_4.hasradar = 0;
            var_4.radarshowenemydirection = 0;
            continue;
        }

        if ( var_5 >= getuavstrengthlevelshowenemyfastsweep() )
            var_4.radarmode = "fast_radar";
        else
            var_4.radarmode = "normal_radar";

        var_4.radarshowenemydirection = var_5 >= var_2;
        var_4.hasradar = 1;
    }
}

blockPlayerUAV()
{
    self endon( "disconnect" );
    self notify( "blockPlayerUAV" );
    self endon( "blockPlayerUAV" );
    self.isradarblocked = 1;
    wait(level.uavBlockTime);
    self.isradarblocked = 0;
}

updateTeamUAVType( var_0 )
{
    var_1 = _getRadarStrength( var_0 ) >= getuavstrengthlevelshowenemydirectional();

    foreach ( var_3 in level.players )
    {
        if ( var_3.team == "spectator" )
            continue;

        var_3.radarmode = level.radarmode[var_3.team];

        if ( var_3.team == var_0 )
            var_3.radarshowenemydirection = var_1;
    }
}

usePlayerUAV( var_0, var_1 )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    self notify( "usePlayerUAV" );
    self endon( "usePlayerUAV" );

    if ( var_0 )
        self.radarmode = "fast_radar";
    else
        self.radarmode = "normal_radar";

    self.hasradar = 1;
    wait(var_1);
    self.hasradar = 0;
}

setTeamRadarWrapper( var_0, var_1 )
{
    setteamradar( var_0, var_1 );
    level notify( "radar_status_change",  var_0  );
}

handleIncomingStinger()
{
    level endon( "game_ended" );
    self endon( "death" );

    for (;;)
    {
        level waittill( "stinger_fired",  var_0, var_1, var_2  );

        if ( !isdefined( var_2 ) || var_2 != self )
            continue;

        var_1 thread stingerProximityDetonate( var_2, var_0 );
    }
}

stingerProximityDetonate( var_0, var_1 )
{
    self endon( "death" );
    var_2 = distance( self.origin, var_0 getpointinbounds( 0, 0, 0 ) );
    var_3 = var_0 getpointinbounds( 0, 0, 0 );

    for (;;)
    {
        if ( !isdefined( var_0 ) )
            var_4 = var_3;
        else
            var_4 = var_0 getpointinbounds( 0, 0, 0 );

        var_3 = var_4;
        var_5 = distance( self.origin, var_4 );

        if ( var_5 < var_2 )
            var_2 = var_5;

        if ( var_5 > var_2 )
        {
            if ( var_5 > 1536 )
                return;

            radiusdamage( self.origin, 1536, 600, 600, var_1, "MOD_EXPLOSIVE", "stinger_mp" );
            playfx( level.stingerFXid, self.origin );
            self hide();
            self notify( "deleted" );
            wait 0.05;
            self delete();
            var_1 notify( "killstreak_destroyed" );
        }

        wait 0.05;
    }
}

addUAVModel()
{
    if ( level.teamBased )
        level.uavmodels[self.team][level.uavmodels[self.team].size] = self;
    else
        level.uavmodels[self.owner.guid + "_" + gettime()] = self;
}

removeUAVModel()
{
    var_0 = [];

    if ( level.teamBased )
    {
        var_1 = self.team;

        foreach ( var_3 in level.uavmodels[var_1] )
        {
            if ( !isdefined( var_3 ) )
                continue;

            var_0[var_0.size] = var_3;
        }

        level.uavmodels[var_1] = var_0;
    }
    else
    {
        foreach ( var_3 in level.uavmodels )
        {
            if ( !isdefined( var_3 ) )
                continue;

            var_0[var_0.size] = var_3;
        }

        level.uavmodels = var_0;
    }
}

addActiveUAV()
{
    if ( level.teamBased )
        level.activeUAVs[self.team]++;
    else
    {
        level.activeUAVs[self.owner.guid]++;
        level.activeUAVs[self.owner.guid + "_radarStrength"] = level.activeUAVs[self.owner.guid + "_radarStrength"] + self.value;
    }
}

addActiveCounterUAV()
{
    if ( level.teamBased )
        level.activeCounterUAVs[self.team]++;
    else
        level.activeCounterUAVs[self.owner.guid]++;
}

removeActiveUAV()
{
    if ( level.teamBased )
    {
        level.activeUAVs[self.team]--;

        if ( !level.activeUAVs[self.team] )
            return;
    }
    else if ( isdefined( self.owner ) )
    {
        level.activeUAVs[self.owner.guid]--;
        level.activeUAVs[self.owner.guid + "_radarStrength"] = level.activeUAVs[self.owner.guid + "_radarStrength"] - self.value;
    }
}

removeActiveCounterUAV()
{
    if ( level.teamBased )
    {
        level.activeCounterUAVs[self.team]--;

        if ( !level.activeCounterUAVs[self.team] )
            return;
    }
    else if ( isdefined( self.owner ) )
        level.activeCounterUAVs[self.owner.guid]--;
}
