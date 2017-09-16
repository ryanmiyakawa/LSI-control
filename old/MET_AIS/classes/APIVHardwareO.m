classdef APIVHardwareO < HandlePlus

    % apivho

    properties (Access = private)
        cl                      % Clock
        dPeriod = 100/1000;
    end


    properties

        cName
        dPos 

    end

            
    methods
        
        function this = APIVHardwareO(cName, cl)

            this.cName = cName;
            this.cl = cl; 
            this.cl.add(@this.handleClock, this.id(), this.dPeriod);

        end

        function dReturn = get(this)
            dReturn = this.dPos;
        end

        function handleClock(this)

            this.dPos = 5 + 0.3*rand(1);
        end
            
        function delete(this)

            this.msg('APIVHardwareO.delete()');

            % Clean up clock tasks
            if isvalid(this.cl) && ...
               this.cl.has(this.id())
                this.cl.remove(this.id());
            end

        end

    end %methods
end %class
    

            
            
            
        