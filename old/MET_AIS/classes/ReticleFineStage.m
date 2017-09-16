classdef ReticleFineStage < MotionControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        hioX
        hioY
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = ReticleFineStage(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'Reticle-Fine-Stage', ...
                uint8([0, 1]), ...
                'Fine Stage', ...
                {'X', 'Y'}); 
                        
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioX = this.cehio{1};
            this.hioY = this.cehio{2};
                        
            this.hioX.setup.uieStepRaw.setVal(10e-9);
            this.hioY.setup.uieStepRaw.setVal(10e-9);
            
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end