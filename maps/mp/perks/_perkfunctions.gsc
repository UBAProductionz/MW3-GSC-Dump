// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

setOverkillPro()
{

}

unsetOverkillPro()
{

}

setEmpImmune()
{

}

unsetEmpImmune()
{

}

setAutoSpot()
{
    autoSpotAdsWatcher();
    autoSpotDeathWatcher();
}

autoSpotDeathWatcher()
{
    self waittill( "death" );
    self endon( "disconnect" );
    self endon( "endAutoSpotAdsWatcher" );
    level endon( "game_ended" );
    self autospotoverlayoff();
}

unsetAutoSpot()
{
    self notify( "endAutoSpotAdsWatcher" );
    self autospotoverlayoff();
}

autoSpotAdsWatcher()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "endAutoSpotAdsWatcher" );
    level endon( "game_ended" );
    var_0 = 0;

    for (;;)
    {
        wait 0.05;

        if ( self isusingturret() )
        {
            self autospotoverlayoff();
            continue;
        }

        var_1 = self playerads();

        if ( var_1 < 1 && var_0 )
        {
            var_0 = 0;
            self autospotoverlayoff();
        }

        if ( var_1 < 1 && !var_0 )
            continue;

        if ( var_1 == 1 && !var_0 )
        {
            var_0 = 1;
            self autospotoverlayon();
        }
    }
}

setRegenSpeed()
{

}

unsetRegenSpeed()
{

}

setHardShell()
{
    self.shellShockReduction = 0.25;
}

unsetHardShell()
{
    self.shellShockReduction = 0;
}

setSharpFocus()
{
    self setviewkickscale( 0.5 );
}

unsetSharpFocus()
{
    self setviewkickscale( 1 );
}

setDoubleLoad()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "endDoubleLoad" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "reload" );
        var_0 = self getweaponslist( "primary" );

        foreach ( var_2 in var_0 )
        {
            var_3 = self getweaponammoclip( var_2 );
            var_4 = weaponclipsize( var_2 );
            var_5 = var_4 - var_3;
            var_6 = self getweaponammostock( var_2 );

            if ( var_3 != var_4 && var_6 > 0 )
            {
                if ( var_3 + var_6 >= var_4 )
                {
                    self setweaponammoclip( var_2, var_4 );
                    self setweaponammostock( var_2, var_6 - var_5 );
                    continue;
                }

                self setweaponammoclip( var_2, var_3 + var_6 );

                if ( var_6 - var_5 > 0 )
                {
                    self setweaponammostock( var_2, var_6 - var_5 );
                    continue;
                }

                self setweaponammostock( var_2, 0 );
            }
        }
    }
}

unsetDoubleLoad()
{
    self notify( "endDoubleLoad" );
}

setMarksman()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    maps\mp\_utility::setRecoilScale( 10 );
    self.recoilScale = 10;
}

unsetMarksman()
{
    maps\mp\_utility::setRecoilScale( 0 );
    self.recoilScale = 0;
}

setStunResistance()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.stunScaler = 0.5;
}

unsetStunResistance()
{
    self.stunScaler = 1;
}

setSteadyAimPro()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self setaimspreadmovementscale( 0.5 );
}

unsetSteadyAimPro()
{
    self notify( "end_SteadyAimPro" );
    self setaimspreadmovementscale( 1.0 );
}

blastshieldUseTracker( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "end_perkUseTracker" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "empty_offhand" );

        if ( !common_scripts\utility::isOffhandWeaponEnabled() )
            continue;

        self [[ var_1 ]]( maps\mp\_utility::_hasPerk( "_specialty_blastshield" ) );
    }
}

perkUseDeathTracker()
{
    self endon( "disconnect" );
    self waittill( "death" );
    self._usePerkEnabled = undefined;
}

setRearView()
{

}

unsetRearView()
{
    self notify( "end_perkUseTracker" );
}

setEndGame()
{
    if ( isdefined( self.endGame ) )
        return;

    self.maxHealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" ) * 4;
    self.health = self.maxHealth;
    self.endGame = 1;
    self.attackerTable[0] = "";
    self visionsetnakedforplayer( "end_game", 5 );
    thread endGameDeath( 7 );
    maps\mp\gametypes\_gamelogic::sethasdonecombat( self, 1 );
}

unsetEndGame()
{
    self notify( "stopEndGame" );
    self.endGame = undefined;
    revertVisionSet();

    if ( !isdefined( self.endGameTimer ) )
        return;

    self.endGameTimer maps\mp\gametypes\_hud_util::destroyElem();
    self.endGameIcon maps\mp\gametypes\_hud_util::destroyElem();
}

revertVisionSet()
{
    if ( isdefined( level.nukeDetonated ) )
        self visionsetnakedforplayer( level.nukeVisionSet, 1 );
    else
        self visionsetnakedforplayer( "", 1 );
}

endGameDeath( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    level endon( "game_ended" );
    self endon( "stopEndGame" );
    wait(var_0 + 1);
    maps\mp\_utility::_suicide();
}

setSiege()
{
    thread trackSiegeEnable();
    thread trackSiegeDissable();
}

trackSiegeEnable()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "stop_trackSiege" );

    for (;;)
    {
        self waittill( "gambit_on" );
        self.moveSpeedScaler = 0;
        maps\mp\gametypes\_weapons::updateMoveSpeedScale();
        var_0 = weaponclass( self getcurrentweapon() );

        if ( var_0 == "pistol" || var_0 == "smg" )
            self setspreadoverride( 1 );
        else
            self setspreadoverride( 2 );

        self player_recoilscaleon( 0 );
        self allowjump( 0 );
    }
}

trackSiegeDissable()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "stop_trackSiege" );

    for (;;)
    {
        self waittill( "gambit_off" );
        unsetSiege();
    }
}

stanceStateListener()
{
    self endon( "death" );
    self endon( "disconnect" );
    self notifyonplayercommand( "adjustedStance", "+stance" );

    for (;;)
    {
        self waittill( "adjustedStance" );

        if ( self.moveSpeedScaler != 0 )
            continue;

        unsetSiege();
    }
}

jumpStateListener()
{
    self endon( "death" );
    self endon( "disconnect" );
    self notifyonplayercommand( "jumped", "+goStand" );

    for (;;)
    {
        self waittill( "jumped" );

        if ( self.moveSpeedScaler != 0 )
            continue;

        unsetSiege();
    }
}

unsetSiege()
{
    self.moveSpeedScaler = 1;
    self resetspreadoverride();
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    self player_recoilscaleoff();
    self allowjump( 1 );
}

setChallenger()
{
    if ( !level.hardcoreMode )
    {
        self.maxHealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" );

        if ( isdefined( self.xpScaler ) && self.xpScaler == 1 && self.maxHealth > 30 )
            self.xpScaler = 2;
    }
}

unsetChallenger()
{
    self.xpScaler = 1;
}

setSaboteur()
{
    self.objectiveScaler = 1.2;
}

unsetSaboteur()
{
    self.objectiveScaler = 1;
}

setLightWeight()
{
    self.moveSpeedScaler = maps\mp\_utility::lightWeightScalar();
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
}

unsetLightWeight()
{
    self.moveSpeedScaler = 1;
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
}

setBlackBox()
{
    self.killStreakScaler = 1.5;
}

unsetBlackBox()
{
    self.killStreakScaler = 1;
}

setSteelNerves()
{
    maps\mp\_utility::givePerk( "specialty_bulletaccuracy", 1 );
    maps\mp\_utility::givePerk( "specialty_holdbreath", 0 );
}

unsetSteelNerves()
{
    maps\mp\_utility::_unsetPerk( "specialty_bulletaccuracy" );
    maps\mp\_utility::_unsetPerk( "specialty_holdbreath" );
}

setDelayMine()
{

}

unsetDelayMine()
{

}

setBackShield()
{
    self attachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );
}

unsetBackShield()
{
    self detachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );
}

setLocalJammer()
{
    if ( !maps\mp\_utility::isEMPed() )
        self radarjamon();
}

unsetLocalJammer()
{
    self radarjamoff();
}

setAC130()
{
    thread killstreakThink( "ac130", 7, "end_ac130Think" );
}

unsetAC130()
{
    self notify( "end_ac130Think" );
}

setSentryMinigun()
{
    thread killstreakThink( "airdrop_sentry_minigun", 2, "end_sentry_minigunThink" );
}

unsetSentryMinigun()
{
    self notify( "end_sentry_minigunThink" );
}

setTank()
{
    thread killstreakThink( "tank", 6, "end_tankThink" );
}

unsetTank()
{
    self notify( "end_tankThink" );
}

setPrecision_airstrike()
{
    thread killstreakThink( "precision_airstrike", 6, "end_precision_airstrike" );
}

unsetPrecision_airstrike()
{
    self notify( "end_precision_airstrike" );
}

setPredatorMissile()
{
    thread killstreakThink( "predator_missile", 4, "end_predator_missileThink" );
}

unsetPredatorMissile()
{
    self notify( "end_predator_missileThink" );
}

setHelicopterMinigun()
{
    thread killstreakThink( "helicopter_minigun", 5, "end_helicopter_minigunThink" );
}

unsetHelicopterMinigun()
{
    self notify( "end_helicopter_minigunThink" );
}

killstreakThink( var_0, var_1, var_2 )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( var_2 );

    for (;;)
    {
        self waittill( "killed_enemy" );

        if ( self.pers["cur_kill_streak"] != var_1 )
            continue;

        thread maps\mp\killstreaks\_killstreaks::giveKillstreak( var_0 );
        thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( var_0, var_1 );
        return;
    }
}

setThermal()
{
    self thermalvisionon();
}

unsetThermal()
{
    self thermalvisionoff();
}

setOneManArmy()
{
    thread oneManArmyWeaponChangeTracker();
}

unsetOneManArmy()
{
    self notify( "stop_oneManArmyTracker" );
}

oneManArmyWeaponChangeTracker()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "stop_oneManArmyTracker" );

    for (;;)
    {
        self waittill( "weapon_change",  var_0  );

        if ( var_0 != "onemanarmy_mp" )
            continue;

        thread selectOneManArmyClass();
    }
}

isOneManArmyMenu( var_0 )
{
    if ( var_0 == game["menu_onemanarmy"] )
        return 1;

    if ( isdefined( game["menu_onemanarmy_defaults_splitscreen"] ) && var_0 == game["menu_onemanarmy_defaults_splitscreen"] )
        return 1;

    if ( isdefined( game["menu_onemanarmy_custom_splitscreen"] ) && var_0 == game["menu_onemanarmy_custom_splitscreen"] )
        return 1;

    return 0;
}

selectOneManArmyClass()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    common_scripts\utility::_disableWeaponSwitch();
    common_scripts\utility::_disableOffhandWeapons();
    common_scripts\utility::_disableUsability();
    self openpopupmenu( game["menu_onemanarmy"] );
    thread closeOMAMenuOnDeath();
    self waittill( "menuresponse",  var_0, var_1  );
    common_scripts\utility::_enableWeaponSwitch();
    common_scripts\utility::_enableOffhandWeapons();
    common_scripts\utility::_enableUsability();

    if ( var_1 == "back" || !isOneManArmyMenu( var_0 ) || maps\mp\_utility::isUsingRemote() )
    {
        if ( self getcurrentweapon() == "onemanarmy_mp" )
        {
            common_scripts\utility::_disableWeaponSwitch();
            common_scripts\utility::_disableOffhandWeapons();
            common_scripts\utility::_disableUsability();
            self switchtoweapon( common_scripts\utility::getLastWeapon() );
            self waittill( "weapon_change" );
            common_scripts\utility::_enableWeaponSwitch();
            common_scripts\utility::_enableOffhandWeapons();
            common_scripts\utility::_enableUsability();
        }

        return;
    }

    thread giveOneManArmyClass( var_1 );
}

closeOMAMenuOnDeath()
{
    self endon( "menuresponse" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "death" );
    common_scripts\utility::_enableWeaponSwitch();
    common_scripts\utility::_enableOffhandWeapons();
    common_scripts\utility::_enableUsability();
    self closepopupmenu();
}

giveOneManArmyClass( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    if ( maps\mp\_utility::_hasPerk( "specialty_omaquickchange" ) )
    {
        var_1 = 3.0;
        self playlocalsound( "foly_onemanarmy_bag3_plr" );
        self playsoundtoteam( "foly_onemanarmy_bag3_npc", "allies", self );
        self playsoundtoteam( "foly_onemanarmy_bag3_npc", "axis", self );
    }
    else
    {
        var_1 = 6.0;
        self playlocalsound( "foly_onemanarmy_bag6_plr" );
        self playsoundtoteam( "foly_onemanarmy_bag6_npc", "allies", self );
        self playsoundtoteam( "foly_onemanarmy_bag6_npc", "axis", self );
    }

    thread omaUseBar( var_1 );
    common_scripts\utility::_disableWeapon();
    common_scripts\utility::_disableOffhandWeapons();
    common_scripts\utility::_disableUsability();
    wait(var_1);
    common_scripts\utility::_enableWeapon();
    common_scripts\utility::_enableOffhandWeapons();
    common_scripts\utility::_enableUsability();
    self.omaClassChanged = 1;
    maps\mp\gametypes\_class::giveLoadout( self.pers["team"], var_0, 0 );

    if ( isdefined( self.carryFlag ) )
        self attach( self.carryFlag, "J_spine4", 1 );

    self notify( "changed_kit" );
    level notify( "changed_kit" );
}

omaUseBar( var_0 )
{
    self endon( "disconnect" );
    var_1 = maps\mp\gametypes\_hud_util::createPrimaryProgressBar( 0, -25 );
    var_2 = maps\mp\gametypes\_hud_util::createPrimaryProgressBarText( 0, -25 );
    var_2 settext( &"MPUI_CHANGING_KIT" );
    var_1 maps\mp\gametypes\_hud_util::updateBar( 0, 1 / var_0 );

    for ( var_3 = 0; var_3 < var_0 && isalive( self ) && !level.gameEnded; var_3 += 0.05 )
        wait 0.05;

    var_1 maps\mp\gametypes\_hud_util::destroyElem();
    var_2 maps\mp\gametypes\_hud_util::destroyElem();
}

setBlastShield()
{
    self setweaponhudiconoverride( "primaryoffhand", "specialty_blastshield" );
}

unsetBlastShield()
{
    self setweaponhudiconoverride( "primaryoffhand", "none" );
}

setFreefall()
{

}

unsetFreefall()
{

}

setTacticalInsertion()
{
    self setoffhandsecondaryclass( "flash" );
    maps\mp\_utility::_giveWeapon( "flare_mp", 0 );
    self givestartammo( "flare_mp" );
    thread monitorTIUse();
}

unsetTacticalInsertion()
{
    self notify( "end_monitorTIUse" );
}

clearPreviousTISpawnpoint()
{
    common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );

    if ( isdefined( self.setSpawnpoint ) )
        deleteTI( self.setSpawnpoint );
}

updateTISpawnPosition()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "end_monitorTIUse" );

    while ( maps\mp\_utility::isReallyAlive( self ) )
    {
        if ( isValidTISpawnPosition() )
            self.TISpawnPosition = self.origin;

        wait 0.05;
    }
}

isValidTISpawnPosition()
{
    if ( canspawn( self.origin ) && self isonground() )
        return 1;
    else
        return 0;
}

monitorTIUse()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "end_monitorTIUse" );
    thread updateTISpawnPosition();
    thread clearPreviousTISpawnpoint();

    for (;;)
    {
        self waittill( "grenade_fire",  var_0, var_1  );

        if ( var_1 != "flare_mp" )
            continue;

        if ( isdefined( self.setSpawnpoint ) )
            deleteTI( self.setSpawnpoint );

        if ( !isdefined( self.TISpawnPosition ) )
            continue;

        if ( maps\mp\_utility::touchingBadTrigger() )
            continue;

        var_2 = playerphysicstrace( self.TISpawnPosition + ( 0, 0, 16 ), self.TISpawnPosition - ( 0, 0, 2048 ) ) + ( 0, 0, 1 );
        var_3 = spawn( "script_model", var_2 );
        var_3.angles = self.angles;
        var_3.team = self.team;
        var_3.owner = self;
        var_3.enemyTrigger = spawn( "script_origin", var_2 );
        var_3 thread GlowStickSetupAndWaitForDeath( self );
        var_3.playerSpawnPos = self.TISpawnPosition;
        var_3 thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_light_stick_tactical_bombsquad", "tag_fire_fx", level.otherTeam[self.team], self );
        self.setSpawnpoint = var_3;
        return;
    }
}

GlowStickSetupAndWaitForDeath( var_0 )
{
    self setmodel( level.precacheModel["enemy"] );

    if ( level.teamBased )
        maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( 0, 0, 20 ) );
    else
        maps\mp\_entityheadicons::setPlayerHeadIcon( var_0, ( 0, 0, 20 ) );

    thread GlowStickDamageListener( var_0 );
    thread GlowStickEnemyUseListener( var_0 );
    thread GlowStickUseListener( var_0 );
    thread GlowStickTeamUpdater( level.otherTeam[self.team], level.spawnGlow["enemy"], var_0 );
    var_1 = spawn( "script_model", self.origin + ( 0, 0, 0 ) );
    var_1.angles = self.angles;
    var_1 setmodel( level.precacheModel["friendly"] );
    var_1 setcontents( 0 );
    var_1 thread GlowStickTeamUpdater( self.team, level.spawnGlow["friendly"], var_0 );
    var_1 playloopsound( "emt_road_flare_burn" );
    self waittill( "death" );
    var_1 stoploopsound();
    var_1 delete();
}

GlowStickTeamUpdater( var_0, var_1, var_2 )
{
    self endon( "death" );
    wait 0.05;
    var_3 = self gettagangles( "tag_fire_fx" );
    var_4 = spawnfx( var_1, self gettagorigin( "tag_fire_fx" ), anglestoforward( var_3 ), anglestoup( var_3 ) );
    triggerfx( var_4 );
    thread deleteOnDeath( var_4 );

    for (;;)
    {
        self hide();
        var_4 hide();

        foreach ( var_6 in level.players )
        {
            if ( var_6.team == var_0 && level.teamBased )
            {
                self showtoplayer( var_6 );
                var_4 showtoplayer( var_6 );
                continue;
            }

            if ( !level.teamBased && var_6 == var_2 && var_1 == level.spawnGlow["friendly"] )
            {
                self showtoplayer( var_6 );
                var_4 showtoplayer( var_6 );
                continue;
            }

            if ( !level.teamBased && var_6 != var_2 && var_1 == level.spawnGlow["enemy"] )
            {
                self showtoplayer( var_6 );
                var_4 showtoplayer( var_6 );
            }
        }

        level common_scripts\utility::waittill_either( "joined_team", "player_spawned" );
    }
}

deleteOnDeath( var_0 )
{
    self waittill( "death" );

    if ( isdefined( var_0 ) )
        var_0 delete();
}

GlowStickDamageListener( var_0 )
{
    self endon( "death" );
    self setcandamage( 1 );
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
            var_2 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "tactical_insertion" );

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isdefined( var_0 ) && var_2 != var_0 )
            {
                var_2 notify( "destroyed_insertion",  var_0  );
                var_2 notify( "destroyed_explosive" );
                var_0 thread maps\mp\_utility::leaderDialogOnPlayer( "ti_destroyed" );
            }

            var_2 thread deleteTI( self );
        }
    }
}

GlowStickUseListener( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( &"MP_PATCH_PICKUP_TI" );
    thread updateEnemyUse( var_0 );

    for (;;)
    {
        self waittill( "trigger",  var_1  );
        var_1 playsound( "chemlight_pu" );

        if ( !var_1 maps\mp\_utility::isJuggernaut() )
            var_1 thread setTacticalInsertion();

        var_1 thread deleteTI( self );
    }
}

updateEnemyUse( var_0 )
{
    self endon( "death" );

    for (;;)
    {
        maps\mp\_utility::setSelfUsable( var_0 );
        level common_scripts\utility::waittill_either( "joined_team", "player_spawned" );
    }
}

deleteTI( var_0 )
{
    if ( isdefined( var_0.enemyTrigger ) )
        var_0.enemyTrigger delete();

    var_1 = var_0.origin;
    var_2 = var_0.angles;
    var_0 delete();
    var_3 = spawn( "script_model", var_1 );
    var_3.angles = var_2;
    var_3 setmodel( level.precacheModel["friendly"] );
    var_3 setcontents( 0 );
    thread dummyGlowStickDelete( var_3 );
}

dummyGlowStickDelete( var_0 )
{
    wait 2.5;
    var_0 delete();
}

GlowStickEnemyUseListener( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    self.enemyTrigger setcursorhint( "HINT_NOICON" );
    self.enemyTrigger sethintstring( &"MP_PATCH_DESTROY_TI" );
    self.enemyTrigger maps\mp\_utility::makeEnemyUsable( var_0 );

    for (;;)
    {
        self.enemyTrigger waittill( "trigger",  var_1  );
        var_1 notify( "destroyed_insertion",  var_0  );
        var_1 notify( "destroyed_explosive" );

        if ( isdefined( var_0 ) && var_1 != var_0 )
            var_0 thread maps\mp\_utility::leaderDialogOnPlayer( "ti_destroyed" );

        var_1 thread deleteTI( self );
    }
}

setLittlebirdSupport()
{
    thread killstreakThink( "littlebird_support", 2, "end_littlebird_support_think" );
}

unsetLittlebirdSupport()
{
    self notify( "end_littlebird_support_think" );
}

setPainted()
{
    if ( isplayer( self ) )
    {
        var_0 = 10.0;

        if ( maps\mp\_utility::_hasPerk( "specialty_quieter" ) )
            var_0 *= 0.5;

        self.painted = 1;
        self setperk( "specialty_radararrow", 1, 0 );
        thread unsetPainted( var_0 );
        thread watchPaintedDeath();
    }
}

watchPaintedDeath()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "death" );
    self.painted = 0;
}

unsetPainted( var_0 )
{
    self notify( "painted_again" );
    self endon( "painted_again" );
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    wait(var_0);
    self.painted = 0;
    self unsetperk( "specialty_radararrow", 1 );
}

isPainted()
{
    return isdefined( self.painted ) && self.painted;
}

setFinalStand()
{
    maps\mp\_utility::givePerk( "specialty_pistoldeath", 0 );
}

unsetFinalStand()
{
    maps\mp\_utility::_unsetPerk( "specialty_pistoldeath" );
}

setCarePackage()
{
    thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop_assault", 0, 0, self, 1 );
}

unsetCarePackage()
{

}

setUAV()
{
    thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "uav", 0, 0, self, 1 );
}

unsetUAV()
{

}

setStoppingPower()
{
    maps\mp\_utility::givePerk( "specialty_bulletdamage", 0 );
    thread watchStoppingPowerKill();
}

watchStoppingPowerKill()
{
    self notify( "watchStoppingPowerKill" );
    self endon( "watchStoppingPowerKill" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "killed_enemy" );
    unsetStoppingPower();
}

unsetStoppingPower()
{
    maps\mp\_utility::_unsetPerk( "specialty_bulletdamage" );
    self notify( "watchStoppingPowerKill" );
}

setC4Death()
{
    if ( !maps\mp\_utility::_hasPerk( "specialty_pistoldeath" ) )
        maps\mp\_utility::givePerk( "specialty_pistoldeath", 0 );
}

unsetC4Death()
{
    if ( maps\mp\_utility::_hasPerk( "specialty_pistoldeath" ) )
        maps\mp\_utility::_unsetPerk( "specialty_pistoldeath" );
}

setJuiced()
{
    self endon( "death" );
    self endon( "faux_spawn" );
    self endon( "disconnect" );
    self endon( "unset_juiced" );
    level endon( "end_game" );
    self.isjuiced = 1;
    self.moveSpeedScaler = 1.25;
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();

    if ( level.splitscreen )
    {
        var_0 = 56;
        var_1 = 21;
    }
    else
    {
        var_0 = 80;
        var_1 = 32;
    }

    self.juicedTimer = maps\mp\gametypes\_hud_util::createTimer( "hudsmall", 1.0 );
    self.juicedTimer maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, var_0 );
    self.juicedTimer settimer( 7.0 );
    self.juicedTimer.color = ( 0.8, 0.8, 0 );
    self.juicedTimer.archived = 0;
    self.juicedTimer.foreground = 1;
    self.juicedIcon = maps\mp\gametypes\_hud_util::createIcon( "specialty_juiced", var_1, var_1 );
    self.juicedIcon.alpha = 0;
    self.juicedIcon maps\mp\gametypes\_hud_util::setParent( self.juicedTimer );
    self.juicedIcon maps\mp\gametypes\_hud_util::setPoint( "BOTTOM", "TOP" );
    self.juicedIcon.archived = 1;
    self.juicedIcon.sort = 1;
    self.juicedIcon.foreground = 1;
    self.juicedIcon fadeovertime( 1.0 );
    self.juicedIcon.alpha = 0.85;
    thread unsetJuicedOnDeath();
    thread unsetJuicedOnRide();
    wait 5;

    if ( isdefined( self.juicedIcon ) )
    {
        self.juicedIcon fadeovertime( 2.0 );
        self.juicedIcon.alpha = 0.0;
    }

    if ( isdefined( self.juicedTimer ) )
    {
        self.juicedTimer fadeovertime( 2.0 );
        self.juicedTimer.alpha = 0.0;
    }

    wait 2;
    unsetJuiced();
}

unsetJuiced( var_0 )
{
    if ( !isdefined( var_0 ) )
    {
        if ( maps\mp\_utility::isJuggernaut() )
        {
            if ( isdefined( self.juggmovespeedscaler ) )
                self.moveSpeedScaler = self.juggmovespeedscaler;
            else
                self.moveSpeedScaler = 0.7;
        }
        else
        {
            self.moveSpeedScaler = 1;

            if ( maps\mp\_utility::_hasPerk( "specialty_lightweight" ) )
                self.moveSpeedScaler = maps\mp\_utility::lightWeightScalar();
        }

        maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    }

    if ( isdefined( self.juicedIcon ) )
        self.juicedIcon destroy();

    if ( isdefined( self.juicedTimer ) )
        self.juicedTimer destroy();

    self.isjuiced = undefined;
    self notify( "unset_juiced" );
}

unsetJuicedOnRide()
{
    self endon( "disconnect" );
    self endon( "unset_juiced" );

    for (;;)
    {
        wait 0.05;

        if ( maps\mp\_utility::isUsingRemote() )
        {
            thread unsetJuiced();
            break;
        }
    }
}

unsetJuicedOnDeath()
{
    self endon( "disconnect" );
    self endon( "unset_juiced" );
    common_scripts\utility::waittill_any( "death", "faux_spawn" );
    thread unsetJuiced( 1 );
}

setCombatHigh()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "unset_combathigh" );
    level endon( "end_game" );
    self.damageBlockedTotal = 0;

    if ( level.splitscreen )
    {
        var_0 = 56;
        var_1 = 21;
    }
    else
    {
        var_0 = 112;
        var_1 = 32;
    }

    if ( isdefined( self.juicedTimer ) )
        self.juicedTimer destroy();

    if ( isdefined( self.juicedIcon ) )
        self.juicedIcon destroy();

    self.combatHighOverlay = newclienthudelem( self );
    self.combatHighOverlay.x = 0;
    self.combatHighOverlay.y = 0;
    self.combatHighOverlay.alignx = "left";
    self.combatHighOverlay.aligny = "top";
    self.combatHighOverlay.horzalign = "fullscreen";
    self.combatHighOverlay.vertalign = "fullscreen";
    self.combatHighOverlay setshader( "combathigh_overlay", 640, 480 );
    self.combatHighOverlay.sort = -10;
    self.combatHighOverlay.archived = 1;
    self.combatHighTimer = maps\mp\gametypes\_hud_util::createTimer( "hudsmall", 1.0 );
    self.combatHighTimer maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, var_0 );
    self.combatHighTimer settimer( 10.0 );
    self.combatHighTimer.color = ( 0.8, 0.8, 0 );
    self.combatHighTimer.archived = 0;
    self.combatHighTimer.foreground = 1;
    self.combatHighIcon = maps\mp\gametypes\_hud_util::createIcon( "specialty_painkiller", var_1, var_1 );
    self.combatHighIcon.alpha = 0;
    self.combatHighIcon maps\mp\gametypes\_hud_util::setParent( self.combatHighTimer );
    self.combatHighIcon maps\mp\gametypes\_hud_util::setPoint( "BOTTOM", "TOP" );
    self.combatHighIcon.archived = 1;
    self.combatHighIcon.sort = 1;
    self.combatHighIcon.foreground = 1;
    self.combatHighOverlay.alpha = 0.0;
    self.combatHighOverlay fadeovertime( 1.0 );
    self.combatHighIcon fadeovertime( 1.0 );
    self.combatHighOverlay.alpha = 1.0;
    self.combatHighIcon.alpha = 0.85;
    thread unsetCombatHighOnDeath();
    thread unsetCombatHighOnRide();
    wait 8;
    self.combatHighIcon fadeovertime( 2.0 );
    self.combatHighIcon.alpha = 0.0;
    self.combatHighOverlay fadeovertime( 2.0 );
    self.combatHighOverlay.alpha = 0.0;
    self.combatHighTimer fadeovertime( 2.0 );
    self.combatHighTimer.alpha = 0.0;
    wait 2;
    self.damageBlockedTotal = undefined;
    maps\mp\_utility::_unsetPerk( "specialty_combathigh" );
}

unsetCombatHighOnDeath()
{
    self endon( "disconnect" );
    self endon( "unset_combathigh" );
    self waittill( "death" );
    thread maps\mp\_utility::_unsetPerk( "specialty_combathigh" );
}

unsetCombatHighOnRide()
{
    self endon( "disconnect" );
    self endon( "unset_combathigh" );

    for (;;)
    {
        wait 0.05;

        if ( maps\mp\_utility::isUsingRemote() )
        {
            thread maps\mp\_utility::_unsetPerk( "specialty_combathigh" );
            break;
        }
    }
}

unsetCombatHigh()
{
    self notify( "unset_combathigh" );
    self.combatHighOverlay destroy();
    self.combatHighIcon destroy();
    self.combatHighTimer destroy();
}

setLightArmor()
{
    thread giveLightArmor();
}

giveLightArmor()
{
    self notify( "give_light_armor" );
    self endon( "give_light_armor" );
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "end_game" );

    if ( isdefined( self.hasLightArmor ) && self.hasLightArmor == 1 )
        removeLightArmor( self.previousMaxHealth );

    var_0 = 200;
    thread removeLightArmorOnDeath();
    self.hasLightArmor = 1;
    self.combatHighOverlay = newclienthudelem( self );
    self.combatHighOverlay.x = 0;
    self.combatHighOverlay.y = 0;
    self.combatHighOverlay.alignx = "left";
    self.combatHighOverlay.aligny = "top";
    self.combatHighOverlay.horzalign = "fullscreen";
    self.combatHighOverlay.vertalign = "fullscreen";
    self.combatHighOverlay setshader( "combathigh_overlay", 640, 480 );
    self.combatHighOverlay.sort = -10;
    self.combatHighOverlay.archived = 1;
    self.previousMaxHealth = self.maxHealth;
    self.maxHealth = var_0;
    self.health = self.maxHealth;
    var_1 = 50;
    var_2 = self.health;

    for (;;)
    {
        if ( self.maxHealth != var_0 )
        {
            removeLightArmor();
            break;
        }

        if ( self.health < 100 )
        {
            removeLightArmor( self.previousMaxHealth );
            break;
        }

        if ( self.health < var_2 )
        {
            var_1 -= ( var_2 - self.health );
            var_2 = self.health;

            if ( var_1 <= 0 )
            {
                removeLightArmor( self.previousMaxHealth );
                break;
            }
        }

        wait 0.5;
    }
}

removeLightArmorOnDeath()
{
    self endon( "disconnect" );
    self endon( "give_light_armor" );
    self endon( "remove_light_armor" );
    self waittill( "death" );
    removeLightArmor();
}

removeLightArmor( var_0 )
{
    if ( isdefined( var_0 ) )
        self.maxHealth = var_0;

    if ( isdefined( self.combatHighOverlay ) )
        self.combatHighOverlay destroy();

    self.hasLightArmor = undefined;
    self notify( "remove_light_armor" );
}

unsetLightArmor()
{
    thread removeLightArmor( self.previousMaxHealth );
}

setRevenge()
{
    self notify( "stopRevenge" );
    wait 0.05;

    if ( !isdefined( self.lastKilledBy ) )
        return;

    if ( level.teamBased && self.team == self.lastKilledBy.team )
        return;

    var_0 = spawnstruct();
    var_0.showTo = self;
    var_0.icon = "compassping_revenge";
    var_0.offset = ( 0, 0, 64 );
    var_0.width = 10;
    var_0.height = 10;
    var_0.archived = 0;
    var_0.delay = 1.5;
    var_0.constantSize = 0;
    var_0.pinToScreenEdge = 1;
    var_0.fadeOutPinnedIcon = 0;
    var_0.is3D = 0;
    self.revengeParams = var_0;
    self.lastKilledBy maps\mp\_entityheadicons::setHeadIcon( var_0.showTo, var_0.icon, var_0.offset, var_0.width, var_0.height, var_0.archived, var_0.delay, var_0.constantSize, var_0.pinToScreenEdge, var_0.fadeOutPinnedIcon, var_0.is3D );
    thread watchRevengeDeath();
    thread watchRevengeKill();
    thread watchRevengeDisconnected();
    thread watchRevengeVictimDisconnected();
    thread watchStopRevenge();
}

watchRevengeDeath()
{
    self endon( "stopRevenge" );
    self endon( "disconnect" );
    var_0 = self.lastKilledBy;

    for (;;)
    {
        var_0 waittill( "spawned_player" );
        var_0 maps\mp\_entityheadicons::setHeadIcon( self.revengeParams.showTo, self.revengeParams.icon, self.revengeParams.offset, self.revengeParams.width, self.revengeParams.height, self.revengeParams.archived, self.revengeParams.delay, self.revengeParams.constantSize, self.revengeParams.pinToScreenEdge, self.revengeParams.fadeOutPinnedIcon, self.revengeParams.is3D );
    }
}

watchRevengeKill()
{
    self endon( "stopRevenge" );
    self waittill( "killed_enemy" );
    self notify( "stopRevenge" );
}

watchRevengeDisconnected()
{
    self endon( "stopRevenge" );
    self.lastKilledBy waittill( "disconnect" );
    self notify( "stopRevenge" );
}

watchStopRevenge()
{
    var_0 = self.lastKilledBy;
    self waittill( "stopRevenge" );

    if ( !isdefined( var_0 ) )
        return;

    foreach ( var_3, var_2 in var_0.entityHeadIcons )
    {
        if ( !isdefined( var_2 ) )
            continue;

        var_2 destroy();
    }
}

watchRevengeVictimDisconnected()
{
    var_0 = self.objIdFriendly;
    var_1 = self.lastKilledBy;
    var_1 endon( "disconnect" );
    level endon( "game_ended" );
    self endon( "stopRevenge" );
    self waittill( "disconnect" );

    if ( !isdefined( var_1 ) )
        return;

    foreach ( var_4, var_3 in var_1.entityHeadIcons )
    {
        if ( !isdefined( var_3 ) )
            continue;

        var_3 destroy();
    }
}

unsetRevenge()
{
    self notify( "stopRevenge" );
}
