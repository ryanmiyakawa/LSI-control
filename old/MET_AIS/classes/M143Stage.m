classdef M143Stage < MotionControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        hioY
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = M143Stage(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'M143-Stage', ...
                uint8([0]), ...
                'Stage', ...
                {'Y'}, ...
                {'hios'}); 
                        
            this.dWidth = 430;
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioY = this.cehio{1};
           
            
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