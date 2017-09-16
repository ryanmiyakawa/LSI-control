classdef _WaferFineStage < JavaDevice
    
    % rcs
    
    properties (Constant)
       
        dWidth      = 310 
        dHeight     = 110
        
    end
    
	properties
        
        hioZ
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        clock
        hPanel
       
    end
    
        
    events
        
        
        
    end
    

    
    methods
        
        
        function this = WaferFineStage(clock)
                        
            % Initialize JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'WaferFineProxy.jar');
            this.cPackage           = 'cxro.common.device.motion';
            this.cConstructFcn      = 'WaferFineStage(''M141-Stage'',''iman.lbl.gov'')';
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
                        
            this.hioZ = HardwareIO('Wafer-Fine-Z', clock, 'Z');
            this.hioZ.setup.uieStepRaw.setVal(10e-9);
            this.hioZ.api = APIHardwareIO(this);
            
            
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
                'Title', 'Wafer Fine Z',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
        
			drawnow;
            
            dButtonWidth = 94;
            dButtonSep = 5;
            dTop = 20;
            
            this.uitConnect.build(this.hPanel, 10 + 0*(dButtonSep + dButtonWidth), dTop, dButtonWidth, Utils.dEDITHEIGHT);
                        
            dSep = 40;
            dLeft = 10;
            dOffset = 60;
                
            this.hioZ.build(this.hPanel, dLeft, dOffset + 0*dSep);
    
            
        end
        
        
        
                   
        function status(this)
                        
                       
        end
        
                
        
        
        
        % Expose hardware methods to the API
        
        function dReturn = get(this)
            dReturn = this.jDevice.get();
        end
        
        function set(this, dVal)
            
            % @parameter dVal
            this.jDevice.set(dVal);
        end
        
        function stop(this)
            this.jDevice.stop();
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
            

    end
    
    methods (Access = protected)
        
        function turnOffHardware(this)

            this.hioZ.turnOff();

        end

        function turnOnHardware(this)

            this.hioZ.turnOn();

        end     
        
    end
    
    methods (Access = private)
        
        

    end % private
    
    
end