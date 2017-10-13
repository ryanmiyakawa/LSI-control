


classdef APIPVCam < mic.Base
  
    properties
        hDevice
        clock
        
        dExposureTime = -1 % this is not stored on device so we have to handle it here
        
        fhOnImageReady % Function to call when image is finished
        fhWhileAcquiring = @(elapsedTime)[]% Function to call on trigger
        
        lIsImageReady
        
        
        dCurrentImage = []
        
        lIsFocusing = false
        
        dTStart = 0 % keeping track of exposure times
        
    end

    methods 
        
        function this = APIPVCam(varargin)
            for k = 1:2:length(varargin)
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        end
        
        function init(this)
            if isempty(this.clock)
                this.initDefaultClock();
            end
            
            % Init exposure time, which calls cameraSettings, which needs
            % to be set before an acquisition can happen:
            this.setExposureTime(0.1);
        end
        
        function initDefaultClock(this)
             this.clock = mic.Clock('APIPVCam');
        end
       
        % Replace these with proper getter and setter functions:
        function setTemperature(this, dVal)
            this.hDevice.setTmpSetpoint(dVal);
        end
        function dT = getTemperature(this)
            dT = this.hDevice.getTmp();
            
        end
        function setExposureTime(this, dVal)
            
            % Set exposure time via camera settings
            lVal = this.hDevice.cameraSettings(false, dVal, 0, 0, 2047, 2047, 1, 1);
            if ~lVal
                msgbox('CAMERA EXP TIME/ROI SET FAILED');
            end
            this.dExposureTime = dVal;
        end
        
        function dS = getExposureTime(this)
             dS = this.dExposureTime;
        end
        
        function lVal = connect(this)
            lVal = this.hDevice.initCamera(0);
            if ~lVal
                msgbox('CAMERA INIT FAILED');
            end
        end
        
        function disconnect(this)
             lVal = this.hDevice.uninitCamera();
             if ~lVal
                msgbox('CAMERA UNINIT FAILED');
            end
        end
        
        function lVal = isConnected(this)
            lVal = this.hDevice.isInitialized();
        end
        
        % -------------
        
        function requestAcquisition(this)
            
            if (this.dExposureTime <= 0)
                msgbox('Need positive exposure time setting');
                return
            end
            
            fprintf('APICamera:Requesting acquisition\n');
            this.lIsImageReady = false;
            
            if ~this.hDevice.startCapture()
                msgbox('CAMERA ACQUISITION FAILED TO START')
                return;
            end
            
            this.dTStart = tic;
            
            dasAcquisition = mic.DeferredActionScheduler(...
                'clock', this.clock, ...
                'fhAction', @()this.acquisitionHandler(),...
                'fhTrigger', @()this.checkImageStatus(),... 
                'cName', 'DASCameraAcquisition2', ...
                'dDelay', 0.3, ...
                'dExpiration', 100, ...
                'lShowExpirationMessage', true);
            dasAcquisition.dispatch();
            
        end
        
        
        % return true if acquisition is finished
        function lVal = checkImageStatus(this)
            oData = this.hDevice.getImage();
            
            if isempty(oData)
                lVal = false;
            else
                lVal = true;
                this.dCurrentImage = oData; % Set image here
            end
            
            
            % Compute elapsed time
            this.fhWhileAcquiring(toc(this.dTStart));
            
        end
        
        function acquisitionHandler(this)
            fprintf('APICamera:Acquisition came back\n');
            this.lIsImageReady = true;
            this.fhOnImageReady(this.dCurrentImage);
        end

        % Accessors
        function lVal = isImageReady(this)
            lVal = this.lIsImageReady;
        end
        function dImg = getImage(this)
            dImg = this.dCurrentImage;
        end
        
    end
    
    methods (Access = protected)
        
    end
    
        

end