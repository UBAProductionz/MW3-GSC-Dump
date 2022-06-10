// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.juggSettings = [];
    level.juggSettings["juggernaut"] = spawnstruct();
    level.juggSettings["juggernaut"].splashUsedName = "used_juggernaut";
    level.juggSettings["juggernaut"].overlay = "goggles_overlay";
    level.juggSettings["juggernaut_recon"] = spawnstruct();
    level.juggSettings["juggernaut_recon"].splashUsedName = "used_juggernaut";
    level.juggSettings["juggernaut_recon"].overlay = "goggles_overlay";

    foreach ( var_1 in level.juggSettings )
        precacheshader( var_1.overlay );
}

giveJuggernaut( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    wait 0.05;

    if ( isdefined( self.hasLightArmor ) && self.hasLightArmor == 1 )
        maps\mp\perks\_perkfunctions::removeLightArmor( self.previousMaxHealth );

    if ( maps\mp\_utility::_hasPerk( "specialty_explosivebullets" ) )
        maps\mp\_utility::_unsetPerk( "specialty_explosivebullets" );

    self.health = self.maxHealth;

    switch ( var_0 )
    {
        case "juggernaut":
            self.isJuggernaut = 1;
            self.juggmovespeedscaler = 0.65;
            maps\mp\gametypes\_class::giveLoadout( self.pers["team"], var_0, 0, 0 );
            self.moveSpeedScaler = 0.65;
            break;
        case "juggernaut_recon":
            self.isJuggernautRecon = 1;
            self.juggmovespeedscaler = 0.75;
            maps\mp\gametypes\_class::giveLoadout( self.pers["team"], var_0, 0, 0 );
            self.moveSpeedScaler = 0.75;
            var_1 = spawn( "script_model", self.origin );
            var_1.team = self.team;
            var_1 makeportableradar( self );
            self.personalRadar = var_1;
            thread radarMover( var_1 );
            break;
    }

    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    self disableweaponpickup();

    if ( !getdvarint( "camera_thirdPerson" ) )
    {
        self.juggernautOverlay = newclienthudelem( self );
        self.juggernautOverlay.x = 0;
        self.juggernautOverlay.y = 0;
        self.juggernautOverlay.alignx = "left";
        self.juggernautOverlay.aligny = "top";
        self.juggernautOverlay.horzalign = "fullscreen";
        self.juggernautOverlay.vertalign = "fullscreen";
        self.juggernautOverlay setshader( level.juggSettings[var_0].overlay, 640, 480 );
        self.juggernautOverlay.sort = -10;
        self.juggernautOverlay.archived = 1;
        self.juggernautOverlay.hidein3rdperson = 1;
    }

    thread juggernautSounds();
    self setperk( "specialty_radarjuggernaut", 1, 0 );
    thread maps\mp\_utility::teamPlayerCardSplash( level.juggSettings[var_0].splashUsedName, self );

    if ( self.streakType == "specialist" )
        thread maps\mp\killstreaks\_killstreaks::clearKillstreaks();
    else
        thread maps\mp\killstreaks\_killstreaks::updateKillstreaks( 1 );

    thread juggRemover();

    if ( isdefined( self.carryFlag ) )
    {
        wait 0.05;
        self attach( self.carryFlag, "J_spine4", 1 );
    }

    level notify( "juggernaut_equipped",  self  );
    maps\mp\_matchdata::logKillstreakEvent( "juggernaut", self.origin );
}

juggernautSounds()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "jugg_removed" );

    for (;;)
    {
        wait 3.0;
        self playsound( "juggernaut_breathing_sound" );
    }
}

radarMover( var_0 )
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    self endon( "jugg_removed" );
    self endon( "jugdar_removed" );

    for (;;)
    {
        var_0 moveto( self.origin, 0.05 );
        wait 0.05;
    }
}

juggRemover()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    self endon( "jugg_removed" );
    thread juggRemoveOnGameEnded();
    thread juggRemoveRadarOnGameEnded();
    common_scripts\utility::waittill_any( "death", "joined_team", "joined_spectators", "lost_juggernaut" );
    self enableweaponpickup();
    self.isJuggernaut = 0;
    self.isJuggernautDef = 0;
    self.isJuggernautGL = 0;
    self.isJuggernautRecon = 0;

    if ( isdefined( self.juggernautOverlay ) )
        self.juggernautOverlay destroy();

    self unsetperk( "specialty_radarjuggernaut", 1 );

    if ( isdefined( self.personalRadar ) )
    {
        self notify( "jugdar_removed" );
        level maps\mp\gametypes\_portable_radar::deletePortableRadar( self.personalRadar );
        self.personalRadar = undefined;
    }

    self notify( "jugg_removed" );
}

juggRemoveOnGameEnded()
{
    self endon( "disconnect" );
    self endon( "jugg_removed" );
    level waittill( "game_ended" );

    if ( isdefined( self.juggernautOverlay ) )
        self.juggernautOverlay destroy();
}

juggRemoveRadarOnGameEnded()
{
    self endon( "jugg_removed" );
    level endon( "game_ended" );
    var_0 = self.personalRadar;
    self waittill( "disconnect" );

    if ( isdefined( var_0 ) )
        level maps\mp\gametypes\_portable_radar::deletePortableRadar( var_0 );
}
