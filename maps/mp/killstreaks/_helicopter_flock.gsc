// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precachevehicle( "attack_littlebird_mp" );
    precachemodel( "vehicle_apache_mp" );
    precachemodel( "vehicle_apache_mg" );
    precacheturret( "apache_minigun_mp" );
    precachevehicle( "apache_strafe_mp" );
    level.killstreakFuncs["littlebird_flock"] = ::tryUseLbFlock;
    level.heli_flock = [];
}

tryUseLbFlock( var_0, var_1 )
{
    if ( !maps\mp\_utility::validateUseStreak() )
        return 0;

    var_2 = 5;

    if ( heliflockactive() || maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount + var_2 >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        return 0;
    }

    maps\mp\_utility::incrementFauxVehicleCount();
    maps\mp\_utility::incrementFauxVehicleCount();
    maps\mp\_utility::incrementFauxVehicleCount();
    maps\mp\_utility::incrementFauxVehicleCount();
    maps\mp\_utility::incrementFauxVehicleCount();
    var_3 = selectLbStrikeLocation( var_0, "littlebird_flock" );

    if ( !isdefined( var_3 ) || !var_3 )
    {
        maps\mp\_utility::decrementFauxVehicleCount();
        maps\mp\_utility::decrementFauxVehicleCount();
        maps\mp\_utility::decrementFauxVehicleCount();
        maps\mp\_utility::decrementFauxVehicleCount();
        maps\mp\_utility::decrementFauxVehicleCount();
        return 0;
    }

    level thread maps\mp\_utility::teamPlayerCardSplash( "used_littlebird_flock", self, self.team );
    return 1;
}

heliflockactive()
{
    var_0 = 0;

    for ( var_1 = 0; var_1 < level.heli_flock.size; var_1++ )
    {
        if ( isdefined( level.heli_flock[var_1] ) )
        {
            var_0 = 1;
            break;
        }
    }

    return var_0;
}

selectLbStrikeLocation( var_0, var_1 )
{
    self playlocalsound( game["voice"][self.team] + "KS_lbd_inposition" );
    maps\mp\_utility::_beginLocationSelection( var_1, "map_artillery_selector", 1, 500 );
    self endon( "stop_location_selection" );
    self waittill( "confirm_location",  var_2, var_3  );

    if ( heliflockactive() || maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        self notify( "cancel_location" );
        return 0;
    }

    level.heli_flock = [];
    level.heli_flock_victims = [];
    thread littlebirdMadeSelectionVO();
    thread finishLbStrikeUsage( var_0, var_2, ::callStrike, var_3 );
    self setblurforplayer( 0, 0.3 );
    return 1;
}

littlebirdMadeSelectionVO()
{
    self endon( "death" );
    self endon( "disconnect" );
    self playlocalsound( game["voice"][self.team] + "KS_hqr_littlebird" );
    wait 3.0;
    self playlocalsound( game["voice"][self.team] + "KS_lbd_inbound" );
}

finishLbStrikeUsage( var_0, var_1, var_2, var_3 )
{
    self notify( "used" );
    wait 0.05;
    thread maps\mp\_utility::stopLocationSelection( 0 );

    if ( isdefined( self ) )
        self thread [[ var_2 ]]( var_0, var_1, var_3 );
}

callStrike( var_0, var_1, var_2 )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    thread handleownerleft();
    var_3 = getFlightPath( var_1, var_2, 0 );
    var_4 = getFlightPath( var_1, var_2, -520 );
    var_5 = getFlightPath( var_1, var_2, 520 );
    var_6 = getFlightPath( var_1, var_2, -1040 );
    var_7 = getFlightPath( var_1, var_2, 1040 );
    level thread doLbStrike( var_0, self, var_3, 0 );
    wait 0.3;
    level thread doLbStrike( var_0, self, var_4, 1 );
    level thread doLbStrike( var_0, self, var_5, 2 );
    wait 0.3;
    level thread doLbStrike( var_0, self, var_6, 3 );
    level thread doLbStrike( var_0, self, var_7, 4 );
    maps\mp\_matchdata::logKillstreakEvent( "littlebird_flock", var_1 );
}

getFlightPath( var_0, var_1, var_2 )
{
    var_0 *= ( 1, 1, 0 );
    var_3 = ( 0, var_1, 0 );
    var_4 = 12000;
    var_5 = [];

    if ( isdefined( var_2 ) && var_2 != 0 )
        var_0 = var_0 + anglestoright( var_3 ) * var_2 + ( 0, 0, randomint( 300 ) );

    var_6 = var_0 + anglestoforward( var_3 ) * ( -1 * var_4 );
    var_7 = var_0 + anglestoforward( var_3 ) * var_4;
    var_8 = maps\mp\killstreaks\_airdrop::getFlyHeightOffset( var_0 ) + 256;
    var_5["start"] = var_6 + ( 0, 0, var_8 );
    var_5["end"] = var_7 + ( 0, 0, var_8 );
    return var_5;
}

doLbStrike( var_0, var_1, var_2, var_3 )
{
    level endon( "game_ended" );

    if ( !isdefined( var_1 ) )
        return;

    var_4 = vectortoangles( var_2["end"] - var_2["start"] );
    var_5 = spawnAttackLittleBird( var_1, var_2["start"], var_4, var_3 );
    var_5.lifeId = var_0;
    var_5.alreadyDead = 0;
    var_5 thread watchTimeOut();
    var_5 thread watchDeath();
    var_5 thread flock_handleDamage();
    var_5 thread startLbFiring1();
    var_5 thread monitorKills();
    var_5 endon( "death" );
    var_5 setmaxpitchroll( 120, 60 );
    var_5 vehicle_setspeed( 48, 48 );
    var_5 setvehgoalpos( var_2["end"], 0 );
    var_5 waittill( "goal" );
    var_5 setmaxpitchroll( 30, 40 );
    var_5 vehicle_setspeed( 32, 32 );
    var_5 setvehgoalpos( var_2["start"], 0 );
    wait 2;
    var_5 setmaxpitchroll( 100, 60 );
    var_5 vehicle_setspeed( 64, 64 );
    var_5 waittill( "goal" );
    var_5 notify( "gone" );
    var_5 removeLittlebird();
}

spawnAttackLittleBird( var_0, var_1, var_2, var_3 )
{
    var_4 = spawnhelicopter( var_0, var_1, var_2, "apache_strafe_mp", "vehicle_apache_mp" );

    if ( !isdefined( var_4 ) )
        return;

    var_4 maps\mp\killstreaks\_helicopter::addToLittleBirdList();
    var_4 thread maps\mp\killstreaks\_helicopter::removeFromLittleBirdListOnDeath();
    var_4.health = 999999;
    var_4.maxHealth = 2000;
    var_4.damagetaken = 0;
    var_4 setcandamage( 1 );
    var_4.owner = var_0;
    var_4.team = var_0.team;
    var_4.killCount = 0;
    var_4.streakName = "littlebird_flock";
    var_4.heliType = "littlebird";
    var_4.specialDamageCallback = ::Callback_VehicleDamage;
    var_5 = spawnturret( "misc_turret", var_4.origin, "apache_minigun_mp" );
    var_5 linkto( var_4, "tag_turret", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    var_5 setmodel( "vehicle_apache_mg" );
    var_5.angles = var_4.angles;
    var_5.owner = var_4.owner;
    var_5.team = var_5.owner.team;
    var_5 maketurretinoperable();
    var_5.vehicle = var_4;
    var_6 = var_4.origin + ( anglestoforward( var_4.angles ) * -200 + anglestoright( var_4.angles ) * -200 ) + ( 0, 0, 50 );
    var_5.killCamEnt = spawn( "script_model", var_6 );
    var_5.killCamEnt setscriptmoverkillcam( "explosive" );
    var_5.killCamEnt linkto( var_4, "tag_origin" );
    var_4.mgTurret1 = var_5;
    var_4.mgTurret1 setdefaultdroppitch( 0 );
    var_4.mgTurret1 setmode( "auto_nonai" );
    var_4.mgTurret1 setsentryowner( var_4.owner );

    if ( level.teamBased )
        var_4.mgTurret1 setturretteam( var_4.owner.team );

    level.heli_flock[var_3] = var_4;
    return var_4;
}

watchTimeOut()
{
    level endon( "game_ended" );
    self endon( "gone" );
    self endon( "death" );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( 60.0 );
    self notify( "death" );
}

monitorKills()
{
    level endon( "game_ended" );
    self endon( "gone" );
    self endon( "death" );
    self endon( "stopFiring" );

    for (;;)
    {
        self waittill( "killedPlayer",  var_0  );
        self.killCount++;
        level.heli_flock_victims[level.heli_flock_victims.size] = var_0;
    }
}

startLbFiring1()
{
    self endon( "gone" );
    self endon( "death" );
    self endon( "stopFiring" );

    for (;;)
    {
        self.mgTurret1 waittill( "turret_on_target" );
        var_0 = 1;
        var_1 = self.mgTurret1 getturrettarget( 0 );

        foreach ( var_3 in level.heli_flock_victims )
        {
            if ( var_1 == var_3 )
            {
                self.mgTurret1 cleartargetentity();
                var_0 = 0;
                break;
            }
        }

        if ( var_0 )
            self.mgTurret1 shootturret();
    }
}

handleownerleft()
{
    level endon( "game_ended" );
    self endon( "flock_done" );
    thread notifyonflockdone();
    common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );

    for ( var_0 = 0; var_0 < level.heli_flock.size; var_0++ )
    {
        if ( isdefined( level.heli_flock[var_0] ) )
            level.heli_flock[var_0] notify( "stopFiring" );
    }

    for ( var_0 = 0; var_0 < level.heli_flock.size; var_0++ )
    {
        if ( isdefined( level.heli_flock[var_0] ) )
        {
            level.heli_flock[var_0] notify( "death" );
            wait 0.1;
        }
    }
}

notifyonflockdone()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );

    while ( heliflockactive() )
        wait 0.5;

    self notify( "flock_done" );
}

flock_handleDamage()
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
                var_12 = self.maxHealth * 0.25;
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

watchDeath()
{
    self endon( "gone" );
    self waittill( "death" );
    thread heliDestroyed();
}

heliDestroyed()
{
    self endon( "gone" );

    if ( !isdefined( self ) )
        return;

    self vehicle_setspeed( 25, 5 );
    thread lbSpin( randomintrange( 180, 220 ) );
    wait(randomfloatrange( 0.5, 1.5 ));
    lbExplode();
}

lbSpin( var_0 )
{
    self endon( "explode" );
    playfxontag( level.chopper_fx["explode"]["medium"], self, "tail_rotor_jnt" );
    thread trail_fx( level.chopper_fx["smoke"]["trail"], "tail_rotor_jnt", "stop tail smoke" );
    self setyawspeed( var_0, var_0, var_0 );

    while ( isdefined( self ) )
    {
        self settargetyaw( self.angles[1] + var_0 * 0.9 );
        wait 1;
    }
}

trail_fx( var_0, var_1, var_2 )
{
    self notify( var_2 );
    self endon( var_2 );
    self endon( "death" );

    for (;;)
    {
        playfxontag( var_0, self, var_1 );
        wait 0.05;
    }
}

lbExplode()
{
    var_0 = self.origin + ( 0, 0, 1 ) - self.origin;
    var_1 = self gettagangles( "tag_deathfx" );
    playfx( level.chopper_fx["explode"]["air_death"]["littlebird"], self gettagorigin( "tag_deathfx" ), anglestoforward( var_1 ), anglestoup( var_1 ) );
    self playsound( "cobra_helicopter_crash" );
    self notify( "explode" );
    removeLittlebird();
}

removeLittlebird()
{
    if ( isdefined( self.mgTurret1 ) )
    {
        if ( isdefined( self.mgTurret1.killCamEnt ) )
            self.mgTurret1.killCamEnt delete();

        self.mgTurret1 delete();
    }

    maps\mp\_utility::decrementFauxVehicleCount();
    self delete();
}
