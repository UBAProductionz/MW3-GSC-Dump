// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.killstreakFuncs["specialty_longersprint_ks"] = ::tryUseExtremeConditioning;
    level.killstreakFuncs["specialty_fastreload_ks"] = ::tryUseSleightOfHand;
    level.killstreakFuncs["specialty_scavenger_ks"] = ::tryUseScavenger;
    level.killstreakFuncs["specialty_blindeye_ks"] = ::tryUseBlindEye;
    level.killstreakFuncs["specialty_paint_ks"] = ::tryUsePaint;
    level.killstreakFuncs["specialty_hardline_ks"] = ::tryUseHardline;
    level.killstreakFuncs["specialty_coldblooded_ks"] = ::tryUseColdBlooded;
    level.killstreakFuncs["specialty_quickdraw_ks"] = ::tryUseQuickdraw;
    level.killstreakFuncs["specialty_assists_ks"] = ::tryUseAssists;
    level.killstreakFuncs["_specialty_blastshield_ks"] = ::tryUseBlastshield;
    level.killstreakFuncs["specialty_detectexplosive_ks"] = ::tryUseSitRep;
    level.killstreakFuncs["specialty_autospot_ks"] = ::tryUseIronLungs;
    level.killstreakFuncs["specialty_bulletaccuracy_ks"] = ::tryUseSteadyAim;
    level.killstreakFuncs["specialty_quieter_ks"] = ::tryUseDeadSilence;
    level.killstreakFuncs["specialty_stalker_ks"] = ::tryUseStalker;
    level.killstreakFuncs["all_perks_bonus"] = ::tryUseAllPerks;
}

tryUseAllPerks()
{

}

tryUseBlindEye( var_0 )
{
    self.spawnperk = 0;
    doPerkFunctions( "specialty_blindeye" );
}

tryUsePaint( var_0 )
{
    doPerkFunctions( "specialty_paint" );
}

tryUseAssists( var_0 )
{
    doPerkFunctions( "specialty_assists" );
}

tryUseSteadyAim( var_0 )
{
    doPerkFunctions( "specialty_bulletaccuracy" );
}

tryUseStalker( var_0 )
{
    doPerkFunctions( "specialty_stalker" );
}

tryUseExtremeConditioning( var_0 )
{
    doPerkFunctions( "specialty_longersprint" );
}

tryUseSleightOfHand( var_0 )
{
    doPerkFunctions( "specialty_fastreload" );
}

tryUseScavenger( var_0 )
{
    doPerkFunctions( "specialty_scavenger" );
}

tryUseHardline( var_0 )
{
    doPerkFunctions( "specialty_hardline" );
    maps\mp\killstreaks\_killstreaks::setStreakCountToNext();
}

tryUseColdBlooded( var_0 )
{
    doPerkFunctions( "specialty_coldblooded" );
}

tryUseQuickdraw( var_0 )
{
    doPerkFunctions( "specialty_quickdraw" );
}

tryUseBlastshield( var_0 )
{
    doPerkFunctions( "_specialty_blastshield" );
}

tryUseSitRep( var_0 )
{
    doPerkFunctions( "specialty_detectexplosive" );
}

tryUseIronLungs( var_0 )
{
    doPerkFunctions( "specialty_autospot" );
}

tryUseAssassin( var_0 )
{
    doPerkFunctions( "specialty_heartbreaker" );
}

tryUseDeadSilence( var_0 )
{
    doPerkFunctions( "specialty_quieter" );
}

doPerkFunctions( var_0 )
{
    maps\mp\_utility::givePerk( var_0, 0 );
    thread watchDeath( var_0 );
    thread checkForPerkUpgrade( var_0 );
    maps\mp\_matchdata::logKillstreakEvent( var_0 + "_ks", self.origin );
}

watchDeath( var_0 )
{
    self endon( "disconnect" );
    self waittill( "death" );
    maps\mp\_utility::_unsetPerk( var_0 );
    maps\mp\_utility::_unsetExtraPerks( var_0 );
}

checkForPerkUpgrade( var_0 )
{
    var_1 = maps\mp\gametypes\_class::getPerkUpgrade( var_0 );

    if ( var_1 != "specialty_null" )
    {
        maps\mp\_utility::givePerk( var_1, 0 );
        thread watchDeath( var_1 );
    }
}

isPerkStreakOn( var_0 )
{
    for ( var_1 = 1; var_1 < 4; var_1++ )
    {
        if ( isdefined( self.pers["killstreaks"][var_1].streakName ) && self.pers["killstreaks"][var_1].streakName == var_0 )
        {
            if ( self.pers["killstreaks"][var_1].available )
                return 1;
        }
    }

    return 0;
}
