classdef _WaferCoarseStage < JavaDevice
    
    % rcs
    
    properties (Constant)
       
        dWidth      = 310 
        dHeight     = 290
        
    end
	properties
        
        hioX
        hioY
        
        hioZ
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
        
        
        function this = WaferCoarseStage(clock)
            
            this.clock = clock;
            
            this.cJarPath           = fullfile(pwd, 'WaferCoarseProxy.jar');
            this.cPackage           = 'cxro.common.device';
            this.cConstructFcn      = 'WaferCoarseStage(''M141-Stage'',''iman.lbl.gov'')';
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
            
            this.hioX   = HardwareIO('Wafer-Coarse-X', this.clock, 'X');
            this.hioY   = HardwareIO('Wafer-Coarse-Y', this.clock, 'Y');
            this.hioZ   = HardwareIO('Wafer-Coarse-Z', this.clock, 'Z');
            this.hioRx  = HardwareIO('Wafer-Coarse-Rx', this.clock, 'Rx');
            this.hioRy  = HardwareIO('Wafer-Coarse-Ry', this.clock, 'Ry');
            
            this.hioX.setup.uieStepRaw.setVal(100e-6);
            this.hioY.setup.uieStepRaw.setVal(100e-6);

            this.hioX.api   = APIHardwareIOStageXYZRxRyRz(this, 'x');
            this.hioY.api   = APIHardwareIOStageXYZRxRyRz(this, 'y');
            this.hioZ.api   = APIHardwareIOStageXYZRxRyRz(this, 'z');
            this.hioRx.api  = APIHardwareIOStageXYZRxRyRz(this, 'rx');
            this.hioRy.api  = APIHardwareIOStageXYZRxRyRz(this, 'ry');
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Coarse XY ZRxRy',...
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
                
            this.hioX.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hioY.build(this.hPanel, dLeft, dOffset + 1*dSep);
            
            dOffset = 160;
            this.hioZ.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.hioRx.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hioRy.build(this.hPanel, dLeft, dOffset + 2*dSep);
    
            
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
            this.hioZ.turnOff();
            this.hioRx.turnOff();
            this.hioRy.turnOff();

        end
        
        function turnOnHardware(this)
            
            this.hioX.turnOn();
            this.hioY.turnOn();
            this.hioZ.turnOn();
            this.hioRx.turnOn();
            this.hioRy.turnOn();
            
        end    
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            

        end
        
        

    end % private
    
    
end