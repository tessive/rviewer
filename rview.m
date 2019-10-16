classdef rview < handle
    %RVIEW Application for viewing a single image or comparing images
    %   RVIEW is intended as a demonstration of the RVIEWER class for
    %   interactive image resizing with interpolation.
    %  
    %   rview(img) will view a single image using the RVIEWER class.  
    %
    %   rview(img1, img2, ...) will display multiple images with
    %   synchronized image position control.  The images must have the 
    %   same dimensions (rows and columns), but truecolor and indexed
    %   images can be mixed.  
    %
    %   Left click to zoom in and recenter
    %   Right click to recenter
    %   Shift-Left click to zoom out and recenter
    %   Double Click to fit image to window
    %
    %   The 1:1 button will set the image to map to display pixels.
    %   The interpolation button will toggle image interpolation on/off
    %
    %   See also:  RVIEWER
    
    %  Copyright 2015 Tessive LLC
    %  Contact: Tony Davis, tony@tessive.com
    %  www.tessive.com
    
    properties
        rviewers    % cell array of rviewer objects
        ui          % Structure of user interface elements
    end
    
    methods
            function app = rview(varargin)
            % This is the "constructor" for the class
            % It runs when an object of this class is created

            for i=1:nargin
                assert(isequal(size(varargin{1}, 1), size(varargin{i}, 1)), 'RVIEW:NotEqualSizes', 'All incoming images must have the same dimensions');
                assert(isequal(size(varargin{1}, 2), size(varargin{i}, 2)), 'RVIEW:NotEqualSizes', 'All incoming images must have the same dimensions');
            end
            
            backgroundcolor = 0.15.*[1,1,1];
            
            app.ui.fig = figure;
            set(app.ui.fig, ...
                'NumberTitle','off',...
                'Name','Image Viewer', ...
                'Color', backgroundcolor, ...
                'Position', [200 200 1400 800]);

            set(app.ui.fig, 'ToolBar', 'none');
            set(app.ui.fig, 'MenuBar', 'none');
            drawnow;

            
            app.ui.toolbar = uitoolbar(app.ui.fig);
            
            rows = ceil(sqrt(nargin));
            cols = ceil(nargin / rows);
            
            icount = 1;
            for i = 1:rows
                for j = 1:cols
                    if icount <= nargin
                        app.rviewers{icount}=rviewer(varargin{icount}, 'Position', [(j-1)/cols, 1 - i/rows, 1/cols, 1/rows]);
                        icount = icount + 1;
                    end
                end
            end
 
            % Synchronize all the viewers both directions
            for i=1:numel(app.rviewers)
                for j=1:numel(app.rviewers)
                    sync(app.rviewers{i}, app.rviewers{j});
                end
            end
            
            
            % Set up pushtools
            currpath = fileparts(mfilename('fullpath'));
            try
                [icon, map] = imread(fullfile(currpath, '1to1icon.png'));
                
                icon = ind2rgb(icon, map);
                icon(icon(:,:,1) == icon(1,1,1)) = NaN;
                icon(icon(:,:,2) == icon(1,1,2)) = NaN;
                icon(icon(:,:,3) == icon(1,1,3)) = NaN;
            catch %if the file does not exist, replace with a red button
                icon = ones([16,16,3]);
                icon(:,:,2) = 0;
                icon(:,:,3) = 0;
            end
            
            
            app.ui.onetoone = uipushtool(app.ui.toolbar,'CData',icon,...
                'TooltipString','Set Images to 1:1',...
                'ClickedCallback',...
                @(~,~)actualpixels(app.rviewers{1}));
            
            
            try
                [icon, map] = imread(fullfile(currpath, 'antialias.png'));
                icon = ind2rgb(icon, map);
            catch %if the file does not exist, replace with a blue button
                icon = ones([16,16,3]);
                icon(:,:,1) = 0;
                icon(:,:,2) = 0;
            end
            app.ui.onetoone = uipushtool(app.ui.toolbar,'CData',icon,...
                'TooltipString','Toggle Antialiasing',...
                'ClickedCallback',...
                @(~,~)toggleinterpolation(app));
            end
           
            
            function toggleinterpolation(app)
                % Interpolation pushtool callback
                for i=1:numel(app.rviewers)
                    interpolation(app.rviewers{i});
                end

            end
            
            function redraw(app)
                % REDRAW Redraws the RVIEW app
                
                for i=1:numel(app.rviewers)
                    redrawimage(app.rviewers{i});
                end
            end
            
            
    end
    
end
