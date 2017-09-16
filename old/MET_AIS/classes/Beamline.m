classdef Beamline < HandlePlus
    
    % How to deal with connecting to hardware?  I think the best option
    % will be to have a single 
    
    properties (Constant)
        
        dWidth          = 1000;
        dHeight         = 600;
    end
    
    
    properties (SetAccess = private)
        
        
    end
    
    
    properties (Access = protected)
        
        
        
    end
    
    
    properties (Access = private)
        
        
        wagoA
            % diodeM141
            % diodeDiagMF
            
        hFigure
        hPanelM141
        hPanelDiagMF
        
    end
    
    
    properties
        
        stageM141
        stageDiagMF
        
        
    end
    
    
    events
        
    end
    
    
    methods
        
        function this = Beamline(clock)
            
            
            this.stageM141 = MotionControl(...
                clock, ...
                'M141-Stage', ...
                {true, false, false, true, true, false}, ...
                false);
            
            this.stageDiagMF = MotionControl(...
                clock, ...
                'DiagMF', ...
                {true, false, false, false, false, false}, ...
                false);
            
            this.wagoA = WagoA(clock);
            
            
        end
        
        
        function build(this)
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Beamline Control',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            drawnow;
            
            % M141 Panel
            
            % Panel
            this.hPanelM141 = uipanel( ...
                'Parent', this.hFigure, ...
                'Units', 'pixels', ...
                'Title', 'M141', ...
                'Clipping', 'on', ...
                'Position', Utils.lt2lb([10 10 300 300], this.hFigure) ...
            );
            drawnow;
            
            
            
            
        end
        
        
    end
    
    
    methods (Access = protected)
        
        
    end
    
    
    methods (Access = private)
        
        
    end
    
end
            
            