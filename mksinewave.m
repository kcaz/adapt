function [output] = mksinewave(amplitude,sf,ori,phase,pixperdegree,sizeimage)

% usage: [output] = mksinewave(amplitude,sf,ori,phase,pixperdegree,sizeimage)
% date: 11/28/06
% by: Christopher Henry
% purpose: takes amplitude, sf, ori, phase, pixelsperdegree, and sizeimage and 
% returns a sinewave grating (contrast image, ranging from -1 to 1, mean 0)
%
% ori and phase are in degrees
% sizeimage is [#rows #columns], that is, it is an mXn image, m pixels
% high, n pixels wide
% sf is in cycles/degree
% pixperdegree is the number of pixels per degree of visual angle

%make a grid with 0,0 at the center
%if size is [501 501], center is at 251,251
%if size is [500 500], center is at 251,251
if (mod(sizeimage(1),2)==0) %if # rows is even
    rowrange = -((sizeimage(1))/2):((sizeimage(1))/2)-1;
else
    rowrange = -((sizeimage(1) - 1)/2):((sizeimage(1) - 1)/2);
end;

if (mod(sizeimage(2),2)==0) %if # columns is even
    colrange = -((sizeimage(2))/2):((sizeimage(2))/2)-1;
else
    colrange = -((sizeimage(2) - 1)/2):((sizeimage(2) - 1)/2);
end;

[x,y] = meshgrid(colrange,rowrange);
%[x,y] = meshgrid(-(sizeimage/2):(sizeimage/2 - 1),-(sizeimage/2):(sizeimage/2 - 1));

%convert x and y from pixel indices so that now the stored values are
%indices for the distance in degrees
x = x./pixperdegree;
y = y./pixperdegree;

%convert ori and phase to radians
ori = (ori*pi)/180;
phase = (phase*pi)/180;

%f1 is frequency in x, f2 is freq in y
%sf = sqrt(f1^2 + f2^2), ori = atan(f2/f1)

f1 = sqrt((sf.^2)/(1+((tan(ori)).^2)));
f2 = f1*(tan(ori));

output = amplitude*sin(2*pi*(f1*x + f2*y) + phase);
