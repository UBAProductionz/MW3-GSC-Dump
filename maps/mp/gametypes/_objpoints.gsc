// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precacheshader( "objpoint_default" );
    level.objPointNames = [];
    level.objPoints = [];

    if ( level.splitscreen )
        level.objPointSize = 15;
    else
        level.objPointSize = 8;

    level.objpoint_alpha_default = 0.5;
    level.objPointScale = 1.0;
}

createTeamObjpoint( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    var_6 = getObjPointByName( var_0 );

    if ( isdefined( var_6 ) )
        deleteObjPoint( var_6 );

    if ( !isdefined( var_3 ) )
        var_3 = "objpoint_default";

    if ( !isdefined( var_5 ) )
        var_5 = 1.0;

    if ( var_2 != "all" )
        var_6 = newteamhudelem( var_2 );
    else
        var_6 = newhudelem();

    var_6.name = var_0;
    var_6.x = var_1[0];
    var_6.y = var_1[1];
    var_6.z = var_1[2];
    var_6.team = var_2;
    var_6.isFlashing = 0;
    var_6.isShown = 1;
    var_6 setshader( var_3, level.objPointSize, level.objPointSize );
    var_6 setwaypoint( 1, 0 );

    if ( isdefined( var_4 ) )
        var_6.alpha = var_4;
    else
        var_6.alpha = level.objpoint_alpha_default;

    var_6.baseAlpha = var_6.alpha;
    var_6.index = level.objPointNames.size;
    level.objPoints[var_0] = var_6;
    level.objPointNames[level.objPointNames.size] = var_0;
    return var_6;
}

deleteObjPoint( var_0 )
{
    if ( level.objPoints.size == 1 )
    {
        level.objPoints = [];
        level.objPointNames = [];
        var_0 destroy();
        return;
    }

    var_1 = var_0.index;
    var_2 = level.objPointNames.size - 1;
    var_3 = getObjPointByIndex( var_2 );
    level.objPointNames[var_1] = var_3.name;
    var_3.index = var_1;
    level.objPointNames[var_2] = undefined;
    level.objPoints[var_0.name] = undefined;
    var_0 destroy();
}

updateOrigin( var_0 )
{
    if ( self.x != var_0[0] )
        self.x = var_0[0];

    if ( self.y != var_0[1] )
        self.y = var_0[1];

    if ( self.z != var_0[2] )
        self.z = var_0[2];
}

setOriginByName( var_0, var_1 )
{
    var_2 = getObjPointByName( var_0 );
    var_2 updateOrigin( var_1 );
}

getObjPointByName( var_0 )
{
    if ( isdefined( level.objPoints[var_0] ) )
        return level.objPoints[var_0];
    else
        return undefined;
}

getObjPointByIndex( var_0 )
{
    if ( isdefined( level.objPointNames[var_0] ) )
        return level.objPoints[level.objPointNames[var_0]];
    else
        return undefined;
}

startFlashing()
{
    self endon( "stop_flashing_thread" );

    if ( self.isFlashing )
        return;

    self.isFlashing = 1;

    while ( self.isFlashing )
    {
        self fadeovertime( 0.75 );
        self.alpha = 0.35 * self.baseAlpha;
        wait 0.75;
        self fadeovertime( 0.75 );
        self.alpha = self.baseAlpha;
        wait 0.75;
    }

    self.alpha = self.baseAlpha;
}

stopFlashing()
{
    if ( !self.isFlashing )
        return;

    self.isFlashing = 0;
}
