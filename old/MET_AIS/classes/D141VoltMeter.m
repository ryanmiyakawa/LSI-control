classdef D141VoltMeter < VoltMeter
    % rcs
    
    properties (Constant)
               
    end
    
	properties
        
        di
        uitConnectPublic
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = D141VoltMeter(clock)
              
            % Call parent constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            
            this@VoltMeter( ...
                clock, ...
                'D141-Diode', ...
                uint8([0]), ...
                {'Diode'}, ...
                {'di'}, ...
                'D141-Diode' ...
            ); 
                        
            this.dWidth = 430;
            
            % Expose Diode member of parent in a nice way
            
            this.di = this.cex{1};
            this.uitConnectPublic = this.uitConnect;
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
        

    end 
    
    
end