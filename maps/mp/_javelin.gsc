// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

InitJavelinUsage()
{
    self.javelinStage = undefined;
    self.javelinPoints = undefined;
    self.javelinNormals = undefined;
    self.javelinLockMisses = undefined;
    self.javelinTargetPoint = undefined;
    self.javelinTargetNormal = undefined;
    self.javelinLockStartTime = undefined;
}

ResetJavelinLocking()
{
    if ( !isdefined( self.javelinUseEntered ) )
        return;

    self.javelinUseEntered = undefined;
    self notify( "stop_lockon_sound" );
    self weaponlockfree();
    self weaponlocktargettooclose( 0 );
    self weaponlocknoclearance( 0 );
    self.currentlyLocking = 0;
    self.currentlyLocked = 0;
    self.javelinTarget = undefined;
    self stoplocalsound( "javelin_clu_lock" );
    self stoplocalsound( "javelin_clu_aquiring_lock" );
    InitJavelinUsage();
}

EyeTraceForward()
{
    var_0 = self geteye();
    var_1 = self getplayerangles();
    var_2 = anglestoforward( var_1 );
    var_3 = var_0 + var_2 * 15000;
    var_4 = bullettrace( var_0, var_3, 0, undefined );

    if ( var_4["surfacetype"] == "none" )
        return undefined;

    if ( var_4["surfacetype"] == "default" )
        return undefined;

    var_5 = var_4["entity"];

    if ( isdefined( var_5 ) )
    {
        if ( var_5 == level.ac130.planemodel )
            return undefined;
    }

    var_6 = [];
    var_6[0] = var_4["position"];
    var_6[1] = var_4["normal"];
    return var_6;
}

LockMissesReset()
{
    self.javelinLockMisses = undefined;
}

LockMissesIncr()
{
    if ( !isdefined( self.javelinLockMisses ) )
        self.javelinLockMisses = 1;
    else
        self.javelinLockMisses++;
}

LockMissesPassedThreshold()
{
    var_0 = 4;

    if ( isdefined( self.javelinLockMisses ) && self.javelinLockMisses >= var_0 )
        return 1;

    return 0;
}

TargetPointTooClose( var_0 )
{
    var_1 = 1100;
    var_2 = distance( self.origin, var_0 );

    if ( var_2 < var_1 )
        return 1;

    return 0;
}

LoopLocalSeekSound( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "stop_lockon_sound" );

    for (;;)
    {
        self playlocalsound( var_0 );
        wait(var_1);
    }
}

TopAttackPasses( var_0, var_1 )
{
    var_2 = var_0 + var_1 * 10.0;
    var_3 = var_2 + ( 0, 0, 2000 );
    var_4 = bullettrace( var_2, var_3, 0, undefined );

    if ( sighttracepassed( var_2, var_3, 0, undefined ) )
        return 1;

    return 0;
}

JavelinUsageLoop()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    var_0 = 1150;
    var_1 = 25;
    var_2 = 100;
    var_3 = 400;
    var_4 = 12;
    var_5 = 0;
    var_6 = 0;
    self.javelinTarget = undefined;
    InitJavelinUsage();

    for (;;)
    {
        wait 0.05;
        var_7 = 0;

        if ( getdvar( "missileDebugDraw" ) == "1" )
            var_7 = 1;

        var_8 = 0;

        if ( getdvar( "missileDebugText" ) == "1" )
            var_8 = 1;

        var_9 = self getcurrentweapon();

        if ( !issubstr( var_9, "javelin" ) || maps\mp\_utility::isEMPed() )
        {
            ResetJavelinLocking();
            continue;
        }

        if ( self playerads() < 0.95 )
        {
            var_6 = gettime();
            ResetJavelinLocking();
            continue;
        }

        self.javelinUseEntered = 1;

        if ( !isdefined( self.javelinStage ) )
            self.javelinStage = 1;

        if ( self.javelinStage == 1 )
        {
            var_10 = maps\mp\_stinger::GetTargetList();

            if ( var_10.size != 0 )
            {
                var_11 = [];

                foreach ( var_13 in var_10 )
                {
                    var_14 = self worldpointinreticle_circle( var_13.origin, 65, 40 );

                    if ( var_14 )
                        var_11[var_11.size] = var_13;
                }

                if ( var_11.size != 0 )
                {
                    var_16 = sortbydistance( var_11, self.origin );

                    if ( !VehicleLockSightTest( var_16[0] ) )
                        continue;

                    if ( var_8 )
                    {

                    }

                    self.javelinTarget = var_16[0];

                    if ( !isdefined( self.javelinLockStartTime ) )
                        self.javelinLockStartTime = gettime();

                    self.javelinStage = 2;
                    self.javelinLostSightlineTime = 0;
                    javelinLockVehicle( var_0 );
                    self.javelinStage = 1;
                    continue;
                }
            }

            if ( LockMissesPassedThreshold() )
            {
                ResetJavelinLocking();
                continue;
            }

            var_17 = gettime() - var_6;

            if ( var_17 < var_2 )
                continue;

            var_17 = gettime() - var_5;

            if ( var_17 < var_1 )
                continue;

            var_5 = gettime();
            var_21 = EyeTraceForward();

            if ( !isdefined( var_21 ) )
            {
                LockMissesIncr();
                continue;
            }

            if ( TargetPointTooClose( var_21[0] ) )
            {
                self weaponlocktargettooclose( 1 );
                continue;
            }
            else
                self weaponlocktargettooclose( 0 );

            if ( isdefined( self.javelinPoints ) )
            {
                var_22 = averagepoint( self.javelinPoints );
                var_23 = distance( var_22, var_21[0] );

                if ( var_23 > var_3 )
                {
                    LockMissesIncr();
                    continue;
                }
            }
            else
            {
                self.javelinPoints = [];
                self.javelinNormals = [];
            }

            self.javelinPoints[self.javelinPoints.size] = var_21[0];
            self.javelinNormals[self.javelinNormals.size] = var_21[1];
            LockMissesReset();

            if ( self.javelinPoints.size < var_4 )
                continue;

            self.javelinTargetPoint = averagepoint( self.javelinPoints );
            self.javelinTargetNormal = averagenormal( self.javelinNormals );
            self.javelinLockMisses = undefined;
            self.javelinPoints = undefined;
            self.javelinNormals = undefined;
            self.javelinLockStartTime = gettime();
            self weaponlockstart( self.javelinTargetPoint );
            thread LoopLocalSeekSound( "javelin_clu_aquiring_lock", 0.6 );
            self.javelinStage = 2;
        }

        if ( self.javelinStage == 2 )
        {
            var_14 = self worldpointinreticle_circle( self.javelinTargetPoint, 65, 45 );

            if ( !var_14 )
            {
                ResetJavelinLocking();
                continue;
            }

            if ( TargetPointTooClose( self.javelinTargetPoint ) )
                self weaponlocktargettooclose( 1 );
            else
                self weaponlocktargettooclose( 0 );

            var_17 = gettime() - self.javelinLockStartTime;

            if ( var_17 < var_0 )
                continue;

            self weaponlockfinalize( self.javelinTargetPoint, ( 0, 0, 0 ), 1 );
            self notify( "stop_lockon_sound" );
            self playlocalsound( "javelin_clu_lock" );
            self.javelinStage = 3;
        }

        if ( self.javelinStage == 3 )
        {
            var_14 = self worldpointinreticle_circle( self.javelinTargetPoint, 65, 45 );

            if ( !var_14 )
            {
                ResetJavelinLocking();
                continue;
            }

            if ( TargetPointTooClose( self.javelinTargetPoint ) )
                self weaponlocktargettooclose( 1 );
            else
                self weaponlocktargettooclose( 0 );

            continue;
        }
    }
}

DebugSightLine( var_0, var_1, var_2 )
{

}

VehicleLockSightTest( var_0 )
{
    var_1 = self geteye();
    var_2 = var_0 getpointinbounds( 0, 0, 0 );
    var_3 = sighttracepassed( var_1, var_2, 0, var_0 );
    DebugSightLine( var_1, var_2, var_3 );

    if ( var_3 )
        return 1;

    var_4 = var_0 getpointinbounds( 1, 0, 0 );
    var_3 = sighttracepassed( var_1, var_4, 0, var_0 );
    DebugSightLine( var_1, var_4, var_3 );

    if ( var_3 )
        return 1;

    var_5 = var_0 getpointinbounds( -1, 0, 0 );
    var_3 = sighttracepassed( var_1, var_5, 0, var_0 );
    DebugSightLine( var_1, var_5, var_3 );

    if ( var_3 )
        return 1;

    return 0;
}

javelinLockVehicle( var_0 )
{
    if ( self.javelinStage == 2 )
    {
        self weaponlockstart( self.javelinTarget );

        if ( !StillValidJavelinLock( self.javelinTarget ) )
        {
            ResetJavelinLocking();
            self.javelinLockStartTime = undefined;
            return;
        }

        var_1 = SoftSightTest();

        if ( !var_1 )
        {
            self.javelinLockStartTime = undefined;
            return;
        }

        if ( !isdefined( self.currentlyLocking ) || !self.currentlyLocking )
        {
            thread LoopLocalSeekSound( "javelin_clu_aquiring_lock", 0.6 );
            self.currentlyLocking = 1;
        }

        var_2 = gettime() - self.javelinLockStartTime;

        if ( maps\mp\_utility::_hasPerk( "specialty_fasterlockon" ) )
        {
            if ( var_2 < var_0 * 0.5 )
                return;
        }
        else if ( var_2 < var_0 )
            return;

        if ( isplayer( self.javelinTarget ) )
            self weaponlockfinalize( self.javelinTarget, ( 0, 0, 64 ), 0 );
        else
            self weaponlockfinalize( self.javelinTarget, ( 0, 0, 0 ), 0 );

        self notify( "stop_lockon_sound" );

        if ( !isdefined( self.currentlyLocked ) || !self.currentlyLocked )
        {
            self playlocalsound( "javelin_clu_lock" );
            self.currentlyLocked = 1;
        }

        self.javelinStage = 3;
    }

    if ( self.javelinStage == 3 )
    {
        var_1 = SoftSightTest();

        if ( !var_1 )
            return;

        if ( !StillValidJavelinLock( self.javelinTarget ) )
        {
            ResetJavelinLocking();
            return;
        }
    }
}

StillValidJavelinLock( var_0 )
{
    if ( !isdefined( var_0 ) )
        return 0;

    if ( !self worldpointinreticle_circle( var_0.origin, 65, 85 ) )
        return 0;

    return 1;
}

SoftSightTest()
{
    var_0 = 500;

    if ( VehicleLockSightTest( self.javelinTarget ) )
    {
        self.javelinLostSightlineTime = 0;
        return 1;
    }

    if ( self.javelinLostSightlineTime == 0 )
        self.javelinLostSightlineTime = gettime();

    var_1 = gettime() - self.javelinLostSightlineTime;

    if ( var_1 >= var_0 )
    {
        ResetJavelinLocking();
        return 0;
    }

    return 1;
}
