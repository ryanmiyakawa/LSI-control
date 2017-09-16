classdef APIVHardwareIOToggle < HandlePlus

    % apiv

    properties (Access = private)
        
    end


    properties

        lVal = false

    end

            
    methods
        
        function this = APIVHardwareIOToggle()

        end

        function lReturn = get(this)
            lReturn = this.lVal;
        end


        function set(this, lVal)
            this.lVal = lVal;
        end 


    end %methods
end %class
    

            
            
            
        