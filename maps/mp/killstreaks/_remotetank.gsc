// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.killstreakFuncs["remote_tank"] = ::tryUseRemoteTank;
    level.tankSettings = [];
    level.tankSettings["remote_tank"] = spawnstruct();
    level.tankSettings["remote_tank"].timeOut = 60.0;
    level.tankSettings["remote_tank"].health = 99999;
    level.tankSettings["remote_tank"].maxHealth = 1000;
    level.tankSettings["remote_tank"].streakName = "remote_tank";
    level.tankSettings["remote_tank"].mgTurretInfo = "ugv_turret_mp";
    level.tankSettings["remote_tank"].glTurretInfo = "remote_tank_projectile_mp";
    level.tankSettings["remote_tank"].sentryModeOff = "sentry_offline";
    level.tankSettings["remote_tank"].weaponInfo = "remote_ugv_mp";
    level.tankSettings["remote_tank"].modelBase = "vehicle_ugv_talon_mp";
    level.tankSettings["remote_tank"].modelMGTurret = "vehicle_ugv_talon_gun_mp";
    level.tankSettings["remote_tank"].modelPlacement = "vehicle_ugv_talon_obj";
    level.tankSettings["remote_tank"].modelPlacementFailed = "vehicle_ugv_talon_obj_red";
    level.tankSettings["remote_tank"].modelDestroyed = "vehicle_ugv_talon_mp";
    level.tankSettings["remote_tank"].stringPlace = &"MP_REMOTE_TANK_PLACE";
    level.tankSettings["remote_tank"].stringCannotPlace = &"MP_REMOTE_TANK_CANNOT_PLACE";
    level.tankSettings["remote_tank"].laptopInfo = "killstreak_remote_tank_laptop_mp";
    level.tankSettings["remote_tank"].remoteInfo = "killstreak_remote_tank_remote_mp";
    makedvarserverinfo( "ui_remoteTankUseTime", level.tankSettings["remote_tank"].timeOut );
    precachemenu( "remotetank_timer" );

    foreach ( var_1 in level.tankSettings )
    {
        precachemodel( var_1.modelBase );
        precachemodel( var_1.modelMGTurret );
        precachemodel( var_1.modelPlacement );
        precachemodel( var_1.modelPlacementFailed );
        precachemodel( var_1.modelDestroyed );
        precacheturret( var_1.mgTurretInfo );
        precachevehicle( var_1.weaponInfo );
        precachestring( var_1.stringPlace );
        precachestring( var_1.stringCannotPlace );
        precacheitem( var_1.laptopInfo );
        precacheitem( var_1.remoteInfo );
        precacheitem( var_1.glTurretInfo );
    }

    level._effect["remote_tank_dying"] = loadfx( "explosions/killstreak_explosion_quick" );
    level._effect["remote_tank_explode"] = loadfx( "explosions/bouncing_betty_explosion" );
    level._effect["remote_tank_spark"] = loadfx( "impacts/large_metal_painted_hit" );
    level._effect["remote_tank_antenna_light_mp"] = loadfx( "misc/aircraft_light_red_blink" );
    level._effect["remote_tank_camera_light_mp"] = loadfx( "misc/aircraft_light_wingtip_green" );
    level.remote_tank_armor_bulletdamage = 0.5;
}

tryUseRemoteTank( var_0 )
{
    var_1 = 1;

    if ( !maps\mp\_utility::validateUseStreak() )
        return 0;
    else if ( maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount + var_1 >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        return 0;
    }

    maps\mp\_utility::incrementFauxVehicleCount();
    var_2 = giveTank( var_0, "remote_tank" );

    if ( var_2 )
    {
        maps\mp\_matchdata::logKillstreakEvent( "remote_tank", self.origin );
        thread maps\mp\_utility::teamPlayerCardSplash( "used_remote_tank", self );
        takeKillstreakWeapons( "remote_tank" );
    }
    else
        maps\mp\_utility::decrementFauxVehicleCount();

    self.isCarrying = 0;
    return var_2;
}

takeKillstreakWeapons( var_0 )
{
    var_1 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( level.tankSettings[var_0].streakName );
    maps\mp\killstreaks\_killstreaks::takeKillstreakWeaponIfNoDupe( var_1 );
    self takeweapon( level.tankSettings[var_0].laptopInfo );
    self takeweapon( level.tankSettings[var_0].remoteInfo );
}

removePerks()
{
    if ( maps\mp\_utility::_hasPerk( "specialty_explosivebullets" ) )
    {
        self.restorePerk = "specialty_explosivebullets";
        maps\mp\_utility::_unsetPerk( "specialty_explosivebullets" );
    }
}

restorePerks()
{
    if ( isdefined( self.restorePerk ) )
    {
        maps\mp\_utility::givePerk( self.restorePerk, 0 );
        self.restorePerk = undefined;
    }
}

waitRestorePerks()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    wait 0.05;
    restorePerks();
}

removeWeapons()
{
    var_0 = self getweaponslistprimaries();

    foreach ( var_2 in var_0 )
    {
        var_3 = strtok( var_2, "_" );

        if ( var_3[0] == "alt" )
        {
            self.restoreWeaponClipAmmo[var_2] = self getweaponammoclip( var_2 );
            self.restoreWeaponStockAmmo[var_2] = self getweaponammostock( var_2 );
            continue;
        }

        self.restoreWeaponClipAmmo[var_2] = self getweaponammoclip( var_2 );
        self.restoreWeaponStockAmmo[var_2] = self getweaponammostock( var_2 );
    }

    self.weaponstorestore = [];

    foreach ( var_2 in var_0 )
    {
        var_3 = strtok( var_2, "_" );
        self.weaponstorestore[self.weaponstorestore.size] = var_2;

        if ( var_3[0] == "alt" )
            continue;

        self takeweapon( var_2 );
    }
}

restoreWeapons()
{
    if ( !isdefined( self.restoreWeaponClipAmmo ) || !isdefined( self.restoreWeaponStockAmmo ) || !isdefined( self.weaponstorestore ) )
        return;

    var_0 = [];

    foreach ( var_2 in self.weaponstorestore )
    {
        var_3 = strtok( var_2, "_" );

        if ( var_3[0] == "alt" )
        {
            var_0[var_0.size] = var_2;
            continue;
        }

        maps\mp\_utility::_giveWeapon( var_2 );

        if ( isdefined( self.restoreWeaponClipAmmo[var_2] ) )
            self setweaponammoclip( var_2, self.restoreWeaponClipAmmo[var_2] );

        if ( isdefined( self.restoreWeaponStockAmmo[var_2] ) )
            self setweaponammostock( var_2, self.restoreWeaponStockAmmo[var_2] );
    }

    foreach ( var_6 in var_0 )
    {
        if ( isdefined( self.restoreWeaponClipAmmo[var_6] ) )
            self setweaponammoclip( var_6, self.restoreWeaponClipAmmo[var_6] );

        if ( isdefined( self.restoreWeaponStockAmmo[var_6] ) )
            self setweaponammostock( var_6, self.restoreWeaponStockAmmo[var_6] );
    }

    self.restoreWeaponClipAmmo = undefined;
    self.restoreWeaponStockAmmo = undefined;
}

waitRestoreWeapons()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    wait 0.05;
    restoreWeapons();
}

giveTank( var_0, var_1 )
{
    var_2 = createTankForPlayer( var_1, self );
    var_2.lifeId = var_0;
    removePerks();
    removeWeapons();
    var_3 = setCarryingTank( var_2, 1 );
    thread restorePerks();
    thread restoreWeapons();

    if ( !isdefined( var_3 ) )
        var_3 = 0;

    return var_3;
}

createTankForPlayer( var_0, var_1 )
{
    var_2 = spawnturret( "misc_turret", var_1.origin + ( 0, 0, 25 ), level.tankSettings[var_0].mgTurretInfo );
    var_2.angles = var_1.angles;
    var_2.tankType = var_0;
    var_2.owner = var_1;
    var_2 setmodel( level.tankSettings[var_0].modelBase );
    var_2 maketurretinoperable();
    var_2 setturretmodechangewait( 1 );
    var_2 setmode( "sentry_offline" );
    var_2 makeunusable();
    var_2 setsentryowner( var_1 );
    return var_2;
}

setCarryingTank( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    var_0 thread tank_setCarried( self );
    common_scripts\utility::_disableWeapon();
    self notifyonplayercommand( "place_tank", "+attack" );
    self notifyonplayercommand( "place_tank", "+attack_akimbo_accessible" );
    self notifyonplayercommand( "cancel_tank", "+actionslot 4" );

    if ( !level.console )
    {
        self notifyonplayercommand( "cancel_tank", "+actionslot 5" );
        self notifyonplayercommand( "cancel_tank", "+actionslot 6" );
        self notifyonplayercommand( "cancel_tank", "+actionslot 7" );
    }

    for (;;)
    {
        var_2 = common_scripts\utility::waittill_any_return( "place_tank", "cancel_tank", "force_cancel_placement" );

        if ( var_2 == "cancel_tank" || var_2 == "force_cancel_placement" )
        {
            if ( !var_1 && var_2 == "cancel_tank" )
                continue;

            if ( level.console )
            {
                var_3 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( level.tankSettings[var_0.tankType].streakName );

                if ( isdefined( self.killstreakIndexWeapon ) && var_3 == maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( self.pers["killstreaks"][self.killstreakIndexWeapon].streakName ) && !self getweaponslistitems().size )
                {
                    maps\mp\_utility::_giveWeapon( var_3, 0 );
                    maps\mp\_utility::_setActionSlot( 4, "weapon", var_3 );
                }
            }

            var_0 tank_setCancelled();
            common_scripts\utility::_enableWeapon();
            return 0;
        }

        if ( !var_0.canBePlaced )
            continue;

        var_0 thread tank_setPlaced();
        common_scripts\utility::_enableWeapon();
        return 1;
    }
}

tank_setCarried( var_0 )
{
    self setmodel( level.tankSettings[self.tankType].modelPlacement );
    self setsentrycarrier( var_0 );
    self setcontents( 0 );
    self setcandamage( 0 );
    self.carriedBy = var_0;
    var_0.isCarrying = 1;
    var_0 thread updateTankPlacement( self );
    thread tank_onCarrierDeath( var_0 );
    thread tank_onCarrierDisconnect( var_0 );
    thread tank_onGameEnded();
    self notify( "carried" );
}

updateTankPlacement( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 endon( "placed" );
    var_0 endon( "death" );
    var_0.canBePlaced = 1;
    var_1 = -1;

    for (;;)
    {
        var_2 = self canplayerplacetank( 25.0, 25.0, 50.0, 40.0, 80.0, 0.7 );
        var_0.origin = var_2["origin"];
        var_0.angles = var_2["angles"];
        var_0.canBePlaced = self isonground() && var_2["result"] && abs( var_2["origin"][2] - self.origin[2] ) < 20;

        if ( var_0.canBePlaced != var_1 )
        {
            if ( var_0.canBePlaced )
            {
                var_0 setmodel( level.tankSettings[var_0.tankType].modelPlacement );

                if ( self.team != "spectator" )
                    self forceusehinton( level.tankSettings[var_0.tankType].stringPlace );
            }
            else
            {
                var_0 setmodel( level.tankSettings[var_0.tankType].modelPlacementFailed );

                if ( self.team != "spectator" )
                    self forceusehinton( level.tankSettings[var_0.tankType].stringCannotPlace );
            }
        }

        var_1 = var_0.canBePlaced;
        wait 0.05;
    }
}

tank_onCarrierDeath( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 waittill( "death" );
    tank_setCancelled();
}

tank_onCarrierDisconnect( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 waittill( "disconnect" );
    tank_setCancelled();
}

tank_onGameEnded( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    level waittill( "game_ended" );
    tank_setCancelled();
}

tank_setCancelled()
{
    if ( isdefined( self.carriedBy ) )
        self.carriedBy forceusehintoff();

    if ( isdefined( self.owner ) )
        self.owner.isCarrying = 0;

    self delete();
}

tank_setPlaced()
{
    self endon( "death" );
    level endon( "game_ended" );
    self notify( "placed" );
    self.carriedBy forceusehintoff();
    self.carriedBy = undefined;

    if ( !isdefined( self.owner ) )
        return 0;

    var_0 = self.owner;
    var_0.isCarrying = 0;
    var_1 = createTank( self );

    if ( !isdefined( var_1 ) )
        return 0;

    var_1 playsound( "sentry_gun_plant" );
    var_1 notify( "placed" );
    var_1 thread tank_setActive();
    self delete();
}

tank_giveWeaponOnPlaced()
{
    self endon( "death" );
    level endon( "game_ended" );

    if ( !isdefined( self.owner ) )
        return;

    var_0 = self.owner;
    var_0 endon( "death" );
    self waittill( "placed" );
    var_0 takeKillstreakWeapons( self.tankType );
    var_0 maps\mp\_utility::_giveWeapon( level.tankSettings[self.tankType].laptopInfo );
    var_0 switchtoweaponimmediate( level.tankSettings[self.tankType].laptopInfo );
}

createTank( var_0 )
{
    var_1 = var_0.owner;
    var_2 = var_0.tankType;
    var_3 = var_0.lifeId;
    var_4 = spawnvehicle( level.tankSettings[var_2].modelBase, var_2, level.tankSettings[var_2].weaponInfo, var_0.origin, var_0.angles, var_1 );

    if ( !isdefined( var_4 ) )
        return undefined;

    var_5 = var_4 gettagorigin( "tag_turret_attach" );
    var_6 = spawnturret( "misc_turret", var_5, level.tankSettings[var_2].mgTurretInfo, 0 );
    var_6 linkto( var_4, "tag_turret_attach", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    var_6 setmodel( level.tankSettings[var_2].modelMGTurret );
    var_6.health = level.tankSettings[var_2].health;
    var_6.owner = var_1;
    var_6.angles = var_1.angles;
    var_6.specialDamageCallback = ::Callback_VehicleDamage;
    var_6.tank = var_4;
    var_6 makeunusable();
    var_6 setdefaultdroppitch( 0 );
    var_6 setcandamage( 0 );
    var_4.specialDamageCallback = ::Callback_VehicleDamage;
    var_4.lifeId = var_3;
    var_4.team = var_1.team;
    var_4.owner = var_1;
    var_4.mgTurret = var_6;
    var_4.health = level.tankSettings[var_2].health;
    var_4.maxHealth = level.tankSettings[var_2].maxHealth;
    var_4.damagetaken = 0;
    var_4.destroyed = 0;
    var_4 setcandamage( 0 );
    var_4.tankType = var_2;
    var_6 setturretmodechangewait( 1 );
    var_4 tank_setInactive();
    var_6 setsentryowner( var_1 );
    var_1.using_remote_tank = 0;
    var_1 setplayerdata( "ugvMissile", 1 );
    var_1 setplayerdata( "ugvDamageFade", 1.0 );
    var_1 setplayerdata( "ugvDamaged", 0 );
    var_1 setplayerdata( "ugvDamageState", 0 );
    var_1 setplayerdata( "ugvBullets", 0 );
    var_1 setplayerdata( "ugvMaxBullets", 0 );
    var_4.empGrenaded = 0;
    var_4.damageFade = 1.0;
    var_4 thread tank_incrementDamageFade();
    var_4 thread tank_watchLowHealth();
    var_4 thread tank_giveWeaponOnPlaced();
    return var_4;
}

tank_setActive()
{
    self endon( "death" );
    self.owner endon( "disconnect" );
    level endon( "game_ended" );
    self makeunusable();
    self.mgTurret maketurretsolid();
    self makevehiclesolidcapsule( 23, 23, 23 );

    if ( !isdefined( self.owner ) )
        return;

    var_0 = self.owner;
    var_1 = ( 0, 0, 20 );

    if ( level.teamBased )
    {
        self.team = var_0.team;
        self.mgTurret.team = var_0.team;
        self.mgTurret setturretteam( var_0.team );

        foreach ( var_3 in level.players )
        {
            if ( var_3 != var_0 && var_3.team == var_0.team )
            {
                var_4 = self.mgTurret maps\mp\_entityheadicons::setHeadIcon( var_3, maps\mp\gametypes\_teams::getTeamHeadIcon( self.team ), var_1, 10, 10, 0, 0.05, 0, 1, 0, 1 );

                if ( isdefined( var_4 ) )
                    var_4 settargetent( self );
            }
        }
    }

    thread tank_handleDisconnect();
    thread tank_handleChangeTeams();
    thread tank_handleDeath();
    thread tank_handleTimeout();
    thread tank_blinkyLightAntenna();
    thread tank_blinkyLightCamera();
    startUsingTank();
    var_0 openmenu( "remotetank_timer" );
}

startUsingTank()
{
    var_0 = self.owner;
    var_0 maps\mp\_utility::setUsingRemote( self.tankType );

    if ( getdvarint( "camera_thirdPerson" ) )
        var_0 maps\mp\_utility::setThirdPersonDOF( 0 );

    var_0.restoreAngles = var_0.angles;
    var_0 maps\mp\_utility::freezeControlsWrapper( 1 );
    var_1 = var_0 maps\mp\killstreaks\_killstreaks::initRideKillstreak();

    if ( var_1 != "success" )
    {
        if ( var_1 != "disconnect" )
            var_0 maps\mp\_utility::clearUsingRemote();

        if ( isdefined( var_0.disabledWeapon ) && var_0.disabledWeapon )
            var_0 common_scripts\utility::_enableWeapon();

        self notify( "death" );
        return 0;
    }

    var_0 maps\mp\_utility::freezeControlsWrapper( 0 );
    self.mgTurret setcandamage( 1 );
    self setcandamage( 1 );
    var_0 remotecontrolvehicle( self );
    var_0 remotecontrolturret( self.mgTurret );
    var_0 thread tank_WatchFiring( self );
    var_0 thread tank_FireMissiles( self );
    thread tank_Earthquake();
    thread tank_playerExit();
    var_0.using_remote_tank = 1;

    if ( var_0 maps\mp\_utility::isJuggernaut() )
        var_0.juggernautOverlay.alpha = 0;

    var_0 maps\mp\_utility::_giveWeapon( level.tankSettings[self.tankType].remoteInfo );
    var_0 switchtoweaponimmediate( level.tankSettings[self.tankType].remoteInfo );
    thread tank_handleDamage();
    self.mgTurret thread tank_turret_handleDamage();
}

tank_blinkyLightAntenna()
{
    self endon( "death" );

    for (;;)
    {
        playfxontag( common_scripts\utility::getfx( "remote_tank_antenna_light_mp" ), self.mgTurret, "tag_headlight_right" );
        wait 1.0;
        stopfxontag( common_scripts\utility::getfx( "remote_tank_antenna_light_mp" ), self.mgTurret, "tag_headlight_right" );
    }
}

tank_blinkyLightCamera()
{
    self endon( "death" );

    for (;;)
    {
        playfxontag( common_scripts\utility::getfx( "remote_tank_camera_light_mp" ), self.mgTurret, "tag_tail_light_right" );
        wait 2.0;
        stopfxontag( common_scripts\utility::getfx( "remote_tank_camera_light_mp" ), self.mgTurret, "tag_tail_light_right" );
    }
}

tank_setInactive()
{
    self.mgTurret setmode( level.tankSettings[self.tankType].sentryModeOff );

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( "none", ( 0, 0, 0 ) );
    else if ( isdefined( self.owner ) )
        maps\mp\_entityheadicons::setPlayerHeadIcon( undefined, ( 0, 0, 0 ) );

    if ( !isdefined( self.owner ) )
        return;

    var_0 = self.owner;

    if ( isdefined( var_0.using_remote_tank ) && var_0.using_remote_tank )
    {
        var_0 notify( "end_remote" );
        var_0 remotecontrolvehicleoff( self );
        var_0 remotecontrolturretoff( self.mgTurret );
        var_0 switchtoweapon( var_0 common_scripts\utility::getLastWeapon() );
        var_0 maps\mp\_utility::clearUsingRemote();
        var_0 setplayerangles( var_0.restoreAngles );

        if ( getdvarint( "camera_thirdPerson" ) )
            var_0 maps\mp\_utility::setThirdPersonDOF( 1 );

        if ( isdefined( var_0.disabledUsability ) && var_0.disabledUsability )
            var_0 common_scripts\utility::_enableUsability();

        var_0 takeKillstreakWeapons( level.tankSettings[self.tankType].streakName );
        var_0.using_remote_tank = 0;
        var_0 thread tank_freezeBuffer();
    }
}

tank_freezeBuffer()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    maps\mp\_utility::freezeControlsWrapper( 1 );
    wait 0.5;
    maps\mp\_utility::freezeControlsWrapper( 0 );
}

tank_handleDisconnect()
{
    self endon( "death" );
    self.owner waittill( "disconnect" );

    if ( isdefined( self.mgTurret ) )
        self.mgTurret notify( "death" );

    self notify( "death" );
}

tank_handleChangeTeams()
{
    self endon( "death" );
    self.owner common_scripts\utility::waittill_any( "joined_team", "joined_spectators" );
    self notify( "death" );
}

tank_handleTimeout()
{
    self endon( "death" );
    var_0 = level.tankSettings[self.tankType].timeOut;
    setdvar( "ui_remoteTankUseTime", var_0 );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_0 );
    self notify( "death" );
}

tank_handleDeath()
{
    level endon( "game_ended" );
    var_0 = self getentitynumber();
    addToUGVList( var_0 );
    self waittill( "death" );
    self playsound( "talon_destroyed" );
    removeFromUGVList( var_0 );
    self setmodel( level.tankSettings[self.tankType].modelDestroyed );

    if ( isdefined( self.owner ) && ( self.owner.using_remote_tank || self.owner maps\mp\_utility::isUsingRemote() ) )
    {
        self.owner setplayerdata( "ugvDamageState", 0 );
        tank_setInactive();
        self.owner.using_remote_tank = 0;

        if ( self.owner maps\mp\_utility::isJuggernaut() )
            self.owner.juggernautOverlay.alpha = 1;
    }

    self.mgTurret setdefaultdroppitch( 40 );
    self.mgTurret setsentryowner( undefined );
    self playsound( "sentry_explode" );
    playfxontag( level._effect["remote_tank_dying"], self.mgTurret, "tag_aim" );
    wait 2.0;
    playfx( level._effect["remote_tank_explode"], self.origin );
    self.mgTurret delete();
    maps\mp\_utility::decrementFauxVehicleCount();
    self delete();
}

Callback_VehicleDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 )
{
    var_12 = self;

    if ( isdefined( self.tank ) )
        var_12 = self.tank;

    if ( isdefined( var_12.alreadyDead ) && var_12.alreadyDead )
        return;

    if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( var_12.owner, var_1 ) )
        return;

    if ( isdefined( var_3 ) && var_3 & level.iDFLAGS_PENETRATION )
        var_12.wasDamagedFromBulletPenetration = 1;

    var_12.wasDamaged = 1;
    var_12.damageFade = 0.0;
    var_12.owner setplayerdata( "ugvDamaged", 1 );
    playfxontagforclients( level._effect["remote_tank_spark"], var_12, "tag_player", var_12.owner );

    if ( isdefined( var_5 ) )
    {
        switch ( var_5 )
        {
            case "artillery_mp":
            case "stealth_bomb_mp":
                var_2 *= 4;
                break;
        }
    }

    if ( var_4 == "MOD_MELEE" )
        var_2 = var_12.maxHealth * 0.5;

    var_13 = var_2;

    if ( isplayer( var_1 ) )
    {
        var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "remote_tank" );

        if ( var_4 == "MOD_RIFLE_BULLET" || var_4 == "MOD_PISTOL_BULLET" )
        {
            if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                var_13 += var_2 * level.armorPiercingMod;
        }

        if ( isexplosivedamagemod( var_4 ) )
            var_13 += var_2;
    }

    if ( isexplosivedamagemod( var_4 ) && ( isdefined( var_5 ) && var_5 == "destructible_car" ) )
        var_13 = var_12.maxHealth;

    if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
        var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "remote_tank" );

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
                var_12.largeProjectileDamage = 1;
                var_13 = var_12.maxHealth + 1;
                break;
            case "artillery_mp":
            case "stealth_bomb_mp":
                var_12.largeProjectileDamage = 0;
                var_13 = var_12.maxHealth * 0.5;
                break;
            case "bomb_site_mp":
                var_12.largeProjectileDamage = 0;
                var_13 = var_12.maxHealth + 1;
                break;
            case "emp_grenade_mp":
                var_13 = 0;
                var_12 thread tank_empgrenaded();
                break;
            case "ims_projectile_mp":
                var_12.largeProjectileDamage = 1;
                var_13 = var_12.maxHealth * 0.5;
                break;
        }

        maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_5, self );
    }

    var_12.damagetaken = var_12.damagetaken + var_13;
    var_12 playsound( "talon_damaged" );

    if ( var_12.damagetaken >= var_12.maxHealth )
    {
        if ( isplayer( var_1 ) && ( !isdefined( var_12.owner ) || var_1 != var_12.owner ) )
        {
            var_12.alreadyDead = 1;
            var_1 notify( "destroyed_killstreak",  var_5  );
            thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_remote_tank", var_1 );
            var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 300, var_5, var_4 );
            var_1 thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DESTROYED_REMOTE_TANK" );
            thread maps\mp\gametypes\_missions::vehicleKilled( var_12.owner, var_12, undefined, var_1, var_2, var_4, var_5 );
        }

        var_12 notify( "death" );
    }
}

tank_empgrenaded()
{
    self notify( "tank_EMPGrenaded" );
    self endon( "tank_EMPGrenaded" );
    self endon( "death" );
    self.owner endon( "disconnect" );
    level endon( "game_ended" );
    self.empGrenaded = 1;
    self.owner setplayerdata( "ugvDamageFade", 0 );
    var_0 = self.owner getplayerdata( "ugvBullets" );
    self.owner setplayerdata( "ugvBullets", 0 );
    self.owner setplayerdata( "ugvMissile", 0 );
    self.mgTurret turretfiredisable();
    wait 3.5;
    self.empGrenaded = 0;
    self.owner setplayerdata( "ugvBullets", var_0 );
    self.owner setplayerdata( "ugvMissile", 1 );
    self.mgTurret turretfireenable();
}

tank_incrementDamageFade()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = 0;

    for (;;)
    {
        if ( !self.empGrenaded )
        {
            if ( self.damageFade < 1.0 )
            {
                self.owner setplayerdata( "ugvDamageFade", self.damageFade );
                self.damageFade = self.damageFade + 0.1;
                var_0 = 1;
            }
            else if ( var_0 )
            {
                self.damageFade = 1.0;
                self.owner setplayerdata( "ugvDamageFade", self.damageFade );
                self.owner setplayerdata( "ugvDamaged", 0 );
                var_0 = 0;
            }
        }

        wait 0.1;
    }
}

tank_watchLowHealth()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = 0.1;
    var_1 = 1;
    var_2 = 1;

    for (;;)
    {
        if ( var_2 )
        {
            if ( self.damagetaken > 0 )
            {
                var_2 = 0;
                self.owner setplayerdata( "ugvDamageState", var_1 );
                var_1++;
            }
        }
        else if ( self.damagetaken >= self.maxHealth * ( var_0 * var_1 ) )
        {
            self.owner setplayerdata( "ugvDamageState", var_1 );
            var_1++;
        }

        wait 0.05;
    }
}

tank_handleDamage()
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

tank_turret_handleDamage()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( isdefined( self.specialDamageCallback ) && isdefined( self.tank ) && ( !isexplosivedamagemod( var_4 ) || isdefined( var_9 ) && isexplosivedamagemod( var_4 ) && ( var_9 == "stealth_bomb_mp" || var_9 == "artillery_mp" ) ) )
            self.tank [[ self.specialDamageCallback ]]( undefined, var_1, var_0, var_8, var_4, var_9, var_3, var_2, undefined, undefined, var_5, var_7 );
    }
}

tank_WatchFiring( var_0 )
{
    self endon( "disconnect" );
    self endon( "end_remote" );
    var_0 endon( "death" );
    var_1 = 50;
    var_2 = var_1;
    self setplayerdata( "ugvMaxBullets", var_1 );
    self setplayerdata( "ugvBullets", var_2 );
    var_3 = weaponfiretime( level.tankSettings[var_0.tankType].mgTurretInfo );

    for (;;)
    {
        if ( var_0.mgTurret isfiringvehicleturret() )
        {
            var_2--;
            self setplayerdata( "ugvBullets", var_2 );

            if ( var_2 <= 0 )
            {
                var_0.mgTurret turretfiredisable();
                wait 2.5;
                var_0 playsound( "talon_reload" );
                self playlocalsound( "talon_reload_plr" );
                var_2 = var_1;
                self setplayerdata( "ugvBullets", var_2 );
                var_0.mgTurret turretfireenable();
            }
        }

        wait(var_3);
    }
}

tank_FireMissiles( var_0 )
{
    self endon( "disconnect" );
    self endon( "end_remote" );
    level endon( "game_ended" );
    var_0 endon( "death" );
    var_1 = 0;

    for (;;)
    {
        if ( self fragbuttonpressed() && !var_0.empGrenaded )
        {
            var_2 = var_0.mgTurret.origin;
            var_3 = var_0.mgTurret.angles;

            switch ( var_1 )
            {
                case 0:
                    var_2 = var_0.mgTurret gettagorigin( "tag_missile1" );
                    var_3 = var_0.mgTurret gettagangles( "tag_player" );
                    break;
                case 1:
                    var_2 = var_0.mgTurret gettagorigin( "tag_missile2" );
                    var_3 = var_0.mgTurret gettagangles( "tag_player" );
                    break;
            }

            var_0 playsound( "talon_missile_fire" );
            self playlocalsound( "talon_missile_fire_plr" );
            var_4 = var_2 + anglestoforward( var_3 ) * 100;
            var_5 = magicbullet( level.tankSettings[var_0.tankType].glTurretInfo, var_2, var_4, self );
            var_1 = ( var_1 + 1 ) % 2;
            self setplayerdata( "ugvMissile", 0 );
            wait 5.0;
            var_0 playsound( "talon_rocket_reload" );
            self playlocalsound( "talon_rocket_reload_plr" );
            self setplayerdata( "ugvMissile", 1 );
            continue;
        }

        wait 0.05;
    }
}

tank_Earthquake()
{
    self endon( "death" );
    self.owner endon( "end_remote" );

    for (;;)
    {
        earthquake( 0.1, 0.25, self.mgTurret gettagorigin( "tag_player" ), 50 );
        wait 0.25;
    }
}

addToUGVList( var_0 )
{
    level.ugvs[var_0] = self;
}

removeFromUGVList( var_0 )
{
    level.ugvs[var_0] = undefined;
}

tank_playerExit()
{
    if ( !isdefined( self.owner ) )
        return;

    var_0 = self.owner;
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    var_0 endon( "end_remote" );
    self endon( "death" );

    for (;;)
    {
        var_1 = 0;

        while ( var_0 usebuttonpressed() )
        {
            var_1 += 0.05;

            if ( var_1 > 0.75 )
            {
                self notify( "death" );
                return;
            }

            wait 0.05;
        }

        wait 0.05;
    }
}
