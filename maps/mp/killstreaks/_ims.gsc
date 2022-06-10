// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.killstreakFuncs["ims"] = ::tryUseIMS;
    level.imsSettings = [];
    level.imsSettings["ims"] = spawnstruct();
    level.imsSettings["ims"].weaponinfo = "ims_projectile_mp";
    level.imsSettings["ims"].modelBase = "ims_scorpion_body";
    level.imsSettings["ims"].modelPlacement = "ims_scorpion_body_placement";
    level.imsSettings["ims"].modelPlacementFailed = "ims_scorpion_body_placement_failed";
    level.imsSettings["ims"].modelDestroyed = "ims_scorpion_body";
    level.imsSettings["ims"].modelBombSquad = "ims_scorpion_body_bombsquad";
    level.imsSettings["ims"].hintstring = &"MP_IMS_PICKUP";
    level.imsSettings["ims"].placeString = &"MP_IMS_PLACE";
    level.imsSettings["ims"].cannotPlaceString = &"MP_IMS_CANNOT_PLACE";
    level.imsSettings["ims"].streakName = "ims";
    level.imsSettings["ims"].splashName = "used_ims";
    level.imsSettings["ims"].lifeSpan = 90.0;
    level.imsSettings["ims"].gracePeriod = 0.4;
    level.imsSettings["ims"].attacks = 4;
    level.imsSettings["ims"].modelExplosive1 = "ims_scorpion_explosive1";
    level.imsSettings["ims"].modelExplosive2 = "ims_scorpion_explosive2";
    level.imsSettings["ims"].modelExplosive3 = "ims_scorpion_explosive3";
    level.imsSettings["ims"].modelExplosive4 = "ims_scorpion_explosive4";
    level.imsSettings["ims"].modelLid1 = "ims_scorpion_lid1";
    level.imsSettings["ims"].modelLid2 = "ims_scorpion_lid2";
    level.imsSettings["ims"].modelLid3 = "ims_scorpion_lid3";
    level.imsSettings["ims"].modelLid4 = "ims_scorpion_lid4";
    level.imsSettings["ims"].tagExplosive1 = "tag_explosive1";
    level.imsSettings["ims"].tagExplosive2 = "tag_explosive2";
    level.imsSettings["ims"].tagExplosive3 = "tag_explosive3";
    level.imsSettings["ims"].tagExplosive4 = "tag_explosive4";
    level.imsSettings["ims"].tagLid1 = "tag_lid1";
    level.imsSettings["ims"].tagLid2 = "tag_lid2";
    level.imsSettings["ims"].tagLid3 = "tag_lid3";
    level.imsSettings["ims"].tagLid4 = "tag_lid4";

    foreach ( var_1 in level.imsSettings )
    {
        precacheitem( var_1.weaponinfo );
        precachemodel( var_1.modelBase );
        precachemodel( var_1.modelPlacement );
        precachemodel( var_1.modelPlacementFailed );
        precachemodel( var_1.modelDestroyed );
        precachemodel( var_1.modelBombSquad );
        precachemodel( var_1.modelExplosive1 );
        precachemodel( var_1.modelExplosive2 );
        precachemodel( var_1.modelExplosive3 );
        precachemodel( var_1.modelExplosive4 );
        precachemodel( var_1.modelLid1 );
        precachemodel( var_1.modelLid2 );
        precachemodel( var_1.modelLid3 );
        precachemodel( var_1.modelLid4 );
        precachestring( var_1.hintstring );
        precachestring( var_1.placeString );
        precachestring( var_1.cannotPlaceString );
    }

    precachestring( &"PLATFORM_HOLD_TO_USE" );
    level._effect["ims_explode_mp"] = loadfx( "explosions/sentry_gun_explosion" );
    level._effect["ims_smoke_mp"] = loadfx( "smoke/car_damage_blacksmoke" );
    level._effect["ims_sensor_trail"] = loadfx( "smoke/smoke_geotrail_rpg" );
    level._effect["ims_sensor_explode"] = loadfx( "explosions/generator_sparks_d" );
    level._effect["ims_antenna_light_mp"] = loadfx( "lights/light_detonator_blink" );
}

tryUseIMS( var_0 )
{
    var_1 = [];

    if ( isdefined( self.imsList ) )
        var_1 = self.imsList;

    var_2 = giveIMS( "ims" );

    if ( !isdefined( var_2 ) )
    {
        var_2 = 0;

        if ( isdefined( self.imsList ) )
        {
            if ( !var_1.size && self.imsList.size )
                var_2 = 1;

            if ( var_1.size && var_1[0] != self.imsList[0] )
                var_2 = 1;
        }
    }

    if ( var_2 )
        maps\mp\_matchdata::logKillstreakEvent( level.imsSettings["ims"].streakName, self.origin );

    self.isCarrying = 0;
    return var_2;
}

giveIMS( var_0 )
{
    var_1 = createIMSForPlayer( var_0, self );
    removePerks();
    var_2 = setCarryingIMS( var_1, 1 );
    thread restorePerks();
    return var_2;
}

setCarryingIMS( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    var_0 thread ims_setCarried( self );
    common_scripts\utility::_disableWeapon();
    self notifyonplayercommand( "place_ims", "+attack" );
    self notifyonplayercommand( "place_ims", "+attack_akimbo_accessible" );
    self notifyonplayercommand( "cancel_ims", "+actionslot 4" );

    if ( !level.console )
    {
        self notifyonplayercommand( "cancel_ims", "+actionslot 5" );
        self notifyonplayercommand( "cancel_ims", "+actionslot 6" );
        self notifyonplayercommand( "cancel_ims", "+actionslot 7" );
    }

    for (;;)
    {
        var_2 = common_scripts\utility::waittill_any_return( "place_ims", "cancel_ims", "force_cancel_placement" );

        if ( var_2 == "cancel_ims" || var_2 == "force_cancel_placement" )
        {
            if ( !var_1 && var_2 == "cancel_ims" )
                continue;

            if ( level.console )
            {
                var_3 = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( level.imsSettings[var_0.imsType].streakName );

                if ( isdefined( self.killstreakIndexWeapon ) && var_3 == maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( self.pers["killstreaks"][self.killstreakIndexWeapon].streakName ) && !self getweaponslistitems().size )
                {
                    maps\mp\_utility::_giveWeapon( var_3, 0 );
                    maps\mp\_utility::_setActionSlot( 4, "weapon", var_3 );
                }
            }

            var_0 ims_setCancelled();
            common_scripts\utility::_enableWeapon();
            return 0;
        }

        if ( !var_0.canBePlaced )
            continue;

        var_0 thread ims_setPlaced();
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

createIMSForPlayer( var_0, var_1 )
{
    if ( isdefined( var_1.isCarrying ) && var_1.isCarrying )
        return;

    var_2 = spawnturret( "misc_turret", var_1.origin + ( 0, 0, 25 ), "sentry_minigun_mp" );
    var_2.angles = var_1.angles;
    var_2.imsType = var_0;
    var_2.owner = var_1;
    var_2 setmodel( level.imsSettings[var_0].modelBase );
    var_2 maketurretinoperable();
    var_2 setturretmodechangewait( 1 );
    var_2 setmode( "sentry_offline" );
    var_2 makeunusable();
    var_2 setsentryowner( var_1 );
    return var_2;
}

createIMS( var_0 )
{
    var_1 = var_0.owner;
    var_2 = var_0.imsType;
    var_3 = spawn( "script_model", var_0.origin );
    var_3 setmodel( level.imsSettings[var_2].modelBase );
    var_3.scale = 3;
    var_3.health = 1000;
    var_3.angles = var_1.angles;
    var_3.imsType = var_2;
    var_3.owner = var_1;
    var_3.team = var_1.team;
    var_3.shouldSplash = 0;
    var_3.hidden = 0;
    var_3.attacks = level.imsSettings[var_2].attacks;
    var_3.lid1 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagLid1 + "_attach" ) );
    var_3.lid1 setmodel( level.imsSettings[var_2].modelLid1 );
    var_3.lid1.tag = level.imsSettings[var_2].tagLid1;
    var_3.lid1 linkto( var_3 );
    var_3.lid2 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagLid2 + "_attach" ) );
    var_3.lid2 setmodel( level.imsSettings[var_2].modelLid2 );
    var_3.lid2.tag = level.imsSettings[var_2].tagLid2;
    var_3.lid2 linkto( var_3 );
    var_3.lid3 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagLid3 + "_attach" ) );
    var_3.lid3 setmodel( level.imsSettings[var_2].modelLid3 );
    var_3.lid3.tag = level.imsSettings[var_2].tagLid3;
    var_3.lid3 linkto( var_3 );
    var_3.lid4 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagLid4 + "_attach" ) );
    var_3.lid4 setmodel( level.imsSettings[var_2].modelLid4 );
    var_3.lid4.tag = level.imsSettings[var_2].tagLid4;
    var_3.lid4 linkto( var_3 );
    var_3.explosive1 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagExplosive1 + "_attach" ) );
    var_3.explosive1 setmodel( level.imsSettings[var_2].modelExplosive1 );
    var_3.explosive1.tag = level.imsSettings[var_2].tagExplosive1;
    var_3.explosive1 linkto( var_3 );
    var_3.explosive2 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagExplosive2 + "_attach" ) );
    var_3.explosive2 setmodel( level.imsSettings[var_2].modelExplosive2 );
    var_3.explosive2.tag = level.imsSettings[var_2].tagExplosive2;
    var_3.explosive2 linkto( var_3 );
    var_3.explosive3 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagExplosive3 + "_attach" ) );
    var_3.explosive3 setmodel( level.imsSettings[var_2].modelExplosive3 );
    var_3.explosive3.tag = level.imsSettings[var_2].tagExplosive3;
    var_3.explosive3 linkto( var_3 );
    var_3.explosive4 = spawn( "script_model", var_3 gettagorigin( level.imsSettings[var_2].tagExplosive4 + "_attach" ) );
    var_3.explosive4 setmodel( level.imsSettings[var_2].modelExplosive4 );
    var_3.explosive4.tag = level.imsSettings[var_2].tagExplosive4;
    var_3.explosive4 linkto( var_3 );
    var_3 ims_setInactive();
    var_3 thread ims_handleOwnerDisconnect();
    var_3 thread ims_handleDeath();
    var_3 thread ims_handleUse();
    var_3 thread ims_handleDamage();
    var_3 thread ims_timeOut();
    var_3 thread ims_createBombSquadModel();
    return var_3;
}

ims_createBombSquadModel()
{
    var_0 = spawn( "script_model", self.origin );
    var_0.angles = self.angles;
    var_0 hide();
    var_1 = level.otherTeam[self.team];
    var_0 thread maps\mp\gametypes\_weapons::bombSquadVisibilityUpdater( var_1, self.owner );
    var_0 setmodel( level.imsSettings[self.imsType].modelBombSquad );
    var_0 linkto( self );
    var_0 setcontents( 0 );
    self.imsBombSquadModel = var_0;
    self waittill( "death" );
    var_0 delete();
}

ims_handleDamage()
{
    self endon( "death" );
    level endon( "game_ended" );
    self.health = 999999;
    self.maxHealth = 300;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_1 ) )
            continue;

        if ( isdefined( var_9 ) )
        {
            switch ( var_9 )
            {
                case "smoke_grenade_mp":
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
                case "ims_projectile_mp":
                    continue;
            }
        }

        if ( !isdefined( self ) )
            return;

        if ( self.hidden )
            continue;

        if ( var_4 == "MOD_MELEE" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        if ( isexplosivedamagemod( var_4 ) )
            var_0 *= 1.5;

        if ( isdefined( var_8 ) && var_8 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;
        var_10 = var_0;

        if ( isplayer( var_1 ) )
        {
            var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "ims" );

            if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                var_10 = var_0 * level.armorPiercingMod;
        }

        if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
            var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "ims" );

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
                var_1 notify( "destroyed_explosive" );
            }

            if ( isdefined( self.owner ) )
                self.owner thread maps\mp\_utility::leaderDialogOnPlayer( "ims_destroyed" );

            self notify( "death" );
            return;
        }
    }
}

ims_handleDeath()
{
    var_0 = self getentitynumber();
    addToIMSList( var_0 );
    self waittill( "death" );
    removeFromIMSList( var_0 );

    if ( !isdefined( self ) )
        return;

    self setmodel( level.imsSettings[self.imsType].modelDestroyed );
    ims_setInactive();
    self playsound( "ims_destroyed" );

    if ( isdefined( self.inUseBy ) )
    {
        playfx( common_scripts\utility::getfx( "ims_explode_mp" ), self.origin + ( 0, 0, 10 ) );
        playfx( common_scripts\utility::getfx( "ims_smoke_mp" ), self.origin );
        self.inUseBy restorePerks();
        self.inUseBy restoreWeapons();
        self notify( "deleting" );
        wait 1.0;
    }
    else
    {
        playfx( common_scripts\utility::getfx( "ims_explode_mp" ), self.origin + ( 0, 0, 10 ) );
        wait 1.5;
        self playsound( "ims_fire" );

        for ( var_1 = 8; var_1 > 0; var_1 -= 0.4 )
        {
            playfx( common_scripts\utility::getfx( "ims_smoke_mp" ), self.origin );
            wait 0.4;
        }

        self notify( "deleting" );
    }

    if ( isdefined( self.objIdFriendly ) )
        maps\mp\_utility::_objective_delete( self.objIdFriendly );

    if ( isdefined( self.objIdEnemy ) )
        maps\mp\_utility::_objective_delete( self.objIdEnemy );

    if ( isdefined( self.lid1 ) )
        self.lid1 delete();

    if ( isdefined( self.lid2 ) )
        self.lid2 delete();

    if ( isdefined( self.lid3 ) )
        self.lid3 delete();

    if ( isdefined( self.lid4 ) )
        self.lid4 delete();

    if ( isdefined( self.explosive1 ) )
    {
        if ( isdefined( self.explosive1.killCamEnt ) )
            self.explosive1.killCamEnt delete();

        self.explosive1 delete();
    }

    if ( isdefined( self.explosive2 ) )
    {
        if ( isdefined( self.explosive2.killCamEnt ) )
            self.explosive2.killCamEnt delete();

        self.explosive2 delete();
    }

    if ( isdefined( self.explosive3 ) )
    {
        if ( isdefined( self.explosive3.killCamEnt ) )
            self.explosive3.killCamEnt delete();

        self.explosive3 delete();
    }

    if ( isdefined( self.explosive4 ) )
    {
        if ( isdefined( self.explosive4.killCamEnt ) )
            self.explosive4.killCamEnt delete();

        self.explosive4 delete();
    }

    self delete();
}

ims_handleUse()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "trigger",  var_0  );

        if ( !maps\mp\_utility::isReallyAlive( var_0 ) )
            continue;

        if ( self.damagetaken >= self.maxHealth )
            continue;

        var_1 = createIMSForPlayer( self.imsType, var_0 );

        if ( !isdefined( var_1 ) )
            continue;

        var_1.ims = self;
        ims_setInactive();
        ims_hideAllParts();
        var_0 setCarryingIMS( var_1, 0 );
    }
}

ims_handleOwnerDisconnect()
{
    self endon( "death" );
    level endon( "game_ended" );
    self notify( "ims_handleOwner" );
    self endon( "ims_handleOwner" );
    self.owner common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );
    self notify( "death" );
}

ims_setPlaced()
{
    self endon( "death" );
    level endon( "game_ended" );

    if ( isdefined( self.carriedBy ) )
        self.carriedBy forceusehintoff();

    self.carriedBy = undefined;

    if ( isdefined( self.owner ) )
        self.owner.isCarrying = 0;

    var_0 = undefined;

    if ( isdefined( self.ims ) )
    {
        var_0 = self.ims;
        var_0 endon( "death" );
        var_0.origin = self.origin;
        var_0.angles = self.angles;
        var_0.carriedBy = undefined;
        wait 0.05;
        var_0 ims_showAllParts();

        if ( isdefined( var_0.imsBombSquadModel ) )
        {
            var_0.imsBombSquadModel show();
            level notify( "update_bombsquad" );
        }
    }
    else
        var_0 = createIMS( self );

    var_0 setcandamage( 1 );
    self playsound( "ims_plant" );
    self notify( "placed" );
    var_0 thread ims_setActive();
    self delete();
}

ims_setCancelled()
{
    if ( isdefined( self.carriedBy ) )
        self.carriedBy forceusehintoff();

    if ( isdefined( self.owner ) )
        self.owner.isCarrying = 0;

    if ( isdefined( self.lid1 ) )
        self.lid1 delete();

    if ( isdefined( self.lid2 ) )
        self.lid2 delete();

    if ( isdefined( self.lid3 ) )
        self.lid3 delete();

    if ( isdefined( self.lid4 ) )
        self.lid4 delete();

    if ( isdefined( self.explosive1 ) )
        self.explosive1 delete();

    if ( isdefined( self.explosive2 ) )
        self.explosive2 delete();

    if ( isdefined( self.explosive3 ) )
        self.explosive3 delete();

    if ( isdefined( self.explosive4 ) )
        self.explosive4 delete();

    self delete();
}

ims_setCarried( var_0 )
{
    self setmodel( level.imsSettings[self.imsType].modelPlacement );
    self setsentrycarrier( var_0 );
    self setcontents( 0 );
    self setcandamage( 0 );
    self.carriedBy = var_0;
    var_0.isCarrying = 1;
    var_0 thread updateIMSPlacement( self );
    thread ims_onCarrierDeath( var_0 );
    thread ims_onCarrierDisconnect( var_0 );
    thread ims_onGameEnded();
    self notify( "carried" );

    if ( isdefined( self.ims ) )
    {
        self.ims notify( "carried" );
        self.ims.carriedBy = var_0;

        if ( isdefined( self.ims.imsBombSquadModel ) )
            self.ims.imsBombSquadModel hide();
    }
}

updateIMSPlacement( var_0 )
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
                var_0 setmodel( level.imsSettings[var_0.imsType].modelPlacement );
                self forceusehinton( level.imsSettings[var_0.imsType].placeString );
            }
            else
            {
                var_0 setmodel( level.imsSettings[var_0.imsType].modelPlacementFailed );
                self forceusehinton( level.imsSettings[var_0.imsType].cannotPlaceString );
            }
        }

        var_1 = var_0.canBePlaced;
        wait 0.05;
    }
}

ims_onCarrierDeath( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 endon( "disconnect" );
    var_0 waittill( "death" );

    if ( self.canBePlaced )
        thread ims_setPlaced();
    else
        ims_setCancelled();
}

ims_onCarrierDisconnect( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    var_0 waittill( "disconnect" );
    ims_setCancelled();
}

ims_onGameEnded( var_0 )
{
    self endon( "placed" );
    self endon( "death" );
    level waittill( "game_ended" );
    ims_setCancelled();
}

ims_setActive()
{
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( level.imsSettings[self.imsType].hintstring );
    var_0 = self.owner;
    var_0 forceusehintoff();

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( 0, 0, 45 ) );
    else
        maps\mp\_entityheadicons::setPlayerHeadIcon( var_0, ( 0, 0, 45 ) );

    self makeusable();
    self setcandamage( 1 );

    if ( isdefined( var_0.imsList ) )
    {
        foreach ( var_2 in var_0.imsList )
        {
            if ( var_2 == self )
                continue;

            var_2 notify( "death" );
        }
    }

    var_0.imsList = [];
    var_0.imsList[0] = self;

    foreach ( var_5 in level.players )
    {
        if ( var_5 == var_0 )
        {
            self enableplayeruse( var_5 );
            continue;
        }

        self disableplayeruse( var_5 );
    }

    if ( self.shouldSplash )
    {
        level thread maps\mp\_utility::teamPlayerCardSplash( level.imsSettings[self.imsType].splashName, var_0 );
        self.shouldSplash = 0;
    }

    var_7 = ( 0, 0, 20 );
    var_8 = ( 0, 0, 256 );
    var_9 = [];
    var_10 = self gettagorigin( level.imsSettings[self.imsType].tagExplosive1 ) + var_7;
    var_9[0] = bullettrace( var_10, var_10 + var_8 - var_7, 0, self );
    var_10 = self gettagorigin( level.imsSettings[self.imsType].tagExplosive2 ) + var_7;
    var_9[1] = bullettrace( var_10, var_10 + var_8 - var_7, 0, self );
    var_10 = self gettagorigin( level.imsSettings[self.imsType].tagExplosive3 ) + var_7;
    var_9[2] = bullettrace( var_10, var_10 + var_8 - var_7, 0, self );
    var_10 = self gettagorigin( level.imsSettings[self.imsType].tagExplosive4 ) + var_7;
    var_9[3] = bullettrace( var_10, var_10 + var_8 - var_7, 0, self );
    var_11 = var_9[0];

    for ( var_12 = 0; var_12 < var_9.size; var_12++ )
    {
        if ( var_9[var_12]["position"][2] < var_11["position"][2] )
            var_11 = var_9[var_12];
    }

    self.attackHeightPos = var_11["position"] - ( 0, 0, 20 );
    var_13 = spawn( "trigger_radius", self.origin, 0, 256, 100 );
    self.attackTrigger = var_13;
    self.attackMoveTime = distance( self.origin, self.attackHeightPos ) / 200;
    self.killCamOffset = ( 0, 0, 12 );

    if ( isdefined( self.explosive1.killCamEnt ) )
        self.explosive1.killCamEnt delete();

    if ( isdefined( self.explosive2.killCamEnt ) )
        self.explosive2.killCamEnt delete();

    if ( isdefined( self.explosive3.killCamEnt ) )
        self.explosive3.killCamEnt delete();

    if ( isdefined( self.explosive4.killCamEnt ) )
        self.explosive4.killCamEnt delete();

    var_0.imsKillCamEnt = undefined;

    if ( isdefined( self.explosive1 ) )
    {
        self.explosive1.killCamEnt = spawn( "script_model", self.explosive1.origin + self.killCamOffset );
        self.explosive1.killCamEnt setscriptmoverkillcam( "explosive" );

        if ( !isdefined( var_0.imsKillCamEnt ) )
            var_0.imsKillCamEnt = self.explosive1.killCamEnt;
    }

    if ( isdefined( self.explosive2 ) )
    {
        self.explosive2.killCamEnt = spawn( "script_model", self.explosive2.origin + self.killCamOffset );
        self.explosive2.killCamEnt setscriptmoverkillcam( "explosive" );

        if ( !isdefined( var_0.imsKillCamEnt ) )
            var_0.imsKillCamEnt = self.explosive2.killCamEnt;
    }

    if ( isdefined( self.explosive3 ) )
    {
        self.explosive3.killCamEnt = spawn( "script_model", self.explosive3.origin + self.killCamOffset );
        self.explosive3.killCamEnt setscriptmoverkillcam( "explosive" );

        if ( !isdefined( var_0.imsKillCamEnt ) )
            var_0.imsKillCamEnt = self.explosive3.killCamEnt;
    }

    if ( isdefined( self.explosive4 ) )
    {
        self.explosive4.killCamEnt = spawn( "script_model", self.explosive4.origin + self.killCamOffset );
        self.explosive4.killCamEnt setscriptmoverkillcam( "explosive" );

        if ( !isdefined( var_0.imsKillCamEnt ) )
            var_0.imsKillCamEnt = self.explosive4.killCamEnt;
    }

    thread ims_blinky_light();
    thread ims_attackTargets();
    thread ims_playerConnected();

    foreach ( var_5 in level.players )
        thread ims_playerJoinedTeam( var_5 );
}

ims_playerConnected()
{
    self endon( "death" );
    level waittill( "connected",  var_0  );
    var_0 waittill( "spawned_player" );
    self disableplayeruse( var_0 );
}

ims_playerJoinedTeam( var_0 )
{
    self endon( "death" );
    var_0 endon( "disconnect" );

    for (;;)
    {
        var_0 waittill( "joined_team" );
        self disableplayeruse( var_0 );
    }
}

ims_blinky_light()
{
    self endon( "death" );
    self endon( "carried" );

    for (;;)
    {
        playfxontag( common_scripts\utility::getfx( "ims_antenna_light_mp" ), self, "tag_fx" );
        wait 1.0;
        stopfxontag( common_scripts\utility::getfx( "ims_antenna_light_mp" ), self, "tag_fx" );
    }
}

ims_setInactive()
{
    self makeunusable();

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( "none", ( 0, 0, 0 ) );
    else if ( isdefined( self.owner ) )
        maps\mp\_entityheadicons::setPlayerHeadIcon( undefined, ( 0, 0, 0 ) );

    if ( isdefined( self.attackTrigger ) )
        self.attackTrigger delete();
}

isFriendlyToIMS( var_0 )
{
    if ( level.teamBased && self.team == var_0.team )
        return 1;

    return 0;
}

ims_attackTargets()
{
    level endon( "game_ended" );

    for (;;)
    {
        if ( !isdefined( self.attackTrigger ) )
            break;

        self.attackTrigger waittill( "trigger",  var_0  );

        if ( isplayer( var_0 ) )
        {
            if ( isdefined( self.owner ) && var_0 == self.owner )
                continue;

            if ( level.teamBased && var_0.pers["team"] == self.team )
                continue;

            if ( !maps\mp\_utility::isReallyAlive( var_0 ) )
                continue;
        }
        else if ( isdefined( var_0.owner ) )
        {
            if ( isdefined( self.owner ) && var_0.owner == self.owner )
                continue;

            if ( level.teamBased && var_0.owner.pers["team"] == self.team )
                continue;
        }

        if ( !sighttracepassed( self.attackHeightPos, var_0.origin + ( 0, 0, 50 ), 0, self ) || !sighttracepassed( self gettagorigin( level.imsSettings[self.imsType].tagLid1 ) + ( 0, 0, 5 ), var_0.origin + ( 0, 0, 50 ), 0, self ) && !sighttracepassed( self gettagorigin( level.imsSettings[self.imsType].tagLid2 ) + ( 0, 0, 5 ), var_0.origin + ( 0, 0, 50 ), 0, self ) && !sighttracepassed( self gettagorigin( level.imsSettings[self.imsType].tagLid3 ) + ( 0, 0, 5 ), var_0.origin + ( 0, 0, 50 ), 0, self ) && !sighttracepassed( self gettagorigin( level.imsSettings[self.imsType].tagLid4 ) + ( 0, 0, 5 ), var_0.origin + ( 0, 0, 50 ), 0, self ) )
            continue;

        self playsound( "ims_trigger" );

        if ( isplayer( var_0 ) && var_0 maps\mp\_utility::_hasPerk( "specialty_delaymine" ) )
        {
            var_0 notify( "triggered_ims" );
            wait(level.delayMineTime);

            if ( !isdefined( self.attackTrigger ) )
                break;
        }
        else
            wait(level.imsSettings[self.imsType].gracePeriod);

        if ( isdefined( self.explosive1 ) && !isdefined( self.explosive1.fired ) )
            fire_sensor( var_0, self.explosive1, self.lid1 );
        else if ( isdefined( self.explosive2 ) && !isdefined( self.explosive2.fired ) )
            fire_sensor( var_0, self.explosive2, self.lid2 );
        else if ( isdefined( self.explosive3 ) && !isdefined( self.explosive3.fired ) )
            fire_sensor( var_0, self.explosive3, self.lid3 );
        else if ( isdefined( self.explosive4 ) && !isdefined( self.explosive4.fired ) )
            fire_sensor( var_0, self.explosive4, self.lid4 );

        self.attacks--;

        if ( self.attacks <= 0 )
            break;

        wait 2.0;

        if ( !isdefined( self.owner ) )
            break;
    }

    if ( isdefined( self.carriedBy ) && isdefined( self.owner ) && self.carriedBy == self.owner )
        return;

    self notify( "death" );
}

fire_sensor( var_0, var_1, var_2 )
{
    playfx( level._effect["ims_sensor_explode"], var_2.origin );
    var_2 hide();
    var_1.fired = 1;
    var_1 unlink();
    var_1 rotateyaw( 3600, self.attackMoveTime );
    var_1 moveto( self.attackHeightPos, self.attackMoveTime, self.attackMoveTime * 0.25, self.attackMoveTime * 0.25 );

    if ( isdefined( var_1.killCamEnt ) )
    {
        if ( isdefined( self.owner ) )
            self.owner.imsKillCamEnt = var_1.killCamEnt;

        var_1.killCamEnt moveto( self.attackHeightPos + self.killCamOffset, self.attackMoveTime, self.attackMoveTime * 0.25, self.attackMoveTime * 0.25 );
        var_1.killCamEnt thread deleteAfterTime( 5.0 );
    }

    var_1 playsound( "ims_launch" );
    var_1 waittill( "movedone" );
    playfx( level._effect["ims_sensor_explode"], var_1.origin );
    var_3 = [];
    var_3[0] = var_0.origin;

    for ( var_4 = 0; var_4 < var_3.size; var_4++ )
    {
        if ( isdefined( self.owner ) )
        {
            magicbullet( "ims_projectile_mp", var_1.origin, var_3[var_4], self.owner );
            continue;
        }

        magicbullet( "ims_projectile_mp", var_1.origin, var_3[var_4] );
    }

    var_2 delete();
    var_1 delete();
}

deleteAfterTime( var_0 )
{
    self endon( "death" );
    level maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_0 );

    if ( isdefined( self ) )
        self delete();
}

ims_timeOut()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = level.imsSettings[self.imsType].lifeSpan;

    while ( var_0 )
    {
        wait 1.0;
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

        if ( !isdefined( self.carriedBy ) )
            var_0 = max( 0, var_0 - 1.0 );
    }

    self notify( "death" );
}

addToIMSList( var_0 )
{
    level.ims[var_0] = self;
}

removeFromIMSList( var_0 )
{
    level.ims[var_0] = undefined;
}

ims_hideAllParts()
{
    if ( isdefined( self.lid1 ) )
        self.lid1 hide();

    if ( isdefined( self.lid2 ) )
        self.lid2 hide();

    if ( isdefined( self.lid3 ) )
        self.lid3 hide();

    if ( isdefined( self.lid4 ) )
        self.lid4 hide();

    if ( isdefined( self.explosive1 ) )
        self.explosive1 hide();

    if ( isdefined( self.explosive2 ) )
        self.explosive2 hide();

    if ( isdefined( self.explosive3 ) )
        self.explosive3 hide();

    if ( isdefined( self.explosive4 ) )
        self.explosive4 hide();

    self hide();
    self.hidden = 1;
}

ims_showAllParts()
{
    if ( isdefined( self.lid1 ) )
        self.lid1 show();

    if ( isdefined( self.lid2 ) )
        self.lid2 show();

    if ( isdefined( self.lid3 ) )
        self.lid3 show();

    if ( isdefined( self.lid4 ) )
        self.lid4 show();

    if ( isdefined( self.explosive1 ) )
        self.explosive1 show();

    if ( isdefined( self.explosive2 ) )
        self.explosive2 show();

    if ( isdefined( self.explosive3 ) )
        self.explosive3 show();

    if ( isdefined( self.explosive4 ) )
        self.explosive4 show();

    self show();
    self.hidden = 0;
}
