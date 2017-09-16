classdef APIHardwareOMod3 < HandlePlus
    
    % See hungarian.m for help on APIHardwareO* classes
    
    properties (Access = private)        
        
        cProp          % identifies method/params to call within parent hardware class
        parent         % Mod3 instance
        
    end

    methods

        function this = APIHardwareOMod3(parent, cProp)
            
            % cProp:
            % cap-1 ... cap-6
            % temp-1 ... temp-7
            
            this.parent = parent;
            this.cProp = cProp;
        end
        

        function dReturn = get(this)
            switch this.cProp
                case 'cap-1'
                    dReturn = this.parent.getCap(1);
                case 'cap-2'
                    dReturn = this.parent.getCap(2);
                case 'cap-3'
                    dReturn = this.parent.getCap(3);
                case 'cap-4'
                    dReturn = this.parent.getCap(4);
                case 'cap-5'
                    dReturn = this.parent.getCap(5);
                case 'cap-6'
                    dReturn = this.parent.getCap(6);   
                case 'temp-1'
                    dReturn = this.parent.getTemp(1);
                case 'temp-2'
                    dReturn = this.parent.getTemp(2);
                case 'temp-3'
                    dReturn = this.parent.getTemp(3);
                case 'temp-4'
                    dReturn = this.parent.getTemp(4);
                case 'temp-5'
                    dReturn = this.parent.getTemp(5);
                case 'temp-6'
                    dReturn = this.parent.getTemp(6);
            end

        end

    end
    
end

