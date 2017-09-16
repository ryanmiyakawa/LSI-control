classdef VendorDevice2GetSetNumber < mic.interface.device.GetSetNumber

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
        
        function this = VendorDevice2GetSetNumber(device, cProp)
            this.device = device;
            this.cProp = cProp;
        end
        
        function d = get(this)
            switch this.cProp
                case 'x'
                    d = this.device.getXPosition();
                case 'y'
                    d = this.device.getYPosition();
            end
            
        end
        
        function set(this, dVal)
            switch this.cProp
                case 'x'
                    this.device.setXPosition(dVal);
                case 'y'
                    this.device.setYPosition(dVal);
            end
            
        end
        
        function l = isReady(this)
            l = true;
        end
        
        function stop(this)
            
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
        

        
    end
        
    
end

