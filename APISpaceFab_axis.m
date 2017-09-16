classdef APISpaceFab_axis < InterfaceApiHardwareIOPlus
    
    properties
        api;        %APISPACEFAB instance
        axis_nb;    %Axis number (1-6)
    end
   
    methods
        function this = APISpaceFab_axis(api_spacefab, axis)
        %APISPACEFAB_AXIS API for individual axes of the SpaceFab stage    
        %   APISpaceFab_axis(api_spacefab, axis)
        %       where api_spacefab is the main SpaceFab stage API
        %       and axis the number of the axis to control (1-6)
        %
        % See also APISPACEFAB
        
            this.api     = api_spacefab;
            this.axis_nb = axis;
        end
        
        function out = get(this)
        %GET Gets the position of the axis (in m)
        %   pos_mm = api.get()
        % See also SET, APISPACEFAB.SETPOSITIONS_MM
        
            %giving a specific position
            out = this.api.getAxisPosition_mm(this.axis_nb);
          
        end
        
        function set(this, val_mm)
        %SET Moves the axis to the specified position
        %   api.set(val_m)
        %
        % See also GET, APISPACEFAB.SETPOSITIONS_MM
            this.api.setAxisPosition_mm(this.axis_nb,  val_mm);
        end
        
       
        
        function isReady = isReady(this) % true when stopped or at its target
        %ISREADY Status of the stage
        %   isReady = api.isReady();
        %
        % See also INDEX, STOP
            isReady = this.api.isReady();
        end
        
        function stop(this) % stop motion to destination
        %STOP Abort motion on all axes
        %   api.stop()
        %
        % See also SET, ISREADY, INDEX
            this.api.stop();
        end
        
        function index(this) % index
        %INDEX Home all axes
        %   api.index
        %
        % See also ISREADY, STOP
            this.api.index();
        end
        
    end
end