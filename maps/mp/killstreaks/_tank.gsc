// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    return;
}

spawnArmor( var_0, var_1, var_2 )
{
    var_3 = self dospawn( "tank", var_0 );
    var_3.health = 3000;
    var_3.targeting_delay = 1;
    var_3.team = var_0.team;
    var_3.pers["team"] = var_3.team;
    var_3.owner = var_0;
    var_3 setcandamage( 1 );
    var_3.standardSpeed = 12;
    var_3 thread deleteOnZ();
    var_3 addToTankList();
    var_3.damageCallback = ::Callback_VehicleDamage;
    return var_3;
}

deleteOnZ()
{
    self endon( "death" );
    var_0 = self.origin[2];

    for (;;)
    {
        if ( var_0 - self.origin[2] > 2048 )
        {
            self.health = 0;
            self notify( "death" );
            return;
        }

        wait 1.0;
    }
}

useTank( var_0 )
{
    return tryUseTank();
}

tryUseTank()
{
    if ( isdefined( level.tankInUse ) && level.tankInUse )
    {
        self iprintlnbold( "Armor support unavailable." );
        return 0;
    }

    if ( !isdefined( getvehiclenode( "startnode", "targetname" ) ) )
    {
        self iprintlnbold( "Tank is currently not supported in this level, bug your friendly neighborhood LD." );
        return 0;
    }

    if ( !vehicle_getspawnerarray().size )
        return 0;

    if ( self.team == "allies" )
        var_0 = level.tankSpawner["allies"] spawnArmor( self, "vehicle_bradley" );
    else
        var_0 = level.tankSpawner["axis"] spawnArmor( self, "vehicle_bmp" );

    var_0 startTank();
    return 1;
}

startTank( var_0 )
{
    var_1 = getvehiclenode( "startnode", "targetname" );
    var_2 = getvehiclenode( "waitnode", "targetname" );
    self.nodes = getvehiclenodearray( "info_vehicle_node", "classname" );
    level.tankInUse = 1;
    thread tankUpdate( var_1, var_2 );
    thread tankDamageMonitor();
    level.tank = self;

    if ( level.teamBased )
    {
        var_3 = maps\mp\gametypes\_gameobjects::getNextObjID();
        objective_add( var_3, "invisible", ( 0, 0, 0 ) );
        objective_team( var_3, "allies" );
        level.tank.objID["allies"] = var_3;
        var_4 = maps\mp\gametypes\_gameobjects::getNextObjID();
        objective_add( var_4, "invisible", ( 0, 0, 0 ) );
        objective_team( var_4, "axis" );
        level.tank.objID["axis"] = var_4;
        var_5 = self.team;
        level.tank.team = var_5;
        level.tank.pers["team"] = var_5;
    }

    var_6 = spawnturret( "misc_turret", self.origin, "abrams_minigun_mp" );
    var_6 linkto( self, "tag_engine_left", ( 0, 0, -20 ), ( 0, 0, 0 ) );
    var_6 setmodel( "sentry_minigun" );
    var_6.angles = self.angles;
    var_6.owner = self.owner;
    var_6 maketurretinoperable();
    self.mgTurret = var_6;
    self.mgTurret setdefaultdroppitch( 0 );
    var_7 = self.angles;
    self.angles = ( 0, 0, 0 );
    var_8 = self gettagorigin( "tag_flash" );
    self.angles = var_7;
    var_9 = var_8 - self.origin;
    thread waitForChangeTeams();
    thread waitForDisco();
    self.timeLastFired = gettime();
    var_10 = spawn( "script_origin", self gettagorigin( "tag_flash" ) );
    var_10 linkto( self, "tag_origin", var_9, ( 0, 0, 0 ) );
    var_10 hide();
    self.neutralTarget = var_10;
    thread tankGetTargets();
    thread destroyTank();
    thread tankGetMiniTargets();
    thread checkDanger();
    thread watchForThreat();
}

waitForChangeTeams()
{
    self endon( "death" );
    self.owner endon( "disconnect" );
    self.owner waittill( "joined_team" );
    self.health = 0;
    self notify( "death" );
}

waitForDisco()
{
    self endon( "death" );
    self.owner waittill( "disconnect" );
    self.health = 0;
    self notify( "death" );
}

setDirection( var_0 )
{
    if ( self.veh_pathdir != var_0 )
    {
        if ( var_0 == "forward" )
            stopToForward();
        else
            stopToReverse();
    }
}

setEngagementSpeed()
{
    self endon( "death" );
    self notify( "path_abandoned" );

    while ( isdefined( self.changingDirection ) )
        wait 0.05;

    var_0 = 2;
    self vehicle_setspeed( var_0, 10, 10 );
    self.speedType = "engage";
}

setMiniEngagementSpeed()
{
    self endon( "death" );
    self notify( "path_abandoned" );

    while ( isdefined( self.changingDirection ) )
        wait 0.05;

    var_0 = 2;
    self vehicle_setspeed( var_0, 10, 10 );
    self.speedType = "engage";
}

setStandardSpeed()
{
    self endon( "death" );

    while ( isdefined( self.changingDirection ) )
        wait 0.05;

    self vehicle_setspeed( self.standardSpeed, 10, 10 );
    self.speedType = "standard";
}

setEvadeSpeed()
{
    self endon( "death" );

    while ( isdefined( self.changingDirection ) )
        wait 0.05;

    self vehicle_setspeed( 15, 15, 15 );
    self.speedType = "evade";
    wait 1.5;
    self vehicle_setspeed( self.standardSpeed, 10, 10 );
}

setDangerSpeed()
{
    self endon( "death" );

    while ( isdefined( self.changingDirection ) )
        wait 0.05;

    self vehicle_setspeed( 5, 5, 5 );
    self.speedType = "danger";
}

stopToReverse()
{
    debugPrintLn2( "tank changing direction at " + gettime() );
    self vehicle_setspeed( 0, 5, 6 );
    self.changingDirection = 1;

    while ( self.veh_speed > 0 )
        wait 0.05;

    wait 0.25;
    self.changingDirection = undefined;
    debugPrintLn2( "tank done changing direction" );
    self.veh_transmission = "reverse";
    self.veh_pathdir = "reverse";
    self vehicle_setspeed( self.standardSpeed, 5, 6 );
}

stopToForward()
{
    debugPrintLn2( "tank changing direction at " + gettime() );
    self vehicle_setspeed( 0, 5, 6 );
    self.changingDirection = 1;

    while ( self.veh_speed > 0 )
        wait 0.05;

    wait 0.25;
    self.changingDirection = undefined;
    debugPrintLn2( "tank done changing direction" );
    self.veh_transmission = "forward";
    self.veh_pathdir = "forward";
    self vehicle_setspeed( self.standardSpeed, 5, 6 );
}

checkDanger()
{
    self endon( "death" );
    var_0 = [];
    var_1 = level.players;
    self.numEnemiesClose = 0;

    for (;;)
    {
        foreach ( var_3 in var_1 )
        {
            if ( !isdefined( var_3 ) )
                continue;

            if ( var_3.team == self.team )
            {
                wait 0.05;
                continue;
            }

            var_4 = distance2d( var_3.origin, self.origin );

            if ( var_4 < 2048 )
                self.numEnemiesClose++;

            wait 0.05;
        }

        if ( isdefined( self.speedType ) && ( self.speedType == "evade" || self.speedType == "engage" ) )
        {
            self.numEnemiesClose = 0;
            continue;
        }

        if ( self.numEnemiesClose > 1 )
            thread setDangerSpeed();
        else
            thread setStandardSpeed();

        self.numEnemiesClose = 0;
        wait 0.05;
    }
}

tankUpdate( var_0, var_1 )
{
    self endon( "tankDestroyed" );
    self endon( "death" );

    if ( !isdefined( level.graphNodes ) )
    {
        self startpath( var_0 );
        return;
    }

    self attachpath( var_0 );
    self startpath( var_0 );
    var_0 notify( "trigger",  self, 1  );
    wait 0.05;

    for (;;)
    {
        while ( isdefined( self.changingDirection ) )
            wait 0.05;

        var_2 = getNodeNearEnemies();

        if ( isdefined( var_2 ) )
            self.endNode = var_2;
        else
            self.endNode = undefined;

        wait 0.65;
    }
}

Callback_VehicleDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 )
{
    if ( ( var_1 == self || var_1 == self.mgTurret || isdefined( var_1.pers ) && var_1.pers["team"] == self.team ) && ( var_1 != self.owner || var_4 == "MOD_MELEE" ) )
        return;

    var_12 = modifyDamage( var_4, var_2, var_1 );
    self vehicle_finishdamage( var_0, var_1, var_12, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 );
}

tankDamageMonitor()
{
    self endon( "death" );
    self.damagetaken = 0;
    var_0 = self vehicle_getspeed();
    var_1 = self.health;
    var_2 = 0;
    var_3 = 0;
    var_4 = 0;

    for (;;)
    {
        self waittill( "damage",  var_5, var_6, var_7, var_8, var_9  );

        if ( isdefined( var_6.classname ) && var_6.classname == "script_vehicle" )
        {
            if ( isdefined( self.bestTarget ) && self.bestTarget != var_6 )
            {
                self.forcedTarget = var_6;
                thread explicitAbandonTarget();
            }
        }
        else if ( isplayer( var_6 ) )
        {
            var_6 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "hitHelicopter" );

            if ( var_6 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
            {
                var_10 = var_5 * level.armorPiercingMod;
                self.health = self.health - int( var_10 );
            }
        }

        if ( self.health <= 0 )
        {
            self notify( "death" );
            return;
        }
        else if ( self.health < var_1 / 4 && var_4 == 0 )
            var_4 = 1;
        else if ( self.health < var_1 / 2 && var_3 == 0 )
            var_3 = 1;
        else if ( self.health < var_1 / 1.5 && var_2 == 0 )
            var_2 = 1;

        if ( var_5 > 1000 )
            handleThreat( var_6 );
    }
}

handleThreat( var_0 )
{
    self endon( "death" );
    var_1 = randomint( 100 );

    if ( isdefined( self.bestTarget ) && self.bestTarget != var_0 && var_1 > 30 )
    {
        var_2 = [];
        var_2[0] = self.bestTarget;
        explicitAbandonTarget( 1, self.bestTarget );
        thread acquireTarget( var_2 );
    }
    else if ( !isdefined( self.bestTarget ) && var_1 > 30 )
    {
        var_2 = [];
        var_2[0] = var_0;
        thread acquireTarget( var_2 );
    }
    else if ( var_1 < 30 )
    {
        playfx( level.tankCover, self.origin );
        thread setEvadeSpeed();
    }
    else
    {
        self fireweapon();
        self playsound( "bmp_fire" );
    }
}

handlePossibleThreat( var_0 )
{
    self endon( "death" );
    var_1 = relativeAngle( var_0 );
    var_2 = distance( self.origin, var_0.origin );

    if ( randomint( 4 ) < 3 )
        return;

    if ( var_1 == "front" && var_2 < 768 )
        thread setEvadeSpeed();
    else if ( var_1 == "rear_side" || var_1 == "rear" && var_2 >= 768 )
    {
        playfx( level.tankCover, self.origin );
        thread setEvadeSpeed();
    }
    else if ( var_1 == "rear" && var_2 < 768 )
    {
        stopToReverse();
        setEvadeSpeed();
        wait 4;
        stopToForward();
    }
    else if ( var_1 == "front_side" || var_1 == "front" )
    {
        playfx( level.tankCover, self.origin );
        stopToReverse();
        setEvadeSpeed();
        wait 8;
        stopToForward();
    }
}

relativeAngle( var_0 )
{
    self endon( "death" );
    var_0 endon( "death" );
    var_0 endon( "disconnect" );
    var_1 = anglestoforward( self.angles );
    var_2 = var_0.origin - self.origin;
    var_1 *= ( 1, 1, 0 );
    var_2 *= ( 1, 1, 0 );
    var_2 = vectornormalize( var_2 );
    var_1 = vectornormalize( var_1 );
    var_3 = vectordot( var_2, var_1 );

    if ( var_3 > 0 )
    {
        if ( var_3 > 0.9 )
            return "front";
        else
            return "front_side";
    }
    else if ( var_3 < -0.9 )
        return "rear";
    else
        return "rear_side";

    var_0 iprintlnbold( var_3 );
}

watchForThreat()
{
    self endon( "death" );

    for (;;)
    {
        var_0 = [];
        var_1 = level.players;

        foreach ( var_3 in var_1 )
        {
            if ( !isdefined( var_3 ) )
            {
                wait 0.05;
                continue;
            }

            if ( !isTarget( var_3 ) )
            {
                wait 0.05;
                continue;
            }

            var_4 = var_3 getcurrentweapon();

            if ( issubstr( var_4, "at4" ) || issubstr( var_4, "stinger" ) || issubstr( var_4, "javelin" ) )
            {
                thread handlePossibleThreat( var_3 );
                wait 8;
            }

            wait 0.15;
        }
    }
}

checkOwner()
{
    if ( !isdefined( self.owner ) || !isdefined( self.owner.pers["team"] ) || self.owner.pers["team"] != self.team )
    {
        self notify( "abandoned" );
        return 0;
    }

    return 1;
}

drawLine( var_0, var_1, var_2, var_3 )
{
    var_4 = int( var_2 * 20 );

    for ( var_5 = 0; var_5 < var_4; var_5++ )
        wait 0.05;
}

modifyDamage( var_0, var_1, var_2 )
{
    if ( var_0 == "MOD_RIFLE_BULLET" )
        return var_1;
    else if ( var_0 == "MOD_PISTOL_BULLET" )
        return var_1;
    else if ( var_0 == "MOD_IMPACT" )
        return var_1;
    else if ( var_0 == "MOD_MELEE" )
        return 0;
    else if ( var_0 == "MOD_EXPLOSIVE_BULLET" )
        return var_1;
    else if ( var_0 == "MOD_GRENADE" )
        return var_1 * 5;
    else if ( var_0 == "MOD_GRENADE_SPLASH" )
        return var_1 * 5;
    else
        return var_1 * 10;
}

destroyTank()
{
    self waittill( "death" );

    if ( level.teamBased )
    {
        var_0 = level.tank.team;
        objective_state( level.tank.objID[var_0], "invisible" );
        objective_state( level.tank.objID[level.otherTeam[var_0]], "invisible" );
    }

    self notify( "tankDestroyed" );
    self vehicle_setspeed( 0, 10, 10 );
    level.tankInUse = 0;
    playfx( level.spawnFire, self.origin );
    playfx( level.tankFire, self.origin );
    removeFromTankList();
    var_1 = spawn( "script_model", self.origin );
    var_1 setmodel( "vehicle_m1a1_abrams_d_static" );
    var_1.angles = self.angles;
    self.mgTurret delete();
    self delete();
    wait 4;
    var_1 delete();
}

onHitPitchClamp()
{
    self notify( "onTargOrTimeOut" );
    self endon( "onTargOrTimeOut" );
    self endon( "turret_on_target" );
    self waittill( "turret_pitch_clamped" );
    thread explicitAbandonTarget( 0, self.bestTarget );
}

fireOnTarget()
{
    self endon( "abandonedTarget" );
    self endon( "killedTarget" );
    self endon( "death" );
    self endon( "targetRemoved" );
    self endon( "lostLOS" );

    for (;;)
    {
        onHitPitchClamp();

        if ( !isdefined( self.bestTarget ) )
            continue;

        var_0 = self gettagorigin( "tag_flash" );
        var_1 = bullettrace( self.origin, var_0, 0, self );

        if ( var_1["position"] != var_0 )
            thread explicitAbandonTarget( 0, self.bestTarget );

        var_1 = bullettrace( var_0, self.bestTarget.origin, 1, self );
        var_2 = distance( self.origin, var_1["position"] );
        var_3 = distance( self.bestTarget.origin, self.origin );

        if ( var_2 < 384 || var_2 + 256 < var_3 )
        {
            wait 0.5;

            if ( var_2 > 384 )
            {
                waitForTurretReady();
                self fireweapon();
                self playsound( "bmp_fire" );
                self.timeLastFired = gettime();
            }

            var_4 = relativeAngle( self.bestTarget );
            thread explicitAbandonTarget( 0, self.bestTarget );
            return;
        }

        waitForTurretReady();
        self fireweapon();
        self playsound( "bmp_fire" );
        self.timeLastFired = gettime();
    }
}

waitForTurretReady()
{
    self endon( "abandonedTarget" );
    self endon( "killedTarget" );
    self endon( "death" );
    self endon( "targetRemoved" );
    self endon( "lostLOS" );
    var_0 = gettime() - self.timeLastFired;

    if ( var_0 < 1499 )
        wait(1.5 - var_0 / 1000);
}

tankGetTargets( var_0 )
{
    self endon( "death" );
    self endon( "leaving" );
    var_1 = [];

    for (;;)
    {
        var_1 = [];
        var_2 = level.players;

        if ( isdefined( self.forcedTarget ) )
        {
            var_1 = [];
            var_1[0] = self.forcedTarget;
            acquireTarget( var_1 );
            self.forcedTarget = undefined;
        }

        if ( isdefined( level.harrier ) && level.harrier.team != self.team && isalive( level.harrier ) )
        {
            if ( isVehicleTarget( level.tank ) )
                var_1[var_1.size] = level.tank;
        }

        if ( isdefined( level.chopper ) && level.chopper.team != self.team && isalive( level.chopper ) )
        {
            if ( isVehicleTarget( level.chopper ) )
                var_1[var_1.size] = level.chopper;
        }

        foreach ( var_4 in var_2 )
        {
            if ( !isdefined( var_4 ) )
            {
                wait 0.05;
                continue;
            }

            if ( isdefined( var_0 ) && var_4 == var_0 )
                continue;

            if ( isTarget( var_4 ) )
            {
                if ( isdefined( var_4 ) )
                    var_1[var_1.size] = var_4;

                continue;
            }

            continue;
        }

        if ( var_1.size > 0 )
        {
            acquireTarget( var_1 );
            continue;
        }

        wait 1;
    }
}

acquireTarget( var_0 )
{
    self endon( "death" );

    if ( var_0.size == 1 )
        self.bestTarget = var_0[0];
    else
        self.bestTarget = getBestTarget( var_0 );

    thread setEngagementSpeed();
    thread watchTargetDeath( var_0 );
    self setturrettargetent( self.bestTarget );
    fireOnTarget();
    thread setNoTarget();
}

setNoTarget()
{
    self endon( "death" );
    setStandardSpeed();
    removeTarget();
    self setturrettargetent( self.neutralTarget );
}

getBestTarget( var_0 )
{
    self endon( "death" );
    var_1 = self gettagorigin( "tag_flash" );
    var_2 = self.origin;
    var_3 = undefined;
    var_4 = undefined;
    var_5 = 0;

    foreach ( var_7 in var_0 )
    {
        var_8 = abs( vectortoangles( var_7.origin - self.origin )[1] );
        var_9 = abs( self gettagangles( "tag_flash" )[1] );
        var_8 = abs( var_8 - var_9 );

        if ( isdefined( level.chopper ) && var_7 == level.chopper )
            return var_7;

        if ( isdefined( level.harrier ) && var_7 == level.harrier )
            return var_7;

        var_10 = var_7 getweaponslistitems();

        foreach ( var_12 in var_10 )
        {
            if ( issubstr( var_12, "at4" ) || issubstr( var_12, "jav" ) || issubstr( var_12, "c4" ) )
                var_8 -= 40;
        }

        if ( !isdefined( var_3 ) )
        {
            var_3 = var_8;
            var_4 = var_7;
            continue;
        }

        if ( var_3 > var_8 )
        {
            var_3 = var_8;
            var_4 = var_7;
        }
    }

    return var_4;
}

watchTargetDeath( var_0 )
{
    self endon( "abandonedTarget" );
    self endon( "lostLOS" );
    self endon( "death" );
    self endon( "targetRemoved" );
    var_1 = self.bestTarget;
    var_1 endon( "disconnect" );
    var_1 waittill( "death" );
    self notify( "killedTarget" );
    removeTarget();
    setStandardSpeed();
    thread setNoTarget();
}

explicitAbandonTarget( var_0, var_1 )
{
    self endon( "death" );
    self notify( "abandonedTarget" );
    setStandardSpeed();
    thread setNoTarget();
    removeTarget();

    if ( isdefined( var_1 ) )
    {
        self.badTarget = var_1;
        badTargetReset();
    }

    if ( isdefined( var_0 ) && var_0 )
        return;

    return;
}

badTargetReset()
{
    self endon( "death" );
    wait 1.5;
    self.badTarget = undefined;
}

removeTarget()
{
    self notify( "targetRemoved" );
    self.bestTarget = undefined;
    self.lastLostTime = undefined;
}

isVehicleTarget( var_0 )
{
    if ( distance2d( var_0.origin, self.origin ) > 4096 )
        return 0;

    if ( distance( var_0.origin, self.origin ) < 512 )
        return 0;

    return turretSightTrace( var_0, 0 );
}

isTarget( var_0 )
{
    self endon( "death" );
    var_1 = distancesquared( var_0.origin, self.origin );

    if ( !level.teamBased && isdefined( self.owner ) && var_0 == self.owner )
        return 0;

    if ( !isalive( var_0 ) || var_0.sessionstate != "playing" )
        return 0;

    if ( var_1 > 16777216 )
        return 0;

    if ( var_1 < 262144 )
        return 0;

    if ( !isdefined( var_0.pers["team"] ) )
        return 0;

    if ( var_0 == self.owner )
        return 0;

    if ( level.teamBased && var_0.pers["team"] == self.team )
        return 0;

    if ( var_0.pers["team"] == "spectator" )
        return 0;

    if ( isdefined( var_0.spawnTime ) && ( gettime() - var_0.spawnTime ) / 1000 <= 5 )
        return 0;

    if ( var_0 maps\mp\_utility::_hasPerk( "specialty_blindeye" ) )
        return 0;

    return self vehicle_canturrettargetpoint( var_0.origin, 1, self );
}

turretSightTrace( var_0, var_1 )
{
    var_2 = var_0 sightconetrace( self gettagorigin( "tag_turret" ), self );

    if ( var_2 < 0.7 )
        return 0;

    if ( isdefined( var_1 ) && var_1 )
        thread drawLine( var_0.origin, self gettagorigin( "tag_turret" ), 10, ( 1, 0, 0 ) );

    return 1;
}

isMiniTarget( var_0 )
{
    self endon( "death" );

    if ( !isalive( var_0 ) || var_0.sessionstate != "playing" )
        return 0;

    if ( !isdefined( var_0.pers["team"] ) )
        return 0;

    if ( var_0 == self.owner )
        return 0;

    if ( distancesquared( var_0.origin, self.origin ) > 1048576 )
        return 0;

    if ( level.teamBased && var_0.pers["team"] == self.team )
        return 0;

    if ( var_0.pers["team"] == "spectator" )
        return 0;

    if ( isdefined( var_0.spawnTime ) && ( gettime() - var_0.spawnTime ) / 1000 <= 5 )
        return 0;

    if ( isdefined( self ) )
    {
        var_1 = self.mgTurret.origin + ( 0, 0, 64 );
        var_2 = var_0 sightconetrace( var_1, self );

        if ( var_2 < 1 )
            return 0;
    }

    return 1;
}

tankGetMiniTargets()
{
    self endon( "death" );
    self endon( "leaving" );
    var_0 = [];

    for (;;)
    {
        var_0 = [];
        var_1 = level.players;

        for ( var_2 = 0; var_2 <= var_1.size; var_2++ )
        {
            if ( isMiniTarget( var_1[var_2] ) )
            {
                if ( isdefined( var_1[var_2] ) )
                    var_0[var_0.size] = var_1[var_2];
            }
            else
                continue;

            wait 0.05;
        }

        if ( var_0.size > 0 )
        {
            acquireMiniTarget( var_0 );
            return;
            continue;
        }

        wait 0.5;
    }
}

getBestMiniTarget( var_0 )
{
    self endon( "death" );
    var_1 = self.origin;
    var_2 = undefined;
    var_3 = undefined;

    foreach ( var_5 in var_0 )
    {
        var_6 = distance( self.origin, var_5.origin );
        var_7 = var_5 getcurrentweapon();

        if ( issubstr( var_7, "at4" ) || issubstr( var_7, "jav" ) || issubstr( var_7, "c4" ) || issubstr( var_7, "smart" ) || issubstr( var_7, "grenade" ) )
            var_6 -= 200;

        if ( !isdefined( var_2 ) )
        {
            var_2 = var_6;
            var_3 = var_5;
            continue;
        }

        if ( var_2 > var_6 )
        {
            var_2 = var_6;
            var_3 = var_5;
        }
    }

    return var_3;
}

acquireMiniTarget( var_0 )
{
    self endon( "death" );

    if ( var_0.size == 1 )
        self.bestMiniTarget = var_0[0];
    else
        self.bestMiniTarget = getBestMiniTarget( var_0 );

    if ( distance2d( self.origin, self.bestMiniTarget.origin ) > 768 )
        thread setMiniEngagementSpeed();

    self notify( "acquiringMiniTarget" );
    self.mgTurret settargetentity( self.bestMiniTarget, ( 0, 0, 64 ) );
    wait 0.15;
    thread fireMiniOnTarget();
    thread watchMiniTargetDeath( var_0 );
    thread watchMiniTargetDistance( var_0 );
    thread watchMiniTargetThreat( self.bestMiniTarget );
}

fireMiniOnTarget()
{
    self endon( "death" );
    self endon( "abandonedMiniTarget" );
    self endon( "killedMiniTarget" );
    var_0 = undefined;
    var_1 = gettime();

    if ( !isdefined( self.bestMiniTarget ) )
        return;

    for (;;)
    {
        if ( !isdefined( self.mgTurret getturrettarget( 1 ) ) )
        {
            if ( !isdefined( var_0 ) )
                var_0 = gettime();

            var_2 = gettime();

            if ( var_0 - var_2 > 1 )
            {
                var_0 = undefined;
                thread explicitAbandonMiniTarget();
                return;
            }

            wait 0.5;
            continue;
        }

        if ( gettime() > var_1 + 1000 && !isdefined( self.bestTarget ) )
        {
            if ( distance2d( self.origin, self.bestMiniTarget.origin ) > 768 )
            {
                var_3[0] = self.bestMiniTarget;
                acquireTarget( var_3 );
            }
        }

        var_4 = randomintrange( 10, 16 );

        for ( var_5 = 0; var_5 < var_4; var_5++ )
        {
            self.mgTurret shootturret();
            wait 0.1;
        }

        wait(randomfloatrange( 0.5, 3.0 ));
    }
}

watchMiniTargetDeath( var_0 )
{
    self endon( "abandonedMiniTarget" );
    self endon( "death" );

    if ( !isdefined( self.bestMiniTarget ) )
        return;

    self.bestMiniTarget waittill( "death" );
    self notify( "killedMiniTarget" );
    self.bestMiniTarget = undefined;
    self.mgTurret cleartargetentity();
    tankGetMiniTargets();
}

watchMiniTargetDistance( var_0 )
{
    self endon( "abandonedMiniTarget" );
    self endon( "death" );

    for (;;)
    {
        if ( !isdefined( self.bestMiniTarget ) )
            return;

        var_1 = bullettrace( self.mgTurret.origin, self.bestMiniTarget.origin, 0, self );
        var_2 = distance( self.origin, var_1["position"] );

        if ( var_2 > 1024 )
        {
            thread explicitAbandonMiniTarget();
            return;
        }

        wait 2;
    }
}

watchMiniTargetThreat( var_0 )
{
    self endon( "abandonedMiniTarget" );
    self endon( "death" );
    self endon( "killedMiniTarget" );

    for (;;)
    {
        var_1 = [];
        var_2 = level.players;

        for ( var_3 = 0; var_3 <= var_2.size; var_3++ )
        {
            if ( isMiniTarget( var_2[var_3] ) )
            {
                if ( !isdefined( var_2[var_3] ) )
                    continue;

                if ( !isdefined( var_0 ) )
                    return;

                var_4 = distance( self.origin, var_0.origin );
                var_5 = distance( self.origin, var_2[var_3].origin );

                if ( var_5 < var_4 )
                {
                    thread explicitAbandonMiniTarget();
                    return;
                }
            }

            wait 0.05;
        }

        wait 0.25;
    }
}

explicitAbandonMiniTarget( var_0 )
{
    self notify( "abandonedMiniTarget" );
    self.bestMiniTarget = undefined;
    self.mgTurret cleartargetentity();

    if ( isdefined( var_0 ) && var_0 )
        return;

    thread tankGetMiniTargets();
    return;
}

addToTankList()
{
    level.tanks[self getentitynumber()] = self;
}

removeFromTankList()
{
    level.tanks[self getentitynumber()] = undefined;
}

getNodeNearEnemies()
{
    var_0 = [];

    foreach ( var_2 in level.players )
    {
        if ( var_2.team == "spectator" )
            continue;

        if ( var_2.team == self.team )
            continue;

        if ( !isalive( var_2 ) )
            continue;

        var_2.dist = 0;
        var_0[var_0.size] = var_2;
    }

    if ( !var_0.size )
        return undefined;

    for ( var_4 = 0; var_4 < var_0.size; var_4++ )
    {
        for ( var_5 = var_4 + 1; var_5 < var_0.size; var_5++ )
        {
            var_6 = distancesquared( var_0[var_4].origin, var_0[var_5].origin );
            var_0[var_4].dist = var_0[var_4].dist + var_6;
            var_0[var_5].dist = var_0[var_5].dist + var_6;
        }
    }

    var_7 = var_0[0];

    foreach ( var_2 in var_0 )
    {
        if ( var_2.dist < var_7.dist )
            var_7 = var_2;
    }

    var_10 = var_7.origin;
    var_11 = sortbydistance( level.graphNodes, var_10 );
    return var_11[0];
}

setupPaths()
{
    var_0 = [];
    var_1 = [];
    var_2 = [];
    var_3 = [];
    var_4 = getvehiclenode( "startnode", "targetname" );
    var_0[var_0.size] = var_4;
    var_1[var_1.size] = var_4;

    while ( isdefined( var_4.target ) )
    {
        var_5 = var_4;
        var_4 = getvehiclenode( var_4.target, "targetname" );
        var_4.prev = var_5;

        if ( var_4 == var_0[0] )
            break;

        var_0[var_0.size] = var_4;

        if ( !isdefined( var_4.target ) )
            return;
    }

    var_0[0].branchNodes = [];
    var_0[0] thread handleBranchNode( "forward" );
    var_3[var_3.size] = var_0[0];
    var_6 = getvehiclenodearray( "branchnode", "targetname" );

    foreach ( var_8 in var_6 )
    {
        var_4 = var_8;
        var_0[var_0.size] = var_4;
        var_1[var_1.size] = var_4;

        while ( isdefined( var_4.target ) )
        {
            var_5 = var_4;
            var_4 = getvehiclenode( var_4.target, "targetname" );
            var_0[var_0.size] = var_4;
            var_4.prev = var_5;

            if ( !isdefined( var_4.target ) )
                var_2[var_2.size] = var_4;
        }
    }

    foreach ( var_4 in var_0 )
    {
        var_11 = 0;

        foreach ( var_13 in var_1 )
        {
            if ( var_13 == var_4 )
                continue;

            if ( var_13.target == var_4.targetname )
                continue;

            if ( isdefined( var_4.target ) && var_4.target == var_13.targetname )
                continue;

            if ( distance2d( var_4.origin, var_13.origin ) > 80 )
                continue;

            var_13 thread handleCapNode( var_4, "reverse" );
            var_13.prev = var_4;

            if ( !isdefined( var_4.branchNodes ) )
                var_4.branchNodes = [];

            var_4.branchNodes[var_4.branchNodes.size] = var_13;
            var_11 = 1;
        }

        if ( var_11 )
            var_4 thread handleBranchNode( "forward" );

        var_15 = 0;

        foreach ( var_17 in var_2 )
        {
            if ( var_17 == var_4 )
                continue;

            if ( !isdefined( var_4.target ) )
                continue;

            if ( var_4.target == var_17.targetname )
                continue;

            if ( isdefined( var_17.target ) && var_17.target == var_4.targetname )
                continue;

            if ( distance2d( var_4.origin, var_17.origin ) > 80 )
                continue;

            var_17 thread handleCapNode( var_4, "forward" );
            var_17.next = getvehiclenode( var_4.targetname, "targetname" );
            var_17.length = distance( var_17.origin, var_4.origin );

            if ( !isdefined( var_4.branchNodes ) )
                var_4.branchNodes = [];

            var_4.branchNodes[var_4.branchNodes.size] = var_17;
            var_15 = 1;
        }

        if ( var_15 )
            var_4 thread handleBranchNode( "reverse" );

        if ( var_15 || var_11 )
            var_3[var_3.size] = var_4;
    }

    if ( var_3.size < 3 )
    {
        level notify( "end_tankPathHandling" );
        return;
    }

    var_20 = [];

    foreach ( var_4 in var_0 )
    {
        if ( !isdefined( var_4.branchNodes ) )
            continue;

        var_20[var_20.size] = var_4;
    }

    foreach ( var_24 in var_20 )
    {
        var_4 = var_24;
        var_25 = 0;

        while ( isdefined( var_4.target ) )
        {
            var_26 = var_4;
            var_4 = getvehiclenode( var_4.target, "targetname" );
            var_25 += distance( var_4.origin, var_26.origin );

            if ( var_4 == var_24 )
                break;

            if ( isdefined( var_4.branchNodes ) )
                break;
        }

        if ( var_25 > 1000 )
        {
            var_4 = var_24;
            var_27 = 0;

            while ( isdefined( var_4.target ) )
            {
                var_26 = var_4;
                var_4 = getvehiclenode( var_4.target, "targetname" );
                var_27 += distance( var_4.origin, var_26.origin );

                if ( var_27 < var_25 / 2 )
                    continue;

                var_4.branchNodes = [];
                var_4 thread handleBranchNode( "forward" );
                var_3[var_3.size] = var_4;
                break;
            }
        }
    }

    level.graphNodes = initNodeGraph( var_3 );

    foreach ( var_4 in var_0 )
    {
        if ( !isdefined( var_4.graphId ) )
            var_4 thread nodeTracker();
    }
}

getRandomBranchNode( var_0 )
{
    var_1 = [];

    foreach ( var_4, var_3 in self.links )
    {
        if ( self.linkDirs[var_4] != var_0 )
            continue;

        var_1[var_1.size] = var_3;
    }

    return var_1[randomint( var_1.size )];
}

getNextNodeForEndNode( var_0, var_1 )
{
    var_2 = level.graphNodes[self.graphId];
    var_3 = generatePath( var_2, var_0, undefined, var_1 );
    var_4 = var_3[0].g;
    var_5 = generatePath( var_2, var_0, undefined, level.otherDir[var_1] );
    var_6 = var_5[0].g;

    if ( !getdvarint( "tankDebug" ) )
        var_6 = 9999999;

    if ( var_4 <= var_6 )
        return var_3[1];
}

handleBranchNode( var_0 )
{
    level endon( "end_tankPathHandling" );

    for (;;)
    {
        self waittill( "trigger",  var_1, var_2  );
        var_3 = level.graphNodes[self.graphId];
        var_1.node = self;
        var_4 = undefined;

        if ( isdefined( var_1.endNode ) && var_1.endNode != var_3 )
        {
            var_4 = getNextNodeForEndNode( var_1.endNode, var_1.veh_pathdir );

            if ( !isdefined( var_4 ) )
                var_1 thread setDirection( level.otherDir[var_1.veh_pathdir] );
        }

        if ( !isdefined( var_4 ) || var_4 == var_3 )
            var_4 = var_3 getRandomBranchNode( var_1.veh_pathdir );

        var_5 = var_3.linkStartNodes[var_4.graphId];

        if ( var_1.veh_pathdir == "forward" )
            var_6 = getNextNode();
        else
            var_6 = getPrevNode();

        if ( var_6 != var_5 )
            var_1 startpath( var_5 );
    }
}

handleCapNode( var_0, var_1 )
{
    for (;;)
    {
        self waittill( "trigger",  var_2  );

        if ( var_2.veh_pathdir != var_1 )
            continue;

        debugPrintLn2( "tank starting path at join node: " + var_0.graphId );
        var_2 startpath( var_0 );
    }
}

nodeTracker()
{
    self.forwardGraphId = getForwardGraphNode().graphId;
    self.reverseGraphId = getReverseGraphNode().graphId;

    for (;;)
    {
        self waittill( "trigger",  var_0, var_1  );
        var_0.node = self;
        var_0.forwardGraphId = self.forwardGraphId;
        var_0.reverseGraphId = self.reverseGraphId;

        if ( !isdefined( self.target ) || self.targetname == "branchnode" )
            var_2 = "TRANS";
        else
            var_2 = "NODE";

        if ( isdefined( var_1 ) )
        {
            debugPrint3D( self.origin, var_2, ( 1, 0.5, 0 ), 1, 2, 100 );
            continue;
        }

        debugPrint3D( self.origin, var_2, ( 0, 1, 0 ), 1, 2, 100 );
    }
}

forceTrigger( var_0, var_1, var_2 )
{
    var_1 endon( "trigger" );
    var_0 endon( "trigger" );
    var_2 endon( "death" );
    var_3 = distancesquared( var_2.origin, var_1.origin );
    var_4 = var_2.veh_pathdir;
    debugPrint3D( var_0.origin + ( 0, 0, 30 ), "LAST", ( 0, 0, 1 ), 0.5, 1, 100 );
    debugPrint3D( var_1.origin + ( 0, 0, 60 ), "NEXT", ( 0, 1, 0 ), 0.5, 1, 100 );
    var_5 = 0;

    for (;;)
    {
        wait 0.05;

        if ( var_4 != var_2.veh_pathdir )
        {
            debugPrintLn2( "tank missed node: reversing direction" );
            var_2 thread forceTrigger( var_1, var_0, var_2 );
            return;
        }

        if ( var_5 )
        {
            debugPrintLn2( "... sending notify." );
            var_1 notify( "trigger",  var_2, 1  );
            return;
        }

        var_6 = distancesquared( var_2.origin, var_1.origin );

        if ( var_6 > var_3 )
        {
            var_5 = 1;
            debugPrintLn2( "tank missed node: forcing notify in one frame..." );
        }

        var_3 = var_6;
    }
}

getForwardGraphNode()
{
    for ( var_0 = self; !isdefined( var_0.graphId ); var_0 = var_0 getNextNode() )
    {

    }

    return var_0;
}

getReverseGraphNode()
{
    for ( var_0 = self; !isdefined( var_0.graphId ); var_0 = var_0 getPrevNode() )
    {

    }

    return var_0;
}

getNextNode()
{
    if ( isdefined( self.target ) )
        return getvehiclenode( self.target, "targetname" );
    else
        return self.next;
}

getPrevNode()
{
    return self.prev;
}

initNodeGraph( var_0 )
{
    var_1 = [];

    foreach ( var_3 in var_0 )
    {
        var_4 = spawnstruct();
        var_4.linkInfos = [];
        var_4.links = [];
        var_4.linkLengths = [];
        var_4.linkDirs = [];
        var_4.linkStartNodes = [];
        var_4.node = var_3;
        var_4.origin = var_3.origin;
        var_4.graphId = var_1.size;
        var_3.graphId = var_1.size;
        debugPrint3D( var_4.origin + ( 0, 0, 80 ), var_4.graphId, ( 1, 1, 1 ), 0.65, 2, 100000 );
        var_1[var_1.size] = var_4;
    }

    foreach ( var_3 in var_0 )
    {
        var_7 = var_3.graphId;
        var_8 = getvehiclenode( var_3.target, "targetname" );
        var_9 = distance( var_3.origin, var_8.origin );
        var_10 = var_8;

        while ( !isdefined( var_8.graphId ) )
        {
            var_9 += distance( var_8.origin, var_8.prev.origin );

            if ( isdefined( var_8.target ) )
            {
                var_8 = getvehiclenode( var_8.target, "targetname" );
                continue;
            }

            var_8 = var_8.next;
        }

        var_1[var_7] addLinkNode( var_1[var_8.graphId], var_9, "forward", var_10 );
        var_8 = var_3.prev;
        var_9 = distance( var_3.origin, var_8.origin );

        for ( var_10 = var_8; !isdefined( var_8.graphId ); var_8 = var_8.prev )
            var_9 += distance( var_8.origin, var_8.prev.origin );

        var_1[var_7] addLinkNode( var_1[var_8.graphId], var_9, "reverse", var_10 );

        foreach ( var_12 in var_3.branchNodes )
        {
            var_8 = var_12;
            var_9 = distance( var_3.origin, var_8.origin );
            var_10 = var_8;

            if ( var_8.targetname == "branchnode" )
            {
                while ( !isdefined( var_8.graphId ) )
                {
                    if ( isdefined( var_8.target ) )
                        var_13 = getvehiclenode( var_8.target, "targetname" );
                    else
                        var_13 = var_8.next;

                    var_9 += distance( var_8.origin, var_13.origin );
                    var_8 = var_13;
                }

                var_1[var_7] addLinkNode( var_1[var_8.graphId], var_9, "forward", var_10 );
                continue;
            }

            while ( !isdefined( var_8.graphId ) )
            {
                var_9 += distance( var_8.origin, var_8.prev.origin );
                var_8 = var_8.prev;
            }

            var_1[var_7] addLinkNode( var_1[var_8.graphId], var_9, "reverse", var_10 );
        }
    }

    return var_1;
}

addLinkNode( var_0, var_1, var_2, var_3 )
{
    self.links[var_0.graphId] = var_0;
    self.linkLengths[var_0.graphId] = var_1;
    self.linkDirs[var_0.graphId] = var_2;
    self.linkStartNodes[var_0.graphId] = var_3;
    var_4 = spawnstruct();
    var_4.toGraphNode = var_0;
    var_4.toGraphId = var_0.graphId;
    var_4.length = var_1;
    var_4.direction = var_2;
    var_4.startNode = var_3;
    self.linkInfos[var_0.graphId] = var_4;
}

generatePath( var_0, var_1, var_2, var_3 )
{
    level.openList = [];
    level.closedList = [];
    var_4 = 0;
    var_5 = [];

    if ( !isdefined( var_2 ) )
        var_2 = [];

    var_1.g = 0;
    var_1.h = getHValue( var_1, var_0 );
    var_1.f = var_1.g + var_1.h;
    addToClosedList( var_1 );
    var_6 = var_1;

    for (;;)
    {
        foreach ( var_9, var_8 in var_6.links )
        {
            if ( is_in_array( var_2, var_8 ) )
                continue;

            if ( is_in_array( level.closedList, var_8 ) )
                continue;

            if ( isdefined( var_3 ) && var_8.linkDirs[var_6.graphId] != var_3 )
                continue;

            if ( !is_in_array( level.openList, var_8 ) )
            {
                addToOpenList( var_8 );
                var_8.parentNode = var_6;
                var_8.g = getGValue( var_8, var_6 );
                var_8.h = getHValue( var_8, var_0 );
                var_8.f = var_8.g + var_8.h;

                if ( var_8 == var_0 )
                    var_4 = 1;

                continue;
            }

            if ( var_8.g < getGValue( var_6, var_8 ) )
                continue;

            var_8.parentNode = var_6;
            var_8.g = getGValue( var_8, var_6 );
            var_8.f = var_8.g + var_8.h;
        }

        if ( var_4 )
            break;

        addToClosedList( var_6 );
        var_10 = level.openList[0];

        foreach ( var_12 in level.openList )
        {
            if ( var_12.f > var_10.f )
                continue;

            var_10 = var_12;
        }

        addToClosedList( var_10 );
        var_6 = var_10;
    }

    for ( var_6 = var_0; var_6 != var_1; var_6 = var_6.parentNode )
        var_5[var_5.size] = var_6;

    var_5[var_5.size] = var_6;
    return var_5;
}

addToOpenList( var_0 )
{
    var_0.openListID = level.openList.size;
    level.openList[level.openList.size] = var_0;
    var_0.closedListID = undefined;
}

addToClosedList( var_0 )
{
    if ( isdefined( var_0.closedListID ) )
        return;

    var_0.closedListID = level.closedList.size;
    level.closedList[level.closedList.size] = var_0;

    if ( !is_in_array( level.openList, var_0 ) )
        return;

    level.openList[var_0.openListID] = level.openList[level.openList.size - 1];
    level.openList[var_0.openListID].openListID = var_0.openListID;
    level.openList[level.openList.size - 1] = undefined;
    var_0.openListID = undefined;
}

getHValue( var_0, var_1 )
{
    return distance( var_0.node.origin, var_1.node.origin );
}

getGValue( var_0, var_1 )
{
    return var_0.parentNode.g + var_0.linkLengths[var_1.graphId];
}

is_in_array( var_0, var_1 )
{
    for ( var_2 = 0; var_2 < var_0.size; var_2++ )
    {
        if ( var_0[var_2] == var_1 )
            return 1;
    }

    return 0;
}

drawPath( var_0 )
{
    for ( var_1 = 1; var_1 < var_0.size; var_1++ )
    {
        var_2 = var_0[var_1 - 1];
        var_3 = var_0[var_1];

        if ( var_2.linkDirs[var_3.graphId] == "reverse" )
            level thread drawLink( var_2.node.origin, var_3.node.origin, ( 1, 0, 0 ) );
        else
            level thread drawLink( var_2.node.origin, var_3.node.origin, ( 0, 1, 0 ) );

        var_4 = var_2.linkStartNodes[var_3.graphId];
        level thread drawLink( var_2.node.origin + ( 0, 0, 4 ), var_4.origin + ( 0, 0, 4 ), ( 0, 0, 1 ) );

        if ( var_2.linkDirs[var_3.graphId] == "reverse" )
        {
            while ( !isdefined( var_4.graphId ) )
            {
                var_5 = var_4;
                var_4 = var_4.prev;
                level thread drawLink( var_5.origin + ( 0, 0, 4 ), var_4.origin + ( 0, 0, 4 ), ( 0, 1, 1 ) );
            }

            continue;
        }

        while ( !isdefined( var_4.graphId ) )
        {
            var_5 = var_4;

            if ( isdefined( var_4.target ) )
                var_4 = getvehiclenode( var_4.target, "targetname" );
            else
                var_4 = var_4.next;

            level thread drawLink( var_5.origin + ( 0, 0, 4 ), var_4.origin + ( 0, 0, 4 ), ( 0, 1, 1 ) );
        }
    }
}

drawGraph( var_0 )
{

}

drawLink( var_0, var_1, var_2 )
{
    level endon( "endpath" );

    for (;;)
        wait 0.05;
}

debugPrintLn2( var_0 )
{

}

debugprint( var_0 )
{

}

debugPrint3D( var_0, var_1, var_2, var_3, var_4, var_5 )
{

}

drawTankGraphIds()
{

}
