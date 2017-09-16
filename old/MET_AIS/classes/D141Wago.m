classdef D141Wago < Wago
    
    properties (Constant)
               
    end
    
	properties
        
        hiot
        uitConnectPublic
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                              
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = D141Wago(clock)
              
            % Call parent constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            
            this@Wago( ...
                clock, ...
                'D141-Actuator', ...
                uint8([0]), ...
                {'Actuator'}, ...
                {'hiot'}, ...
                'D141-Actuator' ...
            ); 
                        
            this.dWidth = 430;
            
            % Expose HIOT member of parent in a nice way
            
            this.hiot = this.cex{1};
            this.uitConnectPublic = this.uitConnect;
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
        

    end 
    
    
end