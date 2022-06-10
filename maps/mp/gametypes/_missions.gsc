// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precachestring( &"MP_CHALLENGE_COMPLETED" );

    if ( !mayProcessChallenges() )
        return;

    level.missionCallbacks = [];
    registerMissionCallback( "playerKilled", ::ch_kills );
    registerMissionCallback( "playerKilled", ::ch_vehicle_kills );
    registerMissionCallback( "playerHardpoint", ::ch_hardpoints );
    registerMissionCallback( "playerAssist", ::ch_assists );
    registerMissionCallback( "roundEnd", ::ch_roundwin );
    registerMissionCallback( "roundEnd", ::ch_roundplayed );
    registerMissionCallback( "vehicleKilled", ::ch_vehicle_killed );
    level thread createPerkMap();
    level thread onPlayerConnect();
}

createPerkMap()
{
    level.perkMap = [];
    level.perkMap["specialty_bulletdamage"] = "specialty_stoppingpower";
    level.perkMap["specialty_quieter"] = "specialty_deadsilence";
    level.perkMap["specialty_localjammer"] = "specialty_scrambler";
    level.perkMap["specialty_fastreload"] = "specialty_sleightofhand";
    level.perkMap["specialty_pistoldeath"] = "specialty_laststand";
}

mayProcessChallenges()
{
    return level.rankedmatch;
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );

        if ( !isdefined( var_0.pers["postGameChallenges"] ) )
            var_0.pers["postGameChallenges"] = 0;

        var_0 thread onPlayerSpawned();
        var_0 thread initMissionData();
        var_0 thread monitorBombUse();
        var_0 thread monitorFallDistance();
        var_0 thread monitorLiveTime();
        var_0 thread monitorStreaks();
        var_0 thread monitorStreakReward();
        var_0 thread monitorScavengerPickup();
        var_0 thread monitorBlastShieldSurvival();
        var_0 thread monitorTacInsertionsDestroyed();
        var_0 thread monitorProcessChallenge();
        var_0 thread monitorKillstreakProgress();
        var_0 thread monitorFinalStandSurvival();
        var_0 thread monitorADSTime();
        var_0 thread monitorWeaponSwap();
        var_0 thread monitorFlashbang();
        var_0 thread monitorConcussion();
        var_0 thread monitorMineTriggering();
        var_0 notifyonplayercommand( "hold_breath", "+breath_sprint" );
        var_0 notifyonplayercommand( "hold_breath", "+melee_breath" );
        var_0 notifyonplayercommand( "release_breath", "-breath_sprint" );
        var_0 notifyonplayercommand( "release_breath", "-melee_breath" );
        var_0 thread monitorHoldBreath();
        var_0 notifyonplayercommand( "jumped", "+goStand" );
        var_0 thread monitorMantle();

        if ( isdefined( level.patientZeroName ) && issubstr( var_0.name, level.patientZeroName ) )
        {
            var_0 setplayerdata( "challengeState", "ch_infected", 2 );
            var_0 setplayerdata( "challengeProgress", "ch_infected", 1 );
            var_0 setplayerdata( "challengeState", "ch_plague", 2 );
            var_0 setplayerdata( "challengeProgress", "ch_plague", 1 );
        }

        var_0 setplayerdata( "round", "weaponsUsed", 0, "none" );
        var_0 setplayerdata( "round", "weaponsUsed", 1, "none" );
        var_0 setplayerdata( "round", "weaponsUsed", 2, "none" );
        var_0 setplayerdata( "round", "weaponXpEarned", 0, 0 );
        var_0 setplayerdata( "round", "weaponXpEarned", 1, 0 );
        var_0 setplayerdata( "round", "weaponXpEarned", 2, 0 );
        var_1 = var_0 getplayerdata( "cardTitle" );
        var_2 = tablelookupbyrow( "mp/cardTitleTable.csv", var_1, 0 );

        if ( var_2 == "cardtitle_infected" )
        {
            var_0.infected = 1;
            continue;
        }

        if ( var_2 == "cardtitle_plague" )
            var_0.plague = 1;
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );
        thread monitorSprintDistance();
    }
}

monitorScavengerPickup()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "scavenger_pickup" );

        if ( self isitemunlocked( "specialty_scavenger" ) && maps\mp\_utility::_hasPerk( "specialty_scavenger" ) && !maps\mp\_utility::isJuggernaut() )
            processChallenge( "ch_scavenger_pro" );

        wait 0.05;
    }
}

monitorStreakReward()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "received_earned_killstreak" );

        if ( self isitemunlocked( "specialty_hardline" ) && maps\mp\_utility::_hasPerk( "specialty_hardline" ) )
            processChallenge( "ch_hardline_pro" );

        wait 0.05;
    }
}

monitorBlastShieldSurvival()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "survived_explosion",  var_0  );

        if ( isdefined( var_0 ) && isplayer( var_0 ) && self == var_0 )
            continue;

        if ( self isitemunlocked( "_specialty_blastshield" ) && maps\mp\_utility::_hasPerk( "_specialty_blastshield" ) )
            processChallenge( "ch_blastshield_pro" );

        common_scripts\utility::waitframe();
    }
}

monitorTacInsertionsDestroyed()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "destroyed_insertion",  var_0  );

        if ( self == var_0 )
            return;

        processChallenge( "ch_darkbringer" );
        maps\mp\_utility::incPlayerStat( "mosttacprevented", 1 );
        thread maps\mp\gametypes\_hud_message::splashNotify( "denied", 20 );
        var_0 maps\mp\gametypes\_hud_message::playerCardSplashNotify( "destroyed_insertion", self );
        common_scripts\utility::waitframe();
    }
}

monitorFinalStandSurvival()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "revive" );
        processChallenge( "ch_livingdead" );
        common_scripts\utility::waitframe();
    }
}

initMissionData()
{
    var_0 = getarraykeys( level.killstreakFuncs );

    foreach ( var_2 in var_0 )
        self.pers[var_2] = 0;

    self.pers["lastBulletKillTime"] = 0;
    self.pers["bulletStreak"] = 0;
    self.explosiveInfo = [];
}

registerMissionCallback( var_0, var_1 )
{
    if ( !isdefined( level.missionCallbacks[var_0] ) )
        level.missionCallbacks[var_0] = [];

    level.missionCallbacks[var_0][level.missionCallbacks[var_0].size] = var_1;
}

getChallengeStatus( var_0 )
{
    if ( isdefined( self.challengeData[var_0] ) )
        return self.challengeData[var_0];
    else
        return 0;
}

ch_assists( var_0 )
{
    var_1 = var_0.player;
    var_1 processChallenge( "ch_assists" );
}

ch_hardpoints( var_0 )
{
    var_1 = var_0.player;
    var_1.pers[var_0.hardpointType]++;

    switch ( var_0.hardpointType )
    {
        case "uav":
            var_1 processChallenge( "ch_uav" );
            var_1 processChallenge( "ch_assault_streaks" );

            if ( var_1.pers["uav"] >= 3 )
                var_1 processChallenge( "ch_nosecrets" );

            break;
        case "airdrop_assault":
            var_1 processChallenge( "ch_airdrop_assault" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "predator_missile":
            var_1 processChallenge( "ch_predator_missile" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "ims":
            var_1 processChallenge( "ch_ims" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "airdrop_sentry_minigun":
            var_1 processChallenge( "ch_airdrop_sentry_minigun" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "precision_airstrike":
            var_1 processChallenge( "ch_precision_airstrike" );
            var_1 processChallenge( "ch_assault_streaks" );

            if ( var_1.pers["precision_airstrike"] >= 2 )
                var_1 processChallenge( "ch_afterburner" );

            break;
        case "helicopter":
            var_1 processChallenge( "ch_helicopter" );
            var_1 processChallenge( "ch_assault_streaks" );

            if ( var_1.pers["helicopter"] >= 2 )
                var_1 processChallenge( "ch_airsuperiority" );

            break;
        case "littlebird_flock":
            var_1 processChallenge( "ch_littlebird_flock" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "littlebird_support":
            var_1 processChallenge( "ch_littlebird_support" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "remote_mortar":
            var_1 processChallenge( "ch_remote_mortar" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "airdrop_remote_tank":
            var_1 processChallenge( "ch_airdrop_remote_tank" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "helicopter_flares":
            var_1 processChallenge( "ch_helicopter_flares" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "ac130":
            var_1 processChallenge( "ch_ac130" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "airdrop_juggernaut":
            var_1 processChallenge( "ch_airdrop_juggernaut" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "osprey_gunner":
            var_1 processChallenge( "ch_osprey_gunner" );
            var_1 processChallenge( "ch_assault_streaks" );
            break;
        case "uav_support":
            var_1 processChallenge( "ch_uav_support" );
            var_1 processChallenge( "ch_support_streaks" );

            if ( var_1.pers["uav"] >= 3 )
                var_1 processChallenge( "ch_nosecrets" );

            break;
        case "counter_uav":
            var_1 processChallenge( "ch_counter_uav" );
            var_1 processChallenge( "ch_support_streaks" );

            if ( var_1.pers["counter_uav"] >= 3 )
                var_1 processChallenge( "ch_sunblock" );

            break;
        case "deployable_vest":
            var_1 processChallenge( "ch_deployable_vest" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "airdrop_trap":
            var_1 processChallenge( "ch_airdrop_trap" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "sam_turret":
            var_1 processChallenge( "ch_sam_turret" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "remote_uav":
            var_1 processChallenge( "ch_remote_uav" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "triple_uav":
            var_1 processChallenge( "ch_triple_uav" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "remote_mg_turret":
            var_1 processChallenge( "ch_remote_mg_turret" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "stealth_airstrike":
            var_1 processChallenge( "ch_stealth_airstrike" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "emp":
            var_1 processChallenge( "ch_emp" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "airdrop_juggernaut_recon":
            var_1 processChallenge( "ch_airdrop_juggernaut_recon" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "escort_airdrop":
            var_1 processChallenge( "ch_escort_airdrop" );
            var_1 processChallenge( "ch_support_streaks" );
            break;
        case "specialty_longersprint_ks":
        case "specialty_longersprint_ks_pro":
            var_1 processChallenge( "ch_longersprint_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_fastreload_ks":
        case "specialty_fastreload_ks_pro":
            var_1 processChallenge( "ch_fastreload_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_scavenger_ks":
        case "specialty_scavenger_ks_pro":
            var_1 processChallenge( "ch_scavenger_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_blindeye_ks":
        case "specialty_blindeye_ks_pro":
            var_1 processChallenge( "ch_blindeye_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_paint_ks":
        case "specialty_paint_ks_pro":
            var_1 processChallenge( "ch_paint_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_hardline_ks":
        case "specialty_hardline_ks_pro":
            var_1 processChallenge( "ch_hardline_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_coldblooded_ks":
        case "specialty_coldblooded_ks_pro":
            var_1 processChallenge( "ch_coldblooded_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_quickdraw_ks":
        case "specialty_quickdraw_ks_pro":
            var_1 processChallenge( "ch_quickdraw_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "_specialty_blastshield_ks":
        case "_specialty_blastshield_ks_pro":
            var_1 processChallenge( "ch_blastshield_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_detectexplosive_ks":
        case "specialty_detectexplosive_ks_pro":
            var_1 processChallenge( "ch_detectexplosive_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_autospot_ks":
        case "specialty_autospot_ks_pro":
            var_1 processChallenge( "ch_autospot_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_bulletaccuracy_ks":
        case "specialty_bulletaccuracy_ks_pro":
            var_1 processChallenge( "ch_bulletaccuracy_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_quieter_ks":
        case "specialty_quieter_ks_pro":
            var_1 processChallenge( "ch_quieter_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "specialty_stalker_ks":
        case "specialty_stalker_ks_pro":
            var_1 processChallenge( "ch_stalker_ks" );
            var_1 processChallenge( "ch_specialist_streaks" );
            break;
        case "all_perks_bonus":
            var_1 processChallenge( "ch_all_perks_bonus" );
            break;
        case "nuke":
            var_1 processChallenge( "ch_nuke" );
            break;
    }
}

ch_vehicle_kills( var_0 )
{
    if ( !isdefined( var_0.attacker ) || !isplayer( var_0.attacker ) )
        return;

    if ( !maps\mp\_utility::isKillstreakWeapon( var_0.sWeapon ) )
        return;

    var_1 = var_0.attacker;

    if ( !isdefined( var_1.pers[var_0.sWeapon + "_streak"] ) || isdefined( var_1.pers[var_0.sWeapon + "_streakTime"] ) && gettime() - var_1.pers[var_0.sWeapon + "_streakTime"] > 7000 )
    {
        var_1.pers[var_0.sWeapon + "_streak"] = 0;
        var_1.pers[var_0.sWeapon + "_streakTime"] = gettime();
    }

    var_1.pers[var_0.sWeapon + "_streak"]++;

    switch ( var_0.sWeapon )
    {
        case "artillery_mp":
            var_1 processChallenge( "ch_carpetbomber" );

            if ( var_1.pers[var_0.sWeapon + "_streak"] >= 5 )
                var_1 processChallenge( "ch_carpetbomb" );

            if ( isdefined( var_1.finalKill ) )
                var_1 processChallenge( "ch_finishingtouch" );

            break;
        case "stealth_bomb_mp":
            var_1 processChallenge( "ch_thespirit" );

            if ( var_1.pers[var_0.sWeapon + "_streak"] >= 6 )
                var_1 processChallenge( "ch_redcarpet" );

            if ( isdefined( var_1.finalKill ) )
                var_1 processChallenge( "ch_technokiller" );

            break;
        case "pavelow_minigun_mp":
            var_1 processChallenge( "ch_jollygreengiant" );

            if ( isdefined( var_1.finalKill ) )
                var_1 processChallenge( "ch_transformer" );

            break;
        case "sentry_minigun_mp":
            var_1 processChallenge( "ch_looknohands" );

            if ( isdefined( var_1.finalKill ) )
                var_1 processChallenge( "ch_absentee" );

            break;
        case "ac130_105mm_mp":
        case "ac130_40mm_mp":
        case "ac130_25mm_mp":
            var_1 processChallenge( "ch_spectre" );

            if ( isdefined( var_1.finalKill ) )
                var_1 processChallenge( "ch_deathfromabove" );

            break;
        case "remotemissile_projectile_mp":
            var_1 processChallenge( "ch_predator" );

            if ( var_1.pers[var_0.sWeapon + "_streak"] >= 4 )
                var_1 processChallenge( "ch_reaper" );

            if ( isdefined( var_1.finalKill ) )
                var_1 processChallenge( "ch_dronekiller" );

            break;
        case "cobra_20mm_mp":
            var_1 processChallenge( "ch_choppervet" );

            if ( isdefined( var_1.finalKill ) )
                var_1 processChallenge( "ch_og" );

            break;
        case "nuke_mp":
            var_0.victim processChallenge( "ch_radiationsickness" );
            break;
        default:
            break;
    }
}

ch_vehicle_killed( var_0 )
{
    if ( !isdefined( var_0.attacker ) || !isplayer( var_0.attacker ) )
        return;

    var_1 = var_0.attacker;
}

clearIDShortly( var_0 )
{
    self endon( "disconnect" );
    self notify( "clearing_expID_" + var_0 );
    self endon( "clearing_expID_" + var_0 );
    wait 3.0;
    self.explosiveKills[var_0] = undefined;
}

MGKill()
{
    var_0 = self;

    if ( !isdefined( var_0.pers["MGStreak"] ) )
    {
        var_0.pers["MGStreak"] = 0;
        var_0 thread endMGStreakWhenLeaveMG();

        if ( !isdefined( var_0.pers["MGStreak"] ) )
            return;
    }

    var_0.pers["MGStreak"]++;

    if ( var_0.pers["MGStreak"] >= 5 )
        var_0 processChallenge( "ch_mgmaster" );
}

endMGStreakWhenLeaveMG()
{
    self endon( "disconnect" );

    for (;;)
    {
        if ( !isalive( self ) || self usebuttonpressed() )
        {
            self.pers["MGStreak"] = undefined;
            break;
        }

        wait 0.05;
    }
}

endMGStreak()
{
    self.pers["MGStreak"] = undefined;
}

killedBestEnemyPlayer( var_0 )
{
    if ( !isdefined( self.pers["countermvp_streak"] ) || !var_0 )
        self.pers["countermvp_streak"] = 0;

    self.pers["countermvp_streak"]++;

    if ( self.pers["countermvp_streak"] == 3 )
        processChallenge( "ch_thebiggertheyare" );
    else if ( self.pers["countermvp_streak"] == 5 )
        processChallenge( "ch_thehardertheyfall" );

    if ( self.pers["countermvp_streak"] >= 10 )
        processChallenge( "ch_countermvp" );
}

isHighestScoringPlayer( var_0 )
{
    if ( !isdefined( var_0.score ) || var_0.score < 1 )
        return 0;

    var_1 = level.players;

    if ( level.teamBased )
        var_2 = var_0.pers["team"];
    else
        var_2 = "all";

    var_3 = var_0.score;

    for ( var_4 = 0; var_4 < var_1.size; var_4++ )
    {
        if ( !isdefined( var_1[var_4].score ) )
            continue;

        if ( var_1[var_4].score < 1 )
            continue;

        if ( var_2 != "all" && var_1[var_4].pers["team"] != var_2 )
            continue;

        if ( var_1[var_4].score > var_3 )
            return 0;
    }

    return 1;
}

ch_kills( var_0, var_1 )
{
    var_0.victim playerDied();

    if ( !isdefined( var_0.attacker ) || !isplayer( var_0.attacker ) )
        return;

    var_2 = var_0.attacker;
    var_1 = var_0.time;

    if ( var_2.pers["cur_kill_streak"] == 10 )
        var_2 processChallenge( "ch_fearless" );

    if ( level.teamBased )
    {
        if ( level.teamCount[var_0.victim.pers["team"]] > 3 && var_2.killedPlayers.size >= level.teamCount[var_0.victim.pers["team"]] )
            var_2 processChallenge( "ch_tangodown" );

        if ( level.teamCount[var_0.victim.pers["team"]] > 3 && var_2.killedPlayersCurrent.size >= level.teamCount[var_0.victim.pers["team"]] )
            var_2 processChallenge( "ch_extremecruelty" );
    }

    if ( isdefined( var_0.victim.inPlayerSmokeScreen ) && var_0.victim.inPlayerSmokeScreen == var_2 )
        var_2 processChallenge( "ch_smokeemifyougotem" );

    if ( isdefined( var_0.victim.inPlayerScrambler ) && var_0.victim.inPlayerScrambler == var_2 )
        var_2 processChallenge( "ch_scram" );

    if ( isdefined( var_0.victim.inPlayerPortableRadar ) && var_0.victim.inPlayerPortableRadar == var_2 )
        var_2 processChallenge( "ch_zerolatency" );

    if ( isdefined( var_2.killedPlayers[var_0.victim.guid] ) && var_2.killedPlayers[var_0.victim.guid] == 5 )
        var_2 processChallenge( "ch_rival" );

    if ( isdefined( var_2.tookWeaponFrom[var_0.sWeapon] ) )
    {
        if ( var_2.tookWeaponFrom[var_0.sWeapon] == var_0.victim && var_0.sMeansOfDeath != "MOD_MELEE" )
            var_2 processChallenge( "ch_cruelty" );
    }

    var_3 = 0;
    var_4 = 0;
    var_5 = 0;
    var_6 = 1;
    var_7[var_0.victim.name] = var_0.victim.name;
    var_8[var_0.sWeapon] = var_0.sWeapon;
    var_9 = 1;
    var_10 = [];

    foreach ( var_12 in var_2.killsThisLife )
    {
        if ( maps\mp\_utility::isCACSecondaryWeapon( var_12.sWeapon ) && var_12.sMeansOfDeath != "MOD_MELEE" )
            var_4++;

        if ( isdefined( var_12.modifiers["longshot"] ) )
            var_5++;

        if ( var_1 - var_12.time < 10000 )
            var_6++;

        if ( maps\mp\_utility::isKillstreakWeapon( var_12.sWeapon ) )
        {
            if ( !isdefined( var_10[var_12.sWeapon] ) )
                var_10[var_12.sWeapon] = 0;

            var_10[var_12.sWeapon]++;
            continue;
        }

        if ( isdefined( level.oneLeftTime[var_2.team] ) && var_12.time > level.oneLeftTime[var_2.team] )
            var_3++;

        if ( isdefined( var_12.victim ) )
        {
            if ( !isdefined( var_7[var_12.victim.name] ) && !isdefined( var_8[var_12.sWeapon] ) && !maps\mp\_utility::isKillstreakWeapon( var_12.sWeapon ) )
                var_9++;

            var_7[var_12.victim.name] = var_12.victim.name;
        }

        var_8[var_12.sWeapon] = var_12.sWeapon;
    }

    foreach ( var_16, var_15 in var_10 )
    {
        if ( var_15 >= 10 )
            var_2 processChallenge( "ch_crabmeat" );
    }

    if ( var_9 == 3 )
        var_2 processChallenge( "ch_renaissance" );

    if ( var_6 > 3 && level.teamCount[var_0.victim.team] <= var_6 )
        var_2 processChallenge( "ch_omnicide" );

    if ( maps\mp\_utility::isCACSecondaryWeapon( var_0.sWeapon ) && var_4 == 2 )
        var_2 processChallenge( "ch_sidekick" );

    if ( isdefined( var_0.modifiers["longshot"] ) && var_5 == 2 )
        var_2 processChallenge( "ch_nbk" );

    if ( isdefined( level.oneLeftTime[var_2.team] ) && var_3 == 2 )
        var_2 processChallenge( "ch_enemyofthestate" );

    if ( var_2 isitemunlocked( "specialty_twoprimaries" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_twoprimaries" ) && var_2.secondaryWeapon == var_0.sWeapon )
        var_2 processChallenge( "ch_twoprimaries_pro" );

    if ( var_0.victim.score > 0 )
    {
        if ( level.teamBased )
        {
            var_17 = var_0.victim.pers["team"];

            if ( isdefined( var_17 ) && var_17 != var_2.pers["team"] )
            {
                if ( isHighestScoringPlayer( var_0.victim ) && level.players.size >= 6 )
                    var_2 killedBestEnemyPlayer( 1 );
                else
                    var_2 killedBestEnemyPlayer( 0 );
            }
        }
        else if ( isHighestScoringPlayer( var_0.victim ) && level.players.size >= 4 )
            var_2 killedBestEnemyPlayer( 1 );
        else
            var_2 killedBestEnemyPlayer( 0 );
    }

    if ( isdefined( var_0.modifiers["avenger"] ) )
        var_2 processChallenge( "ch_avenger" );

    if ( isdefined( var_0.modifiers["buzzkill"] ) && var_0.modifiers["buzzkill"] >= 9 )
        var_2 processChallenge( "ch_thedenier" );

    if ( isdefined( var_2.finalKill ) )
        var_2 processChallenge( "ch_theedge" );

    if ( maps\mp\_utility::isKillstreakWeapon( var_0.sWeapon ) )
        return;

    if ( isdefined( var_0.modifiers["jackintheboxkill"] ) )
        var_2 processChallenge( "ch_jackinthebox" );

    if ( isdefined( var_0.modifiers["cooking"] ) )
        var_2 processChallenge( "ch_no" );

    if ( isdefined( var_2.finalKill ) )
    {
        if ( isdefined( var_0.modifiers["revenge"] ) )
            var_2 processChallenge( "ch_moneyshot" );
    }

    if ( var_2 isAtBrinkOfDeath() )
    {
        var_2.brinkOfDeathKillStreak++;

        if ( var_2.brinkOfDeathKillStreak >= 3 )
            var_2 processChallenge( "ch_thebrink" );
    }

    if ( isdefined( var_2.inFinalStand ) && var_2.inFinalStand )
    {
        if ( isdefined( var_0.modifiers["revenge"] ) )
            var_2 processChallenge( "ch_robinhood" );

        if ( isdefined( var_2.finalKill ) )
            var_2 processChallenge( "ch_lastresort" );

        if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "c4_" ) )
            var_2 processChallenge( "ch_clickclickboom" );

        var_2 processChallenge( "ch_laststandvet" );
    }

    if ( var_0.sMeansOfDeath == "MOD_PISTOL_BULLET" || var_0.sMeansOfDeath == "MOD_RIFLE_BULLET" )
    {
        var_18 = maps\mp\_utility::getWeaponClass( var_0.sWeapon );
        ch_bulletDamageCommon( var_0, var_2, var_1, var_18 );

        if ( maps\mp\_utility::isEnvironmentWeapon( var_0.sWeapon ) )
            var_2 MGKill();
        else
        {
            var_19 = maps\mp\_utility::getBaseWeaponName( var_0.sWeapon );

            if ( isdefined( level.challengeInfo["ch_marksman_" + var_19] ) )
                var_2 processChallenge( "ch_marksman_" + var_19 );

            if ( isdefined( level.challengeInfo["pr_marksman_" + var_19] ) )
                var_2 processChallenge( "pr_marksman_" + var_19 );

            var_18 = tablelookup( "mp/statstable.csv", 4, var_19, 2 );

            switch ( var_18 )
            {
                case "weapon_smg":
                    var_2 processChallenge( "ch_smg_kill" );
                    break;
                case "weapon_assault":
                    var_2 processChallenge( "ch_ar_kill" );
                    break;
                case "weapon_shotgun":
                    var_2 processChallenge( "ch_shotgun_kill" );
                    break;
                case "weapon_sniper":
                    var_2 processChallenge( "ch_sniper_kill" );
                    break;
                case "weapon_pistol":
                    var_2 processChallenge( "ch_handgun_kill" );
                    break;
                case "weapon_machine_pistol":
                    var_2 processChallenge( "ch_machine_pistols_kill" );
                    break;
                case "weapon_lmg":
                    var_2 processChallenge( "ch_lmg_kill" );
                    break;
            }

            endswitch( 8 )  case "weapon_machine_pistol" loc_162B case "weapon_pistol" loc_161B case "weapon_shotgun" loc_15FB case "weapon_lmg" loc_163B case "weapon_sniper" loc_160B case "weapon_assault" loc_15EB case "weapon_smg" loc_15DB default loc_164B
        }
    }
    else if ( issubstr( var_0.sMeansOfDeath, "MOD_GRENADE" ) || issubstr( var_0.sMeansOfDeath, "MOD_EXPLOSIVE" ) || issubstr( var_0.sMeansOfDeath, "MOD_PROJECTILE" ) )
    {
        if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "frag_grenade_short" ) && ( !isdefined( var_0.victim.explosiveInfo["throwbackKill"] ) || !var_0.victim.explosiveInfo["throwbackKill"] ) )
            var_2 processChallenge( "ch_martyr" );

        if ( isdefined( var_0.victim.explosiveInfo["damageTime"] ) && var_0.victim.explosiveInfo["damageTime"] == var_1 )
        {
            if ( var_0.sWeapon == "none" )
                var_0.sWeapon = var_0.victim.explosiveInfo["weapon"];

            var_20 = var_1 + "_" + var_0.victim.explosiveInfo["damageId"];

            if ( !isdefined( var_2.explosiveKills[var_20] ) )
                var_2.explosiveKills[var_20] = 0;

            var_2 thread clearIDShortly( var_20 );
            var_2.explosiveKills[var_20]++;
            var_19 = maps\mp\_utility::getBaseWeaponName( var_0.sWeapon );

            if ( var_19 == "javelin" || var_19 == "m79" || var_19 == "at4" || var_19 == "rpg" || var_19 == "iw5_smaw" || var_19 == "xm25" )
            {
                var_2 processChallenge( "ch_launcher_kill" );

                if ( var_2.explosiveKills[var_20] > 1 )
                    var_2 processChallenge( "pr_expert_" + var_19 );
            }

            var_21 = maps\mp\_utility::getWeaponAttachments( var_0.sWeapon );

            foreach ( var_23 in var_21 )
            {
                switch ( var_23 )
                {
                    case "gp25":
                    case "m320":
                    case "gl":
                        if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "alt_" ) )
                            var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                        continue;
                }
            }

            if ( isdefined( var_0.victim.explosiveInfo["stickKill"] ) && var_0.victim.explosiveInfo["stickKill"] )
            {
                if ( isdefined( var_0.modifiers["revenge"] ) )
                    var_2 processChallenge( "ch_overdraft" );

                if ( isdefined( var_2.finalKill ) )
                    var_2 processChallenge( "ch_stickman" );

                if ( var_2.explosiveKills[var_20] > 1 )
                    var_2 processChallenge( "ch_grouphug" );
            }

            if ( isdefined( var_0.victim.explosiveInfo["stickFriendlyKill"] ) && var_0.victim.explosiveInfo["stickFriendlyKill"] )
                var_2 processChallenge( "ch_resourceful" );

            if ( !issubstr( var_19, "stinger" ) )
            {
                if ( isdefined( level.challengeInfo["ch_marksman_" + var_19] ) )
                    var_2 processChallenge( "ch_marksman_" + var_19 );

                if ( isdefined( level.challengeInfo["pr_marksman_" + var_19] ) )
                    var_2 processChallenge( "pr_marksman_" + var_19 );
            }

            if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "frag_" ) )
            {
                if ( var_2.explosiveKills[var_20] > 1 )
                    var_2 processChallenge( "ch_multifrag" );

                if ( isdefined( var_0.modifiers["revenge"] ) )
                    var_2 processChallenge( "ch_bangforbuck" );

                var_2 processChallenge( "ch_grenadekill" );

                if ( var_0.victim.explosiveInfo["cookedKill"] )
                    var_2 processChallenge( "ch_masterchef" );

                if ( var_0.victim.explosiveInfo["suicideGrenadeKill"] )
                    var_2 processChallenge( "ch_miserylovescompany" );

                if ( var_0.victim.explosiveInfo["throwbackKill"] )
                    var_2 processChallenge( "ch_hotpotato" );
            }
            else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "semtex_" ) )
            {
                if ( isdefined( var_0.modifiers["revenge"] ) )
                    var_2 processChallenge( "ch_timeismoney" );
            }
            else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "c4_" ) )
            {
                if ( isdefined( var_0.modifiers["revenge"] ) )
                    var_2 processChallenge( "ch_iamrich" );

                if ( var_2.explosiveKills[var_20] > 1 )
                    var_2 processChallenge( "ch_multic4" );

                if ( var_0.victim.explosiveInfo["returnToSender"] )
                    var_2 processChallenge( "ch_returntosender" );

                if ( var_0.victim.explosiveInfo["counterKill"] )
                    var_2 processChallenge( "ch_counterc4" );

                if ( isdefined( var_0.victim.explosiveInfo["bulletPenetrationKill"] ) && var_0.victim.explosiveInfo["bulletPenetrationKill"] )
                    var_2 processChallenge( "ch_howthe" );

                if ( var_0.victim.explosiveInfo["chainKill"] )
                    var_2 processChallenge( "ch_dominos" );

                var_2 processChallenge( "ch_c4shot" );
            }
            else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "claymore_" ) )
            {
                if ( isdefined( var_0.modifiers["revenge"] ) )
                    var_2 processChallenge( "ch_breakbank" );

                var_2 processChallenge( "ch_claymoreshot" );

                if ( var_2.explosiveKills[var_20] > 1 )
                    var_2 processChallenge( "ch_multiclaymore" );

                if ( var_0.victim.explosiveInfo["returnToSender"] )
                    var_2 processChallenge( "ch_returntosender" );

                if ( var_0.victim.explosiveInfo["counterKill"] )
                    var_2 processChallenge( "ch_counterclaymore" );

                if ( isdefined( var_0.victim.explosiveInfo["bulletPenetrationKill"] ) && var_0.victim.explosiveInfo["bulletPenetrationKill"] )
                    var_2 processChallenge( "ch_howthe" );

                if ( var_0.victim.explosiveInfo["chainKill"] )
                    var_2 processChallenge( "ch_dominos" );
            }
            else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "bouncingbetty_" ) )
                var_2 processChallenge( "ch_bouncingbetty" );
            else if ( var_0.sWeapon == "explodable_barrel" )
            {

            }
            else if ( var_0.sWeapon == "destructible_car" )
                var_2 processChallenge( "ch_carbomb" );
            else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "rpg_" ) || maps\mp\_utility::isStrStart( var_0.sWeapon, "at4_" ) || maps\mp\_utility::isStrStart( var_0.sWeapon, "iw5_smaw_" ) || maps\mp\_utility::isStrStart( var_0.sWeapon, "xm25_" ) )
            {
                if ( var_2.explosiveKills[var_20] > 1 )
                    var_2 processChallenge( "ch_multirpg" );
            }
        }
    }
    else if ( issubstr( var_0.sMeansOfDeath, "MOD_MELEE" ) && !issubstr( var_0.sWeapon, "riotshield_mp" ) )
    {
        var_2 endMGStreak();
        var_2 processChallenge( "ch_knifevet" );
        var_2.pers["meleeKillStreak"]++;

        if ( var_2.pers["meleeKillStreak"] == 3 )
            var_2 processChallenge( "ch_slasher" );

        if ( var_2 isitemunlocked( "specialty_quieter" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_quieter" ) )
            var_2 processChallenge( "ch_deadsilence_pro" );

        var_25 = var_0.victim.anglesOnDeath[1];
        var_26 = var_2.anglesOnKill[1];
        var_27 = angleclamp180( var_25 - var_26 );

        if ( abs( var_27 ) < 30 )
        {
            var_2 processChallenge( "ch_backstabber" );

            if ( isdefined( var_2.attackers ) )
            {
                foreach ( var_29 in var_2.attackers )
                {
                    if ( var_29 != var_0.victim )
                        continue;

                    var_2 processChallenge( "ch_neverforget" );
                    break;
                }
            }
        }

        if ( !var_2 playerHasAmmo() )
            var_2 processChallenge( "ch_survivor" );

        if ( isdefined( var_2.infected ) )
            var_0.victim processChallenge( "ch_infected" );

        if ( isdefined( var_0.victim.plague ) )
            var_2 processChallenge( "ch_plague" );

        var_19 = maps\mp\_utility::getBaseWeaponName( var_0.sWeapon );
        var_21 = maps\mp\_utility::getWeaponAttachments( var_0.sWeapon );

        foreach ( var_23 in var_21 )
        {
            switch ( var_23 )
            {
                case "tactical":
                    var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    if ( isdefined( level.challengeInfo["ch_marksman_" + var_19] ) )
                        var_2 processChallenge( "ch_marksman_" + var_19 );

                    if ( isdefined( level.challengeInfo["pr_marksman_" + var_19] ) )
                        var_2 processChallenge( "pr_marksman_" + var_19 );

                    continue;
            }
        }
    }
    else if ( issubstr( var_0.sMeansOfDeath, "MOD_MELEE" ) && issubstr( var_0.sWeapon, "riotshield_mp" ) )
    {
        var_2 endMGStreak();
        var_2 processChallenge( "ch_shieldvet" );
        var_2.pers["shieldKillStreak"]++;

        if ( var_2.pers["shieldKillStreak"] == 3 )
            var_2 processChallenge( "ch_smasher" );

        if ( isdefined( var_2.finalKill ) )
            var_2 processChallenge( "ch_owned" );

        var_2 processChallenge( "ch_riot_kill" );
        var_25 = var_0.victim.anglesOnDeath[1];
        var_26 = var_2.anglesOnKill[1];
        var_27 = angleclamp180( var_25 - var_26 );

        if ( abs( var_27 ) < 30 )
            var_2 processChallenge( "ch_backsmasher" );

        if ( !var_2 playerHasAmmo() )
            var_2 processChallenge( "ch_survivor" );
    }
    else if ( issubstr( var_0.sMeansOfDeath, "MOD_IMPACT" ) )
    {
        if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "frag_" ) )
            var_2 processChallenge( "ch_thinkfast" );
        else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "concussion_" ) )
            var_2 processChallenge( "ch_thinkfastconcussion" );
        else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "flash_" ) )
            var_2 processChallenge( "ch_thinkfastflash" );

        if ( var_0.sWeapon == "throwingknife_mp" )
        {
            if ( isdefined( var_0.modifiers["revenge"] ) )
                var_2 processChallenge( "ch_atm" );

            if ( var_1 < var_2.flashEndTime || var_1 < var_2.concussionEndTime )
                var_2 processChallenge( "ch_didyouseethat" );

            if ( isdefined( var_2.finalKill ) )
                var_2 processChallenge( "ch_unbelievable" );

            var_2 processChallenge( "ch_carnie" );

            if ( isdefined( var_0.victim.attackerData[var_2.guid].isPrimary ) )
                var_2 processChallenge( "ch_its_personal" );

            if ( var_2 isitemunlocked( "specialty_fastoffhand" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_fastoffhand" ) )
                var_2 processChallenge( "ch_fastoffhand" );
        }

        var_21 = maps\mp\_utility::getWeaponAttachments( var_0.sWeapon );
        var_19 = maps\mp\_utility::getBaseWeaponName( var_0.sWeapon );

        foreach ( var_23 in var_21 )
        {
            switch ( var_23 )
            {
                case "gp25":
                case "m320":
                case "gl":
                    if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "alt_" ) )
                    {
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                        if ( isdefined( level.challengeInfo["ch_marksman_" + var_19] ) )
                            var_2 processChallenge( "ch_marksman_" + var_19 );

                        if ( isdefined( level.challengeInfo["pr_marksman_" + var_19] ) )
                            var_2 processChallenge( "pr_marksman_" + var_19 );

                        var_2 processChallenge( "ch_ouch" );
                    }

                    continue;
            }
        }
    }
    else if ( var_0.sMeansOfDeath == "MOD_HEAD_SHOT" )
    {
        var_18 = maps\mp\_utility::getWeaponClass( var_0.sWeapon );
        ch_bulletDamageCommon( var_0, var_2, var_1, var_18 );

        switch ( var_18 )
        {
            case "weapon_smg":
                var_2 processChallenge( "ch_smg_kill" );
                var_2 processChallenge( "ch_expert_smg" );
                break;
            case "weapon_assault":
                var_2 processChallenge( "ch_ar_kill" );
                var_2 processChallenge( "ch_expert_assault" );
                break;
            case "weapon_shotgun":
                var_2 processChallenge( "ch_shotgun_kill" );
                break;
            case "weapon_sniper":
                var_2 processChallenge( "ch_sniper_kill" );
                break;
            case "weapon_pistol":
                var_2 processChallenge( "ch_handgun_kill" );
                break;
            case "weapon_machine_pistol":
                var_2 processChallenge( "ch_machine_pistols_kill" );
                break;
            case "weapon_lmg":
                var_2 processChallenge( "ch_lmg_kill" );
                var_2 processChallenge( "ch_expert_lmg" );
                break;
        }

        endswitch( 8 )  case "weapon_machine_pistol" loc_2187 case "weapon_pistol" loc_2177 case "weapon_shotgun" loc_2157 case "weapon_lmg" loc_2197 case "weapon_sniper" loc_2167 case "weapon_assault" loc_213C case "weapon_smg" loc_2121 default loc_21B2

        if ( isdefined( var_0.modifiers["revenge"] ) )
            var_2 processChallenge( "ch_colorofmoney" );

        if ( maps\mp\_utility::isEnvironmentWeapon( var_0.sWeapon ) )
            var_2 MGKill();
        else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "frag_" ) )
            var_2 processChallenge( "ch_thinkfast" );
        else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "concussion_" ) )
            var_2 processChallenge( "ch_thinkfastconcussion" );
        else if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "flash_" ) )
            var_2 processChallenge( "ch_thinkfastflash" );
        else
        {
            var_19 = maps\mp\_utility::getBaseWeaponName( var_0.sWeapon );

            if ( isdefined( level.challengeInfo["ch_expert_" + var_19] ) )
                var_2 processChallenge( "ch_expert_" + var_19 );

            if ( isdefined( level.challengeInfo["pr_expert_" + var_19] ) )
                var_2 processChallenge( "pr_expert_" + var_19 );

            if ( isdefined( level.challengeInfo["ch_marksman_" + var_19] ) )
                var_2 processChallenge( "ch_marksman_" + var_19 );

            if ( isdefined( level.challengeInfo["pr_marksman_" + var_19] ) )
                var_2 processChallenge( "pr_marksman_" + var_19 );
        }
    }

    if ( ( var_0.sMeansOfDeath == "MOD_PISTOL_BULLET" || var_0.sMeansOfDeath == "MOD_RIFLE_BULLET" || var_0.sMeansOfDeath == "MOD_HEAD_SHOT" ) && !maps\mp\_utility::isKillstreakWeapon( var_0.sWeapon ) && !maps\mp\_utility::isEnvironmentWeapon( var_0.sWeapon ) )
    {
        var_21 = maps\mp\_utility::getWeaponAttachments( var_0.sWeapon );
        var_19 = maps\mp\_utility::getBaseWeaponName( var_0.sWeapon );

        foreach ( var_23 in var_21 )
        {
            switch ( var_23 )
            {
                case "acog":
                case "acogsmg":
                    var_23 = "acog";

                    if ( var_2 playerads() )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "akimbo":
                    var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );
                    continue;
                case "eotech":
                case "eotechsmg":
                case "eotechlmg":
                    var_23 = "eotech";

                    if ( var_2 playerads() )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "grip":
                    var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );
                    continue;
                case "heartbeat":
                    var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );
                    continue;
                case "hamrhybrid":
                    if ( var_2 playerads() )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "hybrid":
                    if ( var_2 playerads() )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "reflex":
                case "reflexsmg":
                case "reflexlmg":
                    var_23 = "reflex";

                    if ( var_2 playerads() )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "rof":
                    var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );
                    continue;
                case "shotgun":
                    if ( maps\mp\_utility::isStrStart( var_0.sWeapon, "alt_" ) )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "silencer02":
                case "silencer03":
                case "silencer":
                case "silencer01":
                    var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );
                    continue;
                case "thermal":
                case "thermalsmg":
                    var_23 = "thermal";

                    if ( var_2 playerads() )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "vzscope":
                    if ( var_2 playerads() )
                        var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );

                    continue;
                case "xmags":
                    var_2 processChallenge( "ch_" + var_19 + "_" + var_23 );
                    continue;
                default:
                    continue;
            }
        }

        if ( var_2 isitemunlocked( "specialty_autospot" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_autospot" ) && ( var_2.holdingBreath && var_2 playerads() ) )
            var_2 processChallenge( "ch_autospot_pro" );

        if ( var_2 isitemunlocked( "specialty_bulletaccuracy" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_bulletaccuracy" ) && !var_2 playerads() )
            var_2 processChallenge( "ch_bulletaccuracy_pro" );

        if ( var_2 isitemunlocked( "specialty_stalker" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_stalker" ) && var_2 playerads() )
            var_2 processChallenge( "ch_stalker_pro" );

        if ( distancesquared( var_2.origin, var_0.victim.origin ) < 65536 )
        {
            if ( var_2 isitemunlocked( "specialty_quieter" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_quieter" ) )
                var_2 processChallenge( "ch_deadsilence_pro" );
        }

        if ( var_2 isitemunlocked( "specialty_fastreload" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_fastreload" ) )
            var_2 processChallenge( "ch_sleightofhand_pro" );

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_marksman", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_marksman", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_marksman" ) && var_2 playerads() )
            var_2 processChallenge( "ch_kickstop" );

        if ( var_0.victim.iDFlagsTime == var_1 )
        {
            if ( var_0.victim.iDFlags & level.iDFLAGS_PENETRATION )
            {
                if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_bulletpenetration", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_bulletpenetration", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_bulletpenetration" ) )
                    var_2 processChallenge( "ch_xrayvision" );
            }
        }

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_bling", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_bling", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_bling" ) && var_21.size > 1 )
            var_2 processChallenge( "ch_blingbling" );

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_sharp_focus", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_sharp_focus", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_sharp_focus" ) && var_2.health < var_2.maxHealth && isdefined( var_2.attackers ) )
        {
            foreach ( var_29 in var_2.attackers )
            {
                if ( var_29 == var_0.victim )
                {
                    var_2 processChallenge( "ch_unshakeable" );
                    break;
                }
            }
        }

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_holdbreathwhileads", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_holdbreathwhileads", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_holdbreathwhileads" ) && ( var_2.holdingBreath && var_2 playerads() ) )
            var_2 processChallenge( "ch_holditrightthere" );

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_reducedsway", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_reducedsway", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_reducedsway" ) && var_2 playerads() )
            var_2 processChallenge( "ch_swayless" );

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_longerrange", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_longerrange", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_longerrange" ) )
            var_2 processChallenge( "ch_longishshot" );

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_lightweight", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_lightweight", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_lightweight" ) )
            var_2 processChallenge( "ch_lightweight" );

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_moredamage", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_moredamage", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_moredamage" ) )
            var_2 processChallenge( "ch_moredamage" );
    }

    if ( var_0.sMeansOfDeath == "MOD_MELEE" )
    {
        var_19 = maps\mp\_utility::getBaseWeaponName( var_0.sWeapon );

        if ( var_2 maps\mp\_utility::isBuffUnlockedForWeapon( "specialty_fastermelee", var_19 ) && var_2 maps\mp\_utility::isBuffEquippedOnWeapon( "specialty_fastermelee", var_19 ) && var_2 maps\mp\_utility::_hasPerk( "specialty_fastermelee" ) )
            var_2 processChallenge( "ch_coldsteel" );
    }

    if ( var_2 isitemunlocked( "specialty_quickdraw" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_quickdraw" ) && ( var_2.adsTime > 0 && var_2.adsTime < 3 ) )
        var_2 processChallenge( "ch_quickdraw_pro" );

    if ( var_2 isitemunlocked( "specialty_coldblooded" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_coldblooded" ) )
    {
        if ( level.teamBased )
        {
            var_39 = 0;

            foreach ( var_41 in level.uavmodels[maps\mp\_utility::getOtherTeam( var_2.team )] )
            {
                switch ( var_41.uavType )
                {
                    case "remote_mortar":
                    case "counter":
                        continue;
                }

                var_39 = 1;
                break;
            }

            if ( var_39 )
                var_2 processChallenge( "ch_coldblooded_pro" );
        }
        else
        {
            var_43 = 0;

            foreach ( var_45 in level.players )
            {
                if ( var_45 == var_2 )
                    continue;

                var_43 += level.activeUAVs[var_45.guid];
            }

            if ( var_43 > 0 )
                var_2 processChallenge( "ch_coldblooded_pro" );
        }
    }

    if ( var_2 isitemunlocked( "specialty_empimmune" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_empimmune" ) )
    {
        if ( level.teamBased )
        {
            var_47 = 0;

            foreach ( var_49 in level.uavmodels[maps\mp\_utility::getOtherTeam( var_2.team )] )
            {
                if ( var_49.uavType != "counter" )
                    continue;

                var_47 = 1;
                break;
            }

            if ( var_47 || var_2 maps\mp\_utility::isEMPed() )
                var_2 processChallenge( "ch_spygame" );
        }
        else if ( var_2.isradarblocked || var_2 maps\mp\_utility::isEMPed() )
            var_2 processChallenge( "ch_spygame" );
    }

    if ( isdefined( var_0.victim.isPlanting ) && var_0.victim.isPlanting )
        var_2 processChallenge( "ch_bombplanter" );

    if ( isdefined( var_0.victim.isDefusing ) && var_0.victim.isDefusing )
        var_2 processChallenge( "ch_bombdefender" );

    if ( isdefined( var_0.victim.isBombCarrier ) && var_0.victim.isBombCarrier && ( !isdefined( level.dd ) || !level.dd ) )
        var_2 processChallenge( "ch_bombdown" );

    if ( isdefined( var_0.victim.wasTI ) && var_0.victim.wasTI )
        var_2 processChallenge( "ch_tacticaldeletion" );

    if ( var_2 isitemunlocked( "specialty_quickswap" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_quickswap" ) )
    {
        if ( isdefined( var_2.lastPrimaryWeaponSwapTime ) && gettime() - var_2.lastPrimaryWeaponSwapTime < 3000 )
            var_2 processChallenge( "ch_quickswap" );
    }

    if ( var_2 isitemunlocked( "specialty_extraammo" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_extraammo" ) )
        var_2 processChallenge( "ch_extraammo" );

    if ( isexplosivedamagemod( var_0.sMeansOfDeath ) )
    {
        switch ( var_0.sWeapon )
        {
            case "frag_grenade_mp":
            case "flash_grenade_mp":
            case "concussion_grenade_mp":
            case "semtex_mp":
            case "emp_grenade_mp":
                if ( var_2 isitemunlocked( "specialty_fastoffhand" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_fastoffhand" ) )
                    var_2 processChallenge( "ch_fastoffhand" );

                break;
        }
    }

    if ( var_2 isitemunlocked( "specialty_overkillpro" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_overkillpro" ) )
    {
        if ( var_2.secondaryWeapon == var_0.sWeapon )
        {
            var_21 = maps\mp\_utility::getWeaponAttachments( var_0.sWeapon );

            if ( var_21.size > 0 )
                var_2 processChallenge( "ch_secondprimary" );
        }
    }

    if ( var_2 isitemunlocked( "specialty_stun_resistance" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_stun_resistance" ) )
    {
        if ( isdefined( var_2.lastFlashedTime ) && gettime() - var_2.lastFlashedTime < 5000 )
            var_2 processChallenge( "ch_stunresistance" );
        else if ( isdefined( var_2.lastConcussedTime ) && gettime() - var_2.lastConcussedTime < 5000 )
            var_2 processChallenge( "ch_stunresistance" );
    }

    if ( var_2 isitemunlocked( "specialty_selectivehearing" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_selectivehearing" ) )
        var_2 processChallenge( "ch_selectivehearing" );

    if ( var_2 isitemunlocked( "specialty_fastsprintrecovery" ) && var_2 maps\mp\_utility::_hasPerk( "specialty_fastsprintrecovery" ) )
    {
        if ( isdefined( var_2.lastSprintEndTime ) && gettime() - var_2.lastSprintEndTime < 3000 )
            var_2 processChallenge( "ch_fastsprintrecovery" );
    }
}

ch_bulletDamageCommon( var_0, var_1, var_2, var_3 )
{
    if ( !maps\mp\_utility::isEnvironmentWeapon( var_0.sWeapon ) )
        var_1 endMGStreak();

    if ( maps\mp\_utility::isKillstreakWeapon( var_0.sWeapon ) )
        return;

    if ( var_1.pers["lastBulletKillTime"] == var_2 )
        var_1.pers["bulletStreak"]++;
    else
        var_1.pers["bulletStreak"] = 1;

    var_1.pers["lastBulletKillTime"] = var_2;

    if ( !var_0.victimOnGround )
        var_1 processChallenge( "ch_hardlanding" );

    if ( !var_0.attackerOnGround )
        var_1.pers["midairStreak"]++;

    if ( var_1.pers["midairStreak"] == 2 )
        var_1 processChallenge( "ch_airborne" );

    if ( var_2 < var_0.victim.flashEndTime )
        var_1 processChallenge( "ch_flashbangvet" );

    if ( var_2 < var_1.flashEndTime )
        var_1 processChallenge( "ch_blindfire" );

    if ( var_2 < var_0.victim.concussionEndTime )
        var_1 processChallenge( "ch_concussionvet" );

    if ( var_2 < var_1.concussionEndTime )
        var_1 processChallenge( "ch_slowbutsure" );

    if ( var_1.pers["bulletStreak"] == 2 )
    {
        if ( isdefined( var_0.modifiers["headshot"] ) )
        {
            foreach ( var_5 in var_1.killsThisLife )
            {
                if ( var_5.time != var_2 )
                    continue;

                if ( !isdefined( var_0.modifiers["headshot"] ) )
                    continue;

                var_1 processChallenge( "ch_allpro" );
            }
        }

        if ( var_3 == "weapon_sniper" )
            var_1 processChallenge( "ch_collateraldamage" );
    }

    if ( var_3 == "weapon_pistol" )
    {
        if ( isdefined( var_0.victim.attackerData ) && isdefined( var_0.victim.attackerData[var_1.guid] ) )
        {
            if ( isdefined( var_0.victim.attackerData[var_1.guid].isPrimary ) )
                var_1 processChallenge( "ch_fastswap" );
        }
    }

    if ( !isdefined( var_1.inFinalStand ) || !var_1.inFinalStand )
    {
        if ( var_0.attackerStance == "crouch" )
            var_1 processChallenge( "ch_crouchshot" );
        else if ( var_0.attackerStance == "prone" )
        {
            var_1 processChallenge( "ch_proneshot" );

            if ( var_3 == "weapon_sniper" )
                var_1 processChallenge( "ch_invisible" );
        }
    }

    if ( var_3 == "weapon_sniper" )
    {
        if ( isdefined( var_0.modifiers["oneshotkill"] ) )
            var_1 processChallenge( "ch_ghillie" );
    }

    if ( issubstr( var_0.sWeapon, "silencer" ) )
        var_1 processChallenge( "ch_stealthvet" );
}

ch_roundplayed( var_0 )
{
    var_1 = var_0.player;

    if ( var_1.wasAliveAtMatchStart )
    {
        var_2 = var_1.pers["deaths"];
        var_3 = var_1.pers["kills"];
        var_4 = 1000000;

        if ( var_2 > 0 )
            var_4 = var_3 / var_2;

        if ( var_4 >= 5.0 && var_3 >= 5.0 )
            var_1 processChallenge( "ch_starplayer" );

        if ( var_2 == 0 && maps\mp\_utility::getTimePassed() > 300000 )
            var_1 processChallenge( "ch_flawless" );

        if ( level.placement["all"].size < 3 )
            return;

        if ( var_1.score > 0 )
        {
            switch ( level.gameType )
            {
                case "dm":
                    if ( var_0.place < 3 )
                    {
                        var_1 processChallenge( "ch_victor_dm" );
                        var_1 processChallenge( "ch_ffa_win" );
                    }

                    var_1 processChallenge( "ch_ffa_participate" );
                    break;
                case "war":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_war_win" );

                    var_1 processChallenge( "ch_war_participate" );
                    break;
                case "kc":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_kc_win" );

                    var_1 processChallenge( "ch_kc_participate" );
                    break;
                case "dd":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_dd_win" );

                    var_1 processChallenge( "ch_dd_participate" );
                    break;
                case "koth":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_koth_win" );

                    var_1 processChallenge( "ch_koth_participate" );
                    break;
                case "sab":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_sab_win" );

                    var_1 processChallenge( "ch_sab_participate" );
                    break;
                case "sd":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_sd_win" );

                    var_1 processChallenge( "ch_sd_participate" );
                    break;
                case "dom":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_dom_win" );

                    var_1 processChallenge( "ch_dom_participate" );
                    break;
                case "ctf":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_ctf_win" );

                    var_1 processChallenge( "ch_ctf_participate" );
                    break;
                case "tdef":
                    if ( var_0.winner )
                        var_1 processChallenge( "ch_tdef_win" );

                    var_1 processChallenge( "ch_tdef_participate" );
                    break;
            }
        }
    }
}

ch_roundwin( var_0 )
{
    if ( !var_0.winner )
        return;

    var_1 = var_0.player;

    if ( var_1.wasAliveAtMatchStart )
    {
        switch ( level.gameType )
        {
            case "war":
                if ( level.hardcoreMode )
                {
                    var_1 processChallenge( "ch_teamplayer_hc" );

                    if ( var_0.place == 0 )
                        var_1 processChallenge( "ch_mvp_thc" );
                }
                else
                {
                    var_1 processChallenge( "ch_teamplayer" );

                    if ( var_0.place == 0 )
                        var_1 processChallenge( "ch_mvp_tdm" );
                }

                break;
            case "sab":
                var_1 processChallenge( "ch_victor_sab" );
                break;
            case "sd":
                var_1 processChallenge( "ch_victor_sd" );
                break;
            case "dm":
            case "koth":
            case "dom":
            case "ctf":
            case "hc":
                break;
            default:
                break;
        }
    }
}

playerDamaged( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    self endon( "disconnect" );

    if ( isdefined( var_1 ) )
        var_1 endon( "disconnect" );

    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();
    var_6 = spawnstruct();
    var_6.victim = self;
    var_6.eInflictor = var_0;
    var_6.attacker = var_1;
    var_6.iDamage = var_2;
    var_6.sMeansOfDeath = var_3;
    var_6.sWeapon = var_4;
    var_6.sHitLoc = var_5;
    var_6.victimOnGround = var_6.victim isonground();

    if ( isplayer( var_1 ) )
    {
        var_6.attackerInLastStand = isdefined( var_6.attacker.laststand );
        var_6.attackerOnGround = var_6.attacker isonground();
        var_6.attackerStance = var_6.attacker getstance();
    }
    else
    {
        var_6.attackerInLastStand = 0;
        var_6.attackerOnGround = 0;
        var_6.attackerStance = "stand";
    }

    doMissionCallback( "playerDamaged", var_6 );
}

playerKilled( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    self.anglesOnDeath = self getplayerangles();

    if ( isdefined( var_1 ) )
        var_1.anglesOnKill = var_1 getplayerangles();

    self endon( "disconnect" );
    var_8 = spawnstruct();
    var_8.victim = self;
    var_8.eInflictor = var_0;
    var_8.attacker = var_1;
    var_8.iDamage = var_2;
    var_8.sMeansOfDeath = var_3;
    var_8.sWeapon = var_4;
    var_8.sPrimaryWeapon = var_5;
    var_8.sHitLoc = var_6;
    var_8.time = gettime();
    var_8.modifiers = var_7;
    var_8.victimOnGround = var_8.victim isonground();

    if ( isplayer( var_1 ) )
    {
        var_8.attackerInLastStand = isdefined( var_8.attacker.laststand );
        var_8.attackerOnGround = var_8.attacker isonground();
        var_8.attackerStance = var_8.attacker getstance();
    }
    else
    {
        var_8.attackerInLastStand = 0;
        var_8.attackerOnGround = 0;
        var_8.attackerStance = "stand";
    }

    waitAndProcessPlayerKilledCallback( var_8 );

    if ( isdefined( var_1 ) && maps\mp\_utility::isReallyAlive( var_1 ) )
        var_1.killsThisLife[var_1.killsThisLife.size] = var_8;

    var_8.attacker notify( "playerKilledChallengesProcessed" );
}

vehicleKilled( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    var_7 = spawnstruct();
    var_7.vehicle = var_1;
    var_7.victim = var_0;
    var_7.eInflictor = var_2;
    var_7.attacker = var_3;
    var_7.iDamage = var_4;
    var_7.sMeansOfDeath = var_5;
    var_7.sWeapon = var_6;
    var_7.time = gettime();

    if ( isdefined( var_3 ) && isplayer( var_3 ) && ( !isdefined( var_0 ) || var_3 != var_0 ) && !maps\mp\_utility::isKillstreakWeapon( var_6 ) )
    {
        var_3 maps\mp\killstreaks\_killstreaks::giveAdrenaline( "vehicleDestroyed" );

        switch ( var_6 )
        {
            case "stinger_mp":
                if ( isdefined( var_1.heliType ) && ( var_1.heliType == "flares" || var_1.heliType == "littlebird" || var_1.heliType == "helicopter" || var_1.heliType == "airdrop" ) )
                    var_3 processChallenge( "pr_expert_stinger" );

                var_3 processChallenge( "ch_marksman_stinger" );
                var_3 processChallenge( "pr_marksman_stinger" );
                break;
            default:
                var_8 = maps\mp\_utility::getBaseWeaponName( var_6 );

                if ( isdefined( level.challengeInfo["ch_marksman_" + var_8] ) )
                    var_3 processChallenge( "ch_marksman_" + var_8 );

                if ( isdefined( level.challengeInfo["pr_marksman_" + var_8] ) )
                    var_3 processChallenge( "pr_marksman_" + var_8 );

                break;
        }

        switch ( var_6 )
        {
            case "stinger_mp":
            case "iw5_smaw_mp":
            case "javelin_mp":
                if ( var_3 isitemunlocked( "specialty_fasterlockon" ) && var_3 maps\mp\_utility::_hasPerk( "specialty_fasterlockon" ) )
                    var_3 processChallenge( "ch_fasterlockon" );

                break;
        }

        if ( var_3 isitemunlocked( "specialty_blindeye" ) && var_3 maps\mp\_utility::_hasPerk( "specialty_blindeye" ) )
        {
            var_9 = 1;

            if ( isdefined( var_3.scramProxyPerk ) && var_3.scramProxyPerk )
                var_9 = 0;

            if ( isdefined( var_3.spawnperk ) && var_3.spawnperk )
                var_9 = 0;

            if ( var_9 )
                var_3 processChallenge( "ch_blindeye_pro" );
        }
    }
}

waitAndProcessPlayerKilledCallback( var_0 )
{
    if ( isdefined( var_0.attacker ) )
        var_0.attacker endon( "disconnect" );

    self.processingKilledChallenges = 1;
    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();
    doMissionCallback( "playerKilled", var_0 );
    self.processingKilledChallenges = undefined;
}

playerAssist()
{
    var_0 = spawnstruct();
    var_0.player = self;
    doMissionCallback( "playerAssist", var_0 );
}

useHardpoint( var_0 )
{
    self endon( "disconnect" );
    wait 0.05;
    maps\mp\_utility::WaitTillSlowProcessAllowed();
    var_1 = spawnstruct();
    var_1.player = self;
    var_1.hardpointType = var_0;
    doMissionCallback( "playerHardpoint", var_1 );
}

roundBegin()
{
    doMissionCallback( "roundBegin" );
}

roundEnd( var_0 )
{
    var_1 = spawnstruct();

    if ( level.teamBased )
    {
        var_2 = "allies";

        for ( var_3 = 0; var_3 < level.placement[var_2].size; var_3++ )
        {
            var_1.player = level.placement[var_2][var_3];
            var_1.winner = var_2 == var_0;
            var_1.place = var_3;
            doMissionCallback( "roundEnd", var_1 );
        }

        var_2 = "axis";

        for ( var_3 = 0; var_3 < level.placement[var_2].size; var_3++ )
        {
            var_1.player = level.placement[var_2][var_3];
            var_1.winner = var_2 == var_0;
            var_1.place = var_3;
            doMissionCallback( "roundEnd", var_1 );
        }
    }
    else
    {
        for ( var_3 = 0; var_3 < level.placement["all"].size; var_3++ )
        {
            var_1.player = level.placement["all"][var_3];
            var_1.winner = isdefined( var_0 ) && isplayer( var_0 ) && var_1.player == var_0;
            var_1.place = var_3;
            doMissionCallback( "roundEnd", var_1 );
        }
    }
}

doMissionCallback( var_0, var_1 )
{
    if ( !mayProcessChallenges() )
        return;

    if ( getdvarint( "disable_challenges" ) > 0 )
        return;

    if ( !isdefined( level.missionCallbacks[var_0] ) )
        return;

    if ( isdefined( var_1 ) )
    {
        for ( var_2 = 0; var_2 < level.missionCallbacks[var_0].size; var_2++ )
            thread [[ level.missionCallbacks[var_0][var_2] ]]( var_1 );
    }
    else
    {
        for ( var_2 = 0; var_2 < level.missionCallbacks[var_0].size; var_2++ )
            thread [[ level.missionCallbacks[var_0][var_2] ]]();
    }
}

monitorSprintDistance()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "sprint_begin" );
        self.sprintDistThisSprint = 0;
        thread monitorSprintTime();
        monitorSingleSprintDistance();

        if ( self isitemunlocked( "specialty_longersprint" ) && maps\mp\_utility::_hasPerk( "specialty_longersprint" ) )
            processChallenge( "ch_longersprint_pro", int( self.sprintDistThisSprint / 12 ) );
    }
}

monitorSingleSprintDistance()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "sprint_end" );
    var_0 = self.origin;

    for (;;)
    {
        wait 0.1;
        self.sprintDistThisSprint = self.sprintDistThisSprint + distance( self.origin, var_0 );
        var_0 = self.origin;
    }
}

monitorSprintTime()
{
    level endon( "game_ended" );
    self endon( "spawned_player" );
    self endon( "death" );
    self endon( "disconnect" );
    var_0 = gettime();
    self waittill( "sprint_end" );
    var_1 = int( gettime() - var_0 );
    maps\mp\_utility::incPlayerStat( "sprinttime", var_1 );
    self.lastSprintEndTime = gettime();
}

monitorFallDistance()
{
    self endon( "disconnect" );
    self.pers["midairStreak"] = 0;

    for (;;)
    {
        if ( !isalive( self ) )
        {
            self waittill( "spawned_player" );
            continue;
        }

        if ( !self isonground() )
        {
            self.pers["midairStreak"] = 0;
            var_0 = self.origin[2];

            while ( !self isonground() && isalive( self ) )
            {
                if ( self.origin[2] > var_0 )
                    var_0 = self.origin[2];

                wait 0.05;
            }

            self.pers["midairStreak"] = 0;
            var_1 = var_0 - self.origin[2];

            if ( var_1 < 0 )
                var_1 = 0;

            if ( var_1 / 12.0 > 15 && isalive( self ) )
                processChallenge( "ch_basejump" );

            if ( var_1 / 12.0 > 30 && !isalive( self ) )
                processChallenge( "ch_goodbye" );
        }

        wait 0.05;
    }
}

lastManSD()
{
    if ( !mayProcessChallenges() )
        return;

    if ( !self.wasAliveAtMatchStart )
        return;

    if ( self.teamkillsThisRound > 0 )
        return;

    processChallenge( "ch_lastmanstanding" );
}

monitorBombUse()
{
    self endon( "disconnect" );

    for (;;)
    {
        var_0 = common_scripts\utility::waittill_any_return( "bomb_planted", "bomb_defused" );

        if ( !isdefined( var_0 ) )
            continue;

        if ( var_0 == "bomb_planted" )
        {
            processChallenge( "ch_saboteur" );
            continue;
        }

        if ( var_0 == "bomb_defused" )
            processChallenge( "ch_hero" );
    }
}

monitorLiveTime()
{
    for (;;)
    {
        self waittill( "spawned_player" );
        thread survivalistChallenge();
    }
}

survivalistChallenge()
{
    self endon( "death" );
    self endon( "disconnect" );
    wait 300;

    if ( isdefined( self ) )
        processChallenge( "ch_survivalist" );
}

monitorStreaks()
{
    self endon( "disconnect" );
    self.pers["airstrikeStreak"] = 0;
    self.pers["meleeKillStreak"] = 0;
    self.pers["shieldKillStreak"] = 0;
    thread monitorMisc();

    for (;;)
    {
        self waittill( "death" );
        self.pers["airstrikeStreak"] = 0;
        self.pers["meleeKillStreak"] = 0;
        self.pers["shieldKillStreak"] = 0;
    }
}

monitorMisc()
{
    thread monitorMiscSingle( "destroyed_explosive" );
    thread monitorMiscSingle( "begin_airstrike" );
    thread monitorMiscSingle( "destroyed_car" );
    thread monitorMiscSingle( "destroyed_helicopter" );
    thread monitorMiscSingle( "used_uav" );
    thread monitorMiscSingle( "used_double_uav" );
    thread monitorMiscSingle( "used_triple_uav" );
    thread monitorMiscSingle( "used_counter_uav" );
    thread monitorMiscSingle( "used_directional_uav" );
    thread monitorMiscSingle( "used_airdrop" );
    thread monitorMiscSingle( "used_emp" );
    thread monitorMiscSingle( "used_nuke" );
    thread monitorMiscSingle( "crushed_enemy" );
    self waittill( "disconnect" );
    self notify( "destroyed_explosive" );
    self notify( "begin_airstrike" );
    self notify( "destroyed_car" );
    self notify( "destroyed_helicopter" );
}

monitorMiscSingle( var_0 )
{
    for (;;)
    {
        self waittill( var_0 );

        if ( !isdefined( self ) )
            return;

        monitorMiscCallback( var_0 );
    }
}

monitorMiscCallback( var_0 )
{
    switch ( var_0 )
    {
        case "begin_airstrike":
            self.pers["airstrikeStreak"] = 0;
            break;
        case "destroyed_explosive":
            if ( self isitemunlocked( "specialty_detectexplosive" ) && maps\mp\_utility::_hasPerk( "specialty_detectexplosive" ) )
                processChallenge( "ch_detectexplosives_pro" );

            processChallenge( "ch_backdraft" );
            break;
        case "destroyed_helicopter":
            processChallenge( "ch_flyswatter" );
            break;
        case "destroyed_car":
            processChallenge( "ch_vandalism" );
            break;
        case "crushed_enemy":
            processChallenge( "ch_heads_up" );

            if ( isdefined( self.finalKill ) )
                processChallenge( "ch_droppincrates" );

            break;
    }
}

healthRegenerated()
{
    if ( !isalive( self ) )
        return;

    if ( !mayProcessChallenges() )
        return;

    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    thread resetBrinkOfDeathKillStreakShortly();
    self notify( "healed" );

    if ( isdefined( self.lastDamageWasFromEnemy ) && self.lastDamageWasFromEnemy )
    {
        self.healthRegenerationStreak++;

        if ( self.healthRegenerationStreak >= 5 )
            processChallenge( "ch_invincible" );
    }
}

resetBrinkOfDeathKillStreakShortly()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "damage" );
    wait 1;
    self.brinkOfDeathKillStreak = 0;
}

playerSpawned()
{
    self.brinkOfDeathKillStreak = 0;
    self.healthRegenerationStreak = 0;
    self.pers["MGStreak"] = 0;
}

playerDied()
{
    self.brinkOfDeathKillStreak = 0;
    self.healthRegenerationStreak = 0;
    self.pers["MGStreak"] = 0;
}

isAtBrinkOfDeath()
{
    var_0 = self.health / self.maxHealth;
    return var_0 <= level.healthOverlayCutoff;
}

processChallenge( var_0, var_1, var_2 )
{
    if ( !mayProcessChallenges() )
        return;

    if ( level.players.size < 2 )
        return;

    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    if ( !isdefined( var_1 ) )
        var_1 = 1;

    if ( !issubstr( var_0, "_daily" ) && !issubstr( var_0, "_weekly" ) && self isitemunlocked( "tier_90" ) )
    {
        thread processChallenge( var_0 + "_daily", var_1, var_2 );
        thread processChallenge( var_0 + "_weekly", var_1, var_2 );
    }

    var_3 = getChallengeStatus( var_0 );

    if ( var_3 == 0 )
        return;

    if ( var_3 > level.challengeInfo[var_0]["targetval"].size )
        return;

    var_4 = maps\mp\gametypes\_hud_util::ch_getProgress( var_0 );

    if ( isdefined( var_2 ) && var_2 )
        var_5 = var_1;
    else
        var_5 = var_4 + var_1;

    var_6 = level.challengeInfo[var_0]["targetval"][var_3];

    if ( var_5 >= var_6 )
    {
        var_7 = 1;
        var_5 = var_6;
    }
    else
        var_7 = 0;

    if ( var_4 < var_5 )
        maps\mp\gametypes\_hud_util::ch_setProgress( var_0, var_5 );

    if ( var_7 )
    {
        thread giveRankXpAfterWait( var_0, var_3 );
        maps\mp\_matchdata::logChallenge( var_0, var_3 );

        if ( !isdefined( self.challengesCompleted ) )
            self.challengesCompleted = [];

        var_8 = 0;

        foreach ( var_10 in self.challengesCompleted )
        {
            if ( var_10 == var_0 )
                var_8 = 1;
        }

        if ( !var_8 )
            self.challengesCompleted[self.challengesCompleted.size] = var_0;

        var_3++;
        maps\mp\gametypes\_hud_util::ch_setState( var_0, var_3 );
        self.challengeData[var_0] = var_3;
        thread maps\mp\gametypes\_hud_message::challengeSplashNotify( var_0 );
    }
}

giveRankXpAfterWait( var_0, var_1 )
{
    self endon( "disconnect" );
    wait 0.25;
    maps\mp\gametypes\_rank::giveRankXP( "challenge", level.challengeInfo[var_0]["reward"][var_1], undefined, undefined, var_0 );
}

getMarksmanUnlockAttachment( var_0, var_1 )
{
    return tablelookup( "mp/unlockTable.csv", 0, var_0, 4 + var_1 );
}

getWeaponAttachment( var_0, var_1 )
{
    return tablelookup( "mp/statsTable.csv", 4, var_0, 11 + var_1 );
}

masteryChallengeProcess( var_0 )
{
    if ( tablelookup( "mp/allChallengesTable.csv", 0, "ch_" + var_0 + "_mastery", 1 ) == "" )
        return;

    var_1 = 0;

    for ( var_2 = 0; var_2 <= 10; var_2++ )
    {
        var_3 = getWeaponAttachment( var_0, var_2 );

        if ( var_3 == "" )
            continue;

        if ( maps\mp\gametypes\_class::isAttachmentUnlocked( var_0, var_3 ) )
            var_1++;
    }

    processChallenge( "ch_" + var_0 + "_mastery", var_1, 1 );
}

updateChallenges()
{
    self.challengeData = [];
    self endon( "disconnect" );

    if ( !mayProcessChallenges() )
        return;

    if ( !self isitemunlocked( "challenges" ) )
        return;

    var_0 = 0;

    foreach ( var_13, var_2 in level.challengeInfo )
    {
        var_0++;

        if ( var_0 % 40 == 0 )
            wait 0.05;

        self.challengeData[var_13] = 0;

        if ( isWeaponChallenge( var_13 ) )
        {
            if ( !self isitemunlocked( var_13 ) )
                continue;

            var_3 = getWeaponFromChallenge( var_13 );

            if ( !self isitemunlocked( var_3 ) )
                continue;

            var_4 = getWeaponAttachmentFromChallenge( var_13 );

            if ( isdefined( var_4 ) )
            {
                if ( !maps\mp\gametypes\_class::isAttachmentUnlocked( var_3, var_4 ) )
                    continue;
            }
        }
        else if ( isKillstreakChallenge( var_13 ) )
        {
            if ( !self isitemunlocked( var_13 ) )
                continue;

            var_5 = getKillstreakFromChallenge( var_13 );

            if ( isdefined( var_5 ) )
            {
                if ( !self getplayerdata( "killstreakUnlocked", var_5 ) )
                    continue;
            }
        }
        else
        {
            var_6 = self isitemunlocked( var_13 );

            if ( var_6 == 0 )
                continue;
            else if ( var_6 == 2 )
            {
                var_7 = getChallengeFilter( var_13 );

                if ( var_7 != "" )
                {
                    var_8 = getChallengeTable( var_7 );

                    if ( var_8 != "" )
                    {
                        var_9 = getTierFromTable( var_8, var_13 );

                        if ( var_9 != "" )
                        {
                            if ( !self isitemunlocked( var_9 ) )
                                continue;
                        }
                    }
                }
            }
        }

        if ( isdefined( var_2["requirement"] ) && !self isitemunlocked( var_2["requirement"] ) )
            continue;

        if ( var_2["type"] == 1 )
        {
            var_10 = maps\mp\gametypes\_hud_util::getDailyRef( var_13 );

            if ( var_10 == "" )
                continue;
        }
        else if ( var_2["type"] == 2 )
        {
            var_11 = maps\mp\gametypes\_hud_util::getWeeklyRef( var_13 );

            if ( var_11 == "" )
                continue;
        }

        var_12 = maps\mp\gametypes\_hud_util::ch_getState( var_13 );

        if ( var_12 == 0 )
        {
            maps\mp\gametypes\_hud_util::ch_setState( var_13, 1 );
            var_12 = 1;
        }

        self.challengeData[var_13] = var_12;
    }
}

isInUnlockTable( var_0 )
{
    return tablelookup( "mp/unlockTable.csv", 0, var_0, 0 ) != "";
}

getChallengeFilter( var_0 )
{
    return tablelookup( "mp/allChallengesTable.csv", 0, var_0, 5 );
}

getChallengeTable( var_0 )
{
    return tablelookup( "mp/challengeTable.csv", 8, var_0, 4 );
}

getTierFromTable( var_0, var_1 )
{
    return tablelookup( var_0, 0, var_1, 1 );
}

isWeaponChallenge( var_0 )
{
    if ( !isdefined( var_0 ) )
        return 0;

    var_1 = getChallengeFilter( var_0 );

    if ( isdefined( var_1 ) && var_1 == "riotshield" )
        return 1;

    var_2 = strtok( var_0, "_" );

    for ( var_3 = 0; var_3 < var_2.size; var_3++ )
    {
        var_4 = var_2[var_3];

        if ( var_4 == "iw5" )
            var_4 = var_2[var_3] + "_" + var_2[var_3 + 1];

        if ( maps\mp\gametypes\_class::isValidPrimary( var_4, 0 ) || maps\mp\gametypes\_class::isValidSecondary( var_4, "specialty_null", "specialty_null", 0 ) )
            return 1;
    }

    return 0;
}

getWeaponFromChallenge( var_0 )
{
    var_1 = "ch_";

    if ( issubstr( var_0, "ch_marksman_" ) )
        var_1 = "ch_marksman_";
    else if ( issubstr( var_0, "ch_expert_" ) )
        var_1 = "ch_expert_";
    else if ( issubstr( var_0, "pr_marksman_" ) )
        var_1 = "pr_marksman_";
    else if ( issubstr( var_0, "pr_expert_" ) )
        var_1 = "pr_expert_";

    var_2 = getsubstr( var_0, var_1.size, var_0.size );
    var_3 = strtok( var_2, "_" );
    var_2 = undefined;

    if ( var_3[0] == "iw5" )
        var_2 = var_3[0] + "_" + var_3[1];
    else
        var_2 = var_3[0];

    return var_2;
}

getWeaponAttachmentFromChallenge( var_0 )
{
    var_1 = "ch_";

    if ( issubstr( var_0, "ch_marksman_" ) )
        var_1 = "ch_marksman_";
    else if ( issubstr( var_0, "ch_expert_" ) )
        var_1 = "ch_expert_";
    else if ( issubstr( var_0, "pr_marksman_" ) )
        var_1 = "pr_marksman_";
    else if ( issubstr( var_0, "pr_expert_" ) )
        var_1 = "pr_expert_";

    var_2 = getsubstr( var_0, var_1.size, var_0.size );
    var_3 = strtok( var_2, "_" );
    var_4 = undefined;

    if ( isdefined( var_3[2] ) && maps\mp\_utility::isAttachment( var_3[2] ) )
        var_4 = var_3[2];

    return var_4;
}

isKillstreakChallenge( var_0 )
{
    if ( !isdefined( var_0 ) )
        return 0;

    var_1 = getChallengeFilter( var_0 );

    if ( isdefined( var_1 ) && ( var_1 == "killstreaks_assault" || var_1 == "killstreaks_support" ) )
        return 1;

    return 0;
}

getKillstreakFromChallenge( var_0 )
{
    var_1 = "ch_";
    var_2 = getsubstr( var_0, var_1.size, var_0.size );

    if ( var_2 == "assault_streaks" || var_2 == "support_streaks" )
        var_2 = undefined;

    return var_2;
}

challenge_targetVal( var_0, var_1, var_2 )
{
    var_3 = tablelookup( var_0, 0, var_1, 6 + ( var_2 - 1 ) * 2 );
    return int( var_3 );
}

challenge_rewardVal( var_0, var_1, var_2 )
{
    var_3 = tablelookup( var_0, 0, var_1, 7 + ( var_2 - 1 ) * 2 );
    return int( var_3 );
}

buildChallengeTableInfo( var_0, var_1 )
{
    var_2 = 0;
    var_3 = 0;
    var_4 = tablelookupbyrow( var_0, 0, 0 );

    for ( var_2 = 1; var_4 != ""; var_2++ )
    {
        level.challengeInfo[var_4] = [];
        level.challengeInfo[var_4]["type"] = var_1;
        level.challengeInfo[var_4]["targetval"] = [];
        level.challengeInfo[var_4]["reward"] = [];

        for ( var_5 = 1; var_5 < 11; var_5++ )
        {
            var_6 = challenge_targetVal( var_0, var_4, var_5 );
            var_7 = challenge_rewardVal( var_0, var_4, var_5 );

            if ( var_6 == 0 )
                break;

            level.challengeInfo[var_4]["targetval"][var_5] = var_6;
            level.challengeInfo[var_4]["reward"][var_5] = var_7;
            var_3 += var_7;
        }

        var_4 = tablelookupbyrow( var_0, var_2, 0 );
    }

    return int( var_3 );
}

buildChallegeInfo()
{
    level.challengeInfo = [];
    var_0 = 0;
    var_0 += buildChallengeTableInfo( "mp/allChallengesTable.csv", 0 );
    var_0 += buildChallengeTableInfo( "mp/dailychallengesTable.csv", 1 );
    var_0 += buildChallengeTableInfo( "mp/weeklychallengesTable.csv", 2 );
    var_1 = tablelookupbyrow( "mp/challengeTable.csv", 0, 4 );

    for ( var_2 = 1; var_1 != ""; var_2++ )
    {
        var_3 = tablelookupbyrow( var_1, 0, 0 );

        for ( var_4 = 1; var_3 != ""; var_4++ )
        {
            var_5 = tablelookup( var_1, 0, var_3, 1 );

            if ( var_5 != "" )
                level.challengeInfo[var_3]["requirement"] = var_5;

            var_3 = tablelookupbyrow( var_1, var_4, 0 );
        }

        var_1 = tablelookupbyrow( "mp/challengeTable.csv", var_2, 4 );
    }
}

monitorProcessChallenge()
{
    self endon( "disconnect" );
    level endon( "game_end" );

    for (;;)
    {
        if ( !mayProcessChallenges() )
            return;

        self waittill( "process",  var_0  );
        processChallenge( var_0 );
    }
}

monitorKillstreakProgress()
{
    self endon( "disconnect" );
    level endon( "game_end" );

    for (;;)
    {
        self waittill( "got_killstreak",  var_0  );

        if ( !isdefined( var_0 ) )
            continue;

        switch ( var_0 )
        {
            case 3:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "3streak" );
                break;
            case 4:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "4streak" );
                break;
            case 5:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "5streak" );
                break;
            case 6:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "6streak" );
                break;
            case 7:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "7streak" );
                break;
            case 8:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "8streak" );
                break;
            case 9:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "9streak" );
                break;
            case 10:
                maps\mp\killstreaks\_killstreaks::giveAdrenaline( "10streak" );
                break;
            default:
                break;
        }

        if ( var_0 == 10 && self.killstreaks.size == 0 )
        {
            processChallenge( "ch_theloner" );
            continue;
        }

        if ( var_0 == 9 )
        {
            if ( isdefined( self.killstreaks[7] ) && isdefined( self.killstreaks[8] ) && isdefined( self.killstreaks[9] ) )
                processChallenge( "ch_6fears7" );
        }
    }
}

monitorKilledKillstreak()
{
    self endon( "disconnect" );
    level endon( "game_end" );

    for (;;)
    {
        self waittill( "destroyed_killstreak",  var_0  );

        if ( self isitemunlocked( "specialty_blindeye" ) && maps\mp\_utility::_hasPerk( "specialty_blindeye" ) )
            processChallenge( "ch_blindeye_pro" );

        if ( isdefined( var_0 ) && var_0 == "stinger_mp" )
        {
            processChallenge( "ch_marksman_stinger" );
            processChallenge( "pr_marksman_stinger" );
        }
    }
}

genericChallenge( var_0, var_1 )
{
    switch ( var_0 )
    {
        case "hijacker_airdrop":
            processChallenge( "ch_smoothcriminal" );
            break;
        case "hijacker_airdrop_mega":
            processChallenge( "ch_poolshark" );
            break;
        case "wargasm":
            processChallenge( "ch_wargasm" );
            break;
        case "weapon_assault":
            processChallenge( "ch_surgical_assault" );
            break;
        case "weapon_smg":
            processChallenge( "ch_surgical_smg" );
            break;
        case "weapon_lmg":
            processChallenge( "ch_surgical_lmg" );
            break;
        case "weapon_sniper":
            processChallenge( "ch_surgical_sniper" );
            break;
        case "shield_damage":
            if ( !maps\mp\_utility::isJuggernaut() )
                processChallenge( "ch_shield_damage", var_1 );

            break;
        case "shield_bullet_hits":
            if ( !maps\mp\_utility::isJuggernaut() )
                processChallenge( "ch_shield_bullet", var_1 );

            break;
        case "shield_explosive_hits":
            if ( !maps\mp\_utility::isJuggernaut() )
                processChallenge( "ch_shield_explosive", var_1 );

            break;
    }
}

playerHasAmmo()
{
    var_0 = self getweaponslistprimaries();

    foreach ( var_2 in var_0 )
    {
        if ( self getweaponammoclip( var_2 ) )
            return 1;

        var_3 = weaponaltweaponname( var_2 );

        if ( !isdefined( var_3 ) || var_3 == "none" )
            continue;

        if ( self getweaponammoclip( var_3 ) )
            return 1;
    }

    return 0;
}

monitorADSTime()
{
    self endon( "disconnect" );
    self.adsTime = 0.0;

    for (;;)
    {
        if ( self playerads() == 1 )
            self.adsTime = self.adsTime + 0.05;
        else
            self.adsTime = 0.0;

        wait 0.05;
    }
}

monitorHoldBreath()
{
    self endon( "disconnect" );
    self.holdingBreath = 0;

    for (;;)
    {
        self waittill( "hold_breath" );
        self.holdingBreath = 1;
        self waittill( "release_breath" );
        self.holdingBreath = 0;
    }
}

monitorMantle()
{
    self endon( "disconnect" );
    self.mantling = 0;

    for (;;)
    {
        self waittill( "jumped" );
        var_0 = self getcurrentweapon();
        common_scripts\utility::waittill_notify_or_timeout( "weapon_change", 1 );
        var_1 = self getcurrentweapon();

        if ( var_1 == "none" )
            self.mantling = 1;
        else
            self.mantling = 0;

        if ( self.mantling )
        {
            if ( self isitemunlocked( "specialty_fastmantle" ) && maps\mp\_utility::_hasPerk( "specialty_fastmantle" ) )
                processChallenge( "ch_fastmantle" );

            common_scripts\utility::waittill_notify_or_timeout( "weapon_change", 1 );
            var_1 = self getcurrentweapon();

            if ( var_1 == var_0 )
                self.mantling = 0;
        }
    }
}

monitorWeaponSwap()
{
    self endon( "disconnect" );
    var_0 = self getcurrentweapon();

    for (;;)
    {
        self waittill( "weapon_change",  var_1  );

        if ( var_1 == "none" )
            continue;

        if ( var_1 == var_0 )
            continue;

        if ( maps\mp\_utility::isKillstreakWeapon( var_1 ) || maps\mp\_utility::isDeathStreakWeapon( var_1 ) )
            continue;

        if ( var_1 == "briefcase_bomb_mp" || var_1 == "briefcase_bomb_defuse_mp" )
            continue;

        var_2 = weaponinventorytype( var_1 );

        if ( var_2 != "primary" )
            continue;

        self.lastPrimaryWeaponSwapTime = gettime();
    }
}

monitorFlashbang()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "flashbang",  var_0, var_1, var_2, var_3  );

        if ( self == var_3 )
            continue;

        self.lastFlashedTime = gettime();
    }
}

monitorConcussion()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "concussed",  var_0  );

        if ( self == var_0 )
            continue;

        self.lastConcussedTime = gettime();
    }
}

monitorMineTriggering()
{
    self endon( "disconnect" );

    for (;;)
    {
        common_scripts\utility::waittill_any( "triggered_mine", "triggered_claymore", "triggered_ims" );
        thread waitDelayMineTime();
    }
}

waitDelayMineTime()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    wait(level.delayMineTime + 2);
    processChallenge( "ch_delaymine" );
}
