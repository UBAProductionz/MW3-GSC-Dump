// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.killstreakFuncs["deployable_vest"] = ::tryUseDeployableVest;
    level.boxSettings = [];
    level.boxSettings["deployable_vest"] = spawnstruct();
    level.boxSettings["deployable_vest"].weaponinfo = "deployable_vest_marker_mp";
    level.boxSettings["deployable_vest"].modelBase = "com_deploy_ballistic_vest_friend_world";
    level.boxSettings["deployable_vest"].hintstring = &"MP_LIGHT_ARMOR_PICKUP";
    level.boxSettings["deployable_vest"].capturingString = &"MP_BOX_GETTING_VEST";
    level.boxSettings["deployable_vest"].eventString = &"MP_DEPLOYED_VEST";
    level.boxSettings["deployable_vest"].streakName = "deployable_vest";
    level.boxSettings["deployable_vest"].splashName = "used_deployable_vest";
    level.boxSettings["deployable_vest"].shaderName = "compass_objpoint_deploy_friendly";
    level.boxSettings["deployable_vest"].lifeSpan = 60.0;
    level.boxSettings["deployable_vest"].xp = 50;
    level.boxSettings["deployable_vest"].voDestroyed = "ballistic_vest_destroyed";

    foreach ( var_1 in level.boxSettings )
    {
        precacheitem( var_1.weaponinfo );
        precachemodel( var_1.modelBase );
        precachestring( var_1.hintstring );
        precachestring( var_1.capturingString );
        precachestring( var_1.eventString );
        precacheshader( var_1.shaderName );
    }

    precachestring( &"PLATFORM_HOLD_TO_USE" );
    level._effect["box_explode_mp"] = loadfx( "fire/ballistic_vest_death" );
}

tryUseDeployableVest( var_0 )
{
    self.isCarrying = 1;
    var_1 = beginDeployableViaMarker( var_0, "deployable_vest" );
    self.isCarrying = 0;

    if ( !isdefined( var_1 ) || !var_1 )
        return 0;

    maps\mp\_matchdata::logKillstreakEvent( "deployable_vest", self.origin );
    return 1;
}

beginDeployableViaMarker( var_0, var_1 )
{
    self endon( "death" );
    self.marker = undefined;
    thread watchMarkerUsage( var_0, var_1 );
    var_2 = self getcurrentweapon();

    if ( isMarker( var_2 ) )
        var_3 = var_2;
    else
        var_3 = undefined;

    while ( isMarker( var_2 ) )
    {
        self waittill( "weapon_change",  var_2  );

        if ( isMarker( var_2 ) )
            var_3 = var_2;
    }

    self notify( "stopWatchingMarker" );

    if ( !isdefined( var_3 ) )
        return 0;

    return !( self getammocount( var_3 ) && self hasweapon( var_3 ) );
}

watchMarkerUsage( var_0, var_1 )
{
    self notify( "watchMarkerUsage" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "watchMarkerUsage" );
    self endon( "stopWatchingMarker" );
    thread watchMarker( var_0, var_1 );

    for (;;)
    {
        self waittill( "grenade_pullback",  var_2  );

        if ( !isMarker( var_2 ) )
            continue;

        common_scripts\utility::_disableUsability();
        beginMarkerTracking();
    }
}

watchMarker( var_0, var_1 )
{
    self notify( "watchMarker" );
    self endon( "watchMarker" );
    self endon( "spawned_player" );
    self endon( "disconnect" );
    self endon( "stopWatchingMarker" );

    for (;;)
    {
        self waittill( "grenade_fire",  var_2, var_3  );

        if ( !isMarker( var_3 ) )
            continue;

        if ( !isalive( self ) )
        {
            var_2 delete();
            return;
        }

        var_2.owner = self;
        var_2.weaponName = var_3;
        self.marker = var_2;
        thread takeWeaponOnStuck( var_2, var_3 );
        var_2 thread markerActivate( var_0, var_1, ::box_setActive );
    }
}

takeWeaponOnStuck( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 playsoundtoplayer( "mp_vest_deployed_ui", self );

    if ( self hasweapon( var_1 ) )
    {
        self takeweapon( var_1 );
        self switchtoweapon( common_scripts\utility::getLastWeapon() );
    }
}

beginMarkerTracking()
{
    self notify( "beginMarkerTracking" );
    self endon( "beginMarkerTracking" );
    self endon( "death" );
    self endon( "disconnect" );
    common_scripts\utility::waittill_any( "grenade_fire", "weapon_change" );
    common_scripts\utility::_enableUsability();
}

markerActivate( var_0, var_1, var_2 )
{
    self notify( "markerActivate" );
    self endon( "markerActivate" );
    self waittill( "missile_stuck" );
    var_3 = self.owner;
    var_4 = self.origin;

    if ( !isdefined( var_3 ) )
        return;

    var_5 = createBoxForPlayer( var_1, var_4, var_3 );
    wait 0.05;
    var_5 thread [[ var_2 ]]();
    self delete();
}

isMarker( var_0 )
{
    switch ( var_0 )
    {
        case "deployable_vest_marker_mp":
            return 1;
        default:
            return 0;
    }
}

createBoxForPlayer( var_0, var_1, var_2 )
{
    var_3 = spawn( "script_model", var_1 );
    var_3 setmodel( level.boxSettings[var_0].modelBase );
    var_3.health = 1000;
    var_3.angles = var_2.angles;
    var_3.boxType = var_0;
    var_3.owner = var_2;
    var_3.team = var_2.team;
    var_3 box_setInactive();
    var_3 thread box_handleOwnerDisconnect();
    return var_3;
}

box_setActive()
{
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( level.boxSettings[self.boxType].hintstring );
    self.inUse = 0;

    if ( level.teamBased )
    {
        var_0 = maps\mp\gametypes\_gameobjects::getNextObjID();
        objective_add( var_0, "invisible", ( 0, 0, 0 ) );
        objective_position( var_0, self.origin );
        objective_state( var_0, "active" );
        objective_icon( var_0, level.boxSettings[self.boxType].shaderName );
        objective_team( var_0, self.team );
        self.objIdFriendly = var_0;

        foreach ( var_2 in level.players )
        {
            if ( self.team == var_2.team && !var_2 maps\mp\_utility::isJuggernaut() )
                maps\mp\_entityheadicons::setHeadIcon( var_2, maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( level.boxSettings[self.boxType].streakName ), ( 0, 0, 20 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
        }
    }
    else
    {
        var_0 = maps\mp\gametypes\_gameobjects::getNextObjID();
        objective_add( var_0, "invisible", ( 0, 0, 0 ) );
        objective_position( var_0, self.origin );
        objective_state( var_0, "active" );
        objective_icon( var_0, level.boxSettings[self.boxType].shaderName );
        objective_player( var_0, self.owner getentitynumber() );
        self.objIdFriendly = var_0;

        if ( !self.owner maps\mp\_utility::isJuggernaut() )
            maps\mp\_entityheadicons::setHeadIcon( self.owner, maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( level.boxSettings[self.boxType].streakName ), ( 0, 0, 20 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
    }

    self makeusable();
    self.isUsable = 1;
    self setcandamage( 1 );
    thread box_handleDamage();
    thread box_handleDeath();
    thread box_timeOut();
    thread disableWhenJuggernaut();

    foreach ( var_2 in level.players )
    {
        if ( level.teamBased )
        {
            if ( self.team == var_2.team )
            {
                if ( var_2 maps\mp\_utility::isJuggernaut() )
                {
                    self disableplayeruse( var_2 );
                    thread doubleDip( var_2 );
                }
                else
                    self enableplayeruse( var_2 );

                thread boxThink( var_2 );
            }
            else
                self disableplayeruse( var_2 );

            thread box_playerJoinedTeam( var_2 );
            continue;
        }

        if ( isdefined( self.owner ) && self.owner == var_2 )
        {
            if ( var_2 maps\mp\_utility::isJuggernaut() )
            {
                self disableplayeruse( var_2 );
                thread doubleDip( var_2 );
            }
            else
                self enableplayeruse( var_2 );

            thread boxThink( var_2 );
            continue;
        }

        self disableplayeruse( var_2 );
    }

    level thread maps\mp\_utility::teamPlayerCardSplash( level.boxSettings[self.boxType].splashName, self.owner, self.team );
    thread box_playerConnected();
}

box_playerConnected()
{
    self endon( "death" );
    level waittill( "connected",  var_0  );
    var_0 waittill( "spawned_player" );

    if ( level.teamBased )
    {
        if ( self.team == var_0.team )
        {
            self enableplayeruse( var_0 );
            thread boxThink( var_0 );
            maps\mp\_entityheadicons::setHeadIcon( var_0, maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( level.boxSettings[self.boxType].streakName ), ( 0, 0, 20 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
        }
        else
        {
            self disableplayeruse( var_0 );
            maps\mp\_entityheadicons::setHeadIcon( var_0, "", ( 0, 0, 0 ) );
        }
    }
}

box_playerJoinedTeam( var_0 )
{
    self endon( "death" );
    var_0 endon( "disconnect" );

    for (;;)
    {
        var_0 waittill( "joined_team" );

        if ( level.teamBased )
        {
            if ( self.team == var_0.team )
            {
                self enableplayeruse( var_0 );
                thread boxThink( var_0 );
                maps\mp\_entityheadicons::setHeadIcon( var_0, maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( level.boxSettings[self.boxType].streakName ), ( 0, 0, 20 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
                continue;
            }

            self disableplayeruse( var_0 );
            maps\mp\_entityheadicons::setHeadIcon( var_0, "", ( 0, 0, 0 ) );
        }
    }
}

box_setInactive()
{
    self makeunusable();
    self.isUsable = 0;
    maps\mp\_entityheadicons::setHeadIcon( "none", "", ( 0, 0, 0 ) );

    if ( isdefined( self.objIdFriendly ) )
        maps\mp\_utility::_objective_delete( self.objIdFriendly );
}

box_handleDamage()
{
    self.health = 999999;
    self.maxHealth = 300;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage",  var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9  );

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_1 ) )
            continue;

        if ( isdefined( var_9 ) )
        {
            switch ( var_9 )
            {
                case "smoke_grenade_mp":
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
                    continue;
            }
        }

        if ( !isdefined( self ) )
            return;

        if ( var_4 == "MOD_MELEE" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        if ( isdefined( var_8 ) && var_8 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;
        var_10 = var_0;

        if ( isplayer( var_1 ) )
        {
            var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "deployable_bag" );

            if ( var_4 == "MOD_RIFLE_BULLET" || var_4 == "MOD_PISTOL_BULLET" )
            {
                if ( var_1 maps\mp\_utility::_hasPerk( "specialty_armorpiercing" ) )
                    var_10 += var_0 * level.armorPiercingMod;
            }
        }

        if ( isdefined( var_1.owner ) && isplayer( var_1.owner ) )
            var_1.owner maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "deployable_bag" );

        if ( isdefined( var_9 ) )
        {
            switch ( var_9 )
            {
                case "ac130_105mm_mp":
                case "ac130_40mm_mp":
                case "remotemissile_projectile_mp":
                case "stinger_mp":
                case "javelin_mp":
                case "remote_mortar_missile_mp":
                    self.largeProjectileDamage = 1;
                    var_10 = self.maxHealth + 1;
                    break;
                case "artillery_mp":
                case "stealth_bomb_mp":
                    self.largeProjectileDamage = 0;
                    var_10 += var_0 * 4;
                    break;
                case "bomb_site_mp":
                    self.largeProjectileDamage = 0;
                    var_10 = self.maxHealth + 1;
                    break;
            }

            maps\mp\killstreaks\_killstreaks::killstreakhit( var_1, var_9, self );
        }

        self.damagetaken = self.damagetaken + var_10;

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isplayer( var_1 ) && ( !isdefined( self.owner ) || var_1 != self.owner ) )
            {
                var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100, var_9, var_4 );
                var_1 notify( "destroyed_killstreak" );
            }

            if ( isdefined( self.owner ) )
                self.owner thread maps\mp\_utility::leaderDialogOnPlayer( level.boxSettings[self.boxType].voDestroyed );

            self notify( "death" );
            return;
        }
    }
}

box_handleDeath()
{
    self waittill( "death" );

    if ( !isdefined( self ) )
        return;

    box_setInactive();
    playfx( common_scripts\utility::getfx( "box_explode_mp" ), self.origin );
    wait 0.5;
    self notify( "deleting" );
    self delete();
}

box_handleOwnerDisconnect()
{
    self endon( "death" );
    level endon( "game_ended" );
    self notify( "box_handleOwner" );
    self endon( "box_handleOwner" );
    self.owner common_scripts\utility::waittill_any( "disconnect", "joined_team", "joined_spectators" );
    self notify( "death" );
}

boxThink( var_0 )
{
    self endon( "death" );
    thread boxCaptureThink( var_0 );

    for (;;)
    {
        self waittill( "captured",  var_1  );

        if ( var_1 != var_0 )
            continue;

        switch ( self.boxType )
        {
            case "deployable_vest":
                var_0 playlocalsound( "ammo_crate_use" );
                var_0 [[ level.killstreakFuncs["light_armor"] ]]();
                break;
        }

        if ( isdefined( self.owner ) && var_0 != self.owner )
        {
            self.owner thread maps\mp\gametypes\_rank::xpEventPopup( level.boxSettings[self.boxType].eventString );
            self.owner thread maps\mp\gametypes\_rank::giveRankXP( "support", level.boxSettings[self.boxType].xp );
        }

        maps\mp\_entityheadicons::setHeadIcon( var_0, "", ( 0, 0, 0 ) );
        self disableplayeruse( var_0 );
        thread doubleDip( var_0 );
    }
}

doubleDip( var_0 )
{
    self endon( "death" );
    var_0 endon( "disconnect" );
    var_0 waittill( "death" );

    if ( level.teamBased )
    {
        if ( self.team == var_0.team )
        {
            maps\mp\_entityheadicons::setHeadIcon( var_0, maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( level.boxSettings[self.boxType].streakName ), ( 0, 0, 20 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
            self enableplayeruse( var_0 );
        }
    }
    else if ( isdefined( self.owner ) && self.owner == var_0 )
    {
        maps\mp\_entityheadicons::setHeadIcon( var_0, maps\mp\killstreaks\_killstreaks::getKillstreakCrateIcon( level.boxSettings[self.boxType].streakName ), ( 0, 0, 20 ), 14, 14, undefined, undefined, undefined, undefined, undefined, 0 );
        self enableplayeruse( var_0 );
    }
}

boxCaptureThink( var_0 )
{
    while ( isdefined( self ) )
    {
        self waittill( "trigger",  var_1  );

        if ( var_1 != var_0 )
            continue;

        if ( !useHoldThink( var_0, 2000 ) )
            continue;

        self notify( "captured",  var_0  );
    }
}

isFriendlyToBox( var_0 )
{
    if ( level.teamBased && self.team == var_0.team )
        return 1;

    return 0;
}

box_timeOut()
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = level.boxSettings[self.boxType].lifeSpan;

    while ( var_0 )
    {
        wait 1.0;
        maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

        if ( !isdefined( self.carriedBy ) )
            var_0 = max( 0, var_0 - 1.0 );
    }

    self notify( "death" );
}

deleteOnOwnerDeath( var_0 )
{
    wait 0.25;
    self linkto( var_0, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    var_0 waittill( "death" );
    self delete();
}

box_ModelTeamUpdater( var_0 )
{
    self endon( "death" );
    self hide();

    foreach ( var_2 in level.players )
    {
        if ( var_2.team == var_0 )
            self showtoplayer( var_2 );
    }

    for (;;)
    {
        level waittill( "joined_team" );
        self hide();

        foreach ( var_2 in level.players )
        {
            if ( var_2.team == var_0 )
                self showtoplayer( var_2 );
        }
    }
}

useHoldThink( var_0, var_1 )
{
    var_0 playerlinkto( self );
    var_0 playerlinkedoffsetenable();
    var_0 common_scripts\utility::_disableWeapon();
    var_0.boxParams = spawnstruct();
    var_0.boxParams.curProgress = 0;
    var_0.boxParams.inUse = 1;
    var_0.boxParams.useRate = 0;

    if ( isdefined( var_1 ) )
        var_0.boxParams.useTime = var_1;
    else
        var_0.boxParams.useTime = 3000;

    var_0 thread personalUseBar( self );
    var_2 = useHoldThinkLoop( var_0 );

    if ( isalive( var_0 ) )
    {
        var_0 common_scripts\utility::_enableWeapon();
        var_0 unlink();
    }

    if ( !isdefined( self ) )
        return 0;

    var_0.boxParams.inUse = 0;
    var_0.boxParams.curProgress = 0;
    return var_2;
}

personalUseBar( var_0 )
{
    self endon( "disconnect" );
    var_1 = maps\mp\gametypes\_hud_util::createPrimaryProgressBar( 0, 25 );
    var_2 = maps\mp\gametypes\_hud_util::createPrimaryProgressBarText( 0, 25 );
    var_2 settext( level.boxSettings[var_0.boxType].capturingString );
    var_3 = -1;

    while ( maps\mp\_utility::isReallyAlive( self ) && isdefined( var_0 ) && self.boxParams.inUse && var_0.isUsable && !level.gameEnded )
    {
        if ( var_3 != self.boxParams.useRate )
        {
            if ( self.boxParams.curProgress > self.boxParams.useTime )
                self.boxParams.curProgress = self.boxParams.useTime;

            var_1 maps\mp\gametypes\_hud_util::updateBar( self.boxParams.curProgress / self.boxParams.useTime, 1000 / self.boxParams.useTime * self.boxParams.useRate );

            if ( !self.boxParams.useRate )
            {
                var_1 maps\mp\gametypes\_hud_util::hideElem();
                var_2 maps\mp\gametypes\_hud_util::hideElem();
            }
            else
            {
                var_1 maps\mp\gametypes\_hud_util::showElem();
                var_2 maps\mp\gametypes\_hud_util::showElem();
            }
        }

        var_3 = self.boxParams.useRate;
        wait 0.05;
    }

    var_1 maps\mp\gametypes\_hud_util::destroyElem();
    var_2 maps\mp\gametypes\_hud_util::destroyElem();
}

useHoldThinkLoop( var_0 )
{
    while ( !level.gameEnded && isdefined( self ) && maps\mp\_utility::isReallyAlive( var_0 ) && var_0 usebuttonpressed() && var_0.boxParams.curProgress < var_0.boxParams.useTime )
    {
        var_0.boxParams.curProgress = var_0.boxParams.curProgress + 50 * var_0.boxParams.useRate;

        if ( isdefined( var_0.objectiveScaler ) )
            var_0.boxParams.useRate = 1 * var_0.objectiveScaler;
        else
            var_0.boxParams.useRate = 1;

        if ( var_0.boxParams.curProgress >= var_0.boxParams.useTime )
            return maps\mp\_utility::isReallyAlive( var_0 );

        wait 0.05;
    }

    return 0;
}

disableWhenJuggernaut()
{
    level endon( "game_ended" );
    self endon( "death" );

    for (;;)
    {
        level waittill( "juggernaut_equipped",  var_0  );
        maps\mp\_entityheadicons::setHeadIcon( var_0, "", ( 0, 0, 0 ) );
        self disableplayeruse( var_0 );
        thread doubleDip( var_0 );
    }
}
