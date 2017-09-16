classdef MAStage < MotionControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        hioX
        hioY
        hioRx
        hioRy
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (SetAccess = protected)

    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = MAStage(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'MA-Stage', ...
                uint8([0, 1, 2, 3]), ...
                {'X', 'Y', 'Rx', 'Ry'}, ...
                {'hios', 'hios', 'hios', 'hios'});
            
            this.dWidth = 430;
                        
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioX = this.cehio{1};
            this.hioY = this.cehio{2};
            this.hioRx = this.cehio{3};
            this.hioRy = this.cehio{4};
             
            %{
            this.hioX.setup.uieStepRaw.setVal(100e-6);
            this.hioY.setup.uieStepRaw.setVal(100e-6);
            %}
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
        

    end 
    
    
end