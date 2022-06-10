// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

setScrambler()
{
    self setoffhandsecondaryclass( "flash" );
    maps\mp\_utility::_giveWeapon( "scrambler_mp", 0 );
    self givestartammo( "scrambler_mp" );
    thread monitorScramblerUse();
}

unsetScrambler()
{
    self notify( "end_monitorScramblerUse" );
}

deleteScrambler( var_0 )
{
    if ( !isdefined( var_0 ) )
        return;

    foreach ( var_2 in level.players )
    {
        if ( isdefined( var_2 ) )
            var_2.inPlayerScrambler = undefined;
    }

    var_0 notify( "death" );
    var_0 delete();
    self.deployedScrambler = undefined;
    var_4 = [];
    var_4 = maps\mp\_utility::cleanArray( level.scramblers );
    level.scramblers = var_4;
}

monitorScramblerUse()
{
    self notify( "end_monitorScramblerUse" );
    self endon( "end_monitorScramblerUse" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "grenade_fire",  var_0, var_1  );

        if ( var_1 == "scrambler" || var_1 == "scrambler_mp" )
        {
            if ( !isalive( self ) )
            {
                var_0 delete();
                return;
            }

            var_0 hide();
            var_0 waittill( "missile_stuck" );
            var_2 = 40;

            if ( var_2 * var_2 < distancesquared( var_0.origin, self.origin ) )
            {
                var_3 = bullettrace( self.origin, self.origin - ( 0, 0, var_2 ), 0, self );

                if ( var_3["fraction"] == 1 )
                {
                    var_0 delete();
                    self setweaponammostock( "scrambler_mp", self getweaponammostock( "trophy_mp" ) + 1 );
                    continue;
                }

                var_0.origin = var_3["position"];
            }

            var_0 show();

            if ( isdefined( self.deployedScrambler ) )
                deleteScrambler( self.deployedScrambler );

            var_4 = var_0.origin;
            var_5 = spawn( "script_model", var_4 );
            var_5.health = 100;
            var_5.team = self.team;
            var_5.owner = self;
            var_5 setcandamage( 1 );
            var_5 makescrambler( self );
            var_5 scramblerSetup( self );
            var_5 thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_jammer_bombsquad", "tag_origin", level.otherTeam[self.team], self );
            level.scramblers[level.scramblers.size] = var_5;
            self.deployedScrambler = var_5;
            self.changingWeapon = undefined;
            wait 0.05;

            if ( isdefined( var_0 ) )
                var_0 delete();
        }
    }
}

scramblerSetup( var_0 )
{
    self setmodel( "weapon_jammer" );

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( 0, 0, 20 ) );
    else
        maps\mp\_entityheadicons::setPlayerHeadIcon( var_0, ( 0, 0, 20 ) );

    thread scramblerDamageListener( var_0 );
    thread scramblerUseListener( var_0 );
    var_0 thread scramblerWatchOwner( self );
    thread scramblerBeepSounds();
    thread maps\mp\_utility::notUsableForJoiningPlayers( var_0 );
}

scramblerWatchOwner( var_0 )
{
    var_0 endon( "death" );
    level endon( "game_ended" );
    common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators", "death" );
    level thread deleteScrambler( var_0 );
}

scramblerBeepSounds()
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        wait 3.0;
        self playsound( "scrambler_beep" );
    }
}

scramblerDamageListener( var_0 )
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
                case "smoke_grenade_mp":
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
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

        if ( isplayer( var_2 ) )
            var_2 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scrambler" );

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isdefined( var_0 ) && var_2 != var_0 )
                var_2 notify( "destroyed_explosive" );

            self playsound( "sentry_explode" );
            self.deathEffect = playfx( common_scripts\utility::getfx( "equipment_explode" ), self.origin );
            var_2 thread deleteScrambler( self );
        }
    }
}

scramblerUseListener( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( &"MP_PATCH_PICKUP_SCRAMBLER" );
    maps\mp\_utility::setSelfUsable( var_0 );

    for (;;)
    {
        self waittill( "trigger",  var_1  );
        var_1 playlocalsound( "scavenger_pack_pickup" );

        if ( var_1 getammocount( "scrambler_mp" ) == 0 && !var_1 maps\mp\_utility::isJuggernaut() )
            var_1 setScrambler();

        var_1 thread deleteScrambler( self );
    }
}

scramblerProximityTracker()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "faux_spawn" );
    level endon( "game_ended" );
    self.scramProxyActive = 0;
    var_0 = 512;

    for (;;)
    {
        wait 0.05;
        self.scramProxyActive = 0;

        foreach ( var_2 in level.scramblers )
        {
            if ( !isdefined( var_2 ) )
                continue;

            if ( !maps\mp\_utility::isReallyAlive( self ) )
                continue;

            var_3 = distancesquared( var_2.origin, self.origin );

            if ( level.teamBased && var_2.team != self.team || !level.teamBased && isdefined( var_2.owner ) && var_2.owner != self )
            {
                if ( var_3 < var_0 * var_0 )
                    self.inPlayerScrambler = var_2.owner;
                else
                    self.inPlayerScrambler = undefined;

                continue;
            }

            if ( var_3 < var_0 * var_0 )
            {
                self.scramProxyActive = 1;
                break;
            }
        }

        if ( self.scramProxyActive )
        {
            if ( !maps\mp\_utility::_hasPerk( "specialty_blindeye" ) )
            {
                maps\mp\_utility::givePerk( "specialty_blindeye", 0 );
                self.scramProxyPerk = 1;
            }

            continue;
        }

        if ( isdefined( self.scramProxyPerk ) && self.scramProxyPerk )
        {
            if ( !maps\mp\killstreaks\_perkstreaks::isPerkStreakOn( "specialty_blindeye_ks" ) )
                maps\mp\_utility::_unsetPerk( "specialty_blindeye" );

            self.scramProxyPerk = 0;
        }
    }
}
