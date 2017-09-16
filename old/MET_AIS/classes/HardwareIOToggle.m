classdef HardwareIOToggle < HandlePlus

    % UIToggle lets you issue commands set(true/false)
    % there will be an indicator that shows a red/green dot baset on the
    % result of get() returning lTrue / lFalse.  The indicator will be a
    % small axes next to the toggle.  If software is talking to device api,
    % it shows one set of images (without the gray diagonal stripes) and
    % shows another set of images when it is talking to the virtual APIs
    
    
    properties (Constant)
        
        dHeight = 24;   % height of the UIElement
        dWidth = 290;   % width of the UIElement
    end

    properties      
        setup           % setup -- FIXME : shouldbe renamed something like hioSetup
        apiv            % virtual API (for test and debugging).  Builds its own APIVHardwareIO
        api             % API to the low level controls.  Must be set after initialized.
    end

    properties (SetAccess = private)
        cName   % name identifier
        cDispName
        lVal
        lActive     % boolean to tell whether the motor is active or not
    end

    properties (Access = protected)
        
        cl          % clock 
        cDir        % current directory
        dDelay = 0.1
        
        hPanel      % panel container for the UI element
        
        uitCommand
        uitxLabel
        
        hAxes       % container for UI images
        hImage
        
        % Need a hggroup to store all of the image handles.  For some
        % reason the axes didn't work for this
        
        hStatusAxes
        hImageGroup
        hImageActiveTrue
        hImageActiveFalse
        hImageInactiveTrue
        hImageInactiveFalse
                        
    end
    

    events
        
        
    end

    
    methods        
        
        function this = HardwareIOToggle( ...
            cName, ...
            cl, ...
            cDispName, ...
            u8ImgOff, ...        % optional
            u8ImgOn, ...         % optional
            stF2TOptions, ...    % optional
            stT2FOptions ...     % optional
        )
        
    
            this.cName          = cName;
            this.cl             = cl;
            this.cDispName      = cDispName;
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
    
            % Defaults for optional inputs
            
            if exist('u8ImgOn', 'var') ~= 1
                u8ImgOn = imread(sprintf('%s../assets/axis-pause-24.png', this.cDir));
            end
            
            if exist('u8ImgOff', 'var') ~= 1
                u8ImgOff = imread(sprintf('%s../assets/axis-play-24.png', this.cDir));
            end
            
            if exist('stF2TOptions', 'var') ~= 1
                stF2TOptions            = struct();
                stF2TOptions.lAsk       = false;
            end
            
            if exist('stT2FOptions', 'var') ~= 1
                stT2FOptions            = struct();
                stT2FOptions.lAsk       = false;
            end            
                        
            this.uitCommand = UIToggle( ...
                '', ...
                '', ...
                true, ...
                u8ImgOff, ...
                u8ImgOn, ...
                stF2TOptions, ...
                stT2FOptions);
            
            addlistener(this.uitCommand, 'eChange', @this.handleToggle);
            
            this.uitxLabel = UIText(this.cDispName);
            this.apiv = APIVHardwareIOToggle();
            this.cl.add(@this.handleClock, this.id(), this.dDelay);
            
        end

        
        function build(this, hParent, dLeft, dTop)
          
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent));
            drawnow
                        
                        
            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position',Utils.lt2lb([0 0 this.dWidth this.dHeight], this.hPanel),...
                'XTick', [], ...
                'YTick', [], ...
                'HandleVisibility','on', ...
                'Visible', 'off');
            
            
            this.hImage = image(imread(sprintf('%s../assets/HardwareO.png', this.cDir)));
            set(this.hImage, 'Parent', this.hAxes);
            
            
            this.hStatusAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position',Utils.lt2lb([this.dWidth - 2*this.dHeight 0 this.dHeight this.dHeight], this.hPanel),...
                'Box', 'off', ...
                'HandleVisibility','on', ...
                'Visible', 'off');
            
            
            
            % For some reason, setting 'Box' property before a child is
            % added doesn't work.  Need to set it after
            
                %{
                'XTickMode', 'manual', ...
                'YTickMode', 'manual', ...
                'XAxisLocation', 'bottom', ...
                'YAxisLocation', 'left', ...
                'XTick', [], ...
                'YTick', [], ...
                'XTickLabel', [], ...
                'YTickLabel', [], ...
                %}
          
            this.hImageGroup = hggroup('Parent', this.hStatusAxes);
            
            this.hImageInactiveFalse    = image( ...
                imread(sprintf('%s../assets/HardwareIOToggleInactiveFalse.png', this.cDir)), ...
                'Parent', this.hImageGroup, ...
                'Visible', 'on');
            
            this.hImageInactiveTrue     = image( ...
                imread(sprintf('%s../assets/HardwareIOToggleInactiveTrue.png', this.cDir)), ...
                'Parent', this.hImageGroup, ...
                'Visible', 'on');
            
            this.hImageActiveFalse      = image( ...
                imread(sprintf('%s../assets/hiot-false-24.png', this.cDir)), ...
                'Parent', this.hImageGroup, ...
                'Visible', 'on');
            
            this.hImageActiveTrue       = image( ...
                imread(sprintf('%s../assets/hiot-true-24.png', this.cDir)), ...
                'Parent', this.hImageGroup, ...
                'Visible', 'on');
                         
            this.uitCommand.build(this.hPanel, ...
                this.dWidth - this.dHeight, ...
                0, ...
                this.dHeight, ...
                this.dHeight);
            
            
            this.uitxLabel.build(this.hPanel, ...
                0, ...
                6, ...
                this.dWidth - 2*this.dHeight, ...
                12);
            
            set(this.hStatusAxes, 'Visible', 'off');
            set(this.hAxes, 'Visible', 'off');

            
            
        end

        
        function handleToggle(this, src, evt)
            
            % Remember that lVal has just flipped from what it was
            % pre-click.  The toggle just issues set() commands.  It
            % doesn't do anything smart to show the value, this is handled
            % by the indicator image with each handleClock()
            
            if this.uitCommand.lVal
                
                if this.lActive
                    this.api.set(true);
                else
                    this.apiv.set(true);
                end
                
            else
                
                if this.lActive
                    this.api.set(false);
                else
                    this.apiv.set(false);
                end
            end
                        
        end 

               
        
        function turnOn(this)
        
            this.lActive = true;
                        
            % Kill the APIV
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
                this.apiv = []; % This is calling the setter
            end
            
        end
        
        
        function turnOff(this)
        
            % CA 2014.04.14: Make sure APIV is available
            
            if isempty(this.apiv)
                this.apiv = APIVHardwareIOToggle();
            end
            
            this.lActive = false;
           
        end
        
        
        
        function set.apiv(this, value)
            
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
            end

            this.apiv = value;
            
        end
        
        
        function delete(this)
        %DELETE Class Destructor
        %   HardwareIO.Delete()
        %
        % See also HARDWAREIO, INIT, BUILD

           % Clean up clock tasks
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                % this.msg('Axis.delete() removing clock task'); 
                this.cl.remove(this.id());
            end

            
            % av.  Need to delete because it has a timer that needs to be
            % stopped and deleted

            if ~isempty(this.apiv)
                 delete(this.apiv);
            end

            % delete(this.setup);
            % setup ?

            if ~isempty(this.uitCommand)
                delete(this.uitCommand)
            end
            
        end
        
        function handleClock(this) 
        
            ceh = { ...
                this.hImageInactiveTrue, ...
                this.hImageInactiveFalse, ...
                this.hImageActiveTrue, ...
                this.hImageActiveFalse ...
            };
           
            try
                
                if this.lActive
                    this.lVal = this.api.get();
                else
                    this.lVal = this.apiv.get();
                end
                
                % Update the indicator
                
                
                if this.lVal
                    Utils.hideOtherHandles(this.hImageActiveTrue, ceh);
                else
                    Utils.hideOtherHandles(this.hImageActiveFalse, ceh);
                end
                                
                %{
                if this.lActive
                    if this.lVal
                        Utils.hideOtherHandles(this.hImageActiveTrue, ceh);
                    else
                        Utils.hideOtherHandles(this.hImageActiveFalse, ceh);
                    end
                else
                    if this.lVal
                        Utils.hideOtherHandles(this.hImageInactiveTrue, ceh);
                    else
                        Utils.hideOtherHandles(this.hImageInactiveFalse, ceh);
                    end
                end
                %}
                
                % set(this.hStatusAxes, 'Box', 'off');
                        
                                
            catch err
                this.msg(getReport(err));
                 
            end 

        end
        
    end %methods
    
    methods (Access = protected)
            
        
    end

end %class
