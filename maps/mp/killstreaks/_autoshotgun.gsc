// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.killstreakFuncs["auto_shotgun"] = ::tryUseAutoShotgun;
    level.killstreakSetupFuncs["auto_shotgun"] = ::shotgunSetup;
    level.killstreakFuncs["thumper"] = ::tryUseThumper;
    level.killstreakSetupFuncs["thumper"] = ::thumperSetup;
    thread onPlayerConnect();
}

shotgunSetup()
{
    self givemaxammo( "aa12_mp" );
    thread saveWeaponAmmoOnDeath( "aa12_mp" );
}

tryUseAutoShotgun( var_0 )
{
    thread removeWeaponOnOutOfAmmo( "aa12_mp" );
    return 1;
}

thumperSetup()
{
    self givemaxammo( "m79_mp" );
    thread saveWeaponAmmoOnDeath( "m79_mp" );
}

tryUseThumper()
{
    thread removeWeaponOnOutOfAmmo( "m79_mp" );
    return 1;
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

        if ( !isdefined( self.pers["ksWeapon_clip_ammo"] ) || !isdefined( self.pers["ksWeapon_name"] ) )
            continue;

        var_0 = self.pers["ksWeapon_name"];

        if ( isdefined( self.pers["killstreak"] ) && maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( self.pers["killstreak"] ) != var_0 )
        {
            self.pers["ksWeapon_name"] = undefined;
            self.pers["ksWeapon_clip_ammo"] = undefined;
            self.pers["ksWeapon_stock_ammo"] = undefined;
            continue;
        }

        maps\mp\killstreaks\_killstreaks::giveKillstreakWeapon( var_0 );
        self setweaponammostock( var_0, self.pers["ksWeapon_stock_ammo"] );
        self setweaponammoclip( var_0, self.pers["ksWeapon_clip_ammo"] );
        thread removeWeaponOnOutOfAmmo( var_0 );
        thread saveWeaponAmmoOnDeath( var_0 );
    }
}

saveWeaponAmmoOnDeath( var_0 )
{
    self endon( "disconnect" );
    self endon( "got_killstreak" );
    self notify( "saveWeaponAmmoOnDeath" );
    self endon( "saveWeaponAmmoOnDeath" );
    self.pers["ksWeapon_name"] = undefined;
    self.pers["ksWeapon_clip_ammo"] = undefined;
    self.pers["ksWeapon_stock_ammo"] = undefined;
    self waittill( "death" );

    if ( !self hasweapon( var_0 ) )
        return;

    self.pers["ksWeapon_name"] = var_0;
    self.pers["ksWeapon_clip_ammo"] = self getweaponammoclip( var_0 );
    self.pers["ksWeapon_stock_ammo"] = self getweaponammostock( var_0 );
}

removeWeaponOnOutOfAmmo( var_0 )
{
    self endon( "disconnect" );
    self endon( "death" );
    self notify( var_0 + "_ammo_monitor" );
    self endon( var_0 + "_ammo_monitor" );

    for (;;)
    {
        self waittill( "end_firing" );

        if ( self getcurrentweapon() != var_0 )
            continue;

        var_1 = self getweaponammoclip( var_0 ) + self getweaponammostock( var_0 );

        if ( var_1 )
            continue;

        self takeweapon( var_0 );
        return;
    }
}
