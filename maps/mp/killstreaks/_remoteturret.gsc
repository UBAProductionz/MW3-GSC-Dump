// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.turretType = [];
    level.turretType["mg_turret"] = "remote_mg_turret";
    level.killstreakFuncs["remote_mg_turret"] = ::tryUseRemoteMGTurret;
    level.turretSettings = [];
    level.turretSettings["mg_turret"] = spawnstruct();
    level.turretSettings["mg_turret"].sentryModeOn = "manual";
    level.turretSettings["mg_turret"].sentryModeOff = "sentry_offline";
    level.turretSettings["mg_turret"].timeOut = 60.0;
    level.turretSettings["mg_turret"].health = 999999;
    level.turretSettings["mg_turret"].maxHealth = 1000;
    level.turretSettings["mg_turret"].streakName = "remote_mg_turret";
    level.turretSettings["mg_turret"].weaponinfo = "remote_turret_mp";
    level.turretSettings["mg_turret"].modelBase = "mp_remote_turret";
    level.turretSettings["mg_turret"].modelPlacement = "mp_remote_turret_placement";
    level.turretSettings["mg_turret"].modelPlacementFailed = "mp_remote_turret_placement_failed";
    level.turretSettings["mg_turret"].modelDestroyed = "mp_remote_turret";
    level.turretSettings["mg_turret"].teamSplash = "used_remote_mg_turret";
    level.turretSettings["mg_turret"].hintEnter = &"MP_ENTER_REMOTE_TURRET";
    level.turretSettings["mg_turret"].hintExit = &"MP_EARLY_EXIT";
    level.turretSettings["mg_turret"].hintPickUp = &"MP_DOUBLE_TAP_TO_CARRY";
    level.turretSettings["mg_turret"].placeString = &"MP_TURRET_PLACE";
    level.turretSettings["mg_turret"].cannotPlaceString = &"MP_TURRET_CANNOT_PLACE";
    level.turretSettings["mg_turret"].voDestroyed = "remote_sentry_destroyed";
    level.turretSettings["mg_turret"].laptopInfo = "killstreak_remote_turret_laptop_mp";
    level.turretSettings["mg_turret"].remoteInfo = "killstreak_remote_turret_remote_mp";

    foreach ( var_1 in level.turretSettings )
    {
        precacheitem( var_1.weaponinfo );
        precachemodel( var_1.modelBase );
        precachemodel( var_1.modelPlacement );
        precachemodel( var_1.modelPlacementFailed );
        precachemodel( var_1.modelDestroyed );
        precachestring( var_1.hintEnter );
        precachestring( var_1.hintExit );
        precachestring( var_1.placeString );
        precachestring( var_1.cannotPlaceString );
        precacheitem( var_1.laptopInfo );
        precacheitem( var_1.remoteInfo );
    }

    level._effect["sentry_explode_mp"] = loadfx( "explosions/sentry_gun_explosion" );
    level._effect["sentry_smoke_mp"] = loadfx( "smoke/car_damage_blacksmoke" );
    level._effect["antenna_light_mp"] = loadfx( "lights/light_detonator_blink" );
}

tryUseRemoteMGTurret( var_0 )
{
    var_1 = tryUseRemoteTurret( var_0, "mg_turret" );

    if ( var_1 )
        maps\mp\_matchdata::logKillstreakEvent( level.turretSettings["mg_turret"].streakName, self.origin );

    self.isCarrying = 0;
    return var_1;
}

takeKillstreakWeapons( var_0 )
{
    self takeweapon( level.turretSettings[var_0].laptopInfo );
    self takeweapon( level.turretSettings[var_0].remoteInfo );
}

tryUseRemoteTurret( var_0, var_1 )
{
    if ( maps\mp\_utility::isUsingRemote() )
        return 0;

    var_2 = createTurretForPlayer( var_1, self );
    removePerks();
    setCarryingTurret( var_2, 1 );
    thread restorePerks();

    if ( isdefined( var_2 ) )
        return 1;
    else
        return 0;
}

setCarryingTurret( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    var_0 turret_setCarried( self );
    common_scripts\utility::_disableWeapon();
    self notifyonplayercommand( "place_turret", "+attack" );
    self notifyonplayercommand( "place_turret", "+attack_akimbo_accessible" );
    self notifyonplayercommand( "cancel_turret", "+actionslot 4" );

    if ( !level.console )
    {
        self notifyonplayercommand( "cancel_turret", "+actionslot 5" );
        self notifyonplayercommand( "cancel_turret", "+actionslot 6" );
        self notifyonplayercommand( "cancel_turret", "+actionslot 7" );
    }

    for (;;)
    {
        var_2 = common_scripts\utility::waittill_any_return( "place_turret", "cancel_turret", "force_cancel_placement" );

        if ( var_2 == "cancel_turret" || var_2 == "force_cancel_placement" )
        {
            if ( var_2 == "cancel_turret" && !var_1 )
                continue;

            if ( level.console )
            {
                var_3 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( level.turretSettings[var_0.turretType].streakName );

                if ( isdefined( self.killstreakIndexWeapon ) && var_3 == maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( self.pers["killstreaks"][self.killstreakIndexWeapon].streakName ) && !self getweaponslistitems().size )
                {
                    maps\mp\_utility::_giveWeapon( var_3, 0 );
                    maps\mp\_utility::_setActionSlot( 4, "weapon", var_3 );
                }
            }

            var_0 turret_setCancelled();
            common_scripts\utility::_enableWeapon();
            return 0;
        }

        if ( !var_0.canBePlaced )
            continue;

        var_0 turret_setPlaced();
        common_scripts\utility::_enableWeapon();
        return 1;
    }
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
    foreach ( var_1 in self.weaponList )
    {
        var_2 = strtok( var_1, "_" );

        if ( var_2[0] == "alt" )
        {
            self.restoreWeaponClipAmmo[var_1] = self getweaponammoclip( var_1 );
            self.restoreWeaponStockAmmo[var_1] = self getweaponammostock( var_1 );
            continue;
        }

        self.restoreWeaponClipAmmo[var_1] = self getweaponammoclip( var_1 );
        self.restoreWeaponStockAmmo[var_1] = self getweaponammostock( var_1 );
    }

    self.weaponstorestore = [];

    foreach ( var_1 in self.weaponList )
    {
        var_2 = strtok( var_1, "_" );

        if ( var_2[0] == "alt" )
            continue;

        self.weaponstorestore[self.weaponstorestore.size] = var_1;
        self takeweapon( var_1 );
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

turret_setPlaced()
{
    self setmodel( level.turretSettings[self.turretType].modelBase );
    self setsentrycarrier( undefined );
    self setcandamage( 1 );
    self.carriedBy forceusehintoff();
    self.carriedBy = undefined;

    if ( isdefined( self.owner ) )
        self.owner.isCarrying = 0;

    self playsound( "sentry_gun_plant" );
    thread turret_setActive();
    self notify( "placed" );
}

turret_setCancelled()
{
    self.carriedBy forceusehintoff();

    if ( isdefined( self.owner ) )
        self.owner.isCarrying = 0;

    self delete();
}

turret_setCarried( var_0 )
{
    self setmodel( level.turretSettings[self.turretType].modelPlacement );
    self setcandamage( 0 );
    self setsentrycarrier( var_0 );
    self setcontents( 0 );
    self.carriedBy = var_0;
    var_0.isCarrying = 1;
    var_0 thread updateTurretPlacement( self );
    thread turret_onCarrierDeath( var_0 );
    thread turret_onCarrierDisconnect( var_0 );
    thread turret_onCarrierChangedTeam( var_0 );
    thread turret_onGameEnded();
    self setdefaultdroppitch( -89.0 );
    turret_setInactive();
    self notify( "carried" );
}

updateTurretPlacement( var_0 )
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
        var_2 = self canplayerplacesentry();
        var_0.origin = var_2["origin"];
        var_0.angles = var_2["angles"];
        var_0.canBePlaced = self isonground() && var_2["result"] && abs( var_0.origin[2] - self.origin[2] ) < 10;

        if ( var_0.canBePlaced != var_1 )
        {
            if ( var_0.canBePlaced )
            {
                var_0 setmodel( level.turretSettings[var_0.turretType].modelPlacement );
                self forceusehinton( level.turretSettings[var_0.turretType].placeString );
            }
            else
            {
                var_0 setmodel( level.turretSettings[var_0.turretType].modelPlacementFailed );
                self forceusehinton( level.turretSettings[var_0.turretType].cannotPlaceString );
            }
        }

        var_1 = var_0.canBePlaced;
        wait 0.05;
    }
}

turret_onCarrierDeath( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 waittill( "death" );

    if ( self.canBePlaced )
        turret_setPlaced();
    else
        self delete();
}

turret_onCarrierDisconnect( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 waittill( "disconnect" );
    self delete();
}

turret_onCarrierChangedTeam( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 common_scripts\utility::waittill_any( "joined_team", "joined_spectators" );
    self delete();
}

turret_onGameEnded( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    level waittill( "game_ended" );
    self delete();
}

createTurretForPlayer( var_0, var_1 )
{
    var_2 = spawnturret( "misc_turret", var_1.origin, level.turretSettings[var_0].weaponinfo );
    var_2.angles = var_1.angles;
    var_2 setmodel( level.turretSettings[var_0].modelBase );
    var_2.owner = var_1;
    var_2.health = level.turretSettings[var_0].health;
    var_2.maxHealth = level.turretSettings[var_0].maxHealth;
    var_2.damagetaken = 0;
    var_2.turretType = var_0;
    var_2.stunned = 0;
    var_2.stunnedTime = 5.0;
    var_2 setturretmodechangewait( 1 );
    var_2 turret_setInactive();
    var_2 setsentryowner( var_1 );
    var_2 setturretminimapvisible( 1, var_0 );
    var_2 setdefaultdroppitch( -89.0 );
    var_2 thread turret_handleOwnerDisconnect();
    var_1 setplayerdata( "remoteTurretDamageFade", 1.0 );
    var_1 setplayerdata( "remoteTurretDamaged", 0 );
    var_1 setplayerdata( "remoteTurretDamageState", 0 );
    var_2.damageFade = 1.0;
    var_2 thread turret_incrementDamageFade();
    var_2 thread turret_watchLowHealth();
    return var_2;
}

turret_setActive()
{
    self endon( "death" );
    self.owner endon( "disconnect" );
    self setdefaultdroppitch( 0.0 );
    self makeunusable();
    self maketurretsolid();

    if ( !isdefined( self.owner ) )
        return;

    var_0 = self.owner;

    if ( isdefined( var_0.remoteTurretList ) )
    {
        foreach ( var_2 in var_0.remoteTurretList )
            var_2 notify( "death" );
    }

    var_0.remoteTurretList = [];
    var_0.remoteTurretList[0] = self;
    var_0.using_remote_turret = 0;
    var_0.pickup_message_deleted = 0;
    var_0.enter_message_deleted = 1;

    if ( isalive( var_0 ) )
        var_0 maps\mp\_utility::setLowerMessage( "pickup_remote_turret", level.turretSettings[self.turretType].hintPickUp, undefined, undefined, undefined, undefined, undefined, undefined, 1 );

    var_0 thread watchOwnerMessageOnDeath( self );

    if ( level.teamBased )
    {
        self.team = var_0.team;
        self setturretteam( var_0.team );
        maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( 0, 0, 65 ) );
    }
    else
        maps\mp\_entityheadicons::setPlayerHeadIcon( self.owner, ( 0, 0, 65 ) );

    self.ownerTrigger = spawn( "trigger_radius", self.origin + ( 0, 0, 1 ), 0, 32, 64 );
    var_0 thread turret_handlePickup( self );
    thread watchEnterAndExit();
    thread turret_handleDeath();
    thread turret_handleDamage();
    thread turret_timeOut();
    thread turret_blinky_light();
}

startUsingRemoteTurret()
{
    var_0 = self.owner;
    var_0 maps\mp\_utility::setUsingRemote( self.turretType );
    var_0 maps\mp\_utility::freezeControlsWrapper( 1 );
    var_1 = var_0 maps\mp\killstreaks\_killstreaks::initRideKillstreak();

    if ( var_1 != "success" )
    {
        if ( var_1 != "disconnect" )
            var_0 maps\mp\_utility::clearUsingRemote();

        return 0;
    }

    var_0 maps\mp\_utility::_giveWeapon( level.turretSettings[self.turretType].remoteInfo );
    var_0 switchtoweaponimmediate( level.turretSettings[self.turretType].remoteInfo );
    var_0 maps\mp\_utility::freezeControlsWrapper( 0 );
    var_0 thread waitSetThermal( 1.0, self );

    if ( isdefined( level.HUDItem["thermal_mode"] ) )
        level.HUDItem["thermal_mode"] settext( "" );

    if ( getdvarint( "camera_thirdPerson" ) )
        var_0 maps\mp\_utility::setThirdPersonDOF( 0 );

    var_0 playerlinkweaponviewtodelta( self, "tag_player", 0, 180, 180, 50, 25, 0 );
    var_0 playerlinkedsetviewznear( 0 );
    var_0 playerlinkedsetusebaseangleforviewclamp( 1 );
    var_0 remotecontrolturret( self );
    var_0 maps\mp\_utility::clearLowerMessage( "enter_remote_turret" );
    var_0 maps\mp\_utility::clearLowerMessage( "pickup_remote_turret" );
    var_0 maps\mp\_utility::setLowerMessage( "early_exit", level.turretSettings[self.turretType].hintExit, undefined, undefined, undefined, undefined, undefined, undefined, 1 );

    if ( var_0 maps\mp\_utility::isJuggernaut() )
        var_0.juggernautOverlay.alpha = 0;
}

waitSetThermal( var_0, var_1 )
{
    self endon( "disconnect" );
    var_1 endon( "death" );
    wait(var_0);
    self visionsetthermalforplayer( game["thermal_vision"], 1.5 );
    self thermalvisionon();
    self thermalvisionfofoverlayon();
}

stopUsingRemoteTurret()
{
    var_0 = self.owner;

    if ( var_0 maps\mp\_utility::isUsingRemote() )
    {
        var_0 thermalvisionoff();
        var_0 thermalvisionfofoverlayoff();
        var_0 remotecontrolturretoff( self );
        var_0 unlink();
        var_0 switchtoweapon( var_0 common_scripts\utility::getLastWeapon() );
        var_0 maps\mp\_utility::clearUsingRemote();

        if ( getdvarint( "camera_thirdPerson" ) )
            var_0 maps\mp\_utility::setThirdPersonDOF( 1 );

        var_0 visionsetthermalforplayer( game["thermal_vision"], 0 );
        var_1 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( level.turretSettings[self.turretType].streakName );
        var_0 maps\mp\killstreaks\_killstreaks::takeKillstreakWeaponIfNoDupe( var_1 );
    }

    if ( self.stunned )
        var_0 stopshellshock();

    var_0 maps\mp\_utility::clearLowerMessage( "early_exit" );

    if ( !isdefined( var_0.using_remote_turret_when_died ) || !var_0.using_remote_turret_when_died )
        var_0 maps\mp\_utility::setLowerMessage( "enter_remote_turret", level.turretSettings[self.turretType].hintEnter, undefined, undefined, undefined, 1, 0.25, 1.5, 1 );

    if ( var_0 maps\mp\_utility::isJuggernaut() )
        var_0.juggernautOverlay.alpha = 1;

    self notify( "exit" );
}

watchOwnerMessageOnDeath( var_0 )
{
    self endon( "disconnect" );
    var_0 endon( "death" );
    self.using_remote_turret_when_died = 0;

    for (;;)
    {
        if ( isalive( self ) )
            self waittill( "death" );

        maps\mp\_utility::clearLowerMessage( "enter_remote_turret" );
        maps\mp\_utility::clearLowerMessage( "pickup_remote_turret" );

        if ( self.using_remote_turret )
            self.using_remote_turret_when_died = 1;
        else
            self.using_remote_turret_when_died = 0;

        self waittill( "spawned_player" );

        if ( !self.using_remote_turret_when_died )
        {
            maps\mp\_utility::setLowerMessage( "enter_remote_turret", level.turretSettings[var_0.turretType].hintEnter, undefined, undefined, undefined, 1, 0.25, 1.5, 1 );
            continue;
        }

        var_0 notify( "death" );
    }
}

watchEnterAndExit()
{
    self endon( "death" );
    self endon( "carried" );
    level endon( "game_ended" );
    var_0 = self.owner;

    for (;;)
    {
        var_1 = var_0 getcurrentweapon();

        if ( maps\mp\_utility::isKillstreakWeapon( var_1 ) && var_1 != level.turretSettings[self.turretType].weaponinfo && var_1 != level.turretSettings[self.turretType].laptopInfo && var_1 != level.turretSettings[self.turretType].remoteInfo && var_1 != "none" && ( !var_0 maps\mp\_utility::isJuggernaut() || var_0 maps\mp\_utility::isUsingRemote() ) )
        {
            if ( !isdefined( var_0.enter_message_deleted ) || !var_0.enter_message_deleted )
            {
                var_0.enter_message_deleted = 1;
                var_0 maps\mp\_utility::clearLowerMessage( "enter_remote_turret" );
            }

            wait 0.05;
            continue;
        }

        if ( var_0 istouching( self.ownerTrigger ) )
        {
            if ( !isdefined( var_0.enter_message_deleted ) || !var_0.enter_message_deleted )
            {
                var_0.enter_message_deleted = 1;
                var_0 maps\mp\_utility::clearLowerMessage( "enter_remote_turret" );
            }

            wait 0.05;
            continue;
        }

        if ( isdefined( var_0.empGrenaded ) && var_0.empGrenaded )
        {
            if ( !isdefined( var_0.enter_message_deleted ) || !var_0.enter_message_deleted )
            {
                var_0.enter_message_deleted = 1;
                var_0 maps\mp\_utility::clearLowerMessage( "enter_remote_turret" );
            }

            wait 0.05;
            continue;
        }

        if ( var_0 islinked() && !var_0.using_remote_turret )
        {
            if ( !isdefined( var_0.enter_message_deleted ) || !var_0.enter_message_deleted )
            {
                var_0.enter_message_deleted = 1;
                var_0 maps\mp\_utility::clearLowerMessage( "enter_remote_turret" );
            }

            wait 0.05;
            continue;
        }

        if ( isdefined( var_0.enter_message_deleted ) && var_0.enter_message_deleted && var_1 != "none" )
        {
            var_0 maps\mp\_utility::setLowerMessage( "enter_remote_turret", level.turretSettings[self.turretType].hintEnter, undefined, undefined, undefined, 1, 0.25, 1.5, 1 );
            var_0.enter_message_deleted = 0;
        }

        var_2 = 0;

        while ( var_0 usebuttonpressed() && !var_0 fragbuttonpressed() && !isdefined( var_0.throwingGrenade ) && !var_0 secondaryoffhandbuttonpressed() && !var_0 isusingturret() && var_0 isonground() && !var_0 istouching( self.ownerTrigger ) && ( !isdefined( var_0.empGrenaded ) || !var_0.empGrenaded ) )
        {
            if ( isdefined( var_0.isCarrying ) && var_0.isCarrying )
                break;

            if ( isdefined( var_0.isCapturingCrate ) && var_0.isCapturingCrate )
                break;

            if ( !isalive( var_0 ) )
                break;

            if ( !var_0.using_remote_turret && var_0 maps\mp\_utility::isUsingRemote() )
                break;

            if ( var_0 islinked() && !var_0.using_remote_turret )
                break;

            var_2 += 0.05;

            if ( var_2 > 0.75 )
            {
                var_0.using_remote_turret = !var_0.using_remote_turret;

                if ( var_0.using_remote_turret )
                {
                    var_0 removeWeapons();
                    var_0 takeKillstreakWeapons( self.turretType );
                    var_0 maps\mp\_utility::_giveWeapon( level.turretSettings[self.turretType].laptopInfo );
                    var_0 switchtoweaponimmediate( level.turretSettings[self.turretType].laptopInfo );
                    startUsingRemoteTurret();
                    var_0 restoreWeapons();
                }
                else
                {
                    var_0 takeKillstreakWeapons( self.turretType );
                    stopUsingRemoteTurret();
                }

                wait 2.0;
                break;
            }

            wait 0.05;
        }

        wait 0.05;
    }
}

turret_handlePickup( var_0 )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 endon( "death" );

    if ( !isdefined( var_0.ownerTrigger ) )
        return;

    if ( isdefined( self.pers["isBot"] ) && self.pers["isBot"] )
        return;

    var_1 = 0;

    for (;;)
    {
        var_2 = self getcurrentweapon();

        if ( maps\mp\_utility::isKillstreakWeapon( var_2 ) && var_2 != "killstreak_remote_turret_mp" && var_2 != level.turretSettings[var_0.turretType].weaponinfo && var_2 != level.turretSettings[var_0.turretType].laptopInfo && var_2 != level.turretSettings[var_0.turretType].remoteInfo && var_2 != "none" && ( !maps\mp\_utility::isJuggernaut() || maps\mp\_utility::isUsingRemote() ) )
        {
            if ( !isdefined( self.pickup_message_deleted ) || !self.pickup_message_deleted )
            {
                self.pickup_message_deleted = 1;
                maps\mp\_utility::clearLowerMessage( "pickup_remote_turret" );
            }

            wait 0.05;
            continue;
        }

        if ( !self istouching( var_0.ownerTrigger ) )
        {
            if ( !isdefined( self.pickup_message_deleted ) || !self.pickup_message_deleted )
            {
                self.pickup_message_deleted = 1;
                maps\mp\_utility::clearLowerMessage( "pickup_remote_turret" );
            }

            wait 0.05;
            continue;
        }

        if ( maps\mp\_utility::isReallyAlive( self ) && self istouching( var_0.ownerTrigger ) && !isdefined( var_0.carriedBy ) && self isonground() )
        {
            if ( isdefined( self.pickup_message_deleted ) && self.pickup_message_deleted && var_2 != "none" )
            {
                maps\mp\_utility::setLowerMessage( "pickup_remote_turret", level.turretSettings[var_0.turretType].hintPickUp, undefined, undefined, undefined, undefined, undefined, undefined, 1 );
                self.pickup_message_deleted = 0;
            }

            if ( self usebuttonpressed() )
            {
                if ( isdefined( self.using_remote_turret ) && self.using_remote_turret )
                    continue;

                var_1 = 0;

                while ( self usebuttonpressed() )
                {
                    var_1 += 0.05;
                    wait 0.05;
                }

                if ( var_1 >= 0.5 )
                    continue;

                var_1 = 0;

                while ( !self usebuttonpressed() && var_1 < 0.5 )
                {
                    var_1 += 0.05;
                    wait 0.05;
                }

                if ( var_1 >= 0.5 )
                    continue;

                if ( !maps\mp\_utility::isReallyAlive( self ) )
                    continue;

                if ( isdefined( self.using_remote_turret ) && self.using_remote_turret )
                    continue;

                var_0 setmode( level.turretSettings[var_0.turretType].sentryModeOff );
                thread setCarryingTurret( var_0, 0 );
                var_0.ownerTrigger delete();
                self.remoteTurretList = undefined;
                maps\mp\_utility::clearLowerMessage( "pickup_remote_turret" );
                return;
            }
        }

        wait 0.05;
    }
}

turret_blinky_light()
{
    self endon( "death" );
    self endon( "carried" );

    for (;;)
    {
        playfxontag( common_scripts\utility::getfx( "antenna_light_mp" ), self, "tag_fx" );
        wait 1.0;
        stopfxontag( common_scripts\utility::getfx( "antenna_light_mp" ), self, "tag_fx" );
    }
}

turret_setInactive()
{
    self setmode( level.turretSettings[self.turretType].sentryModeOff );

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( "none", ( 0, 0, 0 ) );
    else if ( isdefined( self.owner ) )
        maps\mp\_entityheadicons::setPlayerHeadIcon( undefined, ( 0, 0, 0 ) );

    if ( !isdefined( self.owner ) )
        return;

    var_0 = self.owner;

    if ( isdefined( var_0.using_remote_turret ) && var_0.using_remote_turret )
    {
        var_0 thermalvisionoff();
        var_0 thermalvisionfofoverlayoff();
        var_0 remotecontrolturretoff( self );
        var_0 unlink();
        var_0 switchtoweapon( var_0 common_scripts\utility::getLastWeapon() );
        var_0 maps\mp\_utility::clearUsingRemote();

        if ( getdvarint( "camera_thirdPerson" ) )
            var_0 maps\mp\_utility::setThirdPersonDOF( 1 );

        var_0 maps\mp\killstreaks\_killstreaks::clearRideIntro();
        var_0 visionsetthermalforplayer( game["thermal_vision"], 0 );

        if ( isdefined( var_0.disabledUsability ) && var_0.disabledUsability )
            var_0 common_scripts\utility::_enableUsability();

        var_0 takeKillstreakWeapons( self.turretType );

        if ( var_0 maps\mp\_utility::isJuggernaut() )
            var_0.juggernautOverlay.alpha = 1;
    }
}

turret_handleOwnerDisconnect()
{
    self endon( "death" );
    level endon( "game_ended" );
    self notify( "turret_handleOwner" );
    self endon( "turret_handleOwner" );
    self.owner common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );
    self notify( "death" );
}

turret_timeOut()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = level.turretSettings[self.turretType].timeOut;

    while ( var_0 )
    {
        wait 1.0;
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

        if ( !isdefined( self.carriedBy ) )
            var_0 = max( 0, var_0 - 1.0 );
    }

    if ( isdefined( self.owner ) )
        self.owner thread maps\mp\_utility::leaderDialogOnPlayer( "sentry_gone" );

    self notify( "death" );
}

turret_handleDeath()
{
    self endon( "carried" );
    var_0 = self getentitynumber();
    maps\mp\killstreaks\_autosentry::addToTurretList( var_0 );
    self waittill( "death" );
    maps\mp\killstreaks\_autosentry::removeFromTurretList( var_0 );

    if ( !isdefined( self ) )
        return;

    self setmodel( level.turretSettings[self.turretType].modelDestroyed );
    turret_setInactive();
    self setdefaultdroppitch( 40 );
    self setsentryowner( undefined );
    self setturretminimapvisible( 0 );

    if ( isdefined( self.ownerTrigger ) )
        self.ownerTrigger delete();

    var_1 = self.owner;

    if ( isdefined( var_1 ) )
    {
        var_1.using_remote_turret = 0;
        var_1 maps\mp\_utility::clearLowerMessage( "enter_remote_turret" );
        var_1 maps\mp\_utility::clearLowerMessage( "early_exit" );
        var_1 maps\mp\_utility::clearLowerMessage( "pickup_remote_turret" );
        var_1 setplayerdata( "remoteTurretDamageState", 0 );
        var_1 restorePerks();
        var_1 restoreWeapons();

        if ( var_1 getcurrentweapon() == "none" )
            var_1 switchtoweapon( var_1 common_scripts\utility::getLastWeapon() );

        if ( self.stunned )
            var_1 stopshellshock();
    }

    self playsound( "sentry_explode" );
    playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_aim" );
    wait 1.5;
    self playsound( "sentry_explode_smoke" );

    for ( var_2 = 8; var_2 > 0; var_2 -= 0.4 )
    {
        playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_aim" );
        wait 0.4;
    }

    self notify( "deleting" );

    if ( isdefined( self.target_ent ) )
        self.target_ent delete();

    self delete();
}

turret_handleDamage()
{
    self endon( "death" );
    self endon( "carried" );
    self setcandamage( 1 );

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_1 ) )
            continue;

        if ( isdefined( var_9 ) )
        {
            switch ( var_9 )
            {
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
                    if ( var_4 == "MOD_GRENADE_SPLASH" && self.owner.using_remote_turret )
                    {
                        self.stunned = 1;
                        thread turret_stun();
                    }
                case "smoke_grenade_mp":
                    continue;
            }
        }

        if ( !isdefined( self ) )
            return;

        if ( var_4 == "MOD_MELEE" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        if ( isdefined( var_8 ) && var_8 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;
        self.damageFade = 0.0;
        self.owner setplayerdata( "remoteTurretDamaged", 1 );
        var_10 = var_0;

        if ( isplayer( var_1 ) )
        {
            var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "remote_turret" );

            if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                var_10 = var_0 * level.armorPiercingMod;
        }

        if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
            var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "remote_turret" );

        if ( isdefined( var_9 ) )
        {
            switch ( var_9 )
            {
                case "ac130_105mm_mp":
                case "ac130_40mm_mp":
                case "remotemissile_projectile_mp":
                case "stinger_mp":
                case "javelin_mp":
                case "remote_mortar_missile_mp":
                    self.largeProjectileDamage = 1;
                    var_10 = self.maxHealth + 1;
                    break;
                case "artillery_mp":
                case "stealth_bomb_mp":
                    self.largeProjectileDamage = 0;
                    var_10 += var_0 * 4;
                    break;
                case "emp_grenade_mp":
                case "bomb_site_mp":
                    self.largeProjectileDamage = 0;
                    var_10 = self.maxHealth + 1;
                    break;
            }

            maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_9, self );
        }

        self.damagetaken = self.damagetaken + var_10;

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isplayer( var_1 ) && ( !isdefined( self.owner ) || var_1 != self.owner ) )
            {
                var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100, var_9, var_4 );
                var_1 notify( "destroyed_killstreak" );
            }

            if ( isdefined( self.owner ) )
                self.owner thread maps\mp\_utility::leaderDialogOnPlayer( level.turretSettings[self.turretType].voDestroyed );

            self notify( "death" );
            return;
        }
    }
}

turret_incrementDamageFade()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = 0;

    for (;;)
    {
        if ( self.damageFade < 1.0 )
        {
            self.owner setplayerdata( "remoteTurretDamageFade", self.damageFade );
            self.damageFade = self.damageFade + 0.1;
            var_0 = 1;
        }
        else if ( var_0 )
        {
            self.damageFade = 1.0;
            self.owner setplayerdata( "remoteTurretDamageFade", self.damageFade );
            self.owner setplayerdata( "remoteTurretDamaged", 0 );
            var_0 = 0;
        }

        wait 0.1;
    }
}

turret_watchLowHealth()
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
                self.owner setplayerdata( "remoteTurretDamageState", var_1 );
                var_1++;
            }
        }
        else if ( self.damagetaken >= self.maxHealth * ( var_0 * var_1 ) )
        {
            self.owner setplayerdata( "remoteTurretDamageState", var_1 );
            var_1++;
        }

        wait 0.05;
    }
}

turret_stun()
{
    self notify( "stunned" );
    self endon( "stunned" );
    self endon( "death" );

    while ( self.stunned )
    {
        self.owner shellshock( "concussion_grenade_mp", self.stunnedTime );
        playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_origin" );
        var_0 = 0;

        while ( var_0 < self.stunnedTime )
        {
            var_0 += 0.05;
            wait 0.05;
        }

        self.stunned = 0;
    }
}
