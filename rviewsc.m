classdef rviewsc < rview
    %RVIEWSC Application for scaling and viewing a monochrome image or comparing images
    %   RVIEWSC is derived from RVIEW, and has the same functionality, but
    %   will scale the intensity of the images (similar to imagesc).
    %
    %   See also:  RVIEW
    %
    %  Copyright 2014 Tessive LLC
    %  Contact: Tony Davis, tony@tessive.com
    %  www.tessive.com
    
    properties
    end
    
    methods
            function app = rviewsc(varargin)
            % RVIEWSC Constructor
            app = app@rview(varargin{:});
            for i=1:numel(app.rviewers)
                app.rviewers{i}.doscaling = true;
                
            end


            end           
            
            
    end
    
end
