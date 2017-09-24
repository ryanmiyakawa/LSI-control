classdef HexapodAxisBridge < mic.interface.device.GetSetNumber

    % This class acts as a bridge between the UI getsetnumber element and
    % a hexapod axis.  
    
    
    % This class implements mic.interface.device.GetSetNumber, which is the
    % interface that mic.ui.device.GetSetNumber expects its provided
    % "device" to implement.  
    
    properties (Constant)
        INTRINSIC_R   = [[-1 0 0 ; 0 0 1; 0 1 0], zeros(3); zeros(3), [-1 0 0 ; 0 0 1; 0 1 0]];    
    end
    
    properties (Access = private)
        
        % {VendorDevice 1x1}
        hexapodStageAPI
        R = eye(6);
        dAxisNumber
    end
    
    methods
        
        function this = HexapodAxisBridge(hexapodStageAPI, axisNumber)
            this.hexapodStageAPI = hexapodStageAPI;
            this.dAxisNumber = axisNumber;
        end
        
        function setR(this, R)
            this.R = R;
        end
        
        function d = get(this)
            dPosAr = this.R*this.INTRINSIC_R*(this.hexapodStageAPI.getAxesPosition()); % Rotate from hexapod coordinates to GUI coordinates
            d = dPosAr(this.dAxisNumber);
            
        end
        
        function set(this, dVal)
            dPosAr = this.R*this.INTRINSIC_R*(this.hexapodStageAPI.getAxesPosition());% Rotate from hexapod coordinates to GUI coordinates
            dPosAr(this.dAxisNumber) = dVal; % Set value into GUI coordinates
            
            % Set 6-vector in hexapod coordinates
            this.hexapodStageAPI.setAxesPosition(...
                        this.INTRINSIC_R\(this.R\dPosAr) ...
                        );
        end
        
        function l = isReady(this)
            l = this.hexapodStageAPI.isReady();
        end
        
        function stop(this)
             this.hexapodStageAPI.stop();
        end
        
        % This will home the stage
        function initialize(this)
             this.hexapodStageAPI.home();
        end
        
        function l = isInitialized(this)
            l = this.hexapodStageAPI.isInitialized();
        end
        
        

        
    end
        
    
end

