classdef _ReticleFineStage < JavaDevice
    
    % rcs
    
    properties (Constant)
       
        dWidth      = 310 
        dHeight     = 190
        
    end
    
	properties
        
        hioX
        hioY
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
        
        
        function this = ReticleFineStage(clock)
            
            this.clock = clock;
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
                        
            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Reticle Fine XYZ',...
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
            this.hioZ.build(this.hPanel, dLeft, dOffset + 2*dSep);
    
            
        end
        
                       
        function status(this)
                        
                       
        end
        
        
        % Expose hardware methods to the API
        
        function dReturn = get(this, cAxis)
            % @parameter cAxis 'x', 'y', 'z' 
            dReturn = this.jDevice.get(cAxis);
        end
        
        function set(this, cAxis, dVal)
            
            % @parameter cAxis 'x', 'y', 'z'
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
    
    methods (Access = private)
        
        function init(this)
            
            
            this.cJarPath           = fullfile(pwd, 'ReticleFineStageProxy.jar');
            this.cPackage           = 'cxro.common.device';
            
            % Todo: get string identifier of stage
            this.cConstructFcn      = 'ReticleFineStage(''M141-Stage'',''iman.lbl.gov'')';
            this.cConnectFcn        = 'enableAxes()';
            this.cDisconnectFcn     = 'disableAxes()';
                        
            addlistener(this, 'eConnect', @this.handleConnect);
            addlistener(this, 'eDisconnect', @this.handleDisconnect);
                        
            this.hioX = HardwareIO('Reticle-Fine-X', this.clock, 'X');
            this.hioY = HardwareIO('Reticle-Fine-Y', this.clock, 'Y');
            this.hioZ = HardwareIO('Reticle-Fine-Z', this.clock, 'Z');
            
            this.hioX.setup.uieStepRaw.setVal(10e-9);
            this.hioY.setup.uieStepRaw.setVal(10e-9);
            this.hioZ.setup.uieStepRaw.setVal(10e-9);

            this.hioX.api = APIHardwareIOStageXYZRxRyRz(this, 'x');
            this.hioY.api = APIHardwareIOStageXYZRxRyRz(this, 'y');
            this.hioZ.api = APIHardwareIOStageXYZRxRyRz(this, 'z');
           

        end
        
        function handleConnect(this, src, evt)
            
                
        end
        
        
        function handleDisconnect(this, src, evt)
            
            
        end
        
    end
    
    methods (Access = protected)
        
        
        function turnOffHardware(this)
            
            this.hioX.turnOff();
            this.hioY.turnOff();
            this.hioZ.turnOff();

        end
        
        function turnOnHardware(this)
            
            this.hioX.turnOn();
            this.hioY.turnOn();
            this.hioZ.turnOn();
            
        end        
        
        

    end % private
    
    
end