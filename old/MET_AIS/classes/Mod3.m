classdef Mod3 < HandlePlus
    
    % m3
    
    properties (Constant)
    
        dWidth      = 310 
        dHeight     = 180  % 415
        
    end
    
	properties
        
        hoCap1
        hoCap2
        hoCap3
        hoCap4
        
        
        %{
        hoTemp1
        hoTemp2
        hoTemp3
        hoTemp4
        hoTemp5
        hoTemp6
        %}
        
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
        
        
        function this = Mod3(cl)
            
            this.cl = cl;
            this.cJarDir = pwd;
            this.cJarPath = sprintf('%s%sMod3Proxy.jar', this.cJarDir, filesep);
            % this.cJarPath = sprintf('%s%sMod3.jar', this.cJarDir, filesep);
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
                'Title', 'Mod3',...
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
                
            this.hoCap1.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hoCap2.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hoCap3.build(this.hPanel, dLeft, dOffset + 2*dSep);
            this.hoCap4.build(this.hPanel, dLeft, dOffset + 3*dSep);
            
            dOffset = dOffset + 5*dSep + 40; 
            
            %{
            this.hoTemp1.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hoTemp2.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hoTemp3.build(this.hPanel, dLeft, dOffset + 2*dSep);
            this.hoTemp4.build(this.hPanel, dLeft, dOffset + 3*dSep);
            this.hoTemp5.build(this.hPanel, dLeft, dOffset + 4*dSep);
            this.hoTemp6.build(this.hPanel, dLeft, dOffset + 5*dSep);
            %}
            
        end
        
                       
        function status(this)
            % this.attach();
            
            this.msg('Mod3.status()');
            
            for n = 1:6
                this.msg(sprintf('Temp %1.0f = %1.2f C', n, this.jDevice.getTemp(n)));
            end
            
            for n = 1:6
                this.msg(sprintf('Cap %1.0f = %1.2f nm', n, this.jDevice.getCap(n)));
            end
                       
            
        end
        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');

            if this.jDevice ~= []
                this.jDevice.unInit();
            end
        end
        
        % Expose hardware methods to the API
        
        function dReturn = getCap(this, dSensor)
            
            % @parameter dSensor (1 - 6)
           
            dReturn = this.jDevice.getCap(dSensor);
        end
        
        function dReturn = getTemp(this, dSensor)
            
            % @parameter dSensor (1 - 6)
           
            dReturn = this.jDevice.getTemp(dSensor);
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
            
            this.hoCap1 = HardwareO('Mod3-Cap-1', this.cl, 'Cap 1');
            this.hoCap2 = HardwareO('Mod3-Cap-2', this.cl, 'Cap 2');
            this.hoCap3 = HardwareO('Mod3-Cap-3', this.cl, 'Cap 3');
            this.hoCap4 = HardwareO('Mod3-Cap-4', this.cl, 'Cap 4');
            
            this.hoCap1.api = APIHardwareOMod3(this, 'cap-1');
            this.hoCap2.api = APIHardwareOMod3(this, 'cap-2');
            this.hoCap3.api = APIHardwareOMod3(this, 'cap-3');
            this.hoCap4.api = APIHardwareOMod3(this, 'cap-4');
            
            %{
            this.hoTemp1 = HardwareO('Mod3-Temp-1', this.cl, 'Temp 1');
            this.hoTemp2 = HardwareO('Mod3-Temp-2', this.cl, 'Temp 2');
            this.hoTemp3 = HardwareO('Mod3-Temp-3', this.cl, 'Temp 3');
            this.hoTemp4 = HardwareO('Mod3-Temp-4', this.cl, 'Temp 4');
            this.hoTemp5 = HardwareO('Mod3-Temp-5', this.cl, 'Temp 5');
            this.hoTemp6 = HardwareO('Mod3-Temp-6', this.cl, 'Temp 6');
            
            this.hoTemp1.api = APIHardwareOMod3(this, 'temp-1');
            this.hoTemp2.api = APIHardwareOMod3(this, 'temp-2');
            this.hoTemp3.api = APIHardwareOMod3(this, 'temp-3');
            this.hoTemp4.api = APIHardwareOMod3(this, 'temp-4');
            this.hoTemp5.api = APIHardwareOMod3(this, 'temp-5');
            this.hoTemp6.api = APIHardwareOMod3(this, 'temp-6');
            %}
        end
        
        
        function turnOffHardware(this)
            
            this.hoCap1.turnOff();
            this.hoCap2.turnOff();
            this.hoCap3.turnOff();
            this.hoCap4.turnOff();
            
            %{
            this.hoTemp1.turnOff();
            this.hoTemp2.turnOff();
            this.hoTemp3.turnOff();
            this.hoTemp4.turnOff();
            this.hoTemp5.turnOff();
            this.hoTemp6.turnOff();
            %}

        end
        
        function turnOnHardware(this)
            
            this.hoCap1.turnOn();
            this.hoCap2.turnOn();
            this.hoCap3.turnOn();
            this.hoCap4.turnOn();
            
            %{
            this.hoTemp1.turnOn();
            this.hoTemp2.turnOn();
            this.hoTemp3.turnOn();
            this.hoTemp4.turnOn();
            this.hoTemp5.turnOn();
            this.hoTemp6.turnOn();
            %}
            
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
                msgbox('Could not disconnect from Mod3.  Check USB cable and controller power.', 'Communication error', 'error');
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
                this.jDevice = cxro.common.device.Mod3Proxy();
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
            methods('cxro.common.device.Mod3')
            
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