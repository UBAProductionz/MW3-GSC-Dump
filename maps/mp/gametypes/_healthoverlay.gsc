// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.healthOverlayCutoff = 0.55;
    var_0 = 5;
    var_0 = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "healthregentime" );
    level.playerHealth_RegularRegenDelay = var_0 * 1000;
    level.healthRegenDisabled = level.playerHealth_RegularRegenDelay <= 0;
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
        thread playerHealthRegen();
        self visionsetthermalforplayer( game["thermal_vision"] );
    }
}

playerHealthRegen()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );
    self endon( "faux_spawn" );
    level endon( "game_ended" );

    if ( self.health <= 0 )
        return;

    var_0 = 0;
    var_1 = 0;
    thread playerPainBreathingSound( self.maxHealth * 0.55 );

    for (;;)
    {
        self waittill( "damage" );

        if ( self.health <= 0 )
            return;

        var_1 = gettime();
        var_2 = self.health / self.maxHealth;

        if ( !isdefined( self.healthRegenLevel ) )
            self.regenSpeed = 1;
        else if ( self.healthRegenLevel == 0.33 )
            self.regenSpeed = 0.75;
        else if ( self.healthRegenLevel == 0.66 )
            self.regenSpeed = 0.5;
        else if ( self.healthRegenLevel == 0.99 )
            self.regenSpeed = 0.3;
        else
            self.regenSpeed = 1;

        if ( var_2 <= level.healthOverlayCutoff )
            self.atBrinkOfDeath = 1;

        thread healthRegeneration( var_1, var_2 );
        thread breathingManager( var_1, var_2 );
    }
}

breathingManager( var_0, var_1 )
{
    self notify( "breathingManager" );
    self endon( "breathingManager" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );
    level endon( "game_ended" );

    if ( maps\mp\_utility::isUsingRemote() )
        return;

    self.breathingStopTime = var_0 + 6000 * self.regenSpeed;
    wait(6 * self.regenSpeed);

    if ( !level.gameEnded )
        self playlocalsound( "breathing_better" );
}

healthRegeneration( var_0, var_1 )
{
    self notify( "healthRegeneration" );
    self endon( "healthRegeneration" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );
    level endon( "game_ended" );

    if ( level.healthRegenDisabled )
        return;

    wait(level.playerHealth_RegularRegenDelay / 1000 * self.regenSpeed);

    if ( var_1 < 0.55 )
        var_2 = 1;
    else
        var_2 = 0;

    for (;;)
    {
        if ( self.regenSpeed == 0.75 )
        {
            wait 0.2;

            if ( self.health < self.maxHealth )
                self.health = self.health + 5;
            else
                break;
        }
        else if ( self.regenSpeed == 0.5 )
        {
            wait 0.05;

            if ( self.health < self.maxHealth )
                self.health = self.health + 2;
            else
                break;
        }
        else if ( self.regenSpeed == 0.3 )
        {
            wait 0.15;

            if ( self.health < self.maxHealth )
                self.health = self.health + 9;
            else
                break;
        }
        else if ( !isdefined( self.regenSpeed ) || self.regenSpeed == 1 )
        {
            wait 0.05;

            if ( self.health < self.maxHealth )
            {
                self.health = self.health + 1;
                var_1 = self.health / self.maxHealth;
            }
            else
                break;
        }

        if ( self.health > self.maxHealth )
            self.health = self.maxHealth;
    }

    maps\mp\gametypes\_damage::resetAttackerList();

    if ( var_2 )
        maps\mp\gametypes\_missions::healthRegenerated();
}

wait_for_not_using_remote()
{
    self notify( "waiting_to_stop_remote" );
    self endon( "waiting_to_stop_remote" );
    self endon( "death" );
    level endon( "game_ended" );
    self waittill( "stopped_using_remote" );

    if ( isdefined( level.nukeDetonated ) )
        self visionsetnakedforplayer( level.nukeVisionSet, 0 );
    else
        self visionsetnakedforplayer( "", 0 );
}

playerPainBreathingSound( var_0 )
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );
    wait 2;

    for (;;)
    {
        wait 0.2;

        if ( self.health <= 0 )
            return;

        if ( self.health >= var_0 )
            continue;

        if ( level.healthRegenDisabled && gettime() > self.breathingStopTime )
            continue;

        if ( maps\mp\_utility::isUsingRemote() )
            continue;

        self playlocalsound( "breathing_hurt" );
        wait 0.784;
        wait(0.1 + randomfloat( 0.8 ));
    }
}
