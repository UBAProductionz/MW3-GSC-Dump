// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.killstreakFuncs["team_ammo_refill"] = ::tryUseTeamAmmoRefill;
}

tryUseTeamAmmoRefill( var_0 )
{
    var_1 = giveTeamAmmoRefill();

    if ( var_1 )
        maps\mp\_matchdata::logKillstreakEvent( "team_ammo_refill", self.origin );

    return var_1;
}

giveTeamAmmoRefill()
{
    if ( level.teamBased )
    {
        foreach ( var_1 in level.players )
        {
            if ( var_1.team == self.team )
                var_1 refillAmmo( 1 );
        }
    }
    else
        refillAmmo( 1 );

    level thread maps\mp\_utility::teamPlayerCardSplash( "used_team_ammo_refill", self );
    return 1;
}

refillAmmo( var_0 )
{
    var_1 = self getweaponslistall();

    if ( var_0 )
    {
        if ( maps\mp\_utility::_hasPerk( "specialty_tacticalinsertion" ) && self getammocount( "flare_mp" ) < 1 )
            maps\mp\_utility::givePerk( "specialty_tacticalinsertion", 0 );

        if ( maps\mp\_utility::_hasPerk( "specialty_scrambler" ) && self getammocount( "scrambler_mp" ) < 1 )
            maps\mp\_utility::givePerk( "specialty_scrambler", 0 );

        if ( maps\mp\_utility::_hasPerk( "specialty_portable_radar" ) && self getammocount( "portable_radar_mp" ) < 1 )
            maps\mp\_utility::givePerk( "specialty_portable_radar", 0 );
    }

    foreach ( var_3 in var_1 )
    {
        if ( issubstr( var_3, "grenade" ) || getsubstr( var_3, 0, 2 ) == "gl" )
        {
            if ( !var_0 || self getammocount( var_3 ) >= 1 )
                continue;
        }

        self givemaxammo( var_3 );
    }

    self playlocalsound( "ammo_crate_use" );
}
