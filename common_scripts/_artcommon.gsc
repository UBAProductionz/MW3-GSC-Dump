// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

artStartVisionFileExport()
{
    common_scripts\utility::fileprint_launcher_start_file();
}

artEndVisionFileExport()
{
    return common_scripts\utility::fileprint_launcher_end_file( "\share\raw\vision\" + level.script + ".vision", 1 );
}

artStartFogFileExport()
{
    common_scripts\utility::fileprint_launcher_start_file();
}

artEndFogFileExport()
{
    return common_scripts\utility::fileprint_launcher_end_file( "\share\raw\maps\createart\" + level.script + "_art.gsc", 1 );
}

artCommonfxprintln( var_0 )
{
    common_scripts\utility::fileprint_launcher( var_0 );
}

setfogsliders()
{

}

translateFogSlidersToScript()
{
    level.fogexphalfplane = getdvarfloat( "scr_fog_exp_halfplane" );
    level.fognearplane = getdvarfloat( "scr_fog_nearplane" );
    level.fogcolor = getdvarvector( "scr_fog_color" );
    level.fogmaxopacity = getdvarfloat( "scr_fog_max_opacity" );
    level.sunFogEnabled = getdvarint( "scr_sunFogEnabled" );
    level.sunFogColor = getdvarvector( "scr_sunFogColor" );
    level.sunFogDir = getdvarvector( "scr_sunFogDir" );
    level.sunFogBeginFadeAngle = getdvarfloat( "scr_sunFogBeginFadeAngle" );
    level.sunFogEndFadeAngle = getdvarfloat( "scr_sunFogEndFadeAngle" );
    level.sunFogScale = getdvarfloat( "scr_sunFogScale" );
    level.fogexphalfplane = limit( level.fogexphalfplane );
    level.fognearplane = limit( level.fognearplane );
    var_0 = limit( level.fogcolor[0] );
    var_1 = limit( level.fogcolor[1] );
    var_2 = limit( level.fogcolor[2] );
    level.fogcolor = ( var_0, var_1, var_2 );
    level.fogmaxopacity = limit( level.fogmaxopacity );
    level.sunFogEnabled = limit( level.sunFogEnabled );
    var_0 = limit( level.sunFogColor[0] );
    var_1 = limit( level.sunFogColor[1] );
    var_2 = limit( level.sunFogColor[2] );
    level.sunFogColor = ( var_0, var_1, var_2 );
    var_3 = limit( level.sunFogDir[0] );
    var_4 = limit( level.sunFogDir[1] );
    var_5 = limit( level.sunFogDir[2] );
    level.sunFogDir = ( var_3, var_4, var_5 );
    level.sunFogBeginFadeAngle = limit( level.sunFogBeginFadeAngle );
    level.sunFogEndFadeAngle = limit( level.sunFogEndFadeAngle );
    level.sunFogScale = limit( level.sunFogScale );
}

limit( var_0 )
{
    var_1 = 0.001;

    if ( var_0 < var_1 && var_0 > var_1 * -1 )
        var_0 = 0;

    return var_0;
}

updateFogFromScript()
{
    if ( !getdvarint( "scr_fog_disable" ) )
    {
        if ( level.sunFogEnabled )
            setexpfog( level.fognearplane, level.fogexphalfplane, level.fogcolor[0], level.fogcolor[1], level.fogcolor[2], level.fogmaxopacity, 0, level.sunFogColor[0], level.sunFogColor[1], level.sunFogColor[2], level.sunFogDir, level.sunFogBeginFadeAngle, level.sunFogEndFadeAngle, level.sunFogScale );
        else
            setexpfog( level.fognearplane, level.fogexphalfplane, level.fogcolor[0], level.fogcolor[1], level.fogcolor[2], level.fogmaxopacity, 0 );
    }
    else
        setexpfog( 1215752192, 1215752193, 0, 0, 0, 0, 0 );
}

artfxprintlnFog()
{
    common_scripts\utility::fileprint_launcher( "" );
    common_scripts\utility::fileprint_launcher( "\t//* Fog section * " );
    common_scripts\utility::fileprint_launcher( "" );
    common_scripts\utility::fileprint_launcher( "\tsetDevDvar( \"scr_fog_disable\", \"" + getdvarint( "scr_fog_disable" ) + "\"" + " );" );
    common_scripts\utility::fileprint_launcher( "" );

    if ( !getdvarint( "scr_fog_disable" ) )
    {
        if ( level.sunFogEnabled )
            common_scripts\utility::fileprint_launcher( "\tsetExpFog( " + level.fognearplane + ", " + level.fogexphalfplane + ", " + level.fogcolor[0] + ", " + level.fogcolor[1] + ", " + level.fogcolor[2] + ", " + level.fogmaxopacity + ", 0, " + level.sunFogColor[0] + ", " + level.sunFogColor[1] + ", " + level.sunFogColor[2] + ", (" + level.sunFogDir[0] + ", " + level.sunFogDir[1] + ", " + level.sunFogDir[2] + "), " + level.sunFogBeginFadeAngle + ", " + level.sunFogEndFadeAngle + ", " + level.sunFogScale + " );" );
        else
            common_scripts\utility::fileprint_launcher( "\tsetExpFog( " + level.fognearplane + ", " + level.fogexphalfplane + ", " + level.fogcolor[0] + ", " + level.fogcolor[1] + ", " + level.fogcolor[2] + ", " + level.fogmaxopacity + ", 0 );" );
    }
}
