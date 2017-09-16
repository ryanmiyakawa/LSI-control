classdef Mod3CapSensor < CapSensor
    
    % m3cap
    
    properties (Constant)
            
    end
    
	properties
        
        hoCap1
        hoCap2
        hoCap3
        hoCap4

    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
    end
    
        
    events
        
    end
    
    
    methods
        
        
        function this = Mod3CapSensor(clock)
            
            
            
            this@CapSensor( ...
                clock, ...
                'RSA', ...
                uint8([0, 1, 2, 3]), ...
                {'Cap 1', 'Cap 2', 'Cap 3', 'Cap 4'}, ...
                {'ho', 'ho', 'ho', 'ho'}, ...
                'Mod3 Cap Sensors' ...
            ); 
                        
            % this.dWidth = 430;
            
            % Expose members of parent in a nice way
            
            this.hoCap1 = this.cex{1};
            this.hoCap2 = this.cex{2};
            this.hoCap3 = this.cex{3};
            this.hoCap4 = this.cex{4};
                        
        end
        
                

    end 
    
    
end