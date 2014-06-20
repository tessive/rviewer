%% How to use RVIEWER 
% Created by Tessive LLC
% Contact:  Tony Davis
%           tony@tessive.com
%           www.tessive.com
%
% RVIEWER is a class that allows simple image display with resizing that
% will interpolate correctly for the display.  It accepts images just like
% the IMAGE function in MATLAB, and will create an axes if one is not
% specified.  See help RVIEWER for more detail on options.
%
% For ease of use, a utility RVIEW is also provided.  RVIEW creates a
% figure with as many RVIEWER objects as images provided to the
% constructor.  
%
% The examples in the following cell-mode script show different uses of
% RVIEW and RVIEWER
%
% Copyright 2014 Tessive LLC

%%  Use RVIEW to view a simple image
%   Left click to zoom in and recenter
%   Right click to recenter
%   Shift-Left click to zoom out and recenter
%   Double Click to fit image to window
%
%   The 1:1 button will set the image to map to display pixels.
%   The interpolation button will toggle image interpolation on/off

inimage = imread('tessivestearman.png');
rview(inimage);

%% Use RVIEW to view two synchronized images

inimage = imread('tessivestearman.png');
grayimage = rgb2gray(inimage);
rview(inimage, grayimage);
colormap(gray(256));

%% Use RVIEWER to view a single image
% NOTE: to zoom, do not use the 'magnify' buttons on a normal figure window.
% 

inimage = imread('tessivestearman.png');
rviewer(inimage);

%% Use RVIEWER to view two images
% Axis parameters can be set while creating an rviewer, or after
% When not synchronized, the viewers will operate independantly.
f = figure;
inimage = imread('tessivestearman.png');
grayimage = rgb2gray(inimage);
rviewer(inimage, 'Parent', f, 'Position', [0, 0.5, 1, 0.5]);
rviewer(grayimage, 'Parent', f, 'Position', [0, 0, 1, 0.5]);
colormap(jet(256));

%% Use RVIEWER to view two images synchronized together
% Use the SYNC method to synchronize two rviewer instances
% Note that you have to use SYNC twice to make the linkage bidirectional if
% desired.  Synchronization can be one-way
f = figure;
inimage = imread('tessivestearman.png');
grayimage = rgb2gray(inimage);
r1 = rviewer(inimage, 'Parent', f, 'Position', [0, 0.5, 1, 0.5]);
r2 = rviewer(grayimage, 'Parent', f, 'Position', [0, 0, 1, 0.5]);
sync(r1, r2);
sync(r2, r1);
colormap(jet(256));

%% Set magnification of a RVIEWER to 1:1, also turn off interpolation
% The methods 'interpolation' and 'actualpixels' can be used for this

inimage = imread('tessivestearman.png');
r = rviewer(inimage);
interpolation(r, false);
actualpixels(r);

%% Actualpixels can be called anytime to reset the image
actualpixels(r);

%% Interpolation by itself will toggle the interpolation settings
interpolation(r);

%% Special use with other graphs
%  If other objects are on the screen, it may be useful to set the
%  'restack' property of the rviewer object to 'true' (it defaults to
%  'false').  Unfortunately, MATLAB's redraw will flicker in this case, but
%  this will ensure the Z-level of the rviewer is in the proper place.
%
%  In this example, try changing the r.restack line to false.  When the
%  figure is resized, it will always come in front of the logo even though
%  it was put at the bottom of the z-ordering when created.  r.restack is
%  set to true, then the image will always end up behind the logo as it was
%  drawn.
inimage = imread('tessivestearman.png');
logo;

r = rviewer(inimage, 'Parent', gcf);
r.restack = true;
uistack(r.maxes, 'bottom');

%% Using rviewersc 
% RVIEWERSC is a derived class from RVIEWER.  It can display images with
% the intensity value scaled, similar to imagesc.   

% Create a badly scaled image
inimage = imread('tessivestearman.png');
rescaled = im2double(rgb2gray(inimage));
rescaled = rescaled .*0.04 - 5; 
h = rviewersc(rescaled);   % This will scale to a 64 value colormap

%% Change colormaps
colormap(gray(256));       % Change to a 256 value colormap


%% Using rviewsc
% RVIEWSC is a derived class from RVIEW.  It can display images with the
% intensity value scaled, similar to imagesc.  It is the full application
% that can be used to comapre images.  Truecolor images displayed with
% rviewsc are not affected by the scaling.
%  

% Create a badly scaled image
inimage = imread('tessivestearman.png');
rescaled = im2double(rgb2gray(inimage));
rescaled = rescaled .*0.04 - 5; 

h = rviewsc(inimage, rescaled);   
%  NOTE, truecolor images are not rescaled and will display normally.
colormap(jet(256));       % Change to a 256 value colormap.



