classdef LSI_Control < handle
    
    
    properties
        cAppPath = fileparts(mfilename('fullpath'))
        cJavaLibPath = 'C:\Users\cxrodev\Documents\MATLAB\metdev\LSI-control';
        cJavaLibName = 'Met5Instruments.jar';
        cDataPath
        cConfigPath
        clock = {}
        vendorDevice
        
        % Colors:
        dAcquireColor = [.97, 1, .9]
        dFocusColor = [.93, .9, 1]
        dDisableColor = [.9, .8, .8]
        dInactiveColor = [.9, .9, .9]
        
        % Comm handles:
         % {mic.ui.device.GetSetLogical 1x1}
        
        uiCommDeltaTauPowerPmac
        uiCommSmarActMcsGoni
        uiCommSmarActSmarPod
        uiCommPIMTECamera
        
        % Instruments handle
        hInstruments
        
        % Stages
        uiDeviceArrayHexapod
        uiDeviceArrayGoni
        uiDeviceArrayReticle
        
        % Bridges
        oHexapodBridges
        oGoniBridges
        oReticleBridges
        

        uibHomeHexapod
        uibHomeGoni
        
        % APIs:
        apiHexapod
        apiGoni
        apiReticle
        apiCamera
        
        % Scans:
        uitgScan
        ceTabList = {'1D-scan', '2D-scan', '3D-scan', 'LSI P/S image acquisition'}
        
        % Camera
        uiDeviceCameraTemperature
        uiDeviceCameraExposureTime
        
        uiButtonAcquire
        uiButtonFocus
        uiButtonSaveImage
        
        uipbExposureProgress
        
        uieImageName
        
        % Configuration
        uicHexapodConfigs
        uicGoniConfigs
        uicReticleConfigs
        uicTemperatureConfig
        uicExposureConfig

        uiDeviceMode
        uiDeviceAwesome
        uiToggleAll
        uiButtonUseDeviceData
        
        uiSLHexapod
        uiSLGoni
        uiSLReticle
        
        
        % Coupled motion parameters
        uieRx
        uieRy
        
        uibRotateCoordinates
        
        hpStageControls
        hpCameraControls
        hpPositionRecall
        hpMainControls
        
        uiFileWatcher
              
        % axes:
        uitgAxes
        hsaAxes
        aScanMonitors
        
        % Scan setups
        ss1D
        ss2D
        ss3D
        ssExp
        
        hFigure
    end
    
    properties (Constant)
        dWidth  = 1440;
        dHeight =  900;
        
        dMultiAxisSeparation = 30;
        
        cHexapodAxisLabels = {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'};
        cGoniLabels = {'Goni-Rx', 'Goni-Ry'};
        cReticleLabels = {'Ret-Coarse-X', 'Ret-Coarse-Y', 'Ret-Rx', 'Ret-Ry', 'Ret-Coarse-Z', 'Ret-Fine-X', 'Ret-Fine-Y'};
    end
    
    properties (Access = private)
        cDirSave
    end
    
    methods
        
        function this = LSI_Control(varargin)
            
            for k = 1:2:length(varargin)
                this.(varargin{k}) = varargin{k+1};
            end
            
            if isempty(this.clock)
                this.initClock();
            end
            
            
            this.initConfig();
            this.initUi();
            this.initComm();
%             this.initHexapodDevice();
%             this.initGoniDevice();
%             this.build();
            
            %this.loadStateFromDisk();
            
            this.initDataPath();
           
            
            
        end
        
        function initDataPath(this)
             % Make data 
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            this.cDataPath = fullfile(cDirThis, '..', '..', '..', 'Data');
            
            sFils = dir(fullfile(cDirThis, '..', '..', '..'));
            lDataFolderExist = false;
            for k = 1:length(sFils)
                if strcmp(sFils(k).name, 'Data')
                    lDataFolderExist = true;
                end
            end
            if ~lDataFolderExist
                mkdir(this.cDataPath);
            end
                
            
        end
        
        function initComm(this)
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };


            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'delta-tau-reticle', ...
                'cLabel', 'Delta Tau Reticle' ...
                );
            this.uiCommSmarActMcsGoni = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'goniometer', ...
                'cLabel', 'Goni' ...
                );
            this.uiCommSmarActSmarPod = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'smarpod', ...
                'cLabel', 'SmarPod' ...
                );
        
            this.uiCommPIMTECamera = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'pimteCamera', ...
                'cLabel', 'PI-MTE Camera' ...
                );
            
            
        end
        
        
        function initClock(this)
            this.clock = mic.Clock('app');
        end
        
        function letMeIn(this)
           1;
        end
        
        function initConfig(this)
            this.cConfigPath = fullfile(this.cAppPath, '+config');
            for k = 1:6
                this.uicHexapodConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, sprintf('hex%d.json', k))...
                    );
            end
            for k = 1:2
                this.uicGoniConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, sprintf('goni%d.json', k))...
                    );
            end
            for k = 1:7
                this.uicReticleConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, sprintf('reticle%d.json', k))...
                    );
            end
            
            this.uicTemperatureConfig = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, 'temp.json')...
                    );
            this.uicExposureConfig = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, 'exposure.json')...
                    );
            
        end
        
        function initUi(this)
            
            
            % Init scalable axes:
            this.hsaAxes = mic.ui.axes.ScalableAxes();
            
            % Init stage device UIs
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k} = mic.ui.device.GetSetNumber( ...
                    'cName', this.cHexapodAxisLabels{k}, ...
                    'clock', this.clock, ...
                    'cLabel', this.cHexapodAxisLabels{k}, ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'lValidateByConfigRange', true, ...
                    'config', this.uicHexapodConfigs{k} ...
                );
            end
            
           for k = 1:length(this.cGoniLabels)
                this.uiDeviceArrayGoni{k} = mic.ui.device.GetSetNumber( ...
                    'cName', this.cGoniLabels{k}, ...
                    'clock', this.clock, ...
                    'cLabel', this.cGoniLabels{k}, ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'lValidateByConfigRange', true, ...
                    'config', this.uicGoniConfigs{k} ...
                    );
           end
           
           for k = 1:length(this.cReticleLabels)
               this.uiDeviceArrayReticle{k} = mic.ui.device.GetSetNumber( ...
                   'cName', this.cReticleLabels{k}, ...
                   'clock', this.clock, ...
                   'cLabel', this.cReticleLabels{k}, ...
                   'lShowLabels', false, ...
                   'lShowStores', false, ...
                   'lValidateByConfigRange', true, ...
                   'config', this.uicReticleConfigs{k} ...
                   );
           end
            
            

            % Init UI for camera control:
            this.uiDeviceCameraTemperature = mic.ui.device.GetSetNumber( ...
                'cName', 'detector_temp', ...
                'clock', this.clock, ...
                'cLabel', 'Temperature', ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowLabels', false, ...
                'config', this.uicTemperatureConfig...
            );
            this.uiDeviceCameraExposureTime = mic.ui.device.GetSetNumber( ...
                'cName', 'exposure_time', ...
                'clock', this.clock, ...
                'cLabel', 'Exposure time', ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lShowLabels', false, ...
                'config', this.uicExposureConfig...
            );
        
        
            this.uiButtonAcquire = mic.ui.common.Button(...
                'cText', 'Acquire', ...
                'fhDirectCallback', @this.onAcquire ...
            );
            
            this.uiButtonFocus = mic.ui.common.Button(...
                'cText', 'Focus', ...
                'fhDirectCallback', @this.onFocus ...
            );
             
            
            this.uiButtonSaveImage = mic.ui.common.Button(...
                'cText', 'Save image', ...
                'fhDirectCallback', @this.onSaveImage ...
            );
        
            this.uieImageName = mic.ui.common.Edit(...
                'cLabel', 'Image name' ...
            );
        

            
            this.uibHomeHexapod = mic.ui.common.Button(...
                'cText', 'Home Hexapod' , 'fhDirectCallback', @(src,evt)this.homeHexapod ...
            );
            this.uibHomeGoni = mic.ui.common.Button(...
                'cText', 'Home Goni' , 'fhDirectCallback', @(src,evt)this.homeGoni ...
            );

            this.uiSLHexapod = mic.ui.common.PositionRecaller(...
                'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                'cName', 'Hexapod', ...
                'hGetCallback', @this.getHexapodRaw, ...
                'hSetCallback', @this.setHexapodRaw);
            
            this.uiSLGoni = mic.ui.common.PositionRecaller(...
                'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                'cName', 'Goni', ...
                'hGetCallback', @this.getGoniRaw, ...
                'hSetCallback', @this.setGoniRaw);
            this.uiSLReticle = mic.ui.common.PositionRecaller(...
                'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                'cName', 'Reticle', ...
                'hGetCallback', @this.getReticleRaw, ...
                'hSetCallback', @this.setReticleRaw);
        
            this.uipbExposureProgress = mic.ui.common.ProgressBar(...
                'dColorFill', [.4, .4, .8], ...
                'dColorBg', [1, 1, 1], ...
                'dHeight', 15, ...
                'dWidth', 455);
            
            
            % Scan tab group:
            this.uitgScan = mic.ui.common.Tabgroup('ceTabNames', this.ceTabList);
            
            % Scans:
            this.ss1D = mic.ui.common.ScanSetup( ...
                            'cLabel', 'Saved pos', ...
                            'dScanAxes', 1, ...
                            'cName', '1D-Scan', ...
                            'cConfigPath', fullfile(this.cAppPath, '+config')...
                        );
                    
            this.ss2D = mic.ui.common.ScanSetup( ...
                            'cLabel', 'Saved pos', ...
                            'dScanAxes', 2, ...
                            'cName', '2D-Scan', ...
                            'cConfigPath', fullfile(this.cAppPath, '+config')...
                        );
                    
            this.ss3D = mic.ui.common.ScanSetup( ...
                            'cLabel', 'Saved pos', ...
                            'dScanAxes', 3, ...
                            'cName', '3D-Scan', ...
                            'cConfigPath', fullfile(this.cAppPath, '+config')...
                        );
                    
            this.ssExp = mic.ui.common.ScanSetup( ...
                            'cLabel', 'Saved pos', ...
                            'dScanAxes', 3, ...
                            'cName', 'Exp-Scan', ...
                            'cConfigPath',fullfile(this.cAppPath, '+config')...
                        );
            
            
            % Axes tab group:
            this.uitgAxes = mic.ui.common.Tabgroup('ceTabNames', {'Camera', 'Scan monitor'});
        end
        

%% Initializing devices

        function setCameraDeviceAndEnable(this, device)
            this.apiCamera = lsicontrol.javaAPI.APIPVCam( ...
                'hDevice', device, ...
                'fhWhileAcquiring', @(elapsedTime)this.whileAcquiring(elapsedTime), ...
                'fhOnImageReady', @(data)this.onCameraImageReady(data) ...
                );
            
            % Link UI to devices, let's try to inline them:
            this.uiDeviceCameraTemperature.setDevice(...
                 lsicontrol.device.InlineGetSetDevice(...
                    'get', @()this.apiCamera.getTemperature(), ...
                    'set', @(dVal)this.apiCamera.setTemperature(dVal) ...
                 )...
            );
            this.uiDeviceCameraTemperature.turnOn();
            this.uiDeviceCameraTemperature.syncDestination()
            
            this.uiDeviceCameraExposureTime.setDevice(...
                 lsicontrol.device.InlineGetSetDevice(...
                    'get', @()this.apiCamera.getExposureTime(), ...
                    'set', @(dVal)this.apiCamera.setExposureTime(dVal) ...
                 )...
            );
            this.uiDeviceCameraExposureTime.turnOn();
            this.uiDeviceCameraExposureTime.syncDestination();
        
        end
        
        % Resets api, bridges, and disconnects hardware device.
        function disconnectCamera(this)
            this.uiDeviceCameraTemperature.turnOff();
            this.uiDeviceCameraTemperature.setDevice([]);
            
            this.uiDeviceCameraExposureTime.turnOff();
            this.uiDeviceCameraExposureTime.setDevice([]);
            
            % Disconnect the camera:
            this.apiCamera.disconnect();
            
            % Delete the Stage API
            this.apiCamera = [];
        end

        % Builds hexapod java api, connecting getSetNumber UI elements
        % to the appropriate API hooks.  Device is already connected
        function setHexapodDeviceAndEnable(this, device)
            
            % Instantiate javaStageAPIs for communicating with devices
            this.apiHexapod 	= lsicontrol.javaAPI.CXROJavaStageAPI(...
                                  'jStage', device);
           
            % Check if we need to index stage:
            if (~this.apiHexapod.isInitialized())
                if strcmp(questdlg('Hexapod is not referenced. Index now?'), 'Yes')
                    this.apiHexapod.home();
                     % Wait till hexapod has finished move:
                    dafHexapodHome = mic.DeferredActionScheduler(...
                        'clock', this.clock, ...
                        'fhAction', @()this.setHexapodDeviceAndEnable(device),...
                        'fhTrigger', @()this.apiHexapod.isInitialized(),...
                        'cName', 'DASHexapodIndexing', ...
                        'dDelay', 0.5, ...
                        'dExpiration', 10, ...
                        'lShowExpirationMessage', true);
                    dafHexapodHome.dispatch();
                
                end
                return % Return in either case, only proceed if initialized
            end
            
            % Use coupled-axis bridge to create single axis control
            dHexapodR = [[-1 0 0 ; 0 0 1; 0 1 0], zeros(3); zeros(3), [-1 0 0 ; 0 0 1; 0 1 0]];  
            for k = 1:6
                this.oHexapodBridges{k} = lsicontrol.device.CoupledAxisBridge(this.apiHexapod, k, 6);
                this.oHexapodBridges{k}.setR(dHexapodR);
                this.uiDeviceArrayHexapod{k}.setDevice(this.oHexapodBridges{k});
                this.uiDeviceArrayHexapod{k}.turnOn();
                this.uiDeviceArrayHexapod{k}.syncDestination();
            end
        end
        
        % Resets api, bridges, and disconnects hardware device.
        function disconnectHexapod(this)
            for k = 1:6
                this.oHexapodBridges{k} = [];
                this.uiDeviceArrayHexapod{k}.turnOff();
                this.uiDeviceArrayHexapod{k}.setDevice([]);
            end
            
            % Disconnect the stage:
            this.apiHexapod.disconnect();
            
            % Delete the Stage API
            this.apiHexapod = [];
        end
        
         % Builds goni java api, connecting getSetNumber UI elements
        % to the appropriate API hooks.  Device is already connected
        function setGoniDeviceAndEnable(this, device)
            
            % Instantiate javaStageAPIs for communicating with devices
            this.apiGoni        = lsicontrol.javaAPI.CXROJavaStageAPI(...
                                  'jStage', device);
            % Check if we need to index stage:
            if (~this.apiGoni.isInitialized())
                if strcmp(questdlg('Goniometer is not referenced. Index now?'), 'Yes')
                    this.apiGoni.home();
                else
                    return
                end
            end
            
            % Use coupled-axis bridge to create single axis control
            for k = 1:2
                this.oGoniBridges{k} = lsicontrol.device.CoupledAxisBridge(this.apiGoni, k, 2);
                this.uiDeviceArrayGoni{k}.setDevice(this.oGoniBridges{k});
                this.uiDeviceArrayGoni{k}.turnOn();
                this.uiDeviceArrayGoni{k}.syncDestination();
            end
        end
        
        % Resets api, bridges, and disconnects hardware device.
        function disconnectGoni(this)
            for k = 1:2
                this.oGoniBridges{k} = [];
                this.uiDeviceArrayGoni{k}.turnOff();
                this.uiDeviceArrayGoni{k}.setDevice([]);
            end
            
            % Disconnect the stage:
            this.apiGoni.disconnect();
            
            % Disconnect the API
            this.apiGoni = [];
        end
        
        % These don't work yet but we need to hook this in
        function setReticleAxisDevice(this, device, index)
            this.uiDeviceArrayReticle{index}.setDevice(device);
            this.uiDeviceArrayReticle{index}.turnOn();
            this.uiDeviceArrayReticle{index}.syncDestination();
        end
        
        
        function disconnectReticleAxisDevice(this, index)
            this.uiDeviceArrayReticle{index}.turnOff();
            this.uiDeviceArrayReticle{index}.setDevice([]);
        end
        
%% Functions for getting and setting stages directly for Position recaller and hooks for camera
        
        % Camera methods:
        
        % Callback for what to do when image is ready from camera
        function onCameraImageReady(this, data)
            this.hsaAxes.imagesc(data);
            this.uiButtonAcquire.setText('Acquire');
            this.uiButtonAcquire.setColor(this.dAcquireColor);
            this.uiButtonFocus.setText('Focus');
            this.uiButtonFocus.setColor(this.dFocusColor);
            
            this.uipbExposureProgress.set(1);
            this.uipbExposureProgress.setColor([.2, .8, .2]);
            
            % update image name:
            [path, nPNGs] = this.getDataSubdirectoryPath();
            
            cFileName = fullfile(path, sprintf('%0.3d.png', nPNGs + 1));
            [~, name, ext] = fileparts(cFileName);
            
            this.uieImageName.set([name, ext]);
            this.uiButtonSaveImage.setColor([.1, .9, .3]);
            
        end
        
        % Callback for what to do while acquisition is happening
        function whileAcquiring(this, dElapsedTime)
            dProgress = dElapsedTime/this.apiCamera.getExposureTime();
            if dProgress > 1
                dProgress = 1;
            end
            
            this.uipbExposureProgress.set(dProgress);
        end
        
        % Callback for the acquire button
        function onAcquire(this)
            if isempty(this.apiCamera)
                msgbox('No camera connected!');
                return
            end
            
            
            this.uiButtonAcquire.setText('Acquiring...')
            this.uiButtonAcquire.setColor(this.dDisableColor);
            this.uiButtonFocus.setText('...')
            this.uiButtonFocus.setColor(this.dInactiveColor);
            
            this.uipbExposureProgress.set(0);
            this.uipbExposureProgress.setColor([.4, .4, .8]);
            
            this.apiCamera.requestAcquisition();
        end
        
        % Callback for the focus button
        function onFocus(this)
            
        end
        
        % Callback for the save button
        function onSaveImage(this)
            % Check if image is ready:
            if ~this.apiCamera.lIsImageReady || isempty(this.apiCamera.dCurrentImage)
                msgbox('No image available');
                return
            end
            dImg = this.apiCamera.dCurrentImage;
            
            cFileName = this.uieImageName.get();
            
            path = this.getDataSubdirectoryPath();
           
            this.saveAndLogImage(path, cFileName, dImg);
            imwrite(dImg, fullfile(path, cFileName), 'png');
            
            this.uipbExposureProgress.set(0);
            this.uipbExposureProgress.setColor([.95, .95, .95]);
            this.uiButtonSaveImage.setColor(this.dInactiveColor);
            
        end
        
        % get data subdirectory
        function [path, nPNGs] = getDataSubdirectoryPath(this)
            % Today's date:
            cSubDirName = datestr(now, 29);
            
            sFils = dir(this.cDataPath);
            lDataFolderExist = false;
            for k = 1:length(sFils)
                if strcmp(sFils(k).name, cSubDirName)
                    lDataFolderExist = true;
                end
            end
            path = fullfile(this.cDataPath, cSubDirName);
            if ~lDataFolderExist
                mkdir(path);
            end
            
            nPNGs = length(dir(fullfile(path, '*.png')));
            
        end
        
        % When an image is saved, make sure to log it
        function saveAndLogImage(this, cSubDirPath, cFileName, dImg)
            
            % Make log structure:
            stLog = struct();
            
            % Add timestamp
            stLog.timeStamp = datestr(now, 31);
            
            stLog.fileName = cFileName;
            
            % Add Hexapod coordinates:
            if isempty(this.apiHexapod)
                stLog.hexapodX = 'off';
                stLog.hexapodY = 'off';
                stLog.hexapodZ = 'off';
                stLog.hexapodRx = 'off';
                stLog.hexapodRy = 'off';
                stLog.hexapodRz = 'off';
            else 
                dHexapodPositions = this.getHexapodRaw(this);
                stLog.hexapodX = sprintf('%0.6f', dHexapodPositions(1));
                stLog.hexapodY = sprintf('%0.6f', dHexapodPositions(2));
                stLog.hexapodZ = sprintf('%0.6f', dHexapodPositions(3));
                stLog.hexapodRx = sprintf('%0.6f', dHexapodPositions(4));
                stLog.hexapodRy = sprintf('%0.6f', dHexapodPositions(5));
                stLog.hexapodRz = sprintf('%0.6f', dHexapodPositions(6));
            end
            
            % Add Goni coordinates:
            if isempty(this.apiGoni)
                stLog.goniRx = 'off';
                stLog.goniRy = 'off';
            else 
                dGoniPositions = this.getGoniRaw(this);
                stLog.goniRx = sprintf('%0.6f', dGoniPositions(1));
                stLog.goniRy = sprintf('%0.6f', dGoniPositions(2));
            end
            
            % Add Reticle coordinates:
            
            % Add temperature and exposure times:
            if isempty(this.apiCamera)
                stLog.cameraTemp = 'off';
                stLog.cameraExposureTime = 'off'; 
            else
                stLog.cameraTemp = sprintf('%0.1f', this.apiCamera.getTemperature());
                stLog.cameraExposureTime = sprintf('%0.4f', this.apiCamera.getExposureTime()); 
            end
            
            
            % Create log file and headers if necessary
            nl = java.lang.System.getProperty('line.separator').char;

            ceFieldNames = fieldnames(stLog);
            
            sFils = dir(cSubDirPath);
            lDataFileExist = false;
            for k = 1:length(sFils)
                if strcmp(sFils(k).name, 'log.csv')
                    lDataFileExist = true;
                end
            end
            logPath = fullfile(cSubDirPath, 'log.csv');
            fid = fopen(logPath, 'a');
            cWriteStr = '';
            if ~lDataFileExist
                for k = 1:length(ceFieldNames)
                    cWriteStr = sprintf('%s%s,',cWriteStr, ceFieldNames{k});
                end
                cWriteStr(end) = [];
                cWriteStr = [cWriteStr nl];
            end
            
            % Write structure fields
            for k = 1:length(ceFieldNames)
                cWriteStr = sprintf('%s%s,',cWriteStr, stLog.(ceFieldNames{k}));
            end
            cWriteStr(end) = [];
            cWriteStr = [cWriteStr nl];
            fwrite(fid, cWriteStr);
            fclose(fid);

            % Save .mat file
            [~, fl, ext] = fileparts(cFileName);
            save(fullfile(cSubDirPath, [fl '.mat']), 'stLog', 'dImg');

        end
        
        %%

        % Need to implement these methods:
        function positions = getReticleRaw(this)
            for k = 1:length(this.uiDeviceArrayReticle)
                positions(k) = this.uiDeviceArrayReticle{k}.getDestRaw(); %#ok<AGROW>
            end
        end
        
        function setReticleRaw(this, positions)
            for k = 1:length(this.uiDeviceArrayReticle)
                this.uiDeviceArrayReticle{k}.setAxesPosition(); %#ok<AGROW>
            end
        end
        
        
        function syncHexapodDestinations(this)
         % Sync edit boxes
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k}.syncDestination();
            end
        end
        function syncGoniDestinations(this)
         % Sync edit boxes
            for k = 1:length(this.cGoniLabels)
                this.uiDeviceArrayGoni{k}.syncDestination();
            end
        end
        function syncReticleDestinations(this)
         % Sync edit boxes
            for k = 1:length(this.cReticleLabels)
                this.uiDeviceArrayReticle{k}.syncDestination();
            end
        end
        
        
        % Sets the raw positions to hexapod.  Used as a handler for
        % PositionRecaller
        function setHexapodRaw(this, positions) 
            
            if ~isempty(this.apiHexapod)
                % Set hexapod positions to saved values
                this.apiHexapod.setAxesPosition(positions);

                % Wait till hexapod has finished move:
                dafHexapodMoving = mic.DeferredActionScheduler(...
                    'clock', this.clock, ...
                    'fhAction', @()this.syncHexapodDestinations(),...
                    'fhTrigger', @()this.apiHexapod.isReady(),...
                    'cName', 'DASHexapodMoving', ...
                    'dDelay', 1, ...
                    'dExpiration', 10, ...
                    'lShowExpirationMessage', true);
                dafHexapodMoving.dispatch();
            else
                % If Hexapod is not connected, set GetSetNumber UIs:
                for k = 1:length(positions)
                    this.uiDeviceArrayHexapod{k}.setDestRaw(positions(k));
                    this.uiDeviceArrayHexapod{k}.moveToDest();
                end
            end
        end
        
        % Gets the raw positions from hexapod.  Used as a handler for 
        % PositionRecaller
        function positions = getHexapodRaw(this)
             if ~isempty(this.apiHexapod)
                positions = this.apiHexapod.getAxesPosition();
             else % get virtual positions from GetSetNumber UIs:
                 for k = 1:length(this.uiDeviceArrayHexapod)
                     positions(k) = this.uiDeviceArrayHexapod{k}.getDestRaw(); %#ok<AGROW>
                 end
             end
        end
        
        % Sets the raw positions to hexapod.  Used as a handler for
        % PositionRecaller
        function setGoniRaw(this, positions) 
            if ~isempty(this.apiGoni)
                % Set hexapod positions to saved values
                this.apiGoni.setAxesPosition(positions);

                % Wait till hexapod has finished move:
                dafGoniMoving = mic.DeferredActionScheduler(...
                    'clock', this.clock, ...
                    'fhAction', @()this.syncGoniDestinations(),...
                    'fhTrigger', @()this.apiGoni.isReady(),...
                    'cName', 'DASHexapodMoving', ...
                    'dDelay', 1, ...
                    'dExpiration', 10, ...
                    'lShowExpirationMessage', true);
                dafGoniMoving.dispatch();
            else
                % If Hexapod is not connected, set GetSetNumber UIs:
                for k = 1:length(positions)
                    this.uiDeviceArrayGoni{k}.setDestRaw(positions(k));
                    this.uiDeviceArrayGoni{k}.moveToDest();
                end
            end
        end
        
        function positions = getGoniRaw(this)
             if ~isempty(this.apiGoni)
                positions = this.apiGoni.getAxesPosition();
             else % get virtual positions from GetSetNumber UIs:
                 for k = 1:length(this.uiDeviceArrayGoni)
                     positions(k) = this.uiDeviceArrayGoni{k}.getDestRaw(); %#ok<AGROW>
                 end
             end
        end
            
%% Build main figure
        function build(this)
            
            % Main figure
            this.hFigure = figure(...
                    'name', 'Interferometer control',...
                    'Units', 'pixels',...
                    'Position', [10 10 this.dWidth this.dHeight],...
                    'handlevisibility','off',... %out of reach gcf
                    'numberTitle','off',...
                    'Toolbar','none',...
                    'Menubar','none', ...
                    'Color', [0.7 0.73 0.73]);
                
           % Axes:
           
           
           % Main Axes:
           this.uitgAxes.build(this.hFigure, 880, 10, 540, 590);
           this.hsaAxes.build(this.uitgAxes.getTabByName('Camera'), 10, 10, 520, 520);
                
            % Stage panel:
            this.hpStageControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Stage control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', [10 250 490 600] ...
            );
        
            % Scan control panel:
            this.hpPositionRecall = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Position recall and coordinate transform',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', [510 250 360 600] ...
                );
        
            % Camera control panel:
            this.hpCameraControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Camera control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', [880 610 540 240] ...
            );
        
            % Scan controls:
            this.uitgScan.build(this.hFigure, 10, 10, 860, 230);

             % Scans:
            this.ss1D.build(this.uitgScan.getTabByIndex(1), 10, 10, 850, 180); 
                    
            this.ss2D.build(this.uitgScan.getTabByIndex(2), 10, 10, 850, 180);
                    
            this.ss3D.build(this.uitgScan.getTabByIndex(3), 10, 10, 850, 180);
                    
            this.ssExp.build(this.uitgScan.getTabByIndex(4), 10, 10, 850, 180);
            
                
            % Position recall:
            this.uiSLHexapod.build(this.hpPositionRecall, 10, 390, 340, 188);
            this.uiSLGoni.build(this.hpPositionRecall, 10, 200, 340, 188);
            this.uiSLReticle.build(this.hpPositionRecall, 10, 10, 340, 188);
            
            
            
            % Stage UI elements
            
            dAxisPos = 30;
            dLeft = 20;
            
            
           
             % Build comms and axes
            this.uiCommSmarActSmarPod.build(this.hpStageControls, dLeft, dAxisPos - 7);
            this.uibHomeHexapod.build(this.hpStageControls, dLeft + 340, dAxisPos - 5, 95, 20);
            dAxisPos = dAxisPos + 20;
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k}.build(this.hpStageControls, ...
                    dLeft, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            dAxisPos = dAxisPos + 20;
            this.uiCommSmarActMcsGoni.build(this.hpStageControls,  dLeft, dAxisPos - 7);
            this.uibHomeGoni.build(this.hpStageControls, dLeft + 340, dAxisPos - 5, 95, 20);
            dAxisPos = dAxisPos + 20;
            for k = 1:length(this.cGoniLabels)
                this.uiDeviceArrayGoni{k}.build(this.hpStageControls, ...
                    dLeft, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            dAxisPos = dAxisPos + 20;
            this.uiCommDeltaTauPowerPmac.build(this.hpStageControls,  dLeft, dAxisPos - 7);
            dAxisPos = dAxisPos + 20;
            for k = 1:length(this.cReticleLabels)
                this.uiDeviceArrayReticle{k}.build(this.hpStageControls, ...
                    dLeft, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            

            
            
            
           % this.uibRotateCoordinates.build(this.hpStageControls, 600, 130, 100, 40);
            
            % Camera UI elements
            this.uiDeviceCameraTemperature.build(this.hpCameraControls, 10, 40);            
            this.uiDeviceCameraExposureTime.build(this.hpCameraControls, 10, 70);
            
            this.uiCommPIMTECamera.build    (this.hpCameraControls, 10,  15);
            
            this.uiButtonFocus.build        (this.hpCameraControls, 10,  110, 100, 30);
            this.uiButtonAcquire.build      (this.hpCameraControls, 130, 110, 100, 30);
            this.uiButtonSaveImage.build    (this.hpCameraControls, 330, 165, 100, 20);
            
            this.uieImageName.build         (this.hpCameraControls, 10, 150, 300, 25);
            
            
            this.uipbExposureProgress.build(this.hpCameraControls, 10, 200);
      
            % Position recall elements
            
            % Button colors:
            this.uiButtonAcquire.setText('Acquire')
            this.uiButtonAcquire.setColor(this.dAcquireColor);
            this.uiButtonFocus.setText('Focus')
            this.uiButtonFocus.setColor(this.dFocusColor);
            
            
        end
        
        function homeHexapod(this)
            if strcmp(questdlg('Would you like to home the Hexapod?'), 'Yes')
                this.apiHexapod.home();
            end
        end
        
        function homeGoni(this)
            if strcmp(questdlg('Would you like to home the Goniometer?'), 'Yes')
                this.apiGoni.home();
            end
        end
        
        

        
        
        function delete(this)
            this.saveStateToDisk();

            this.deleteUi();
        end
        
        function deleteUi(this)
            % Stop the clock:
            this.clock.stop();
                        
            for k = 1:length(this.cHexapodAxisLabels)
                delete(this.uiDeviceArrayHexapod{k});
            end
            
            delete(this.uiDeviceMode);
            delete(this.uiDeviceAwesome);
            delete(this.uiButtonUseDeviceData);
            delete(this.uiToggleAll);
            delete(this.clock);
            
        end
        
        function st = save(this)
           st = struct();
%            st.uiDeviceX = this.uiDeviceX.save();
%            st.uiDeviceY = this.uiDeviceY.save();
        end
        
        function load(this, st)
%            this.uiDeviceX.load(st.uiDeviceX);
%            this.uiDeviceY.load(st.uiDeviceY);
        end
        
    
    end
    
    
    methods (Access = protected)
        
        function fileWatchHandler(this, src, directory, filename)
            img = [];
            path = [directory, '/', filename];
            switch filename(end-2:end)
                case {'png', 'bmp', 'jpg'}
                    img = imread(path);
                    
                     
                     
                     
                case 'spe'
                    
            end
            
            if length(size(img)) == 3
                img = mean(img, 3);
            end
            this.hsaAxes.imagesc(img);
            
            
        end
        
        function onToggleAllChange(this, src, evt)
            
            if this.uiToggleAll.get()
                this.turnOnAllDeviceUi();
            else
                this.turnOffAllDeviceUi()
            end
            
        end
        
        
        function onButtonUseDeviceDataChange(this, src, evt)
            
            this.uiDeviceX.getValCalDisplay()
            this.uiDeviceY.getValCalDisplay()
            this.uiDeviceMode.get()
            this.uiDeviceAwesome.get()
            
        end
        
        function saveStateToDisk(this)
            st = this.save();
            save(this.file(), 'st');
            
        end
        
        function loadStateFromDisk(this)
            if exist(this.file(), 'file') == 2
                fprintf('loadStateFromDisk()\n');
                load(this.file()); % populates variable st in local workspace
                this.load(st);
            end
        end
        
        function c = file(this)
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['saved-state', '.mat']...
            );
        end
        
    end
    
end

