classdef ReticlePick < HandlePlus
%RETICLEPICK Class that allows to pick a reticle configuration
%
% See also RETICLEPICKPANEL, PUPILFILL, HEIGHTSENSOR    
    
    properties (Constant)
        d_FIELD_WIDTH = 1000;       % um
        d_FIELD_HEIGHT = 150;       % um
        d_FIELD_X_PITCH = 2000;     % um
        d_FIELD_Y_PITCH = 300;      % um
        d_ROWS = 9;
        d_COLS = 5;
        
        d_PxScale = 400/1000;
        
        bDispLoadSave = 0;
        dEDITHEIGHT = 30;
        dLABELHEIGHT = 15;
        dEditPad = 10;
        dPanelTopPad = 20;
        dPanelBotPad = 10;
    end
    
    properties (SetAccess = private)
    end
    
    properties (Access = private)
        cName   % name identifier
        cDir    % class directory
        
        hFigure
        hAxes
        hImage
        hCrosshairCircles
        hCrosshairLine1
        hCrosshairLine2
        hCrosshairLine3
        hCrosshairLine4
        
        dCrosshairXOffset   % px offset to center of plot.  Right in GUI is +
        dCrosshairYOffset   % px offset to center of plot.  Up in GUI is +      
    end
    
    properties  
        uipReticle
        uipField
        
        uieXOffset
        uieYOffset
        uibZero
        
        dXOffset            % x offset (um) to get light centered over field target
        dYOffset            % y offset (um) to get light centered over field target 
        
        dX                  % x position of stage including field + offset (um)
        dY                  % y position of stage including field + offset (um)
        
        sData               % parse_json(JSON) JSON returned from server
    end
    
    events
    end
    
    methods (Access = private)
    end
    
    methods
        
        function this = ReticlePick(cName)
        %RETICLEPICK Class constructor
        %   rp = ReticlePick('name')
        %
        % See also INIT, BUILD, DELETE
            
            this.dCrosshairXOffset = 0;
            this.dCrosshairYOffset = 0;
            this.cName = cName;
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
    
            this.init();
        end
                
        
        function init(this)
        %INIT Initializes he Reticle Pick class
        %   ReticlePick.init()  
        %    read and parse JSON with reticle/field data.  Eventually this
        %    will be a URL request that returns JSON. For now I will read
        %    a text file with JSON
        %
        % See also RETICLEPICK, BUILD, DELETE
            
            this.sData = parse_json(fileread(sprintf('%s../reticles.json', this.cDir)));
            this.sData = this.sData{1}; % has to do with parse_json

        
            this.uipReticle = UIPopup( ...
                'Reticle', ...
                this.getReticleOptions(), ...
                'Reticle', ...
                true ...
                );
            
            
            this.uipField = UIPopup( ...
                'Field', ...
                this.getFieldOptions(), ...
                'Field', ...
                true ...
                );
            
            this.uieXOffset = UIEdit('X offset (um)', 'd', true);
            this.uieYOffset = UIEdit('Y offset (um)', 'd', true);
            this.uibZero = UIButton('Re-zero');
            
            this.uieXOffset.setVal(0);
            this.uieYOffset.setVal(0);
            
            
            
            addlistener(this.uieXOffset, 'eChange', @this.handleXOffset);
            addlistener(this.uieYOffset, 'eChange', @this.handleYOffset);
            addlistener(this.uibZero, 'eChange', @this.handleZero);
            addlistener(this.uipReticle, 'eChange', @this.handleReticle);
            addlistener(this.uipField, 'eChange', @this.handleField);
        end
        
        
        function build(this)
        %BUILD Builds the UI element in a  separate figure
        %   ReticlePick.build()
        %
        % See also RETICLEPICK, INIT, DELETE
        
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  this.cName,...
                'Position', [100 100 500 400],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleFigure, ...
                'WindowButtonMotionFcn', @this.handleMouseMotion ...
                );
                % 'Pointer', 'fullcrosshair' ...
                % );
            
            drawnow;
                        
            this.uipReticle.build(this.hFigure, 10, 10, 200, 40);
            this.uipField.build(this.hFigure, 210, 10, 200, 40);
            
            % The field is 1000 um x 150 mm.  Use 400 px x 60 px (same
            % aspect ratio) for the plot
            dWidth = this.d_PxScale*this.d_FIELD_WIDTH;
            dHeight = this.d_PxScale*this.d_FIELD_HEIGHT;
            
            this.hAxes = axes(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Position', Utils.lt2lb([10 60 dWidth dHeight], this.hFigure),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'XTick',[],...
                'YTick',[],...
                'XColor','white',...
                'YColor','white',...
                'HandleVisibility','on', ...
                'XLimMode', 'manual',...
                'YLimMode', 'manual', ...
                'ZLimMode', 'manual', ...
                'ALimMode', 'manual', ...
                'CLimMode', 'manual', ...
                'ZLimMode', 'manual', ...
                'ButtonDownFcn', @this.handleAxesClick ...
                );
            
            dTop = 135;
            
            this.uieXOffset.build(this.hFigure, 10, dTop, 100, Utils.dEDITHEIGHT);
            this.uieYOffset.build(this.hFigure, 110, dTop, 100, Utils.dEDITHEIGHT);
            this.uibZero.build(this.hFigure, 220, dTop, 100, Utils.dEDITHEIGHT);
            
            % The ButtonDownFunction listener registers clicks on the axes
            % but if you add anything handles on top of the axes (for
            % example with plot(...) or image(...), you also need to add
            % the click listener to those handles since they will be "on
            % top" of the axes.
        end
        
        
        function handleReticle(this, src, evt)
            
            this.msg('ReticlePick.handleReticle()');
            this.uipField.ceOptions = this.getFieldOptions();
            
        end
        
        
        function handleField(this, src, evt)
            
            this.msg('ReticlePick.handleField()');
            
            % Update field plot/image
            
            u8R = this.uipReticle.u8Selected;
            u8F = this.uipField.u8Selected;
            
            cPath = sprintf('%s../assets/reticles/%s/%1.0f%1.0f.jpg', ...
                this.cDir, ...
                this.sData.reticles{u8R}.name, ... 
                this.sData.reticles{u8R}.fields{u8F}.row, ...
                this.sData.reticles{u8R}.fields{u8F}.col ...
                );
            
            if exist(cPath, 'file') == 2
                
                dImg = imread(cPath);
                set(this.hFigure, 'CurrentAxes', this.hAxes);
                this.hImage = imagesc(dImg);
                % axis('image');
                % colormap('gray');
                set(this.hAxes, 'xtick', [], 'ytick', [])
                
                % Make sure the image handle has the ButtonDown listener
                set(this.hImage, 'ButtonDownFcn', @this.handleAxesClick);
                
            else
                this.msg(sprintf('ReticlePick.handleField() %s oes not exist', cPath));
            end
            
            % Update dX, dY, dXOffset, dYOffset
            
            this.updatePos();
            this.updateCrosshair();
            
            
        end
        
        
        function handleFigure(this, src, evt)
            
            delete(this.hFigure);
            
        end
        
        
        function cReticles = getReticleOptions(this)
            
            % Return a cell array of chars with the name of each reticle
            
            cReticles = cell(0);
            for k = 1:length(this.sData.reticles)
                cReticles{k} = this.sData.reticles{k}.name;
            end

        end
        
        function cFields = getFieldOptions(this)
            
           % Based on the value of the reticle popup, return a cell array
           % of char with the name of each field in the selected reticle
           
           cFields = cell(0);
           for k = 1:length(this.sData.reticles{this.uipReticle.u8Selected}.fields)
               cFields{k} = this.sData.reticles{this.uipReticle.u8Selected}.fields{k}.name;
           end
            
        end
        
        function handleAxesClick(this, src, evt)
            
            % this.msg('ReticlePick.handleAxesClick()');
            % get(this.hAxes, 'CurrentPoint')
            
            % Update crosshair
            
            dCursor = get(this.hFigure, 'CurrentPoint');     % [left bottom]
            dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
           
            dCursorLeft =    dCursor(1);
            dCursorBottom =  dCursor(2);
           
            dAxesLeft =      dAxes(1);
            dAxesBottom =    dAxes(2);
            dAxesWidth =     dAxes(3);
            dAxesHeight =    dAxes(4);
            
            
            this.dCrosshairXOffset = dCursorLeft - dAxesLeft - dAxesWidth/2;         % px
            this.dCrosshairYOffset = dCursorBottom - dAxesBottom - dAxesHeight/2;    % px           
            this.updateCrosshair();
            
            
            this.updatePos();
            
            
        end
        
        function updateCrosshair(this)
            
            % Remove previous crosshair
            
            if ishandle(this.hCrosshairCircles)
                delete([ ...
                    this.hCrosshairCircles ...
                    this.hCrosshairLine1 ...
                    this.hCrosshairLine2 ...
                    this.hCrosshairLine3 ...
                    this.hCrosshairLine4]);
            end
            
            
            dWidth = this.d_PxScale*this.d_FIELD_WIDTH;
            dHeight = this.d_PxScale*this.d_FIELD_HEIGHT;
            
            dR1 = 5;
            dR2 = 10;
            
            dTime = linspace(0,2*pi,50);
            dX1 = dR1*cos(dTime) + dWidth/2 + this.dCrosshairXOffset;
            dY1 = dR1*sin(dTime) + dHeight/2 - this.dCrosshairYOffset;
            dX2 = dR2*cos(dTime) + dWidth/2 + this.dCrosshairXOffset;
            dY2 = dR2*sin(dTime) + dHeight/2 - this.dCrosshairYOffset;
            dX = [dX1 dX2];
            dY = [dY1 dY2];
            
            mult_out = 1.5;
            mult_in = 0.5;
           
            % Line color, line width

            c1 = .3;
            c2 = .1;
            c3 = .4;
            linewidth = 1;
            
            set(this.hFigure, 'CurrentAxes', this.hAxes);
            
            % Inner / outer circles
            this.hCrosshairCircles = line( ...
                dX, ...
                dY, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth ...
                );
            
            % Cross
            this.hCrosshairLine1 = line( ...
                [-dR2*mult_out -dR1*mult_in] + dWidth/2 + this.dCrosshairXOffset, ...
                [0 0] + dHeight/2 - this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth ...
                );
            
            this.hCrosshairLine2 = line( ...
                [dR2*mult_out dR1*mult_in] + dWidth/2 + this.dCrosshairXOffset, ...
                [0 0] + dHeight/2 - this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth ...
                );
            
            this.hCrosshairLine3 = line( ...
                [0 0] + dWidth/2 + this.dCrosshairXOffset, ...
                [dR2*mult_out dR1*mult_in]  + dHeight/2 - this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth ...
                );
            
            this.hCrosshairLine4 = line( ...
                [0 0] + dWidth/2 + this.dCrosshairXOffset, ...
                -[dR2*mult_out dR1*mult_in]  + dHeight/2 - this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth ...
                );
            
        end
        
        
        function handleMouseMotion(this, src, evt)
            
           % this.msg('ReticlePic.handleMouseMotion()');
           
           % If the mouse is inside the axes, turn the cursor into a
           % crosshair, else make sure it is an arrow
           
           dCursor = get(this.hFigure, 'CurrentPoint');     % [left bottom]
           dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
           
           dCursorLeft =    dCursor(1);
           dCursorBottom =  dCursor(2);
           
           dAxesLeft =      dAxes(1);
           dAxesBottom =    dAxes(2);
           dAxesWidth =     dAxes(3);
           dAxesHeight =    dAxes(4);
           
           if   dCursorLeft > dAxesLeft && ...
                dCursorLeft < dAxesLeft + dAxesWidth && ...
                dCursorBottom > dAxesBottom && ...
                dCursorBottom <= dAxesBottom + dAxesHeight
            
                
                if strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'fullcrosshair')
                end
                
            
           else
           
                if ~strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'arrow')
                end
                
           end

        end
        
        
        function handleZero(this, src, evt)
            
            this.dCrosshairXOffset = 0;
            this.dCrosshairYOffset = 0;
            
            this.updatePos();
            this.updateCrosshair();
        end
        
        function handleXOffset(this, src, evt)
            
            % Update crosshair
            this.dCrosshairXOffset = -this.uieXOffset.val()*this.d_PxScale;
            this.updateCrosshair();
        end
        
        function handleYOffset(this, src, evt)
            
            % Update crosshair
            this.dCrosshairYOffset = -this.uieYOffset.val()*this.d_PxScale;
            this.updateCrosshair();

        end
        
        
        function updatePos(this)
        %UPDATEPOS Updates dX, dY, dXOffset, dYOffset
        %   ReticlePick.updatePos()
            
            % If we assume that the stage axis is oriented such that when
            % you look at the multilayer side of the reticle as you hold it
            % in your hand (as you are the photons), the right side of the
            % mask is positive x, the left side is negative x
            
            this.uieXOffset.setVal(-this.dCrosshairXOffset/this.d_PxScale);
            this.uieYOffset.setVal(-this.dCrosshairYOffset/this.d_PxScale);
            

            % Compute the stage position.  Assume that 0,0 is the center of
            % the reticle.  I will need to program some offsets here.  This
            % will assume that the middle of the fields area is in the
            % center of the reticle
            
            u8R = this.uipReticle.u8Selected;
            u8F = this.uipField.u8Selected;
            
            dActiveRow = this.sData.reticles{u8R}.fields{u8F}.row;
            dActiveCol = this.sData.reticles{u8R}.fields{u8F}.col;
            
            % X
            if this.d_COLS == floor(this.d_COLS/2)
                % even
                % space is in the middle, need to subtract 0.5 of the pitch
                this.dX = (dActiveCol - this.d_COLS/2 - 0.5)*this.d_FIELD_X_PITCH + this.uieXOffset.val();
                
            else
                % odd.  easy since a field is centered in the middle
                this.dX = (dActiveCol - ceil(this.d_COLS/2))*this.d_FIELD_X_PITCH + this.uieXOffset.val();
            end
            
            % Y
            if this.d_ROWS == floor(this.d_ROWS/2)
                % even
                % space is in the middle, need to subtract 0.5 of the pitch
                this.dY = (dActiveRow - this.d_ROWS/2 - 0.5)*this.d_FIELD_Y_PITCH + this.uieYOffset.val();
                
            else
                % odd.  easy since a field is centered in the middle
                this.dY = (dActiveRow - ceil(this.d_ROWS/2))*this.d_FIELD_Y_PITCH + this.uieYOffset.val();
            end
 
        end

    end  %methods
end % classdef