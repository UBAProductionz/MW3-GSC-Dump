// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precacheshellshock( "flashbang_mp" );
    thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0 thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );
        thread monitorEMPGrenade();
    }
}

monitorEMPGrenade()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    self.empEndTime = 0;

    for (;;)
    {
        self waittill( "emp_grenaded",  var_0  );

        if ( !isalive( self ) )
            continue;

        if ( isdefined( self.usingRemote ) )
            continue;

        if ( maps\mp\_utility::_hasPerk( "specialty_empimmune" ) )
            continue;

        var_1 = 1;
        var_2 = 0;

        if ( level.teamBased && isdefined( var_0 ) && isdefined( var_0.pers["team"] ) && var_0.pers["team"] == self.pers["team"] && var_0 != self )
        {
            if ( level.friendlyfire == 0 )
                continue;
            else if ( level.friendlyfire == 1 )
            {
                var_2 = 0;
                var_1 = 1;
            }
            else if ( level.friendlyfire == 2 )
            {
                var_1 = 0;
                var_2 = 1;
            }
            else if ( level.friendlyfire == 3 )
            {
                var_2 = 1;
                var_1 = 1;
            }
        }
        else if ( isdefined( var_0 ) )
        {
            var_0 notify( "emp_hit" );

            if ( var_0 != self )
                var_0 maps\mp\gametypes\_missions::processChallenge( "ch_onthepulse" );
        }

        if ( var_1 && isdefined( self ) )
            thread applyEMP();

        if ( var_2 && isdefined( var_0 ) )
            var_0 thread applyEMP();
    }
}

applyEMP()
{
    self notify( "applyEmp" );
    self endon( "applyEmp" );
    self endon( "death" );
    wait 0.05;
    self.empDuration = 10;
    self.empGrenaded = 1;
    self shellshock( "flashbang_mp", 1 );
    self.empEndTime = gettime() + self.empDuration * 1000;
    thread empRumbleLoop( 0.75 );
    self setempjammed( 1 );
    thread empGrenadeDeathWaiter();
    wait(self.empDuration);
    self notify( "empGrenadeTimedOut" );
    checkToTurnOffEmp();
}

empGrenadeDeathWaiter()
{
    self notify( "empGrenadeDeathWaiter" );
    self endon( "empGrenadeDeathWaiter" );
    self endon( "empGrenadeTimedOut" );
    self waittill( "death" );
    checkToTurnOffEmp();
}

checkToTurnOffEmp()
{
    self.empGrenaded = 0;

    if ( level.teamBased && ( level.teamEMPed[self.team] || level.teamNukeEMPed[self.team] ) || !level.teamBased && isdefined( level.EMPPlayer ) && level.EMPPlayer != self || !level.teamBased && isdefined( level.nukeInfo.player ) && level.nukeInfo.player != self )
        return;

    self setempjammed( 0 );
}

empRumbleLoop( var_0 )
{
    self endon( "emp_rumble_loop" );
    self notify( "emp_rumble_loop" );
    var_1 = gettime() + var_0 * 1000;

    while ( gettime() < var_1 )
    {
        self playrumbleonentity( "damage_heavy" );
        wait 0.05;
    }
}

isEMPGrenaded()
{
    return isdefined( self.empEndTime ) && gettime() < self.empEndTime;
}
