classdef HexapodAxisBridge < mic.interface.device.GetSetNumber

    % This class implements mic.interface.device.GetSetNumber, which is the
    % interface that mic.ui.device.GetSetNumber expects its provided
    % "device" to implement.  It
    
    properties (Access = private)
        
        % {VendorDevice 1x1}
        hexapodBridge
        R = eye(6);

        dAxisNumber
    end
    
    methods
        
        function this = HexapodAxisBridge(HexapodBridge, axisNumber)
            this.hexapodBridge = HexapodBridge;
            this.dAxisNumber = axisNumber;
        end
        
        function d = get(this)
            dPosAr = this.R*(this.hexapodBridge.getPositions_mm');
            d = dPosAr(axisNumber);
            
        end
        
        function set(this, dVal)
            dPosAr = this.hexapodBridge.getPositions_mm';
            dPosAr(axisNumber) = dVal;
            
            this.hexapodBridge.setPositions_mm(...
                        this.R\dPosAr ...
                        );
        end
        
        function l = isReady(this)
            l = this.hexapodBridge.isReady();
        end
        
        function stop(this)
             this.hexapodBridge.stop();
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = this.hexapodBridge.isInitialized();
        end
        
        

        
    end
        
    
end

