// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

createFX()
{
    level.func_position_player = common_scripts\utility::void;
    level.func_position_player_get = ::func_position_player_get;
    level.func_loopfxthread = common_scripts\_fx::loopfxthread;
    level.func_oneshotfxthread = common_scripts\_fx::OneShotfxthread;
    level.func_create_loopsound = common_scripts\_fx::create_loopsound;
    level.func_updatefx = common_scripts\_createfx::restart_fx_looper;
    level.func_process_fx_rotater = common_scripts\_createfx::process_fx_rotater;
    level.mp_createfx = 1;
    level.callbackStartGameType = common_scripts\utility::void;
    level.callbackPlayerConnect = common_scripts\utility::void;
    level.callbackPlayerDisconnect = common_scripts\utility::void;
    level.callbackPlayerDamage = common_scripts\utility::void;
    level.callbackPlayerKilled = common_scripts\utility::void;
    level.callbackCodeEndGame = common_scripts\utility::void;
    level.callbackPlayerLastStand = common_scripts\utility::void;
    level.callbackPlayerConnect = ::Callback_PlayerConnect;
    level.callbackPlayerMigrated = common_scripts\utility::void;
    thread common_scripts\_createfx::func_get_level_fx();
    common_scripts\_createfx::createfx_common();
    level waittill( "eternity" );
}

func_position_player_get( var_0 )
{
    return level.player.origin;
}

Callback_PlayerConnect()
{
    self waittill( "begin" );

    if ( !isdefined( level.player ) )
    {
        var_0 = getentarray( "mp_global_intermission", "classname" );
        self spawn( var_0[0].origin, var_0[0].angles );
        maps\mp\gametypes\_playerlogic::updateSessionState( "playing", "" );
        self.maxHealth = 10000000;
        self.health = 10000000;
        level.player = self;
        thread common_scripts\_createfx::createFxLogic();
        thread ufo_mode();
    }
    else
        kick( self getentitynumber() );
}

ufo_mode()
{
    level.player openpopupmenu( "painter_mp" );
    level.player closepopupmenu( "painter_mp" );
}
