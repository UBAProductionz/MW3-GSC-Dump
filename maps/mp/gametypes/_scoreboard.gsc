// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

processLobbyScoreboards()
{
    foreach ( var_1 in level.placement["all"] )
        var_1 setPlayerScoreboardInfo();

    if ( level.teamBased )
    {
        var_3 = getteamscore( "allies" );
        var_4 = getteamscore( "axis" );

        if ( var_3 == var_4 )
            var_5 = "tied";
        else if ( var_3 > var_4 )
            var_5 = "allies";
        else
            var_5 = "axis";

        if ( var_5 == "tied" )
        {
            buildScoreboardType( "allies" );
            buildScoreboardType( "axis" );

            foreach ( var_1 in level.players )
            {
                if ( var_1.pers["team"] == "spectator" )
                {
                    var_1 setplayerdata( "round", "scoreboardType", "allies" );
                    continue;
                }

                var_1 setplayerdata( "round", "scoreboardType", var_1.pers["team"] );
            }
        }
        else
        {
            buildScoreboardType( var_5 );

            foreach ( var_1 in level.players )
                var_1 setplayerdata( "round", "scoreboardType", var_5 );
        }
    }
    else
    {
        buildScoreboardType( "neutral" );

        foreach ( var_1 in level.players )
            var_1 setplayerdata( "round", "scoreboardType", "neutral" );
    }

    foreach ( var_1 in level.players )
        var_1 setclientdvars( "player_summary_xp", var_1.pers["summary"]["xp"], "player_summary_score", var_1.pers["summary"]["score"], "player_summary_challenge", var_1.pers["summary"]["challenge"], "player_summary_match", var_1.pers["summary"]["match"], "player_summary_misc", var_1.pers["summary"]["misc"] );
}

setPlayerScoreboardInfo()
{
    var_0 = getclientmatchdata( "scoreboardPlayerCount" );

    if ( var_0 <= 24 )
    {
        setclientmatchdata( "players", self.clientMatchDataId, "score", self.pers["score"] );
        var_1 = self.pers["kills"];
        setclientmatchdata( "players", self.clientMatchDataId, "kills", var_1 );
        var_2 = self.pers["assists"];
        setclientmatchdata( "players", self.clientMatchDataId, "assists", var_2 );
        var_3 = self.pers["deaths"];
        setclientmatchdata( "players", self.clientMatchDataId, "deaths", var_3 );
        var_4 = game[self.pers["team"]];
        setclientmatchdata( "players", self.clientMatchDataId, "faction", var_4 );
        var_0++;
        setclientmatchdata( "scoreboardPlayerCount", var_0 );
    }
    else
    {

    }
}

buildScoreboardType( var_0 )
{
    if ( var_0 == "neutral" )
    {
        var_1 = 0;

        foreach ( var_3 in level.placement["all"] )
        {
            setclientmatchdata( "scoreboards", var_0, var_1, var_3.clientMatchDataId );
            var_1++;
        }
    }
    else
    {
        var_5 = maps\mp\_utility::getOtherTeam( var_0 );
        var_1 = 0;

        foreach ( var_3 in level.placement[var_0] )
        {
            setclientmatchdata( "scoreboards", var_0, var_1, var_3.clientMatchDataId );
            var_1++;
        }

        foreach ( var_3 in level.placement[var_5] )
        {
            setclientmatchdata( "scoreboards", var_0, var_1, var_3.clientMatchDataId );
            var_1++;
        }
    }
}
