classdef HexapodBridge < mic.interface.device.GetSetNumber

    % This class implements mic.interface.device.GetSetNumber, which is the
    % interface that mic.ui.device.GetSetNumber expects its provided
    % "device" to implement.  It
    
    properties (Constant)
        INTRINSIC_R   = [[-1 0 0 ; 0 0 1; 0 1 0], zeros(3); zeros(3), [-1 0 0 ; 0 0 1; 0 1 0]];    
    end
    
    properties (Access = private)
        % {VendorDevice 1x1}
        hexapodBridge
        
        % Composed rotation transformation
        R = eye(6);
    end
    
    methods
        
        function this = HexapodBridge(HexapodBridge)
            this.hexapodBridge = HexapodBridge;
        end
        
        function setR(this, R)
            this.R = R;
        end
        
        function dPosAr = get(this)
            dPosAr = this.R*this.INTRINSIC_R*(this.hexapodBridge.getPositions_mm); % Rotate from hexapod coordinates to GUI coordinates
        end
        
        function set(this, dPosAr)
            % Set 6-vector in hexapod coordinates
            this.hexapodBridge.setPositions_mm(...
                        this.INTRINSIC_R\(this.R\dPosAr) ...
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

