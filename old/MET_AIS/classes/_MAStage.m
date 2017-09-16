classdef _MAStage < JavaDevice
    
    % rcs
    
    properties (Constant)
       
        dWidth      = 310 
        dHeight     = 230
        
    end
	properties
        
        hioX
        hioY
        hioRx
        hioRy
        
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
        
        
        function this = MAStage(clock)
            
            this.clock = clock;
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % 2014.02.11 CNA temporary msg box to alert settings required 
            % to hook up to nPoint over ICE
            
            %{
            h = msgbox( ...
                ['To connect to Mod3 over ICE, you need to TURN OFF WIFI ' ...
                'and TURN OFF VPN (for some reason, we cannot reach ' ...
                'met-dev.dhcp.lbl.gov when VPN is on) and plug an ' ...
                'ethernet cable into the computer.'], ...
                'Mod3 ICE connection help', ...
                'warn' ...
            ); 
            %}

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'MA X,Y,Rx,Ry',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;
            
            dButtonWidth = 94;
            dButtonSep = 5;
            dTop = 20;
            
            this.uitConnect.build( ...
                this.hPanel, ...
                10 + 0*(dButtonSep + dButtonWidth), ...
                dTop, ...
                dButtonWidth, ...
                Utils.dEDITHEIGHT);
                        
            dSep = 40;
            dLeft = 10;
            dOffset = 60;
                
            this.hioX.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hioY.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hioRx.build(this.hPanel, dLeft, dOffset + 2*dSep);
            this.hioRy.build(this.hPanel, dLeft, dOffset + 3*dSep);
    
            
        end
        
        
                       
        function status(this)
                        
                       
        end
        
                
        
        
        
        % Expose hardware methods to the API
        
        function dReturn = get(this, cAxis)
            % @parameter cAxis 'x', 'y', 'z' 'rx', 'ry', 
            dReturn = this.jDevice.get(cAxis);
        end
        
        function set(this, cAxis, dVal)
            
            % @parameter cAxis 'x', 'y', 'z', 'rx', 'ry'
            % @parameter dVal
            
            this.jDevice.set(cAxis, dVal);
        end
        
        function stop(this, cAxis)
            this.jDevice.stop(cAxis);
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
            
            this.hioX.turnOff();
            this.hioY.turnOff();
            this.hioRx.turnOff();
            this.hioRy.turnOff();
            

        end
        
        function turnOnHardware(this)
            
            this.hioX.turnOn();
            this.hioY.turnOn();
            this.hioRx.turnOn();
            this.hioRy.turnOn();
            
        end
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            % Initialize JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'MotionControlProxy.jar');
            this.cPackage           = 'cxro.common.device.motion';
            this.cClass             = 'MotionControlProxy';
            this.cConstructArgs     = '''M141-Stage'',''iman.lbl.gov''';
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
         
            this.hioX = HardwareIO('MA-X', this.clock, 'X');
            this.hioY = HardwareIO('MA-Y', this.clock, 'Y');
            this.hioRx = HardwareIO('MA-Rx', this.clock, 'Rx');
            this.hioRy = HardwareIO('MA-Ry', this.clock, 'Ry');
            
            this.hioX.setup.uieStepRaw.setVal(100e-6);
            this.hioY.setup.uieStepRaw.setVal(100e-6);

            this.hioX.api = APIHardwareIOStageXYZRxRyRz(this, 'x');
            this.hioY.api = APIHardwareIOStageXYZRxRyRz(this, 'y');
            this.hioRx.api = APIHardwareIOStageXYZRxRyRz(this, 'rx');
            this.hioRy.api = APIHardwareIOStageXYZRxRyRz(this, 'ry');

        end
        
        
              
        
        

    end % private
    
    
end