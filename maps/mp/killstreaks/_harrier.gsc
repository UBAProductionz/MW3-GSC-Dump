// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

beginHarrier( var_0, var_1, var_2 )
{
    var_3 = getent( "airstrikeheight", "targetname" );

    if ( isdefined( var_3 ) )
        var_4 = var_3.origin[2];
    else if ( isdefined( level.airstrikeHeightScale ) )
        var_4 = 850 * level.airstrikeHeightScale;
    else
        var_4 = 850;

    var_2 *= ( 1, 1, 0 );
    var_5 = var_2 + ( 0, 0, var_4 );
    var_6 = spawnDefensiveHarrier( var_0, self, var_1, var_5 );
    var_6.pathGoal = var_5;
    return var_6;
}

getCorrectHeight( var_0, var_1, var_2 )
{
    var_3 = 1200;
    var_4 = traceGroundPoint( var_0, var_1 );
    var_5 = var_4 + var_3;

    if ( isdefined( level.airstrikeHeightScale ) && var_5 < 850 * level.airstrikeHeightScale )
        var_5 = 950 * level.airstrikeHeightScale;

    var_5 += randomint( var_2 );
    return var_5;
}

spawnDefensiveHarrier( var_0, var_1, var_2, var_3 )
{
    var_4 = vectortoangles( var_3 - var_2 );

    if ( var_1.team == "allies" )
        var_5 = spawnhelicopter( var_1, var_2, var_4, "harrier_mp", "vehicle_av8b_harrier_jet_mp" );
    else
        var_5 = spawnhelicopter( var_1, var_2, var_4, "harrier_mp", "vehicle_av8b_harrier_jet_opfor_mp" );

    if ( !isdefined( var_5 ) )
        return;

    var_5 addToHeliList();
    var_5 thread removeFromHeliListOnDeath();
    var_5.speed = 250;
    var_5.accel = 175;
    var_5.health = 3000;
    var_5.maxHealth = var_5.health;
    var_5.team = var_1.team;
    var_5.owner = var_1;
    var_5 setcandamage( 1 );
    var_5.owner = var_1;
    var_5 thread harrierDestroyed();
    var_5 setmaxpitchroll( 0, 90 );
    var_5 vehicle_setspeed( var_5.speed, var_5.accel );
    var_5 thread playHarrierFx();
    var_5 setdamagestate( 3 );
    var_5.missiles = 6;
    var_5.pers["team"] = var_5.team;
    var_5 sethoverparams( 50, 100, 50 );
    var_5 setturningability( 0.05 );
    var_5 setyawspeed( 45, 25, 25, 0.5 );
    var_5.defendLoc = var_3;
    var_5.lifeId = var_0;
    var_5.damageCallback = ::Callback_VehicleDamage;
    level.harriers = common_scripts\utility::array_removeUndefined( level.harriers );
    level.harriers[level.harriers.size] = var_5;
    return var_5;
}

defendLocation( var_0 )
{
    var_0 endon( "death" );
    var_0 thread harrierTimer();
    var_0 setvehgoalpos( var_0.pathGoal, 1 );
    var_0 thread closeToGoalCheck( var_0.pathGoal );
    var_0 waittill( "goal" );
    var_0 stopHarrierWingFx();
    var_0 engageGround();
}

closeToGoalCheck( var_0 )
{
    self endon( "goal" );
    self endon( "death" );

    for (;;)
    {
        if ( distance2d( self.origin, var_0 ) < 768 )
        {
            self setmaxpitchroll( 45, 25 );
            break;
        }

        wait 0.05;
    }
}

engageGround()
{
    self notify( "engageGround" );
    self endon( "engageGround" );
    self endon( "death" );
    thread harrierGetTargets();
    thread randomHarrierMovement();
    var_0 = self.defendLoc;
    self vehicle_setspeed( 15, 5 );
    self setvehgoalpos( var_0, 1 );
    self waittill( "goal" );
}

harrierLeave()
{
    self endon( "death" );
    self setmaxpitchroll( 0, 0 );
    self notify( "leaving" );
    breakTarget( 1 );
    self notify( "stopRand" );

    for (;;)
    {
        self vehicle_setspeed( 35, 25 );
        var_0 = self.origin + anglestoforward( ( 0, randomint( 360 ), 0 ) ) * 500;
        var_0 += ( 0, 0, 900 );
        var_1 = bullettrace( self.origin, self.origin + ( 0, 0, 900 ), 0, self );

        if ( var_1["surfacetype"] == "none" )
            break;

        wait 0.1;
    }

    self setvehgoalpos( var_0, 1 );
    thread startHarrierWingFx();
    self waittill( "goal" );
    self playsound( "harrier_fly_away" );
    var_2 = getPathEnd();
    self vehicle_setspeed( 250, 75 );
    self setvehgoalpos( var_2, 1 );
    self waittill( "goal" );
    level.airPlane[level.airPlane.size - 1] = undefined;
    self notify( "harrier_gone" );
    thread harrierDelete();
}

harrierDelete()
{
    self delete();
}

harrierTimer()
{
    self endon( "death" );
    maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( 45 );
    harrierLeave();
}

randomHarrierMovement()
{
    self notify( "randomHarrierMovement" );
    self endon( "randomHarrierMovement" );
    self endon( "stopRand" );
    self endon( "death" );
    self endon( "acquiringTarget" );
    self endon( "leaving" );
    var_0 = self.defendLoc;

    for (;;)
    {
        var_1 = getNewPoint( self.origin );
        self setvehgoalpos( var_1, 1 );
        self waittill( "goal" );
        wait(randomintrange( 3, 6 ));
        self notify( "randMove" );
    }
}

getNewPoint( var_0, var_1 )
{
    self endon( "stopRand" );
    self endon( "death" );
    self endon( "acquiringTarget" );
    self endon( "leaving" );

    if ( !isdefined( var_1 ) )
    {
        var_2 = [];

        foreach ( var_4 in level.players )
        {
            if ( var_4 == self )
                continue;

            if ( !level.teamBased || var_4.team != self.team )
                var_2[var_2.size] = var_4.origin;
        }

        if ( var_2.size > 0 )
        {
            var_6 = averagepoint( var_2 );
            var_7 = var_6[0];
            var_8 = var_6[1];
        }
        else
        {
            var_9 = level.mapCenter;
            var_10 = level.mapSize / 6 - 200;
            var_7 = randomfloatrange( var_9[0] - var_10, var_9[0] + var_10 );
            var_8 = randomfloatrange( var_9[1] - var_10, var_9[1] + var_10 );
        }

        var_11 = getCorrectHeight( var_7, var_8, 20 );
    }
    else if ( common_scripts\utility::cointoss() )
    {
        var_12 = self.origin - self.bestTarget.origin;
        var_7 = var_12[0];
        var_8 = var_12[1] * -1;
        var_11 = getCorrectHeight( var_7, var_8, 20 );
        var_13 = ( var_8, var_7, var_11 );

        if ( distance2d( self.origin, var_13 ) > 1200 )
        {
            var_8 *= 0.5;
            var_7 *= 0.5;
            var_13 = ( var_8, var_7, var_11 );
        }
    }
    else
    {
        if ( distance2d( self.origin, self.bestTarget.origin ) < 200 )
            return;

        var_14 = self.angles[1];
        var_15 = ( 0, var_14, 0 );
        var_16 = self.origin + anglestoforward( var_15 ) * randomintrange( 200, 400 );
        var_11 = getCorrectHeight( var_16[0], var_16[1], 20 );
        var_7 = var_16[0];
        var_8 = var_16[1];
    }

    for (;;)
    {
        var_17 = traceNewPoint( var_7, var_8, var_11 );

        if ( var_17 != 0 )
            return var_17;

        var_7 = randomfloatrange( var_0[0] - 1200, var_0[0] + 1200 );
        var_8 = randomfloatrange( var_0[1] - 1200, var_0[1] + 1200 );
        var_11 = getCorrectHeight( var_7, var_8, 20 );
    }
}

traceNewPoint( var_0, var_1, var_2 )
{
    self endon( "stopRand" );
    self endon( "death" );
    self endon( "acquiringTarget" );
    self endon( "leaving" );
    self endon( "randMove" );

    for ( var_3 = 1; var_3 <= 10; var_3++ )
    {
        switch ( var_3 )
        {
            case 1:
                var_4 = bullettrace( self.origin, ( var_0, var_1, var_2 ), 0, self );
                break;
            case 2:
                var_4 = bullettrace( self gettagorigin( "tag_left_wingtip" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 3:
                var_4 = bullettrace( self gettagorigin( "tag_right_wingtip" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 4:
                var_4 = bullettrace( self gettagorigin( "tag_engine_left2" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 5:
                var_4 = bullettrace( self gettagorigin( "tag_engine_right2" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 6:
                var_4 = bullettrace( self gettagorigin( "tag_right_alamo_missile" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 7:
                var_4 = bullettrace( self gettagorigin( "tag_left_alamo_missile" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 8:
                var_4 = bullettrace( self gettagorigin( "tag_right_archer_missile" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 9:
                var_4 = bullettrace( self gettagorigin( "tag_left_archer_missile" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            case 10:
                var_4 = bullettrace( self gettagorigin( "tag_light_tail" ), ( var_0, var_1, var_2 ), 0, self );
                break;
            default:
                var_4 = bullettrace( self.origin, ( var_0, var_1, var_2 ), 0, self );
        }

        if ( var_4["surfacetype"] != "none" )
            return 0;

        wait 0.05;
    }

    var_5 = ( var_0, var_1, var_2 );
    return var_5;
}

traceGroundPoint( var_0, var_1 )
{
    self endon( "death" );
    self endon( "acquiringTarget" );
    self endon( "leaving" );
    var_2 = -9999999;
    var_3 = 9999999;
    var_4 = -9999999;
    var_5 = self.origin[2];
    var_6 = undefined;
    var_7 = undefined;

    for ( var_8 = 1; var_8 <= 5; var_8++ )
    {
        switch ( var_8 )
        {
            case 1:
                var_9 = bullettrace( ( var_0, var_1, var_5 ), ( var_0, var_1, var_4 ), 0, self );
                break;
            case 2:
                var_9 = bullettrace( ( var_0 + 20, var_1 + 20, var_5 ), ( var_0 + 20, var_1 + 20, var_4 ), 0, self );
                break;
            case 3:
                var_9 = bullettrace( ( var_0 - 20, var_1 - 20, var_5 ), ( var_0 - 20, var_1 - 20, var_4 ), 0, self );
                break;
            case 4:
                var_9 = bullettrace( ( var_0 + 20, var_1 - 20, var_5 ), ( var_0 + 20, var_1 - 20, var_4 ), 0, self );
                break;
            case 5:
                var_9 = bullettrace( ( var_0 - 20, var_1 + 20, var_5 ), ( var_0 - 20, var_1 + 20, var_4 ), 0, self );
                break;
            default:
                var_9 = bullettrace( self.origin, ( var_0, var_1, var_4 ), 0, self );
        }

        if ( var_9["position"][2] > var_2 )
        {
            var_2 = var_9["position"][2];
            var_6 = var_9;
        }
        else if ( var_9["position"][2] < var_3 )
        {
            var_3 = var_9["position"][2];
            var_7 = var_9;
        }

        wait 0.05;
    }

    return var_2;
}

playHarrierFx()
{
    self endon( "death" );
    wait 0.2;
    playfxontag( level.fx_airstrike_contrail, self, "tag_right_wingtip" );
    playfxontag( level.fx_airstrike_contrail, self, "tag_left_wingtip" );
    wait 0.2;
    playfxontag( level.harrier_afterburnerfx, self, "tag_engine_right" );
    playfxontag( level.harrier_afterburnerfx, self, "tag_engine_left" );
    wait 0.2;
    playfxontag( level.harrier_afterburnerfx, self, "tag_engine_right2" );
    playfxontag( level.harrier_afterburnerfx, self, "tag_engine_left2" );
    wait 0.2;
    playfxontag( level.chopper_fx["light"]["left"], self, "tag_light_L_wing" );
    wait 0.2;
    playfxontag( level.chopper_fx["light"]["right"], self, "tag_light_R_wing" );
    wait 0.2;
    playfxontag( level.chopper_fx["light"]["belly"], self, "tag_light_belly" );
    wait 0.2;
    playfxontag( level.chopper_fx["light"]["tail"], self, "tag_light_tail" );
}

stopHarrierWingFx()
{
    stopfxontag( level.fx_airstrike_contrail, self, "tag_right_wingtip" );
    stopfxontag( level.fx_airstrike_contrail, self, "tag_left_wingtip" );
}

startHarrierWingFx()
{
    wait 3.0;

    if ( !isdefined( self ) )
        return;

    playfxontag( level.fx_airstrike_contrail, self, "tag_right_wingtip" );
    playfxontag( level.fx_airstrike_contrail, self, "tag_left_wingtip" );
}

getPathStart( var_0 )
{
    var_1 = 100;
    var_2 = 15000;
    var_3 = 850;
    var_4 = randomfloat( 360 );
    var_5 = ( 0, var_4, 0 );
    var_6 = var_0 + anglestoforward( var_5 ) * ( -1 * var_2 );
    var_6 += ( ( randomfloat( 2 ) - 1 ) * var_1, ( randomfloat( 2 ) - 1 ) * var_1, 0 );
    return var_6;
}

getPathEnd()
{
    var_0 = 150;
    var_1 = 15000;
    var_2 = 850;
    var_3 = self.angles[1];
    var_4 = ( 0, var_3, 0 );
    var_5 = self.origin + anglestoforward( var_4 ) * var_1;
    return var_5;
}

fireOnTarget( var_0, var_1 )
{
    self endon( "leaving" );
    self endon( "stopfiring" );
    self endon( "explode" );
    self endon( "death" );
    self.bestTarget endon( "death" );
    self.bestTarget endon( "disconnect" );
    var_2 = gettime();
    var_3 = gettime();
    var_4 = 0;
    self setvehweapon( "harrier_20mm_mp" );

    if ( !isdefined( var_1 ) )
        var_1 = 50;

    for (;;)
    {
        if ( isReadyToFire( var_0 ) )
        {
            break;
            continue;
        }

        wait 0.25;
    }

    self setturrettargetent( self.bestTarget, ( 0, 0, 50 ) );
    var_5 = 25;

    for (;;)
    {
        if ( var_5 == 25 )
            self playloopsound( "weap_cobra_20mm_fire_npc" );

        var_5--;
        self fireweapon( "tag_flash", self.bestTarget, ( 0, 0, 0 ), 0.05 );
        wait 0.1;

        if ( var_5 <= 0 )
        {
            self stoploopsound();
            wait 1;
            var_5 = 25;
        }
    }
}

isReadyToFire( var_0 )
{
    self endon( "death" );
    self endon( "leaving" );

    if ( !isdefined( var_0 ) )
        var_0 = 10;

    var_1 = anglestoforward( self.angles );
    var_2 = self.bestTarget.origin - self.origin;
    var_1 *= ( 1, 1, 0 );
    var_2 *= ( 1, 1, 0 );
    var_2 = vectornormalize( var_2 );
    var_1 = vectornormalize( var_1 );
    var_3 = vectordot( var_2, var_1 );
    var_4 = cos( var_0 );

    if ( var_3 >= var_4 )
        return 1;
    else
        return 0;
}

acquireGroundTarget( var_0 )
{
    self endon( "death" );
    self endon( "leaving" );

    if ( var_0.size == 1 )
        self.bestTarget = var_0[0];
    else
        self.bestTarget = getBestTarget( var_0 );

    backToDefendLocation( 0 );
    self notify( "acquiringTarget" );
    self setturrettargetent( self.bestTarget );
    self setlookatent( self.bestTarget );
    var_1 = getNewPoint( self.origin, 1 );
    self setvehgoalpos( var_1, 1 );
    thread watchTargetDeath();
    thread watchTargetLOS();
    self setvehweapon( "harrier_20mm_mp" );
    thread fireOnTarget();
}

backToDefendLocation( var_0 )
{
    self setvehgoalpos( self.defendLoc, 1 );

    if ( isdefined( var_0 ) && var_0 )
        self waittill( "goal" );
}

wouldCollide( var_0 )
{
    var_1 = bullettrace( self.origin, var_0, 1, self );

    if ( var_1["position"] == var_0 )
        return 0;
    else
        return 1;
}

watchTargetDeath()
{
    self notify( "watchTargetDeath" );
    self endon( "watchTargetDeath" );
    self endon( "newTarget" );
    self endon( "death" );
    self endon( "leaving" );
    self.bestTarget waittill( "death" );
    thread breakTarget();
}

watchTargetLOS( var_0 )
{
    self endon( "death" );
    self.bestTarget endon( "death" );
    self.bestTarget endon( "disconnect" );
    self endon( "leaving" );
    self endon( "newTarget" );
    var_1 = undefined;

    if ( !isdefined( var_0 ) )
        var_0 = 1000;

    for (;;)
    {
        if ( !isTarget( self.bestTarget ) )
        {
            thread breakTarget();
            return;
        }

        if ( !isdefined( self.bestTarget ) )
        {
            thread breakTarget();
            return;
        }

        if ( self.bestTarget sightconetrace( self.origin, self ) < 1 )
        {
            if ( !isdefined( var_1 ) )
                var_1 = gettime();

            if ( gettime() - var_1 > var_0 )
            {
                thread breakTarget();
                return;
            }
        }
        else
            var_1 = undefined;

        wait 0.25;
    }
}

breakTarget( var_0 )
{
    self endon( "death" );
    self clearlookatent();
    self stoploopsound();
    self notify( "stopfiring" );

    if ( isdefined( var_0 ) && var_0 )
        return;

    thread randomHarrierMovement();
    self notify( "newTarget" );
    thread harrierGetTargets();
}

harrierGetTargets()
{
    self notify( "harrierGetTargets" );
    self endon( "harrierGetTargets" );
    self endon( "death" );
    self endon( "leaving" );
    var_0 = [];

    for (;;)
    {
        var_0 = [];
        var_1 = level.players;

        if ( isdefined( level.chopper ) && level.chopper.team != self.team && isalive( level.chopper ) )
        {
            if ( !isdefined( level.chopper.nonTarget ) || isdefined( level.chopper.nonTarget ) && !level.chopper.nonTarget )
            {
                thread engageVehicle( level.chopper );
                return;
            }
            else
                backToDefendLocation( 1 );
        }

        for ( var_2 = 0; var_2 < var_1.size; var_2++ )
        {
            var_3 = var_1[var_2];

            if ( isTarget( var_3 ) )
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
            acquireGroundTarget( var_0 );
            return;
        }

        wait 1;
    }
}

isTarget( var_0 )
{
    self endon( "death" );

    if ( !isalive( var_0 ) || var_0.sessionstate != "playing" )
        return 0;

    if ( isdefined( self.owner ) && var_0 == self.owner )
        return 0;

    if ( distance( var_0.origin, self.origin ) > 8192 )
        return 0;

    if ( distance2d( var_0.origin, self.origin ) < 768 )
        return 0;

    if ( !isdefined( var_0.pers["team"] ) )
        return 0;

    if ( level.teamBased && var_0.pers["team"] == self.team )
        return 0;

    if ( var_0.pers["team"] == "spectator" )
        return 0;

    if ( isdefined( var_0.spawnTime ) && ( gettime() - var_0.spawnTime ) / 1000 <= 5 )
        return 0;

    if ( var_0 maps\mp\_utility::_hasPerk( "specialty_blindeye" ) )
        return 0;

    var_1 = self.origin + ( 0, 0, -160 );
    var_2 = anglestoforward( self.angles );
    var_3 = var_1 + 144 * var_2;
    var_4 = var_0 sightconetrace( self.origin, self );

    if ( var_4 < 1 )
        return 0;

    return 1;
}

getBestTarget( var_0 )
{
    self endon( "death" );
    var_1 = self gettagorigin( "tag_flash" );
    var_2 = self.origin;
    var_3 = anglestoforward( self.angles );
    var_4 = undefined;
    var_5 = undefined;
    var_6 = 0;

    foreach ( var_8 in var_0 )
    {
        var_9 = abs( vectortoangles( var_8.origin - self.origin )[1] );
        var_10 = abs( self gettagangles( "tag_flash" )[1] );
        var_9 = abs( var_9 - var_10 );
        var_11 = var_8 getweaponslistitems();

        foreach ( var_13 in var_11 )
        {
            if ( issubstr( var_13, "at4" ) || issubstr( var_13, "stinger" ) || issubstr( var_13, "jav" ) )
                var_9 -= 40;
        }

        if ( distance( self.origin, var_8.origin ) > 2000 )
            var_9 += 40;

        if ( !isdefined( var_4 ) )
        {
            var_4 = var_9;
            var_5 = var_8;
            continue;
        }

        if ( var_4 > var_9 )
        {
            var_4 = var_9;
            var_5 = var_8;
        }
    }

    return var_5;
}

fireMissile( var_0 )
{
    self endon( "death" );
    self endon( "leaving" );

    if ( self.missiles <= 0 )
        return;

    var_1 = checkForFriendlies( var_0, 256 );

    if ( !isdefined( var_0 ) )
        return;

    if ( distance2d( self.origin, var_0.origin ) < 512 )
        return;

    if ( isdefined( var_1 ) && var_1 )
        return;

    self.missiles--;
    self setvehweapon( "harrier_FFAR_mp" );

    if ( isdefined( var_0.targetEnt ) )
        var_2 = self fireweapon( "tag_flash", var_0.targetEnt, ( 0, 0, -250 ) );
    else
        var_2 = self fireweapon( "tag_flash", var_0, ( 0, 0, -250 ) );

    var_2 missile_setflightmodedirect();
    var_2 missile_settargetent( var_0 );
}

checkForFriendlies( var_0, var_1 )
{
    self endon( "death" );
    self endon( "leaving" );
    var_2 = [];
    var_3 = level.players;
    var_4 = var_0.origin;

    for ( var_5 = 0; var_5 < var_3.size; var_5++ )
    {
        var_6 = var_3[var_5];

        if ( var_6.team != self.team )
            continue;

        var_7 = var_6.origin;

        if ( distance2d( var_7, var_4 ) < 512 )
            return 1;
    }

    return 0;
}

Callback_VehicleDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 )
{
    if ( ( var_1 == self || isdefined( var_1.pers ) && var_1.pers["team"] == self.team && level.teamBased ) && var_1 != self.owner )
        return;

    if ( self.health <= 0 )
        return;

    switch ( var_5 )
    {
        case "ac130_105mm_mp":
        case "ac130_40mm_mp":
        case "remotemissile_projectile_mp":
        case "stinger_mp":
        case "javelin_mp":
            self.largeProjectileDamage = 1;
            var_2 = self.maxHealth + 1;
            break;
        case "at4_mp":
        case "rpg_mp":
            self.largeProjectileDamage = 1;
            var_2 = self.maxHealth - 900;
            break;
        default:
            if ( var_5 != "none" )
                var_2 = int( var_2 / 2 );

            self.largeProjectileDamage = 0;
            break;
    }

    maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_5, self );
    var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "" );

    if ( isplayer( var_1 ) && var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
    {
        var_12 = int( var_2 * level.armorPiercingMod );
        var_2 += var_12;
    }

    if ( self.health <= var_2 )
    {
        if ( isplayer( var_1 ) && ( !isdefined( self.owner ) || var_1 != self.owner ) )
        {
            thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_harrier", var_1 );
            var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 300, var_5, var_4 );
            thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, var_1, var_2, var_4, var_5 );
            var_1 notify( "destroyed_killstreak" );
        }

        self notify( "death" );
    }

    if ( self.health - var_2 <= 900 && ( !isdefined( self.smoking ) || !self.smoking ) )
    {
        thread playDamageEfx();
        self.smoking = 1;
    }

    self vehicle_finishdamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_11 );
}

playDamageEfx()
{
    self endon( "death" );
    stopfxontag( level.harrier_afterburnerfx, self, "tag_engine_left" );
    playfxontag( level.harrier_smoke, self, "tag_engine_left" );
    stopfxontag( level.harrier_afterburnerfx, self, "tag_engine_right" );
    playfxontag( level.harrier_smoke, self, "tag_engine_right" );
    wait 0.15;
    stopfxontag( level.harrier_afterburnerfx, self, "tag_engine_left2" );
    playfxontag( level.harrier_smoke, self, "tag_engine_left2" );
    stopfxontag( level.harrier_afterburnerfx, self, "tag_engine_right2" );
    playfxontag( level.harrier_smoke, self, "tag_engine_right2" );
    playfxontag( level.chopper_fx["damage"]["heavy_smoke"], self, "tag_engine_left" );
}

harrierDestroyed()
{
    self endon( "harrier_gone" );
    self waittill( "death" );

    if ( !isdefined( self ) )
        return;

    if ( !isdefined( self.largeProjectileDamage ) )
    {
        self vehicle_setspeed( 25, 5 );
        thread harrierSpin( randomintrange( 180, 220 ) );
        wait(randomfloatrange( 0.5, 1.5 ));
    }

    harrierExplode();
}

harrierExplode()
{
    self playsound( "harrier_jet_crash" );
    level.airPlane[level.airPlane.size - 1] = undefined;
    var_0 = self gettagangles( "tag_deathfx" );
    playfx( level.harrier_deathfx, self gettagorigin( "tag_deathfx" ), anglestoforward( var_0 ), anglestoup( var_0 ) );
    self notify( "explode" );
    wait 0.05;
    thread harrierDelete();
}

harrierSpin( var_0 )
{
    self endon( "explode" );
    playfxontag( level.chopper_fx["explode"]["medium"], self, "tag_origin" );
    self setyawspeed( var_0, var_0, var_0 );

    while ( isdefined( self ) )
    {
        self settargetyaw( self.angles[1] + var_0 * 0.9 );
        wait 1;
    }
}

engageVehicle( var_0 )
{
    var_0 endon( "death" );
    var_0 endon( "leaving" );
    var_0 endon( "crashing" );
    self endon( "death" );
    acquireVehicleTarget( var_0 );
    thread fireOnVehicleTarget();
}

fireOnVehicleTarget()
{
    self endon( "leaving" );
    self endon( "stopfiring" );
    self endon( "explode" );
    self.bestTarget endon( "crashing" );
    self.bestTarget endon( "leaving" );
    self.bestTarget endon( "death" );
    var_0 = gettime();

    if ( isdefined( self.bestTarget ) && self.bestTarget.classname == "script_vehicle" )
    {
        self setturrettargetent( self.bestTarget );

        for (;;)
        {
            var_1 = distance2d( self.origin, self.bestTarget.origin );

            if ( gettime() - var_0 > 2500 && var_1 > 1000 )
            {
                fireMissile( self.bestTarget );
                var_0 = gettime();
            }

            wait 0.1;
        }
    }
}

acquireVehicleTarget( var_0 )
{
    self endon( "death" );
    self endon( "leaving" );
    self notify( "newTarget" );
    self.bestTarget = var_0;
    self notify( "acquiringVehTarget" );
    self setlookatent( self.bestTarget );
    thread watchVehTargetDeath();
    thread watchVehTargetCrash();
    self setturrettargetent( self.bestTarget );
}

watchVehTargetCrash()
{
    self endon( "death" );
    self endon( "leaving" );
    self.bestTarget endon( "death" );
    self.bestTarget endon( "drop_crate" );
    self.bestTarget waittill( "crashing" );
    breakVehTarget();
}

watchVehTargetDeath()
{
    self endon( "death" );
    self endon( "leaving" );
    self.bestTarget endon( "crashing" );
    self.bestTarget endon( "drop_crate" );
    self.bestTarget waittill( "death" );
    breakVehTarget();
}

breakVehTarget()
{
    self clearlookatent();

    if ( isdefined( self.bestTarget ) && !isdefined( self.bestTarget.nonTarget ) )
        self.bestTarget.nonTarget = 1;

    self notify( "stopfiring" );
    self notify( "newTarget" );
    thread stopHarrierWingFx();
    thread engageGround();
}

evasiveManuverOne()
{
    self setmaxpitchroll( 15, 80 );
    self vehicle_setspeed( 50, 100 );
    self setyawspeed( 90, 30, 30, 0.5 );
    var_0 = self.origin;
    var_1 = self.angles[1];

    if ( common_scripts\utility::cointoss() )
        var_2 = ( 0, var_1 + 90, 0 );
    else
        var_2 = ( 0, var_1 - 90, 0 );

    var_3 = self.origin + anglestoforward( var_2 ) * 500;
    self setvehgoalpos( var_3, 1 );
    self waittill( "goal" );
}

drawLine( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( var_3 ) )
        var_3 = ( 1, 1, 1 );

    var_4 = int( var_2 * 20 );

    for ( var_5 = 0; var_5 < var_4; var_5++ )
        wait 0.05;
}

addToHeliList()
{
    level.helis[self getentitynumber()] = self;
}

removeFromHeliListOnDeath()
{
    var_0 = self getentitynumber();
    self waittill( "death" );
    level.helis[var_0] = undefined;
}
