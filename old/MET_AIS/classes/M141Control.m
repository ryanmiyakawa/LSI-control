classdef M141Control < HandlePlus
    
    % rcs
    
    properties (Constant)
      
        dWidth      = 450
        dHeight     = 440
        
    end
    
	properties
        
        m141s
        m141vm
        d141
        
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
        
        
        function this = M141Control(cl)
            
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
                'Name', 'M141 Control', ...
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
            
            this.m141s.build(this.hFigure, dPad, dTop);            
            this.m141vm.build( ...
                this.hFigure, ...
                dPad, ...
                dTop + this.m141s.dHeight + dPad);
            this.d141.build( ...
                this.hFigure, ...
                dPad, ...
                dTop + this.m141s.dHeight + dPad + this.m141vm.dHeight + dPad);
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    

    end
    
    methods (Access = private)
        
        function init(this)
            
            this.m141s  = M141Stage(this.cl);
            this.m141vm = M141VoltMeter(this.cl);
            this.d141   = D141(this.cl);
            
        end
        
        
        function handleCloseRequestFcn(this, src, evt)
            this.msg('M141Control.closeRequestFcn()');
            delete(this.hFigure);
        end
        
        
        

    end % private
    
    
end