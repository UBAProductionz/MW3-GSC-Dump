// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.isTeamSpeaking["allies"] = 0;
    level.isTeamSpeaking["axis"] = 0;
    level.speakers["allies"] = [];
    level.speakers["axis"] = [];
    level.bcSounds = [];
    level.bcSounds["reload"] = "inform_reloading_generic";
    level.bcSounds["frag_out"] = "inform_attack_grenade";
    level.bcSounds["flash_out"] = "inform_attack_flashbang";
    level.bcSounds["smoke_out"] = "inform_attack_smoke";
    level.bcSounds["conc_out"] = "inform_attack_stun";
    level.bcSounds["c4_plant"] = "inform_attack_thwc4";
    level.bcSounds["claymore_plant"] = "inform_plant_claymore";
    level.bcSounds["semtex_out"] = "semtex_use";
    level.bcSounds["kill"] = "inform_killfirm_infantry";
    level.bcSounds["casualty"] = "inform_casualty_generic";
    level.bcSounds["suppressing_fire"] = "cmd_suppressfire";
    level.bcSounds["semtex_incoming"] = "semtex_incoming";
    level.bcSounds["c4_incoming"] = "c4_incoming";
    level.bcSounds["flash_incoming"] = "flash_incoming";
    level.bcSounds["stun_incoming"] = "stun_incoming";
    level.bcSounds["grenade_incoming"] = "grenade_incoming";
    level.bcSounds["rpg_incoming"] = "rpg_incoming";
    level thread onPlayerConnect();
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
        var_0 = maps\mp\gametypes\_teams::getTeamVoicePrefix( self.team );

        if ( !isdefined( self.pers["voiceIndex"] ) || var_0 != "RU_" && self.pers["voiceNum"] >= 3 )
        {
            if ( var_0 == "RU_" )
                self.pers["voiceNum"] = randomintrange( 0, 4 );
            else
                self.pers["voiceNum"] = randomintrange( 0, 2 );

            self.pers["voicePrefix"] = var_0 + self.pers["voiceNum"] + "_";
        }

        if ( level.splitscreen )
            continue;

        thread claymoreTracking();
        thread reloadTracking();
        thread grenadeTracking();
        thread grenadeProximityTracking();
        thread suppressingFireTracking();
    }
}

grenadeProximityTracking()
{
    self endon( "disconnect" );
    self endon( "death" );
    var_0 = self.origin;

    for (;;)
    {
        if ( !isdefined( level.grenades ) || level.grenades.size < 1 || !maps\mp\_utility::isReallyAlive( self ) )
        {
            wait 0.05;
            continue;
        }

        var_1 = maps\mp\_utility::combineArrays( level.grenades, level.missiles );

        foreach ( var_3 in var_1 )
        {
            wait 0.05;

            if ( !isdefined( var_3 ) )
                continue;

            if ( isdefined( var_3.weaponName ) )
            {
                switch ( var_3.weaponName )
                {
                    case "claymore_mp":
                        continue;
                }
            }

            switch ( var_3.model )
            {
                case "weapon_parabolic_knife":
                case "weapon_jammer":
                case "weapon_radar":
                case "mp_trophy_system":
                    continue;
            }

            if ( !isdefined( var_3.owner ) )
                var_3.owner = getmissileowner( var_3 );

            if ( isdefined( var_3.owner ) && level.teamBased && var_3.owner.team == self.team )
                continue;

            var_4 = distancesquared( var_3.origin, self.origin );

            if ( var_4 < 147456 )
            {
                if ( bullettracepassed( var_3.origin, self.origin, 0, self ) )
                {
                    if ( common_scripts\utility::cointoss() )
                    {
                        continue;
                        wait 5;
                        continue;
                    }

                    if ( var_3.model == "projectile_concussion_grenade" )
                    {
                        level thread sayLocalSound( self, "stun_incoming" );
                        wait 5;
                        continue;
                    }

                    if ( var_3.model == "projectile_m84_flashbang_grenade" )
                    {
                        level thread sayLocalSound( self, "flash_incoming" );
                        wait 5;
                        continue;
                    }

                    if ( var_3.model == "projectile_rocket" )
                    {
                        level thread sayLocalSound( self, "rpg_incoming" );
                        wait 5;
                        continue;
                    }

                    if ( var_3.model == "weapon_c4" )
                    {
                        level thread sayLocalSound( self, "c4_incoming" );
                        wait 5;
                        continue;
                    }

                    if ( var_3.model == "projectile_m203grenade" )
                    {
                        level thread sayLocalSound( self, "rpg_incoming" );
                        wait 5;
                        continue;
                    }

                    if ( var_3.model == "projectile_semtex_grenade" )
                    {
                        level thread sayLocalSound( self, "semtex_incoming" );
                        wait 5;
                        continue;
                    }

                    level thread sayLocalSound( self, "grenade_incoming" );
                    wait 5;
                }
            }
        }
    }
}

suppressingFireTracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );
    var_0 = undefined;

    for (;;)
    {
        self waittill( "begin_firing" );
        thread suppressWaiter();
        self waittill( "end_firing" );
        self notify( "stoppedFiring" );
    }
}

suppressWaiter()
{
    self notify( "suppressWaiter" );
    self endon( "suppressWaiter" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "stoppedFiring" );
    wait 2;
    level thread sayLocalSound( self, "suppressing_fire" );
}

claymoreTracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );

    for (;;)
    {
        self waittill( "begin_firing" );
        var_0 = self getcurrentweapon();

        if ( var_0 == "claymore_mp" )
            level thread sayLocalSound( self, "claymore_plant" );
    }
}

reloadTracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );

    for (;;)
    {
        self waittill( "reload_start" );
        level thread sayLocalSound( self, "reload" );
    }
}

grenadeTracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "faux_spawn" );

    for (;;)
    {
        self waittill( "grenade_fire",  var_0, var_1  );

        if ( var_1 == "frag_grenade_mp" )
        {
            level thread sayLocalSound( self, "frag_out" );
            continue;
        }

        if ( var_1 == "semtex_mp" )
        {
            level thread sayLocalSound( self, "semtex_out" );
            continue;
        }

        if ( var_1 == "flash_grenade_mp" )
        {
            level thread sayLocalSound( self, "flash_out" );
            continue;
        }

        if ( var_1 == "concussion_grenade_mp" )
        {
            level thread sayLocalSound( self, "conc_out" );
            continue;
        }

        if ( var_1 == "smoke_grenade_mp" )
        {
            level thread sayLocalSound( self, "smoke_out" );
            continue;
        }

        if ( var_1 == "c4_mp" )
            level thread sayLocalSound( self, "c4_plant" );
    }
}

sayLocalSoundDelayed( var_0, var_1, var_2 )
{
    var_0 endon( "death" );
    var_0 endon( "disconnect" );
    wait(var_2);
    sayLocalSound( var_0, var_1 );
}

sayLocalSound( var_0, var_1 )
{
    var_0 endon( "death" );
    var_0 endon( "disconnect" );

    if ( isSpeakerInRange( var_0 ) )
        return;

    if ( var_0.team != "spectator" )
    {
        var_2 = var_0.pers["voicePrefix"];
        var_3 = var_2 + level.bcSounds[var_1];
        var_0 thread doSound( var_3 );
    }
}

doSound( var_0 )
{
    var_1 = self.pers["team"];
    level addSpeaker( self, var_1 );
    self playsoundtoteam( var_0, var_1, self );
    thread timeHack( var_0 );
    common_scripts\utility::waittill_any( var_0, "death", "disconnect" );
    level removeSpeaker( self, var_1 );
}

timeHack( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    wait 2.0;
    self notify( var_0 );
}

isSpeakerInRange( var_0 )
{
    var_0 endon( "death" );
    var_0 endon( "disconnect" );
    var_1 = 1000000;

    if ( isdefined( var_0 ) && isdefined( var_0.pers["team"] ) && var_0.pers["team"] != "spectator" )
    {
        for ( var_2 = 0; var_2 < level.speakers[var_0.pers["team"]].size; var_2++ )
        {
            var_3 = level.speakers[var_0.pers["team"]][var_2];

            if ( var_3 == var_0 )
                return 1;

            if ( !isdefined( var_3 ) )
                continue;

            if ( distancesquared( var_3.origin, var_0.origin ) < var_1 )
                return 1;
        }
    }

    return 0;
}

addSpeaker( var_0, var_1 )
{
    level.speakers[var_1][level.speakers[var_1].size] = var_0;
}

removeSpeaker( var_0, var_1 )
{
    var_2 = [];

    for ( var_3 = 0; var_3 < level.speakers[var_1].size; var_3++ )
    {
        if ( level.speakers[var_1][var_3] == var_0 )
            continue;

        var_2[var_2.size] = level.speakers[var_1][var_3];
    }

    level.speakers[var_1] = var_2;
}
