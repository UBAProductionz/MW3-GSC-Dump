// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

getHighestScoringPlayer()
{
    updatePlacement();

    if ( !level.placement["all"].size )
        return undefined;
    else
        return level.placement["all"][0];
}

getLosingPlayers()
{
    updatePlacement();
    var_0 = level.placement["all"];
    var_1 = [];

    foreach ( var_3 in var_0 )
    {
        if ( var_3 == level.placement["all"][0] )
            continue;

        var_1[var_1.size] = var_3;
    }

    return var_1;
}

givePlayerScore( var_0, var_1, var_2, var_3, var_4 )
{
    if ( !isdefined( var_3 ) )
        var_3 = 0;

    if ( !isdefined( var_4 ) )
        var_4 = 0;

    var_5 = var_1.pers["score"];
    onPlayerScore( var_0, var_1, var_2 );

    if ( var_5 == var_1.pers["score"] )
        return;

    if ( !var_1 maps\mp\_utility::rankingEnabled() && !level.hardcoreMode && !var_4 )
        var_1 thread maps\mp\gametypes\_rank::xpPointsPopup( var_1.pers["score"] - var_5, 0, ( 0.85, 0.85, 0.85 ), 0 );

    var_1 maps\mp\gametypes\_persistence::statAdd( "score", var_1.pers["score"] - var_5 );
    var_1.score = var_1.pers["score"];
    var_1 maps\mp\gametypes\_persistence::statSetChild( "round", "score", var_1.score );

    if ( !level.teamBased )
        thread sendUpdatedDMScores();

    if ( !var_3 )
        var_1 maps\mp\gametypes\_gamelogic::checkPlayerScoreLimitSoon();

    var_6 = var_1 maps\mp\gametypes\_gamelogic::checkScoreLimit();
}

onPlayerScore( var_0, var_1, var_2 )
{
    var_3 = maps\mp\gametypes\_rank::getScoreInfoValue( var_0 );
    var_1.pers["score"] = var_1.pers["score"] + var_3 * level.objectivePointsMod;
}

_getPlayerScore( var_0, var_1 )
{
    if ( var_1 == var_0.pers["score"] )
        return;

    var_0.pers["score"] = var_1;
    var_0.score = var_0.pers["score"];
    var_0 thread maps\mp\gametypes\_gamelogic::checkScoreLimit();
}

_setPlayerScore( var_0 )
{
    return var_0.pers["score"];
}

giveTeamScoreForObjective( var_0, var_1 )
{
    var_1 *= level.objectivePointsMod;
    var_2 = game["teamScores"][var_0];
    var_3 = level.otherTeam[var_0];

    if ( game["teamScores"][var_0] > game["teamScores"][var_3] )
        level.wasWinning = var_0;
    else if ( game["teamScores"][var_3] > game["teamScores"][var_0] )
        level.wasWinning = var_3;

    _setTeamScore( var_0, _getTeamScore( var_0 ) + var_1 );
    var_4 = "none";

    if ( game["teamScores"][var_0] > game["teamScores"][var_3] )
        var_4 = var_0;
    else if ( game["teamScores"][var_3] > game["teamScores"][var_0] )
        var_4 = var_3;

    if ( !level.splitscreen && var_4 != "none" && var_4 != level.wasWinning && gettime() - level.lastStatusTime > 5000 && maps\mp\_utility::getScoreLimit() != 1 )
    {
        level.lastStatusTime = gettime();
        maps\mp\_utility::leaderDialog( "lead_taken", var_4, "status" );

        if ( level.wasWinning != "none" )
            maps\mp\_utility::leaderDialog( "lead_lost", level.wasWinning, "status" );
    }

    if ( var_4 != "none" )
        level.wasWinning = var_4;
}

getWinningTeam()
{
    if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
        return "allies";
    else if ( game["teamScores"]["allies"] < game["teamScores"]["axis"] )
        return "axis";

    return "none";
}

_setTeamScore( var_0, var_1 )
{
    if ( var_1 == game["teamScores"][var_0] )
        return;

    game["teamScores"][var_0] = var_1;
    updateTeamScore( var_0 );

    if ( game["status"] == "overtime" && !isdefined( level.overtimeScoreWinOverride ) || isdefined( level.overtimeScoreWinOverride ) && !level.overtimeScoreWinOverride )
        thread maps\mp\gametypes\_gamelogic::onScoreLimit();
    else
    {
        thread maps\mp\gametypes\_gamelogic::checkTeamScoreLimitSoon( var_0 );
        thread maps\mp\gametypes\_gamelogic::checkScoreLimit();
    }
}

updateTeamScore( var_0 )
{
    var_1 = 0;

    if ( !maps\mp\_utility::isRoundBased() || !maps\mp\_utility::isObjectiveBased() )
        var_1 = _getTeamScore( var_0 );
    else
        var_1 = game["roundsWon"][var_0];

    setteamscore( var_0, var_1 );
}

_getTeamScore( var_0 )
{
    return game["teamScores"][var_0];
}

sendUpdatedTeamScores()
{
    level notify( "updating_scores" );
    level endon( "updating_scores" );
    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();

    foreach ( var_1 in level.players )
        var_1 updatescores();
}

sendUpdatedDMScores()
{
    level notify( "updating_dm_scores" );
    level endon( "updating_dm_scores" );
    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();

    for ( var_0 = 0; var_0 < level.players.size; var_0++ )
    {
        level.players[var_0] updatedmscores();
        level.players[var_0].updatedDMScores = 1;
    }
}

removeDisconnectedPlayerFromPlacement()
{
    var_0 = 0;
    var_1 = level.placement["all"].size;
    var_2 = 0;

    for ( var_3 = 0; var_3 < var_1; var_3++ )
    {
        if ( level.placement["all"][var_3] == self )
            var_2 = 1;

        if ( var_2 )
            level.placement["all"][var_3] = level.placement["all"][var_3 + 1];
    }

    if ( !var_2 )
        return;

    level.placement["all"][var_1 - 1] = undefined;

    if ( level.teamBased )
    {
        updateTeamPlacement();
        return;
    }

    var_1 = level.placement["all"].size;

    for ( var_3 = 0; var_3 < var_1; var_3++ )
    {
        var_4 = level.placement["all"][var_3];
        var_4 notify( "update_outcome" );
    }
}

updatePlacement()
{
    var_0 = [];

    foreach ( var_2 in level.players )
    {
        if ( isdefined( var_2.connectedPostGame ) || var_2.pers["team"] != "allies" && var_2.pers["team"] != "axis" )
            continue;

        var_0[var_0.size] = var_2;
    }

    for ( var_4 = 1; var_4 < var_0.size; var_4++ )
    {
        var_2 = var_0[var_4];
        var_5 = var_2.score;

        for ( var_6 = var_4 - 1; var_6 >= 0 && getBetterPlayer( var_2, var_0[var_6] ) == var_2; var_6-- )
            var_0[var_6 + 1] = var_0[var_6];

        var_0[var_6 + 1] = var_2;
    }

    level.placement["all"] = var_0;

    if ( level.teamBased )
        updateTeamPlacement();
}

getBetterPlayer( var_0, var_1 )
{
    if ( var_0.score > var_1.score )
        return var_0;

    if ( var_1.score > var_0.score )
        return var_1;

    if ( var_0.deaths < var_1.deaths )
        return var_0;

    if ( var_1.deaths < var_0.deaths )
        return var_1;

    if ( common_scripts\utility::cointoss() )
        return var_0;
    else
        return var_1;
}

updateTeamPlacement()
{
    var_0["allies"] = [];
    var_0["axis"] = [];
    var_0["spectator"] = [];
    var_1 = level.placement["all"];
    var_2 = var_1.size;

    for ( var_3 = 0; var_3 < var_2; var_3++ )
    {
        var_4 = var_1[var_3];
        var_5 = var_4.pers["team"];
        var_0[var_5][var_0[var_5].size] = var_4;
    }

    level.placement["allies"] = var_0["allies"];
    level.placement["axis"] = var_0["axis"];
}

initialDMScoreUpdate()
{
    wait 0.2;
    var_0 = 0;

    for (;;)
    {
        var_1 = 0;
        var_2 = level.players;

        for ( var_3 = 0; var_3 < var_2.size; var_3++ )
        {
            var_4 = var_2[var_3];

            if ( !isdefined( var_4 ) )
                continue;

            if ( isdefined( var_4.updatedDMScores ) )
                continue;

            var_4.updatedDMScores = 1;
            var_4 updatedmscores();
            var_1 = 1;
            wait 0.5;
        }

        if ( !var_1 )
            wait 3;
    }
}

processAssist( var_0 )
{
    self endon( "disconnect" );
    var_0 endon( "disconnect" );
    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();

    if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
        return;

    if ( self.pers["team"] == var_0.pers["team"] )
        return;

    self thread [[ level.onXPEvent ]]( "assist" );
    maps\mp\_utility::incPersStat( "assists", 1 );
    self.assists = maps\mp\_utility::getPersStat( "assists" );
    maps\mp\_utility::incPlayerStat( "assists", 1 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "assists", self.assists );
    givePlayerScore( "assist", self, var_0 );
    maps\mp\killstreaks\_killstreaks::giveAdrenaline( "assist" );
    thread maps\mp\gametypes\_missions::playerAssist();
}

processShieldAssist( var_0 )
{
    self endon( "disconnect" );
    var_0 endon( "disconnect" );
    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();

    if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
        return;

    if ( self.pers["team"] == var_0.pers["team"] )
        return;

    self thread [[ level.onXPEvent ]]( "assist" );
    self thread [[ level.onXPEvent ]]( "assist" );
    maps\mp\_utility::incPersStat( "assists", 1 );
    self.assists = maps\mp\_utility::getPersStat( "assists" );
    maps\mp\_utility::incPlayerStat( "assists", 1 );
    maps\mp\gametypes\_persistence::statSetChild( "round", "assists", self.assists );
    givePlayerScore( "assist", self, var_0 );
    thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "shield_assist" );
    thread maps\mp\gametypes\_missions::playerAssist();
}
