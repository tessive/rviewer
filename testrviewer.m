%% Test Rviewer

inimage = imread('tessivestearman.png');
rviewer(inimage);

%% Test Rviewer with an axes already created

h = axes
rviewer(inimage, h);

%% Test Rviewer when making custom axes things
rviewer(inimage, 'Position', [0.4, 0.5, 0.5, 0.5])


%% Test Rviewer when one rviewer replaces another
h=axes;
rviewer(inimage, h);
rviewer(inimage, h);

%% Test Rviewersc

temp = rgb2gray(inimage);
inimage = im2double(inimage);
temp = temp .*0.04 - 5;
%colormap(jet(256));
h = rviewersc(temp);



%%
colormap(jet(64));
%redrawimage(h);


%% Change the colormap
colormap(jet(6));

%% Test rviewsc
temp = rgb2gray(inimage);
inimage = im2double(inimage);
temp = temp .*0.04 - 5; 
h = rviewsc(inimage, temp);
colormap(jet(256));
%redraw(h);