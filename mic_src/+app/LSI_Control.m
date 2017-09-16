classdef ZTS_Control < handle
    
    
    properties
        cAppPath = fileparts(mfilename('fullpath'))
        cConfigPath
        clock
        vendorDevice
        
        % Stages
        uiDeviceArrayHexapod
        
        % Bridges
        oHexapodBridges
        
        uibConnectHexapod
        uibHomeHexapod
        
        % Stage API:
        spaceFabAPI
        
        % Camera
        uiDeviceCameraTemperature
        uiDeviceCameraExposureTime
        uiDeviceCameraExposureMode
        uiButtonAcquire
        uiButtonFocus
        uiButtonSaveImage
        
        uicHexapodConfigs
        uicGoniConfigs
        uicReticleConfigs
        uicTemperatureConfig
        uicExposureConfig

        uiDeviceMode
        uiDeviceAwesome
        uiToggleAll
        uiButtonUseDeviceData
        
        uiSaveLoadUI
        
        % Coupled motion parameters
        uieRx
        uieRy
        
        uibRotateCoordinates
        
        hpStageControls
        hpCameraControls
        hpPositionRecall
        hpMainControls
        
        uiFileWatcher
              
        hsaAxes
        hFigure
    end
    
    properties (Constant)
        dWidth  = 1440;
        dHeight =  860;
        
        dMultiAxisSeparation = 50;
        
        cHexapodAxisLabels = {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'};
    end
    
    properties (Access = private)
        cDirSave
    end
    
    methods
        
        function this = ZTS_Control()
            
            
            this.initClock();
            this.initConfig();
            this.initUi();
            
            this.addUiListeners();
            this.setUiTooltips();
            this.initDevices();
            this.build();
            
            %this.loadStateFromDisk();
            
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
                'cText', 'Acquire' ...
            );
            this.uiButtonFocus = mic.ui.common.Button(...
                'cText', 'Focus' ...
            );
            this.uiButtonSaveImage = mic.ui.common.Button(...
                'cText', 'Save image' ...
            );
        
            this.uibRotateCoordinates = mic.ui.common.Button(...
                'cText', 'Rotate coordinates', 'fhDirectCallback', @this.launchRotationUI ...
            );
            
            this.uibConnectHexapod = mic.ui.common.Button(...
                'cText', 'Home stage' , 'fhDirectCallback', @(src,evt)this.homeStage ...
            );
            this.uibHomeHexapod = mic.ui.common.Button(...
                'cText', 'Turn on stage' , 'fhDirectCallback', @(src,evt)this.enableAxes ...
            );
        
            this.uiFileWatcher = mic.ui.common.FileWatcher(...
                'hCallback', @(src, p, d)this.fileWatchHandler(src, p, d), ...
                'clock', this.clock);

            this.uiSaveLoadUI = mic.ui.common.SaveLoadList('cConfigPath', 'src/+app/+config', ...
                'hGetCallback', @this.getHexapodRaw, ...
                'hSetCallback', @this.setHexapodRaw);

        
        end
        
        function setUiTooltips(this)
%             this.uiButtonUseDeviceData.setTooltip('Click me to echo the value of each device to the command line')
            
        end
        
        function addUiListeners(this)
           
        end
        
        function setHexapodRaw(this, positions) 
            % Set hexapod positions to saved values
            this.spaceFabAPI.setPositions_mm(positions);
            
            % Wait till hexapod has finished move:
            for k = 1:20
                if (this.spaceFabAPI.isReady)
                    break;
                end
                pause(.5)
            end
            
            % Sync edit boxes
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k}.syncDestination();
            end
            
        end
        function positions = getHexapodRaw(this)
             positions = this.spaceFabAPI.getPositions_mm();
        end
        
        
        function launchRotationUI(this)
            rc = mic.ui.common.RotationCorrectionUI('callback', @(Rt, rx, ry)this.rotateCoordinateSystem(Rt, rx, ry));
        end
        
        function rotateCoordinateSystem(this, R, rx, ry)
           for k = 1:6
               this.oHexapodBridges{k}.setR(R);
           end
           disp('Rotating coordinate system for hexapod bridges:');
           disp(R);
        end
        
        
        
        function initDevices(this)
            
            % Link devices here
            
            % First get master SpaceFab API:
            this.spaceFabAPI = app.device.APISpaceFab();
            
            % Use Hexapod "bridge" to create single axis control
            for k = 1:6
                this.oHexapodBridges{k} = app.device.HexapodAxisBridge(this.spaceFabAPI, k);
                this.uiDeviceArrayHexapod{k}.setDevice(this.oHexapodBridges{k});
            end
                        
%             this.vendorDevice = VendorDevice();
            
            % You can store a reference to these devices you want but there
            % is no need since you can access thrm through the
            % mic.ui.device.*

%             getSetNumberX = app.device.VendorDevice2GetSetNumber(this.vendorDevice, 'x');
%             getSetNumberY = app.device.VendorDevice2GetSetNumber(this.vendorDevice, 'y');
%             getTextMode = app.device.VendorDevice2GetText(this.vendorDevice, 'mode');
%             getSetLogicalAwesome = app.device.VendorDevice2GetSetLogical(this.vendorDevice, 'awesome');
% 
%             this.uiDeviceX.setDevice(getSetNumberX);
%             this.uiDeviceY.setDevice(getSetNumberY);
%             this.uiDeviceMode.setDevice(getTextMode);
%             this.uiDeviceAwesome.setDevice(getSetLogicalAwesome);
            
        end
        
        function build(this)
            
            % Main figure
            this.hFigure = figure(...
                    'name', 'Interferometer control',...
                    'Units', 'pixels',...
                    'Position', [10 10 this.dWidth this.dHeight],...
                    'handlevisibility','off',... %out of reach gcf
                    'numberTitle','off',...
                    'Toolbar','none',...
                    'Menubar','none');
                
           % Main Axes:
            this.hsaAxes.build(this.hFigure, 800, 260, 580, 580)
                
            % Stage panel:
            this.hpStageControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Stage control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [40 340 720 440] ...
            );
        
            % Scan control panel:
            this.hpPositionRecall = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Position recall and coordinate transform',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [40 20 720 300] ...
                );
        
            % Camera control panel:
            this.hpCameraControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Camera control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [800 20 580 200] ...
            );
           
%             % Main control panel:
%             this.hpMainControls = uipanel(...
%                 'Parent', this.hFigure,...
%                 'Units', 'pixels',...
%                 'Title', 'Main control',...
%                 'FontWeight', 'Bold',...
%                 'Clipping', 'on',...
%                 'Position', [40 700 720 120] ...
%                 );
                
            % Position recall:
            this.uiSaveLoadUI.build(this.hpPositionRecall, 10, 10);
            
            % Stage UI elements
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k}.build(this.hpStageControls, ...
                    40, 40 + (k - 1) * this.dMultiAxisSeparation);
            end
            dGapSeparation = 40;
            
            this.uibHomeHexapod.build(this.hpStageControls, 600, 40, 100, 40);
            this.uibConnectHexapod.build(this.hpStageControls, 600, 90, 100, 40);
            this.uibRotateCoordinates.build(this.hpStageControls, 600, 130, 100, 40);
            
            % Camera UI elements
            this.uiDeviceCameraTemperature.build(this.hpCameraControls, 20, 20);            
            this.uiDeviceCameraExposureTime.build(this.hpCameraControls, 20, 70);
            
            this.uiFileWatcher.build(this.hpCameraControls, 20, 55);

            this.uiButtonFocus.build(this.hpCameraControls, 20, 150, 120, 40);
            this.uiButtonAcquire.build(this.hpCameraControls, 160, 150, 120, 40);
            this.uiButtonSaveImage.build(this.hpCameraControls, 300, 150, 120, 40);
      
            % Position recall elements
           % this.uiButtonAdd
%         
%         
%             this.uiDeviceMode.build(this.hFigure, 10, 130);
%             this.uiDeviceAwesome.build(this.hFigure, 10, 170);
%             this.uiToggleAll.build(this.hFigure, 10, 210, 120, 30);
%             this.uiButtonUseDeviceData.build(this.hFigure, 10, 250, 120, 30);
            
        end
        
        function homeStage(this)
            if strcmp(questdlg('Would you like to home the stage?'), 'Yes')
                this.spaceFabAPI.index();
            end
        end
        
        function enableAxes(this)
            if strcmp(questdlg('Turn on hexapod?'), 'Yes')
                for k = 1:6
                     this.uiDeviceArrayHexapod{k}.turnOn();
                     this.uiDeviceArrayHexapod{k}.syncDestination();
                end
            end
        end
        
        function turnOnAllDeviceUi(this)
%             this.uiDeviceX.turnOn();
%             this.uiDeviceY.turnOn();
%             this.uiDeviceMode.turnOn();
%             this.uiDeviceAwesome.turnOn();
        end
        
        function turnOffAllDeviceUi(this)
%             this.uiDeviceX.turnOff();
%             this.uiDeviceY.turnOff();
%             this.uiDeviceMode.turnOff();
%             this.uiDeviceAwesome.turnOff();
        end
        
        function delete(this)
            this.saveStateToDisk();

            this.deleteUi();
        end
        
        function deleteUi(this)
                        
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

