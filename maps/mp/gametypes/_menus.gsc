// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( !isdefined( game["gamestarted"] ) )
    {
        game["menu_team"] = "team_marinesopfor";
        game["menu_class_allies"] = "class_marines";
        game["menu_changeclass_allies"] = "changeclass_marines";
        game["menu_initteam_allies"] = "initteam_marines";
        game["menu_class_axis"] = "class_opfor";
        game["menu_changeclass_axis"] = "changeclass_opfor";
        game["menu_initteam_axis"] = "initteam_opfor";
        game["menu_class"] = "class";
        game["menu_changeclass"] = "changeclass";
        game["menu_controls"] = "ingame_controls";

        if ( !level.console )
        {
            game["menu_muteplayer"] = "muteplayer";
            precachemenu( game["menu_muteplayer"] );
        }
        else
        {
            game["menu_leavegame"] = "popup_leavegame";

            if ( level.splitscreen )
            {
                game["menu_team"] += "_splitscreen";
                game["menu_class_allies"] += "_splitscreen";
                game["menu_changeclass_allies"] += "_splitscreen";
                game["menu_class_axis"] += "_splitscreen";
                game["menu_changeclass_axis"] += "_splitscreen";
                game["menu_class"] += "_splitscreen";
                game["menu_controls"] += "_splitscreen";
                game["menu_leavegame"] += "_splitscreen";
                game["menu_changeclass_defaults_splitscreen"] = "changeclass_splitscreen_defaults";
                game["menu_changeclass_custom_splitscreen"] = "changeclass_splitscreen_custom";
                precachemenu( game["menu_changeclass_defaults_splitscreen"] );
                precachemenu( game["menu_changeclass_custom_splitscreen"] );
            }

            precachemenu( game["menu_controls"] );
            precachemenu( game["menu_leavegame"] );
        }

        precachemenu( "scoreboard" );
        precachemenu( game["menu_team"] );
        precachemenu( game["menu_class_allies"] );
        precachemenu( game["menu_changeclass_allies"] );
        precachemenu( game["menu_initteam_allies"] );
        precachemenu( game["menu_class_axis"] );
        precachemenu( game["menu_changeclass_axis"] );
        precachemenu( game["menu_class"] );
        precachemenu( game["menu_changeclass"] );
        precachemenu( game["menu_initteam_axis"] );
        precachestring( &"MP_HOST_ENDED_GAME" );
        precachestring( &"MP_HOST_ENDGAME_RESPONSE" );
    }

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0 thread onMenuResponse();
    }
}

isOptionsMenu( var_0 )
{
    if ( var_0 == game["menu_changeclass"] )
        return 1;

    if ( var_0 == game["menu_team"] )
        return 1;

    if ( var_0 == game["menu_controls"] )
        return 1;

    if ( issubstr( var_0, "pc_options" ) )
        return 1;

    return 0;
}

onMenuResponse()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "menuresponse",  var_0, var_1  );

        if ( var_1 == "back" )
        {
            if ( var_0 != game["menu_team"] || self.pers["team"] != "spectator" || maps\mp\gametypes\_tweakables::getTweakableValue( "game", "spectatetype" ) != 0 )
            {
                self closepopupmenu();
                self closeingamemenu();

                if ( isOptionsMenu( var_0 ) )
                {
                    if ( self.pers["team"] == "allies" )
                        self openpopupmenu( game["menu_class_allies"] );

                    if ( self.pers["team"] == "axis" )
                        self openpopupmenu( game["menu_class_axis"] );
                }
            }

            continue;
        }

        if ( var_1 == "changeteam" )
        {
            self closepopupmenu();
            self closeingamemenu();
            self openpopupmenu( game["menu_team"] );
        }

        if ( var_1 == "changeclass_marines" )
        {
            self closepopupmenu();
            self closeingamemenu();
            self openpopupmenu( game["menu_changeclass_allies"] );
            continue;
        }

        if ( var_1 == "changeclass_opfor" )
        {
            self closepopupmenu();
            self closeingamemenu();
            self openpopupmenu( game["menu_changeclass_axis"] );
            continue;
        }

        if ( var_1 == "changeclass_marines_splitscreen" )
            self openpopupmenu( "changeclass_marines_splitscreen" );

        if ( var_1 == "changeclass_opfor_splitscreen" )
            self openpopupmenu( "changeclass_opfor_splitscreen" );

        if ( var_1 == "endgame" )
        {
            if ( level.splitscreen )
            {
                endparty();

                if ( !level.gameEnded )
                    level thread maps\mp\gametypes\_gamelogic::forceEnd();
            }

            continue;
        }

        if ( var_1 == "endround" )
        {
            if ( !level.gameEnded )
                level thread maps\mp\gametypes\_gamelogic::forceEnd();
            else
            {
                self closepopupmenu();
                self closeingamemenu();
                self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
            }

            continue;
        }

        if ( var_0 == game["menu_team"] )
        {
            switch ( var_1 )
            {
                case "allies":
                    self [[ level.allies ]]();
                    break;
                case "axis":
                    self [[ level.axis ]]();
                    break;
                case "autoassign":
                    self [[ level.autoassign ]]();
                    break;
                case "spectator":
                    self [[ level.spectator ]]();
                    break;
            }

            continue;
        }

        if ( var_0 == game["menu_changeclass"] || isdefined( game["menu_changeclass_defaults_splitscreen"] ) && var_0 == game["menu_changeclass_defaults_splitscreen"] || isdefined( game["menu_changeclass_custom_splitscreen"] ) && var_0 == game["menu_changeclass_custom_splitscreen"] )
        {
            self closepopupmenu();
            self closeingamemenu();
            self.selectedClass = 1;
            self [[ level.class ]]( var_1 );
            continue;
        }

        if ( !level.console )
        {
            if ( var_0 == game["menu_quickcommands"] )
            {
                maps\mp\gametypes\_quickmessages::quickcommands( var_1 );
                continue;
            }

            if ( var_0 == game["menu_quickstatements"] )
            {
                maps\mp\gametypes\_quickmessages::quickstatements( var_1 );
                continue;
            }

            if ( var_0 == game["menu_quickresponses"] )
                maps\mp\gametypes\_quickmessages::quickresponses( var_1 );
        }
    }
}

getTeamAssignment()
{
    var_0[0] = "allies";
    var_0[1] = "axis";

    if ( !level.teamBased )
        return var_0[randomint( 2 )];

    if ( self.sessionteam != "none" && self.sessionteam != "spectator" && self.sessionstate != "playing" && self.sessionstate != "dead" )
        var_1 = self.sessionteam;
    else
    {
        var_2 = maps\mp\gametypes\_teams::CountPlayers();

        if ( var_2["allies"] == var_2["axis"] )
        {
            if ( getteamscore( "allies" ) == getteamscore( "axis" ) )
                var_1 = var_0[randomint( 2 )];
            else if ( getteamscore( "allies" ) < getteamscore( "axis" ) )
                var_1 = "allies";
            else
                var_1 = "axis";
        }
        else if ( var_2["allies"] < var_2["axis"] )
            var_1 = "allies";
        else
            var_1 = "axis";
    }

    return var_1;
}

menuAutoAssign()
{
    maps\mp\_utility::closeMenus();
    var_0 = getTeamAssignment();

    if ( isdefined( self.pers["team"] ) && ( self.sessionstate == "playing" || self.sessionstate == "dead" ) )
    {
        if ( var_0 == self.pers["team"] )
        {
            beginClassChoice();
            return;
        }
        else
        {
            self.switching_teams = 1;
            self.joining_team = var_0;
            self.leaving_team = self.pers["team"];
            self suicide();
        }
    }

    addToTeam( var_0 );
    self.pers["class"] = undefined;
    self.class = undefined;

    if ( !isalive( self ) )
        self.statusicon = "hud_status_dead";

    self notify( "end_respawn" );
    beginClassChoice();
}

beginClassChoice( var_0 )
{
    var_1 = self.pers["team"];

    if ( maps\mp\_utility::allowClassChoice() )
        self openpopupmenu( game["menu_changeclass_" + var_1] );
    else
        thread bypassClassChoice();

    if ( !isalive( self ) )
        thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime( 0.1 );
}

bypassClassChoice()
{
    self.selectedClass = 1;
    self [[ level.class ]]( "class0" );
}

beginTeamChoice()
{
    self openpopupmenu( game["menu_team"] );
}

showMainMenuForTeam()
{
    var_0 = self.pers["team"];
    self openpopupmenu( game["menu_class_" + var_0] );
}

menuAllies()
{
    maps\mp\_utility::closeMenus();

    if ( self.pers["team"] != "allies" )
    {
        if ( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
        {
            self openpopupmenu( game["menu_team"] );
            return;
        }

        if ( level.inGracePeriod && !self.hasDoneCombat )
            self.hasSpawned = 0;

        if ( self.sessionstate == "playing" )
        {
            self.switching_teams = 1;
            self.joining_team = "allies";
            self.leaving_team = self.pers["team"];
            self suicide();
        }

        addToTeam( "allies" );
        self.pers["class"] = undefined;
        self.class = undefined;
        self notify( "end_respawn" );
    }

    beginClassChoice();
}

menuAxis()
{
    maps\mp\_utility::closeMenus();

    if ( self.pers["team"] != "axis" )
    {
        if ( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "axis" ) )
        {
            self openpopupmenu( game["menu_team"] );
            return;
        }

        if ( level.inGracePeriod && !self.hasDoneCombat )
            self.hasSpawned = 0;

        if ( self.sessionstate == "playing" )
        {
            self.switching_teams = 1;
            self.joining_team = "axis";
            self.leaving_team = self.pers["team"];
            self suicide();
        }

        addToTeam( "axis" );
        self.pers["class"] = undefined;
        self.class = undefined;
        self notify( "end_respawn" );
    }

    beginClassChoice();
}

menuSpectator()
{
    maps\mp\_utility::closeMenus();

    if ( isdefined( self.pers["team"] ) && self.pers["team"] == "spectator" )
        return;

    if ( isalive( self ) )
    {
        self.switching_teams = 1;
        self.joining_team = "spectator";
        self.leaving_team = self.pers["team"];
        self suicide();
    }

    addToTeam( "spectator" );
    self.pers["class"] = undefined;
    self.class = undefined;
    thread maps\mp\gametypes\_playerlogic::spawnSpectator();
}

menuClass( var_0 )
{
    maps\mp\_utility::closeMenus();

    if ( var_0 == "demolitions_mp,0" && self getplayerdata( "featureNew", "demolitions" ) )
        self setplayerdata( "featureNew", "demolitions", 0 );

    if ( var_0 == "sniper_mp,0" && self getplayerdata( "featureNew", "sniper" ) )
        self setplayerdata( "featureNew", "sniper", 0 );

    if ( !isdefined( self.pers["team"] ) || self.pers["team"] != "allies" && self.pers["team"] != "axis" )
        return;

    var_1 = maps\mp\gametypes\_class::getClassChoice( var_0 );
    var_2 = maps\mp\gametypes\_class::getWeaponChoice( var_0 );

    if ( var_1 == "restricted" )
    {
        beginClassChoice();
        return;
    }

    if ( isdefined( self.pers["class"] ) && self.pers["class"] == var_1 && ( isdefined( self.pers["primary"] ) && self.pers["primary"] == var_2 ) )
        return;

    if ( self.sessionstate == "playing" )
    {
        if ( isdefined( self.pers["lastClass"] ) && isdefined( self.pers["class"] ) )
        {
            self.pers["lastClass"] = self.pers["class"];
            self.lastClass = self.pers["lastClass"];
        }

        self.pers["class"] = var_1;
        self.class = var_1;
        self.pers["primary"] = var_2;

        if ( game["state"] == "postgame" )
            return;

        if ( level.inGracePeriod && !self.hasDoneCombat )
        {
            maps\mp\gametypes\_class::setClass( self.pers["class"] );
            self.tag_stowed_back = undefined;
            self.tag_stowed_hip = undefined;
            maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
        }
        else
            self iprintlnbold( game["strings"]["change_class"] );
    }
    else
    {
        if ( isdefined( self.pers["lastClass"] ) && isdefined( self.pers["class"] ) )
        {
            self.pers["lastClass"] = self.pers["class"];
            self.lastClass = self.pers["lastClass"];
        }

        self.pers["class"] = var_1;
        self.class = var_1;
        self.pers["primary"] = var_2;

        if ( game["state"] == "postgame" )
            return;

        if ( game["state"] == "playing" && !maps\mp\_utility::isInKillcam() )
            thread maps\mp\gametypes\_playerlogic::spawnClient();
    }

    thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

addToTeam( var_0, var_1 )
{
    if ( isdefined( self.team ) )
        maps\mp\gametypes\_playerlogic::removeFromTeamCount();

    self.pers["team"] = var_0;
    self.team = var_0;

    if ( !maps\mp\_utility::matchMakingGame() || isdefined( self.pers["isBot"] ) || !maps\mp\_utility::allowTeamChoice() )
    {
        if ( level.teamBased )
            self.sessionteam = var_0;
        else if ( var_0 == "spectator" )
            self.sessionteam = "spectator";
        else
            self.sessionteam = "none";
    }

    if ( game["state"] != "postgame" )
        maps\mp\gametypes\_playerlogic::addToTeamCount();

    maps\mp\_utility::updateObjectiveText();

    if ( isdefined( var_1 ) && var_1 )
        waittillframeend;

    maps\mp\_utility::updateMainMenu();

    if ( var_0 == "spectator" )
    {
        self notify( "joined_spectators" );
        level notify( "joined_team" );
    }
    else
    {
        self notify( "joined_team" );
        level notify( "joined_team" );
    }
}
