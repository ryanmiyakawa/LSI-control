classdef M143Control < HandlePlus
    
    % rcs
    
    properties (Constant)
      
        dWidth      = 450
        dHeight     = 130
        
    end
    
	properties
        
        m143s
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        cl
        hFigure
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = M143Control(cl)
            
            this.cl= cl;
            this.init();
            
        end
        
                
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'M143 Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            
            this.m143s.build(this.hFigure, dPad, dTop);            
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
                                    
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    

    end
    
    methods (Access = private)
        
        function init(this)
            
            this.m143s  = M143Stage(this.cl);
            
        end
        
        
        function handleCloseRequestFcn(this, src, evt)
            delete(this.hFigure);
        end
                

    end % private
    
    
end