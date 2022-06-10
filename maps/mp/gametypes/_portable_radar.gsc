// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

setPortableRadar()
{
    self setoffhandsecondaryclass( "flash" );
    maps\mp\_utility::_giveWeapon( "portable_radar_mp", 0 );
    self givestartammo( "portable_radar_mp" );
    thread monitorPortableRadarUse();
}

unsetPortableRadar()
{
    self notify( "end_monitorPortableRadarUse" );
}

deletePortableRadar( var_0 )
{
    if ( !isdefined( var_0 ) )
        return;

    foreach ( var_2 in level.players )
    {
        if ( isdefined( var_2 ) )
            var_2.inPlayerPortableRadar = undefined;
    }

    var_0 notify( "death" );
    var_0 delete();
    self.deployedPortableRadar = undefined;
}

monitorPortableRadarUse()
{
    self notify( "end_monitorPortableRadarUse" );
    self endon( "end_monitorPortableRadarUse" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "grenade_fire",  var_0, var_1  );

        if ( var_1 == "portabl_radar" || var_1 == "portable_radar_mp" )
        {
            if ( !isalive( self ) )
            {
                var_0 delete();
                return;
            }

            if ( isdefined( self.deployedPortableRadar ) )
                deletePortableRadar( self.deployedPortableRadar );

            var_0 waittill( "missile_stuck" );
            var_2 = var_0.origin;

            if ( isdefined( var_0 ) )
                var_0 delete();

            var_3 = spawn( "script_model", var_2 );
            var_3.health = 100;
            var_3.team = self.team;
            var_3.owner = self;
            var_3 setcandamage( 1 );
            var_3 makeportableradar( self );
            var_3 portableRadarSetup( self );
            var_3 thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_radar_bombsquad", "tag_origin", level.otherTeam[self.team], self );
            var_3 thread portableRadarProximityTracker();
            thread portableRadarWatchOwner( var_3 );
            self.deployedPortableRadar = var_3;
        }
    }
}

portableRadarSetup( var_0 )
{
    self setmodel( "weapon_radar" );

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( 0, 0, 20 ) );
    else
        maps\mp\_entityheadicons::setPlayerHeadIcon( var_0, ( 0, 0, 20 ) );

    thread portableRadarDamageListener( var_0 );
    thread portableRadarUseListener( var_0 );
    thread portableRadarBeepSounds();
    thread maps\mp\_utility::notUsableForJoiningPlayers( var_0 );
}

portableRadarWatchOwner( var_0 )
{
    var_0 endon( "death" );
    level endon( "game_ended" );
    common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators", "spawned_player" );
    level thread deletePortableRadar( var_0 );
}

portableRadarBeepSounds()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        wait 2.0;
        self playsound( "sentry_gun_beep" );
    }
}

portableRadarDamageListener( var_0 )
{
    self endon( "death" );
    self.health = 999999;
    self.maxHealth = 100;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage",  var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10  );

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_2 ) )
            continue;

        if ( isdefined( var_10 ) )
        {
            switch ( var_10 )
            {
                case "concussion_grenade_mp":
                case "smoke_grenade_mp":
                case "flash_grenade_mp":
                    continue;
            }
        }

        if ( !isdefined( self ) )
            return;

        if ( var_5 == "MOD_MELEE" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        if ( isdefined( var_9 ) && var_9 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;
        self.damagetaken = self.damagetaken + var_1;

        if ( isdefined( var_10 ) && var_10 == "emp_grenade_mp" )
            self.damagetaken = self.maxHealth + 1;

        if ( isplayer( var_2 ) )
            var_2 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "portable_radar" );

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isdefined( var_0 ) && var_2 != var_0 )
                var_2 notify( "destroyed_explosive" );

            self playsound( "sentry_explode" );
            self.deathEffect = playfx( common_scripts\utility::getfx( "equipment_explode" ), self.origin );
            var_2 thread deletePortableRadar( self );
        }
    }
}

portableRadarUseListener( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( &"MP_PATCH_PICKUP_PORTABLE_RADAR" );
    maps\mp\_utility::setSelfUsable( var_0 );

    for (;;)
    {
        self waittill( "trigger",  var_1  );
        var_1 playlocalsound( "scavenger_pack_pickup" );

        if ( var_1 getammocount( "portable_radar_mp" ) == 0 )
            var_1 setPortableRadar();

        var_1 thread deletePortableRadar( self );
    }
}

portableRadarProximityTracker()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = 512;

    for (;;)
    {
        foreach ( var_2 in level.players )
        {
            if ( !isdefined( var_2 ) )
                continue;

            if ( level.teamBased && var_2.team == self.team )
                continue;

            var_3 = distancesquared( self.origin, var_2.origin );

            if ( distancesquared( var_2.origin, self.origin ) < var_0 * var_0 )
            {
                var_2.inPlayerPortableRadar = self.owner;
                continue;
            }

            var_2.inPlayerPortableRadar = undefined;
        }

        wait 0.05;
    }
}
