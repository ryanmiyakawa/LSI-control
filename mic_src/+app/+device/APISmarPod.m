% Needs to interpret the following commands from 
% HexapodBridge < mic.interface.device.GetSetNumber
%
% getPositions_mm
% setPositions_mm
% isReady()
% isInitialized()
% stop()
%
% But also should have 



classdef APISmarPod < app.javaAPI.CXROJavaStageAPI
  
    properties
        hInstruments
        lIsConnected = false;
    end

    methods 
        
        function this = APISmarPod(hInstruments)
            this.hInstruments = hInstruments;
            this.init();
        end
        
        function init(this)
        end
        
        function connect(this)
            this.jStage = this.hInstruments.getLsiHexapod();
            this.jStage.connect();
            this.lIsConnected = true;
        end
        
        function lConnected = isConnected(this)
            lConnected = this.lIsConnected;
        end


    end
        

end