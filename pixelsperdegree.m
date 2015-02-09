function [pixperdegree] = pixelsperdegree(npixels, sizecm, distcm)

% usage: [pixperdegree] = pixelsperdegree(npixels, sizecm, distcm)
% date: 11/08/06
% by: Christopher Henry
% purpose: takes screensize in pixels and cm and distance to screen in cm
% as input and returns the number of pixels per degree of visual angle
% npixels = [#pixelswide #pixelshigh]
% sizecm = [widthincm heightincm]
% distcm = distance to screen in cm

pixpercminwidth = npixels(1)/sizecm(1);
pixpercminheight = npixels(2)/sizecm(2);
pixpercm = 0.5*(pixpercminwidth+pixpercminheight); %take average of two measurements (in the event that they differ)

%find how much 1 deg of visual angle subtends in cm, based on distance to
%screen

%tan(0.5degree) = distance on screen/distance to screen
%in radians, 0.5 degrees = 0.5*(pi/180);

screendist = (tan(0.5*(pi/180)))*distcm; %screendist = distance on screen, in cm, subtended by 0.5 degrees of visual angle
screendist = screendist*2; %distance subtended by 1 degree of visual angle

%now we have pixels/cm and cm/degree of visual angle ... multiply them to
%get pixels/degree of visual angle

pixperdegree = pixpercm*screendist;
