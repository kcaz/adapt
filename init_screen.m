function screen = init_screen(screen)
    load gammaTable1
	screen.table = gammaTable1;
	screen.distance = 64.5;
	screen.dimcm = [34.8 26.1];
	screen.screendims = [1024 768]; 
	screen.framerate = 85;
	screen.imagesize = [256 256];
	screen.buffersize = screen.imagesize;
	screen.pixperdegree = pixelsperdegree(screen.screendims,screen.dimcm,screen.distance);
	screen.window = raised_cosine(screen.imagesize, round(0.425*min(screen.imagesize)), round(0.5*min(screen.imagesize)));
	screen.screen_num = 2;
	%{
	screen.screendims = [1366 768];
	screen.pixperdegree = 33.133;
	%}
end

