classdef GoniAxisBridge < mic.interface.device.GetSetNumber

    % This class acts as a bridge between the UI getsetnumber element and
    % a goni axis.  
    
    
    % This class implements mic.interface.device.GetSetNumber, which is the
    % interface that mic.ui.device.GetSetNumber expects its provided
    % "device" to implement.  
    
    properties (Constant)
        INTRINSIC_R = eye(2);
    end
    
    
    properties (Access = private)
        
        % {VendorDevice 1x1}
        goniStageAPI
        dAxisNumber
        R = eye(2);
    end
    
    methods
        
        function this = GoniAxisBridge(goniStageAPI, axisNumber)
            this.goniStageAPI = goniStageAPI;
            this.dAxisNumber = axisNumber;
        end
        
        function setR(this, R)
            this.R = R;
        end
        
        function d = get(this)
            dPosAr = this.R*this.INTRINSIC_R*(this.goniStageAPI.getAxesPosition()); % Rotate from goni coordinates to GUI coordinates
            d = dPosAr(this.dAxisNumber);
            
        end
        
        function set(this, dVal)
            dPosAr = this.R*this.INTRINSIC_R*(this.goniStageAPI.getAxesPosition());% Rotate from goni coordinates to GUI coordinates
            dPosAr(this.dAxisNumber) = dVal; % Set value into GUI coordinates
            
            % Set 6-vector in goni coordinates
            this.goniStageAPI.setAxesPosition(...
                        this.INTRINSIC_R\(this.R\dPosAr) ...
                        );
        end
        
        function l = isReady(this)
            l = this.goniStageAPI.isReady();
        end
        
        function stop(this)
             this.goniStageAPI.stop();
        end
        
        % This will home the stage
        function initialize(this)
             this.goniStageAPI.home();
        end
        
        function l = isInitialized(this)
            l = this.goniStageAPI.isInitialized();
        end
        
        

        
    end
        
    
end

