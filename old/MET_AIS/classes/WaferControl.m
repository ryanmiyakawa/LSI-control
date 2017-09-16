classdef WaferControl < HandlePlus
    
    % wc
    
    properties (Constant)
       
        dFieldWidth     = 200e-6
        dFieldHeight    = 30e-6
        dMinV           = 0.5      % For HSV color (min transparency)
        dWidth          = 1280
        dHeight         = 780
    end
    
	properties
        
        wcs
        wfs
        hs
        lExposing       = false
       
    end
    
    properties (SetAccess = private)
        
        hFigure
        hOverlay
        
    end
    
    properties (Access = private)
                      
        cl
        zpa
        hTrack
        hCarriage
        hIllum
        hWafer
        hFEMPreview
        hExposures
        
        dDelay = 0.1
        dFieldX
        dFieldY
        
        dXFEMPreview            % size: [focus x dose] of X positions
        dYFEMPreview            % size: [focus x dose] of Y positions
                                % these values are updated whenever the FEM
                                % grid changes
        
        
        % Store exposure data in a cell.  Each item of the cell is an array that 
        % contains:
        %
        %   dX
        %   dY
        %   dDoseNum        the dose shot num
        %   dFEMDoseNum
        %   dFocusNum       the focus shot num
        %   dFEMFocusNum
        %
        % The dose/focus data is used for color/hue 
        % As each exposure finishes, an array is pushed to to this cell
        
        ceExposure  
        
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = WaferControl(cl)
            
            this.cl = cl;
            this.init();
            
        end
        
                
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Wafer Control',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            % set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            this.hs.build(this.hFigure, dPad, dTop);
            this.wcs.build(this.hFigure, dPad, dTop + dPad + this.hs.dHeight);
            this.wfs.build(this.hFigure, dPad, dTop + dPad + this.hs.dHeight + dPad + this.wcs.dHeight);
            this.zpa.build(this.hFigure, 330, dTop);
            
            % Build heirarchy of hggroups/hgtransforms for drawing
            
            %{
            this.hTrack         = hggroup('Parent', this.zpa.hHggroup);
            this.hCarriage      = hgtransform('Parent', this.zpa.hHggroup);
            this.hWafer         = hggroup('Parent', this.hCarriage);
            this.hFEMPreview    = hggroup('Parent', this.hWafer);
            this.hFEM           = hggroup('Parent', this.hWafer);
            this.hIllum         = hggroup('Parent', this.zpa.hHggroup);
            
            this.drawTrack(); 
            this.drawCarriage();
            this.drawWafer(); 
            this.drawIllum(); 
            this.drawFEM(); 
            this.drawFEMPreview(); 
            %}
            
            % For some reason when I build the hg* instances as shown above
            % and then add content to them, the stacking order is messed up
            % (the wafer is not on top of the carriage) but when I do it
            % this way it works. 
            
           
            this.hTrack         = hggroup('Parent', this.zpa.hHggroup);
            this.drawTrack(); 
            
            this.hCarriage      = hgtransform('Parent', this.zpa.hHggroup);
            this.drawCarriage(); 
            
            this.hWafer         = hggroup('Parent', this.hCarriage);
            this.drawWafer();

            this.hFEMPreview    = hggroup('Parent', this.hWafer);
            this.drawFEMPreview();
            
            this.hExposures     = hggroup('Parent', this.hWafer);
            this.drawExposures();
            
            this.hIllum         = hggroup('Parent', this.zpa.hHggroup);
            this.drawIllum();
            
            this.hOverlay       = hggroup('Parent', this.zpa.hHggroup);
            
            
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
            
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
        end
           
        function updateFEMPreview(this, dX, dY)
            
            % dX    (double)    size:[focus x dose] 
            % dY    (double)    size:[focus x dose] 
            %
            %   -1  0   1 
            %   -1  0   1
            %   -1  0   1
            %
            %   2   2   2
            %   1   1   1
            %   0   0   0
            
            this.dXFEMPreview = dX;
            this.dYFEMPreview = dY;
            this.drawFEMPreview();
            
        end
        
                
        function addExposure(this, dData)
            
            % See ceFEM property for more info
            % dData size:[1x6]
            %   dX
            %   dY
            %   dDoseNum        the dose shot num
            %   dFEMDoseNum
            %   dFocusNum       the focus shot num
            %   dFEMFocusNum  
            
            this.ceExposure{length(this.ceExposure) + 1} = dData;
            this.drawExposure(dData);
                        
        end
        
                
        function purgeExposures(this)
            
            this.ceExposure = {};
            Utils.deleteChildren(this.hExposures);                
            
        end
        
        function purgeOverlay(this)
            
            Utils.deleteChildren(this.hOverlay);                
            
        end
                
        
        function handleClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            hHgtf = makehgtform('translate', [this.wcs.hioX.dValCal this.wcs.hioY.dValCal 0]);
            if ishandle(this.hCarriage);
                set(this.hCarriage, 'Matrix', hHgtf);
            end
            
            
        end
        
        
        function fakeExposures(this)
            
            % For testing
            
            dX          = 0.4e-3;
            dY          = -0.1e-3;
            dX0         = 0e-3;
            dY0         = 1e-3;
            dDoseNum    = 11;
            dFocusNum   = 9;
            
            for focus = 1:dFocusNum
                for dose = 1:dDoseNum
                    this.addExposure([dX0 + (dose - 1)*dX, dY0 + (focus - 1)*dY, dose, dDoseNum, focus, dFocusNum]);
                end
            end
        end
        
        
        function set.lExposing(this, lVal)
            
            if lVal
                if ~this.lExposing
                    % Changinf form not exposing to exposing
                    this.drawOverlay();
                end
            else
                this.purgeOverlay();
            end
                
            this.lExposing = lVal;
            
        end
        
            

    end
    
    methods (Access = private)
        
        function init(this)
            
            this.wcs    = WaferCoarseStage(this.cl);
            this.wfs    = WaferFineStage(this.cl);
            
            %{
            this.wcs = MotionControl( ...
                this.cl, ...
                'Wafer-Coarse-Stage', ...
                {true, true, true, true, true, false}, ...
                true);
            
            
            this.wfs = MotionControl( ...
                this.cl, ...
                'Wafer-Fine-Stage', ...
                {false, false, true, false, false, false}, ...
                true);   
            %}
            
            this.wcs.hioX.setup.uieStepRaw.setVal(100e-6);
            this.wcs.hioY.setup.uieStepRaw.setVal(100e-6);
            
                     
            this.wfs.hioZ.setup.uieStepRaw.setVal(100e-9);
            
            
            this.hs     = HeightSensor(this.cl);
            this.zpa    = ZoomPanAxes(-1, 1, -1, 1, 890, 690, 500);
            this.cl.add(@this.handleClock, this.id(), this.dDelay);

        end
        
        
        function handleCloseRequestFcn(this, src, evt)
            
            delete(this.hFigure);
            % this.saveState();
            
        end
        
        function drawTrack(this)
            
           
           % (L)eft (R)ight (T)op (B)ottom
           
           % Base is 1500 x 500 perfectly centered
           
           dL = -750e-3;
           dR = 750e-3;
           dT = 250e-3;
           dB = -250e-3;
           
           patch( ...
               [dL dL dR dR], ...
               [dB dT dT dB], ...
               [0.5, 0.5, 0.5], ...
               'Parent', this.hTrack, ...
               'EdgeColor', 'none');
           
           % Track
           
           dL = -1450e-3/2;
           dR = 1450e-3/2;
           dT = 200e-3;
           dB = -200e-3;
           
           patch( ...
               [dL dL dR dR], ...
               [dB dT dT dB], ...
               [0.6, 0.6, 0.6], ...
               'Parent', this.hTrack, ...
               'EdgeColor', 'none');
            
        end
        
        function drawIllum(this)
            
            dL = -this.dFieldWidth/2;
            dR = this.dFieldWidth/2;
            dT = this.dFieldHeight/2;
            dB = -this.dFieldHeight/2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb(0.9, 1, 1), ...
                'Parent', this.hIllum, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
            );
        
            uistack(hPatch, 'top');
        end
        
        function drawCarriage(this)
            

            dL = -200e-3;
            dR = 200e-3;
            dT = 200e-3;
            dB = -200e-3;

            
            % Base square
            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                [0.4, 0.4, 0.4], ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
            

            % Circular part without the triangle-ish thing
                       
            dTheta = linspace(0, 2*pi, 100);
            dR = 175e-3;
          
            patch( ...
                dR*sin(dTheta), ...
                dR*cos(dTheta), ...
                [0.5, 0.5, 0.5], ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
            
            % The part in 60-degree archs with 60-degree flats
            
            dDTheta = 1/360;
            dTheta = [0/180:dDTheta:30/180, ...
                90/180:dDTheta:150/180, ...
                210/180:dDTheta:270/180, ...
                330/180:dDTheta: 360/180]*pi;
            
            % dR = 173e-3;
            dTheta = dTheta - 30*pi/180;
            
            hPatch = patch( ...
                dR*sin(dTheta), ...
                dR*cos(dTheta), ...
                [0.3, 0.3, 0.3], ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
                        
        end
        
        function drawWafer(this)
            
            dDTheta = 1/360;            
            dTheta = [0/180:dDTheta:70/180,...
                110/180:dDTheta:170/180,...
                190/180:dDTheta:360/180]*pi;
            
            
            dR = 150e-3;
            dTheta = dTheta - 90*pi/180;
            
            hPatch = patch( ...
                dR*sin(dTheta), ...
                dR*cos(dTheta), ...
                [0, 0, 0], ...
                'Parent', this.hWafer, ...
                'EdgeColor', 'none');
            
            uistack(hPatch, 'top');
                        
        end
        
        
        
        function drawFEMPreview(this)
            
            if ishandle(this.hFEMPreview)
                Utils.deleteChildren(this.hFEMPreview);
            else
                return;
            end
                           
            [dFocusNum, dDoseNum] = size(this.dXFEMPreview);
                        
            for row = 1:dFocusNum
                for col = 1:dDoseNum
                
                    dL = this.dXFEMPreview(row, col) - this.dFieldWidth/2;
                    dR = this.dXFEMPreview(row, col) + this.dFieldWidth/2;
                    dT = this.dYFEMPreview(row, col) + this.dFieldHeight/2;
                    dB = this.dYFEMPreview(row, col) - this.dFieldHeight/2;

                    patch( ...
                        [dL dL dR dR], ...
                        [dB dT dT dB], ...
                        [1, 1, 1], ...
                        'Parent', this.hFEMPreview, ...
                        'FaceAlpha', 0.2, ...
                        'EdgeColor', 'none' ...
                    );
                    % 'LineWidth', 2, ...

                end
            end
        end
        
        function drawExposures(this)
                        
            for k = 1:length(this.ceExposure)
                this.drawExposure(this.ceExposure{k});
            end
            
        end
        
        function drawExposure(this, dData)
            
            if isempty(this.hFigure) || ...
                ~ishandle(this.hFigure)
                return
            end
            
            if isempty(this.hExposures) || ...
                ~ishandle(this.hExposures)
                return
            end
            
            % (H)ue is focus
            % (V)alue is dose
            
            dH = (dData(5) - 1)/dData(6); 
            dV = this.dMinV + (1 - this.dMinV)*dData(3)/dData(4);

            dL = dData(1) - this.dFieldWidth/2;
            dR = dData(1) + this.dFieldWidth/2;
            dT = dData(2) + this.dFieldHeight/2;
            dB = dData(2) - this.dFieldHeight/2;

            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb([dH, 1, dV]), ...
                'Parent', this.hExposures, ...
                'EdgeColor', 'none' ...
            );
        end
        
        
        function drawOverlay(this)
            
            this.msg('drawOverlay');
            
            if  isempty(this.hFigure) || ...
                ~ishandle(this.hFigure)
                return
            end
            
            if isempty(this.hOverlay) || ...
                ~ishandle(this.hOverlay)
                return
            end
            
            dL = -1;
            dR = 1;
            dT = 1;
            dB = -1;
            
            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb(0.9, 1, 1), ...
                'Parent', this.hOverlay, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
            );
            
        end
        
        
        
    end % private
    
    
end