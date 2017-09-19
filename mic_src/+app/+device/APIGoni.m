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



classdef APIGoni < app.javaAPI.CXROJavaStageAPI
  
    properties
        hInstruments
    end

    methods 
        
        function this = APIGoni()
        % This API should be instatiated once, and only once, to avoid 
        % instabilities
        
            this.init();
        end
        
        function init(this)
        %INIT Loads the library and initializes the connection to the stage
        %   api.init()
        %
        % See also CONNECT, DELETE
        
            %Always make sure you're in the right folder : Matlab crash o/w
            path = pwd;
            
            %load the library
            javaclasspath(strcat(path,...
                filesep,'Met5Instruments.jar'));
            import cxro.met5.Instruments.*;
            import java.util.concurrent.Future;
            
            % instruments:
            this.hInstruments = cxro.met5.Instruments();
            %connect to the stage
            this.connect(this.hInstruments);
            this.jStage = instruments.getLsiGoniometer();
            this.jStage.connect();
            
            
        end
              


    end
        

end