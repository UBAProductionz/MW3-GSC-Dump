// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precacheshader( "progress_bar_bg" );
    precacheshader( "progress_bar_fg" );
    precacheshader( "progress_bar_fill" );
    level.uiParent = spawnstruct();
    level.uiParent.horzalign = "left";
    level.uiParent.vertalign = "top";
    level.uiParent.alignx = "left";
    level.uiParent.aligny = "top";
    level.uiParent.x = 0;
    level.uiParent.y = 0;
    level.uiParent.width = 0;
    level.uiParent.height = 0;
    level.uiParent.children = [];
    level.fontHeight = 12;
    level.hud["allies"] = spawnstruct();
    level.hud["axis"] = spawnstruct();
    level.primaryProgressBarY = -61;
    level.primaryProgressBarX = 0;
    level.primaryProgressBarHeight = 9;
    level.primaryProgressBarWidth = 120;
    level.primaryProgressBarTextY = -75;
    level.primaryProgressBarTextX = 0;
    level.primaryProgressBarFontSize = 0.6;
    level.teamProgressBarY = 32;
    level.teamProgressBarHeight = 14;
    level.teamProgressBarWidth = 192;
    level.teamProgressBarTextY = 8;
    level.teamProgressBarFontSize = 1.65;
    level.lowerTextYAlign = "BOTTOM";
    level.lowerTextY = -90;
    level.lowerTextFontSize = 1.6;
}

fontPulseInit( var_0 )
{
    self.baseFontScale = self.fontScale;

    if ( isdefined( var_0 ) )
        self.maxFontScale = min( var_0, 6.3 );
    else
        self.maxFontScale = min( self.fontScale * 2, 6.3 );

    self.inFrames = 2;
    self.outFrames = 4;
}

fontPulse( var_0 )
{
    self notify( "fontPulse" );
    self endon( "fontPulse" );
    self endon( "death" );
    var_0 endon( "disconnect" );
    var_0 endon( "joined_team" );
    var_0 endon( "joined_spectators" );
    self changefontscaleovertime( self.inFrames * 0.05 );
    self.fontScale = self.maxFontScale;
    wait(self.inFrames * 0.05);
    self changefontscaleovertime( self.outFrames * 0.05 );
    self.fontScale = self.baseFontScale;
}
