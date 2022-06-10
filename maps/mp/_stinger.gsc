// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

InitStingerUsage()
{
    self.stingerStage = undefined;
    self.stingerTarget = undefined;
    self.stingerLockStartTime = undefined;
    self.stingerLostSightlineTime = undefined;
    thread ResetStingerLockingOnDeath();
    level.stingerTargets = [];
}

ResetStingerLocking()
{
    if ( !isdefined( self.stingerUseEntered ) )
        return;

    self.stingerUseEntered = undefined;
    self notify( "stop_javelin_locking_feedback" );
    self notify( "stop_javelin_locked_feedback" );
    self weaponlockfree();
    InitStingerUsage();
}

ResetStingerLockingOnDeath()
{
    self endon( "disconnect" );
    self notify( "ResetStingerLockingOnDeath" );
    self endon( "ResetStingerLockingOnDeath" );

    for (;;)
    {
        self waittill( "death" );
        ResetStingerLocking();
    }
}

StillValidStingerLock( var_0 )
{
    if ( !isdefined( var_0 ) )
        return 0;

    if ( !self worldpointinreticle_circle( var_0.origin, 65, 85 ) )
        return 0;

    if ( self.stingerTarget == level.ac130.planemodel && !isdefined( level.ac130player ) )
        return 0;

    return 1;
}

LoopStingerLockingFeedback()
{
    self endon( "stop_javelin_locking_feedback" );

    for (;;)
    {
        if ( isdefined( level.chopper ) && isdefined( level.chopper.gunner ) && isdefined( self.stingerTarget ) && self.stingerTarget == level.chopper.gunner )
            level.chopper.gunner playlocalsound( "missile_locking" );

        if ( isdefined( level.ac130player ) && isdefined( self.stingerTarget ) && self.stingerTarget == level.ac130.planemodel )
            level.ac130player playlocalsound( "missile_locking" );

        self playlocalsound( "stinger_locking" );
        self playrumbleonentity( "ac130_25mm_fire" );
        wait 0.6;
    }
}

LoopStingerLockedFeedback()
{
    self endon( "stop_javelin_locked_feedback" );

    for (;;)
    {
        if ( isdefined( level.chopper ) && isdefined( level.chopper.gunner ) && isdefined( self.stingerTarget ) && self.stingerTarget == level.chopper.gunner )
            level.chopper.gunner playlocalsound( "missile_locking" );

        if ( isdefined( level.ac130player ) && isdefined( self.stingerTarget ) && self.stingerTarget == level.ac130.planemodel )
            level.ac130player playlocalsound( "missile_locking" );

        self playlocalsound( "stinger_locked" );
        self playrumbleonentity( "ac130_25mm_fire" );
        wait 0.25;
    }
}

LockSightTest( var_0 )
{
    var_1 = self geteye();

    if ( !isdefined( var_0 ) )
        return 0;

    var_2 = sighttracepassed( var_1, var_0.origin, 0, var_0 );

    if ( var_2 )
        return 1;

    var_3 = var_0 getpointinbounds( 1, 0, 0 );
    var_2 = sighttracepassed( var_1, var_3, 0, var_0 );

    if ( var_2 )
        return 1;

    var_4 = var_0 getpointinbounds( -1, 0, 0 );
    var_2 = sighttracepassed( var_1, var_4, 0, var_0 );

    if ( var_2 )
        return 1;

    return 0;
}

StingerDebugDraw( var_0 )
{

}

SoftSightTest()
{
    var_0 = 500;

    if ( LockSightTest( self.stingerTarget ) )
    {
        self.stingerLostSightlineTime = 0;
        return 1;
    }

    if ( self.stingerLostSightlineTime == 0 )
        self.stingerLostSightlineTime = gettime();

    var_1 = gettime() - self.stingerLostSightlineTime;

    if ( var_1 >= var_0 )
    {
        ResetStingerLocking();
        return 0;
    }

    return 1;
}

GetTargetList()
{
    var_0 = [];

    if ( level.teamBased )
    {
        if ( isdefined( level.chopper ) && ( level.chopper.team != self.team || isdefined( level.chopper.owner ) && level.chopper.owner == self ) )
            var_0[var_0.size] = level.chopper;

        if ( isdefined( level.ac130player ) && level.ac130player.team != self.team )
            var_0[var_0.size] = level.ac130.planemodel;

        if ( isdefined( level.harriers ) )
        {
            foreach ( var_2 in level.harriers )
            {
                if ( isdefined( var_2 ) && ( var_2.team != self.team || isdefined( var_2.owner ) && var_2.owner == self ) )
                    var_0[var_0.size] = var_2;
            }
        }

        if ( level.uavmodels[level.otherTeam[self.team]].size )
        {
            foreach ( var_5 in level.uavmodels[level.otherTeam[self.team]] )
                var_0[var_0.size] = var_5;
        }

        if ( isdefined( level.littleBirds ) )
        {
            foreach ( var_8 in level.littleBirds )
            {
                if ( isdefined( var_8 ) && ( var_8.team != self.team || isdefined( var_8.owner ) && var_8.owner == self ) )
                    var_0[var_0.size] = var_8;
            }
        }

        if ( isdefined( level.ugvs ) )
        {
            foreach ( var_11 in level.ugvs )
            {
                if ( isdefined( var_11 ) && ( var_11.team != self.team || isdefined( var_11.owner ) && var_11.owner == self ) )
                    var_0[var_0.size] = var_11;
            }
        }
    }
    else
    {
        if ( isdefined( level.chopper ) )
            var_0[var_0.size] = level.chopper;

        if ( isdefined( level.ac130player ) )
            var_0[var_0.size] = level.ac130.planemodel;

        if ( isdefined( level.harriers ) )
        {
            foreach ( var_2 in level.harriers )
            {
                if ( isdefined( var_2 ) )
                    var_0[var_0.size] = var_2;
            }
        }

        if ( level.uavmodels.size )
        {
            foreach ( var_16, var_5 in level.uavmodels )
            {
                if ( isdefined( var_5.owner ) && var_5.owner == self )
                    continue;

                var_0[var_0.size] = var_5;
            }
        }

        if ( isdefined( level.littleBirds ) )
        {
            foreach ( var_8 in level.littleBirds )
            {
                if ( !isdefined( var_8 ) )
                    continue;

                var_0[var_0.size] = var_8;
            }
        }

        if ( isdefined( level.ugvs ) )
        {
            foreach ( var_11 in level.ugvs )
            {
                if ( !isdefined( var_11 ) )
                    continue;

                var_0[var_0.size] = var_11;
            }
        }

        foreach ( var_22 in level.players )
        {
            if ( !isalive( var_22 ) )
                continue;

            if ( level.teamBased && var_22.team == self.team )
                continue;

            if ( var_22 == self )
                continue;

            if ( var_22 maps\mp\_utility::isJuggernaut() )
                var_0[var_0.size] = var_22;
        }
    }

    return var_0;
}

StingerUsageLoop()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    var_0 = 1000;
    InitStingerUsage();

    for (;;)
    {
        wait 0.05;
        var_1 = self getcurrentweapon();

        if ( var_1 != "stinger_mp" && var_1 != "at4_mp" && var_1 != "iw5_smaw_mp" )
        {
            ResetStingerLocking();
            continue;
        }

        if ( self playerads() < 0.95 )
        {
            ResetStingerLocking();
            continue;
        }

        self.stingerUseEntered = 1;

        if ( !isdefined( self.stingerStage ) )
            self.stingerStage = 0;

        StingerDebugDraw( self.stingerTarget );

        if ( self.stingerStage == 0 )
        {
            var_2 = GetTargetList();

            if ( var_2.size == 0 )
                continue;

            var_3 = [];

            foreach ( var_5 in var_2 )
            {
                if ( !isdefined( var_5 ) )
                    continue;

                var_6 = self worldpointinreticle_circle( var_5.origin, 65, 75 );

                if ( var_6 )
                    var_3[var_3.size] = var_5;
            }

            if ( var_3.size == 0 )
                continue;

            var_8 = sortbydistance( var_3, self.origin );

            if ( !LockSightTest( var_8[0] ) )
                continue;

            thread LoopStingerLockingFeedback();
            self.stingerTarget = var_8[0];
            self.stingerLockStartTime = gettime();
            self.stingerStage = 1;
            self.stingerLostSightlineTime = 0;
        }

        if ( self.stingerStage == 1 )
        {
            if ( !StillValidStingerLock( self.stingerTarget ) )
            {
                ResetStingerLocking();
                continue;
            }

            var_9 = SoftSightTest();

            if ( !var_9 )
                continue;

            var_10 = gettime() - self.stingerLockStartTime;

            if ( maps\mp\_utility::_hasPerk( "specialty_fasterlockon" ) )
            {
                if ( var_10 < var_0 * 0.5 )
                    continue;
            }
            else if ( var_10 < var_0 )
                continue;

            self notify( "stop_javelin_locking_feedback" );
            thread LoopStingerLockedFeedback();

            if ( self.stingerTarget.model == "vehicle_av8b_harrier_jet_opfor_mp" || self.stingerTarget.model == "vehicle_av8b_harrier_jet_mp" || self.stingerTarget.model == "vehicle_little_bird_armed" || self.stingerTarget.model == "vehicle_ugv_talon_mp" )
                self weaponlockfinalize( self.stingerTarget );
            else if ( isplayer( self.stingerTarget ) )
                self weaponlockfinalize( self.stingerTarget, ( 100, 0, 64 ) );
            else
                self weaponlockfinalize( self.stingerTarget, ( 100, 0, -32 ) );

            self.stingerStage = 2;
        }

        if ( self.stingerStage == 2 )
        {
            var_9 = SoftSightTest();

            if ( !var_9 )
                continue;

            if ( !StillValidStingerLock( self.stingerTarget ) )
            {
                ResetStingerLocking();
                continue;
            }
        }
    }
}
