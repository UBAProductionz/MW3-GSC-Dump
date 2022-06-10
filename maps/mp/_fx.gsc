// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

script_print_fx()
{
    if ( !isdefined( self.script_fxid ) || !isdefined( self.script_fxcommand ) || !isdefined( self.script_delay ) )
    {
        self delete();
        return;
    }

    if ( isdefined( self.target ) )
        var_0 = getent( self.target ).origin;
    else
        var_0 = "undefined";

    if ( self.script_fxcommand == "OneShotfx" )
    {

    }

    if ( self.script_fxcommand == "loopfx" )
    {

    }

    if ( self.script_fxcommand == "loopsound" )
        return;
}

script_playfx( var_0, var_1, var_2 )
{
    if ( !var_0 )
        return;

    if ( isdefined( var_2 ) )
        playfx( var_0, var_1, var_2 );
    else
        playfx( var_0, var_1 );
}

script_playfxontag( var_0, var_1, var_2 )
{
    if ( !var_0 )
        return;

    playfxontag( var_0, var_1, var_2 );
}

GrenadeExplosionfx( var_0 )
{
    playfx( level._effect["mechanical explosion"], var_0 );
    earthquake( 0.15, 0.5, var_0, 250 );
}

soundfx( var_0, var_1, var_2 )
{
    var_3 = spawn( "script_origin", ( 0, 0, 0 ) );
    var_3.origin = var_1;
    var_3 playloopsound( var_0 );

    if ( isdefined( var_2 ) )
        var_3 thread soundfxDelete( var_2 );
}

soundfxDelete( var_0 )
{
    level waittill( var_0 );
    self delete();
}

blendDelete( var_0 )
{
    self waittill( "death" );
    var_0 delete();
}
