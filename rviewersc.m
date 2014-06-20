classdef rviewersc < rviewer
    %RVIEWERSC Properly resizing image viewer which rescales input
    %  Image viewer with colormap scaling which can properly resize 
    %
    %  rviewersc is derived from rviewer, and has the same methods and
    %  properties.  The only differnece is that rviewersc will rescale the
    %  input image (similar to imagesc).
    %
    % obj = rviewersc(inimage)
    %   Will use the current axes (gca) or create an axes object to
    %   use for image viewing, and will create an rviewer instance
    %   and display the image.  If another instance of rviewer is
    %   already using the axes, the existing instance will be
    %   cleared and a new rviewer instance created.
    %
    % obj = rviewrsc(inimage, H)
    %   Will create a new rviewer instance using the axes handle H.
    %   If H already contains an rviewer instance, it will be
    %   cleared and a new rviewer instace created.
    % 
    % obj = rviewersc(inimage, paramater, value, ...)
    %   Will create an axes using the paramaters specified in the
    %   paramater/value pairs (same as calling AXES)
    %
    %   Left click to zoom in and recenter
    %   Right click to recenter
    %   Shift-Left click to zoom out and recenter
    %   Double Click to fit image to window
    %
    %  Copyright 2014 Tessive LLC
    %  Contact: Tony Davis, tony@tessive.com
    %  www.tessive.com
    %  
    %  See also: rviewer, rviewer.redrawimge
    
    properties
        
    end
    
    
    methods
        
        function this = rviewersc(inimage, varargin)
            % RVIEWERSC Constructor for the rviewersc class
            % Class constructor for rviewersc.  
            % obj = rviewer(inimage)
            %   Will load with an image.  An image is required when the class
            %   is instantiated.  
            % 
            % obj = rviewer(inimage)
            %   Will use the current axes (gca) or create an axes object to
            %   use for image viewing, and will create an rviewer instance
            %   and display the image.  If another instance of rviewer is
            %   already using the axes, the existing instance will be
            %   cleared and a new rviewer instance created.
            %
            % obj = rviewr(inimage, H)
            %   Will create a new rviewer instance using the axes handle H.
            %   If H already contains an rviewer instance, it will be
            %   cleared and a new rviewer instace created.
            % 
            % obj = rviewer(inimage, paramater, value, ...)
            %   Will create an axes using the paramaters specified in the
            %   paramater/value pairs (same as calling AXES)
            %
            % See also: rviewer, rviewer.loadimage, axes
            
            this = this@rviewer(inimage, varargin{:});
            this.doscaling = true;

        end
    end
    

    
end

