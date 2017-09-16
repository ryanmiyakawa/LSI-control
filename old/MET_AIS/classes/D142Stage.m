classdef D142Stage < MotionControl
    
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
        
        
        function this = D142Stage(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'D142-Stage', ...
                uint8([0]), ...
                'Diag142 stage', ...
                {'Z'}, ...
                {'hios'}); 
                        
            this.dWidth = 430;
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioZ = this.cehio{1};
            
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