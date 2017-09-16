classdef LSI_Control < handle
    
    properties
        cAppPath = fileparts(mfilename('fullpath'))
        cConfigPath
        clock
        vendorDevice
        
        % Stages
        uiDeviceArraySmarPod
        uiDeviceGoniX
        uiDeviceGoniY
        
        uiDeviceReticleX
        uiDeviceReticleY
        uiDeviceReticleZ
        
        
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
        
        hpStageControls
        hpCameraControls
        hpScanControls
        hpMainControls
        
       
        
        hsaAxes
        
        hFigure
    end
    
    properties (Constant)
        dWidth  = 1440;
        dHeight =  860;
        
        dMultiAxisSeparation = 35;
        
        cSmarPodAxisLabels = {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'};
    end
    
    properties (Access = private)
        cDirSave
    end
    
    methods
        
        function this = LSI_Control()
            
            
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
        
        function initConfig(this)
            this.cConfigPath = fullfile(this.cAppPath, '+config');
            for k = 1:6
                this.uicHexapodConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, sprintf('hex%d.json', k))...
                    );
                
            end
            for k = 1:2
                this.uicGoniConfigs{k} =  mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, sprintf('goni%d.json', k))...
                    );
            end
            for k = 1:3
                this.uicReticleConfigs{k} =  mic.config.GetSetNumber(...
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
            this.hsaAxes = mic.ui.common.ScalableAxes();
            
            % Init stage device UIs
            for k = 1:length(this.cSmarPodAxisLabels)
                this.uiDeviceArraySmarPod{k} = mic.ui.device.GetSetNumber( ...
                    'cName', this.cSmarPodAxisLabels{k}, ...
                    'clock', this.clock, ...
                    'cLabel', this.cSmarPodAxisLabels{k}, ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'config', this.uicHexapodConfigs{k} ...
                );
            end
            
            this.uiDeviceGoniX = mic.ui.device.GetSetNumber( ...
                'cName', 'Goni_Rx', ...
                'clock', this.clock, ...
                'cLabel', 'Rx', ...
                'lShowLabels', false, ...
                'lShowStores', false, ...
                'config', this.uicGoniConfigs{1}...
            );
            this.uiDeviceGoniY = mic.ui.device.GetSetNumber( ...
                'cName', 'Goni_Ry', ...
                'clock', this.clock, ...
                'cLabel', 'Ry', ...
                'lShowLabels', false, ...
                'lShowStores', false, ...
                'config', this.uicGoniConfigs{2}...
            );
            
            this.uiDeviceReticleX = mic.ui.device.GetSetNumber( ...
                    'cName', 'Reticle_x', ...
                    'clock', this.clock, ...
                    'cLabel', 'X', ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'config', this.uicReticleConfigs{1}...
                );
            this.uiDeviceReticleY = mic.ui.device.GetSetNumber( ...
                    'cName', 'Reticle_y', ...
                    'clock', this.clock, ...
                    'cLabel', 'Y', ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'config', this.uicReticleConfigs{2}...
                );
            this.uiDeviceReticleZ = mic.ui.device.GetSetNumber( ...
                    'cName', 'Reticle_z', ...
                    'clock', this.clock, ...
                    'cLabel', 'Z', ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'config', this.uicReticleConfigs{3}...
                );
            
            
            

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
            

            this.uiDeviceMode = mic.ui.device.GetText( ...
                'clock', this.clock, ...
                'cName', 'mode', ...
                'cLabel', 'mode', ...
                'lShowLabels', false ...
            );

            this.uiDeviceAwesome = mic.ui.device.GetSetLogical( ...
                'clock', this.clock, ...
                'cName', 'awesome', ...
                'cLabel', 'awesome', ...
                'lShowLabels', false ...
            );


            this.uiToggleAll = mic.ui.common.Toggle(...
                'cTextFalse', 'Turn On All', ...
                'cTextTrue', 'Turn Off All' ...
            );
        
            this.uiButtonUseDeviceData = mic.ui.common.Button(...
                'cText', 'Use Device Data' ...
            );
        
     
        
        end
        
        function setUiTooltips(this)
            this.uiButtonUseDeviceData.setTooltip('Click me to echo the value of each device to the command line')
            
        end
        
        function addUiListeners(this)
            
            addlistener(this.uiToggleAll, 'eChange', @this.onToggleAllChange);
            addlistener(this.uiButtonUseDeviceData, 'eChange', @this.onButtonUseDeviceDataChange);
        end
        
        
        function initDevices(this)
            
            this.vendorDevice = VendorDevice();
            
            % You can store a reference to these devices you want but there
            % is no need since you can access thrm through the
            % mic.ui.device.*

            getSetNumberX = app.device.VendorDevice2GetSetNumber(this.vendorDevice, 'x');
            getSetNumberY = app.device.VendorDevice2GetSetNumber(this.vendorDevice, 'y');
            getTextMode = app.device.VendorDevice2GetText(this.vendorDevice, 'mode');
            getSetLogicalAwesome = app.device.VendorDevice2GetSetLogical(this.vendorDevice, 'awesome');
% 
%             this.uiDeviceX.setDevice(getSetNumberX);
%             this.uiDeviceY.setDevice(getSetNumberY);
            this.uiDeviceMode.setDevice(getTextMode);
            this.uiDeviceAwesome.setDevice(getSetLogicalAwesome);
            
        end
        
        function build(this)
            
            % Main figure
            this.hFigure = figure(...
                    'name', 'Interferometer control',...
                    'Units', 'pixels',...
                    'Position', [100 100 this.dWidth this.dHeight],...
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
                'Position', [40 240 720 440] ...
            );
        
            % Scan control panel:
            this.hpScanControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Scan control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [40 20 720 200] ...
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
           
            % Main control panel:
            this.hpMainControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Main control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [40 700 720 120] ...
                );
                
            % Stage UI elements
            for k = 1:length(this.cSmarPodAxisLabels)
                this.uiDeviceArraySmarPod{k}.build(this.hpStageControls, ...
                    40, 40 + (k - 1) * this.dMultiAxisSeparation);
            end
            dGapSeparation = 40;
            this.uiDeviceGoniX.build(this.hpStageControls, 40, dGapSeparation + 6 * this.dMultiAxisSeparation);
            this.uiDeviceGoniY.build(this.hpStageControls, 40, dGapSeparation + 7 * this.dMultiAxisSeparation);
            
            this.uiDeviceReticleX.build(this.hpStageControls, 40, 2*dGapSeparation + 8 * this.dMultiAxisSeparation);
            this.uiDeviceReticleY.build(this.hpStageControls, 40, 2*dGapSeparation + 9 * this.dMultiAxisSeparation);
            this.uiDeviceReticleZ.build(this.hpStageControls, 40, 2*dGapSeparation + 10 * this.dMultiAxisSeparation);
            
            % Camera UI elements
            this.uiDeviceCameraTemperature.build(this.hpCameraControls, 20, 20);            
            this.uiDeviceCameraExposureTime.build(this.hpCameraControls, 20, 70);

            this.uiButtonFocus.build(this.hpCameraControls, 20, 150, 120, 40);
            this.uiButtonAcquire.build(this.hpCameraControls, 160, 150, 120, 40);
            this.uiButtonSaveImage.build(this.hpCameraControls, 300, 150, 120, 40);
      

%         
%         
%             this.uiDeviceMode.build(this.hFigure, 10, 130);
%             this.uiDeviceAwesome.build(this.hFigure, 10, 170);
%             this.uiToggleAll.build(this.hFigure, 10, 210, 120, 30);
%             this.uiButtonUseDeviceData.build(this.hFigure, 10, 250, 120, 30);
            
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
                        
            for k = 1:length(this.cSmarPodAxisLabels)
                delete(this.uiDeviceArraySmarPod{k});
            end
            
            delete(this.uiDeviceGoniX);
            delete(this.uiDeviceGoniX);
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

