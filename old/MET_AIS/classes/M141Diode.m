classdef M141Diode < VoltMeter
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        di
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = M141Diode(clock)
              
            % Call parent constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            
            this@VoltMeter( ...
                clock, ...
                'M141-Diode', ...
                uint8([0]), ...
                {'Diode'}, ...
                {'di'}, ...
                'Stage Diode' ...
            ); 
                        
            this.dWidth = 430;
            
            % Expose Diode member of parent in a nice way
            
            this.di = this.cex{1};
            
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
        

    end 
    
    
end