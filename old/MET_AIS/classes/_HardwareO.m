classdef HardwareO < HandlePlus
%HARDWAREO Class that allows for the reading of a sensor or else.
% Contrary to Diode Class, this class is meant to have direct access to the
% (unprocessed) hardware readings
% This class is very similar to HardwareIO, except that it doesn't allow 
% for a motion (there is no edit box)
%
%   ho = HardwareO('name', clock)creates an instance with a name 'name'
%   ho = HardwareO('name', clock, 'display name') will do the same, except
%       that the displayed name will not be default 'name'
%
% See also HARDWAREIO, DIODE
    
    % Hungarian: ho
    
    % adapted from HardwareIO
    % AW, Aug 2013
    % comments :
    % mahor changes have been done in the clock : now using an external
    % function handle when the API is virtual// might be superseeded with a API_HO
    % there are not verification to make
    % we can add the units

    properties (Constant)
        dWidth = 300;  % width of the UIElement
        dHeight = 36;  % height of the UIElement
    end

    properties
        % use only hungarian prefix since only one instance
        
        setup           % Setup FIXME rather hoSetup
        apiv            % APIV
        api             % API
        fhReadVal;      % function handle to read a value
    end

    properties (SetAccess = private)
        cName       % name identifier
        cl          % clock   
    end

    properties (Access = private)
        cDispName   %name to display
        cDir        % directory
       
        uitxPos     % label to display the current position reading
        lActive     % boolean to tell whether the motor is active or not
        uitActive   % UIToggle button
        uitCal      % UIToggle button to tell whether the reading is calibr
        uibSetup    % button that launches the setup menu
        uitxLabel   % label to displau the name of the element

        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff = [244 245 169]./255;
        dColorOn = [241 241 241]./255;
        
    end

    events 
    end

    methods        
        
        function this = HardwareO(cName, cl, cDispName)  
        %HARDWAREO Class constuctor
        %
        %   hi = HardwareI('name', clock) uses 'name' as default display
        %   hi = HardwareI('name', clock, 'dispName') 
        %
        % See also DELETE, INIT, BUILD
            
            if exist('cDispName', 'var') ~= 1
                cDispName = cName; % ms
            end
            
            this.cName = cName;
            this.cl = cl;
            this.cDispName = cDispName;

            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));

            this.init();

        end

%% Methods
        function init(this)
        %INIT Initializes the class
        %   HardwareO.init()
        %
        % See also HARDWAREO, INIT, BUILD
            
            % Setup
            this.setup = SetupHardwareIO(this.cName);
            addlistener(this.setup, 'eCalibrationChange', @this.handleCalibrationChange);

            %activity ribbon on the right
            this.uitActive = UIToggle( ...
                'enable', ...   % (off) not active
                'disable', ...  % (on) active
                true, ...
                imread(sprintf('%s../assets/controllernotactive.png', this.cDir)), ...
                imread(sprintf('%s../assets/controlleractive.png', this.cDir)), ...
                true, ...
                'Are you sure you want to change status?' ...
                );

            %calibration toggle button
            this.uitCal = UIToggle( ...
                'raw', ...  % (off) showing raw
                'cal', ...  % (on) showing cal
                true, ...
                imread(sprintf('%s../assets/mcRAW.png', this.cDir)), ...
                imread(sprintf('%s../assets/mcCAL.png', this.cDir)) ...
                );
            %setup toggle button
            this.uibSetup = UIButton( ...
                'Setup', ...
                true, ...
                imread(sprintf('%s../assets/mcsetup.png', this.cDir)) ...
                );

            
            %position reading
            this.uitxPos = UIText('Pos', 'right');

            % Name (on the left)
            this.uitxLabel = UIText(this.cDispName);

            %TODO : optional registration to the clock of APIV
            %this.apiv = APIVHardwareIO(this.cName, 0, this.cl); 
            
            %Clock registration
            fh = @this.handleClock;
            this.cl.add(fh, [class(this),':',this.cName], this.setup.uieDelay.val());

            % event listeners
            addlistener(this.uitCal,    'eChange', @this.handleUI);
            %addlistener(this.uibIndex,  'eChange', @this.handleUI); %TODO
            %erase
            addlistener(this.uibSetup,  'eChange', @this.handleUI);

        end

        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element associated with the class
        %   HardwareO.build(hParent, dLeft, dTop)
        %
        % See also HARDWAREO, INIT, DELETE  
        
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
                );
            drawnow

            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position',Utils.lt2lb([0 0 this.dWidth this.dHeight], this.hPanel),...
                'XColor', [0 0 0], ...
                'YColor', [0 0 0], ...
                'HandleVisibility','on', ...
                'Visible', 'off' ...
            );
            
            this.hImage = image(imread(sprintf('%s../assets/HardwareIO.png', this.cDir)));
            set(this.hImage, 'Parent', this.hAxes);
            % set(this.hImage, 'CData', imread(sprintf('%s../assets/HardwareIO.png', this.cDir)));
            
            axis('image');
            axis('off');


            y_rel = -1;
 
           
            this.uitCal.build(this.hPanel, this.dWidth - 36-12, 0+y_rel, 36, 12);
            this.uibSetup.build(this.hPanel, this.dWidth - 36-12, 12+y_rel, 36, 12);
            %this.uibIndex.build(this.hPanel, this.dWidth - 36, 24+y_rel, 36, 12);
            this.uitxPos.build(this.hPanel, this.dWidth-36-36-18-75-75-6-12, 12+y_rel, 75, 12);
            this.uitxLabel.build(this.hPanel, 3, 12+y_rel, this.dWidth-36-36-18-75-75, 12);
            this.uitActive.build(this.hPanel, this.dWidth-12, 0+y_rel, 12, 36);

        end
        
        function dPosRaw = readRaw(this)
        %READRAW Reads the sensor value, in raw units.
        %
        %   dPosRaw = HardwareO.readRaw();
        
            try
                if this.lActive
                    dPosRaw = this.api.get();
                else
                    %dPosRaw = this.apiv.get();
                    if ~isempty(this.fhReadVal)
                        dPosRaw = this.fhReadVal();
                    else
                        dPosRaw = 0;
                    end
                end
            catch err
                this.msg(getReport(err));
            end
            
            
        end
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the API to control the h
        %   HardwareO.turnOn()
        %
        % See also TURNOFF
        
            this.lActive = true;
            
            % set(this.hPanel, 'BackgroundColor', this.dColorOn);
            set(this.hImage, 'Visible', 'off');
                        
            % Update destination values to match device values
            this.setDestRaw(this.api.get());
        end
        
        function turnOff(this)
        %TURNOFF Turns the motor off
        %   HardwareO.turnOn()
        %
        % See also TURNON
        
            this.lActive = false;
            set(this.hImage, 'Visible', 'on');
            % set(this.hPanel, 'BackgroundColor', this.dColorOff);

        end       
        

        function delete(this)
        %DELETE Class Destructor
        %   HardwareO.Delete()
        %
        % See also HARDWAREO, INIT, BUILD

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

            if ~isempty(this.uitActive)
                delete(this.uitActive)
            end
            if ~isempty(this.uitCal)
                delete(this.uitCal)
            end
            if ~isempty(this.uibSetup)
                delete(this.uibSetup)
            end

            if ~isempty(this.uitxPos)
                delete(this.uitxPos)
            end
            if ~isempty(this.uitxLabel)
                delete(this.uitxLabel)
            end
        end

    end %methods
    
    methods(Hidden)
	
        function updateDestUnits(this)
        %TODO Implement
        end
        
        
        function handleClock(this)
        %HANDLECLOCK Callback triggered by the clock
        %   HardwareO.HandleClock()
        %   updates the position reading and the ho status (=/~moving)
        
            try
                dPosRaw = this.readRaw;
                
                % update uitxPos
                if this.uitCal.lVal
                    % cal
                    this.uitxPos.cVal = sprintf('%.3f', this.setup.raw2cal(dPosRaw));
                else
                    % raw
                    this.uitxPos.cVal = sprintf('%.3f', dPosRaw); %
                end
                drawnow;
                %
                
            catch err
                this.msg(getReport(err));
            end
        end
        
        
        function handleUI(this, src, evt)
        %HANDLEUI Callback for the User interface (uicontrols etc.)
        %   HardwareO.handleUI(src,~)
        
           if (src==this.uibSetup)
                    this.setup.build();
                    
                    % TODO : improve this quick'n' dirty fix
                     hPanels = findall(this.setup.hFigure,'Type', 'uipanel');
                     for k = 1:length(hPanels)
                         if strcmp(get(hPanels(k),'Title'),'"Is There?" Tolerance') ||...
                            strcmp(get(hPanels(k),'Title'),'(Software) motion limits') ||...
                            strcmp(get(hPanels(k),'Title'),'Step (+/- buttons)')
                        
                            set(hPanels(k),'visible','off')
                         end
                     end

           elseif (src==this.uitCal)
                    this.updateDestUnits();
                    % uitxPos will automatically change the next time the
                    % value is refreshed
                % TODO :erase
                %elseif (src==this.uibIndex)
                    %this.index();

            end
        end

        function handleCalibrationChange(this, ~, ~)
        %HANDLECALIBRATIONCHANGE Callback to handle change in RAW/Cal mode
        
            this.msg('HardwareIO.handleCalibrationChange()'); %TODO remove when finalized
            if this.uitCal.lVal

                %TODO : remove; useless now
%                 % cal
% 
%                 % need to update dMin, dMax, and val of uieDest since
%                 % raw2cal has changed.  For dest pos, set to motor pos set
%                 % dest to motor pos since there is no way to compute the
%                 % previous dest from current cal dest since cal2raw has
%                 % changed (slope has changed).
% 
%                 if this.lActive
%                     dPos = this.api.get();
%                 else
%                     %dPos = this.apiv.get();
%                     if ~isempty(fhUpdate)
%                         dPos = this.fhReadVal();
%                     else
%                         dPos = 0;
%                     end
%                 end
            else
                % raw

            end
        end 
    end

end %class
