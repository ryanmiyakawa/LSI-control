classdef WaferCoarseStage < MotionControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        hioX
        hioY
        hioZ
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
        
        
        function this = WaferCoarseStage(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'Wafer-Coarse-Stage', ...
                uint8([0, 1, 2, 3, 4]), ...
                'Coarse', ...
                {'X', 'Y', 'Z', 'Rx', 'Ry'}); 
                        
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioX = this.cehio{1};
            this.hioY = this.cehio{2};
            this.hioZ = this.cehio{3};
            this.hioRx = this.cehio{4};
            this.hioRy = this.cehio{5};
                        
            this.hioX.setup.uieStepRaw.setVal(100e-6);
            this.hioY.setup.uieStepRaw.setVal(100e-6);
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
        

    end 
    
    
end