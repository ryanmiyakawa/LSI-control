classdef VendorDevice2GetText < mic.interface.device.GetText

    properties (Access = private)
        
        % {VendorDevice 1x1}
        device
        cProp
    end
    
    methods
        
        function this = VendorDevice2GetText(device, cProp)
            this.device = device;
            this.cProp = cProp;
        end
        
        function c = get(this)
            switch this.cProp
                case 'mode'
                    c = this.device.getMode();
            end
            
        end
        
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
        
        
    end
        
    
end

