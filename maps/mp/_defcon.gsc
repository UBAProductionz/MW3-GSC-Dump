// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( !isdefined( level.defconMode ) || level.defconMode == 0 )
        return;

    if ( !isdefined( game["defcon"] ) )
        game["defcon"] = 4;

    makedvarserverinfo( "scr_defcon", game["defcon"] );
    level.defconStreakAdd[5] = 0;
    level.defconStreakAdd[4] = 0;
    level.defconStreakAdd[3] = -1;
    level.defconStreakAdd[2] = -1;
    level.defconStreakAdd[1] = -1;
    level.defconPointMod[5] = 1;
    level.defconPointMod[4] = 1;
    level.defconPointMod[3] = 1;
    level.defconPointMod[2] = 1;
    level.defconPointMod[1] = 2;
    updateDefcon( game["defcon"] );
    thread defconKillstreakThread();
}

defconKillstreakWait( var_0 )
{
    for (;;)
    {
        level waittill( "player_got_killstreak_" + var_0,  var_1  );
        level notify( "defcon_killstreak",  var_0, var_1  );
    }
}

defconKillstreakThread()
{
    level endon( "game_ended" );
    var_0 = 10;
    level thread defconKillstreakWait( var_0 );
    level thread defconKillstreakWait( var_0 - 1 );
    level thread defconKillstreakWait( var_0 - 2 );
    level thread defconKillstreakWait( var_0 * 2 );
    level thread defconKillstreakWait( var_0 * 2 - 1 );
    level thread defconKillstreakWait( var_0 * 2 - 2 );
    level thread defconKillstreakWait( var_0 * 3 );
    level thread defconKillstreakWait( var_0 * 3 - 1 );
    level thread defconKillstreakWait( var_0 * 3 - 2 );

    for (;;)
    {
        level waittill( "defcon_killstreak",  var_1, var_2  );

        if ( game["defcon"] <= 1 )
            continue;

        if ( var_1 % var_0 == var_0 - 2 )
        {
            foreach ( var_4 in level.players )
            {
                if ( !isalive( var_4 ) )
                    continue;

                var_4 thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( "two_from_defcon", var_2 );
            }

            continue;
        }

        if ( var_1 % var_0 == var_0 - 1 )
        {
            foreach ( var_4 in level.players )
            {
                if ( !isalive( var_4 ) )
                    continue;

                var_4 thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( "one_from_defcon", var_2 );
            }

            continue;
        }

        updateDefcon( game["defcon"] - 1, var_2, var_1 );
    }
}

updateDefcon( var_0, var_1, var_2 )
{
    var_0 = int( var_0 );
    var_3 = game["defcon"];
    game["defcon"] = var_0;
    level.objectivePointsMod = level.defconPointMod[var_0];
    setdvar( "scr_defcon", game["defcon"] );

    if ( isdefined( var_1 ) )
        var_1 notify( "changed_defcon" );

    if ( var_0 == var_3 )
        return;

    if ( game["defcon"] == 3 && isdefined( var_1 ) )
    {
        var_1 maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop_mega" );
        var_1 thread maps\mp\gametypes\_hud_message::splashNotify( "caused_defcon", var_2 );
    }

    foreach ( var_5 in level.players )
    {
        if ( isalive( var_5 ) )
        {
            var_5 thread maps\mp\gametypes\_hud_message::defconSplashNotify( game["defcon"], var_0 < var_3 );

            if ( isdefined( var_1 ) )
                var_5 thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( "changed_defcon", var_1 );
        }
    }
}
