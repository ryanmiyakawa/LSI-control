classdef HeightSensor < HandlePlus
    
    % hs
    % Six HardwareO instances that expose the reading of each channel in
    % nm.  As of 2014.05.14 this does not have any high-speed data logging
    % capability nor does it do any kinematics on the nm values to compute
    % tip/tilt (but Antoine built a lot of this into HeightSensorCore)
    
    
    properties (Constant)
        
       dWidth       = 310 
       dHeight      = 240
       
    end
	properties
        
        hoCh1
        hoCh2
        hoCh3
        hoCh4
        hoCh5
        hoCh6        
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                    
        cl        
        cJarDir
        cJarPath
        
        hPanel
        uitConnect
        jDevice 
        
    end
    
        
    events
        
        eConnect
        eDisconnect
        
    end
    

    
    methods
        
        
        function this = HeightSensor(cl)
            
            this.cl = cl;
            this.cJarDir = pwd;
            this.cJarPath = sprintf('%s%sHeightSensorProxy.jar', this.cJarDir, filesep);
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % 2014.02.11 CNA temporary msg box to alert settings required 
            % to hook up to nPoint over ICE
            
            %{
            h = msgbox( ...
                'To connect to Mod3 over ICE, you need to TURN OFF WIFI and TURN OFF VPN (for some reason, we cannot reach met-dev.dhcp.lbl.gov when VPN is on) and plug an ethernet cable into the computer.', ...
                'Mod3 ICE connection help', ...
                'warn' ...
            ); 
            %}

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Height Sensor',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
        
			drawnow;
            
            dButtonWidth = 94;
            dButtonSep = 5;
            dTop = 20;
            
            this.uitConnect.build(this.hPanel, 10 + 0*(dButtonSep + dButtonWidth), dTop, dButtonWidth, Utils.dEDITHEIGHT);
                        
            dSep = 28;
            dLeft = 10;
            dOffset = 60;
                
            this.hoCh1.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hoCh2.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hoCh3.build(this.hPanel, dLeft, dOffset + 2*dSep);
            this.hoCh4.build(this.hPanel, dLeft, dOffset + 3*dSep);
            this.hoCh5.build(this.hPanel, dLeft, dOffset + 4*dSep);
            this.hoCh6.build(this.hPanel, dLeft, dOffset + 5*dSep);
            
        end
        
        
                       
        function status(this)
            % this.attach();
            
            
            for n = 1:6
                this.msg(sprintf('Temp %1.0f = %1.2f C', n, this.jDevice.getTemp(n)));
            end
            
            for n = 1:6
                this.msg(sprintf('Cap %1.0f = %1.2f nm', n, this.jDevice.getCap(n)));
            end
                       
            
        end
        
                
        
        %% Destructor
        
        function delete(this)
            
            if this.jDevice ~= []
                this.msg('nPoint.delete()');
                this.jDevice.unInit();
            end
        end
        
        % Expose hardware methods to the API
        
        function dReturn = get(this, dCh)
            
            % @parameter dSensor (1 - 6)
           
            dReturn = this.jDevice.get(dCh);
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
            
        function lReturn = isActive(this)
            lReturn = this.uitConnect.lVal;
        end

    end
    
    methods (Access = private)
        
        function init(this)
            
            this.uitConnect = UIToggle('Connect', 'Disconnect');
            addlistener(this.uitConnect, 'eChange', @this.handleConnect);
            
            this.hoCh1 = HardwareO('HeightSensor-Ch-1', this.cl, 'Ch 1');
            this.hoCh2 = HardwareO('HeightSensor-Ch-2', this.cl, 'Ch 2');
            this.hoCh3 = HardwareO('HeightSensor-Ch-3', this.cl, 'Ch 3');
            this.hoCh4 = HardwareO('HeightSensor-Ch-4', this.cl, 'Ch 4');
            this.hoCh5 = HardwareO('HeightSensor-Ch-5', this.cl, 'Ch 5');
            this.hoCh6 = HardwareO('HeightSensor-Ch-6', this.cl, 'Ch 6');
            
            this.hoCh1.api = APIHardwareOHeightSensor(this, 'ch1');
            this.hoCh2.api = APIHardwareOHeightSensor(this, 'ch2');
            this.hoCh3.api = APIHardwareOHeightSensor(this, 'ch3');
            this.hoCh4.api = APIHardwareOHeightSensor(this, 'ch4');
            this.hoCh5.api = APIHardwareOHeightSensor(this, 'ch5');
            this.hoCh6.api = APIHardwareOHeightSensor(this, 'ch6');

        end
        
        
        function turnOffHardware(this)
            
            this.hoCh1.turnOff();
            this.hoCh2.turnOff();
            this.hoCh3.turnOff();
            this.hoCh4.turnOff();
            this.hoCh5.turnOff();
            this.hoCh6.turnOff();
            
        end
        
        function turnOnHardware(this)
            
            this.hoCh1.turnOn();
            this.hoCh2.turnOn();
            this.hoCh3.turnOn();
            this.hoCh4.turnOn();
            this.hoCh5.turnOn();
            this.hoCh6.turnOn();           
            
        end        
        
        function handleConnect(this, src, evt)
            
            if(this.uitConnect.lVal)
                % Connect and turn on
                if ~this.connect()
                    this.uitConnect.lVal = false   
                end
            else
                % Disconnect and turn off
                if ~this.disconnect()
                    this.uitConnect.lVal = true;
                end
            end
                
        end
        
        % Send to JavaDevice
        
        function lReturn = disconnect(this)
            
            
            % Attempt to disconnect.  Before doing so, we need to turn
            % off all HardwareIO/O instances so they don't access the real
            % API

            this.turnOffHardware();
            
            if isequal(this.jDevice, [])
                lReturn = true;
                return;
            end
            
            lReturn = this.jDevice.unInit();
            if lReturn
                % Success
                notify(this, 'eDisconnect');
            else
                % Could not unitialize
                msgbox('Could not disconnect from Height Sensor.  Check USB cable and controller power.', 'Communication error', 'error');
                lReturn = false;
                % Turn on HardwareIO/O instances (2014.04.24 this doesn't
                % make any sense to me why we would keep them on. 
                % this.turnOnHardware();
            end

        end
         
        % Send to JavaDevice
        
        function lReturn = connect(this)
             
            % Make sure library is loaded
            if ~this.libIsLoaded()
                this.loadLib();
            end
            
            
            % Make sure a Java device exists
            if isequal(this.jDevice, [])
                this.jDevice = cxro.common.device.HeightSensorProxy();
            end
            
            % this.jDevice.unInit();  % Make sure device not initialized to old instance
            
            % Initialize
            lReturn = this.jDevice.init();
            
            if lReturn
                
                % Success
                % Turn on HardwareIO/O instances 
                this.turnOnHardware();
                notify(this,'eConnect');
                
            else
                    
                % Failure
                msgbox('Could not connect to Mod3.  Check USB cable and controller power.', 'Communication error', 'error');
                lReturn = false;
                
            end
            
        end
        
        % Send to JavaDevice
        
        function loadLib(this)
        
            % Temporarily set user.dir to this folder so nPoint.jar can
            % load libnPoint.dylib and other files
            
            java.lang.System.setProperty('user.dir', this.cJarDir)

            % Add files to Java class path

            javaaddpath(this.cJarPath);
            
            % By using the import command, we can simplify java class names.  Instead
            % of a = cxro.serm.wago.Test(), you can do a = Test();
            
            % import cxro.common.device.*
            methods('cxro.common.device.HeightSensor')
            
        end
        
        % Send to JavaDevice
        
        function lOut = libIsLoaded(this)
           
            % DPE == Dynamic Path Entries
            
            ceDPE = javaclasspath;
            for k = 1:length(ceDPE)
                if strcmp(ceDPE{k}, this.cJarPath)
                    lOut = true;
                    return;
                end
            end
            
            lOut = false;
            
        end

    end % private
    
    
end