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



classdef APIReticle < app.javaAPI.CXROJavaStageAPI
  
    properties
        hInstruments
    end

    methods 
        
        function this = APIReticle(hInstruments)
        % This API should be instatiated once, and only once, to avoid 
        % instabilities
            this.hInstruments = hInstruments;
            this.init();
        end
        
        function init(this)
        end
        
        function connect(this)
            this.jStage = this.hInstruments.getReticle();
            this.jStage.connect();
        end


    end
        

end