// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.killstreakFuncs["littlebird_support"] = ::tryUseLBSupport;
    level.heliGuardSettings = [];
    level.heliGuardSettings["littlebird_support"] = spawnstruct();
    level.heliGuardSettings["littlebird_support"].timeOut = 60.0;
    level.heliGuardSettings["littlebird_support"].health = 999999;
    level.heliGuardSettings["littlebird_support"].maxHealth = 2000;
    level.heliGuardSettings["littlebird_support"].streakName = "littlebird_support";
    level.heliGuardSettings["littlebird_support"].weaponInfo = "attack_littlebird_mp";
    level.heliGuardSettings["littlebird_support"].weaponinfo = "littlebird_guard_minigun_mp";
    level.heliGuardSettings["littlebird_support"].weaponModelLeft = "vehicle_little_bird_minigun_left";
    level.heliGuardSettings["littlebird_support"].weaponModelRight = "vehicle_little_bird_minigun_right";
    level.heliGuardSettings["littlebird_support"].weaponTagLeft = "tag_minigun_attach_left";
    level.heliGuardSettings["littlebird_support"].weaponTagRight = "tag_minigun_attach_right";
    level.heliGuardSettings["littlebird_support"].sentryMode = "auto_nonai";
    level.heliGuardSettings["littlebird_support"].modelBase = "vehicle_little_bird_armed";
    level.heliGuardSettings["littlebird_support"].teamSplash = "used_littlebird_support";

    foreach ( var_1 in level.heliGuardSettings )
    {
        precachevehicle( var_1.weaponInfo );
        precacheturret( var_1.weaponinfo );
        precachemodel( var_1.weaponModelLeft );
        precachemodel( var_1.weaponModelRight );
        precachemodel( var_1.modelBase );
    }

    lbSupport_setAirStartNodes();
    lbSupport_setAirNodeMesh();
}

tryUseLBSupport( var_0 )
{
    var_1 = "littlebird_support";
    var_2 = 1;

    if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }
    else if ( maps\mp\_utility::isUsingRemote() )
        return 0;
    else if ( isdefined( level.littlebirdGuard ) || maps\mp\killstreaks\_helicopter::exceededMaxLittlebirds( var_1 ) )
    {
        self iprintlnbold( &"MP_AIR_SPACE_TOO_CROWDED" );
        return 0;
    }
    else if ( !level.air_node_mesh.size )
    {
        self iprintlnbold( &"MP_UNAVAILABLE_IN_LEVEL" );
        return 0;
    }
    else if ( maps\mp\_utility::currentActiveVehicleCount() >= maps\mp\_utility::maxVehiclesAllowed() || level.fauxVehicleCount + var_2 >= maps\mp\_utility::maxVehiclesAllowed() )
    {
        self iprintlnbold( &"MP_TOO_MANY_VEHICLES" );
        return 0;
    }

    maps\mp\_utility::incrementFauxVehicleCount();
    var_3 = createLBGuard( var_1 );

    if ( !isdefined( var_3 ) )
    {
        maps\mp\_utility::decrementFauxVehicleCount();
        return 0;
    }

    thread startLBSupport( var_3 );
    level thread maps\mp\_utility::teamPlayerCardSplash( level.heliGuardSettings[var_1].teamSplash, self, self.team );
    return 1;
}

createLBGuard( var_0 )
{
    var_1 = lbSupport_getClosestStartNode( self.origin );

    if ( isdefined( var_1.angles ) )
        var_2 = var_1.angles;
    else
        var_2 = ( 0, 0, 0 );

    var_3 = maps\mp\killstreaks\_airdrop::getFlyHeightOffset( self.origin );
    var_4 = lbSupport_getClosestNode( self.origin );
    var_4 = lbsupport_tu0_new_incoming_position( var_4 );
    var_5 = anglestoforward( self.angles );
    var_6 = var_4.origin * ( 1, 1, 0 ) + ( 0, 0, 1 ) * var_3 + var_5 * -100;
    var_7 = var_1.origin;
    var_8 = spawnhelicopter( self, var_7, var_2, level.heliGuardSettings[var_0].weaponInfo, level.heliGuardSettings[var_0].modelBase );

    if ( !isdefined( var_8 ) )
        return;

    var_8 maps\mp\killstreaks\_helicopter::addToLittleBirdList();
    var_8 thread maps\mp\killstreaks\_helicopter::removeFromLittleBirdListOnDeath();
    var_8.health = level.heliGuardSettings[var_0].health;
    var_8.maxHealth = level.heliGuardSettings[var_0].maxHealth;
    var_8.damagetaken = 0;
    var_8.speed = 100;
    var_8.followSpeed = 40;
    var_8.owner = self;
    var_8.team = self.team;
    var_8 setmaxpitchroll( 45, 45 );
    var_8 vehicle_setspeed( var_8.speed, 100, 40 );
    var_8 setyawspeed( 120, 60 );
    var_8 setneargoalnotifydist( 512 );
    var_8.killCount = 0;
    var_8.heliType = "littlebird";
    var_8.heliGuardType = "littlebird_support";
    var_8.targettingRadius = 2000;
    var_8.targetPos = var_6;
    var_8.currentNode = var_4;
    var_9 = spawnturret( "misc_turret", var_8.origin, level.heliGuardSettings[var_0].weaponinfo );
    var_9 linkto( var_8, level.heliGuardSettings[var_0].weaponTagLeft, ( 0, 0, 0 ), ( 0, 0, 0 ) );
    var_9 setmodel( level.heliGuardSettings[var_0].weaponModelLeft );
    var_9.angles = var_8.angles;
    var_9.owner = var_8.owner;
    var_9.team = self.team;
    var_9 maketurretinoperable();
    var_9.vehicle = var_8;
    var_8.mgTurretLeft = var_9;
    var_8.mgTurretLeft setdefaultdroppitch( 0 );
    var_10 = var_8.origin + ( anglestoforward( var_8.angles ) * -100 + anglestoright( var_8.angles ) * -100 ) + ( 0, 0, 50 );
    var_9.killCamEnt = spawn( "script_model", var_10 );
    var_9.killCamEnt setscriptmoverkillcam( "explosive" );
    var_9.killCamEnt linkto( var_8, "tag_origin" );
    var_9 = spawnturret( "misc_turret", var_8.origin, level.heliGuardSettings[var_0].weaponinfo );
    var_9 linkto( var_8, level.heliGuardSettings[var_0].weaponTagRight, ( 0, 0, 0 ), ( 0, 0, 0 ) );
    var_9 setmodel( level.heliGuardSettings[var_0].weaponModelRight );
    var_9.angles = var_8.angles;
    var_9.owner = var_8.owner;
    var_9.team = self.team;
    var_9 maketurretinoperable();
    var_9.vehicle = var_8;
    var_8.mgTurretRight = var_9;
    var_8.mgTurretRight setdefaultdroppitch( 0 );
    var_10 = var_8.origin + ( anglestoforward( var_8.angles ) * -100 + anglestoright( var_8.angles ) * 100 ) + ( 0, 0, 50 );
    var_9.killCamEnt = spawn( "script_model", var_10 );
    var_9.killCamEnt setscriptmoverkillcam( "explosive" );
    var_9.killCamEnt linkto( var_8, "tag_origin" );

    if ( level.teamBased )
    {
        var_8.mgTurretLeft setturretteam( self.team );
        var_8.mgTurretRight setturretteam( self.team );
    }

    var_8.mgTurretLeft setmode( level.heliGuardSettings[var_0].sentryMode );
    var_8.mgTurretRight setmode( level.heliGuardSettings[var_0].sentryMode );
    var_8.mgTurretLeft setsentryowner( self );
    var_8.mgTurretRight setsentryowner( self );
    var_8.mgTurretLeft thread lbSupport_attackTargets();
    var_8.mgTurretRight thread lbSupport_attackTargets();
    var_8.attract_strength = 10000;
    var_8.attract_range = 150;
    var_8.attractor = missile_createattractorent( var_8, var_8.attract_strength, var_8.attract_range );
    var_8.hasDodged = 0;
    var_8.empGrenaded = 0;
    var_8 thread lbSupport_handleDamage();
    var_8 thread lbSupport_watchDeath();
    var_8 thread lbSupport_watchTimeout();
    var_8 thread lbSupport_watchOwnerLoss();
    var_8 thread lbSupport_watchOwnerDamage();
    var_8 thread lbSupport_watchRoundEnd();
    var_8 thread lbSupport_lightFX();
    level.littlebirdGuard = var_8;
    var_8.owner maps\mp\_matchdata::logKillstreakEvent( level.heliGuardSettings[var_8.heliGuardType].streakName, var_8.targetPos );
    return var_8;
}

lbSupport_lightFX()
{
    playfxontag( level.chopper_fx["light"]["left"], self, "tag_light_nose" );
    wait 0.05;
    playfxontag( level.chopper_fx["light"]["belly"], self, "tag_light_belly" );
    wait 0.05;
    playfxontag( level.chopper_fx["light"]["tail"], self, "tag_light_tail1" );
    wait 0.05;
    playfxontag( level.chopper_fx["light"]["tail"], self, "tag_light_tail2" );
}

startLBSupport( var_0 )
{
    level endon( "game_ended" );
    var_0 endon( "death" );
    var_0 setlookatent( self );
    var_0 setvehgoalpos( var_0.targetPos );
    var_0 waittill( "near_goal" );
    var_0 vehicle_setspeed( var_0.speed, 60, 30 );
    var_0 waittill( "goal" );
    var_0 setvehgoalpos( var_0.currentNode.origin, 1 );
    var_0 waittill( "goal" );
    var_0 thread lbSupport_followPlayer();
    var_0 thread maps\mp\killstreaks\_helicopter::handleIncomingSAM( ::lbSupport_watchSAMProximity );
    var_0 thread maps\mp\killstreaks\_helicopter::handleIncomingStinger( ::lbsupport_watchstingerproximity );
}

lbSupport_followPlayer()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "leaving" );

    if ( !isdefined( self.owner ) )
    {
        thread lbSupport_leave();
        return;
    }

    self.owner endon( "disconnect" );
    self.owner endon( "joined_team" );
    self.owner endon( "joined_spectators" );
    self vehicle_setspeed( self.followSpeed, 20, 20 );

    for (;;)
    {
        if ( isdefined( self.owner ) && isalive( self.owner ) )
        {
            var_0 = lbSupport_getClosestLinkedNode( self.owner.origin );

            if ( isdefined( var_0 ) && var_0 != self.currentNode )
            {
                self.currentNode = var_0;
                lbSupport_moveToPlayer();
                continue;
            }
        }

        wait 1;
    }
}

lbSupport_moveToPlayer()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "leaving" );
    self.owner endon( "death" );
    self.owner endon( "disconnect" );
    self.owner endon( "joined_team" );
    self.owner endon( "joined_spectators" );
    self notify( "lbSupport_moveToPlayer" );
    self endon( "lbSupport_moveToPlayer" );
    self.inTransit = 1;
    self setvehgoalpos( self.currentNode.origin, 1 );
    self waittill( "goal" );
    self.inTransit = 0;
    self notify( "hit_goal" );
}

lbSupport_watchDeath()
{
    level endon( "game_ended" );
    self endon( "gone" );
    self waittill( "death" );
    thread heliDestroyed();
}

lbSupport_watchTimeout()
{
    level endon( "game_ended" );
    self endon( "death" );
    self.owner endon( "disconnect" );
    self.owner endon( "joined_team" );
    self.owner endon( "joined_spectators" );
    var_0 = level.heliGuardSettings[self.heliGuardType].timeOut;
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( var_0 );
    thread lbSupport_leave();
}

lbSupport_watchOwnerLoss()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "leaving" );
    self.owner common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );
    thread lbSupport_leave();
}

lbSupport_watchOwnerDamage()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "leaving" );
    self.owner endon( "disconnect" );
    self.owner endon( "joined_team" );
    self.owner endon( "joined_spectators" );

    for (;;)
    {
        self.owner waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( isplayer( var_1 ) )
        {
            if ( var_1 != self.owner && distance2d( var_1.origin, self.origin ) <= self.targettingRadius && !var_1 maps\mp\_utility::_hasPerk( "specialty_blindeye" ) && !( level.hardcoreMode && level.teamBased && var_1.team == self.team ) )
            {
                self setlookatent( var_1 );
                self.mgTurretLeft settargetentity( var_1 );
                self.mgTurretRight settargetentity( var_1 );
            }
        }
    }
}

lbSupport_watchRoundEnd()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "leaving" );
    self.owner endon( "disconnect" );
    self.owner endon( "joined_team" );
    self.owner endon( "joined_spectators" );
    level waittill( "round_end_finished" );
    thread lbSupport_leave();
}

lbSupport_leave()
{
    self endon( "death" );
    self notify( "leaving" );
    level.littlebirdGuard = undefined;
    self clearlookatent();
    var_0 = maps\mp\killstreaks\_airdrop::getFlyHeightOffset( self.origin );
    var_1 = self.origin + ( 0, 0, var_0 );
    self vehicle_setspeed( self.speed, 60 );
    self setmaxpitchroll( 45, 180 );
    self setvehgoalpos( var_1 );
    self waittill( "goal" );
    var_1 += anglestoforward( self.angles ) * 15000;
    var_2 = spawn( "script_origin", var_1 );

    if ( isdefined( var_2 ) )
    {
        self setlookatent( var_2 );
        var_2 thread wait_and_delete( 3.0 );
    }

    self setvehgoalpos( var_1 );
    self waittill( "goal" );
    self notify( "gone" );
    removeLittlebird();
}

wait_and_delete( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    wait(var_0);
    self delete();
}

lbSupport_handleDamage()
{
    self endon( "death" );
    level endon( "game_ended" );
    self setcandamage( 1 );

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_1 ) )
            continue;

        if ( !isdefined( self ) )
            return;

        if ( isdefined( var_8 ) && var_8 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;
        var_10 = var_0;

        if ( isplayer( var_1 ) )
        {
            if ( var_1 != self.owner && distance2d( var_1.origin, self.origin ) <= self.targettingRadius && !var_1 maps\mp\_utility::_hasPerk( "specialty_blindeye" ) && !( level.hardcoreMode && level.teamBased && var_1.team == self.team ) )
            {
                self setlookatent( var_1 );
                self.mgTurretLeft settargetentity( var_1 );
                self.mgTurretRight settargetentity( var_1 );
            }

            var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "helicopter" );

            if ( var_4 == "MOD_RIFLE_BULLET" || var_4 == "MOD_PISTOL_BULLET" )
            {
                if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                    var_10 += var_0 * level.armorPiercingMod;
            }
        }

        if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
            var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "helicopter" );

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
                case "sam_projectile_mp":
                    self.largeProjectileDamage = 1;
                    var_10 = self.maxHealth * 0.25;
                    break;
                case "emp_grenade_mp":
                    var_10 = 0;
                    thread lbsupport_empgrenaded();
                    break;
                case "osprey_player_minigun_mp":
                    self.largeProjectileDamage = 0;
                    var_10 *= 2;
                    break;
            }

            maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_9, self );
        }

        self.damagetaken = self.damagetaken + var_10;

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isplayer( var_1 ) && ( !isdefined( self.owner ) || var_1 != self.owner ) )
            {
                var_1 notify( "destroyed_helicopter" );
                var_1 notify( "destroyed_killstreak",  var_9  );
                thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_little_bird", var_1 );
                var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 300, var_9, var_4 );
                var_1 thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DESTROYED_LITTLE_BIRD" );
                thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, var_1, var_0, var_4, var_9 );
            }

            if ( isdefined( self.owner ) )
                self.owner thread maps\mp\_utility::leaderDialogOnPlayer( "lbguard_destroyed" );

            self notify( "death" );
            return;
        }
    }
}

lbsupport_empgrenaded()
{
    self notify( "lbSupport_EMPGrenaded" );
    self endon( "lbSupport_EMPGrenaded" );
    self endon( "death" );
    self.owner endon( "disconnect" );
    level endon( "game_ended" );
    self.empGrenaded = 1;
    self.mgTurretRight notify( "stop_shooting" );
    self.mgTurretLeft notify( "stop_shooting" );

    if ( isdefined( level._effect["ims_sensor_explode"] ) )
    {
        playfxontag( common_scripts\utility::getfx( "ims_sensor_explode" ), self.mgTurretRight, "tag_aim" );
        playfxontag( common_scripts\utility::getfx( "ims_sensor_explode" ), self.mgTurretLeft, "tag_aim" );
    }

    wait 3.5;
    self.empGrenaded = 0;
    self.mgTurretRight notify( "turretstatechange" );
    self.mgTurretLeft notify( "turretstatechange" );
}

heliDestroyed()
{
    level.littlebirdGuard = undefined;

    if ( !isdefined( self ) )
        return;

    self vehicle_setspeed( 25, 5 );
    thread lbSpin( randomintrange( 180, 220 ) );
    wait(randomfloatrange( 0.5, 1.5 ));
    lbExplode();
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

removeLittlebird()
{
    level.lbStrike = 0;

    if ( isdefined( self.mgTurretLeft ) )
    {
        if ( isdefined( self.mgTurretLeft.killCamEnt ) )
            self.mgTurretLeft.killCamEnt delete();

        self.mgTurretLeft delete();
    }

    if ( isdefined( self.mgTurretRight ) )
    {
        if ( isdefined( self.mgTurretRight.killCamEnt ) )
            self.mgTurretRight.killCamEnt delete();

        self.mgTurretRight delete();
    }

    if ( isdefined( self.marker ) )
        self.marker delete();

    maps\mp\_utility::decrementFauxVehicleCount();
    self delete();
}

lbSupport_watchSAMProximity( var_0, var_1, var_2, var_3 )
{
    level endon( "game_ended" );
    var_2 endon( "death" );

    for ( var_4 = 0; var_4 < var_3.size; var_4++ )
    {
        if ( isdefined( var_3[var_4] ) && !var_2.hasDodged )
        {
            var_2.hasDodged = 1;
            var_5 = spawn( "script_origin", var_2.origin );
            var_5.angles = var_2.angles;
            var_5 movegravity( anglestoright( var_3[var_4].angles ) * -1000, 0.05 );
            var_5 thread maps\mp\killstreaks\_helicopter::deleteAfterTime( 5.0 );

            for ( var_6 = 0; var_6 < var_3.size; var_6++ )
            {
                if ( isdefined( var_3[var_6] ) )
                    var_3[var_6] missile_settargetent( var_5 );
            }

            var_7 = var_2.origin + anglestoright( var_3[var_4].angles ) * 200;
            var_2 vehicle_setspeed( var_2.speed, 100, 40 );
            var_2 setvehgoalpos( var_7, 1 );
            wait 2.0;
            var_2 vehicle_setspeed( var_2.followSpeed, 20, 20 );
            break;
        }
    }
}

lbsupport_watchstingerproximity( var_0, var_1, var_2 )
{
    level endon( "game_ended" );
    var_2 endon( "death" );

    if ( isdefined( self ) && !var_2.hasDodged )
    {
        var_2.hasDodged = 1;
        var_3 = spawn( "script_origin", var_2.origin );
        var_3.angles = var_2.angles;
        var_3 movegravity( anglestoright( self.angles ) * -1000, 0.05 );
        var_3 thread maps\mp\killstreaks\_helicopter::deleteAfterTime( 5.0 );
        self missile_settargetent( var_3 );
        var_4 = var_2.origin + anglestoright( self.angles ) * 200;
        var_2 vehicle_setspeed( var_2.speed, 100, 40 );
        var_2 setvehgoalpos( var_4, 1 );
        wait 2.0;
        var_2 vehicle_setspeed( var_2.followSpeed, 20, 20 );
    }
}

lbSupport_getClosestStartNode( var_0 )
{
    var_1 = undefined;
    var_2 = 999999;

    foreach ( var_4 in level.air_start_nodes )
    {
        var_5 = distance( var_4.origin, var_0 );

        if ( var_5 < var_2 )
        {
            var_1 = var_4;
            var_2 = var_5;
        }
    }

    return var_1;
}

lbSupport_getClosestNode( var_0 )
{
    var_1 = undefined;
    var_2 = 999999;

    foreach ( var_4 in level.air_node_mesh )
    {
        var_5 = distance( var_4.origin, var_0 );

        if ( var_5 < var_2 )
        {
            var_1 = var_4;
            var_2 = var_5;
        }
    }

    return var_1;
}

lbSupport_getClosestLinkedNode( var_0 )
{
    var_1 = undefined;
    var_2 = distance2d( self.currentNode.origin, var_0 );
    var_3 = var_2;

    foreach ( var_5 in self.currentNode.neighbors )
    {
        var_6 = distance2d( var_5.origin, var_0 );

        if ( var_6 < var_2 && var_6 < var_3 )
        {
            var_1 = var_5;
            var_3 = var_6;
        }
    }

    return var_1;
}

lbSupport_arrayContains( var_0, var_1 )
{
    if ( var_0.size <= 0 )
        return 0;

    foreach ( var_3 in var_0 )
    {
        if ( var_3 == var_1 )
            return 1;
    }

    return 0;
}

lbSupport_getLinkedStructs()
{
    var_0 = [];

    if ( isdefined( self.script_linkto ) )
    {
        var_1 = common_scripts\utility::get_links();

        for ( var_2 = 0; var_2 < var_1.size; var_2++ )
        {
            var_3 = common_scripts\utility::getstruct( var_1[var_2], "script_linkname" );

            if ( isdefined( var_3 ) )
                var_0[var_0.size] = var_3;
        }
    }

    return var_0;
}

lbSupport_setAirStartNodes()
{
    level.air_start_nodes = common_scripts\utility::getstructarray( "chopper_boss_path_start", "targetname" );

    foreach ( var_1 in level.air_start_nodes )
        var_1.neighbors = var_1 lbSupport_getLinkedStructs();
}

lbSupport_setAirNodeMesh()
{
    level.air_node_mesh = common_scripts\utility::getstructarray( "so_chopper_boss_path_struct", "script_noteworthy" );
    lbsupport_tu0_raise_positions();

    foreach ( var_1 in level.air_node_mesh )
    {
        var_1.neighbors = var_1 lbSupport_getLinkedStructs();

        foreach ( var_3 in level.air_node_mesh )
        {
            if ( var_1 == var_3 )
                continue;

            if ( !lbSupport_arrayContains( var_1.neighbors, var_3 ) && lbSupport_arrayContains( var_3 lbSupport_getLinkedStructs(), var_1 ) )
                var_1.neighbors[var_1.neighbors.size] = var_3;
        }
    }
}

lbsupport_tu0_raise_positions()
{
    switch ( getdvar( "mapname" ) )
    {
        case "mp_lambeth":
            var_0 = [];
            var_0[var_0.size] = ( -291.1, 1587.3, 184 );
            var_0[var_0.size] = ( -947.1, 1859.3, 376 );
            var_0[var_0.size] = ( -1155.1, 1187.3, 344 );
            var_0[var_0.size] = ( -467.1, -316.7, 184 );
            var_0[var_0.size] = ( 956.9, 2931.3, 216 );
            var_0[var_0.size] = ( 2748.9, 963.3, 328 );
            var_0[var_0.size] = ( 2732.9, 83.3, 376 );
            var_1 = [];
            var_1[var_1.size] = ( -1027.1, -1180.7, 312 );

            for ( var_2 = 0; var_2 < level.air_node_mesh.size; var_2++ )
            {
                foreach ( var_4 in var_0 )
                {
                    if ( int( level.air_node_mesh[var_2].origin[0] ) == int( var_4[0] ) && int( level.air_node_mesh[var_2].origin[1] ) == int( var_4[1] ) && int( level.air_node_mesh[var_2].origin[2] ) == int( var_4[2] ) )
                    {
                        level.air_node_mesh[var_2].origin = level.air_node_mesh[var_2].origin + ( 0, 0, 192 );
                        break;
                    }
                }

                foreach ( var_4 in var_1 )
                {
                    if ( int( level.air_node_mesh[var_2].origin[0] ) == int( var_4[0] ) && int( level.air_node_mesh[var_2].origin[1] ) == int( var_4[1] ) && int( level.air_node_mesh[var_2].origin[2] ) == int( var_4[2] ) )
                    {
                        level.air_node_mesh[var_2].origin = level.air_node_mesh[var_2].origin + ( 0, 0, 300 );
                        break;
                    }
                }
            }

            break;
        case "mp_village":
            var_8 = [];
            var_8[var_8.size] = ( 684.9, 2227.3, 680 );
            var_8[var_8.size] = ( 60.9, 1363.3, 728 );
            var_8[var_8.size] = ( 972.9, 163.3, 744 );
            var_8[var_8.size] = ( 1756.9, -444.7, 744 );
            var_8[var_8.size] = ( 412.9, 67.3, 680 );
            var_9 = [];
            var_9[var_9.size] = ( 352, 800, 736 );
            var_9[var_9.size] = ( 1600, 352, 752 );
            var_10 = [];
            var_10[var_10.size] = ( 1100.9, 1155.3, 632 );
            var_11 = ( -1155.1, -1260.7, 1096 );

            for ( var_2 = 0; var_2 < level.air_node_mesh.size; var_2++ )
            {
                foreach ( var_4 in var_8 )
                {
                    if ( int( level.air_node_mesh[var_2].origin[0] ) == int( var_4[0] ) && int( level.air_node_mesh[var_2].origin[1] ) == int( var_4[1] ) && int( level.air_node_mesh[var_2].origin[2] ) == int( var_4[2] ) )
                    {
                        level.air_node_mesh[var_2].origin = level.air_node_mesh[var_2].origin + ( 0, 0, 200 );
                        break;
                    }
                }

                foreach ( var_4 in var_9 )
                {
                    if ( int( level.air_node_mesh[var_2].origin[0] ) == int( var_4[0] ) && int( level.air_node_mesh[var_2].origin[1] ) == int( var_4[1] ) && int( level.air_node_mesh[var_2].origin[2] ) == int( var_4[2] ) )
                    {
                        level.air_node_mesh[var_2].origin = level.air_node_mesh[var_2].origin + ( 0, 0, 250 );
                        break;
                    }
                }

                foreach ( var_4 in var_10 )
                {
                    if ( int( level.air_node_mesh[var_2].origin[0] ) == int( var_4[0] ) && int( level.air_node_mesh[var_2].origin[1] ) == int( var_4[1] ) && int( level.air_node_mesh[var_2].origin[2] ) == int( var_4[2] ) )
                    {
                        level.air_node_mesh[var_2].origin = level.air_node_mesh[var_2].origin + ( 0, 0, 400 );
                        break;
                    }
                }

                if ( int( level.air_node_mesh[var_2].origin[0] ) == int( var_11[0] ) && int( level.air_node_mesh[var_2].origin[1] ) == int( var_11[1] ) && int( level.air_node_mesh[var_2].origin[2] ) == int( var_11[2] ) )
                {
                    level.air_node_mesh[var_2].origin = ( -1003, -1035, 986 );
                    continue;
                }
            }

            break;
        case "mp_interchange":
            var_18 = [];
            var_18[var_18.size] = ( -755.1, -1788.7, 360 );

            for ( var_2 = 0; var_2 < level.air_node_mesh.size; var_2++ )
            {
                foreach ( var_4 in var_18 )
                {
                    if ( int( level.air_node_mesh[var_2].origin[0] ) == int( var_4[0] ) && int( level.air_node_mesh[var_2].origin[1] ) == int( var_4[1] ) && int( level.air_node_mesh[var_2].origin[2] ) == int( var_4[2] ) )
                    {
                        level.air_node_mesh[var_2].origin = level.air_node_mesh[var_2].origin + ( 0, 0, 100 );
                        break;
                    }
                }
            }

            break;
        default:
            break;
    }
}

lbsupport_tu0_new_incoming_position( var_0 )
{
    switch ( getdvar( "mapname" ) )
    {
        case "mp_interchange":
            var_1 = [];
            var_2 = [];
            var_1[var_2.size][0] = ( 1340.9, 1299.3, 360 );
            var_1[var_2.size][1] = ( 2220.9, 115.3, 408 );
            var_2[var_2.size] = ( 1884.9, 787.3, 312 );
            var_1[var_2.size][0] = ( -755.1, -588.7, 728 );
            var_1[var_2.size][1] = ( -2563.1, -1580.7, 1192 );
            var_2[var_2.size] = ( -1363.1, -1164.7, 472 );
            var_1[var_2.size][0] = ( -35.1, -2492.7, 488 );
            var_1[var_2.size][1] = ( 396.9, -1884.7, 696 );
            var_2[var_2.size] = ( -755.1, -1788.7, 460 );
            var_3 = randomintrange( 0, 100 ) > 50;

            for ( var_4 = 0; var_4 < var_2.size; var_4++ )
            {
                if ( int( var_0.origin[0] ) == int( var_2[var_4][0] ) && int( var_0.origin[1] ) == int( var_2[var_4][1] ) && int( var_0.origin[2] ) == int( var_2[var_4][2] ) )
                {
                    for ( var_5 = 0; var_5 < level.air_node_mesh.size; var_5++ )
                    {
                        if ( int( level.air_node_mesh[var_5].origin[0] ) == int( var_1[var_4][var_3][0] ) && int( level.air_node_mesh[var_5].origin[1] ) == int( var_1[var_4][var_3][1] ) && int( level.air_node_mesh[var_5].origin[2] ) == int( var_1[var_4][var_3][2] ) )
                            return level.air_node_mesh[var_5];
                    }
                }
            }

            break;
        default:
            break;
    }

    return var_0;
}

lbSupport_attackTargets()
{
    self.vehicle endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "turretstatechange" );

        if ( self isfiringturret() && !self.vehicle.empGrenaded )
        {
            thread lbSupport_burstFireStart();
            continue;
        }

        thread lbSupport_burstFireStop();
    }
}

lbSupport_burstFireStart()
{
    self.vehicle endon( "death" );
    self.vehicle endon( "leaving" );
    self endon( "stop_shooting" );
    level endon( "game_ended" );
    var_0 = 0.1;
    var_1 = 40;
    var_2 = 80;
    var_3 = 1.0;
    var_4 = 2.0;

    for (;;)
    {
        var_5 = randomintrange( var_1, var_2 + 1 );

        for ( var_6 = 0; var_6 < var_5; var_6++ )
        {
            var_7 = self getturrettarget( 0 );

            if ( isdefined( var_7 ) && ( !isdefined( var_7.spawnTime ) || ( gettime() - var_7.spawnTime ) / 1000 > 5 ) && ( isdefined( var_7.team ) && var_7.team != "spectator" ) && maps\mp\_utility::isReallyAlive( var_7 ) )
            {
                self.vehicle setlookatent( var_7 );
                self shootturret();
            }

            wait(var_0);
        }

        wait(randomfloatrange( var_3, var_4 ));
    }
}

lbSupport_burstFireStop()
{
    self notify( "stop_shooting" );

    if ( isdefined( self.vehicle.owner ) )
        self.vehicle setlookatent( self.vehicle.owner );
}
