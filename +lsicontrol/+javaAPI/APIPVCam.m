


classdef APIPVCam < mic.Base
  
    properties
        hDevice
        clock
        
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
        end
        
        function initDefaultClock(this)
             this.clock = mic.Clock('APIPVCam');
        end
       
        % Replace these with proper getter and setter functions:
        function setTemperature(this, dVal)
            this.hDevice.setTemperature(dVal);% ----- Replace with proper function
        end
        function dT = getTemperature(this)
            dT = this.hDevice.getTemperature();% ----- Replace with proper function
            
        end
        function setExposureTime(this, dVal)
            this.hDevice.setExposureTime(dVal);% ----- Replace with proper function
        end
        function dS = getExposureTime(this)
             dS = this.hDevice.getExposureTime();% ----- Replace with proper function
        end
        
        function disconnect(this)
             this.hDevice.disconnect();% ----- Replace with proper function
        end
        function lVal = isConnected(this)
            lVal = this.hDevice.isConnected();% ----- Replace with proper function
        end
        
        % -------------
        
        function requestAcquisition(this)
            fprintf('APICamera:Requesting acquisition\n');
            this.lIsImageReady = false;
            
            this.hDevice.acquire();  % ----- Replace with proper function
            
            this.dTStart = tic;
            
            dasAcquisition = mic.DeferredActionScheduler(...
                'clock', this.clock, ...
                'fhAction', @()this.acquisitionHandler(),...
                'fhTrigger', @()this.checkImageStatus(),... % ----- Replace with proper function
                'cName', 'DASCameraAcquisition2', ...
                'dDelay', 0.3, ...
                'dExpiration', 100, ...
                'lShowExpirationMessage', true);
            dasAcquisition.dispatch();
            
        end
        
        function lVal = checkImageStatus(this)
            lVal = this.hDevice.isImageReady();
            
            % Compute elapsed time
            this.fhWhileAcquiring(toc(this.dTStart));
            
        end
        
        function acquisitionHandler(this)
            fprintf('APICamera:Acquisition came back\n');
            this.dCurrentImage = this.hDevice.getImage(); % ----- Replace with proper function
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