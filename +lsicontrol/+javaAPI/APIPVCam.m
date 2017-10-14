


classdef APIPVCam < mic.Base
  
    properties
        hDevice
        clock
        
        dExposureTime = -1 % this is not stored on device so we have to handle it here
        dTemperature = 25 % also log this since we don't have access to it during an exposure
        
        lIsAcquiring = false
        
        fhOnImageReady % Function to call when image is finished
        fhWhileAcquiring = @(elapsedTime)[]% Function to call on trigger
        
        lIsImageReady
        
        nPixelsX = 1340
        nPixelsY = 1300
        
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
            this.setExposureTime(1);
        end
        
        function initDefaultClock(this)
             this.clock = mic.Clock('APIPVCam');
        end
       
        % Replace these with proper getter and setter functions:
        function setTemperature(this, dVal)
            this.hDevice.setTmpSetpoint(dVal);
        end
        function dT = getTemperature(this)
            if this.lIsAcquiring
                % Read most recent value when we are acquiring since T is
                % locked;
                dT = this.dTemperature;
            else
                try
                    dT = this.hDevice.getTmp();
                    this.dTemperature = dT; % store most recent temperature
                catch
                    fprintf('Camera temperature read failed!');
                    dT = -1000;
                end
                
            end
            
            if dT < -70 && dT > -1000 % overheated
                dT = 9999;
            end
        end
        
        function lVal = setExposureTime(this, dVal)
            
            % Set exposure time via camera settings
            lVal = this.hDevice.cameraSettings(false, uint64(dVal*1000), 0, 1339, 0, 1299, 1, 1);
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
            % Verify that camera settings have been set on each acquire:
            this.setExposureTime(this.dExposureTime);
            
            this.lIsAcquiring = true;
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
            lVal = this.hDevice.checkStatus();
            
            % Compute elapsed time
            this.fhWhileAcquiring(toc(this.dTStart));
        end
        
        function acquisitionHandler(this)
            fprintf('APICamera:Acquisition came back\n');
            
            dImg = typecast((this.hDevice.getImage()), 'uint16');
            
            this.dCurrentImage = reshape(dImg, 1340, 1300);
            this.lIsImageReady = true;
            this.lIsAcquiring = false;
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