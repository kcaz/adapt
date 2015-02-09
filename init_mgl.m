function nothing = init_mgl(screen)
	mglOpen(screen.screen_num,screen.screendims(1),screen.screendims(2),screen.framerate,32);
	if ~isempty(screen.table)	
		mglSetGammaTable(screen.table);
	end	
	mglScreenCoordinates
	mglClearScreen([128 128 128]);
	mglFlush;
	
end
