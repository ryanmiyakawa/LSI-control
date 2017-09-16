classdef APIHardwareOHeightSensor < HandlePlus
    
    % See hungarian.m for help on APIHardwareO* classes
    
    properties (Access = private)        
        
        cProp       % identifies method/params to call within parent hardware class
        parent          % Mod3 instance
        
    end

    methods

        function this = APIHardwareOHeightSensor(parent, cProp)
            
            % cProp:
            % ch1, ch2, ... ch6
            
            this.parent = parent;
            this.cProp = cProp;
        end
        

        function dReturn = get(this)
            switch this.cProp
                case 'ch1'
                    dReturn = this.parent.get(1);
                case 'ch2'
                    dReturn = this.parent.get(2);
                case 'ch3'
                    dReturn = this.parent.get(3);
                case 'ch4'
                    dReturn = this.parent.get(4);
                case 'ch5'
                    dReturn = this.parent.get(5);
                case 'ch6'
                    dReturn = this.parent.get(6);   
                
            end

        end

    end
    
end

