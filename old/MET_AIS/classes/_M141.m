classdef _M141 < JavaDevice
        
	properties (Constant)
       
        dWidth      = 310 
        dHeight     = 190
        
    end
    
    properties
        
        hioX
        hioRx
        hioRy
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                                
        hPanel
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
       
        
        function this = M141(clock)
                        
            this.msg('constructor');
            
            % Initialize JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'MotionControlProxy.jar');
            this.cPackage           = 'cxro.common.device.motion';
            % this.cConstructFcn      = 'MotionControlProxy(''M141-Stage'',''iman.lbl.gov'')';
            this.cConstructFcn      = 'MotionControlProxy(''M141-Stage'',''192.168.1.100'')';
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
            
            this.hioX   = HardwareIO('M141-X', clock, 'X');
            this.hioRx  = HardwareIO('M141-Rx', clock, 'Rx');
            this.hioRy  = HardwareIO('M141-Ry', clock, 'Ry');
            
            this.hioX.api   = APIHardwareIOStageXYZRxRyRz(this, 'x');
            this.hioRx.api  = APIHardwareIOStageXYZRxRyRz(this, 'rx');
            this.hioRy.api  = APIHardwareIOStageXYZRxRyRz(this, 'ry');
            
           
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'M141 X, Rx, Ry',...
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
            
            % uitConnect created in parent class
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
            this.hioRx.build(this.hPanel, dLeft, dOffset + 1*dSep);
            this.hioRy.build(this.hPanel, dLeft, dOffset + 2*dSep);
    
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
        
        % Expose hardware methods to the API
        
        function dReturn = get(this, cAxis)
            % @parameter cAxis 'x', 'rx', 'ry' 
            
            switch cAxis
                case 'x'
                    dReturn = this.jDevice.getAxisPosition(0);
                case 'rx'
                    dReturn = this.jDevice.getAxisPosition(1);  % fakeing 1 since 2 and 3 are open loop
                case 'ry'
                    dReturn = this.jDevice.getAxisPosition(2);
            end

            
        end
        
        function set(this, cAxis, dVal)
            
            % @parameter cAxis 'x', 'rx', 'ry'
            % @parameter dVal
            
            switch cAxis
                case 'x'
                    this.jDevice.setAxisTarget(0, dVal);
                case 'rx'
                    this.jDevice.setAxisTarget(1, dVal);
                case 'ry'
                    this.jDevice.setAxisTarget(2, dVal);
            end
        end
        
        function stop(this, cAxis)
            
            
            %{
            switch cAxis
                case 'x'
                    this.jDevice.stopAxisMove(0);
                case 'rx'
                    this.jDevice.stopAxisMove(1);
                case 'ry'
                    this.jDevice.stopAxisMove(2);
            end
            %}
            
        end

    end
    
    methods (Access = protected)
                
        % Overload
        
        function turnOffHardwareIO(this)
            
            
            this.hioX.turnOff();
            this.hioRx.turnOff();
            this.hioRy.turnOff();
            
        end
        
        % Overload
        
        function turnOnHardwareIO(this)
            
            this.hioX.turnOn();
            this.hioRx.turnOn();
            this.hioRy.turnOn();
            
        end
        
        
    end % protected
    
    
    methods (Access = private)
        
                
        function handleConnect(this, src, evt)
            
            
        end
        
        function handleDisconnect(this, src, evt)
            
            
        end
            
        
    end
    
    
end