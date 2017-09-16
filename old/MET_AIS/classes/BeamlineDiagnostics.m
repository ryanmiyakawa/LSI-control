classdef BeamlineDiagnostics < HandlePlus
    
    %as
    
    properties (Constant)
        
        
    end
    
    properties
        
        % double
        dVx
        dVy
        dVxCorrected
        dVyCorrected
        dTime
        dFreqMin
        dFreqMax
        
        
        % UI
        uipType
        
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
        
        uieDCx
        uieDCy
        
        uieRastorData
        uieRastorTransitTime
        uilSaved
        
        
        uieFilterHz
        uieVoltsScale
        
        uibPreview
        uibSave
        
        % String
        cName
        cDir
    end
    
    
    properties (Access = private)
        
        hFigure
        hWaveformPanel
        hWaveformMultiPanel
        hWaveformDCPanel
        hWaveformRastorPanel
        hWaveformGeneralPanel
        hSavedWaveformsPanel
        hPreviewPanel
        hAxis2D
        hAxis2DSim
        hAxis1D
        hScanAxisPanel
        hScanAxis
        hCameraPanel
       
    end
    
    events
        eLowLimitChange
        eHighLimitChange
        eCalibrationChange
    end
    
    
    methods
        
        % Constructor
        function this = BeamlineDiagnostics(cName)
            this.cName = cName;
            this.init();
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
        end
        
        
        function init(this)
            
            % 2012.04.16 C. Cork instructed me to use double for all raw
            % values
            
            this.uipType =                  UIPopup('Select Waveform Type', {'Multipole', 'DC', 'Rastor'}, 'Select Waveform Type', true);
            
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
            
            this.uipMultiTimeType =         UIPopup('Select Time Type', {'Period (ms)', 'Hz (avg)'}, 'Select Time Type', true);
            this.uieMultiPeriod =           UIEdit('Period (ms)', 'd');
            this.uieMultiHz =               UIEdit('Hz (avg)', 'd');
            this.uitMultiFreqRange =        UIText('');
            
            this.uieDCx =                   UIEdit('X offset', 'd');
            this.uieDCy =                   UIEdit('Y offset', 'd');
            
            this.uieRastorData =            UIEdit('(sig_x,sig_y,ms),(sig_x,sig_y,ms),...', 'c');
            this.uieRastorTransitTime =     UIEdit('Transit Time (s)', 'd');
            
            this.uieFilterHz =              UIEdit('Filter Hz', 'd');
            this.uieVoltsScale =            UIEdit('Volts scale', 'd');
            this.uieTimeStep =              UIEdit('Time step (us)', 'd');

            this.uibPreview =               UIButton('Preview');
            this.uibSave =                  UIButton('Save');
            this.uilSaved =                 UIList('Saved Pupil Fills', cell(1,0), '', true, true, false);
            
        
            
            addlistener(this.uipType,           'eChange', @this.handleType);
            addlistener(this.uipMultiTimeType,  'eChange', @this.handleMultiTimeType);
            addlistener(this.uibPreview,        'eChange', @this.handlePreview);
            addlistener(this.uibSave,           'eChange', @this.handleSave);
            addlistener(this.uilSaved,          'eChange', @this.handleSaved);
            
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
            this.uieFilterHz.setVal(400);
            this.uieVoltsScale.setVal(10);
            this.uieTimeStep.setVal(24);    % nPoint has a 24 us control loop
            this.uieRastorData.setVal('(0.3,0.3,5),(0.5,0.5,10),(0.4,0.4,4)');
            
            this.uieDCx.setVal(0.5);
            this.uieDCy.setVal(0.3);
           
                        
        end
        
        
        function handleMultiTimeType(this, src, evt)
            
            this.msg('PupilFill.handleMultiTimeType');
            
            % Hide both UIEdits
            this.uieMultiHz.hide();
            this.uieMultiPeriod.hide();
                                    
            % Show the UIEdit based on popup type 
            switch this.uipMultiTimeType.u8Selected
                case uint8(1)
                    % Period
                    this.uieMultiPeriod.show();
                    
                case uint8(2)
                    % Hz
                    this.uieMultiHz.show();
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
            
        end
        
        
     
        
        function updateWaveforms(this)
            
            % Update dVx, dVy, dVxCorrected, dVyCorrected, dTime and update
            % plot preview
            
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
                    
                    
                    [this.dVx, this.dVy, ...
                     this.dVxCorrected, ...
                     this.dVyCorrected, ...
                     this.dTime, ...
                     this.dFreqMin, ...
                     this.dFreqMax] = PupilFillCore.getMulti( ...
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
                    [this.dVx, this.dVy, this.dVxCorrected, this.dVyCorrected, this.dTime] = PupilFillCore.getDC( ...
                        this.uieDCx.val(), ...
                        this.uieDCy.val(),...
                        this.uieVoltsScale.val(), ...
                        this.uieTimeStep.val()*1e-6 ...         
                        );
                    
                case uint8(3)
                    % Rastor
                    [this.dVx, this.dVy, this.dVxCorrected, this.dVyCorrected, this.dTime] = PupilFillCore.getRastor( ...
                        this.uieRastorData.val(), ...
                        this.uieRastorTransitTime.val(), ...
                        this.uieTimeStep.val(), ... % send in us, not s
                        this.uieVoltsScale.val(), ...
                        this.uieFilterHz.val() ...
                        );
                                        
            end
            
        end
        
        function updateAxes(this)
            
            set(this.hFigure, 'CurrentAxes', this.hAxis2D)
            plot(this.dVx, this.dVy, 'b');
            xlim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])
            ylim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])
            
            set(this.hFigure, 'CurrentAxes', this.hAxis1D)
            plot(this.dTime*1000, this.dVx, 'r', this.dTime*1000, this.dVy,'b')
            xlabel('Time [ms]')
            ylabel('Volts')
            legend('vx','vy')
            xlim([0 max(this.dTime*1000)])
            ylim([-this.uieVoltsScale.val() this.uieVoltsScale.val()])
            
        end
        
        
        

        
        function savePupilFill(this, cName)
            
            cPath = sprintf('%s../pupilfill/%s.mat', ...
                this.cDir, ...
                cName ...
                );
            
            % Create a nested recursive structure of all public properties
            
            s = this.saveClassInstance();
            
            % Remove uilSaved from the structure.  We don't want to
            % overwrite the list of available prescriptions when one is
            % loaded
            
            s = rmfield(s, 'uilSaved');

            
            % Save
            save(cPath, 's');
            
            % If the name is not already on the list, append it
            if isempty(strmatch(cName, this.uilSaved.ceOptions, 'exact'))
                this.uilSaved.append(cName);
            end
            
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
            
           
        end
        
        function buildScanAxis(this)
            
            dWidth = 700;
            
            this.hScanAxisPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Saved Waveforms',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([100 100 dWidth 500], this.hFigure) ...
            );
			drawnow;
        
            
            
        end
        
 
        
        
        
        function build(this)
            
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  this.cName,...
                'Position', [20 50 1250 720],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.cb ...
                );
            
            drawnow;
            
            this.buildScanAxis();
            
  
        end
        
        function cb(this, src, evt)
            
            switch src
                case this.hFigure
                    this.closeRequestFcn();
                    
            end
            
        end
        
        function handleUI(this, src, evt)
            
                     
            switch src
                       
            end
            
        end
        
        
        function closeRequestFcn(this)
            this.msg('AxisSetup.closeRequestFcn()');
            delete(this.hFigure);
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
        

        
        
 
        
        function buildCameraPanel(this)
            
            % Panel
            this.hCameraPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Camera overlay with sigma annular lines',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([720 300 400 350], this.hFigure) ...
            );
			drawnow;
            
        end
        
        
    end

end
        
        
        