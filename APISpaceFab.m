classdef APISpaceFab < InterfaceApiHardwareIOPlus
   
    properties    
        jStage = 0;
    end

    methods 
        
        function this = APISpaceFab()
        %APISPACEFAB API for SpaceFab stage    
        %   api = APISpaceFab() creates an instance of the api
        %         and connects to the stage (init)
        % This API should be instatiated once, and only once, to avoid 
        % instabilities
        %
        % See also APISPACEFAB_AXIS, INIT
        
            this.init();
        end
        
        function init(this)
        %INIT Loads the library and initializes the connection to the stage
        %   api.init()
        %
        % See also CONNECT, DELETE
        
            %Always make sure you're in the right folder : Matlab crash o/w
            path = fileparts(mfilename('fullpath'));
            %path = 'C:\Documents and Settings\msduser\My Documents\MATLAB\serm_mic';
            
            %load the library
            javaclasspath(strcat(path,...
                filesep,'SpaceFabStageLib-1.0.jar'));
            import cxro.serm.device.*;
            import cxro.common.device.*;
            import java.util.concurrent.Future;
            
            %connect to the stage
            this.connect();
        end
              
        function connect(this)
        %CONNECT Connects to the stage (instantiate the java object)
        %   use init( instead)
        %   api.connect()
        %
        % See also INIT, DISCONNECT
            this.jStage = cxro.serm.device.SpaceFabStage('cxro/serm/device/SpaceFab', 'COM4');
        end
        
        function disconnect(this)
        %DISCONNECT Closes the connection with stage
        % api.disconnect()
        %
        % See also CONNECT, DELETE
            this.API_close();
        end
        
        function out = get(this)
        %GET Reads the position on the first axis (in meters)
        %  pos_m = api.get() should be used only for troubleshooting purposes
        %  use GETAXISPOSITIONS_MM instead
        %
        % See also GETAXISPOSITIONS_MM, SET
        
            %giving a specific position
            out = this.getAxisPosition_mm(1)*1;
        end
        
        function set(this, val)
        %SET Moves the first axis to a given position (in meters)
        %   api.set(pos_m) should be used only for troubleshooting purposes
        %   use  setPositions instead
        %
        % See also SETPOSITIONS
            this.setAxisPosition(1,val);
        end
        
        function isReady = isReady(this) 
        %ISREADY check whether the stage is ready for motion
        %   api.isready()
        %
        % See also GET, SET, STOP, INDEX
        
        % true when stopped or at its target
            isReady = this.API_isReady();
        end

       function stop(this) % stop motion to destination
       %STOP Aborts motion on all axes
       %    api.stop()
       %
       % See also GET, SET, ISREADY, INDEX
           this.API_abortMove();
       end
       
       function index(this) % index
       %INDEX Homes the stage on all axes
       %    api.index()
       %
       % See also GET, SET, ISREADY,STOP
       
           this.API_homeStage();
       end
        
        function position_mm =  getAxisPosition_mm(this, axis)
        %GETAXISPOSITION_MM Gets the position of a single axis
        %   position_mm =  api.getAxisPosition_mm(axis)
        %       returns the position of a given axis in mm
        %
        % See also GETPOSITIONS_MM, SETAXISPOSITION_MM
            
            positions_mm = this.API_getStagePosition();
            position_mm = positions_mm(axis);
        end
        
        function positions = getPositions_mm(this)
        %GETPOSITIONS_MM Gets the position of all axes
        %   position_mm =  api.getAxisPosition_mm(axis)
        %       returns the position of all axes in mm, as an array
        %
        % See also GETAXISPOSITIONS_MM, SETPOSITIONS_MM
        
            positions = this.API_getStagePosition();
        end
        
        
        function setPositions_mm(this, val_array_mm)
        %SETPOSITIONS Moves the stage on all axes
        %   api.setPositions(positions_mm)
        %
        % See also SETAXISPOSITION
        
            this.API_moveStageAbsolute(val_array_mm);
        end
        
        function setAxisPosition_mm(this,axis,value)
        %SETAXISPOSITION_MM Moves one axis of the stage
        %   api.setAxisPositions(axis positions_mm)
        %
        % See also SETAXISPOSITION_MM, GETAXISPOSITION_MM
            pos_mm = this.getPositions_mm();
            pos_mm(axis) = value;
            this.API_moveStageAbsolute(pos_mm);
        end
        

        function delete(this)
        %DELETE Closes the connection with stage
            this.disconnect();
        end
        
    end
%%
    methods (Access = private)
        
        function positions_mm = API_getStagePosition(this)
            if ~isempty(this.jStage)
                positions_mm = this.jStage.getStagePosition;
            else
                positions_mm = -ones(6,1);
            end
        end
        
        function API_abortMove(this)
            if ~isempty(this.jStage)
                this.jStage.abortMove();
            end
        end
        
        function API_connect(this)
            if ~isempty(this.jStage)
                this.jStage.connect();
            end
        end
        
        function API_close(this)
            if ~isempty(this.jStage)
                this.jStage.close();
            end
        end
        
        function jFut = API_moveStageAbsolute(this, val)
            % vals are an array of positions
            if ~isempty(this.jStage)
                %false flag unknown reason
                jFut = this.jStage.moveStageAbsolute(val, false);
            end
        end
        
        function API_moveStageSequence(this, val)
            if ~isempty(this.jStage)
                this.jStage.moveStageSequence(val);
            end
        end
        
        function API_homeStage(this)
            if ~isempty(this.jStage)
                this.jStage.homeStage();
            end
        end
        
        function isInitialized = API_isInitialized(this)
            if ~isempty(this.jStage)
                isInitialized = this.jStage.isInitialized();
            end
        end
        
        function isReady = API_isReady(this)
            if ~isempty(this.jStage)
                isReady = this.jStage.isReady();
            end
        end
    end % methods private
end