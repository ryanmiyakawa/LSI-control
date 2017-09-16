classdef VendorDevice2GetSetLogical < mic.interface.device.GetSetLogical

    % This class implements mic.interface.device.GetSetNumber, which is the
    % interface that mic.ui.device.GetSetNumber expects its provided
    % "device" to implement.  It
    
    
    
    properties (Access = private)
        
        % {VendorDevice 1x1}
        device
        
        % {char 1xm} property of VendorDevice being exposed
        cProp
        
        
    end
    
    methods
        
        % @param {VendorDevice 1x1}
        % @param {char 1xm} property of VendorDevice being exposed
        function this = VendorDevice2GetSetLogical(device, cProp)
            this.device = device;
            this.cProp = cProp;
        end
        
        function l = get(this)
            switch this.cProp
                case 'awesome'
                    l = this.device.getAwesomeState();
                
            end
            
        end
        
        function set(this, lVal)
            switch this.cProp
                case 'awesome'
                    if lVal
                        this.device.turnOnAwesome();
                    else
                        this.device.turnOffAwesome();
                    end
                
            end
            
        end
        
        function l = isReady(this)
            l = true;
        end
        
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
        

        
    end
        
    
end

