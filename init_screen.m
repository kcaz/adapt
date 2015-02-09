function screen = init_screen(screen)
	screen.table = load('calibbrownie15mar2012.mat');
	screen.table = screen.table.lut.table; %erg
	screen.distance = 64.5;
	screen.dimcm = [34.8 26.1];
	screen.screendims = [1024 768]; 
	screen.framerate = 85;
	screen.imagesize = [500 500];
	screen.buffersize = screen.imagesize;
	screen.pixperdegree = pixelsperdegree(screen.screendims,screen.dimcm,screen.distance);
	screen.window = raised_cosine(screen.imagesize, round(0.425*min(screen.imagesize)), round(0.5*min(screen.imagesize)));
	screen.screen_num = 2;
	%{
	screen.screendims = [1366 768];
	screen.pixperdegree = 33.133;
	%}
end

