classdef _Wago < JavaDevice
    
    % np
    
	properties (Constant)
       
        
    end
    
    properties
        
        % This fictitous wago will have five sub-devices on it and we will
        % allow each one to be built on a separate panel.  Just call the
        % build functions of each one directly
     
        hioA
        hioB
        hiotC
        doideD
        diodeE
        
    end
    
    properties (SetAccess = private)
    
        
    end
    
    properties (Access = private)
                                
        cName
        clock
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = Wago(cName, clock)
               
            % cName         char                device name, passed into Java
            % clock         Clock
            % lShowToggle   logical             show the toggle (connect/disconnect) or not
            
            this.cName      = cName;
            
            % JavaDevice properties
            
            this.cJarPath           = fullfile(pwd, 'Wago.jar');
            this.cPackage           = 'cxro.common.device';
            this.cConstructFcn      = sprintf('Wago(''%s'')', cName);
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
            
            
            % Build all Hardware* instances that represent the sub-devices
            % attached to this wago device and attach the api
            
            
            this.hioA       = HardwareIO([this.cName,'-A'], clock, 'A');
            this.hioA.api   = APIWago(this, 'a');
            
            this.hioB       = HardwareIO([this.cName,'-B'], clock, 'B');
            this.hioB.api   = APIWago(this, 'b');
            
            this.hiotC      = HardwareIOToggle([this.cName,'-C'], clock, 'C');
            this.hiotC.api  = APIWago(this, 'c');
            
            this.diodeD     = Diode([this.cName,'-DiodeD'], clock, 'Diode D');
            this.diodeD.api = APIWago(this, 'd');

            this.diodeE     = Diode([this.cName,'-DiodeE'], clock, 'Diode E');
            this.diodeE.api = APIWago(this, 'e');
        
        end
                
                       
        % Expose hardware methods to the API
        
        function dReturn = get(this, cAxis)
            
            switch cAxis
                case 'x'
                    dReturn = this.jDevice.getAxisPosition(1);
                case 'y'
                    dReturn = this.jDevice.getAxisPosition(2);
                case 'z'
                    dReturn = this.jDevice.getAxisPosition(3);
                case 'rx'
                    dReturn = this.jDevice.getAxisPosition(4);
                case 'ry'
                    dReturn = this.jDevice.getAxisPosition(5);
                case 'rz'
                    dReturn = this.jDevice.getAxisPosition(6);
            end

            
        end
        
        function set(this, cAxis, dVal)
            
            % @parameter cAxis 'x', 'rx', 'ry'
            % @parameter dVal
            
            switch cAxis
                case 'x'
                    this.jDevice.setAxisPosition(1, dVal);
                case 'y'
                    this.jDevice.setAxisPosition(2, dVal);
                case 'z'
                    this.jDevice.setAxisPosition(3, dVal);
                case 'rx'
                    this.jDevice.setAxisPosition(4, dVal);
                case 'ry'
                    this.jDevice.setAxisPosition(5, dVal);
                case 'rz'
                    this.jDevice.setAxisPosition(6, dVal);
            end
        end
        
        function stop(this, cAxis)
            
            
            switch cAxis
                case 'x'
                    this.jDevice.stopAxisMove(1);
                case 'y'
                    this.jDevice.stopAxisMove(2);
                case 'z'
                    this.jDevice.stopAxisMove(3);
                case 'rx'
                    this.jDevice.stopAxisMove(4);
                case 'ry'
                    this.jDevice.stopAxisMove(5);
                case 'rz'
                    this.jDevice.stopAxisMove(6);
            end
        end
        
        
        function turnOn(this)
            
            this.hioA.turnOn();
            this.hioB.turnOn();
            this.hiotC.turnOn();
            this.doideD.turnOn();
            this.diodeE.turnOn();
            
        end

        function turnOff(this)
            
            this.hioA.turnOff();
            this.hioB.turnOff();
            this.hiotC.turnOff();
            this.doideD.turnOff();
            this.diodeE.turnOff();
            
        end
        
    end
    
    methods (Access = protected)
                
        % Overload
        
        function turnOffHardwareIO(this)
            
            this.hioA.turnOff();
            this.hioB.turnOff();
            this.hiotC.turnOff();
            this.doideD.turnOff();
            this.diodeE.turnOff();
            
        end
        
        % Overload
        
        function turnOnHardwareIO(this)
            
            this.hioA.turnOn();
            this.hioB.turnOn();
            this.hiotC.turnOn();
            this.doideD.turnOn();
            this.diodeE.turnOn();
            
        end
        
        
    end % protected
    
    
    methods (Access = private)
        
                
        function handleConnect(this, src, evt)
            
            
        end
        
        function handleDisconnect(this, src, evt)
            
            
        end
            
        
    end
    
    
end