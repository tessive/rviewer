classdef rviewer < handle
    %RVIEWER Properly resizing image viewer
    %  Image viewer which can properly resize
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
    %   Left click to zoom in and recenter
    %   Right click to recenter
    %   Shift-Left click to zoom out and recenter
    %   Double Click to fit image to window
    %
    %  Copyright 2014 Tessive LLC
    %  Contact: Tony Davis, tony@tessive.com
    %  www.tessive.com
    %  
    %  See also: rviewer.loadimage, rviewer.interpolation, rviewer.sync, 
    %      rviewer.actualpixels, rviewer.redrawimage, 
    %      rview, rviewersc, rviewsc
    
    properties
        
        hfig        % Handle to the figure associated with this viewer
        maxes       % Image axes handle
        himage      % Image handle
        
        doscaling = false  % Do image rescaling based on the current colormap
        
        ButtonDownFcn % A user-definable callback for any user click.
        imagedata   % the image data
        imageminval % the maximum value of the image data
        imagemaxval % the minimum value of the image data
        
        imagecenter % The center location for the image
        mag = 1        % The image magnification level (1 = fit to axes)
        interpolate = true % True if interpolation should be used, false otherwise
        zoomonclick = true % True if the rviewer should zoom in, out, or center to buttondown events
        totalscale  % The total image scaling at the image level 
        
        restack     % Optional value if Z-level restacking is desired. Defaults off.  When active, can cause the figure window to flicker on redraw.
    end
    
    properties (Access = private)
        
        resizecallbacks % Cell array of additional resize callback functions
        deletecallbacks % Cell array of additional delete callback functions
        
        resizetimer %Timer object to wait until all resizing is done before doing the redraw
        
        sviewers    %Cell array of synchronized viewers
        
    end
    
    methods
        
        function this = rviewer(inimage, varargin)
            % RVIEWER Constructor for the rviewer class
            % Class constructor for rviewer.  
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
            
            switch numel(varargin)
                case 0
                    this.maxes = gca;
                case 1
                    this.maxes = varargin{1};
                otherwise
                    this.maxes = axes(varargin{:});
            end

            
            % Find the parent figure of the axes.  Axes can have other
            % types as parents, so keep looking until a figure handle is
            % found.
            objhandle = this.maxes;
            % if the object is a figure or figure descendent, return the
            % figure. Otherwise return [].
            while ~isempty(objhandle) && ~strcmp('figure', get(objhandle,'type'))
              objhandle = get(objhandle,'parent');
            end
            this.hfig = objhandle;        
            
            % Delete any other RVIEWER instances using the same axes
            rviewer.RegisterDeleteCallback('CheckAxesInstances', this);
            
            axis(this.maxes, 'image');
            axis(this.maxes, 'off');
            this.imagedata = inimage;
            this.imagemaxval = double(max(inimage(:)));
            this.imageminval = double(min(inimage(:)));


            
            this.imagecenter(1) = size(inimage,1)./2;
            this.imagecenter(2) = size(inimage,2)./2;
            
            this.resizecallbacks = {};
            this.deletecallbacks = {};
            
            this.restack = false;
            
            redrawimage(this);
            drawnow;
            
            this.resizetimer = timer('StartDelay', 0.25, 'TimerFcn', @(~,~)redrawimage(this));
            rviewer.RegisterResizeCallback('Register', this);
            rviewer.RegisterDeleteCallback('Register', this);
            
        end
        
        
        
        function delete(this)
            %  DELETE Delete an rviewer instance
            %  Class destructor
            %
            %  See also: rviewer
            stop(this.resizetimer);
            set(this.himage, 'ButtonDownFcn', []);
            rviewer.RegisterResizeCallback('Unregister', this);
            rviewer.RegisterDeleteCallback('Unregister', this);
            delete(this.resizetimer);
            this.imagedata = [];
        end
        
        function this = interpolation(this, varargin)
            %  INTERPOLATION Sets the interpolation value
            %  interpolation(obj, true) will enable interpolation on the rviewer
            %      object
            %  interpolation(obj, false) will use nearest neighbor viewing
            %
            %  interpolation(obj) with no arguments will toggle the
            %  interpolation.
            %
            %  Calling this method will initiate a redraw of the image.
            %
            %  See also: rviewer
            narginchk(1,2);
            if nargin == 2
                this.interpolate = varargin{1};
            else
                this.interpolate = ~this.interpolate;
            end
            this = redrawimage(this);
        end
        
        function set.doscaling(this, value)
            %  DOSCALING Set image intensity scaling on or off
            %
            %  See also: rviewer
            this.doscaling = value;
            redrawimage(this);
        end
        
        
        function this = loadimage(this, inimage)
            %  LOADIMAGE Loads a new image array into an rviewer instance
            %  loadimage(obj, inimage)
            %  Replace the image displayed with a new one.
            %
            %  See also: rviewer
            this.imagedata = inimage;
            this.imageminval = double(min(inimage(:)));
            this.imagemaxval = double(max(inimage(:)));
            this.mag = 1;
            this.imagecenter(1) = size(inimage,1)./2;
            this.imagecenter(2) = size(inimage,2)./2;
            this = redrawimage(this);
            this = updatesync(this);
        end
        
        
        function this = sync(this, viewertoconnect)
            %  SYNC Synchronizes one rviewr object to another for display
            %  sync(rviewer, viewertoconnect)
            %  Register another rviewer to be synchronized when this copy has a
            %  magnification or position change.
            %
            %  See also: rviewer
            this.sviewers{end+1}=viewertoconnect;
        end
        
        function this = actualpixels(this)
            %  ACTUALPIXELS Set magnification to one to one screen pixels
            %  actualpixels(obj)
            %
            %  Will change the mag property such that the display is mapped
            %  to one-to-one with the display pixels
            %
            %  See also: rviewer
            
            
            [arows, acols] = getactualpixels(this);
            
            
            % Size of the input image
            irows = size(this.imagedata, 1);
            icols = size(this.imagedata, 2);
            
            this.mag = 1/min(arows/irows, acols/icols);
            
            this = redrawimage(this);
            
            % Update any synchronized viewers
            this = updatesync(this);
            
        end
        
        
        function this = redrawimage(this)
            %  REDRAWIMAGE Redraws the rviewer image
            %  This method is used to draw the image to the screen.
            %  It is called by the figure resize callback any time the figure
            %  is resized.  It can be called manually, especially when a
            %  colormap has changed.
            %
            %  See Also: rviewer
            
            currentstacklevel  = find(get(get(this.maxes, 'Parent'), 'Children') == this.maxes);

            [arows, acols] = getactualpixels(this);
            
            % Size of the input image
            irows = size(this.imagedata, 1);
            icols = size(this.imagedata, 2);
            
            this.totalscale = min(arows/irows, acols/icols)*this.mag;
            
            % Compute the number of rows and columns to use from the
            % original image, matching the aspect ratio of the output
            % window
            crows = min(arows/this.totalscale, irows);
            ccols = min(acols/this.totalscale, icols);
            
            
            rowinds = 1:crows;
            colinds = 1:ccols;
            rowoffset = this.imagecenter(1) - crows/2;
            coloffset = this.imagecenter(2) - ccols/2;
            
            
            rowoffset = max(0, rowoffset);
            coloffset = max(0, coloffset);
            rowoffset = min(size(this.imagedata,1)-rowinds(end), rowoffset);
            coloffset = min(size(this.imagedata,2)-colinds(end), coloffset);
            
            
            rowinds = round(rowinds + rowoffset);
            colinds = round(colinds + coloffset);
            tempimage = this.imagedata(rowinds, colinds,:);
            
            
            % Correct the image center location
            this.imagecenter(1)=rowinds(round(end/2));
            this.imagecenter(2)=colinds(round(end/2));
            
            if this.interpolate
                tempimage = imresize(tempimage, this.totalscale, 'Method', 'lanczos2', 'Antialiasing', true);
            else
                tempimage = imresize(tempimage, this.totalscale, 'Method', 'nearest', 'Antialiasing', true);
            end
            
            %For truecolor images, make sure it's limited between 0 and 1
            if isfloat(tempimage) && ~ismatrix(tempimage)  
                tempimage=max(tempimage, 0);
                tempimage=min(tempimage, 1);
            end
 
            if this.doscaling && ismatrix(tempimage)
                % Use imagesc if we are scaling
                this.himage = imagesc(tempimage, 'Parent', this.maxes, [this.imageminval, this.imagemaxval]);  
            else
                this.himage = image(tempimage, 'Parent', this.maxes);
            end
                
            
            if this.restack
                uistack(this.maxes, 'down', currentstacklevel);  % Move the axes back to the stack level it was at the start.
            end
            axis(this.maxes, 'image');
            axis(this.maxes, 'off');
            set(this.himage, 'ButtonDownFcn', @(src, event)ButtonClick(this, src, event));
            set(this.himage, 'Tag', 'DoNotIgnore');  %This can be queried, used if one wishes to use rotate3d with other objects
            
            
        end
        
    end
    
    methods (Access = protected)
        
        
        function this = resize(this)
            % resize
            % Called when the resize callback of the figure is called.  This
            % will reset a timer that will fire one second after the last
            % resize call, and the timer will call redrawimage
            stop(this.resizetimer);
            start(this.resizetimer);
        end
        

        function this = ButtonClick(this, handle, data)
            % ButtonClick
            % The handler for mouse events
            % Click to zoom in and recenter, shift-click to zoom out and recenter
            % Right click to recenter without zoom change
            % Double-click to reset image to full size
            
            if this.zoomonclick
               cp = get(this.maxes, 'CurrentPoint');
               arows = size(get(this.himage, 'CData'), 1);  % total pixel rows in the display axes
               acols = size(get(this.himage, 'CData'), 2);  % total pixel columns in the display axes
               crow = cp(1,2);  % Which pixel row was clicked in the axes
               ccol = cp(1,1);  % Which pixel column was clicked in the axes
               
               
               this.imagecenter(1) = this.imagecenter(1) + (crow - arows/2)/this.totalscale;
               this.imagecenter(2) = this.imagecenter(2) + (ccol - acols/2)/this.totalscale;
               
               switch get(get(this.maxes, 'Parent'), 'SelectionType')
                  case 'normal'
                     this.mag = this.mag * 1.5;
                  case 'extend'
                     this.mag = this.mag / 1.5;
                  case 'alt'
                     % just reposition, no magnification change
                  case 'open'
                     this.mag = 1;
                     this.imagecenter(1) = size(this.imagedata,1)./2;
                     this.imagecenter(2) = size(this.imagedata,2)./2;
                  otherwise
               end
               
               this.mag = max(this.mag, 1);
               this.mag = min(this.mag, 30);
               this = redrawimage(this);
               
               % Update any synchronized viewers
               this = updatesync(this);
            end
            
            % Call any registered callback
            if ~isempty(this.ButtonDownFcn)
                feval(this.ButtonDownFcn, handle, data); 
            end

        end;
        
        function this = updatesync(this)
            %  UPDATESYNC Update all synchronized rviewer instances
            for i=1:numel(this.sviewers)
                sviewer = this.sviewers{i};
                sviewer.mag = this.mag;
                sviewer.imagecenter = this.imagecenter;
                redrawimage(sviewer);
            end
            
        end
        
        function [arows, acols] = getactualpixels(this)
           % Returns the size of the axes in actual pixels.
            origaxesunits = get(this.maxes, 'Units');
            set(this.maxes, 'Units', 'pixels');
            s = get(this.maxes, 'Position');
            set(this.maxes, 'Units', origaxesunits);
            % size of the output window on the screen, in pixels
            arows = ceil(s(4));
            acols = ceil(s(3));
            
            % This is a quick sanity check: if the axes are larger than the
            % figure, use the figure size.
            origfigunits = get(this.maxes, 'Units');
            set(this.hfig, 'Units', 'pixels');
            s = get(this.hfig, 'Position');
            set(this.hfig, 'Units', origfigunits);
            arows = min(arows, ceil(s(4)));
            acols = min(acols, ceil(s(3)));
        end
        
    end
    
    methods (Static = true, Access = private)
        
        %  RegisterResizeCallback
        %  This static method is used to allow multiple instances of
        %  rviewer to all have their resize method called when a figure
        %  resizes.  Each needs to call this method to register their
        %  callback with the figure.
        %
        %  This method registers itself as the figure callback and in turn
        %  calls all the appropriate resize functions.
        %
        %  Uses:
        %  RegisterResizeCallback(hObject, eventdata)
        %  This is the normal callback mode, which is registered with the
        %  figure ResizeFcn.
        %
        %  RegisterResizeCallback('Register', rviewerinstance)
        %  Registers a specific instance of rviewer to be resized.
        %
        %  RegisterResizeCallback('Unregister', rviewerinstance)
        %  Removes a rviewer instance from the callback list.
        %
        function RegisterResizeCallback(varargin)
            persistent CBLIST;
            persistent ORIGCALLBACKLIST;
            % CBLIST is a cell array of registered rviewer instances
            % ORIGCALLBACKLIST is an array of structures for callbacks
            % the structures have elements of fighandlenumber and callback
            
            if isempty(ORIGCALLBACKLIST)
               ORIGCALLBACKLIST = struct('fighandlenumber', [], 'callback', function_handle.empty);
            end
            
            if ~ischar(varargin{1})  % This is the normal callback from the figure
               hObject = varargin{1};
               
               % Call the original callback if present (first)
               for i=1:numel(ORIGCALLBACKLIST)
                  if ORIGCALLBACKLIST(i).fighandlenumber == double(hObject)
                     if ~isempty(ORIGCALLBACKLIST(i).callback)
                        feval(ORIGCALLBACKLIST(i).callback, varargin{:});
                     end
                  end
               end
               
               
               i=1;
               while i <= numel(CBLIST)
                  rviewerinstance = CBLIST{i};
                  if (rviewerinstance.hfig == hObject) % If the figure number matches
                     resize(rviewerinstance);
                  end
                  i = i+1;
               end


                
            else
                action =varargin{1};
                rviewerinstance = varargin{2};
                switch action
                    case 'Register'
                        rviewer.RegisterResizeCallback('Unregister', rviewerinstance);  %First remove any other instances of this same object
                        % If there are no registered Rviewer instances,
                        % then we need to store the ResizeFcn for the
                        % figure.

                        CBLIST{end+1} = rviewerinstance;
                        
                        % If the current callback for the figure isn't
                        % empty, and it isn't a copy of this callback, then
                        % we need to store the original callback.
                        currentcallback = get(rviewerinstance.hfig, 'ResizeFcn');
                        if ~isempty(currentcallback)
                           if ~strcmpi(func2str(currentcallback), 'rviewer.RegisterResizeCallback')
                              
                              origstruct.fighandlenumber = double(rviewerinstance.hfig);
                              origstruct.callback = currentcallback;
                              ORIGCALLBACKLIST(end+1) = origstruct;
                           end
                        end
                        
                        set(rviewerinstance.hfig, 'ResizeFcn',  @rviewer.RegisterResizeCallback); %Register this static method with the figure.
                    case 'Unregister'
                        for i = numel(CBLIST): -1: 1
                            if (rviewerinstance == CBLIST{i})
                                CBLIST(i) = [];
                            end
                        end
                        
                        % If that removed all the Rviewer instances related to this figure, then
                        % replace the original callback.
                        remainingrviewers = 0;
                        for i=1:numel(CBLIST)
                           cbinstance = CBLIST{i};
                           if double(cbinstance.hfig) == double(rviewerinstance.hfig)
                              remainingrviewers = remainingrviewers+1;
                           end
                        end
                        
                        if remainingrviewers == 0  % We don't have any rviewers related to this figure anymore
                           % Find the original callback and replace it in
                           % the figure's resize callback, and remove it
                           % from the ORIGCALLBACKLIST array.
                           for i=numel(ORIGCALLBACKLIST):-1:1
                              if ORIGCALLBACKLIST(i).fighandlenumber == double(rviewerinstance.hfig)
                                 if ~isempty(ORIGCALLBACKLIST(i).callback)
                                    set(rviewerinstance.hfig, 'ResizeFcn', ORIGCALLBACKLIST(i).callback);
                                    ORIGCALLBACKLIST(i) = [];
                                 end
                              end
                           end
                        end
                        
                    otherwise
                        error('registerresizecallback:UnknownCall', 'Function ''%s'' is unknown.', action);
                        
                end
            end
            
        end
        
        
        function RegisterDeleteCallback(varargin)
            %  RegisterDeleteCallback
            %  This static method is used to allow multiple instances of
            %  rviewer to all have their delete method called when a figure
            %  is deleted.  Each needs to call this method to register their
            %  callback with the figure.
            %
            %  This method registers itself as the figure callback and in turn
            %  calls all the appropriate delete functions.
            %
            %  Uses:
            %  RegisterDeleteCallback(hObject, eventdata)
            %  This is the normal callback mode, which is registered with the
            %  figure DeleteFcn.
            %
            %  RegisterDeleteCallback('Register', rviewerinstance)
            %  Registers a specific instance of rviewer to be deleted.
            %
            %  RegisterDeleteCallback('Unregister', rviewerinstance)
            %  Removes a rviewer instance from the callback list.
            %
            %  RegisterDeleteCallback('CheckAxesInstances', rviewerinstance)
            %  Deletes any previous instance of rviewer associated with the
            %  same axes object as rviewerinstance.  Only one rviewer at a
            %  time can be viewed in an axes.
            %
            persistent CBLIST;
            persistent ORIGCALLBACKLIST;
            % CBLIST is a cell array of registered rviewer instances
            % ORIGCALLBACKLIST is an array of structures for callbacks
            % the structures have elements of fighandlenumber and callback
            
            if isempty(ORIGCALLBACKLIST)
               ORIGCALLBACKLIST = struct('fighandlenumber', [], 'callback', function_handle.empty);
            end
           
            % CBLIST is a cell array of registered rviewer instances
            if ~ischar(varargin{1})  % This is the normal callback from the figure
                hObject = varargin{1};
                origcallback = function_handle.empty;
                 % Get the original callback
                for i=1:numel(ORIGCALLBACKLIST)
                   if ORIGCALLBACKLIST(i).fighandlenumber == double(hObject)
                      origcallback = ORIGCALLBACKLIST(i).callback;

                   end
                end
                
                
                i=1;
                while i <= numel(CBLIST)
                    rviewerinstance = CBLIST{i};
                    if (rviewerinstance.hfig == hObject) % If the figure number matches
                        delete(rviewerinstance);
                        i = 1;  % Because the CBLIST is being cleared an element at a time, we have to restart the count.
                    else
                        i = i+1;
                    end
                end
                
                % Call the original callback if present (after all our
                % cleanup)
                if ~isempty(origcallback)
                   feval(origcallback, varargin{:});
                end
                
                
            else % We are registering or unregistering the callback
                action =varargin{1};
                rviewerinstance = varargin{2};
                switch action
                    case 'Register'
                        rviewer.RegisterDeleteCallback('Unregister', rviewerinstance);  %First remove any other instances of this same object                        
                        CBLIST{end+1} = rviewerinstance;  % Add this instance to the list
                        
                        % If the current callback for the figure isn't
                        % empty, and it isn't a copy of this callback, then
                        % we need to store the original callback.
                        currentcallback = get(rviewerinstance.hfig, 'DeleteFcn');
                        if ~isempty(currentcallback)
                           if ~strcmpi(func2str(currentcallback), 'rviewer.RegisterDeleteCallback')
                              origstruct.fighandlenumber = double(rviewerinstance.hfig);
                              origstruct.callback = currentcallback;
                              ORIGCALLBACKLIST(end+1) = origstruct;
                           end
                        end
                        
                        set(rviewerinstance.hfig, 'DeleteFcn',  @rviewer.RegisterDeleteCallback); %Register this static method with the figure.
                    case 'Unregister'
                        for i=numel(CBLIST): -1 : 1
                            if (rviewerinstance == CBLIST{i})
                                CBLIST(i) = [];
                            end
                        end
                        
                        % If that removed all the Rviewer instances related to this figure, then
                        % replace the original callback.

                        remainingrviewers = 0;
                        for i=1:numel(CBLIST)
                           cbinstance = CBLIST{i};
                           if double(cbinstance.hfig) == double(rviewerinstance.hfig)
                              remainingrviewers = remainingrviewers+1;
                           end
                        end
                        
                        if remainingrviewers == 0  % We don't have any rviewers related to this figure anymore
                           % Find the original callback and replace it in
                           % the figure's delete callback, and remove it
                           % from the ORIGCALLBACKLIST array.
                           for i=numel(ORIGCALLBACKLIST):-1:1
                              if ORIGCALLBACKLIST(i).fighandlenumber == double(rviewerinstance.hfig)
                                 if ~isempty(ORIGCALLBACKLIST(i).callback)
                                    set(rviewerinstance.hfig, 'DeleteFcn', ORIGCALLBACKLIST(i).callback);
                                    ORIGCALLBACKLIST(i) = [];
                                 end
                              end
                           end
                        end

                        
                        
                        
                    case 'CheckAxesInstances'
                        for i=numel(CBLIST): -1 :1 
                            if CBLIST{i}.maxes == rviewerinstance.maxes
                                delete(CBLIST{i});
                            end
                        end
                    otherwise
                        error('registerdeletecallback:UnknownCall', 'Function ''%s'' is unknown.', action);
                end
            end
            
        end
        
        
        
    end
end

