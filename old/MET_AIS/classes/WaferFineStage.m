classdef WaferFineStage < MotionControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        hioZ
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = WaferFineStage(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'Wafer-Fine-Stage', ...
                uint8([0]), ...
                'Fine', ...
                {'Z'}); 
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioZ = this.cehio{1};
            this.hioZ.setup.uieStepRaw.setVal(10e-9);
            
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end