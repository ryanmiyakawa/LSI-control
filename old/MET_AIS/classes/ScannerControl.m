classdef ScannerControl < HandlePlus
%PUPILFILL Class that allows to monitor and the control of the Pupil fill
%
%   See also ScannerCore, RETICLEPICK, HEIGHTSENSOR
    
    properties (Constant)
        
        dPupilScale     = 1.1;
        dPupilPixels    = 220;
        
        dWidth          = 1230
        dHeight         = 720

    end
    
    properties
        
        dFreqMin        % minimum frequency
        dFreqMax        % maximum frequency
        
        np      % nPoint class instance (controller)
        
        dVx
        dVy
        dVxCorrected
        dVyCorrected
        dTime
        i32X
        i32Y
        
        dRVxCommand
        dRVyCommand
        dRVxSensor
        dRVySensor
        dRTime
        
        uipType
        uipPlotType
        
        uieMultiPoleNum
        uieMultiSigMin
        uieMultiSigMax
        uieMultiCirclesPerPole
        uieMultiDwell
        uieMultiOffset
        uieMultiRot
        uieMultiXOffset
        uieMultiYOffset
        uieMultiFills
        uieMultiTransitTime
        uieTimeStep
        uipMultiTimeType
        uieMultiHz
        uieMultiPeriod
        uitMultiFreqRange

        uieSawSigX
        uieSawPhaseX
        uieSawOffsetX
        uieSawSigY
        uieSawPhaseY
        uieSawOffsetY
        uipSawTimeType
        uieSawHz
        uieSawPeriod
        
        uieSerpSigX
        uieSerpSigY
        uieSerpNumX
        uieSerpNumY
        uieSerpOffsetX
        uieSerpOffsetY
        uieSerpPeriod
        
        uieDCx
        uieDCy
        
        uieRastorData
        uieRastorTransitTime
        uilSaved
        
        uieFilterHz
        uieVoltsScale
        uieConvKernelSig
        
        uibPreview
        uibSave
        uibRecord
        uieRecordTime
        
        uibSetWaveform
    end
    
    properties (Access = private)
        
        cSaveDir
        cDir            % class directory
        
        cDevice         % Name of nPoint device 'm142' (field), 'm143' (pupil)
        
        dYOffset = 360;
       
        cl      % clock
        
        lConnected = false;
        hFigure
        hWaveformPanel
        hWaveformMultiPanel
        hWaveformDCPanel
        hWaveformRastorPanel
        hWaveformSawPanel
        hWaveformSerpPanel
        hWaveformGeneralPanel
        hSavedWaveformsPanel
        
        hPlotPanel              % main plot panel
        hPlotPreviewPanel       % panel with the plots for the preview data
        hPlotMonitorPanel       % panel with all of the plots for the record data
        hPlotRecordPanel        % panel with the uie time and record button
        
        hPreviewAxis2D
        hPreviewAxis2DSim
        hPreviewAxis1D
        
        hMonitorAxis2D
        hMonitorAxis2DSim
        hMonitorAxis1D
        
        hCameraPanel
        hDevicePanel
    end
    
    events
        
        eNew
        eDelete
        
    end
    
    
    methods
        
        function this = ScannerControl(cl, cDevice)
        %PUPILFILL Class constructor
        %   pf = PupilFill('name', clock)
        %
        % See also INIT, BUILD, DELETE
           
            this.cl = cl;
            this.cDevice = cDevice;
            
            this.cSaveDir = sprintf('save/scanner-%s', this.cDevice);
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            
            this.init();
        end
                
        
        function build(this)
        % BUILD Builds the UI element controls in a separate window
        %   PupilFill.Build()
        %
        % See also PUPILFILL, INIT, DELETE
            
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
        
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name',  sprintf('Scanner Control (%s)', this.cDevice), ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on', ...
                'CloseRequestFcn', @this.cb ...
                );
            
            drawnow;
            
            this.buildWaveformPanel();
            this.buildSavedWaveformsPanel();
            this.buildPlotPanel();
            % this.buildCameraPanel();
            % this.buildDevicePanel();
            this.np.build(this.hFigure, 750 + 160, this.dYOffset);
            this.uilSaved.refresh();
        end
        
        function delete(this)
           
            this.msg('delete');
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
        end

    end
    
    methods (Access = private)
        
        function init(this)
        %INIT Initializes the PupilFill class
        %   PupilFill.init()
        %
        % See also PUPILFILL, BUILD, DELETE
            
            % 2012.04.16 C. Cork instructed me to use double for all raw
            % values
            
            this.uipType =                  UIPopup({'Multipole', 'DC', 'Rastor', 'Saw', 'Serpentine'}, 'Select Waveform Type', true);
            addlistener(this.uipType, 'eChange', @this.handleType);
            
            this.uieMultiPoleNum =          UIEdit('Poles', 'u8');
            this.uieMultiSigMin =           UIEdit('Sig min', 'd');
            this.uieMultiSigMax =           UIEdit('Sig max', 'd');
            this.uieMultiCirclesPerPole =   UIEdit('Circles/pole', 'u8');
            this.uieMultiDwell =            UIEdit('Dwell', 'u8');
            this.uieMultiOffset =           UIEdit('Pole Offset', 'd');
            this.uieMultiRot =              UIEdit('Rot', 'd');
            this.uieMultiXOffset =          UIEdit('X Global Offset', 'd');
            this.uieMultiYOffset =          UIEdit('Y Global Offset', 'd');

            this.uieMultiTransitTime =      UIEdit('Transit Frac', 'd');
            
            this.uipMultiTimeType =         UIPopup({'Period (ms)', 'Hz (avg)'}, 'Select Time Type', true);
            addlistener(this.uipMultiTimeType, 'eChange', @this.handleMultiTimeType);            
            
            this.uieMultiPeriod =           UIEdit('Period (ms)', 'd');
            this.uieMultiHz =               UIEdit('Hz (avg)', 'd');
            this.uitMultiFreqRange =        UIText('');
            
            this.uieDCx =                   UIEdit('X offset', 'd');
            this.uieDCy =                   UIEdit('Y offset', 'd');
            
            this.uieRastorData =            UIEdit('(sig_x,sig_y,ms),(sig_x,sig_y,ms),...', 'c');
            this.uieRastorTransitTime =     UIEdit('Transit Time (s)', 'd');
            
            % *********** General waveform panel
            
            this.uieFilterHz =              UIEdit('Filter Hz', 'd');
            this.uieFilterHz.setVal(400);
            this.uieFilterHz.dMin =         1;
            this.uieFilterHz.dMax =         10000;
            
            this.uieVoltsScale =            UIEdit('Volts scale', 'd');
            this.uieVoltsScale.setVal(10);
            this.uieVoltsScale.dMin =       0;
            this.uieVoltsScale.dMax =       10;
            
            this.uieTimeStep =              UIEdit('Time step (us)', 'd');
            this.uieTimeStep.setVal(24);    % nPoint has a 24 us control loop
            
            
            this.uieConvKernelSig               = UIEdit('Conv. kernel sig', 'd');
            this.uieConvKernelSig.setVal(0.05);
            this.uieConvKernelSig.dMin          = 0.01;
            this.uieConvKernelSig.dMax             = 1;
            
            this.uibPreview =               UIButton('Preview');
            this.uibSave =                  UIButton('Save');
            
            this.uilSaved =                 UIList( cell(1,0), '', true, true, false, true);
            this.uilSaved.setRefreshFcn(@this.refreshSaved);
            
            this.uipPlotType =              UIPopup({'Preview', 'nPoint Monitor'}, 'Select Plot Source', true);
            this.uibRecord =                UIButton('Record');
            this.uieRecordTime =            UIEdit('Time (ms)', 'd', false);
            
            this.uibSetWaveform =           UIButton('Set nPoint');
            
            
            % ************ nPoint
            
            % 2014.02.11 CNA
            % I decided that we will build two PupilFill instances, one for
            % the field scanner and one for the pupil scanner.  We will
            % need to pass in information about the nPoint we want to
            % connect to.  I'm assuming I will eventually build in a second
            % parameter to nPoint that can specify which hardware it is
            % connected to.  This, in turn will be passed to the 
            % APIHardwareIOnPoint instances within the nPoint 
            
            
            this.np = nPoint(this.cl, this.cDevice);
            addlistener(this.np, 'eConnect', @this.handleConnect);
            addlistener(this.np, 'eDisconnect', @this.handleDisconnect);
            
            % ************ Saw waveform panel 
            this.uieSawSigX =               UIEdit('Sig X', 'd'); 
            this.uieSawSigX.dMin =          0;
            this.uieSawSigX.dMax =          1;
            this.uieSawSigX.setVal(0.5);
            
            this.uieSawPhaseX =             UIEdit('Phase X (pi)', 'd');
            this.uieSawPhaseX.dMin =        -2;
            this.uieSawPhaseX.dMax =        2;
                        
            this.uieSawOffsetX =            UIEdit('Offset X', 'd');
            this.uieSawOffsetX.dMin =       -1;
            this.uieSawOffsetX.dMax =       1;
            
            this.uieSawSigY =               UIEdit('Sig Y', 'd'); 
            this.uieSawSigY.dMin =          0;
            this.uieSawSigY.dMax =          1;
            this.uieSawSigY.setVal(0.5);            
            
            this.uieSawPhaseY =             UIEdit('Phase Y (pi)', 'd');
            this.uieSawPhaseY.dMin =        -2;
            this.uieSawPhaseY.dMax =        2;
                        
            this.uieSawOffsetY =            UIEdit('Offset Y', 'd');
            this.uieSawOffsetY.dMin =       -1;
            this.uieSawOffsetY.dMax =       1;
                                    
            this.uipSawTimeType =           UIPopup({'Period (ms)', 'Hz (avg)'}, 'Select Time Type', true);
            addlistener(this.uipSawTimeType, 'eChange', @this.handleSawTimeType);            
            
            this.uieSawHz =                 UIEdit('Hz (avg)', 'd');
            this.uieSawHz.dMin =            0;
            this.uieSawHz.dMax =            1000;
            this.uieSawHz.setVal(200);
            
            this.uieSawPeriod =             UIEdit('Period (ms)', 'd');
            this.uieSawPeriod.setVal(100); 
            this.uieSawPeriod.dMin =        1;
            this.uieSawPeriod.dMax =        10000;
            
            
            
            % ************ Serp waveform panel 
            this.uieSerpSigX =               UIEdit('Sig X', 'd'); 
            this.uieSerpSigX.dMin =          0;
            this.uieSerpSigX.dMax =          1;
            this.uieSerpSigX.setVal(0.5);
            
            this.uieSerpNumX =             UIEdit('Num X (odd)', 'u8');
            this.uieSerpNumX.setVal(uint8(7));
            this.uieSerpNumX.dMin =        uint8(4);
            this.uieSerpNumX.dMax =        uint8(20);
            
            this.uieSerpOffsetX =            UIEdit('Offset X', 'd');
            this.uieSerpOffsetX.dMin =       -1;
            this.uieSerpOffsetX.dMax =       1;
            
            this.uieSerpSigY =               UIEdit('Sig Y', 'd'); 
            this.uieSerpSigY.dMin =          0;
            this.uieSerpSigY.dMax =          1;
            this.uieSerpSigY.setVal(0.5);            
            
            this.uieSerpNumY =             UIEdit('Num Y (odd)', 'u8');
            this.uieSerpNumY.setVal(uint8(7));
            this.uieSerpNumY.dMin =        uint8(4);
            this.uieSerpNumY.dMax =        uint8(20);
            
            this.uieSerpOffsetY =            UIEdit('Offset Y', 'd');
            this.uieSerpOffsetY.dMin =       -1;
            this.uieSerpOffsetY.dMax =       1;
            
            this.uieSerpPeriod =             UIEdit('Period (ms)', 'd');
            this.uieSerpPeriod.setVal(100); 
            this.uieSerpPeriod.dMin =        1;
            this.uieSerpPeriod.dMax =        10000;
            
                        
            addlistener(this.uibPreview, 'eChange', @this.handlePreview);
            addlistener(this.uibSave, 'eChange', @this.handleSave);
            addlistener(this.uilSaved, 'eChange', @this.handleSaved);
            addlistener(this.uilSaved, 'eDelete', @this.handleSavedDelete);
            addlistener(this.uipPlotType, 'eChange', @this.handlePlotType);
            addlistener(this.uibRecord, 'eChange', @this.handleRecord);
            addlistener(this.uibSetWaveform, 'eChange', @this.handleSetWavetable);
            
            % Default values
            
            this.uieMultiPoleNum.setVal(uint8(4));
            this.uieMultiSigMin.setVal(0.2);
            this.uieMultiSigMax.setVal(0.3);
            this.uieMultiCirclesPerPole.setVal(uint8(2));
            this.uieMultiDwell.setVal(uint8(2));
            this.uieMultiOffset.setVal(0.6);
            this.uieMultiTransitTime.setVal(0.08);
            this.uieMultiHz.setVal(200);
            this.uieMultiPeriod.setVal(100);
            this.uieRastorData.setVal('(0.3,0.3,5),(0.5,0.5,10),(0.4,0.4,4)');
            
            this.uieDCx.setVal(0.5);
            this.uieDCy.setVal(0.3);
            
            
            this.uieRecordTime.dMax = 2000;
            this.uieRecordTime.dMin = 0;
            this.uieRecordTime.setVal(100);
            
            

                        
        end
        
        function loadState(this)
                        
            %{
            % ceSelected is a cell of selected options - use the first
            % one.  Populates a structure named s in the local
            % workspace of this method

            cFile = fullfile(this.cDir, '..', this.cSaveDir, this.cName);
            
            if exist(cFile, 'file') ~= 0

                load(cFile); % populates s in local workspace

                this.loadClassInstance(s);
                % this.updateAxes();
                % this.updatePupilImg('preview');
            
            end
            %}
        end
        
        function saveState(this)
            
            %{
            cPath = fullfile(this.cDir, '..', this.cSaveDir, 'saved-state.mat');
            
            % Create a nested recursive structure of all public properties
            s = this.saveClassInstance();
                        
            % Save
            save(cPath, 's');  
            %}
            
        end
       
        
        function handleConnect(this, src, evt)
            
            this.lConnected = true;
            
            if this.uipPlotType.u8Selected == uint8(2)
                % nPoint Monitor
                if ishandle(this.hPlotRecordPanel)
                    set(this.hPlotRecordPanel, 'Visible', 'on');
                end
            end
             
            % Show "set waveform" button
            % Show "record" button
            % Show "set" button
            
            % this.uibRecord.show();
            % this.uieRecordTime.show();
            this.uibSetWaveform.show();    
        end
        
        
        function handleDisconnect(this, src, evt)
            
            this.lConnected = false;
            
            if ishandle(this.hPlotRecordPanel)
                set(this.hPlotRecordPanel, 'Visible', 'off');
            end
                
            % this.uibRecord.hide();
            % this.uieRecordTime.hide();
            this.uibSetWaveform.hide();
        end
        
                
        function handleMultiTimeType(this, src, evt)
            
                                                
            % Show the UIEdit based on popup type 
            switch this.uipMultiTimeType.u8Selected
                case uint8(1)
                    % Period
                    if this.uieMultiHz.isVisible()
                        this.uieMultiHz.hide();
                    end
                    
                    if ~this.uieMultiPeriod.isVisible()
                        this.uieMultiPeriod.show();
                    end
                    
                case uint8(2)
                    % Hz
                    if this.uieMultiPeriod.isVisible()
                        this.uieMultiPeriod.hide();
                    end
                    
                    if ~this.uieMultiHz.isVisible()
                        this.uieMultiHz.show();
                    end
            end    
        end

        
        function handleSawTimeType(this, src, evt)
            
            
            % Show the UIEdit based on popup type
            
            switch this.uipSawTimeType.u8Selected
                case uint8(1)
                    % Period
                    if this.uieSawHz.isVisible()
                        this.uieSawHz.hide();
                    end
                    
                    if ~this.uieSawPeriod.isVisible()
                        this.uieSawPeriod.show();
                    end
                    
                case uint8(2)
                    % Hz
                    if this.uieSawPeriod.isVisible()
                        this.uieSawPeriod.hide();
                    end
                    
                    if ~this.uieSawHz.isVisible()
                        this.uieSawHz.show();
                    end
            end
            
            
        end
        
        function handleType(this, src, evt)
            
            
            % Build the sub-panel based on popup type 
            switch this.uipType.u8Selected
                case uint8(1)
                    % Multi
                    this.hideOtherWaveformPanels(this.hWaveformMultiPanel);
                    if ishandle(this.hWaveformMultiPanel)
                        set(this.hWaveformMultiPanel, 'Visible', 'on');
                    else
                        this.buildWaveformMultiPanel();
                    end
                    
                case uint8(2)
                    % DC offset
                    this.hideOtherWaveformPanels(this.hWaveformDCPanel);
                    if ishandle(this.hWaveformDCPanel)
                        set(this.hWaveformDCPanel, 'Visible', 'on');
                    else
                        this.buildWaveformDCPanel();
                    end
                case uint8(3)
                    % Rastor
                    this.hideOtherWaveformPanels(this.hWaveformRastorPanel);
                    if ishandle(this.hWaveformRastorPanel)
                        set(this.hWaveformRastorPanel, 'Visible', 'on');
                    else
                        this.buildWaveformRastorPanel();
                    end
                case uint8(4)
                    % Triangle
                    this.hideOtherWaveformPanels(this.hWaveformSawPanel);
                    if ishandle(this.hWaveformSawPanel)
                        set(this.hWaveformSawPanel, 'Visible', 'on');
                    else
                        this.buildWaveformSawPanel();
                    end
                case uint8(5)
                    % Serpentine
                    this.hideOtherWaveformPanels(this.hWaveformSerpPanel);
                    if ishandle(this.hWaveformSerpPanel)
                        set(this.hWaveformSerpPanel, 'Visible', 'on');
                    else
                        this.buildWaveformSerpPanel();
                    end
            end
            
            
        end
        
        
        function hideOtherWaveformPanels(this, h)
            
            % @parameter h
            %   type: handle
            %   desc: handle of the panel that you don't want to hide
            
            % USE CAUTION!  h may be empty when we pass it in
            
            %{
            this.msg( ...
                sprintf( ...
                    'PupilFill.hideOtherWaveformPanels() \n\t %1.0f', ...
                    h ...
                ) ...
            );
            %}
            
            % cell of handles of each waveform panel
            ceh = { ...
                this.hWaveformMultiPanel, ...
                this.hWaveformDCPanel, ...
                this.hWaveformRastorPanel, ...
                this.hWaveformSawPanel, ...
                this.hWaveformSerpPanel ...
            };
            
            % loop through all panels
            for n = 1:length(ceh)            
                
                %{
                this.msg( ...
                    sprintf( ...
                        'PupilFill.hideOtherWaveformPanels() \n\t panel: %s \n\t ishandle: %1.0f \n\t handleval: %1.0f \n\t visible: %s \n\t isequal: %1.0f ', ...
                        this.uipType.ceOptions{uint8(n)}, ...
                        +ishandle(ceh{n}), ...
                        ceh{n}, ...
                        get(ceh{n}, 'Visible'), ...
                        +(ceh{n} ~= h) ...
                    ) ...
                );
                %}
                
                if ishandle(ceh{n}) & ...
                   strcmp(get(ceh{n}, 'Visible'), 'on') & ...
                   (isempty(h) | ceh{n} ~= h)
                    this.msg(sprintf('PupilFill.hideOtherWaveformPanels() hiding %s panel', this.uipType.ceOptions{uint8(n)}));
                    set(ceh{n}, 'Visible', 'off');
                    
                end
            end
            
        end
        
        function hideWaveformPanels(this)
                           
            if ishandle(this.hWaveformMultiPanel)
                set(this.hWaveformMultiPanel, 'Visible', 'off');
            end
            
            if ishandle(this.hWaveformDCPanel)
                set(this.hWaveformDCPanel, 'Visible', 'off');
            end
            
            if ishandle(this.hWaveformRastorPanel)
                set(this.hWaveformRastorPanel, 'Visible', 'off');
            end
            
            if ishandle(this.hWaveformSawPanel)
                set(this.hWaveformSawPanel, 'Visible', 'off');
            end
            
            drawnow;
            
        end
        
        
        function handlePlotType(this, src, evt)
            
            
            % Debug: echo visibility of record button
            
            % this.uibRecord.isVisible()
            % this.uieRecordTime.isVisible();
            
            
            % Hide all other panels
            this.hidePlotPanels();
                        
            % Build the sub-panel based on popup type 
            switch this.uipPlotType.u8Selected
                case uint8(1)
                    % Preview
                    if ishandle(this.hPlotPreviewPanel)
                        set(this.hPlotPreviewPanel, 'Visible', 'on');
                    else
                        this.buildPlotPreviewPanel();
                    end
                case uint8(2)
                    % nPoint Monitor
                    if ishandle(this.hPlotMonitorPanel)
                        set(this.hPlotMonitorPanel, 'Visible', 'on');
                    else
                        this.buildPlotMonitorPanel();
                    end
                    
                    % Show the record panel when the device is connected
                    if this.lConnected
                        if ishandle(this.hPlotRecordPanel)
                            set(this.hPlotRecordPanel, 'Visible', 'on');
                        else
                            this.buildPlotRecordPanel();
                        end
                    end
                    
            end                
            
        end
        
        function hidePlotPanels(this)
                           
            if ishandle(this.hPlotPreviewPanel)
                set(this.hPlotPreviewPanel, 'Visible', 'off');
            end
            
            if ishandle(this.hPlotMonitorPanel)
                set(this.hPlotMonitorPanel, 'Visible', 'off');
            end
            
            if ishandle(this.hPlotRecordPanel)
                set(this.hPlotRecordPanel, 'Visible', 'off');
            end
                                                
        end
        
        function handlePreview(this, src, evt)
            
            % Change plot type to preview
            this.uipPlotType.u8Selected = uint8(1);
            
            
            this.updateWaveforms();
            this.updateAxes();
            this.updatePupilImg('preview');
            
            if this.uipType.u8Selected == uint8(1)
                
                % Update multi range
                
                % The piezos have a voltage range between -30V and 150V
                % 180V is the full swing to achieve 6 mrad
                % +/- 90V = +/- sig = 1.
                % The current across a capacitor is: I = C*dV/dt 
                % The "small signal" capacitance of the piezo stack is about 2e-6 F (C/V).  
                % Source http://trs-new.jpl.nasa.gov/dspace/bitstream/2014/41642/1/08-0299.pdf
                % At full range, the voltage signal is: V(t) = 90*sin(2*pi*f*t)
                % dV/dt = 90*2*pi*f*cos(2*pi*f*t) which has a max of 180*pi*f V/s   
                % At 100 Hz, this is 180*100*pi V/s * 2e-6 (C/V) = 113 mA.  
                % It is believed that capacitance increases to 2.5e-6 F bit
                % for large signal which brings current up to 140 mA
         
    
                % Min frequency occurs at max sig and visa versa
                dC = 2e-6; % advertised
                dC_scale_factor = 300/113;
                
                dVdt_sig_max = 2*pi*90*this.uieMultiSigMax.val()*this.dFreqMin;
                dVdt_sig_min = 2*pi*90*this.uieMultiSigMin.val()*this.dFreqMax;
                dI_sig_max = dC*dC_scale_factor*dVdt_sig_max*1000; % mA
                dI_sig_min = dC*dC_scale_factor*dVdt_sig_min*1000; % mA
                
                cMsg = sprintf('Freq: %1.0f Hz - %1.0f Hz.\nI: %1.0f mA - %1.0f mA', ...
                    this.dFreqMin, ...
                    this.dFreqMax, ...
                    dI_sig_min, ...
                    dI_sig_max ...
                    );
             
                this.uitMultiFreqRange.cVal = cMsg;
            end
            
        end
        
        function updateWaveforms(this)
            
            % Update:
            % 
            %   dVx, 
            %   dVy, 
            %   dVxCorrected, 
            %   dVyCorrected, 
            %   dTime 
            %   i32X
            %   i32Y
            %
            % and update plot preview
            
            switch this.uipType.u8Selected
                case uint8(1)
                    % Multi
                    
                    % Figure type
                    
                    % Show the UIEdit based on popup type 
                    switch this.uipMultiTimeType.u8Selected
                        case uint8(1)
                            % Period
                            lPeriod = true;

                        case uint8(2)
                            % Hz
                            lPeriod = false;
                    end
                    
                    
                    [this.dVx, ...
                     this.dVy, ...
                     this.dVxCorrected, ...
                     this.dVyCorrected, ...
                     this.dTime, ...
                     this.dFreqMin, ...
                     this.dFreqMax] = ScannerCore.getMulti( ...
                        double(this.uieMultiPoleNum.val()), ...
                        this.uieMultiSigMin.val(), ...
                        this.uieMultiSigMax.val(), ...
                        double(this.uieMultiCirclesPerPole.val()), ...
                        double(this.uieMultiDwell.val()), ...
                        this.uieMultiTransitTime.val(), ...
                        this.uieMultiOffset.val(), ...
                        this.uieMultiRot.val(), ...
                        this.uieMultiXOffset.val(), ...
                        this.uieMultiYOffset.val(), ...
                        this.uieMultiHz.val(), ...
                        this.uieVoltsScale.val(), ...
                        this.uieTimeStep.val()*1e-6, ...         
                        this.uieFilterHz.val(), ... 
                        this.uieMultiPeriod.val()/1000, ...
                        lPeriod ...
                        );
                    
                case uint8(2)
                    % DC offset
                    [this.dVx, this.dVy, this.dVxCorrected, this.dVyCorrected, this.dTime] = ScannerCore.getDC( ...
                        this.uieDCx.val(), ...
                        this.uieDCy.val(),...
                        this.uieVoltsScale.val(), ...
                        this.uieTimeStep.val()*1e-6 ...         
                        );
                    
                case uint8(3)
                    % Rastor
                    [this.dVx, this.dVy, this.dVxCorrected, this.dVyCorrected, this.dTime] = ScannerCore.getRastor( ...
                        this.uieRastorData.val(), ...
                        this.uieRastorTransitTime.val(), ...
                        this.uieTimeStep.val(), ... % send in us, not s
                        this.uieVoltsScale.val(), ...
                        this.uieFilterHz.val() ...
                        );
                    
                case uint8(4)
                    % Saw
                    
                    if this.uipSawTimeType.u8Selected == uint8(1)
                        % Period (ms)
                        dHz = 1/(this.uieSawPeriod.val()/1e3);
                    else
                        % Hz
                        dHz = this.uieSawHz.val();
                    end
                    
                    st = ScannerCore.getSaw( ...
                        this.uieSawSigX.val(), ...
                        this.uieSawPhaseX.val(), ...
                        this.uieSawOffsetX.val(), ...
                        this.uieSawSigY.val(), ...
                        this.uieSawPhaseY.val(), ...
                        this.uieSawOffsetY.val(), ...
                        this.uieVoltsScale.val(), ...
                        dHz, ...
                        this.uieFilterHz.val(), ...
                        this.uieTimeStep.val()*1e-6 ...
                        );
                    
                    this.dVx = st.dX;
                    this.dVy = st.dY;
                    this.dTime = st.dT;
                    
                case uint8(5)
                    % Serpentine
                                        
                    st = ScannerCore.getSerpentine2( ...
                        this.uieSerpSigX.val(), ...
                        this.uieSerpSigY.val(), ...
                        this.uieSerpNumX.val(), ...
                        this.uieSerpNumY.val(), ...
                        this.uieSerpOffsetX.val(), ...
                        this.uieSerpOffsetY.val(), ...
                        this.uieSerpPeriod.val()*1e-3, ...
                        this.uieVoltsScale.val(), ...
                        this.uieFilterHz.val(), ...
                        this.uieTimeStep.val()*1e-6 ...
                        );
                    
                    this.dVx = st.dX;
                    this.dVy = st.dY;
                    this.dTime = st.dT;
                                        
            end
            
            
            this.i32X = int32(this.dVx/this.uieVoltsScale.val()*2^20/2);
            this.i32Y = int32(this.dVy/this.uieVoltsScale.val()*2^20/2);  
                        
        end
        
        function updateAxes(this)
            
            % NEED TO FIX!!
            
            if ishandle(this.hFigure) & ... 
               ishandle(this.hPreviewAxis2D) & ...
               ishandle(this.hPreviewAxis1D)

                set(this.hFigure, 'CurrentAxes', this.hPreviewAxis2D)
                plot(this.dVx, this.dVy, 'b');
                xlim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])
                ylim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])

                set(this.hFigure, 'CurrentAxes', this.hPreviewAxis1D)
                plot(this.dTime*1000, this.dVx, 'r', this.dTime*1000, this.dVy,'b')
                xlabel('Time [ms]')
                ylabel('Volts')
                legend('vx','vy')
                xlim([0 max(this.dTime*1000)])
                ylim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])
            end
            
        end
        
        function updateRecordAxes(this)
            
            if ishandle(this.hFigure) & ... 
               ishandle(this.hMonitorAxis2D) & ...
               ishandle(this.hMonitorAxis1D)

                set(this.hFigure, 'CurrentAxes', this.hMonitorAxis2D)
                cla;
                hold on
                plot(this.dRVxSensor, this.dRVySensor, 'b', 'LineWidth', 2);
                plot(this.dRVxCommand, this.dRVyCommand, 'b');
                xlim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])
                ylim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])
                legend('sensor', 'command');

                set(this.hFigure, 'CurrentAxes', this.hMonitorAxis1D)
                cla;
                hold on
                plot(this.dRTime*1000, this.dRVxSensor, 'r', 'LineWidth', 2);
                plot(this.dRTime*1000, this.dRVySensor,'b', 'LineWidth', 2);
                plot(this.dRTime*1000, this.dRVxCommand,'r');
                plot(this.dRTime*1000, this.dRVyCommand,'b');

                xlabel('Time [ms]')
                ylabel('Volts')
                legend('vx sensor','vy sensor', 'vx command', 'vy command');
                xlim([0 max(this.dRTime*1000)])
                ylim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])

                this.updatePupilImg('device');
                
            end
            
        end
        
        
        
        function handleSave(this, src, evt)
            
            
            % Generate a suggested name for save structure.  
            
            switch this.uipType.u8Selected
                case uint8(1)
                    
                    % Multi
                    
                    switch this.uipMultiTimeType.u8Selected
                        case uint8(1)
                            % Period
                            cName = sprintf('%1.0fPole_off%1.0f_rot%1.0f_min%1.0f_max%1.0f_num%1.0f_dwell%1.0f_xoff%1.0f_yoff%1.0f_per%1.0f_filthz%1.0f_dt%1.0f',...
                                this.uieMultiPoleNum.val(), ...
                                this.uieMultiOffset.val()*100, ...
                                this.uieMultiRot.val(), ...
                                this.uieMultiSigMin.val()*100, ...
                                this.uieMultiSigMax.val()*100, ...
                                this.uieMultiCirclesPerPole.val(), ...
                                this.uieMultiDwell.val(), ...
                                this.uieMultiXOffset.val()*100, ...
                                this.uieMultiYOffset.val()*100, ...
                                this.uieMultiPeriod.val(), ...
                                this.uieFilterHz.val(), ...
                                this.uieTimeStep.val() ...
                            );
                        case uint8(2)
                            % Freq
                            cName = sprintf('%1.0fPole_off%1.0f_rot%1.0f_min%1.0f_max%1.0f_num%1.0f_dwell%1.0f_xoff%1.0f_yoff%1.0f_hz%1.0f_filthz%1.0f_dt%1.0f',...
                                this.uieMultiPoleNum.val(), ...
                                this.uieMultiOffset.val()*100, ...
                                this.uieMultiRot.val(), ...
                                this.uieMultiSigMin.val()*100, ...
                                this.uieMultiSigMax.val()*100, ...
                                this.uieMultiCirclesPerPole.val(), ...
                                this.uieMultiDwell.val(), ...
                                this.uieMultiXOffset.val()*100, ...
                                this.uieMultiYOffset.val()*100, ...
                                this.uieMultiHz.val(), ...
                                this.uieFilterHz.val(), ...
                                this.uieTimeStep.val() ...
                            ); 
                    end
                    
                case uint8(2)
                    
                    % DC offset
                    cName = sprintf('DC_x%1.0f_y%1.0f_dt%1.0f', ...
                        this.uieDCx.val()*100, ...
                        this.uieDCy.val()*100, ...
                        this.uieTimeStep.val() ...
                    );
                
                case uint8(3)
                    
                    % Rastor
                    cName = sprintf('Rastor_%s_ramp%1.0f_dt%1.0f', ...
                        this.uieRastorData.val(), ...
                        this.uieRastorTransitTime.val(), ...
                        this.uieTimeStep.val() ...
                    );
                
                case uint8(4)
                    % Saw
                    switch this.uipSawTimeType.u8Selected
                        case uint8(1)
                            % Period
                            cName = sprintf('Saw_sigx%1.0f_phasex%1.0f_offx%1.0f_sigy%1.0f_phasey%1.0f_offy%1.0f_scale%1.0f_per%1.0f_filthz%1.0f_dt%1.0f.mat',...
                                this.uieSawSigX.val()*100, ...
                                this.uieSawPhaseX.val(), ...
                                this.uieSawOffsetX.val()*100, ...
                                this.uieSawSigY.val()*100, ...
                                this.uieSawPhaseY.val(), ...
                                this.uieSawOffsetY.val()*100, ...
                                this.uieVoltsScale.val(), ...
                                this.uieSawPeriod.val(), ...
                                this.uieFilterHz.val(), ...
                                this.uieTimeStep.val() ...
                            );                           
                    
                        
                        case uint8(2)
                            % Period
                            cName = sprintf('Saw_sigx%1.0f_phasex%1.0f_offx%1.0f_sigy%1.0f_phasey%1.0f_offy%1.0f_scale%1.0f_hz%1.0f_filthz%1.0f_dt%1.0f.mat',...
                                this.uieSawSigX.val()*100, ...
                                this.uieSawPhaseX.val(), ...
                                this.uieSawOffsetX.val()*100, ...
                                this.uieSawSigY.val()*100, ...
                                this.uieSawPhaseY.val(), ...
                                this.uieSawOffsetY.val()*100, ...
                                this.uieVoltsScale.val(), ...
                                this.uieSawHz.val(), ...
                                this.uieFilterHz.val(), ...
                                this.uieTimeStep.val() ...
                            );   
                    end
                    
                case uint8(5)
                    
                    % Serpentine
                    cName = sprintf('Serpentine_sigx%1.0f_numx%1.0f_offx%1.0f_sigy%1.0f_numy%1.0f_offy%1.0f_scale%1.0f_per%1.0f_filthz%1.0f_dt%1.0f.mat',...
                        this.uieSerpSigX.val()*100, ...
                        this.uieSerpNumX.val(), ...
                        this.uieSerpOffsetX.val()*100, ...
                        this.uieSerpSigY.val()*100, ...
                        this.uieSerpNumY.val(), ...
                        this.uieSerpOffsetY.val()*100, ...
                        this.uieVoltsScale.val(), ...
                        this.uieSerpPeriod.val(), ...
                        this.uieFilterHz.val(), ...
                        this.uieTimeStep.val() ...
                    );  
                     
            end
            
            
            cName = fullfile(this.cSaveDir, cName);
            [cFileName, cPathName, cFilterIndex] = uiputfile('*.mat', 'Save As:', cName);
            
            % uiputfile returns 0 when the user hits cancel
            if cFileName ~= 0
                this.savePupilFill(cFileName, cPathName)
            end
                                                    
        end
        
        
        function savePupilFill(this, cFileName, cPathName)
                                    
            % Create a nested recursive structure of all public properties
            
            s = this.saveClassInstance();
            
            % Remove uilSaved from the structure.  We don't want to
            % overwrite the list of available prescriptions when one is
            % loaded
            
            s = rmfield(s, 'uilSaved');
                        
            % Save
            save(fullfile(cPathName, cFileName), 's');
            
            % If the name is not already on the list, append it
            if isempty(strmatch(cFileName, this.uilSaved.ceOptions, 'exact'))
                this.uilSaved.append(cFileName);
            end
            
            notify(this, 'eNew');
            
            %{
            % Save ascii files for nPoint software.  Make sure the time
            % step is 24 us.  This is the control loop clock so it will
            % read a data point from the file once every 24 us.  If your
            % samples are not separated by 24 us, the process of reading
            % the txt file will change the effective frequency
            
            % Signal levels need to be in mrad.  +/- 10 V == +/- 3 mrad.
            % Also, the vector needs to be a column vector before it is
            % written to ascii so each value goes on a new line.
            
            vx = this.dVx*3/10;
            vy = this.dVy*3/10;
            
            vx = vx';
            vy = vy';
            
            % Build the pupilfill_ascii directory if it does not exist
            
            cSaveDir = sprintf('%s../pupilfill_ascii', this.cDir);
            if exist(cSaveDir, 'dir') == 0
                mkdir(cSaveDir);
            end
            
            % Save
            
            cPathX = sprintf('%s/%s_x.txt', ...
                cSaveDir, ...
                cName ...
                );
            cPathY = sprintf('%s/%s_y.txt', ...
                cSaveDir, ...
                cName ...
                );
            
            save(cPathX, 'vx', '-ascii');
            save(cPathY, 'vy', '-ascii');
            %}
           
        end
        
        function buildWaveformPanel(this)
                        
            if ishandle(this.hFigure)

                dLeftCol1 = 10;
                dLeftCol2 = 100;
                dEditWidth = 80;
                dTop = 20;
                dSep = 55;

                % Panel
                this.hWaveformPanel = uipanel(...
                    'Parent', this.hFigure,...
                    'Units', 'pixels',...
                    'Title', 'Build Waveform',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([10 10 210 700], this.hFigure) ...
                );
                drawnow;


                % Popup (to select type)
                this.uipType.build(this.hWaveformPanel, dLeftCol1, dTop, 190, Utils.dEDITHEIGHT);

                % Build the sub-panel based on popup type 
                switch this.uipType.u8Selected
                    case uint8(1)
                        % Multi
                        this.buildWaveformMultiPanel();
                    case uint8(2)
                        % DC offset
                        this.buildWaveformDCPanel();
                    case uint8(3)
                        % Rastor
                        this.buildWaveformRastorPanel();
                    case uint8(4)
                        % Triangle
                        this.buildWaveformSawPanel();
                    case uint8(5)
                        % Serpentine
                        this.buildWaveformSerpPanel();
                end


                % Build sub-panel for parameters that apply to all waveform
                this.buildWaveformGeneralPanel();


                % Preview and save buttons
                dTop = 630;
                this.uibPreview.build(this.hWaveformPanel, dLeftCol1, dTop, 190, Utils.dEDITHEIGHT);
                dTop = dTop + 30;

                this.uibSave.build(this.hWaveformPanel, dLeftCol1, dTop, 190, Utils.dEDITHEIGHT);
                dTop = dTop + dSep;
                
            end
            
        end
        
        function buildWaveformGeneralPanel(this)
            
            if ishandle(this.hWaveformPanel)

                dLeftCol1 = 10;
                dLeftCol2 = 100;
                dEditWidth = 80;
                dTop = 20;
                dSep = 55;

                % Panel

                this.hWaveformGeneralPanel = uipanel(...
                    'Parent', this.hWaveformPanel,...
                    'Units', 'pixels',...
                    'Title', 'General',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([10 490 190 130], this.hWaveformPanel) ...
                );
                drawnow;

                % Build filter Hz, Volts scale and time step

                this.uieFilterHz.build(this.hWaveformGeneralPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);            
                this.uieVoltsScale.build(this.hWaveformGeneralPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
                dTop = dTop + dSep;

                this.uieTimeStep.build(this.hWaveformGeneralPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieConvKernelSig.build(this.hWaveformGeneralPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
                
                dTop = dTop + dSep; 
                
            end
            
        end
        
        
        function buildWaveformMultiPanel(this)
            
            if ishandle(this.hWaveformPanel)
            
                dLeftCol1 = 10;
                dLeftCol2 = 100;
                dEditWidth = 80;
                dTop = 20;
                dSep = 55;

                % Panel
                this.hWaveformMultiPanel = uipanel(...
                    'Parent', this.hWaveformPanel,...
                    'Units', 'pixels',...
                    'Title', 'Multipole configuration',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([10 65 190 420], this.hWaveformPanel) ...
                );
                drawnow;

                this.uieMultiPoleNum.build(this.hWaveformMultiPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieMultiTransitTime.build(this.hWaveformMultiPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);            


                dTop = dTop + dSep;

                this.uieMultiSigMin.build(this.hWaveformMultiPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieMultiSigMax.build(this.hWaveformMultiPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
                dTop = dTop + dSep;

                this.uieMultiCirclesPerPole.build(this.hWaveformMultiPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieMultiDwell.build(this.hWaveformMultiPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
                dTop = dTop + dSep;

                this.uieMultiOffset.build(this.hWaveformMultiPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieMultiRot.build(this.hWaveformMultiPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
                dTop = dTop + dSep;

                this.uieMultiXOffset.build(this.hWaveformMultiPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieMultiYOffset.build(this.hWaveformMultiPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
                dTop = dTop + dSep;

                % Popup (to select type)
                this.uipMultiTimeType.build(this.hWaveformMultiPanel, dLeftCol1, dTop, 170, Utils.dEDITHEIGHT);
                dTop = dTop + 45;

                this.uieMultiPeriod.build(this.hWaveformMultiPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieMultiHz.build(this.hWaveformMultiPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);                

                % Call handler for multitimetype to make active type visible
                this.handleMultiTimeType();
                dTop = dTop + 45;

                this.uitMultiFreqRange.build(this.hWaveformMultiPanel, dLeftCol1, dTop, 170, 30);
                
                drawnow;
                
            end
            
        end
        
        function buildWaveformDCPanel(this)
            
            if ishandle(this.hWaveformPanel)

                dLeftCol1 = 10;
                dLeftCol2 = 100;
                dEditWidth = 80;
                dTop = 20;
                dSep = 55;

                % Panel

                this.hWaveformDCPanel = uipanel(...
                    'Parent', this.hWaveformPanel,...
                    'Units', 'pixels',...
                    'Title', 'DC configuration',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([10 65 190 80], this.hWaveformPanel) ...
                );
                drawnow;


                this.uieDCx.build(this.hWaveformDCPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);            
                this.uieDCy.build(this.hWaveformDCPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);
                
                drawnow;
            end

        end
        
        function buildWaveformRastorPanel(this)
            
            if ishandle(this.hWaveformPanel)

                dLeftCol1 = 10;
                dLeftCol2 = 100;
                dEditWidth = 80;
                dTop = 20;
                dSep = 55;

                % Panel
                this.hWaveformRastorPanel = uipanel(...
                    'Parent', this.hWaveformPanel,...
                    'Units', 'pixels',...
                    'Title', 'Rastor configuration',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([10 65 190 130], this.hWaveformPanel) ...
                );
                drawnow;


                this.uieRastorData.build(this.hWaveformRastorPanel, dLeftCol1, dTop, 170, Utils.dEDITHEIGHT); 
                dTop = dTop + dSep;     

                this.uieRastorTransitTime.build(this.hWaveformRastorPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
           
                drawnow;
            
            end
            
        end
        
        function buildWaveformSawPanel(this)
            
            if ishandle(this.hWaveformPanel)

                dLeftCol1 = 10;
                dLeftCol2 = 100;
                dEditWidth = 80;
                dTop = 20;
                dSep = 55;

                this.hWaveformSawPanel = uipanel(...
                    'Parent', this.hWaveformPanel,...
                    'Units', 'pixels',...
                    'Title', 'Triangle configuration',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([10 65 190 300], this.hWaveformPanel) ...
                );
                drawnow;

                this.uieSawSigX.build(this.hWaveformSawPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieSawSigY.build(this.hWaveformSawPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);            

                dTop = dTop + dSep;
                
                this.uieSawPhaseX.build(this.hWaveformSawPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieSawPhaseY.build(this.hWaveformSawPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);            

                dTop = dTop + dSep;
                
                this.uieSawOffsetX.build(this.hWaveformSawPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieSawOffsetY.build(this.hWaveformSawPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);            
                
                dTop = dTop + dSep;
                
                this.uipSawTimeType.build(this.hWaveformSawPanel, dLeftCol1, dTop, 170, Utils.dEDITHEIGHT);
                
                dTop = dTop + 45;

                this.uieSawPeriod.build(this.hWaveformSawPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieSawHz.build(this.hWaveformSawPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);                
                this.handleSawTimeType(); % Call handler for multitimetype to make active type visible
                
                drawnow;
            end
            
        end
        
        
        function buildWaveformSerpPanel(this)
            
            if ishandle(this.hWaveformPanel)

                dLeftCol1 = 10;
                dLeftCol2 = 100;
                dEditWidth = 80;
                dTop = 20;
                dSep = 55;

                this.hWaveformSerpPanel = uipanel(...
                    'Parent', this.hWaveformPanel,...
                    'Units', 'pixels',...
                    'Title', 'Serpentine config',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([10 65 190 300], this.hWaveformPanel) ...
                );
                drawnow;

                this.uieSerpSigX.build(this.hWaveformSerpPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieSerpSigY.build(this.hWaveformSerpPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);            

                dTop = dTop + dSep;
                
                this.uieSerpNumX.build(this.hWaveformSerpPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieSerpNumY.build(this.hWaveformSerpPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);            

                dTop = dTop + dSep;
                
                this.uieSawOffsetX.build(this.hWaveformSerpPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                this.uieSawOffsetY.build(this.hWaveformSerpPanel, dLeftCol2, dTop, dEditWidth, Utils.dEDITHEIGHT);            
                
                dTop = dTop + dSep;
                
                this.uieSerpPeriod.build(this.hWaveformSerpPanel, dLeftCol1, dTop, dEditWidth, Utils.dEDITHEIGHT);
                
                drawnow;
            end
            
        end
        
        function buildSavedWaveformsPanel(this)
            
            if ishandle(this.hFigure)

                dWidth = 480 + 190;

                hPanel = uipanel(...
                    'Parent', this.hFigure,...
                    'Units', 'pixels',...
                    'Title', 'Saved Waveforms',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([230 this.dYOffset dWidth 350], this.hFigure) ...
                );
                drawnow;

                dButtonWidth = 100;
                this.uilSaved.build(hPanel, 10, 20, dWidth-20, 290);
                this.uibSetWaveform.build(hPanel, dWidth - 20 - dButtonWidth, 315, dButtonWidth, Utils.dEDITHEIGHT);
                this.uibSetWaveform.hide();
                
            end
            
        end
        
        function buildPlotPanel(this)
            
            if ishandle(this.hFigure)

                this.hPlotPanel = uipanel(...
                    'Parent', this.hFigure,...
                    'Units', 'pixels',...
                    'Title', 'Plot',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([230 10 990 340], this.hFigure) ...
                );
                drawnow; 

                % Popup (to select type)
                this.uipPlotType.build(this.hPlotPanel, 10, 20, 190, Utils.dEDITHEIGHT);

                % Call handler for popup to build type
                this.handlePlotType();
            end
            
        end
        
        function buildPlotPreviewPanel(this)
            
            if ishandle(this.hPlotPanel)

                dSize = 220;
                dPad = 30;

                this.hPlotPreviewPanel = uipanel(...
                    'Parent', this.hPlotPanel,...
                    'Units', 'pixels',...
                    'Title', '',...
                    'Clipping', 'on',...
                    'BorderType', 'none', ...
                    'Position', Utils.lt2lb([2 65 990-6 280], this.hPlotPanel) ...
                );
                drawnow;            

                this.hPreviewAxis1D = axes(...
                    'Parent', this.hPlotPreviewPanel,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([dPad 5 dSize*2 dSize], this.hPlotPreviewPanel),...
                    'XColor', [0 0 0],...
                    'YColor', [0 0 0],...
                    'HandleVisibility','on'...
                    );

                this.hPreviewAxis2D = axes(...
                    'Parent', this.hPlotPreviewPanel,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([2*(dPad+dSize) 5 dSize dSize], this.hPlotPreviewPanel),...
                    'XColor', [0 0 0],...
                    'YColor', [0 0 0],...
                    'DataAspectRatio',[1 1 1],...
                    'HandleVisibility','on'...
                    );

                this.hPreviewAxis2DSim = axes(...
                    'Parent', this.hPlotPreviewPanel,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([3*(dSize+dPad) 5 dSize dSize], this.hPlotPreviewPanel),...
                    'XColor', [0 0 0],...
                    'YColor', [0 0 0],...
                    'DataAspectRatio',[1 1 1],...
                    'HandleVisibility','on'...
                    );

                    % 'PlotBoxAspectRatio',[obj.xpix obj.ypix 1],...
                    % 'XTick',[],...
                    % 'YTick',[],...
                    % 'Xlim',[obj.stagexminCAL obj.stagexmaxCAL] ...
                    % 'Color',[0.3,0.3,0.3],...
                    
            end
            
            
        end
        
        
        
        function buildPlotMonitorPanel(this)
            
            if ishandle(this.hPlotPanel)

                dSize = 220;
                dPad = 30;

                this.hPlotMonitorPanel = uipanel(...
                    'Parent', this.hPlotPanel,...
                    'Units', 'pixels',...
                    'Title', '',...
                    'Clipping', 'on',...
                    'BorderType', 'none', ...
                    'Position', Utils.lt2lb([2 65 990-6 280], this.hPlotPanel) ...
                );
                drawnow;


                this.hMonitorAxis1D = axes(...
                    'Parent', this.hPlotMonitorPanel,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([dPad 5 dSize*2 dSize], this.hPlotMonitorPanel),...
                    'XColor', [0 0 0],...
                    'YColor', [0 0 0],...
                    'HandleVisibility','on'...
                    );

                this.hMonitorAxis2D = axes(...
                    'Parent', this.hPlotMonitorPanel,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([2*(dPad+dSize) 5 dSize dSize], this.hPlotMonitorPanel),...
                    'XColor', [0 0 0],...
                    'YColor', [0 0 0],...
                    'DataAspectRatio',[1 1 1],...
                    'HandleVisibility','on'...
                    );

                this.hMonitorAxis2DSim = axes(...
                    'Parent', this.hPlotMonitorPanel,...
                    'Units', 'pixels',...
                    'Position',Utils.lt2lb([3*(dSize+dPad) 5 dSize dSize], this.hPlotMonitorPanel),...
                    'XColor', [0 0 0],...
                    'YColor', [0 0 0],...
                    'DataAspectRatio',[1 1 1],...
                    'HandleVisibility','on'...
                    );

                    % 'PlotBoxAspectRatio',[obj.xpix obj.ypix 1],...
                    % 'XTick',[],...
                    % 'YTick',[],...
                    % 'Xlim',[obj.stagexminCAL obj.stagexmaxCAL] ...
                    % 'Color',[0.3,0.3,0.3],...
                    
            end
            
            
        end
        
        
        function buildPlotRecordPanel(this)
            
            if ishandle(this.hPlotPanel)

                this.hPlotRecordPanel = uipanel(...
                    'Parent', this.hPlotPanel,...
                    'Units', 'pixels',...
                    'Title', '',...
                    'Clipping', 'on',...
                    'BorderType', 'none', ...
                    'Position', Utils.lt2lb([210 25 200 40], this.hPlotPanel) ...
                );
                drawnow;

                % Button
                this.uibRecord.build(this.hPlotRecordPanel, 0, 0, 100, Utils.dEDITHEIGHT);

                % Time
                this.uieRecordTime.build(this.hPlotRecordPanel, 105, 0, 40, Utils.dEDITHEIGHT);

                % "ms"
                uitLabel = UIText('ms');
                uitLabel.build(this.hPlotRecordPanel, 150, 8, 30, Utils.dEDITHEIGHT);

                % this.uibRecord.hide();
                % this.uieRecordTime.hide();
            end
            
        end
        
        
        
        
        
        function cb(this, src, evt)
            
            switch src
                case this.hFigure
                    this.closeRequestFcn();
                    
            end
            
        end
        
        
        
        
        function closeRequestFcn(this)
            delete(this.hFigure);
            this.saveState();
            
            
            
        end
        
        
        
        function updatePupilImg(this, cType)

            % Return if the handles don't exist
            
            switch (cType)
                case 'preview'
                    if  ishandle(this.hFigure) & ...
                        ishandle(this.hPreviewAxis2DSim)
                        % Proceed
                    else
                        return;
                    end
                case 'device'
                    if ishandle(this.hFigure) & ...
                       ishandle(this.hMonitorAxis2DSim)
                        % Proceed
                    else
                        return;
                    end
            end
            

            % 2013.08.19 CNA
            % Passing in Vx and Vy now so it is easy to do with the sensor
            % data and not just the preview waveform data

            % Set up pupil preview parameters

            pixels = 220;
            scale_factor = 1.1;
            range = this.uieVoltsScale.val()*scale_factor;

            % Create empty pupil fill matrices

            int = zeros(pixels,pixels);
            int_gc = zeros(pixels,pixels);

            % Map each (vx,vy) pair to its corresponding pixel in the pupil
            % fill matrices.  For vy, need to flip its sign before
            % computing the pixel because of the way matlab does y
            % coordinates in an image plot

            dVoltsAtEdge = this.dPupilScale*this.uieVoltsScale.val();

            switch (cType)
                case 'preview'
                    dVxPixel = ceil(this.dVx/dVoltsAtEdge*(this.dPupilPixels/2)) + floor(this.dPupilPixels/2);
                    dVyPixel = ceil(-this.dVy/dVoltsAtEdge*(this.dPupilPixels/2)) + floor(this.dPupilPixels/2);                    
                case 'device'
                    dVxPixel = ceil(this.dRVxSensor/dVoltsAtEdge*(this.dPupilPixels/2)) + floor(this.dPupilPixels/2);
                    dVyPixel = ceil(-this.dRVySensor/dVoltsAtEdge*(this.dPupilPixels/2)) + floor(this.dPupilPixels/2);
            end

            % If any of the pixels lie outside the matrix, discard them

            dIndex = find(  dVxPixel <= this.dPupilPixels & ...
                            dVxPixel > 0 & ...
                            dVyPixel <= this.dPupilPixels & ...
                            dVyPixel > 0 ...
                            );

            dVxPixel = dVxPixel(dIndex);
            dVyPixel = dVyPixel(dIndex);

            % Add a "1" at each pixel where (vx,vy) pairs reside.  We may end up adding
            % "1" to a given pixel a few times - especially if the dwell is set to more
            % than 1.

            for n = 1:length(dVxPixel)
                int(dVyPixel(n), dVxPixel(n)) = int(dVyPixel(n), dVxPixel(n)) + 1;
            end

%             for n = 1:length(x_gc)
%                 int_gc(y_gc(n),x_gc(n)) = int_gc(y_gc(n),x_gc(n)) + 1;
%             end

            % Get the convolution kernel.  Assume a Gaussign of FWHM =
            % dSigmaKernel.  The matrix will have


            dKernelSig = 0.02; % Using uie now.
            dKernelSigPixels = this.uieConvKernelSig.val()*this.dPupilPixels/this.dPupilScale/2;
            dKernelPixels = floor(dKernelSigPixels*2*4); % the extra factor of 2 is for oversize padding
            [dX, dY] = this.getXY(dKernelPixels, dKernelPixels, dKernelPixels, dKernelPixels);
            dKernelInt = this.gauss(dX, dKernelSigPixels, dY, dKernelSigPixels);
            
            [dX, dY] = this.getXY(pixels, pixels, 2*scale_factor, 2*scale_factor);
            dKernelInt = this.gauss(dX, this.uieConvKernelSig.val(), dY, this.uieConvKernelSig.val());
            
            
            % Update.  Build an aberrated, lumpy footprint for developing
            % serpentine patterns
            
            %{
            
            dKernelInt = zeros(size(dY));
            dTrials = 4;
            dSpread = 0.2;
            dMag = abs(randn(1, dTrials));
            dX0 = randn(1, dTrials)*dSpread*scale_factor;
            dY0 = randn(1, dTrials)*dSpread*scale_factor;
            
            for n = 1:dTrials
                dKernelInt = dKernelInt + dMag(n)*this.gauss(...
                    dX - dX0(n), ...
                    this.uieConvKernelSig.val(), ...
                    dY - dY0(n), ...
                    this.uieConvKernelSig.val());
            end
            
            
            % Compute centroid
            dArea = sum(sum(dKernelInt));
            dMeanX = sum(sum(dKernelInt.*dX))/dArea*pixels/2;
            dMeanY = sum(sum(dKernelInt.*dY))/dArea*pixels/2;
            
            dKernelInt = circshift(dKernelInt, [-round(dMeanX), -round(dMeanY)]);
            
            %}
                      

            % Convolve the pseudo-intensity map with kernel and normalize

            int = conv2(int,dKernelInt.^2,'same');
            int = int./max(max(int));
            % int = imrotate(int, 90);


            % Fill simulated with gain plot.  Old way to activate the axes we want:
            % axes(handles.pupil_axes), however this way sucks because it actually
            % creates a new

            switch (cType)
                case 'preview'
                    set(this.hFigure, 'CurrentAxes', this.hPreviewAxis2DSim);
                case 'device'
                    set(this.hFigure, 'CurrentAxes', this.hMonitorAxis2DSim);
            end

            imagesc(int)
            axis('image')
            colormap('jet');


            % Create plotting data for circles at sigma = 0.3 - 1.0

            dSig = [0.3:0.1:1.0];
            dPhase = linspace(0, 2*pi, this.dPupilPixels);

            for (k = 1:length(dSig))

                % set(this.hFigure, 'CurrentAxes', this.hPreviewAxis2DSim)
                x = dSig(k)*this.dPupilPixels/this.dPupilScale/2*cos(dPhase) + this.dPupilPixels/2;
                y = dSig(k)*this.dPupilPixels/this.dPupilScale/2*sin(dPhase) + this.dPupilPixels/2;
                line( ...
                    x, y, ...
                    'color', [0.3 0.3 0.3], ... % [0.3 0.1 0.4], ... % [1 1 0] == yellow
                    'LineWidth', 1 ...
                    );

            end

        end
        
      
        
        function drawSigmaCircles(this)

            
            
        end
        
        
        function [X,Y] = getXY(this, Nx, Ny, Lx, Ly)

            % Sample spacing

            dx = Lx/Nx;
            dy = Ly/Ny;


            % Sampled simulation points 1D 

            x = -Lx/2:dx:Lx/2 - dx;
            y = -Ly/2:dy:Ly/2 - dy;
            % u = -1/2/dx: 1/Nx/dx: 1/2/dx - 1/Nx/dx;
            % v = -1/2/dy: 1/Ny/dy: 1/2/dy - 1/Ny/dy;

            [Y,X] = meshgrid(y,x);
            % [V,U] = meshgrid(v,u);
            
        end
        
        
        function [out] = gauss(this, x, sigx, y, sigy)

            if nargin == 5
                out = exp(-((x/sigx).^2/2+(y/sigy).^2/2)); 
            elseif nargin == 4;
                disp('Must input x,sigx,y,sigy in ''gauss'' function')
            elseif nargin == 3;
                out = exp(-x.^2/2/sigx^2);
            elseif nargin == 12;
                out = exp(-x.^2/2);
            end
            
        end
        
        function handleSavedDelete(this, src, evt)
           
            % In this case, evt is an instance of EventWithData (custom
            % class that extends event.EventData) that has a property
            % stData (a structure).  The structure has one property called
            % options which is a cell array of the items on the list that
            % were just deleted.
            % 
            % Need to loop through them and delete them from the directory.
            % The actual filenames are appended with .mat
            
            evt.stData.ceOptions
            
            for k = 1:length(evt.stData.ceOptions)
                
                cFile = sprintf('%s../%s/%s.mat', ...
                    this.cDir, ...
                    this.cSaveDir, ...
                    evt.stData.ceOptions{k} ...
                );
            
                if exist(cFile, 'file') ~= 0
                    % File exists, delete it
                    delete(cFile);
                else
                    this.msg(sprintf('Cannot find file: %s; not deleting.', cFile));
                end
                
            end
            
            notify(this, 'eDelete')

        end
        
        function handleSaved(this, src, evt)
            
                        
            % Make sure preview is showing
            
            if this.uipPlotType.u8Selected ~= uint8(1)
                this.uipPlotType.u8Selected = uint8(1);
            end
            
            
            % Load the .mat file
            
            
            if ~isempty(this.uilSaved.ceSelected)
                
                % ceSelected is a cell of selected options - use the first
                % one.  Populates a structure named s in the local
                % workspace of this method
                
                cFile = fullfile( ...
                    this.cDir, ...
                    '..', ...
                    this.cSaveDir, ...
                    this.uilSaved.ceSelected{1} ...
                );
            
                
                if exist(cFile, 'file') ~= 0
                
                    load(cFile); % populates s in local workspace
                    
                    % Remove a few properties from s (if they are there),
                    % specifically the ceOptions property of the uiPopup
                    % instances
                                        
                    % uipType.ceOptions
                    
                    if isfield(s, 'uipType')
                        st = rmfield(s.uipType, 'ceOptions');
                        s.uipType = st;
                    end
                    
                    % uipMultiTimeType.ceOptions
                    
                    if isfield(s, 'uipMultiTimeType')
                        st = rmfield(s.uipMultiTimeType, 'ceOptions');
                        s.uipMultiTimeType = st;
                    end
                    
                    % uipSawTimeType.ceOptions
                    
                    if isfield(s, 'uipSawTimeType')
                        st = rmfield(s.uipSawTimeType, 'ceOptions');
                        s.uipSawTimeType = st;
                    end
                    
                    this.loadClassInstance(s);
                    
                    % When dVx, dVy, etc. are private
                    % this.handlePreview();  
                    
                    % When dVx, dVy, etc. are public
                    this.updateAxes();
                    this.updatePupilImg('preview');
                    
                else
                    
                    % warning message box
                    
                    h = msgbox( ...
                        'This pupil file file cannot be found.  Click OK below to continue.', ...
                        'File does not exist', ...
                        'warn', ...
                        'modal' ...
                        );
                    
                    % wait for them to close the message
                    uiwait(h);
                    
                    
                end
                
                
            else
                
                % ceSelected is an empty [1x0] cell.  do nothing
                
            end
            
 
        end
        
        function buildCameraPanel(this)
            
            if ishandle(this.hFigure)

                % Panel
                this.hCameraPanel = uipanel(...
                    'Parent', this.hFigure,...
                    'Units', 'pixels',...
                    'Title', 'Camera overlay with sigma annular lines',...
                    'Clipping', 'on',...
                    'Position', Utils.lt2lb([720 this.dYOffset 400 350], this.hFigure) ...
                );
                drawnow;
            end
            
        end        
        
        function handleRecord(this, src, evt)
            
            stReturn = this.np.record(this.uieRecordTime.val());
            
            % Unpack 
            this.dRVxCommand =      stReturn.dRVxCommand;
            this.dRVxSensor =       stReturn.dRVxSensor;
            this.dRVyCommand =      stReturn.dRVyCommand;   
            this.dRVySensor =       stReturn.dRVySensor;
            this.dRTime =           stReturn.dRTime;
            
            % Update the axes
            this.updateRecordAxes();
            
        end
        
        
        function handleSetWavetable(this, src, evt)
            
            %{
            Stages have 20-bit precision throughout their range.  Positions
            are 20-bit signed (+/-524287). When signal is at +/- 524287,
            the stage is at its max range.   For example, if an axis has a
            range of +/- 50 um and you want to command the stage to move to
            +15 microns from center, you would set "signal" to 0x26666 (=
            524287/50*15).

            User passes in pre-scaled array of integers

            The maximum buffer size is 83,333 points, 2 seconds of data at
            full loop speed (1 clock cycle every 24 ?sec).
            %}
            
            if isempty(this.i32X) || ...
               isempty(this.i32Y)
                
                % Empty - did not type anything
                % Throw a warning box and recursively call

                h = msgbox( ...
                    'The signal has not been set, click preview first.', ...
                    'Empty name', ...
                    'warn', ...
                    'modal' ...
                    );

                % wait for them to close the message
                uiwait(h);
                return;
            end
            
            
            if this.np.setWavetable(this.i32X, this.i32Y)            
            
                h = msgbox( ...
                    'The waveform has been set and nPoint is scanning!.', ...
                    'Success!', ...
                    'help', ...
                    'modal' ...
                );
            else 
                
                h = msgbox( ...
                    'There was an error.  nPoint is not scanning.', ...
                    'Error', ...
                    'warn', ...
                    'modal' ...
                );
            end
                

            % wait for them to close the message
            uiwait(h);

            
            %{
            if this.np.isActive()
                
                
            else
                
                this.np.setWavetable(i32Vx, i32Vy);
                h = msgbox( ...
                    'The waveform has been set!  nPoint is not scanning since it was not scanning before you changed the waveform.', ...
                    'Success!', ...
                    'help', ...
                    'modal' ...
                    );
                % wait for them to close the message
                uiwait(h);
            end
            %}
            
        end
        
        function ceReturn = refreshSaved(this)
            
            cPath = fullfile(this.cDir, '..', this.cSaveDir);
            ceReturn = Utils.dir2cell(cPath, 'date', 'descend');
                        
        end
    
        
    end

end
        
        
        