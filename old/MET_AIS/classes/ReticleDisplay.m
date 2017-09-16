classdef ReticleDisplay < HandlePlus
    
    % zpa
    
	properties
                
        dXPan
        dYPan
        dZoom
                
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        hPanel
        hSliderZoom
        hSliderXPan
        hSliderYPan
        hAxes
        hCenterText
        hZoomText
        
        % Use units of meters.  The display area will be the entire
        % vacuum chamber which is 2 m x 2 m with (0, 0) at the center of 
        % the chamber.  You can think of dXMin, dXMax, etc as the bounds of
        % the canvas that you want to display within an axis that is 
        % dAxesWidth px wide and dAxesHeight px tall
        
        % When the zoom is 1, the canvas dimension (X vs Y) that is largest
        % needs to fill the dimension of the axis that is largest.  Since 
        % the axis will always display 1:1 in (x, y), this means the limits
        % of one direction will need to be scaled by the aspect ratio of
        % the plot
        
        dXMin = -1
        dXMax = 1
        dYMin = -1
        dYMax = 1
                
        dZoomMin = 1
        dZoomMax = 5
        
        dAxesWidth = 1000
        dAxesHeight = 500
        
        dXRange         % set in init()
        dYRange         % set in init()
        dAxesAR         % set in init()
        dCanvasAR       % set in init()
        
        dSliderPad = 10
        dSliderThick = 15
                        
    end
    
        
    events
        
        eConnect
        eDisconnect
        
    end
    

    
    methods
        
        
        function this = ReticleDisplay()
            
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dAxesWidth this.dAxesHeight], hParent) ...
            );
        
            % 'Title', 'Reticle Coarse Stage',...

        
			drawnow;
            
            % The axes fills the entire panel.  Sliders are "on top" of the
            % ases
            
            this.hAxes = axes(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Position', Utils.lt2lb([0 0 this.dAxesWidth this.dAxesHeight], this.hPanel), ...
                'XTick', [], ...
                'YTick', [], ...
                'XColor', 'white',...
                'YColor', 'white',...
                'Color', [0.3,0.3,0.3],...
                'DataAspectRatio', [1 1 1],...
                'PlotBoxAspectRatio', [this.dAxesWidth this.dAxesHeight 1],...
                'HandleVisibility', 'on' ...
            );
            
            
            this.hSliderXPan = uicontrol(...
                'Parent', this.hPanel,...
                'Style', 'slider', ...
                'Min', this.dXMin, ...
                'Max', this.dXMax, ...
                'Value', (this.dXMax - this.dXMin)/2, ...
                'SliderStep', [0.1 0.1],...
                'Position', Utils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dAxesHeight - 2*this.dSliderPad - 2*this.dSliderThick ...
                    this.dAxesWidth - 2*this.dSliderPad ...
                    this.dSliderThick], this.hPanel) ...
            );
        
        
            this.hSliderYPan = uicontrol(...
                'Parent', this.hPanel,...
                'Style', 'slider', ...
                'Min', this.dYMin, ...
                'Max', this.dYMax, ...
                'Value', (this.dYMax - this.dYMin)/2, ...
                'SliderStep', [0.1 0.1],...
                'Position', Utils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dSliderPad ...
                    this.dSliderThick ...
                    this.dAxesHeight - 4*this.dSliderPad - 2*this.dSliderThick], this.hPanel) ...
            );
        

            this.hSliderZoom = uicontrol(...
                'Parent', this.hPanel, ...
                'Style', 'slider', ...
                'Min', this.dZoomMin, ...
                'Max', this.dZoomMax, ...
                'Value', 1, ...
                'SliderStep', [0.1 0.1],...
                'Position', Utils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dAxesHeight - this.dSliderPad - this.dSliderThick ...
                    this.dAxesWidth - 2*this.dSliderPad ...
                    this.dSliderThick], this.hPanel) ... 
            ); 
        
            %{
            this.hCenterText = uicontrol(...
                'Parent',this.hParent,...
                'Units','pixels',...
                'HorizontalAlignment','left',...
                'Position',[this.xpos ...
                    Utils.uicontrolY(this.ypos,this.hParent,15) ...
                    40 ...
                    15 ...
                 ],...
                'String','Center',...
                'Style','text');
            
            this.hZoomText = uicontrol(...
                'Parent',this.hParent,...
                'Units','pixels',...
                'HorizontalAlignment','left',...
                'Position',[this.xpos ...
                    Utils.uicontrolY(this.ypos+20,this.hParent,15) ...
                    40 ...
                    15 ...
                ],...
                'String','Zoom',...
                'Style','text');
            %}
                        
            
            lh2 = addlistener(this.hSliderXPan, 'ContinuousValueChange', @this.handleSliderXPan);
            lh3 = addlistener(this.hSliderYPan, 'ContinuousValueChange', @this.handleSliderYPan);
            lh1 = addlistener(this.hSliderZoom, 'ContinuousValueChange', @this.handleSliderZoom);
            
            
            % set(this.hPanel, 'CurrentAxes', this.hAxes)
            
            dt = pi/1000;
            t = [0*pi/180:dt:70*pi/180,...
                110*pi/180:dt:170*pi/180,...
                190*pi/180:dt:360*pi/180];
            
            % Rotate 90-degrees
            
            d = 0.5; % diameter
            patch(d/2*sin(t), d/2*cos(t), [0.1, 0.1, 0.1]);
            patch( ...
                0.95*[this.dXMin this.dXMin this.dXMax this.dXMax], ...
                0.1*[this.dYMin this.dYMax this.dYMax this.dYMin], ...
                [0.3, 0.3, 0.3] ...
                );
                
            
            
        end
        
        
        
                
        
        %% Destructor
        
        function delete(this)
            
            
        end
        
                               
        function show(this)
    
            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
            end
            
        end
        
        
        
        function this = set.dZoom(this, dVal)
                        
            % The stage starts out having limits defined by the range of
            % the stage motor(s).  At zoom = 1, the display shows the
            % entire area that the state motors can reach.  As we zoom in,
            % we change the viewed range by a factor 'zoom'.  The 'right
            % amount of zoom' is simply achieved by setting the xlim and
            % ylim values to the motor limits scaled by the zoom valuel.
            % However, this would always keep the geometric center of the
            % oMotorStage limits in the center of the axis - which is not
            % what we want to do.  We want to keep the current center (pan)
            % position as the center position while zooming.  So we first
            % find the center position using the average of the current
            % limits in x and y and then shift the newly scaled (zoomed)
            % limits by the current center position. 
        
           
            dXLimits = get(this.hAxes, 'Xlim')
            dYLimits = get(this.hAxes, 'Ylim')
            
            dXCenter = (dXLimits(1) + dXLimits(2))/2
            dYCenter = (dYLimits(1) + dYLimits(2))/2
            
            
            if (this.dAxesAR > this.dCanvasAR)
                
                fprintf('dAxisAR > dCanvasAR');
                
                % At zoom 1, the x direction of the canvas fills the axis
                % and there is canvas content hidden in the y direction
                % above and below the axis limits
                
                
                dXMin = dXCenter - this.dXRange/2/dVal;
                dXMax = dXCenter + this.dXRange/2/dVal;
                
                dYMin = dYCenter - this.dXRange/2/dVal/this.dAxesAR;
                dYMax = dYCenter + this.dXRange/2/dVal/this.dAxesAR;
                
                                
            else
                
                % At zoom 1, the y direction of the canvas fills the axis
                % and there is canvas content hidden in the x direction to
                % the left and right of the axis
                
                
                dYMin = dYCenter - this.dYRange/2/dVal;
                dYMax = dYCenter + this.dYRange/2/dVal;
                
                dXMin = dXCenter - this.dYRange/2/dVal*this.dAxesAR;
                dXMax = dXCenter + this.dYRange/2/dVal*this.dAxesAR;
                
            end

            
            %{
            dXMin = dXCenter - dXRange/2/dVal
            dXMax = dXCenter + dXRange/2/dVal
            
            dYMin = dYCenter - dYRange/2/dVal
            dYMax = dYCenter + dYRange/2/dVal
            %}
            
            
            if (dXMin < this.dXMin)
                dXMin = this.dXMin;
                fprintf('dXMin < this.dXMin');
                
                
                if (this.dAxesAR > this.dCanvasAR)
                    dXMax = this.dXMin + this.dXRange/dVal;
                else
                    dXMax = this.dXMin + this.dYRange/dVal*this.dAxesAR;
                end
                    
            end
            
            if (dXMax > this.dXMax)
                fprintf('dXMax > this.dXMax');
                dXMax = this.dXMax;
                
                 if (this.dAxesAR > this.dCanvasAR)
                    dXMin = this.dXMax - this.dXRange/dVal;
                 else
                    dXMin = this.dXMax - this.dYRange/dVal*this.dAxesAR;
                 end
            end
            
            if (dYMin < this.dYMin)
                fprintf('dYMin < this.dYMin');
                dYMin = this.dYMin;
                
                if (this.dAxesAR > this.dCanvasAR)
                    dYMax = this.dYMin + this.dXRange/dVal/this.dAxesAR;
                else
                    dYMax = this.dYMin + this.dYRange/dVal;
                end
                
            end
            
            if (dYMax > this.dYMax)
                fprintf('dYMax > this.dYMax');
                dYMax = this.dYMax;
                
                if (this.dAxesAR > this.dCanvasAR)
                    dYMin = this.dYMax - this.dXRange/dVal/this.dAxesAR;
                else
                    dYMin = this.dYMax - this.dYRange/dVal;
                end
                
            end
            
            % Set the limits
            
            set(this.hAxes, 'Xlim', [dXMin dXMax]);
            set(this.hAxes, 'Ylim', [dYMin dYMax]);
            
            % If we zoom out and hit the stage limit, the center of the view will
            % be at a different location on the stage.  We will update the
            % value of the xpan slider to reflect this change.
            
            set(this.hSliderXPan, 'Value', (dXMin + dXMax)/2);
            set(this.hSliderYPan, 'Value', (dYMin + dYMax)/2);
            % this.dXPan = (dXMin + dXMax)/2;
            this.dZoom = dVal;
                                    
        end
        
        function this = set.dXPan(this, dVal)
            
            % The pan slider has a value of lowCAL on the left and
            % increases linearly to a value of highCAL on the right. As we
            % pan, we want to keep the zoom level fixed.  This means we
            % need to make sure the xlim and ylim properties have the same
            % range (max-min) before and after the pan.
            
            
            dLimits = get(this.hAxes, 'Xlim');
            dRange = dLimits(2) - dLimits(1);
            
            % Set low and high limits based on pan value and range
            % (determined by zoom level)
            
            dLimMin = dVal - dRange/2;
            dLimMax = dVal + dRange/2;
            
                        
            % Check that xmin/xmax are within low/high stage limits
            
            if dLimMin < this.dXMin
                dLimMin = this.dXMin;
                dLimMax = dLimMin + dRange;
            end
            
            if dLimMax > this.dXMax
                dLimMax = this.dXMax;
                dLimMin = this.dXMax - dRange;
            end
            
            % Set axis limits
            
            set(this.hAxes, 'Xlim', [dLimMin dLimMax]);
                        
        end
        
        function this = set.dYPan(this, dVal)
            
            % The pan slider has a value of lowCAL on the left and
            % increases linearly to a value of highCAL on the right. As we
            % pan, we want to keep the zoom level fixed.  This means we
            % need to make sure the xlim and ylim properties have the same
            % range (max-min) before and after the pan.
            
            
            dLimits = get(this.hAxes, 'Ylim');
            dRange = dLimits(2) - dLimits(1);
            
            % Set low and high limits based on pan value and range
            % (determined by zoom level)
            
            dLimMin = dVal - dRange/2;
            dLimMax = dVal + dRange/2;
            
                        
            % Check that xmin/xmax are within low/high stage limits
            
            if dLimMin < this.dYMin
                dLimMin = this.dYMin;
                dLimMax = dLimMin + dRange;
            end
            
            if dLimMax > this.dYMax
                dLimMax = this.dYMax;
                dLimMin = this.dYMax - dRange;
            end
            
            % Set axis limits
            
            set(this.hAxes, 'Ylim', [dLimMin dLimMax]);
                        
        end
            

    end
    
    methods (Access = private)
        
        
        function handleSliderXPan(this, ~, ~)
            this.dXPan = get(this.hSliderXPan, 'Value');
        end
        
        function handleSliderYPan(this, ~, ~)
            this.dYPan = get(this.hSliderYPan, 'Value');
        end
        
        function handleSliderZoom(this, ~, ~)
            this.dZoom = get(this.hSliderZoom, 'Value'); 
        end        
                
        function init(this)
            
            this.dXRange = this.dXMax - this.dXMin;
            this.dYRange = this.dYMax - this.dYMin;
                        
            this.dAxesAR = this.dAxesWidth/this.dAxesHeight;
            this.dCanvasAR = this.dXRange/this.dYRange;

        end        

    end % private
    
    
end