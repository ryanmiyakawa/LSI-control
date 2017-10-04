
% A virtual class mimicking the PVCAM device

classdef virtualPVCam < mic.Base
  
    properties
        hDevice
        clock
        
        lIsImageReady
        lIsConnected = false
        dCurrentImage = []
        
        dExposureTime = 1
        dTemperature = 20
        
        dPicIndex = 1;
    end

    methods 
        
        function this = virtualPVCam(varargin)
            this.init();
        end
        
        function init(this)
            this.clock = mic.Clock('Virtual_PVCAM');
            this.lIsConnected = true;
        end
        
        function disconnect(this)
            this.lIsConnected = false;
        end
        
        function lVal = isConnected(this)
            lVal = this.lIsConnected();
        end
       
        function setTemperature(this, dVal)
             this.dTemperature = dVal;
        end
        
        function dT = getTemperature(this)
            dT = this.dTemperature;
        end
        function setExposureTime(this, dVal)
            this.dExposureTime = dVal;
        end
        function dVal = getExposureTime(this)
            dVal = this.dExposureTime;
        end
        
        function acquire(this)
            this.lIsImageReady = false;
            
            dTStart = tic;
            
            dasAcquisition = mic.DeferredActionScheduler(...
                'clock', this.clock, ...
                'fhAction', @()this.acquisitionHandler(),...
                'fhTrigger', @()toc(dTStart) > this.dExposureTime,...
                'cName', 'virtualAcquisition', ...
                'dDelay', 0.3, ...
                'dExpiration', 100, ...
                'lShowExpirationMessage', true);
            dasAcquisition.dispatch();
            
        end
        
        function acquisitionHandler(this)
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            switch(this.dPicIndex)
                case 0
                    img = imread([cDir '/+dummyImages/manny.png']);
                case 1
                    img = imread([cDir '/+dummyImages/brown_bear.png']);
                case 2
                    img = imread([cDir '/+dummyImages/manny_tophat.png']);
                case 3
                    img = imread([cDir '/+dummyImages/lena512.png']);
            end
            this.dCurrentImage = sum(img,3);
            this.dPicIndex = mod(this.dPicIndex + 1, 4);
            this.lIsImageReady = true;
            
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