// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.sentryType = [];
    level.sentryType["sentry_minigun"] = "sentry";
    level.sentryType["sam_turret"] = "sam_turret";
    level.killstreakFuncs[level.sentryType["sentry_minigun"]] = ::tryUseAutoSentry;
    level.killstreakFuncs[level.sentryType["sam_turret"]] = ::tryUseSAM;
    level.sentrySettings = [];
    level.sentrySettings["sentry_minigun"] = spawnstruct();
    level.sentrySettings["sentry_minigun"].health = 999999;
    level.sentrySettings["sentry_minigun"].maxHealth = 1000;
    level.sentrySettings["sentry_minigun"].burstMin = 20;
    level.sentrySettings["sentry_minigun"].burstMax = 120;
    level.sentrySettings["sentry_minigun"].pauseMin = 0.15;
    level.sentrySettings["sentry_minigun"].pauseMax = 0.35;
    level.sentrySettings["sentry_minigun"].sentryModeOn = "sentry";
    level.sentrySettings["sentry_minigun"].sentryModeOff = "sentry_offline";
    level.sentrySettings["sentry_minigun"].timeOut = 90.0;
    level.sentrySettings["sentry_minigun"].spinupTime = 0.05;
    level.sentrySettings["sentry_minigun"].overheatTime = 8.0;
    level.sentrySettings["sentry_minigun"].cooldownTime = 0.1;
    level.sentrySettings["sentry_minigun"].fxTime = 0.3;
    level.sentrySettings["sentry_minigun"].streakName = "sentry";
    level.sentrySettings["sentry_minigun"].weaponinfo = "sentry_minigun_mp";
    level.sentrySettings["sentry_minigun"].modelBase = "sentry_minigun_weak";
    level.sentrySettings["sentry_minigun"].modelPlacement = "sentry_minigun_weak_obj";
    level.sentrySettings["sentry_minigun"].modelPlacementFailed = "sentry_minigun_weak_obj_red";
    level.sentrySettings["sentry_minigun"].modelDestroyed = "sentry_minigun_weak_destroyed";
    level.sentrySettings["sentry_minigun"].hintstring = &"SENTRY_PICKUP";
    level.sentrySettings["sentry_minigun"].headicon = 1;
    level.sentrySettings["sentry_minigun"].teamSplash = "used_sentry";
    level.sentrySettings["sentry_minigun"].shouldSplash = 0;
    level.sentrySettings["sentry_minigun"].voDestroyed = "sentry_destroyed";
    level.sentrySettings["sam_turret"] = spawnstruct();
    level.sentrySettings["sam_turret"].health = 999999;
    level.sentrySettings["sam_turret"].maxHealth = 1000;
    level.sentrySettings["sam_turret"].burstMin = 20;
    level.sentrySettings["sam_turret"].burstMax = 120;
    level.sentrySettings["sam_turret"].pauseMin = 0.15;
    level.sentrySettings["sam_turret"].pauseMax = 0.35;
    level.sentrySettings["sam_turret"].sentryModeOn = "sentry";
    level.sentrySettings["sam_turret"].sentryModeOff = "sentry_offline";
    level.sentrySettings["sam_turret"].timeOut = 90.0;
    level.sentrySettings["sam_turret"].spinupTime = 0.05;
    level.sentrySettings["sam_turret"].overheatTime = 8.0;
    level.sentrySettings["sam_turret"].cooldownTime = 0.1;
    level.sentrySettings["sam_turret"].fxTime = 0.3;
    level.sentrySettings["sam_turret"].streakName = "sam_turret";
    level.sentrySettings["sam_turret"].weaponinfo = "sam_mp";
    level.sentrySettings["sam_turret"].modelBase = "mp_sam_turret";
    level.sentrySettings["sam_turret"].modelPlacement = "mp_sam_turret_placement";
    level.sentrySettings["sam_turret"].modelPlacementFailed = "mp_sam_turret_placement_failed";
    level.sentrySettings["sam_turret"].modelDestroyed = "mp_sam_turret";
    level.sentrySettings["sam_turret"].hintstring = &"SENTRY_PICKUP";
    level.sentrySettings["sam_turret"].headicon = 1;
    level.sentrySettings["sam_turret"].teamSplash = "used_sam_turret";
    level.sentrySettings["sam_turret"].shouldSplash = 0;
    level.sentrySettings["sam_turret"].voDestroyed = "sam_destroyed";

    foreach ( var_1 in level.sentrySettings )
    {
        precacheitem( var_1.weaponinfo );
        precachemodel( var_1.modelBase );
        precachemodel( var_1.modelPlacement );
        precachemodel( var_1.modelPlacementFailed );
        precachemodel( var_1.modelDestroyed );
        precachestring( var_1.hintstring );

        if ( isdefined( var_1.ownerHintString ) )
            precachestring( var_1.ownerHintString );
    }

    precacheitem( "sam_projectile_mp" );
    level._effect["sentry_overheat_mp"] = loadfx( "smoke/sentry_turret_overheat_smoke" );
    level._effect["sentry_explode_mp"] = loadfx( "explosions/sentry_gun_explosion" );
    level._effect["sentry_smoke_mp"] = loadfx( "smoke/car_damage_blacksmoke" );
}

tryUseAutoSentry( var_0 )
{
    var_1 = giveSentry( "sentry_minigun" );

    if ( var_1 )
        maps\mp\_matchdata::logKillstreakEvent( level.sentrySettings["sentry_minigun"].streakName, self.origin );

    return var_1;
}

tryUseSAM( var_0 )
{
    var_1 = giveSentry( "sam_turret" );

    if ( var_1 )
        maps\mp\_matchdata::logKillstreakEvent( level.sentrySettings["sam_turret"].streakName, self.origin );

    return var_1;
}

giveSentry( var_0 )
{
    if ( !maps\mp\_utility::validateUseStreak() )
        return 0;

    self.last_sentry = var_0;
    var_1 = createSentryForPlayer( var_0, self );
    removePerks();
    var_2 = setCarryingSentry( var_1, 1 );
    thread waitRestorePerks();
    self.isCarrying = 0;

    if ( isdefined( var_1 ) )
        return 1;
    else
        return 0;
}

setCarryingSentry( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    var_0 sentry_setCarried( self );
    common_scripts\utility::_disableWeapon();
    self notifyonplayercommand( "place_sentry", "+attack" );
    self notifyonplayercommand( "place_sentry", "+attack_akimbo_accessible" );
    self notifyonplayercommand( "cancel_sentry", "+actionslot 4" );

    if ( !level.console )
    {
        self notifyonplayercommand( "cancel_sentry", "+actionslot 5" );
        self notifyonplayercommand( "cancel_sentry", "+actionslot 6" );
        self notifyonplayercommand( "cancel_sentry", "+actionslot 7" );
    }

    for (;;)
    {
        var_2 = common_scripts\utility::waittill_any_return( "place_sentry", "cancel_sentry", "force_cancel_placement" );

        if ( var_2 == "cancel_sentry" || var_2 == "force_cancel_placement" )
        {
            if ( !var_1 && var_2 == "cancel_sentry" )
                continue;

            if ( level.console )
            {
                var_3 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( level.sentrySettings[var_0.sentryType].streakName );

                if ( isdefined( self.killstreakIndexWeapon ) && var_3 == maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( self.pers["killstreaks"][self.killstreakIndexWeapon].streakName ) && !self getweaponslistitems().size )
                {
                    maps\mp\_utility::_giveWeapon( var_3, 0 );
                    maps\mp\_utility::_setActionSlot( 4, "weapon", var_3 );
                }
            }

            var_0 sentry_setCancelled();
            common_scripts\utility::_enableWeapon();
            return 0;
        }

        if ( !var_0.canBePlaced )
            continue;

        var_0 sentry_setPlaced();
        common_scripts\utility::_enableWeapon();
        return 1;
    }
}

removeWeapons()
{
    if ( self hasweapon( "riotshield_mp" ) )
    {
        self.restoreWeapon = "riotshield_mp";
        self takeweapon( "riotshield_mp" );
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

restoreWeapons()
{
    if ( isdefined( self.restoreWeapon ) )
    {
        maps\mp\_utility::_giveWeapon( self.restoreWeapon );
        self.restoreWeapon = undefined;
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

createSentryForPlayer( var_0, var_1 )
{
    var_2 = spawnturret( "misc_turret", var_1.origin, level.sentrySettings[var_0].weaponinfo );
    var_2.angles = var_1.angles;
    var_2 sentry_initSentry( var_0, var_1 );
    return var_2;
}

sentry_initSentry( var_0, var_1 )
{
    self.sentryType = var_0;
    self.canBePlaced = 1;
    self setmodel( level.sentrySettings[self.sentryType].modelBase );
    self.shouldSplash = 1;
    self setcandamage( 1 );

    switch ( var_0 )
    {
        case "minigun_turret":
        case "gl_turret":
            self setleftarc( 80 );
            self setrightarc( 80 );
            self setbottomarc( 50 );
            self setdefaultdroppitch( 0.0 );
            self.originalOwner = var_1;
            break;
        case "sam_turret":
            self maketurretinoperable();
            self setleftarc( 180 );
            self setrightarc( 180 );
            self settoparc( 80 );
            self setdefaultdroppitch( -89.0 );
            self.laser_on = 0;
            var_2 = spawn( "script_model", self gettagorigin( "tag_laser" ) );
            var_2 linkto( self );
            self.killCamEnt = var_2;
            self.killCamEnt setscriptmoverkillcam( "explosive" );
            break;
        default:
            self maketurretinoperable();
            self setdefaultdroppitch( -89.0 );
            break;
    }

    self setturretmodechangewait( 1 );
    sentry_setInactive();
    sentry_setOwner( var_1 );
    thread sentry_handleDamage();
    thread sentry_handleDeath();
    thread sentry_timeOut();

    switch ( var_0 )
    {
        case "minigun_turret":
            self.momentum = 0;
            self.heatLevel = 0;
            self.overheated = 0;
            thread sentry_heatMonitor();
            break;
        case "gl_turret":
            self.momentum = 0;
            self.heatLevel = 0;
            self.cooldownWaitTime = 0;
            self.overheated = 0;
            thread turret_heatMonitor();
            thread turret_coolMonitor();
            break;
        case "sam_turret":
            thread sentry_handleUse();
            thread sentry_beepSounds();
            break;
        default:
            thread sentry_handleUse();
            thread sentry_attackTargets();
            thread sentry_beepSounds();
            break;
    }
}

sentry_handleDamage()
{
    self endon( "death" );
    level endon( "game_ended" );
    self.health = level.sentrySettings[self.sentryType].health;
    self.maxHealth = level.sentrySettings[self.sentryType].maxHealth;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_1 ) )
            continue;

        if ( isdefined( var_8 ) && var_8 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        switch ( var_9 )
        {
            case "artillery_mp":
            case "stealth_bomb_mp":
                var_0 *= 4;
                break;
            case "bomb_site_mp":
                var_0 = self.maxHealth;
                break;
        }

        if ( var_4 == "MOD_MELEE" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        var_10 = var_0;

        if ( isplayer( var_1 ) )
        {
            var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "sentry" );

            if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                var_10 = var_0 * level.armorPiercingMod;
        }

        if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
            var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "sentry" );

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
            thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, var_1, var_0, var_4, var_9 );

            if ( isplayer( var_1 ) && ( !isdefined( self.owner ) || var_1 != self.owner ) )
            {
                var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100, var_9, var_4 );
                var_1 notify( "destroyed_killstreak" );

                if ( isdefined( self.UAVRemoteMarkedBy ) && self.UAVRemoteMarkedBy != var_1 )
                    self.UAVRemoteMarkedBy thread maps\mp\killstreaks\_remoteuav::remoteUAV_processTaggedAssist();
            }

            if ( isdefined( self.owner ) )
                self.owner thread maps\mp\_utility::leaderDialogOnPlayer( level.sentrySettings[self.sentryType].voDestroyed );

            self notify( "death" );
            return;
        }
    }
}

sentry_watchDisabled()
{
    self endon( "carried" );
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "emp_damage",  var_0, var_1  );
        playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_aim" );
        self setdefaultdroppitch( 40 );
        self setmode( level.sentrySettings[self.sentryType].sentryModeOff );
        wait(var_1);
        self setdefaultdroppitch( -89.0 );
        self setmode( level.sentrySettings[self.sentryType].sentryModeOn );
    }
}

sentry_handleDeath()
{
    self waittill( "death" );

    if ( !isdefined( self ) )
        return;

    self setmodel( level.sentrySettings[self.sentryType].modelDestroyed );
    sentry_setInactive();
    self setdefaultdroppitch( 40 );
    self setsentryowner( undefined );
    self setturretminimapvisible( 0 );

    if ( isdefined( self.ownerTrigger ) )
        self.ownerTrigger delete();

    self playsound( "sentry_explode" );

    switch ( self.sentryType )
    {
        case "minigun_turret":
        case "gl_turret":
            self.forceDisable = 1;
            self turretfiredisable();
            break;
        default:
            break;
    }

    if ( isdefined( self.inUseBy ) )
    {
        playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_origin" );
        playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_aim" );
        self.inUseBy.turret_overheat_bar maps\mp\gametypes\_hud_util::destroyElem();
        self.inUseBy restorePerks();
        self.inUseBy restoreWeapons();
        self notify( "deleting" );
        wait 1.0;
        stopfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_origin" );
        stopfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_aim" );
    }
    else
    {
        playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_aim" );
        wait 1.5;
        self playsound( "sentry_explode_smoke" );

        for ( var_0 = 8; var_0 > 0; var_0 -= 0.4 )
        {
            playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_aim" );
            wait 0.4;
        }

        self notify( "deleting" );
    }

    if ( isdefined( self.killCamEnt ) )
        self.killCamEnt delete();

    self delete();
}

sentry_handleUse()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "trigger",  var_0  );

        if ( !maps\mp\_utility::isReallyAlive( var_0 ) )
            continue;

        if ( self.sentryType == "sam_turret" )
            self setmode( level.sentrySettings[self.sentryType].sentryModeOff );

        var_0 setCarryingSentry( self, 0 );
    }
}

turret_handlePickup( var_0 )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 endon( "death" );

    if ( !isdefined( var_0.ownerTrigger ) )
        return;

    var_1 = 0;

    for (;;)
    {
        if ( isalive( self ) && self istouching( var_0.ownerTrigger ) && !isdefined( var_0.inUseBy ) && !isdefined( var_0.carriedBy ) && self isonground() )
        {
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

                var_0 setmode( level.sentrySettings[var_0.sentryType].sentryModeOff );
                thread setCarryingSentry( var_0, 0 );
                var_0.ownerTrigger delete();
                return;
            }
        }

        wait 0.05;
    }
}

turret_handleUse()
{
    self notify( "turret_handluse" );
    self endon( "turret_handleuse" );
    self endon( "deleting" );
    level endon( "game_ended" );
    self.forceDisable = 0;
    var_0 = ( 1, 0.9, 0.7 );
    var_1 = ( 1, 0.65, 0 );
    var_2 = ( 1, 0.25, 0 );

    for (;;)
    {
        self waittill( "trigger",  var_3  );

        if ( isdefined( self.carriedBy ) )
            continue;

        if ( isdefined( self.inUseBy ) )
            continue;

        if ( !maps\mp\_utility::isReallyAlive( var_3 ) )
            continue;

        var_3 removePerks();
        var_3 removeWeapons();
        self.inUseBy = var_3;
        self setmode( level.sentrySettings[self.sentryType].sentryModeOff );
        sentry_setOwner( var_3 );
        self setmode( level.sentrySettings[self.sentryType].sentryModeOn );
        var_3 thread turret_shotMonitor( self );
        var_3.turret_overheat_bar = var_3 maps\mp\gametypes\_hud_util::createBar( var_0, 100, 6 );
        var_3.turret_overheat_bar maps\mp\gametypes\_hud_util::setPoint( "CENTER", "BOTTOM", 0, -70 );
        var_3.turret_overheat_bar.alpha = 0.65;
        var_3.turret_overheat_bar.bar.alpha = 0.65;
        var_4 = 0;

        for (;;)
        {
            if ( !maps\mp\_utility::isReallyAlive( var_3 ) )
            {
                self.inUseBy = undefined;
                var_3.turret_overheat_bar maps\mp\gametypes\_hud_util::destroyElem();
                break;
            }

            if ( !var_3 isusingturret() )
            {
                self notify( "player_dismount" );
                self.inUseBy = undefined;
                var_3.turret_overheat_bar maps\mp\gametypes\_hud_util::destroyElem();
                var_3 restorePerks();
                var_3 restoreWeapons();
                self sethintstring( level.sentrySettings[self.sentryType].hintstring );
                self setmode( level.sentrySettings[self.sentryType].sentryModeOff );
                sentry_setOwner( self.originalOwner );
                self setmode( level.sentrySettings[self.sentryType].sentryModeOn );
                break;
            }

            if ( self.heatLevel >= level.sentrySettings[self.sentryType].overheatTime )
                var_5 = 1;
            else
                var_5 = self.heatLevel / level.sentrySettings[self.sentryType].overheatTime;

            var_3.turret_overheat_bar maps\mp\gametypes\_hud_util::updateBar( var_5 );

            if ( self.forceDisable || self.overheated )
            {
                self turretfiredisable();
                var_3.turret_overheat_bar.bar.color = var_2;
                var_4 = 0;
            }
            else if ( self.heatLevel > level.sentrySettings[self.sentryType].overheatTime * 0.75 && self.sentryType == "minigun_turret" )
            {
                var_3.turret_overheat_bar.bar.color = var_1;

                if ( randomintrange( 0, 10 ) < 6 )
                    self turretfireenable();
                else
                    self turretfiredisable();

                if ( !var_4 )
                {
                    var_4 = 1;
                    thread PlayHeatFX();
                }
            }
            else
            {
                var_3.turret_overheat_bar.bar.color = var_0;
                self turretfireenable();
                var_4 = 0;
                self notify( "not_overheated" );
            }

            wait 0.05;
        }

        self setdefaultdroppitch( 0.0 );
    }
}

sentry_handleOwnerDisconnect()
{
    self endon( "death" );
    level endon( "game_ended" );
    self notify( "sentry_handleOwner" );
    self endon( "sentry_handleOwner" );
    self.owner common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );
    self notify( "death" );
}

sentry_setOwner( var_0 )
{
    self.owner = var_0;
    self setsentryowner( self.owner );
    self setturretminimapvisible( 1, self.sentryType );

    if ( level.teamBased )
    {
        self.team = self.owner.team;
        self setturretteam( self.team );
    }

    thread sentry_handleOwnerDisconnect();
}

sentry_setPlaced()
{
    self setmodel( level.sentrySettings[self.sentryType].modelBase );

    if ( self getmode() == "manual" )
        self setmode( level.sentrySettings[self.sentryType].sentryModeOff );

    self setsentrycarrier( undefined );
    self setcandamage( 1 );

    switch ( self.sentryType )
    {
        case "minigun_turret":
        case "gl_turret":
            self.angles = self.carriedBy.angles;

            if ( isalive( self.originalOwner ) )
                self.originalOwner maps\mp\_utility::setLowerMessage( "pickup_hint", level.sentrySettings[self.sentryType].ownerHintString, 3.0, undefined, undefined, undefined, undefined, undefined, 1 );

            self.ownerTrigger = spawn( "trigger_radius", self.origin + ( 0, 0, 1 ), 0, 105, 64 );
            self.originalOwner thread turret_handlePickup( self );
            thread turret_handleUse();
            break;
        default:
            break;
    }

    sentry_makeSolid();
    self.carriedBy forceusehintoff();
    self.carriedBy = undefined;

    if ( isdefined( self.owner ) )
        self.owner.isCarrying = 0;

    sentry_setActive();
    self playsound( "sentry_gun_plant" );
    self notify( "placed" );
}

sentry_setCancelled()
{
    self.carriedBy forceusehintoff();

    if ( isdefined( self.owner ) )
        self.owner.isCarrying = 0;

    self delete();
}

sentry_setCarried( var_0 )
{
    if ( isdefined( self.originalOwner ) )
        jump loc_1165

    self setmodel( level.sentrySettings[self.sentryType].modelPlacement );
    self setsentrycarrier( var_0 );
    self setcandamage( 0 );
    sentry_makeNotSolid();
    self.carriedBy = var_0;
    var_0.isCarrying = 1;
    var_0 thread updateSentryPlacement( self );
    thread sentry_onCarrierDeath( var_0 );
    thread sentry_onCarrierDisconnect( var_0 );
    thread sentry_onCarrierChangedTeam( var_0 );
    thread sentry_onGameEnded();
    self setdefaultdroppitch( -89.0 );
    sentry_setInactive();
    self notify( "carried" );
}

updateSentryPlacement( var_0 )
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
                var_0 setmodel( level.sentrySettings[var_0.sentryType].modelPlacement );
                self forceusehinton( &"SENTRY_PLACE" );
            }
            else
            {
                var_0 setmodel( level.sentrySettings[var_0.sentryType].modelPlacementFailed );
                self forceusehinton( &"SENTRY_CANNOT_PLACE" );
            }
        }

        var_1 = var_0.canBePlaced;
        wait 0.05;
    }
}

sentry_onCarrierDeath( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 waittill( "death" );

    if ( self.canBePlaced )
        sentry_setPlaced();
    else
        self delete();
}

sentry_onCarrierDisconnect( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 waittill( "disconnect" );
    self delete();
}

sentry_onCarrierChangedTeam( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 common_scripts\utility::waittill_any( "joined_team", "joined_spectators" );
    self delete();
}

sentry_onGameEnded( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    level waittill( "game_ended" );
    self delete();
}

sentry_setActive()
{
    self setmode( level.sentrySettings[self.sentryType].sentryModeOn );
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( level.sentrySettings[self.sentryType].hintstring );

    if ( level.sentrySettings[self.sentryType].headicon )
    {
        if ( level.teamBased )
            maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( 0, 0, 65 ) );
        else
            maps\mp\_entityheadicons::setPlayerHeadIcon( self.owner, ( 0, 0, 65 ) );
    }

    self makeusable();

    foreach ( var_1 in level.players )
    {
        switch ( self.sentryType )
        {
            case "minigun_turret":
            case "gl_turret":
                self enableplayeruse( var_1 );
                continue;
            default:
                var_2 = self getentitynumber();
                addToTurretList( var_2 );

                if ( var_1 == self.owner )
                    self enableplayeruse( var_1 );
                else
                    self disableplayeruse( var_1 );

                continue;
        }
    }

    if ( self.shouldSplash )
    {
        level thread maps\mp\_utility::teamPlayerCardSplash( level.sentrySettings[self.sentryType].teamSplash, self.owner, self.owner.team );
        self.shouldSplash = 0;
    }

    if ( self.sentryType == "sam_turret" )
        thread sam_attackTargets();

    thread sentry_watchDisabled();
}

sentry_setInactive()
{
    self setmode( level.sentrySettings[self.sentryType].sentryModeOff );
    self makeunusable();
    var_0 = self getentitynumber();

    switch ( self.sentryType )
    {
        case "gl_turret":
            break;
        default:
            removeFromTurretList( var_0 );
            break;
    }

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( "none", ( 0, 0, 0 ) );
    else if ( isdefined( self.owner ) )
        maps\mp\_entityheadicons::setPlayerHeadIcon( undefined, ( 0, 0, 0 ) );
}

sentry_makeSolid()
{
    self maketurretsolid();
}

sentry_makeNotSolid()
{
    self setcontents( 0 );
}

isFriendlyToSentry( var_0 )
{
    if ( level.teamBased && self.team == var_0.team )
        return 1;

    return 0;
}

addToTurretList( var_0 )
{
    level.turrets[var_0] = self;
}

removeFromTurretList( var_0 )
{
    level.turrets[var_0] = undefined;
}

sentry_attackTargets()
{
    self endon( "death" );
    level endon( "game_ended" );
    self.momentum = 0;
    self.heatLevel = 0;
    self.overheated = 0;
    thread sentry_heatMonitor();

    for (;;)
    {
        common_scripts\utility::waittill_either( "turretstatechange", "cooled" );

        if ( self isfiringturret() )
        {
            thread sentry_burstFireStart();
            continue;
        }

        sentry_spinDown();
        thread sentry_burstFireStop();
    }
}

sentry_timeOut()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = level.sentrySettings[self.sentryType].timeOut;

    while ( var_0 )
    {
        wait 1.0;
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

        if ( !isdefined( self.carriedBy ) )
            var_0 = max( 0, var_0 - 1.0 );
    }

    if ( isdefined( self.owner ) )
    {
        if ( self.sentryType == "sam_turret" )
            self.owner thread maps\mp\_utility::leaderDialogOnPlayer( "sam_gone" );
        else
            self.owner thread maps\mp\_utility::leaderDialogOnPlayer( "sentry_gone" );
    }

    self notify( "death" );
}

sentry_targetLockSound()
{
    self endon( "death" );
    self playsound( "sentry_gun_beep" );
    wait 0.1;
    self playsound( "sentry_gun_beep" );
    wait 0.1;
    self playsound( "sentry_gun_beep" );
}

sentry_spinUp()
{
    thread sentry_targetLockSound();

    while ( self.momentum < level.sentrySettings[self.sentryType].spinupTime )
    {
        self.momentum = self.momentum + 0.1;
        wait 0.1;
    }
}

sentry_spinDown()
{
    self.momentum = 0;
}

sentry_burstFireStart()
{
    self endon( "death" );
    self endon( "stop_shooting" );
    level endon( "game_ended" );
    sentry_spinUp();
    var_0 = weaponfiretime( level.sentrySettings[self.sentryType].weaponinfo );
    var_1 = level.sentrySettings[self.sentryType].burstMin;
    var_2 = level.sentrySettings[self.sentryType].burstMax;
    var_3 = level.sentrySettings[self.sentryType].pauseMin;
    var_4 = level.sentrySettings[self.sentryType].pauseMax;

    for (;;)
    {
        var_5 = randomintrange( var_1, var_2 + 1 );

        for ( var_6 = 0; var_6 < var_5 && !self.overheated; var_6++ )
        {
            self shootturret();
            self.heatLevel = self.heatLevel + var_0;
            wait(var_0);
        }

        wait(randomfloatrange( var_3, var_4 ));
    }
}

sentry_burstFireStop()
{
    self notify( "stop_shooting" );
}

turret_shotMonitor( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 endon( "death" );
    var_0 endon( "player_dismount" );
    var_1 = weaponfiretime( level.sentrySettings[var_0.sentryType].weaponinfo );

    for (;;)
    {
        var_0 waittill( "turret_fire" );
        var_0.heatLevel = var_0.heatLevel + var_1;
        var_0.cooldownWaitTime = var_1;
    }
}

sentry_heatMonitor()
{
    self endon( "death" );
    var_0 = weaponfiretime( level.sentrySettings[self.sentryType].weaponinfo );
    var_1 = 0;
    var_2 = 0;
    var_3 = level.sentrySettings[self.sentryType].overheatTime;
    var_4 = level.sentrySettings[self.sentryType].cooldownTime;

    for (;;)
    {
        if ( self.heatLevel != var_1 )
            wait(var_0);
        else
            self.heatLevel = max( 0, self.heatLevel - 0.05 );

        if ( self.heatLevel > var_3 )
        {
            self.overheated = 1;
            thread PlayHeatFX();

            switch ( self.sentryType )
            {
                case "minigun_turret":
                    playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_aim" );
                    break;
                default:
                    break;
            }

            while ( self.heatLevel )
            {
                self.heatLevel = max( 0, self.heatLevel - var_4 );
                wait 0.1;
            }

            self.overheated = 0;
            self notify( "not_overheated" );
        }

        var_1 = self.heatLevel;
        wait 0.05;
    }
}

turret_heatMonitor()
{
    self endon( "death" );
    var_0 = level.sentrySettings[self.sentryType].overheatTime;

    for (;;)
    {
        if ( self.heatLevel > var_0 )
        {
            self.overheated = 1;
            thread PlayHeatFX();

            switch ( self.sentryType )
            {
                case "gl_turret":
                    playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_aim" );
                    break;
                default:
                    break;
            }

            while ( self.heatLevel )
                wait 0.1;

            self.overheated = 0;
            self notify( "not_overheated" );
        }

        wait 0.05;
    }
}

turret_coolMonitor()
{
    self endon( "death" );

    for (;;)
    {
        if ( self.heatLevel > 0 )
        {
            if ( self.cooldownWaitTime <= 0 )
                self.heatLevel = max( 0, self.heatLevel - 0.05 );
            else
                self.cooldownWaitTime = max( 0, self.cooldownWaitTime - 0.05 );
        }

        wait 0.05;
    }
}

PlayHeatFX()
{
    self endon( "death" );
    self endon( "not_overheated" );
    level endon( "game_ended" );
    self notify( "playing_heat_fx" );
    self endon( "playing_heat_fx" );

    for (;;)
    {
        playfxontag( common_scripts\utility::getfx( "sentry_overheat_mp" ), self, "tag_flash" );
        wait(level.sentrySettings[self.sentryType].fxTime);
    }
}

playSmokeFX()
{
    self endon( "death" );
    self endon( "not_overheated" );
    level endon( "game_ended" );

    for (;;)
    {
        playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_aim" );
        wait 0.4;
    }
}

sentry_beepSounds()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        wait 3.0;

        if ( !isdefined( self.carriedBy ) )
            self playsound( "sentry_gun_beep" );
    }
}

sam_attackTargets()
{
    self endon( "carried" );
    self endon( "death" );
    level endon( "game_ended" );
    self.samTargetEnt = undefined;
    self.samMissileGroups = [];

    for (;;)
    {
        self.samTargetEnt = sam_acquireTarget();
        sam_fireOnTarget();
        wait 0.05;
    }
}

sam_acquireTarget()
{
    var_0 = self gettagorigin( "tag_laser" );

    if ( !isdefined( self.samTargetEnt ) )
    {
        if ( level.teamBased )
        {
            foreach ( var_2 in level.uavmodels[level.otherTeam[self.team]] )
            {
                if ( isdefined( var_2.isLeaving ) && var_2.isLeaving )
                    continue;

                if ( sighttracepassed( var_0, var_2.origin, 0, self ) )
                    return var_2;
            }

            foreach ( var_5 in level.littleBirds )
            {
                if ( isdefined( var_5.team ) && var_5.team == self.team )
                    continue;

                if ( sighttracepassed( var_0, var_5.origin, 0, self ) )
                    return var_5;
            }

            foreach ( var_8 in level.helis )
            {
                if ( isdefined( var_8.team ) && var_8.team == self.team )
                    continue;

                if ( sighttracepassed( var_0, var_8.origin, 0, self ) )
                    return var_8;
            }

            if ( level.ac130InUse && isdefined( level.ac130.owner ) && level.ac130.owner.team != self.team )
            {
                if ( sighttracepassed( var_0, level.ac130.planemodel.origin, 0, self ) )
                    return level.ac130.planemodel;
            }

            foreach ( var_2 in level.remote_uav )
            {
                if ( !isdefined( var_2 ) )
                    continue;

                if ( isdefined( var_2.team ) && var_2.team == self.team )
                    continue;

                if ( sighttracepassed( var_0, var_2.origin, 0, self, var_2 ) )
                    return var_2;
            }
        }
        else
        {
            foreach ( var_2 in level.uavmodels )
            {
                if ( isdefined( var_2.isLeaving ) && var_2.isLeaving )
                    continue;

                if ( isdefined( var_2.owner ) && isdefined( self.owner ) && var_2.owner == self.owner )
                    continue;

                if ( sighttracepassed( var_0, var_2.origin, 0, self ) )
                    return var_2;
            }

            foreach ( var_5 in level.littleBirds )
            {
                if ( isdefined( var_5.owner ) && isdefined( self.owner ) && var_5.owner == self.owner )
                    continue;

                if ( sighttracepassed( var_0, var_5.origin, 0, self ) )
                    return var_5;
            }

            foreach ( var_8 in level.helis )
            {
                if ( isdefined( var_8.owner ) && isdefined( self.owner ) && var_8.owner == self.owner )
                    continue;

                if ( sighttracepassed( var_0, var_8.origin, 0, self ) )
                    return var_8;
            }

            if ( level.ac130InUse && isdefined( level.ac130.owner ) && isdefined( self.owner ) && level.ac130.owner != self.owner )
            {
                if ( sighttracepassed( var_0, level.ac130.planemodel.origin, 0, self ) )
                    return level.ac130.planemodel;
            }

            foreach ( var_2 in level.remote_uav )
            {
                if ( !isdefined( var_2 ) )
                    continue;

                if ( isdefined( var_2.owner ) && isdefined( self.owner ) && var_2.owner == self.owner )
                    continue;

                if ( sighttracepassed( var_0, var_2.origin, 0, self, var_2 ) )
                    return var_2;
            }
        }

        self cleartargetentity();
        return undefined;
    }
    else
    {
        if ( !sighttracepassed( var_0, self.samTargetEnt.origin, 0, self ) )
        {
            self cleartargetentity();
            return undefined;
        }

        return self.samTargetEnt;
    }
}

sam_fireOnTarget()
{
    if ( isdefined( self.samTargetEnt ) )
    {
        if ( self.samTargetEnt == level.ac130.planemodel && !isdefined( level.ac130player ) )
        {
            self.samTargetEnt = undefined;
            self cleartargetentity();
            return;
        }

        self settargetentity( self.samTargetEnt );
        self waittill( "turret_on_target" );

        if ( !isdefined( self.samTargetEnt ) )
            return;

        if ( !self.laser_on )
        {
            thread sam_watchLaser();
            thread sam_watchCrashing();
            thread sam_watchLeaving();
            thread sam_watchLineOfSight();
        }

        wait 2.0;

        if ( !isdefined( self.samTargetEnt ) )
            return;

        if ( self.samTargetEnt == level.ac130.planemodel && !isdefined( level.ac130player ) )
        {
            self.samTargetEnt = undefined;
            self cleartargetentity();
            return;
        }

        var_0 = [];
        var_0[0] = self gettagorigin( "tag_le_missile1" );
        var_0[1] = self gettagorigin( "tag_le_missile2" );
        var_0[2] = self gettagorigin( "tag_ri_missile1" );
        var_0[3] = self gettagorigin( "tag_ri_missile2" );
        var_1 = self.samMissileGroups.size;

        for ( var_2 = 0; var_2 < 4; var_2++ )
        {
            if ( !isdefined( self.samTargetEnt ) )
                return;

            if ( isdefined( self.carriedBy ) )
                return;

            self shootturret();
            var_3 = magicbullet( "sam_projectile_mp", var_0[var_2], self.samTargetEnt.origin, self.owner );
            var_3 missile_settargetent( self.samTargetEnt );
            var_3 missile_setflightmodedirect();
            var_3.samTurret = self;
            var_3.samMissileGroup = var_1;
            self.samMissileGroups[var_1][var_2] = var_3;
            level notify( "sam_missile_fired",  self.owner, var_3, self.samTargetEnt  );

            if ( var_2 == 3 )
                break;

            wait 0.25;
        }

        level notify( "sam_fired",  self.owner, self.samMissileGroups[var_1], self.samTargetEnt  );
        wait 3.0;
    }
}

sam_watchLineOfSight()
{
    level endon( "game_ended" );
    self endon( "death" );

    while ( isdefined( self.samTargetEnt ) && isdefined( self getturrettarget( 1 ) ) && self getturrettarget( 1 ) == self.samTargetEnt )
    {
        var_0 = self gettagorigin( "tag_laser" );

        if ( !sighttracepassed( var_0, self.samTargetEnt.origin, 0, self, self.samTargetEnt ) )
        {
            self cleartargetentity();
            self.samTargetEnt = undefined;
            break;
        }

        wait 0.05;
    }
}

sam_watchLaser()
{
    self endon( "death" );
    self laseron();
    self.laser_on = 1;

    while ( isdefined( self.samTargetEnt ) && isdefined( self getturrettarget( 1 ) ) && self getturrettarget( 1 ) == self.samTargetEnt )
        wait 0.05;

    self laseroff();
    self.laser_on = 0;
}

sam_watchCrashing()
{
    self endon( "death" );
    self.samTargetEnt endon( "death" );

    if ( !isdefined( self.samTargetEnt.heliType ) )
        return;

    self.samTargetEnt waittill( "crashing" );
    self cleartargetentity();
    self.samTargetEnt = undefined;
}

sam_watchLeaving()
{
    self endon( "death" );
    self.samTargetEnt endon( "death" );

    if ( !isdefined( self.samTargetEnt.model ) )
        return;

    if ( self.samTargetEnt.model == "vehicle_uav_static_mp" )
    {
        self.samTargetEnt waittill( "leaving" );
        self cleartargetentity();
        self.samTargetEnt = undefined;
    }
}
