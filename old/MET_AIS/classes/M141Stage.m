classdef M141Stage < MotionControl
    
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        hioX
        hioRx
        hioRy
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = M141Stage(clock)
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this@MotionControl( ...
                clock, ...
                'M141-Stage', ...
                uint8([0, 1, 2]), ...
                'Stage', ...
                {'X', 'Rx', 'Ry'}, ...
                {'hios', 'hios', 'hios'}); 
                        
            this.dWidth = 430;
            
            % Expose HardwareIO members of MotionControl in a nice way
            
            this.hioX = this.cehio{1};
            this.hioRx = this.cehio{2};
            this.hioRy = this.cehio{3};
            
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