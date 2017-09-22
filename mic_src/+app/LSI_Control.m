classdef LSI_Control < handle
    
    
    properties
        cAppPath = fileparts(mfilename('fullpath'))
        cJavaLibPath = 'C:\Users\cxrodev\Documents\MATLAB\metdev\LSI-control';
        cJavaLibName = 'Met5Instruments.jar';
        cConfigPath
        clock
        vendorDevice
        
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
        
        uibConnectHexapod
        uibConnectGoni
        uibConnectReticle
        uibHomeHexapod
        uibHomeGoni
        uibHomeReticle
        
        % APIs:
        apiHexapod
        apiGoni
        apiReticle
        cameraAPI
        
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
              
        hsaAxes
        hFigure
    end
    
    properties (Constant)
        dWidth  = 1440;
        dHeight =  860;
        
        dMultiAxisSeparation = 30;
        
        cHexapodAxisLabels = {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'};
        cGoniLabels = {'Goni-Rx', 'Goni-Ry'};
        cReticleLabels = {'Ret-X', 'Ret-Y', 'Ret-Z'};
    end
    
    properties (Access = private)
        cDirSave
    end
    
    methods
        
        function this = LSI_Control(varargin)
            
            for k = 1:2:length(varargin)
                this.(varargin{k}) = varargin{k+1};
            end
            
            
            this.initClock();
            this.initInstruments();
            this.initConfig();
            this.initUi();
            
            this.initDevices();
            this.build();
            
            %this.loadStateFromDisk();
            
        end
        
        function initInstruments(this)
            
            %load java library
            javaclasspath(fullfile(this.cJavaLibPath, this.cJavaLibName));
            import cxro.met5.Instruments.*;
            import java.util.concurrent.Future;
            
            % instruments:
            this.hInstruments = cxro.met5.Instruments(this.cJavaLibPath);
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
            for k = 1:3
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
            
            this.uibHomeHexapod = mic.ui.common.Button(...
                'cText', 'Home Hexapod' , 'fhDirectCallback', @(src,evt)this.homeHexapod ...
            );
            this.uibHomeGoni = mic.ui.common.Button(...
                'cText', 'Home Goni' , 'fhDirectCallback', @(src,evt)this.homeGoni ...
            );
            this.uibHomeReticle = mic.ui.common.Button(...
                'cText', 'Home Reticle' , 'fhDirectCallback', @(src,evt)this.homeReticle ...
            );
        
        
            this.uibConnectHexapod = mic.ui.common.Button(...
                'cText', 'Connect Hexapod' , 'fhDirectCallback', @(src,evt)this.connectHexapod ...
            );
            this.uibConnectGoni = mic.ui.common.Button(...
                'cText', 'Connect Goni' , 'fhDirectCallback', @(src,evt)this.connectGoni ...
            );
            this.uibConnectReticle = mic.ui.common.Button(...
                'cText', 'Connect Reticle' , 'fhDirectCallback', @(src,evt)this.connectReticle ...
            );
        
            this.uiFileWatcher = mic.ui.common.FileWatcher(...
                'hCallback', @(src, p, d)this.fileWatchHandler(src, p, d), ...
                'clock', this.clock);

            this.uiSLHexapod = mic.ui.common.PositionRecaller(...
                'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                'cName', 'HexapodRecall', ...
                'hGetCallback', @this.getHexapodRaw, ...
                'hSetCallback', @this.setHexapodRaw);

        
        end
        
        
        % Sets the raw positions to hexapod.  Used as a handler for
        % PositionRecaller
        function setHexapodRaw(this, positions) 
            
            if this.apiHexapod.isConnected()
                % Set hexapod positions to saved values
                this.apiHexapod.setAxesPosition(positions);

                % Wait till hexapod has finished move:
                for k = 1:20
                    if (this.apiHexapod.isReady())
                        break;
                    end
                    pause(.5)
                end

                % Sync edit boxes
                for k = 1:length(this.cHexapodAxisLabels)
                    this.uiDeviceArrayHexapod{k}.syncDestination();
                end
            
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
             if this.apiHexapod.isConnected()
                positions = this.apiHexapod.getAxesPosition();
             else % get virtual positions from GetSetNumber UIs:
                 for k = 1:length( this.uiDeviceArrayHexapod)
                     positions(k) = this.uiDeviceArrayHexapod{k}.getDestRaw(); %#ok<AGROW>
                 end
             end
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
            
            % Build device APIs
%             this.apiHexapod 	= app.device.APISmarPod(this.hInstruments);
%             this.apiGoni        = app.device.APIGoni(this.hInstruments);
%             this.apiReticle     = app.device.APIReticle(this.hInstruments);

            % Instantiate javaStageAPIs for communicating with devices
            this.apiHexapod 	= app.javaAPI.CXROJavaStageAPI(...
                                  'fhStageGetter',  @() this.hInstruments.getLsiHexapod());
            this.apiGoni        = app.javaAPI.CXROJavaStageAPI(...
                                  'fhStageGetter',  @() this.hInstruments.getLsiGoniometer());
           
            this.apiReticle     = app.javaAPI.CXROJavaStageAPI(...
                                  'fhStageGetter',  @() []); % need to plug this in to chris's code
            
            % Use coupled-axis bridge to create single axis control
            dHexapodR = [[-1 0 0 ; 0 0 1; 0 1 0], zeros(3); zeros(3), [-1 0 0 ; 0 0 1; 0 1 0]];  
            for k = 1:6
                this.oHexapodBridges{k} = app.device.CoupledAxisBridge(this.apiHexapod, k, 6);
                this.oHexapodBridges{k}.setR(dHexapodR);
                this.uiDeviceArrayHexapod{k}.setDevice(this.oHexapodBridges{k});
            end
            
             % Use coupled-axis bridge to create single axis control
            for k = 1:2
                this.oGoniBridges{k} = app.device.CoupledAxisBridge(this.apiGoni, k, 2);
                this.uiDeviceArrayGoni{k}.setDevice(this.oGoniBridges{k});
            end
            
            % Use coupled-axis bridge to create single axis control
            for k = 1:3
                this.oReticleBridges{k} = app.device.CoupledAxisBridge(this.apiReticle, k, 3);
                this.uiDeviceArrayReticle{k}.setDevice(this.oReticleBridges{k});
            end
                        

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
                'Position', [20 400 720 440] ...
            );
        
            % Scan control panel:
            this.hpPositionRecall = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Position recall and coordinate transform',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [20 20 720 360] ...
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
            this.uiSLHexapod.build(this.hpPositionRecall, 10, 10, 350, 270);
            
            
            
            % Stage UI elements
            dAxisPos = 40;
            dH1 = dAxisPos;
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k}.build(this.hpStageControls, ...
                    40, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            dAxisPos = dAxisPos + 20;
            dH2 = dAxisPos;
            for k = 1:length(this.cGoniLabels)
                this.uiDeviceArrayGoni{k}.build(this.hpStageControls, ...
                    40, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            dAxisPos = dAxisPos + 20;
             dH3 = dAxisPos;
             for k = 1:length(this.cReticleLabels)
                this.uiDeviceArrayReticle{k}.build(this.hpStageControls, ...
                    40, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            
           
            
            this.uibConnectHexapod.build(this.hpStageControls, 510, dH1, 95, 40);
            this.uibHomeHexapod.build(this.hpStageControls, 615, dH1, 95, 40);
            
            this.uibConnectGoni.build(this.hpStageControls, 510, dH2, 95, 40);
            this.uibHomeGoni.build(this.hpStageControls, 615, dH2, 95, 40);
            
           
            this.uibConnectReticle.build(this.hpStageControls, 510, dH3, 95, 40);
            this.uibHomeReticle.build(this.hpStageControls, 615, dH3, 95, 40);
            
            
           % this.uibRotateCoordinates.build(this.hpStageControls, 600, 130, 100, 40);
            
            % Camera UI elements
            this.uiDeviceCameraTemperature.build(this.hpCameraControls, 20, 20);            
            this.uiDeviceCameraExposureTime.build(this.hpCameraControls, 20, 70);
            
%             this.uiFileWatcher.build(this.hpCameraControls, 20, 55);

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
        
         function homeReticle(this)
            if strcmp(questdlg('Would you like to home the Reticle?'), 'Yes')
                this.apiReticle.home();
            end
        end
        
        % Connnect hexapod and enable axes
        function connectHexapod(this)
            if strcmp(questdlg('Connect hexapod?'), 'Yes')
                for k = 1:6
                     this.uiDeviceArrayHexapod{k}.turnOn();
                     this.uiDeviceArrayHexapod{k}.syncDestination();
                end
            end
        end
        
        % Connnect Goni and enable axes
         function connectGoni(this)
            if strcmp(questdlg('Turn on Goniometer?'), 'Yes')
                this.apiGoni.connect();
                for k = 1:2
                     this.uiDeviceArrayGoni{k}.turnOn();
                     this.uiDeviceArrayGoni{k}.syncDestination();
                end
            end
         end
        
          % Connnect Goni and enable axes
         function connectReticle(this)
            if strcmp(questdlg('Enable Reticle control?'), 'Yes')
                this.apiReticle.connect();
                for k = 1:3
                     this.uiDeviceArrayReticle{k}.turnOn();
                     this.uiDeviceArrayReticle{k}.syncDestination();
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

