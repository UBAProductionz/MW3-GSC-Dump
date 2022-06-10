// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

exploder_sound()
{
    if ( isdefined( self.script_delay ) )
        wait(self.script_delay);

    self playsound( level.scr_sound[self.script_sound] );
}

_beginLocationSelection( var_0, var_1, var_2, var_3 )
{
    self setclientdvar( "ui_selecting_location", "1" );
    self beginlocationselection( var_1, var_2, var_3 );
    self.selectingLocation = 1;
    self setblurforplayer( 10.3, 0.3 );
    thread endSelectionOnAction( "cancel_location" );
    thread endSelectionOnAction( "death" );
    thread endSelectionOnAction( "disconnect" );
    thread endSelectionOnAction( "used" );
    thread endSelectionOnAction( "weapon_change" );
    self endon( "stop_location_selection" );
    thread endSelectionOnEndGame();
    thread endSelectionOnEMP();

    if ( isdefined( var_0 ) && self.team != "spectator" )
    {
        if ( isdefined( self.streakMsg ) )
            self.streakMsg destroy();

        if ( self issplitscreenplayer() )
        {
            self.streakMsg = maps\mp\gametypes\_hud_util::createFontString( "hudbig", 0.65 );
            self.streakMsg maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, -98 );
        }
        else
        {
            self.streakMsg = maps\mp\gametypes\_hud_util::createFontString( "bigfixed", 0.8 );
            self.streakMsg maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0, -190 );
        }

        var_4 = tablelookupistring( "mp/killstreakTable.csv", 1, var_0, 2 );
        self.streakMsg settext( var_4 );
    }
}

stopLocationSelection( var_0, var_1 )
{
    if ( !isdefined( var_1 ) )
        var_1 = "generic";

    if ( !var_0 )
    {
        self setblurforplayer( 0, 0.3 );
        self endlocationselection();
        self.selectingLocation = undefined;

        if ( isdefined( self.streakMsg ) )
            self.streakMsg destroy();
    }

    self notify( "stop_location_selection",  var_1  );
}

endSelectionOnEMP()
{
    self endon( "stop_location_selection" );

    for (;;)
    {
        level waittill( "emp_update" );

        if ( !isEMPed() )
            continue;

        thread stopLocationSelection( 0, "emp" );
        return;
    }
}

endSelectionOnAction( var_0 )
{
    self endon( "stop_location_selection" );
    self waittill( var_0 );
    thread stopLocationSelection( var_0 == "disconnect", var_0 );
}

endSelectionOnEndGame()
{
    self endon( "stop_location_selection" );
    level waittill( "game_ended" );
    thread stopLocationSelection( 0, "end_game" );
}

isAttachment( var_0 )
{
    var_1 = tablelookup( "mp/attachmentTable.csv", 4, var_0, 0 );

    if ( isdefined( var_1 ) && var_1 != "" )
        return 1;
    else
        return 0;
}

getAttachmentType( var_0 )
{
    var_1 = tablelookup( "mp/attachmentTable.csv", 4, var_0, 2 );
    return var_1;
}

delayThread( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    thread delayThread_proc( var_1, var_0, var_2, var_3, var_4, var_5, var_6 );
}

delayThread_proc( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    wait(var_1);

    if ( !isdefined( var_2 ) )
        thread [[ var_0 ]]();
    else if ( !isdefined( var_3 ) )
        thread [[ var_0 ]]( var_2 );
    else if ( !isdefined( var_4 ) )
        thread [[ var_0 ]]( var_2, var_3 );
    else if ( !isdefined( var_5 ) )
        thread [[ var_0 ]]( var_2, var_3, var_4 );
    else if ( !isdefined( var_6 ) )
        thread [[ var_0 ]]( var_2, var_3, var_4, var_5 );
    else
        thread [[ var_0 ]]( var_2, var_3, var_4, var_5, var_6 );
}

getPlant()
{
    var_0 = self.origin + ( 0, 0, 10 );
    var_1 = 11;
    var_2 = anglestoforward( self.angles );
    var_2 *= var_1;
    var_3[0] = var_0 + var_2;
    var_3[1] = var_0;
    var_4 = bullettrace( var_3[0], var_3[0] + ( 0, 0, -18 ), 0, undefined );

    if ( var_4["fraction"] < 1 )
    {
        var_5 = spawnstruct();
        var_5.origin = var_4["position"];
        var_5.angles = orientToNormal( var_4["normal"] );
        return var_5;
    }

    var_4 = bullettrace( var_3[1], var_3[1] + ( 0, 0, -18 ), 0, undefined );

    if ( var_4["fraction"] < 1 )
    {
        var_5 = spawnstruct();
        var_5.origin = var_4["position"];
        var_5.angles = orientToNormal( var_4["normal"] );
        return var_5;
    }

    var_3[2] = var_0 + ( 16, 16, 0 );
    var_3[3] = var_0 + ( 16, -16, 0 );
    var_3[4] = var_0 + ( -16, -16, 0 );
    var_3[5] = var_0 + ( -16, 16, 0 );
    var_6 = undefined;
    var_7 = undefined;

    for ( var_8 = 0; var_8 < var_3.size; var_8++ )
    {
        var_4 = bullettrace( var_3[var_8], var_3[var_8] + ( 0, 0, -1000 ), 0, undefined );

        if ( !isdefined( var_6 ) || var_4["fraction"] < var_6 )
        {
            var_6 = var_4["fraction"];
            var_7 = var_4["position"];
        }
    }

    if ( var_6 == 1 )
        var_7 = self.origin;

    var_5 = spawnstruct();
    var_5.origin = var_7;
    var_5.angles = orientToNormal( var_4["normal"] );
    return var_5;
}

orientToNormal( var_0 )
{
    var_1 = ( var_0[0], var_0[1], 0 );
    var_2 = length( var_1 );

    if ( !var_2 )
        return ( 0, 0, 0 );

    var_3 = vectornormalize( var_1 );
    var_4 = var_0[2] * -1;
    var_5 = ( var_3[0] * var_4, var_3[1] * var_4, var_2 );
    var_6 = vectortoangles( var_5 );
    return var_6;
}

deletePlacedEntity( var_0 )
{
    var_1 = getentarray( var_0, "classname" );

    for ( var_2 = 0; var_2 < var_1.size; var_2++ )
        var_1[var_2] delete();
}

playSoundOnPlayers( var_0, var_1, var_2 )
{
    if ( level.splitscreen )
    {
        if ( isdefined( level.players[0] ) )
            level.players[0] playlocalsound( var_0 );
    }
    else if ( isdefined( var_1 ) )
    {
        if ( isdefined( var_2 ) )
        {
            for ( var_3 = 0; var_3 < level.players.size; var_3++ )
            {
                var_4 = level.players[var_3];

                if ( var_4 issplitscreenplayer() && !var_4 issplitscreenplayerprimary() )
                    continue;

                if ( isdefined( var_4.pers["team"] ) && var_4.pers["team"] == var_1 && !isExcluded( var_4, var_2 ) )
                    var_4 playlocalsound( var_0 );
            }

            return;
        }

        for ( var_3 = 0; var_3 < level.players.size; var_3++ )
        {
            var_4 = level.players[var_3];

            if ( var_4 issplitscreenplayer() && !var_4 issplitscreenplayerprimary() )
                continue;

            if ( isdefined( var_4.pers["team"] ) && var_4.pers["team"] == var_1 )
                var_4 playlocalsound( var_0 );
        }

        return;
    }
    else if ( isdefined( var_2 ) )
    {
        for ( var_3 = 0; var_3 < level.players.size; var_3++ )
        {
            if ( level.players[var_3] issplitscreenplayer() && !level.players[var_3] issplitscreenplayerprimary() )
                continue;

            if ( !isExcluded( level.players[var_3], var_2 ) )
                level.players[var_3] playlocalsound( var_0 );
        }
    }
    else
    {
        for ( var_3 = 0; var_3 < level.players.size; var_3++ )
        {
            if ( level.players[var_3] issplitscreenplayer() && !level.players[var_3] issplitscreenplayerprimary() )
                continue;

            level.players[var_3] playlocalsound( var_0 );
        }
    }
}

sortLowerMessages()
{
    for ( var_0 = 1; var_0 < self.lowerMessages.size; var_0++ )
    {
        var_1 = self.lowerMessages[var_0];
        var_2 = var_1.priority;

        for ( var_3 = var_0 - 1; var_3 >= 0 && var_2 > self.lowerMessages[var_3].priority; var_3-- )
            self.lowerMessages[var_3 + 1] = self.lowerMessages[var_3];

        self.lowerMessages[var_3 + 1] = var_1;
    }
}

addLowerMessage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    var_9 = undefined;

    foreach ( var_11 in self.lowerMessages )
    {
        if ( var_11.name == var_0 )
        {
            if ( var_11.text == var_1 && var_11.priority == var_3 )
                return;

            var_9 = var_11;
            break;
        }
    }

    if ( !isdefined( var_9 ) )
    {
        var_9 = spawnstruct();
        self.lowerMessages[self.lowerMessages.size] = var_9;
    }

    var_9.name = var_0;
    var_9.text = var_1;
    var_9.time = var_2;
    var_9.addTime = gettime();
    var_9.priority = var_3;
    var_9.showTimer = var_4;
    var_9.shouldFade = var_5;
    var_9.fadeToAlpha = var_6;
    var_9.fadeToAlphaTime = var_7;
    var_9.hidewhenindemo = var_8;
    sortLowerMessages();
}

removeLowerMessage( var_0 )
{
    if ( isdefined( self.lowerMessages ) )
    {
        for ( var_1 = self.lowerMessages.size; var_1 > 0; var_1-- )
        {
            if ( self.lowerMessages[var_1 - 1].name != var_0 )
                continue;

            var_2 = self.lowerMessages[var_1 - 1];

            for ( var_3 = var_1; var_3 < self.lowerMessages.size; var_3++ )
            {
                if ( isdefined( self.lowerMessages[var_3] ) )
                    self.lowerMessages[var_3 - 1] = self.lowerMessages[var_3];
            }

            self.lowerMessages[self.lowerMessages.size - 1] = undefined;
        }

        sortLowerMessages();
    }
}

getLowerMessage()
{
    return self.lowerMessages[0];
}

setLowerMessage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    if ( !isdefined( var_3 ) )
        var_3 = 1;

    if ( !isdefined( var_2 ) )
        var_2 = 0;

    if ( !isdefined( var_4 ) )
        var_4 = 0;

    if ( !isdefined( var_5 ) )
        var_5 = 0;

    if ( !isdefined( var_6 ) )
        var_6 = 0.85;

    if ( !isdefined( var_7 ) )
        var_7 = 3.0;

    if ( !isdefined( var_8 ) )
        var_8 = 0;

    addLowerMessage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 );
    updateLowerMessage();
}

updateLowerMessage()
{
    var_0 = getLowerMessage();

    if ( !isdefined( var_0 ) )
    {
        self.lowerMessage.alpha = 0;
        self.lowerTimer.alpha = 0;
    }
    else
    {
        self.lowerMessage settext( var_0.text );
        self.lowerMessage.alpha = 0.85;
        self.lowerTimer.alpha = 1;
        self.lowerMessage.hidewhenindemo = var_0.hidewhenindemo;

        if ( var_0.shouldFade )
        {
            self.lowerMessage fadeovertime( min( var_0.fadeToAlphaTime, 60 ) );
            self.lowerMessage.alpha = var_0.fadeToAlpha;
        }

        if ( var_0.time > 0 && var_0.showTimer )
            self.lowerTimer settimer( max( var_0.time - ( gettime() - var_0.addTime ) / 1000, 0.1 ) );
        else
        {
            if ( var_0.time > 0 && !var_0.showTimer )
            {
                self.lowerTimer settext( "" );
                self.lowerMessage fadeovertime( min( var_0.time, 60 ) );
                self.lowerMessage.alpha = 0;
                thread clearOnDeath( var_0 );
                thread clearAfterFade( var_0 );
                return;
            }

            self.lowerTimer settext( "" );
        }
    }
}

clearOnDeath( var_0 )
{
    self notify( "message_cleared" );
    self endon( "message_cleared" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "death" );
    clearLowerMessage( var_0.name );
}

clearAfterFade( var_0 )
{
    wait(var_0.time);
    clearLowerMessage( var_0.name );
    self notify( "message_cleared" );
}

clearLowerMessage( var_0 )
{
    removeLowerMessage( var_0 );
    updateLowerMessage();
}

clearLowerMessages()
{
    for ( var_0 = 0; var_0 < self.lowerMessages.size; var_0++ )
        self.lowerMessages[var_0] = undefined;

    if ( !isdefined( self.lowerMessage ) )
        return;

    updateLowerMessage();
}

printOnTeam( var_0, var_1 )
{
    foreach ( var_3 in level.players )
    {
        if ( var_3.team != var_1 )
            continue;

        var_3 iprintln( var_0 );
    }
}

printBoldOnTeam( var_0, var_1 )
{
    for ( var_2 = 0; var_2 < level.players.size; var_2++ )
    {
        var_3 = level.players[var_2];

        if ( isdefined( var_3.pers["team"] ) && var_3.pers["team"] == var_1 )
            var_3 iprintlnbold( var_0 );
    }
}

printBoldOnTeamArg( var_0, var_1, var_2 )
{
    for ( var_3 = 0; var_3 < level.players.size; var_3++ )
    {
        var_4 = level.players[var_3];

        if ( isdefined( var_4.pers["team"] ) && var_4.pers["team"] == var_1 )
            var_4 iprintlnbold( var_0, var_2 );
    }
}

printOnTeamArg( var_0, var_1, var_2 )
{
    for ( var_3 = 0; var_3 < level.players.size; var_3++ )
    {
        var_4 = level.players[var_3];

        if ( isdefined( var_4.pers["team"] ) && var_4.pers["team"] == var_1 )
            var_4 iprintln( var_0, var_2 );
    }
}

printOnPlayers( var_0, var_1 )
{
    var_2 = level.players;

    for ( var_3 = 0; var_3 < var_2.size; var_3++ )
    {
        if ( isdefined( var_1 ) )
        {
            if ( isdefined( var_2[var_3].pers["team"] ) && var_2[var_3].pers["team"] == var_1 )
                var_2[var_3] iprintln( var_0 );

            continue;
        }

        var_2[var_3] iprintln( var_0 );
    }
}

printAndSoundOnEveryone( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    var_7 = isdefined( var_4 );
    var_8 = 0;

    if ( isdefined( var_5 ) )
        var_8 = 1;

    if ( level.splitscreen || !var_7 )
    {
        for ( var_9 = 0; var_9 < level.players.size; var_9++ )
        {
            var_10 = level.players[var_9];
            var_11 = var_10.pers["team"];

            if ( isdefined( var_11 ) )
            {
                if ( var_11 == var_0 && isdefined( var_2 ) )
                {
                    var_10 iprintln( var_2, var_6 );
                    continue;
                }

                if ( var_11 == var_1 && isdefined( var_3 ) )
                    var_10 iprintln( var_3, var_6 );
            }
        }

        if ( var_7 )
            level.players[0] playlocalsound( var_4 );
    }
    else if ( var_8 )
    {
        for ( var_9 = 0; var_9 < level.players.size; var_9++ )
        {
            var_10 = level.players[var_9];
            var_11 = var_10.pers["team"];

            if ( isdefined( var_11 ) )
            {
                if ( var_11 == var_0 )
                {
                    if ( isdefined( var_2 ) )
                        var_10 iprintln( var_2, var_6 );

                    var_10 playlocalsound( var_4 );
                    continue;
                }

                if ( var_11 == var_1 )
                {
                    if ( isdefined( var_3 ) )
                        var_10 iprintln( var_3, var_6 );

                    var_10 playlocalsound( var_5 );
                }
            }
        }
    }
    else
    {
        for ( var_9 = 0; var_9 < level.players.size; var_9++ )
        {
            var_10 = level.players[var_9];
            var_11 = var_10.pers["team"];

            if ( isdefined( var_11 ) )
            {
                if ( var_11 == var_0 )
                {
                    if ( isdefined( var_2 ) )
                        var_10 iprintln( var_2, var_6 );

                    var_10 playlocalsound( var_4 );
                    continue;
                }

                if ( var_11 == var_1 )
                {
                    if ( isdefined( var_3 ) )
                        var_10 iprintln( var_3, var_6 );
                }
            }
        }
    }
}

printAndSoundOnTeam( var_0, var_1, var_2 )
{
    foreach ( var_4 in level.players )
    {
        if ( var_4.team != var_0 )
            continue;

        var_4 printAndSoundOnPlayer( var_1, var_2 );
    }
}

printAndSoundOnPlayer( var_0, var_1 )
{
    self iprintln( var_0 );
    self playlocalsound( var_1 );
}

_playLocalSound( var_0 )
{
    if ( level.splitscreen && self getentitynumber() != 0 )
        return;

    self playlocalsound( var_0 );
}

dvarIntValue( var_0, var_1, var_2, var_3 )
{
    var_0 = "scr_" + level.gameType + "_" + var_0;

    if ( getdvar( var_0 ) == "" )
    {
        setdvar( var_0, var_1 );
        return var_1;
    }

    var_4 = getdvarint( var_0 );

    if ( var_4 > var_3 )
        var_4 = var_3;
    else if ( var_4 < var_2 )
        var_4 = var_2;
    else
        return var_4;

    setdvar( var_0, var_4 );
    return var_4;
}

dvarFloatValue( var_0, var_1, var_2, var_3 )
{
    var_0 = "scr_" + level.gameType + "_" + var_0;

    if ( getdvar( var_0 ) == "" )
    {
        setdvar( var_0, var_1 );
        return var_1;
    }

    var_4 = getdvarfloat( var_0 );

    if ( var_4 > var_3 )
        var_4 = var_3;
    else if ( var_4 < var_2 )
        var_4 = var_2;
    else
        return var_4;

    setdvar( var_0, var_4 );
    return var_4;
}

play_sound_on_tag( var_0, var_1 )
{
    if ( isdefined( var_1 ) )
        playsoundatpos( self gettagorigin( var_1 ), var_0 );
    else
        playsoundatpos( self.origin, var_0 );
}

getOtherTeam( var_0 )
{
    if ( var_0 == "allies" )
        return "axis";
    else if ( var_0 == "axis" )
        return "allies";
}

wait_endon( var_0, var_1, var_2, var_3 )
{
    self endon( var_1 );

    if ( isdefined( var_2 ) )
        self endon( var_2 );

    if ( isdefined( var_3 ) )
        self endon( var_3 );

    wait(var_0);
}

initPersStat( var_0 )
{
    if ( !isdefined( self.pers[var_0] ) )
        self.pers[var_0] = 0;
}

getPersStat( var_0 )
{
    return self.pers[var_0];
}

incPersStat( var_0, var_1 )
{
    if ( isdefined( self ) && isdefined( self.pers ) && isdefined( self.pers[var_0] ) )
    {
        self.pers[var_0] = self.pers[var_0] + var_1;
        maps\mp\gametypes\_persistence::statAdd( var_0, var_1 );
    }
}

setPersStat( var_0, var_1 )
{
    self.pers[var_0] = var_1;
}

initPlayerStat( var_0, var_1 )
{
    if ( !isdefined( self.stats["stats_" + var_0] ) )
    {
        if ( !isdefined( var_1 ) )
            var_1 = 0;

        self.stats["stats_" + var_0] = spawnstruct();
        self.stats["stats_" + var_0].value = var_1;
    }
}

incPlayerStat( var_0, var_1 )
{
    var_2 = self.stats["stats_" + var_0];
    var_2.value = var_2.value + var_1;
}

setPlayerStat( var_0, var_1 )
{
    var_2 = self.stats["stats_" + var_0];
    var_2.value = var_1;
    var_2.time = gettime();
}

getPlayerStat( var_0 )
{
    return self.stats["stats_" + var_0].value;
}

getPlayerStatTime( var_0 )
{
    return self.stats["stats_" + var_0].time;
}

setPlayerStatIfGreater( var_0, var_1 )
{
    var_2 = getPlayerStat( var_0 );

    if ( var_1 > var_2 )
        setPlayerStat( var_0, var_1 );
}

setPlayerStatIfLower( var_0, var_1 )
{
    var_2 = getPlayerStat( var_0 );

    if ( var_1 < var_2 )
        setPlayerStat( var_0, var_1 );
}

updatePersRatio( var_0, var_1, var_2 )
{
    var_3 = maps\mp\gametypes\_persistence::statGet( var_1 );
    var_4 = maps\mp\gametypes\_persistence::statGet( var_2 );

    if ( var_4 == 0 )
        var_4 = 1;

    maps\mp\gametypes\_persistence::statSet( var_0, int( var_3 * 1000 / var_4 ) );
}

updatePersRatioBuffered( var_0, var_1, var_2 )
{
    var_3 = maps\mp\gametypes\_persistence::statGetBuffered( var_1 );
    var_4 = maps\mp\gametypes\_persistence::statGetBuffered( var_2 );

    if ( var_4 == 0 )
        var_4 = 1;

    maps\mp\gametypes\_persistence::statSetBuffered( var_0, int( var_3 * 1000 / var_4 ) );
}

WaitTillSlowProcessAllowed( var_0 )
{
    if ( level.lastSlowProcessFrame == gettime() )
    {
        if ( isdefined( var_0 ) && var_0 )
        {
            while ( level.lastSlowProcessFrame == gettime() )
                wait 0.05;
        }
        else
        {
            wait 0.05;

            if ( level.lastSlowProcessFrame == gettime() )
            {
                wait 0.05;

                if ( level.lastSlowProcessFrame == gettime() )
                {
                    wait 0.05;

                    if ( level.lastSlowProcessFrame == gettime() )
                        wait 0.05;
                }
            }
        }
    }

    level.lastSlowProcessFrame = gettime();
}

waitForTimeOrNotify( var_0, var_1 )
{
    self endon( var_1 );
    wait(var_0);
}

isExcluded( var_0, var_1 )
{
    for ( var_2 = 0; var_2 < var_1.size; var_2++ )
    {
        if ( var_0 == var_1[var_2] )
            return 1;
    }

    return 0;
}

leaderDialog( var_0, var_1, var_2, var_3 )
{
    if ( level.splitscreen )
        return;

    if ( var_0 == "null" )
        return;

    if ( !isdefined( var_1 ) )
        leaderDialogBothTeams( var_0, "allies", var_0, "axis", var_2, var_3 );
    else
    {
        if ( level.splitscreen )
        {
            if ( level.players.size )
                level.players[0] leaderDialogOnPlayer( var_0, var_2 );

            return;
        }

        if ( isdefined( var_3 ) )
        {
            for ( var_4 = 0; var_4 < level.players.size; var_4++ )
            {
                var_5 = level.players[var_4];

                if ( isdefined( var_5.pers["team"] ) && var_5.pers["team"] == var_1 && !isExcluded( var_5, var_3 ) )
                {
                    if ( var_5 issplitscreenplayer() && !var_5 issplitscreenplayerprimary() )
                        continue;

                    var_5 leaderDialogOnPlayer( var_0, var_2 );
                }
            }

            return;
        }

        for ( var_4 = 0; var_4 < level.players.size; var_4++ )
        {
            var_5 = level.players[var_4];

            if ( isdefined( var_5.pers["team"] ) && var_5.pers["team"] == var_1 )
            {
                if ( var_5 issplitscreenplayer() && !var_5 issplitscreenplayerprimary() )
                    continue;

                var_5 leaderDialogOnPlayer( var_0, var_2 );
            }
        }
    }
}

leaderDialogBothTeams( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( level.splitscreen )
        return;

    if ( level.splitscreen )
    {
        if ( level.players.size )
            level.players[0] leaderDialogOnPlayer( var_0, var_4 );
    }
    else
    {
        if ( isdefined( var_5 ) )
        {
            for ( var_6 = 0; var_6 < level.players.size; var_6++ )
            {
                var_7 = level.players[var_6];
                var_8 = var_7.pers["team"];

                if ( !isdefined( var_8 ) )
                    continue;

                if ( isExcluded( var_7, var_5 ) )
                    continue;

                if ( var_7 issplitscreenplayer() && !var_7 issplitscreenplayerprimary() )
                    continue;

                if ( var_8 == var_1 )
                {
                    var_7 leaderDialogOnPlayer( var_0, var_4 );
                    continue;
                }

                if ( var_8 == var_3 )
                    var_7 leaderDialogOnPlayer( var_2, var_4 );
            }

            return;
        }

        for ( var_6 = 0; var_6 < level.players.size; var_6++ )
        {
            var_7 = level.players[var_6];
            var_8 = var_7.pers["team"];

            if ( !isdefined( var_8 ) )
                continue;

            if ( var_7 issplitscreenplayer() && !var_7 issplitscreenplayerprimary() )
                continue;

            if ( var_8 == var_1 )
            {
                var_7 leaderDialogOnPlayer( var_0, var_4 );
                continue;
            }

            if ( var_8 == var_3 )
                var_7 leaderDialogOnPlayer( var_2, var_4 );
        }
    }
}

leaderDialogOnPlayers( var_0, var_1, var_2 )
{
    foreach ( var_4 in var_1 )
        var_4 leaderDialogOnPlayer( var_0, var_2 );
}

leaderDialogOnPlayer( var_0, var_1, var_2 )
{
    if ( !isdefined( var_2 ) )
        var_2 = 0;

    var_3 = self.pers["team"];

    if ( level.splitscreen )
        return;

    if ( !isdefined( var_3 ) )
        return;

    if ( var_3 != "allies" && var_3 != "axis" )
        return;

    if ( isdefined( var_1 ) )
    {
        if ( self.leaderDialogGroup == var_1 )
        {
            if ( var_2 )
            {
                self stoplocalsound( self.leaderDialogActive );
                thread playLeaderDialogOnPlayer( var_0, var_3 );
            }

            return;
        }

        var_4 = isdefined( self.leaderDialogGroups[var_1] );
        self.leaderDialogGroups[var_1] = var_0;
        var_0 = var_1;

        if ( var_4 )
            return;
    }

    if ( self.leaderDialogActive == "" )
        thread playLeaderDialogOnPlayer( var_0, var_3 );
    else
        self.leaderDialogQueue[self.leaderDialogQueue.size] = var_0;
}

playLeaderDialogOnPlayer( var_0, var_1 )
{
    self endon( "disconnect" );
    self notify( "playLeaderDialogOnPlayer" );
    self endon( "playLeaderDialogOnPlayer" );

    if ( isdefined( self.leaderDialogGroups[var_0] ) )
    {
        var_2 = var_0;
        var_0 = self.leaderDialogGroups[var_2];
        self.leaderDialogGroups[var_2] = undefined;
        self.leaderDialogGroup = var_2;
    }

    if ( issubstr( game["dialog"][var_0], "null" ) )
        return;

    self.leaderDialogActive = game["voice"][var_1] + game["dialog"][var_0];
    self playlocalsound( game["voice"][var_1] + game["dialog"][var_0] );
    wait 3.0;
    self.leaderDialogLocalSound = "";
    self.leaderDialogActive = "";
    self.leaderDialogGroup = "";

    if ( self.leaderDialogQueue.size > 0 )
    {
        var_3 = self.leaderDialogQueue[0];

        for ( var_4 = 1; var_4 < self.leaderDialogQueue.size; var_4++ )
            self.leaderDialogQueue[var_4 - 1] = self.leaderDialogQueue[var_4];

        self.leaderDialogQueue[var_4 - 1] = undefined;
        thread playLeaderDialogOnPlayer( var_3, var_1 );
    }
}

updateMainMenu()
{
    if ( self.pers["team"] == "spectator" )
        self setclientdvar( "g_scriptMainMenu", game["menu_team"] );
    else
        self setclientdvar( "g_scriptMainMenu", game["menu_class_" + self.pers["team"]] );
}

updateObjectiveText()
{
    if ( self.pers["team"] == "spectator" )
        self setclientdvar( "cg_objectiveText", "" );
    else
    {
        if ( getWatchedDvar( "scorelimit" ) > 0 && !isObjectiveBased() )
        {
            if ( level.splitscreen )
            {
                self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ) );
                return;
            }

            self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ), getWatchedDvar( "scorelimit" ) );
            return;
            return;
        }

        self setclientdvar( "cg_objectiveText", getObjectiveText( self.pers["team"] ) );
    }
}

setObjectiveText( var_0, var_1 )
{
    game["strings"]["objective_" + var_0] = var_1;
    precachestring( var_1 );
}

setObjectiveScoreText( var_0, var_1 )
{
    game["strings"]["objective_score_" + var_0] = var_1;
    precachestring( var_1 );
}

setObjectiveHintText( var_0, var_1 )
{
    game["strings"]["objective_hint_" + var_0] = var_1;
    precachestring( var_1 );
}

getObjectiveText( var_0 )
{
    return game["strings"]["objective_" + var_0];
}

getObjectiveScoreText( var_0 )
{
    return game["strings"]["objective_score_" + var_0];
}

getObjectiveHintText( var_0 )
{
    return game["strings"]["objective_hint_" + var_0];
}

getTimePassed()
{
    if ( !isdefined( level.startTime ) || !isdefined( level.discardTime ) )
        return 0;

    if ( level.timerStopped )
        return level.timerPauseTime - level.startTime - level.discardTime;
    else
        return gettime() - level.startTime - level.discardTime;
}

getSecondsPassed()
{
    return getTimePassed() / 1000;
}

getMinutesPassed()
{
    return getSecondsPassed() / 60;
}

ClearKillcamState()
{
    self.forcespectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
}

isInKillcam()
{
    return self.forcespectatorclient != -1 || self.killcamentity != -1;
}

isValidClass( var_0 )
{
    return isdefined( var_0 ) && var_0 != "";
}

getValueInRange( var_0, var_1, var_2 )
{
    if ( var_0 > var_2 )
        return var_2;
    else if ( var_0 < var_1 )
        return var_1;
    else
        return var_0;
}

waitForTimeOrNotifies( var_0 )
{
    var_1 = gettime();
    var_2 = ( gettime() - var_1 ) / 1000;

    if ( var_2 < var_0 )
    {
        wait(var_0 - var_2);
        return var_0;
    }
    else
        return var_2;
}

closeMenus()
{
    self closepopupmenu();
    self closeingamemenu();
}

logXPGains()
{
    if ( !isdefined( self.xpGains ) )
        return;

    var_0 = getarraykeys( self.xpGains );

    for ( var_1 = 0; var_1 < var_0.size; var_1++ )
    {
        var_2 = self.xpGains[var_0[var_1]];

        if ( !var_2 )
            continue;

        self logstring( "xp " + var_0[var_1] + ": " + var_2 );
    }
}

registerRoundSwitchDvar( var_0, var_1, var_2, var_3 )
{
    registerWatchDvarInt( "roundswitch", var_1 );
    var_0 = "scr_" + var_0 + "_roundswitch";
    level.roundswitchDvar = var_0;
    level.roundswitchMin = var_2;
    level.roundswitchMax = var_3;
    level.roundSwitch = getdvarint( var_0, var_1 );

    if ( level.roundSwitch < var_2 )
        level.roundSwitch = var_2;
    else if ( level.roundSwitch > var_3 )
        level.roundSwitch = var_3;
}

registerRoundLimitDvar( var_0, var_1 )
{
    registerWatchDvarInt( "roundlimit", var_1 );
}

registerWinLimitDvar( var_0, var_1 )
{
    registerWatchDvarInt( "winlimit", var_1 );
}

registerScoreLimitDvar( var_0, var_1 )
{
    registerWatchDvarInt( "scorelimit", var_1 );
}

registerTimeLimitDvar( var_0, var_1 )
{
    registerWatchDvarFloat( "timelimit", var_1 );
    makedvarserverinfo( "ui_timelimit", getTimeLimit() );
}

registerHalfTimeDvar( var_0, var_1 )
{
    registerWatchDvarInt( "halftime", var_1 );
    makedvarserverinfo( "ui_halftime", getHalfTime() );
}

registerNumLivesDvar( var_0, var_1 )
{
    registerWatchDvarInt( "numlives", var_1 );
}

setOverTimeLimitDvar( var_0 )
{
    makedvarserverinfo( "overtimeTimeLimit", var_0 );
}

get_damageable_player( var_0, var_1 )
{
    var_2 = spawnstruct();
    var_2.isPlayer = 1;
    var_2.isADestructable = 0;
    var_2.entity = var_0;
    var_2.damageCenter = var_1;
    return var_2;
}

get_damageable_sentry( var_0, var_1 )
{
    var_2 = spawnstruct();
    var_2.isPlayer = 0;
    var_2.isADestructable = 0;
    var_2.isSentry = 1;
    var_2.entity = var_0;
    var_2.damageCenter = var_1;
    return var_2;
}

get_damageable_grenade( var_0, var_1 )
{
    var_2 = spawnstruct();
    var_2.isPlayer = 0;
    var_2.isADestructable = 0;
    var_2.entity = var_0;
    var_2.damageCenter = var_1;
    return var_2;
}

get_damageable_mine( var_0, var_1 )
{
    var_2 = spawnstruct();
    var_2.isPlayer = 0;
    var_2.isADestructable = 0;
    var_2.entity = var_0;
    var_2.damageCenter = var_1;
    return var_2;
}

get_damageable_player_pos( var_0 )
{
    return var_0.origin + ( 0, 0, 32 );
}

getStanceCenter()
{
    if ( self getstance() == "crouch" )
        var_0 = self.origin + ( 0, 0, 24 );
    else if ( self getstance() == "prone" )
        var_0 = self.origin + ( 0, 0, 10 );
    else
        var_0 = self.origin + ( 0, 0, 32 );

    return var_0;
}

get_damageable_grenade_pos( var_0 )
{
    return var_0.origin;
}

getDvarVec( var_0 )
{
    var_1 = getdvar( var_0 );

    if ( var_1 == "" )
        return ( 0, 0, 0 );

    var_2 = strtok( var_1, " " );

    if ( var_2.size < 3 )
        return ( 0, 0, 0 );

    setdvar( "tempR", var_2[0] );
    setdvar( "tempG", var_2[1] );
    setdvar( "tempB", var_2[2] );
    return ( getdvarfloat( "tempR" ), getdvarfloat( "tempG" ), getdvarfloat( "tempB" ) );
}

strip_suffix( var_0, var_1 )
{
    if ( var_0.size <= var_1.size )
        return var_0;

    if ( getsubstr( var_0, var_0.size - var_1.size, var_0.size ) == var_1 )
        return getsubstr( var_0, 0, var_0.size - var_1.size );

    return var_0;
}

_takeWeaponsExcept( var_0 )
{
    var_1 = self getweaponslistall();

    foreach ( var_3 in var_1 )
    {
        if ( var_3 == var_0 )
        {
            continue;
            continue;
        }

        self takeweapon( var_3 );
    }
}

saveData()
{
    var_0 = spawnstruct();
    var_0.offhandClass = self getoffhandsecondaryclass();
    var_0.actionSlots = self.saved_actionSlotData;
    var_0.currentWeapon = self getcurrentweapon();
    var_1 = self getweaponslistall();
    var_0.weapons = [];

    foreach ( var_3 in var_1 )
    {
        if ( weaponinventorytype( var_3 ) == "exclusive" )
            continue;

        if ( weaponinventorytype( var_3 ) == "altmode" )
            continue;

        var_4 = spawnstruct();
        var_4.name = var_3;
        var_4.clipAmmoR = self getweaponammoclip( var_3, "right" );
        var_4.clipAmmoL = self getweaponammoclip( var_3, "left" );
        var_4.stockAmmo = self getweaponammostock( var_3 );

        if ( isdefined( self.throwingGrenade ) && self.throwingGrenade == var_3 )
            var_4.stockAmmo--;

        var_0.weapons[var_0.weapons.size] = var_4;
    }

    self.script_saveData = var_0;
}

restoreData()
{
    var_0 = self.script_saveData;
    self setoffhandsecondaryclass( var_0.offhandClass );

    foreach ( var_2 in var_0.weapons )
    {
        _giveWeapon( var_2.name, int( tablelookup( "mp/camoTable.csv", 1, self.loadoutPrimaryCamo, 0 ) ) );
        self setweaponammoclip( var_2.name, var_2.clipAmmoR, "right" );

        if ( issubstr( var_2.name, "akimbo" ) )
            self setweaponammoclip( var_2.name, var_2.clipAmmoL, "left" );

        self setweaponammostock( var_2.name, var_2.stockAmmo );
    }

    foreach ( var_6, var_5 in var_0.actionSlots )
        _setActionSlot( var_6, var_5.type, var_5.item );

    if ( self getcurrentweapon() == "none" )
    {
        var_2 = var_0.currentWeapon;

        if ( var_2 == "none" )
            var_2 = common_scripts\utility::getLastWeapon();

        self setspawnweapon( var_2 );
        self switchtoweapon( var_2 );
    }
}

_setActionSlot( var_0, var_1, var_2 )
{
    self.saved_actionSlotData[var_0].type = var_1;
    self.saved_actionSlotData[var_0].item = var_2;
    self setactionslot( var_0, var_1, var_2 );
}

isFloat( var_0 )
{
    if ( int( var_0 ) != var_0 )
        return 1;

    return 0;
}

registerWatchDvarInt( var_0, var_1 )
{
    var_2 = "scr_" + level.gameType + "_" + var_0;
    level.watchDvars[var_2] = spawnstruct();
    level.watchDvars[var_2].value = getdvarint( var_2, var_1 );
    level.watchDvars[var_2].type = "int";
    level.watchDvars[var_2].notifyString = "update_" + var_0;
}

registerWatchDvarFloat( var_0, var_1 )
{
    var_2 = "scr_" + level.gameType + "_" + var_0;
    level.watchDvars[var_2] = spawnstruct();
    level.watchDvars[var_2].value = getdvarfloat( var_2, var_1 );
    level.watchDvars[var_2].type = "float";
    level.watchDvars[var_2].notifyString = "update_" + var_0;
}

registerWatchDvar( var_0, var_1 )
{
    var_2 = "scr_" + level.gameType + "_" + var_0;
    level.watchDvars[var_2] = spawnstruct();
    level.watchDvars[var_2].value = getdvar( var_2, var_1 );
    level.watchDvars[var_2].type = "string";
    level.watchDvars[var_2].notifyString = "update_" + var_0;
}

setOverrideWatchDvar( var_0, var_1 )
{
    var_0 = "scr_" + level.gameType + "_" + var_0;
    level.overrideWatchDvars[var_0] = var_1;
}

getWatchedDvar( var_0 )
{
    var_0 = "scr_" + level.gameType + "_" + var_0;

    if ( isdefined( level.overrideWatchDvars ) && isdefined( level.overrideWatchDvars[var_0] ) )
        return level.overrideWatchDvars[var_0];

    return level.watchDvars[var_0].value;
}

updateWatchedDvars()
{
    while ( game["state"] == "playing" )
    {
        var_0 = getarraykeys( level.watchDvars );

        foreach ( var_2 in var_0 )
        {
            if ( level.watchDvars[var_2].type == "string" )
                var_3 = getProperty( var_2, level.watchDvars[var_2].value );
            else if ( level.watchDvars[var_2].type == "float" )
                var_3 = getFloatProperty( var_2, level.watchDvars[var_2].value );
            else
                var_3 = getIntProperty( var_2, level.watchDvars[var_2].value );

            if ( var_3 != level.watchDvars[var_2].value )
            {
                level.watchDvars[var_2].value = var_3;
                level notify( level.watchDvars[var_2].notifyString,  var_3  );
            }
        }

        wait 1.0;
    }
}

isRoundBased()
{
    if ( !level.teamBased )
        return 0;

    if ( getWatchedDvar( "winlimit" ) != 1 && getWatchedDvar( "roundlimit" ) != 1 )
        return 1;

    return 0;
}

isLastRound()
{
    if ( !level.teamBased )
        return 1;

    if ( getWatchedDvar( "roundlimit" ) > 1 && game["roundsPlayed"] >= getWatchedDvar( "roundlimit" ) - 1 )
        return 1;

    if ( getWatchedDvar( "winlimit" ) > 1 && game["roundsWon"]["allies"] >= getWatchedDvar( "winlimit" ) - 1 && game["roundsWon"]["axis"] >= getWatchedDvar( "winlimit" ) - 1 )
        return 1;

    return 0;
}

wasOnlyRound()
{
    if ( !level.teamBased )
        return 1;

    if ( isdefined( level.onlyRoundOverride ) )
        return 0;

    if ( getWatchedDvar( "winlimit" ) == 1 && hitWinLimit() )
        return 1;

    if ( getWatchedDvar( "roundlimit" ) == 1 )
        return 1;

    return 0;
}

wasLastRound()
{
    if ( level.forcedEnd )
        return 1;

    if ( !level.teamBased )
        return 1;

    if ( hitRoundLimit() || hitWinLimit() )
        return 1;

    return 0;
}

hitRoundLimit()
{
    if ( getWatchedDvar( "roundlimit" ) <= 0 )
        return 0;

    return game["roundsPlayed"] >= getWatchedDvar( "roundlimit" );
}

hitScoreLimit()
{
    if ( isObjectiveBased() )
        return 0;

    if ( getWatchedDvar( "scorelimit" ) <= 0 )
        return 0;

    if ( level.teamBased )
    {
        if ( game["teamScores"]["allies"] >= getWatchedDvar( "scorelimit" ) || game["teamScores"]["axis"] >= getWatchedDvar( "scorelimit" ) )
            return 1;
    }
    else
    {
        for ( var_0 = 0; var_0 < level.players.size; var_0++ )
        {
            var_1 = level.players[var_0];

            if ( isdefined( var_1.score ) && var_1.score >= getWatchedDvar( "scorelimit" ) )
                return 1;
        }
    }

    return 0;
}

hitWinLimit()
{
    if ( getWatchedDvar( "winlimit" ) <= 0 )
        return 0;

    if ( !level.teamBased )
        return 1;

    if ( getRoundsWon( "allies" ) >= getWatchedDvar( "winlimit" ) || getRoundsWon( "axis" ) >= getWatchedDvar( "winlimit" ) )
        return 1;

    return 0;
}

getScoreLimit()
{
    if ( isRoundBased() )
    {
        if ( getWatchedDvar( "roundlimit" ) )
            return getWatchedDvar( "roundlimit" );
        else
            return getWatchedDvar( "winlimit" );
    }
    else
        return getWatchedDvar( "scorelimit" );
}

getRoundsWon( var_0 )
{
    return game["roundsWon"][var_0];
}

isObjectiveBased()
{
    return level.objectiveBased;
}

getTimeLimit()
{
    if ( inOvertime() && ( !isdefined( game["inNukeOvertime"] ) || !game["inNukeOvertime"] ) )
    {
        var_0 = int( getdvar( "overtimeTimeLimit" ) );

        if ( isdefined( var_0 ) )
        {
            return var_0;
            return;
        }

        return 1;
        return;
    }
    else if ( isdefined( level.dd ) && level.dd && isdefined( level.bombexploded ) && level.bombexploded > 0 )
        return getWatchedDvar( "timelimit" ) + level.bombexploded * level.ddTimeToAdd;
    else
        return getWatchedDvar( "timelimit" );
}

getHalfTime()
{
    if ( inOvertime() )
        return 0;
    else if ( isdefined( game["inNukeOvertime"] ) && game["inNukeOvertime"] )
        return 0;
    else
        return getWatchedDvar( "halftime" );
}

inOvertime()
{
    return isdefined( game["status"] ) && game["status"] == "overtime";
}

gameHasStarted()
{
    if ( level.teamBased )
        return level.hasSpawned["axis"] && level.hasSpawned["allies"];
    else
        return level.maxPlayerCount > 1;
}

getAverageOrigin( var_0 )
{
    var_1 = ( 0, 0, 0 );

    if ( !var_0.size )
        return undefined;

    foreach ( var_3 in var_0 )
        var_1 += var_3.origin;

    var_5 = int( var_1[0] / var_0.size );
    var_6 = int( var_1[1] / var_0.size );
    var_7 = int( var_1[2] / var_0.size );
    var_1 = ( var_5, var_6, var_7 );
    return var_1;
}

getLivingPlayers( var_0 )
{
    var_1 = [];

    foreach ( var_3 in level.players )
    {
        if ( !isalive( var_3 ) )
            continue;

        if ( level.teamBased && isdefined( var_0 ) )
        {
            if ( var_0 == var_3.pers["team"] )
                var_1[var_1.size] = var_3;

            continue;
        }

        var_1[var_1.size] = var_3;
    }

    return var_1;
}

setUsingRemote( var_0 )
{
    if ( isdefined( self.carryIcon ) )
        self.carryIcon.alpha = 0;

    self.usingRemote = var_0;
    common_scripts\utility::_disableOffhandWeapons();
    self notify( "using_remote" );
}

getRemoteName()
{
    return self.usingRemote;
}

freezeControlsWrapper( var_0 )
{
    if ( isdefined( level.hostMigrationTimer ) )
    {
        self freezecontrols( 1 );
        return;
    }

    self freezecontrols( var_0 );
}

clearUsingRemote()
{
    if ( isdefined( self.carryIcon ) )
        self.carryIcon.alpha = 1;

    self.usingRemote = undefined;
    common_scripts\utility::_enableOffhandWeapons();
    var_0 = self getcurrentweapon();

    if ( var_0 == "none" || isKillstreakWeapon( var_0 ) )
        self switchtoweapon( common_scripts\utility::getLastWeapon() );

    freezeControlsWrapper( 0 );
    self notify( "stopped_using_remote" );
}

isUsingRemote()
{
    return isdefined( self.usingRemote );
}

queueCreate( var_0 )
{
    if ( !isdefined( level.queues ) )
        level.queues = [];

    level.queues[var_0] = [];
}

queueAdd( var_0, var_1 )
{
    level.queues[var_0][level.queues[var_0].size] = var_1;
}

queueRemoveFirst( var_0 )
{
    var_1 = undefined;
    var_2 = [];

    foreach ( var_4 in level.queues[var_0] )
    {
        if ( !isdefined( var_4 ) )
            continue;

        if ( !isdefined( var_1 ) )
        {
            var_1 = var_4;
            continue;
        }

        var_2[var_2.size] = var_4;
    }

    level.queues[var_0] = var_2;
    return var_1;
}

_giveWeapon( var_0, var_1, var_2 )
{
    if ( !isdefined( var_1 ) )
        var_1 = -1;

    if ( issubstr( var_0, "_akimbo" ) || isdefined( var_2 ) && var_2 == 1 )
        self giveweapon( var_0, var_1, 1 );
    else
        self giveweapon( var_0, var_1, 0 );
}

_hasPerk( var_0 )
{
    if ( isdefined( self.perks[var_0] ) )
        return 1;

    return 0;
}

givePerk( var_0, var_1 )
{
    if ( issubstr( var_0, "_mp" ) )
    {
        switch ( var_0 )
        {
            case "frag_grenade_mp":
                self setoffhandprimaryclass( "frag" );
                break;
            case "throwingknife_mp":
                self setoffhandprimaryclass( "throwingknife" );
                break;
            case "trophy_mp":
                self setoffhandsecondaryclass( "flash" );
                break;
        }

        _giveWeapon( var_0, 0 );
        self givestartammo( var_0 );
        _setPerk( var_0, var_1 );
        return;
    }

    if ( issubstr( var_0, "specialty_weapon_" ) )
    {
        _setPerk( var_0, var_1 );
        return;
    }

    _setPerk( var_0, var_1 );
    _setExtraPerks( var_0 );
}

_setPerk( var_0, var_1 )
{
    self.perks[var_0] = 1;

    if ( isdefined( level.perkSetFuncs[var_0] ) )
        self thread [[ level.perkSetFuncs[var_0] ]]();

    self setperk( var_0, !isdefined( level.scriptPerks[var_0] ), var_1 );
}

_setExtraPerks( var_0 )
{
    if ( var_0 == "specialty_coldblooded" )
        givePerk( "specialty_heartbreaker", 0 );

    if ( var_0 == "specialty_fasterlockon" )
        givePerk( "specialty_armorpiercing", 0 );

    if ( var_0 == "specialty_spygame" )
        givePerk( "specialty_empimmune", 0 );

    if ( var_0 == "specialty_rollover" )
        givePerk( "specialty_assists", 0 );
}

_unsetPerk( var_0 )
{
    self.perks[var_0] = undefined;

    if ( isdefined( level.perkUnsetFuncs[var_0] ) )
        self thread [[ level.perkUnsetFuncs[var_0] ]]();

    self unsetperk( var_0, !isdefined( level.scriptPerks[var_0] ) );
}

_unsetExtraPerks( var_0 )
{
    if ( var_0 == "specialty_bulletaccuracy" )
        _unsetPerk( "specialty_steadyaimpro" );

    if ( var_0 == "specialty_coldblooded" )
        _unsetPerk( "specialty_heartbreaker" );

    if ( var_0 == "specialty_fasterlockon" )
        _unsetPerk( "specialty_armorpiercing" );

    if ( var_0 == "specialty_spygame" )
        _unsetPerk( "specialty_empimmune" );

    if ( var_0 == "specialty_rollover" )
        _unsetPerk( "specialty_assists" );
}

_clearPerks()
{
    foreach ( var_2, var_1 in self.perks )
    {
        if ( isdefined( level.perkUnsetFuncs[var_2] ) )
            self [[ level.perkUnsetFuncs[var_2] ]]();
    }

    self.perks = [];
    self clearperks();
}

quickSort( var_0 )
{
    return quickSortMid( var_0, 0, var_0.size - 1 );
}

quickSortMid( var_0, var_1, var_2 )
{
    var_3 = var_1;
    var_4 = var_2;

    if ( var_2 - var_1 >= 1 )
    {
        var_5 = var_0[var_1];

        while ( var_4 > var_3 )
        {
            while ( var_0[var_3] <= var_5 && var_3 <= var_2 && var_4 > var_3 )
                var_3++;

            while ( var_0[var_4] > var_5 && var_4 >= var_1 && var_4 >= var_3 )
                var_4--;

            if ( var_4 > var_3 )
                var_0 = swap( var_0, var_3, var_4 );
        }

        var_0 = swap( var_0, var_1, var_4 );
        var_0 = quickSortMid( var_0, var_1, var_4 - 1 );
        var_0 = quickSortMid( var_0, var_4 + 1, var_2 );
    }
    else
        return var_0;

    return var_access_5;
}

swap( var_0, var_1, var_2 )
{
    var_3 = var_0[var_1];
    var_0[var_1] = var_0[var_2];
    var_0[var_2] = var_3;
    return var_0;
}

_suicide()
{
    if ( isUsingRemote() && !isdefined( self.fauxDead ) )
        thread maps\mp\gametypes\_damage::PlayerKilled_internal( self, self, self, 10000, "MOD_SUICIDE", "frag_grenade_mp", ( 0, 0, 0 ), "none", 0, 1116, 1 );
    else if ( !isUsingRemote() && !isdefined( self.fauxDead ) )
        self suicide();
}

isReallyAlive( var_0 )
{
    if ( isalive( var_0 ) && !isdefined( var_0.fauxDead ) )
        return 1;

    return 0;
}

playDeathSound()
{
    var_0 = randomintrange( 1, 8 );

    if ( self.team == "axis" )
        self playsound( "generic_death_russian_" + var_0 );
    else
        self playsound( "generic_death_american_" + var_0 );
}

rankingEnabled()
{
    return level.rankedmatch && !self.usingOnlineDataOffline;
}

privateMatch()
{
    return level.onlinegame && getdvarint( "xblive_privatematch" );
}

matchMakingGame()
{
    return level.onlinegame && !getdvarint( "xblive_privatematch" );
}

setAltSceneObj( var_0, var_1, var_2, var_3 )
{

}

endSceneOnDeath( var_0 )
{
    self endon( "altscene" );
    var_0 waittill( "death" );
    self notify( "end_altScene" );
}

getGametypeNumLives()
{
    return getWatchedDvar( "numlives" );
}

giveCombatHigh( var_0 )
{
    self.combatHigh = var_0;
}

arrayInsertion( var_0, var_1, var_2 )
{
    if ( var_0.size != 0 )
    {
        for ( var_3 = var_0.size; var_3 >= var_2; var_3-- )
            var_0[var_3 + 1] = var_0[var_3];
    }

    var_0[var_2] = var_1;
}

getProperty( var_0, var_1 )
{
    var_2 = var_1;
    var_2 = getdvar( var_0, var_1 );
    return var_2;
}

getIntProperty( var_0, var_1 )
{
    var_2 = var_1;
    var_2 = getdvarint( var_0, var_1 );
    return var_2;
}

getFloatProperty( var_0, var_1 )
{
    var_2 = var_1;
    var_2 = getdvarfloat( var_0, var_1 );
    return var_2;
}

statusMenu( var_0 )
{
    self endon( "disconnect" );

    if ( !isdefined( self._statusMenu ) )
        self.statusMenu = 0;

    if ( self.statusMenu )
        return;

    self.statusMenu = 1;
    self openpopupmenu( "status_update" );
    wait(var_0);
    self closepopupmenu( "status_update" );
    wait 10.0;
    self.statusMenu = 0;
}

isChangingWeapon()
{
    return isdefined( self.changingWeapon );
}

killShouldAddToKillstreak( var_0 )
{
    if ( _hasPerk( "specialty_explosivebullets" ) )
        return 0;

    if ( isdefined( self.isJuggernautRecon ) && self.isJuggernautRecon == 1 )
        return 0;

    if ( isdefined( level.killstreakChainingWeapons[var_0] ) )
    {
        for ( var_1 = 1; var_1 < 4; var_1++ )
        {
            if ( isdefined( self.pers["killstreaks"][var_1] ) && isdefined( self.pers["killstreaks"][var_1].streakName ) && self.pers["killstreaks"][var_1].streakName == level.killstreakChainingWeapons[var_0] && isdefined( self.pers["killstreaks"][var_1].lifeId ) && self.pers["killstreaks"][var_1].lifeId == self.pers["deaths"] )
                return streakShouldChain( level.killstreakChainingWeapons[var_0] );
        }

        return 0;
    }

    return !isKillstreakWeapon( var_0 );
}

streakShouldChain( var_0 )
{
    var_1 = maps\mp\killstreaks\_killstreaks::getStreakCost( var_0 );
    var_2 = maps\mp\killstreaks\_killstreaks::getNextStreakName();
    var_3 = maps\mp\killstreaks\_killstreaks::getStreakCost( var_2 );
    return var_1 < var_3;
}

isJuggernaut()
{
    if ( isdefined( self.isJuggernaut ) && self.isJuggernaut == 1 )
        return 1;

    if ( isdefined( self.isJuggernautDef ) && self.isJuggernautDef == 1 )
        return 1;

    if ( isdefined( self.isJuggernautGL ) && self.isJuggernautGL == 1 )
        return 1;

    if ( isdefined( self.isJuggernautRecon ) && self.isJuggernautRecon == 1 )
        return 1;

    return 0;
}

isKillstreakWeapon( var_0 )
{
    if ( !isdefined( var_0 ) )
        return 0;

    if ( var_0 == "none" )
        return 0;

    var_1 = strtok( var_0, "_" );
    var_2 = 0;

    if ( var_0 != "destructible_car" && var_0 != "barrel_mp" )
    {
        foreach ( var_4 in var_1 )
        {
            if ( var_4 == "mp" )
            {
                var_2 = 1;
                break;
            }
        }

        if ( !var_2 )
            var_0 += "_mp";
    }

    if ( issubstr( var_0, "destructible" ) )
        return 0;

    if ( issubstr( var_0, "killstreak" ) )
        return 1;

    if ( maps\mp\killstreaks\_airdrop::isAirdropMarker( var_0 ) )
        return 1;

    if ( isdefined( level.killstreakWeildWeapons[var_0] ) )
        return 1;

    if ( isdefined( weaponinventorytype( var_0 ) ) && weaponinventorytype( var_0 ) == "exclusive" && ( var_0 != "destructible_car" && var_0 != "barrel_mp" ) )
        return 1;

    return 0;
}

isEnvironmentWeapon( var_0 )
{
    if ( !isdefined( var_0 ) )
        return 0;

    if ( var_0 == "turret_minigun_mp" )
        return 1;

    if ( issubstr( var_0, "_bipod_" ) )
        return 1;

    return 0;
}

isjuggernautweapon( var_0 )
{
    if ( !isdefined( var_0 ) )
        return 0;

    switch ( var_0 )
    {
        case "iw5_m60jugg_mp":
        case "iw5_mp412jugg_mp":
        case "iw5_riotshieldjugg_mp":
        case "iw5_usp45jugg_mp":
            return 1;
    }

    return 0;
}

getWeaponClass( var_0 )
{
    var_1 = strtok( var_0, "_" );

    if ( var_1[0] == "iw5" )
    {
        var_2 = var_1[0] + "_" + var_1[1];
        var_3 = tablelookup( "mp/statstable.csv", 4, var_2, 2 );
    }
    else if ( var_1[0] == "alt" )
    {
        var_2 = var_1[1] + "_" + var_1[2];
        var_3 = tablelookup( "mp/statstable.csv", 4, var_2, 2 );
    }
    else
        var_3 = tablelookup( "mp/statstable.csv", 4, var_1[0], 2 );

    if ( var_3 == "" )
    {
        var_4 = strip_suffix( var_0, "_mp" );
        var_3 = tablelookup( "mp/statstable.csv", 4, var_4, 2 );
    }

    if ( isEnvironmentWeapon( var_0 ) )
        var_3 = "weapon_mg";
    else if ( isKillstreakWeapon( var_0 ) )
        var_3 = "killstreak";
    else if ( isDeathStreakWeapon( var_0 ) )
        var_3 = "deathstreak";
    else if ( var_0 == "none" )
        var_3 = "other";
    else if ( var_3 == "" )
        var_3 = "other";

    return var_3;
}

isDeathStreakWeapon( var_0 )
{
    if ( var_0 == "c4death_mp" || var_0 == "frag_grenade_short_mp" )
        return 1;
    else
        return 0;
}

getBaseWeaponName( var_0 )
{
    var_1 = strtok( var_0, "_" );

    if ( var_1[0] == "iw5" )
        var_1[0] = var_1[0] + "_" + var_1[1];
    else if ( var_1[0] == "alt" )
        var_1[0] = var_1[1] + "_" + var_1[2];

    return var_1[0];
}

fixAkimboString( var_0, var_1 )
{
    if ( !isdefined( var_1 ) )
        var_1 = 1;

    var_2 = 0;

    for ( var_3 = 0; var_3 < var_0.size; var_3++ )
    {
        if ( var_0[var_3] == "a" && var_0[var_3 + 1] == "k" && var_0[var_3 + 2] == "i" && var_0[var_3 + 3] == "m" && var_0[var_3 + 4] == "b" && var_0[var_3 + 5] == "o" )
        {
            var_2 = var_3;
            break;
        }
    }

    var_0 = getsubstr( var_0, 0, var_2 ) + getsubstr( var_0, var_2 + 6, var_0.size );

    if ( var_1 )
        var_0 += "_akimbo";

    return var_0;
}

playSoundinSpace( var_0, var_1 )
{
    playsoundatpos( var_1, var_0 );
}

limitDecimalPlaces( var_0, var_1 )
{
    var_2 = 1;

    for ( var_3 = 0; var_3 < var_1; var_3++ )
        var_2 *= 10;

    var_4 = var_0 * var_2;
    var_4 = int( var_4 );
    var_4 /= var_2;
    return var_4;
}

roundDecimalPlaces( var_0, var_1, var_2 )
{
    if ( !isdefined( var_2 ) )
        var_2 = "nearest";

    var_3 = 1;

    for ( var_4 = 0; var_4 < var_1; var_4++ )
        var_3 *= 10;

    var_5 = var_0 * var_3;

    if ( var_2 == "up" )
        var_6 = ceil( var_5 );
    else if ( var_2 == "down" )
        var_6 = floor( var_5 );
    else
        var_6 = var_5 + 0.5;

    var_5 = int( var_6 );
    var_5 /= var_3;
    return var_5;
}

playerForClientId( var_0 )
{
    foreach ( var_2 in level.players )
    {
        if ( var_2.clientid == var_0 )
            return var_2;
    }

    return undefined;
}

isRested()
{
    if ( !rankingEnabled() )
        return 0;

    return self getplayerdata( "restXPGoal" ) > self getplayerdata( "experience" );
}

stringToFloat( var_0 )
{
    var_1 = strtok( var_0, "." );
    var_2 = int( var_1[0] );

    if ( isdefined( var_1[1] ) )
    {
        var_3 = 1;

        for ( var_4 = 0; var_4 < var_1[1].size; var_4++ )
            var_3 *= 0.1;

        var_2 += int( var_1[1] ) * var_3;
    }

    return var_2;
}

setSelfUsable( var_0 )
{
    self makeusable();

    foreach ( var_2 in level.players )
    {
        if ( var_2 != var_0 )
        {
            self disableplayeruse( var_2 );
            continue;
        }

        self enableplayeruse( var_2 );
    }
}

makeTeamUsable( var_0 )
{
    self makeusable();
    thread _updateTeamUsable( var_0 );
}

_updateTeamUsable( var_0 )
{
    self endon( "death" );

    for (;;)
    {
        foreach ( var_2 in level.players )
        {
            if ( var_2.team == var_0 )
            {
                self enableplayeruse( var_2 );
                continue;
            }

            self disableplayeruse( var_2 );
        }

        level waittill( "joined_team" );
    }
}

makeEnemyUsable( var_0 )
{
    self makeusable();
    thread _updateEnemyUsable( var_0 );
}

_updateEnemyUsable( var_0 )
{
    self endon( "death" );
    var_1 = var_0.team;

    for (;;)
    {
        if ( level.teamBased )
        {
            foreach ( var_3 in level.players )
            {
                if ( var_3.team != var_1 )
                {
                    self enableplayeruse( var_3 );
                    continue;
                }

                self disableplayeruse( var_3 );
            }
        }
        else
        {
            foreach ( var_3 in level.players )
            {
                if ( var_3 != var_0 )
                {
                    self enableplayeruse( var_3 );
                    continue;
                }

                self disableplayeruse( var_3 );
            }
        }

        level waittill( "joined_team" );
    }
}

getNextLifeId()
{
    var_0 = getmatchdata( "lifeCount" );

    if ( var_0 < level.MaxLives )
        setmatchdata( "lifeCount", var_0 + 1 );

    return var_0;
}

initGameFlags()
{
    if ( !isdefined( game["flags"] ) )
        game["flags"] = [];
}

gameFlagInit( var_0, var_1 )
{
    game["flags"][var_0] = var_1;
}

gameFlag( var_0 )
{
    return game["flags"][var_0];
}

gameFlagSet( var_0 )
{
    game["flags"][var_0] = 1;
    level notify( var_0 );
}

gameFlagClear( var_0 )
{
    game["flags"][var_0] = 0;
}

gameFlagWait( var_0 )
{
    while ( !gameFlag( var_0 ) )
        level waittill( var_0 );
}

isPrimaryDamage( var_0 )
{
    if ( var_0 == "MOD_RIFLE_BULLET" || var_0 == "MOD_PISTOL_BULLET" )
        return 1;

    return 0;
}

isBulletDamage( var_0 )
{
    var_1 = "MOD_RIFLE_BULLET MOD_PISTOL_BULLET MOD_HEAD_SHOT";

    if ( issubstr( var_1, var_0 ) )
        return 1;

    return 0;
}

initLevelFlags()
{
    if ( !isdefined( level.levelFlags ) )
        level.levelFlags = [];
}

levelFlagInit( var_0, var_1 )
{
    level.levelFlags[var_0] = var_1;
}

levelFlag( var_0 )
{
    return level.levelFlags[var_0];
}

levelFlagSet( var_0 )
{
    level.levelFlags[var_0] = 1;
    level notify( var_0 );
}

levelFlagClear( var_0 )
{
    level.levelFlags[var_0] = 0;
    level notify( var_0 );
}

levelFlagWait( var_0 )
{
    while ( !levelFlag( var_0 ) )
        level waittill( var_0 );
}

levelFlagWaitOpen( var_0 )
{
    while ( levelFlag( var_0 ) )
        level waittill( var_0 );
}

getWeaponAttachments( var_0 )
{
    var_1 = strtok( var_0, "_" );
    var_2 = [];

    foreach ( var_4 in var_1 )
    {
        if ( issubstr( var_4, "scopevz" ) )
            var_2[var_2.size] = "vzscope";

        if ( maps\mp\gametypes\_class::isValidAttachment( var_4, 0 ) )
            var_2[var_2.size] = var_4;
    }

    return var_2;
}

isEMPed()
{
    if ( self.team == "spectator" )
        return 0;

    if ( level.teamBased )
        return level.teamEMPed[self.team] || isdefined( self.empGrenaded ) && self.empGrenaded || level.teamNukeEMPed[self.team];
    else
        return isdefined( level.EMPPlayer ) && level.EMPPlayer != self || isdefined( self.empGrenaded ) && self.empGrenaded || isdefined( level.nukeInfo.player ) && self != level.nukeInfo.player && level.teamNukeEMPed[self.team];
}

isAirDenied()
{
    return 0;
}

isNuked()
{
    if ( self.team == "spectator" )
        return 0;

    return isdefined( self.nuked );
}

getPlayerForGuid( var_0 )
{
    foreach ( var_2 in level.players )
    {
        if ( var_2.guid == var_0 )
            return var_2;
    }

    return undefined;
}

teamPlayerCardSplash( var_0, var_1, var_2 )
{
    if ( level.hardcoreMode )
        return;

    foreach ( var_4 in level.players )
    {
        if ( isdefined( var_2 ) && var_4.team != var_2 )
            continue;

        var_4 thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( var_0, var_1 );
    }
}

isCACPrimaryWeapon( var_0 )
{
    switch ( getWeaponClass( var_0 ) )
    {
        case "weapon_smg":
        case "weapon_assault":
        case "weapon_riot":
        case "weapon_sniper":
        case "weapon_lmg":
        case "weapon_shotgun":
            return 1;
        default:
            return 0;
    }
}

isCACSecondaryWeapon( var_0 )
{
    switch ( getWeaponClass( var_0 ) )
    {
        case "weapon_projectile":
        case "weapon_pistol":
        case "weapon_machine_pistol":
            return 1;
        default:
            return 0;
    }
}

getLastLivingPlayer( var_0 )
{
    var_1 = undefined;

    foreach ( var_3 in level.players )
    {
        if ( isdefined( var_0 ) && var_3.team != var_0 )
            continue;

        if ( !isReallyAlive( var_3 ) && !var_3 maps\mp\gametypes\_playerlogic::maySpawn() )
            continue;

        var_1 = var_3;
    }

    return var_1;
}

getPotentialLivingPlayers()
{
    var_0 = [];

    foreach ( var_2 in level.players )
    {
        if ( !isReallyAlive( var_2 ) && !var_2 maps\mp\gametypes\_playerlogic::maySpawn() )
            continue;

        var_0[var_0.size] = var_2;
    }

    return var_0;
}

waitTillRecoveredHealth( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    var_2 = 0;

    if ( !isdefined( var_1 ) )
        var_1 = 0.05;

    if ( !isdefined( var_0 ) )
        var_0 = 0;

    for (;;)
    {
        if ( self.health != self.maxHealth )
            var_2 = 0;
        else
            var_2 += var_1;

        wait(var_1);

        if ( self.health == self.maxHealth && var_2 >= var_0 )
            break;
    }

    return;
}

attachmentMap( var_0, var_1 )
{
    var_2 = tablelookup( "mp/statstable.csv", 4, var_1, 2 );

    switch ( var_2 )
    {
        case "weapon_smg":
            if ( var_0 == "reflex" )
                return "reflexsmg";
            else if ( var_0 == "eotech" )
                return "eotechsmg";
            else if ( var_0 == "acog" )
                return "acogsmg";
            else if ( var_0 == "thermal" )
                return "thermalsmg";
        case "weapon_lmg":
            if ( var_0 == "reflex" )
                return "reflexlmg";
            else if ( var_0 == "eotech" )
                return "eotechlmg";
        case "weapon_machine_pistol":
            if ( var_0 == "reflex" )
                return "reflexsmg";
            else if ( var_0 == "eotech" )
                return "eotechsmg";
        default:
            return var_0;
    }
}

validateAttachment( var_0 )
{
    switch ( var_0 )
    {
        case "silencer02":
        case "silencer03":
            return "silencer";
        case "gp25":
        case "m320":
            return "gl";
        case "reflexsmg":
        case "reflexlmg":
            return "reflex";
        case "eotechsmg":
        case "eotechlmg":
            return "eotech";
        case "acogsmg":
            return "acog";
        case "thermalsmg":
            return "thermal";
        default:
            return var_0;
    }
}

_objective_delete( var_0 )
{
    objective_delete( var_0 );

    if ( !isdefined( level.reclaimedReservedObjectives ) )
    {
        level.reclaimedReservedObjectives = [];
        level.reclaimedReservedObjectives[0] = var_0;
    }
    else
        level.reclaimedReservedObjectives[level.reclaimedReservedObjectives.size] = var_0;
}

touchingBadTrigger()
{
    var_0 = getentarray( "trigger_hurt", "classname" );

    foreach ( var_2 in var_0 )
    {
        if ( self istouching( var_2 ) )
            return 1;
    }

    var_4 = getentarray( "radiation", "targetname" );

    foreach ( var_2 in var_4 )
    {
        if ( self istouching( var_2 ) )
            return 1;
    }

    return 0;
}

setThirdPersonDOF( var_0 )
{
    if ( var_0 )
        self setdepthoffield( 0, 110, 512, 4096, 6, 1.8 );
    else
        self setdepthoffield( 0, 0, 512, 512, 4, 0 );
}

killTrigger( var_0, var_1, var_2 )
{
    var_3 = spawn( "trigger_radius", var_0, 0, var_1, var_2 );

    for (;;)
    {
        var_3 waittill( "trigger",  var_4  );

        if ( !isplayer( var_4 ) )
            continue;

        var_4 suicide();
    }
}

findIsFacing( var_0, var_1, var_2 )
{
    var_3 = cos( var_2 );
    var_4 = anglestoforward( var_0.angles );
    var_5 = var_1.origin - var_0.origin;
    var_4 *= ( 1, 1, 0 );
    var_5 *= ( 1, 1, 0 );
    var_5 = vectornormalize( var_5 );
    var_4 = vectornormalize( var_4 );
    var_6 = vectordot( var_5, var_4 );

    if ( var_6 >= var_3 )
        return 1;
    else
        return 0;
}

combineArrays( var_0, var_1 )
{
    if ( !isdefined( var_0 ) && isdefined( var_1 ) )
        return var_1;

    if ( !isdefined( var_1 ) && isdefined( var_0 ) )
        return var_0;

    foreach ( var_3 in var_1 )
        var_0[var_0.size] = var_3;

    return var_0;
}

setRecoilScale( var_0, var_1 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 0;

    if ( !isdefined( self.recoilScale ) )
        self.recoilScale = var_0;
    else
        self.recoilScale = self.recoilScale + var_0;

    if ( isdefined( var_1 ) )
    {
        if ( isdefined( self.recoilScale ) && var_1 < self.recoilScale )
            var_1 = self.recoilScale;

        var_2 = 100 - var_1;
    }
    else
        var_2 = 100 - self.recoilScale;

    if ( var_2 < 0 )
        var_2 = 0;

    if ( var_2 > 100 )
        var_2 = 100;

    if ( var_2 == 100 )
    {
        self player_recoilscaleoff();
        return;
    }

    self player_recoilscaleon( var_2 );
}

cleanArray( var_0 )
{
    var_1 = [];

    foreach ( var_4, var_3 in var_0 )
    {
        if ( !isdefined( var_3 ) )
            continue;

        var_1[var_1.size] = var_0[var_4];
    }

    return var_1;
}

notUsableForJoiningPlayers( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    var_0 endon( "death" );

    for (;;)
    {
        level waittill( "player_spawned",  var_1  );

        if ( isdefined( var_1 ) && var_1 != var_0 )
            self disableplayeruse( var_1 );
    }
}

isStrStart( var_0, var_1 )
{
    return getsubstr( var_0, 0, var_1.size ) == var_1;
}

validateUseStreak()
{
    if ( isdefined( self.laststand ) && !_hasPerk( "specialty_finalstand" ) )
    {
        self iprintlnbold( &"MP_UNAVILABLE_IN_LASTSTAND" );
        return 0;
    }
    else if ( isdefined( level.civilianJetFlyBy ) )
    {
        self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
        return 0;
    }
    else if ( isUsingRemote() )
        return 0;
    else if ( isEMPed() )
        return 0;
    else
        return 1;
}

currentActiveVehicleCount( var_0 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 0;

    var_1 = var_0;

    if ( isdefined( level.helis ) )
        var_1 += level.helis.size;

    if ( isdefined( level.littleBirds ) )
        var_1 += level.littleBirds.size;

    if ( isdefined( level.ugvs ) )
        var_1 += level.ugvs.size;

    return var_1;
}

maxVehiclesAllowed()
{
    return 8;
}

incrementFauxVehicleCount()
{
    level.fauxVehicleCount++;
}

decrementFauxVehicleCount()
{
    level.fauxVehicleCount--;

    if ( level.fauxVehicleCount < 0 )
        level.fauxVehicleCount = 0;
}

lightWeightScalar()
{
    return 1.1;
}

allowTeamChoice()
{
    var_0 = int( tablelookup( "mp/gametypesTable.csv", 0, level.gameType, 4 ) );
    return var_0;
}

allowClassChoice()
{
    var_0 = int( tablelookup( "mp/gametypesTable.csv", 0, level.gameType, 5 ) );
    return var_0;
}

isBuffUnlockedForWeapon( var_0, var_1 )
{
    var_2 = 4;
    var_3 = 0;
    var_4 = 4;
    var_5 = self getplayerdata( "weaponRank", var_1 );
    var_6 = int( tablelookup( "mp/weaponRankTable.csv", var_3, getWeaponClass( var_1 ), var_4 ) );
    var_7 = tablelookup( "mp/weaponRankTable.csv", var_6, var_0, var_2 );

    if ( var_7 != "" )
    {
        if ( var_5 >= int( var_7 ) )
            return 1;
    }

    return 0;
}

isBuffEquippedOnWeapon( var_0, var_1 )
{
    if ( isdefined( self.loadoutPrimary ) && self.loadoutPrimary == var_1 )
    {
        if ( isdefined( self.loadoutPrimaryBuff ) && self.loadoutPrimaryBuff == var_0 )
            return 1;
    }
    else if ( isdefined( self.loadoutSecondary ) && self.loadoutSecondary == var_1 )
    {
        if ( isdefined( self.loadoutSecondaryBuff ) && self.loadoutSecondaryBuff == var_0 )
            return 1;
    }

    return 0;
}

setCommonRulesFromMatchRulesData( var_0 )
{
    var_1 = getmatchrulesdata( "commonOption", "timeLimit" );
    setdynamicdvar( "scr_" + level.gameType + "_timeLimit", var_1 );
    registerTimeLimitDvar( level.gameType, var_1 );
    var_2 = getmatchrulesdata( "commonOption", "scoreLimit" );
    setdynamicdvar( "scr_" + level.gameType + "_scoreLimit", var_2 );
    registerScoreLimitDvar( level.gameType, var_2 );
    var_3 = getmatchrulesdata( "commonOption", "numLives" );
    setdynamicdvar( "scr_" + level.gameType + "_numLives", var_3 );
    registerNumLivesDvar( level.gameType, var_3 );
    setdynamicdvar( "scr_player_maxhealth", getmatchrulesdata( "commonOption", "maxHealth" ) );
    setdynamicdvar( "scr_player_healthregentime", getmatchrulesdata( "commonOption", "healthRegen" ) );
    level.matchRules_damageMultiplier = 0;
    level.matchRules_vampirism = 0;
    setdynamicdvar( "scr_game_spectatetype", getmatchrulesdata( "commonOption", "spectateModeAllowed" ) );
    setdynamicdvar( "scr_game_allowkillcam", getmatchrulesdata( "commonOption", "showKillcam" ) );
    setdynamicdvar( "scr_game_forceuav", getmatchrulesdata( "commonOption", "radarAlwaysOn" ) );
    setdynamicdvar( "scr_" + level.gameType + "_playerrespawndelay", getmatchrulesdata( "commonOption", "respawnDelay" ) );
    setdynamicdvar( "scr_" + level.gameType + "_waverespawndelay", getmatchrulesdata( "commonOption", "waveRespawnDelay" ) );
    setdynamicdvar( "scr_player_forcerespawn", getmatchrulesdata( "commonOption", "forceRespawn" ) );
    level.matchRules_allowCustomClasses = getmatchrulesdata( "commonOption", "allowCustomClasses" );
    setdynamicdvar( "scr_game_hardpoints", getmatchrulesdata( "commonOption", "allowKillstreaks" ) );
    setdynamicdvar( "scr_game_perks", getmatchrulesdata( "commonOption", "allowPerks" ) );
    setdynamicdvar( "g_hardcore", getmatchrulesdata( "commonOption", "hardcoreModeOn" ) );
    setdynamicdvar( "scr_thirdPerson", getmatchrulesdata( "commonOption", "forceThirdPersonView" ) );
    setdynamicdvar( "camera_thirdPerson", getmatchrulesdata( "commonOption", "forceThirdPersonView" ) );
    setdynamicdvar( "scr_game_onlyheadshots", getmatchrulesdata( "commonOption", "headshotsOnly" ) );

    if ( !isdefined( var_0 ) )
        setdynamicdvar( "scr_team_fftype", getmatchrulesdata( "commonOption", "friendlyFire" ) );

    if ( getmatchrulesdata( "commonOption", "hardcoreModeOn" ) )
    {
        setdynamicdvar( "scr_team_fftype", 1 );
        setdynamicdvar( "scr_player_maxhealth", 30 );
        setdynamicdvar( "scr_player_healthregentime", 0 );
        setdynamicdvar( "scr_player_respawndelay", 10 );
        setdynamicdvar( "scr_game_allowkillcam", 0 );
        setdynamicdvar( "scr_game_forceuav", 0 );
    }
}

reInitializeMatchRulesOnMigration()
{
    for (;;)
    {
        level waittill( "host_migration_begin" );
        [[ level.initializeMatchRules ]]();
    }
}

reinitializethermal( var_0 )
{
    self endon( "disconnect" );

    if ( isdefined( var_0 ) )
        var_0 endon( "death" );

    for (;;)
    {
        level waittill( "host_migration_begin" );

        if ( isdefined( self.lastvisionsetthermal ) )
            self visionsetthermalforplayer( self.lastvisionsetthermal, 0 );
    }
}

GetMatchRulesSpecialClass( var_0, var_1 )
{
    var_2 = [];
    var_2["loadoutPrimaryAttachment2"] = "none";
    var_2["loadoutSecondaryAttachment2"] = "none";
    var_2["loadoutPrimary"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 0, "weapon" );
    var_2["loadoutPrimaryAttachment"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 0, "attachment", 0 );
    var_2["loadoutPrimaryAttachment2"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 0, "attachment", 1 );
    var_2["loadoutPrimaryBuff"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 0, "buff" );
    var_2["loadoutPrimaryCamo"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 0, "camo" );
    var_2["loadoutPrimaryReticle"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 0, "reticle" );
    var_2["loadoutSecondary"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 1, "weapon" );
    var_2["loadoutSecondaryAttachment"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 1, "attachment", 0 );
    var_2["loadoutSecondaryAttachment2"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 1, "attachment", 1 );
    var_2["loadoutSecondaryBuff"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 1, "buff" );
    var_2["loadoutSecondaryCamo"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 1, "camo" );
    var_2["loadoutSecondaryReticle"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "weaponSetups", 1, "reticle" );
    var_2["loadoutEquipment"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "perks", 0 );
    var_2["loadoutOffhand"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "perks", 6 );

    if ( var_2["loadoutOffhand"] == "specialty_null" )
        var_2["loadoutOffhand"] = "none";

    var_2["loadoutPerk1"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "perks", 1 );
    var_2["loadoutPerk2"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "perks", 2 );
    var_2["loadoutPerk3"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "perks", 3 );
    var_3 = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "perks", 5 );

    if ( var_3 != "specialty_null" )
    {
        var_2["loadoutStreakType"] = var_3;
        var_2["loadoutKillstreak1"] = maps\mp\gametypes\_class::recipe_getKillstreak( var_0, var_1, var_3, 0 );
        var_2["loadoutKillstreak2"] = maps\mp\gametypes\_class::recipe_getKillstreak( var_0, var_1, var_3, 1 );
        var_2["loadoutKillstreak3"] = maps\mp\gametypes\_class::recipe_getKillstreak( var_0, var_1, var_3, 2 );
    }

    var_2["loadoutDeathstreak"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "class", "deathstreak" );
    var_2["loadoutJuggernaut"] = getmatchrulesdata( "defaultClasses", var_0, var_1, "juggernaut" );
    return var_2;
}

recipeClassApplyJuggernaut( var_0 )
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    if ( level.inGracePeriod && !self.hasDoneCombat )
        self waittill( "giveLoadout" );
    else
        self waittill( "spawned_player" );

    if ( var_0 )
    {
        self notify( "lost_juggernaut" );
        wait 0.5;
    }

    if ( !isdefined( self.isjuiced ) )
    {
        self.moveSpeedScaler = 0.7;
        maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    }

    self.juggmovespeedscaler = 0.7;
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
        self.juggernautOverlay setshader( level.juggSettings["juggernaut"].overlay, 640, 480 );
        self.juggernautOverlay.sort = -10;
        self.juggernautOverlay.archived = 1;
        self.juggernautOverlay.hidein3rdperson = 1;
    }

    thread maps\mp\killstreaks\_juggernaut::juggernautSounds();

    if ( level.gameType != "jugg" || isdefined( level.matchRules_showJuggRadarIcon ) && level.matchRules_showJuggRadarIcon )
        self setperk( "specialty_radarjuggernaut", 1, 0 );

    if ( isdefined( self.isJuggModeJuggernaut ) && self.isJuggModeJuggernaut )
    {
        var_1 = spawn( "script_model", self.origin );
        var_1.team = self.team;
        var_1 makeportableradar( self );
        self.personalRadar = var_1;
        thread maps\mp\killstreaks\_juggernaut::radarMover( var_1 );
    }

    level notify( "juggernaut_equipped",  self  );
    thread maps\mp\killstreaks\_juggernaut::juggRemover();
}
