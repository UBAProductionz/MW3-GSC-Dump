// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

watchTrophyUsage()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );
    self.trophyArray = [];

    for (;;)
    {
        self waittill( "grenade_fire",  var_0, var_1  );

        if ( var_1 == "trophy" || var_1 == "trophy_mp" )
        {
            if ( !isalive( self ) )
            {
                var_0 delete();
                return;
            }

            var_0 hide();
            var_0 waittill( "missile_stuck" );
            var_2 = 40;

            if ( var_2 * var_2 < distancesquared( var_0.origin, self.origin ) )
            {
                var_3 = bullettrace( self.origin, self.origin - ( 0, 0, var_2 ), 0, self );

                if ( var_3["fraction"] == 1 )
                {
                    var_0 delete();
                    self setweaponammostock( "trophy_mp", self getweaponammostock( "trophy_mp" ) + 1 );
                    continue;
                }

                var_0.origin = var_3["position"];
            }

            var_0 show();
            self.trophyArray = common_scripts\utility::array_removeUndefined( self.trophyArray );

            if ( self.trophyArray.size >= level.maxPerPlayerExplosives )
                self.trophyArray[0] detonate();

            var_4 = spawn( "script_model", var_0.origin );
            var_4 setmodel( "mp_trophy_system" );
            var_4 thread maps\mp\gametypes\_weapons::createBombSquadModel( "mp_trophy_system_bombsquad", "tag_origin", level.otherTeam[self.team], self );
            var_4.angles = var_0.angles;
            self.trophyArray[self.trophyArray.size] = var_4;
            var_4.owner = self;
            var_4.team = self.team;
            var_4.weaponName = var_1;

            if ( isdefined( self.trophyRemainingAmmo ) && self.trophyRemainingAmmo > 0 )
                var_4.ammo = self.trophyRemainingAmmo;
            else
                var_4.ammo = 2;

            var_4.trigger = spawn( "script_origin", var_4.origin );
            var_4 thread trophyDamage( self );
            var_4 thread trophyActive( self );
            var_4 thread trophyDisconnectWaiter( self );
            var_4 thread trophyPlayerSpawnWaiter( self );
            var_4 thread trophyUseListener( self );
            var_4 thread maps\mp\gametypes\_weapons::c4EMPKillstreakWait();

            if ( level.teamBased )
                var_4 maps\mp\_entityheadicons::setTeamHeadIcon( var_4.team, ( 0, 0, 65 ) );
            else
                var_4 maps\mp\_entityheadicons::setPlayerHeadIcon( var_4.owner, ( 0, 0, 65 ) );

            wait 0.05;

            if ( isdefined( var_0 ) )
                var_0 delete();
        }
    }
}

trophyUseListener( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );
    var_0 endon( "disconnect" );
    var_0 endon( "death" );
    self.trigger setcursorhint( "HINT_NOICON" );
    self.trigger sethintstring( &"MP_PICKUP_TROPHY" );
    self.trigger maps\mp\_utility::setSelfUsable( var_0 );
    self.trigger thread maps\mp\_utility::notUsableForJoiningPlayers( var_0 );

    for (;;)
    {
        self.trigger waittill( "trigger",  var_0  );
        var_0 playlocalsound( "scavenger_pack_pickup" );

        if ( !var_0 maps\mp\_utility::isJuggernaut() )
        {
            var_0 maps\mp\_utility::givePerk( "trophy_mp", 0 );
            var_0.trophyRemainingAmmo = self.ammo;
        }

        self.trigger delete();
        self delete();
        self notify( "death" );
    }
}

trophyPlayerSpawnWaiter( var_0 )
{
    self endon( "disconnect" );
    self endon( "death" );
    var_0 waittill( "spawned" );
    thread trophyBreak();
}

trophyDisconnectWaiter( var_0 )
{
    self endon( "death" );
    var_0 waittill( "disconnect" );
    thread trophyBreak();
}

trophyActive( var_0 )
{
    var_0 endon( "disconnect" );
    self endon( "death" );
    var_1 = self.origin;

    for (;;)
    {
        if ( !isdefined( level.grenades ) || level.grenades.size < 1 && level.missiles.size < 1 || isdefined( self.disabled ) )
        {
            wait 0.05;
            continue;
        }

        var_2 = maps\mp\_utility::combineArrays( level.grenades, level.missiles );

        foreach ( var_4 in var_2 )
        {
            wait 0.05;

            if ( !isdefined( var_4 ) )
                continue;

            if ( var_4 == self )
                continue;

            if ( isdefined( var_4.weaponName ) )
            {
                switch ( var_4.weaponName )
                {
                    case "claymore_mp":
                        continue;
                }
            }

            switch ( var_4.model )
            {
                case "weapon_jammer":
                case "weapon_parabolic_knife":
                case "weapon_radar":
                case "mp_trophy_system":
                    continue;
            }

            if ( !isdefined( var_4.owner ) )
                var_4.owner = getmissileowner( var_4 );

            if ( isdefined( var_4.owner ) && level.teamBased && var_4.owner.team == var_0.team )
                continue;

            if ( isdefined( var_4.owner ) && var_4.owner == var_0 )
                continue;

            var_5 = distancesquared( var_4.origin, self.origin );

            if ( var_5 < 147456 )
            {
                if ( bullettracepassed( var_4.origin, self.origin, 0, self ) )
                {
                    playfx( level.sentry_fire, self.origin + ( 0, 0, 32 ), var_4.origin - self.origin, anglestoup( self.angles ) );
                    self playsound( "trophy_detect_projectile" );

                    if ( isdefined( var_4.classname ) && var_4.classname == "rocket" && ( isdefined( var_4.type ) && ( var_4.type == "remote" || var_4.type == "remote_mortar" ) ) )
                    {
                        if ( isdefined( var_4.type ) && var_4.type == "remote" )
                        {
                            level thread maps\mp\gametypes\_missions::vehicleKilled( var_4.owner, var_0, undefined, var_0, undefined, "MOD_EXPLOSIVE", "trophy_mp" );
                            level thread maps\mp\_utility::teamPlayerCardSplash( "callout_destroyed_predator_missile", var_0 );
                            var_0 thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100, "trophy_mp", "MOD_EXPLOSIVE" );
                            var_0 notify( "destroyed_killstreak",  "trophy_mp"  );
                        }

                        if ( isdefined( level.chopper_fx["explode"]["medium"] ) )
                            playfx( level.chopper_fx["explode"]["medium"], var_4.origin );

                        if ( isdefined( level.barrelExpSound ) )
                            var_4 playsound( level.barrelExpSound );
                    }

                    var_0 thread projectileExplode( var_4, self );
                    var_0 maps\mp\gametypes\_missions::processChallenge( "ch_noboomforyou" );
                    self.ammo--;

                    if ( self.ammo <= 0 )
                        thread trophyBreak();
                }
            }
        }
    }
}

projectileExplode( var_0, var_1 )
{
    self endon( "death" );
    var_2 = var_0.origin;
    var_3 = var_0.model;
    var_4 = var_0.angles;

    if ( var_3 == "weapon_light_marker" )
    {
        playfx( level.empGrenadeExplode, var_2, anglestoforward( var_4 ), anglestoup( var_4 ) );
        var_1 thread trophyBreak();
        var_0 delete();
        return;
    }

    var_0 delete();
    var_1 playsound( "trophy_fire" );
    playfx( level.mine_explode, var_2, anglestoforward( var_4 ), anglestoup( var_4 ) );
    var_5 = self;

    if ( level.teamBased && level.friendlyfire )
        var_5 = undefined;

    radiusdamage( var_2, 128, 105, 10, var_5, "MOD_EXPLOSIVE", "trophy_mp" );
}

trophyDamage( var_0 )
{
    self endon( "death" );
    var_0 endon( "death" );
    self setcandamage( 1 );
    self.health = 999999;
    self.maxHealth = 100;
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage",  var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10  );

        if ( !isplayer( var_2 ) )
            continue;

        if ( !maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, var_2 ) )
            continue;

        if ( isdefined( var_10 ) )
        {
            switch ( var_10 )
            {
                case "smoke_grenade_mp":
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
                    continue;
            }
        }

        if ( !isdefined( self ) )
            return;

        if ( var_5 == "MOD_MELEE" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        if ( isdefined( var_9 ) && var_9 & level.iDFLAGS_PENETRATION )
            self.wasDamagedFromBulletPenetration = 1;

        self.wasDamaged = 1;

        if ( isdefined( var_10 ) && var_10 == "emp_grenade_mp" )
            self.damagetaken = self.damagetaken + self.maxHealth;

        self.damagetaken = self.damagetaken + var_1;

        if ( isplayer( var_2 ) )
            var_2 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "trophy" );

        if ( self.damagetaken >= self.maxHealth )
        {
            if ( isdefined( var_0 ) && var_2 != var_0 )
                var_2 notify( "destroyed_explosive" );

            thread trophyBreak();
        }
    }
}

trophyBreak()
{
    playfxontag( common_scripts\utility::getfx( "sentry_explode_mp" ), self, "tag_origin" );
    playfxontag( common_scripts\utility::getfx( "sentry_smoke_mp" ), self, "tag_origin" );
    self playsound( "sentry_explode" );
    self notify( "death" );
    var_0 = self.origin;
    self.trigger makeunusable();
    wait 3;

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    if ( isdefined( self ) )
        self delete();
}

createkilltriggers()
{
    switch ( level.script )
    {
        case "mp_dome":
            createkilltrigger( ( 65.2303, 284.217, -307.954 ), 20, 64 );
            createkilltrigger( ( 550.941, 1778.53, -108.78 ), 120, 64 );
            break;
        case "mp_hardhat":
            createkilltrigger( ( 916.224, -1911.95, 332.625 ), 230, 64 );
            createkilltrigger( ( 78.2076, 800.055, 498.384 ), 120, 32 );
            createkilltrigger( ( 165.7, -208.641, 408.544 ), 90, 64 );
            createkilltrigger( ( 647.502, -619.168, 318.386 ), 70, 64 );
            createkilltrigger( ( 1353.14, 1379.13, 500.502 ), 100, 64 );
            break;
        case "mp_paris":
            createkilltrigger( ( 442.346, -895.006, 128.819 ), 14, 32 );
            createkilltrigger( ( 277.62, -972.828, 129.303 ), 32, 64 );
            createkilltrigger( ( 1717.79, 549.294, 144.871 ), 20, 32 );
            createkilltrigger( ( 130.734, 2027.64, 95.1856 ), 32, 64 );
            createkilltrigger( ( -2077.26, 602.075, 646.415 ), 300, 64 );
            break;
        case "mp_plaza2":
            createkilltrigger( ( -1355.79, -56.389, 952.179 ), 50, 32 );
            createkilltrigger( ( -1354.92, 147.436, 914.707 ), 40, 32 );
            createkilltrigger( ( -266.038, 976.432, 761.29 ), 30, 32 );
            createkilltrigger( ( 189.786, -472.274, 738.957 ), 60, 40 );
            createkilltrigger( ( 652.957, -398.834, 687.308 ), 60, 40 );
            createkilltrigger( ( 480.709, -1961.1, 742.611 ), 110, 40 );
            createkilltrigger( ( -990.873, -140.348, 905.785 ), 45, 64 );
            createkilltrigger( ( -1215.71, -140.041, 905.785 ), 45, 64 );
            createkilltrigger( ( -485.723, 559.951, 801.125 ), 50, 64 );
            createkilltrigger( ( -350.711, 559.951, 801.125 ), 50, 64 );
            createkilltrigger( ( 369.49, 912.654, 798.966 ), 200, 64 );
            createkilltrigger( ( -738.525, 1698.84, 796.122 ), 100, 200 );
            break;
        case "mp_seatown":
            createkilltrigger( ( -1965.25, -862.286, 273.747 ), 100, 120 );
            createkilltrigger( ( -583.448, 582.223, 375.4 ), 20, 64 );
            createkilltrigger( ( -1400.83, 1367.31, 391.082 ), 200, 100 );
            break;
        case "mp_lambeth":
            createkilltrigger( ( 202.69, 1447.83, -85.4053 ), 100, 64 );
            createkilltrigger( ( 1487.4, 1713.4, -141.171 ), 20, 120 );
            createkilltrigger( ( 1375.03, 2067.73, 3.36294 ), 20, 64 );
            createkilltrigger( ( 333.856, 2020.39, 14.2658 ), 32, 64 );
            break;
        case "mp_alpha":
            createkilltrigger( ( -768, 1277.92, 162.01 ), 8, 40 );
            createkilltrigger( ( -768, 1151.35, 162.01 ), 8, 40 );
            createkilltrigger( ( -768, 1024.97, 162.01 ), 8, 40 );
            createkilltrigger( ( -768, 896.526, 162.01 ), 8, 40 );
            createkilltrigger( ( -115.306, -423.98, 188.944 ), 50, 72 );
            break;
        case "mp_underground":
            createkilltrigger( ( 975.678, 1727.09, -121.848 ), 20, 72 );
            createkilltrigger( ( 273.891, 1933.97, -97.8215 ), 12, 72 );
            createkilltrigger( ( -44.8348, 1878.63, -108.455 ), 30, 64 );
            createkilltrigger( ( -287.736, 3014.45, 60.6556 ), 300, 200 );
            break;
        case "mp_bootleg":
            createkilltrigger( ( -1353.36, 33.4733, 49.2629 ), 60, 32 );
            createkilltrigger( ( -1360.71, -37.7305, 49.2629 ), 60, 32 );
            createkilltrigger( ( -1553.97, -744.555, 113.469 ), 14, 64 );
            createkilltrigger( ( 52.7655, -257.007, -48.4873 ), 40, 64 );
            createkilltrigger( ( -952.634, 1634.85, -68.327 ), 50, 64 );
            createkilltrigger( ( -894.218, 1518.04, -68.327 ), 55, 64 );
            createkilltrigger( ( 44.5985, -1871.56, 226.461 ), 200, 64 );
            createkilltrigger( ( -1476.79, -730.554, 87.178 ), 30, 64 );
            createkilltrigger( ( -1336.19, 141.716, 61.0992 ), 70, 64 );
            break;
        case "mp_radar":
            createkilltrigger( ( -4213.97, 2374.97, 1287.35 ), 120, 64 );
            createkilltrigger( ( -4340.14, 3693.87, 1299.49 ), 120, 64 );
            createkilltrigger( ( -4832.37, 4363.34, 1365.7 ), 120, 64 );
            createkilltrigger( ( -3837.91, 1665.4, 1256 ), 68, 64 );
            createkilltrigger( ( -3841.18, 1537.42, 1267.05 ), 68, 64 );
            createkilltrigger( ( -6917.44, 4752.67, 1498.9 ), 200, 64 );
            createkilltrigger( ( -5801.42, 3119.02, 1638.7 ), 300, 300 );
            break;
        case "mp_mogadishu":
            createkilltrigger( ( -87.1578, 483.38, 152.515 ), 24, 64 );
            createkilltrigger( ( -140.927, 129.438, 84.5235 ), 16, 64 );
            createkilltrigger( ( 1514.97, 2500.66, 171.984 ), 32, 32 );
            createkilltrigger( ( 238.065, 249.291, 75.904 ), 100, 64 );
            createkilltrigger( ( 564.572, 1132.1, 65.043 ), 12, 64 );
            createkilltrigger( ( -32.8942, 297.377, 88.8334 ), 52, 64 );
            createkilltrigger( ( 219.136, 1207.01, 121.441 ), 130, 64 );
            createkilltrigger( ( 722.165, 1210.59, 73.5508 ), 150, 64 );
            createkilltrigger( ( 98.2886, -869.883, 138.138 ), 100, 64 );
            break;
        case "mp_carbon":
            createkilltrigger( ( -1933.36, -4337.14, 3890.75 ), 14, 90 );
            createkilltrigger( ( -2676.72, -3496.48, 3694.44 ), 14, 14 );
            createkilltrigger( ( -3377.57, -4567.52, 3785.84 ), 40, 80 );
            break;
        case "mp_bravo":
            createkilltrigger( ( 878.518, -539.478, 1171.53 ), 14, 64 );
            createkilltrigger( ( -1275.65, 984.295, 1394.08 ), 200, 64 );
            break;
        case "mp_interchange":
            createkilltrigger( ( -712.089, 1183.13, 192.016 ), 100, 64 );
            break;
        case "mp_exchange":
            createkilltrigger( ( 76.163, -1513.53, 265.376 ), 600, 64 );
            createkilltrigger( ( -1078.77, -1040.27, 196.185 ), 250, 64 );
            createkilltrigger( ( 1705.31, 1012.04, 238.247 ), 40, 64 );
            createkilltrigger( ( 1706.24, 881.525, 238.247 ), 40, 64 );
            createkilltrigger( ( 918.001, -1387.3, 192.754 ), 40, 64 );
            createkilltrigger( ( 1039.45, -1420.39, 192.754 ), 40, 64 );
            createkilltrigger( ( -270.995, -691.246, 184.239 ), 40, 64 );
            createkilltrigger( ( -511.649, -1104.71, 169.967 ), 40, 64 );
            createkilltrigger( ( -841.228, -522.82, 147.096 ), 50, 64 );
            createkilltrigger( ( 445.223, 1552.75, 234.433 ), 40, 64 );
            createkilltrigger( ( 261.291, 814.016, 204.573 ), 50, 64 );
            break;
    }
}

createkilltrigger( var_0, var_1, var_2 )
{
    thread maps\mp\_utility::killTrigger( var_0, var_1, var_2 );
}
