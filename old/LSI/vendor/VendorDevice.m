classdef VendorDevice < handle
    
    % Assume this is a black-box 
    
    properties
    end
    
    properties (Access = private)
         
        dMeanX = 5;
        dMeanY = 10;
        dSig = 0.5;
        lAwesome = false;
        
        ceModes = { ...
            'Mode 1', ...
            'Mode 2', ...
            'Mode 3' ...
        }
    
    end
    
    methods
        
        function this = VendorDevice()
            
        end
            
        % @return {double 1x1}
        function d = getXPosition(this)
            d = this.dMeanX + this.dSig * randn(1);
            fprintf('VendorDevice getXPosition()\n');
        end
        
        function setXPosition(this, dVal)
            this.dMeanX = dVal;
            fprintf('VendorDevice setXPosition(%1.3f)\n', dVal);
        end
        
        % @return {double 1x1}
        function d = getYPosition(this)
            d = this.dMeanY + this.dSig * randn(1);
            fprintf('VendorDevice getYPosition()\n');
        end
        
        
        function setYPosition(this, dVal)
            this.dMeanY = dVal;
            fprintf('VendorDevice setYPosition(%1.3f)\n', dVal);
        end
        
        % @return {char 1xm}
        function c = getMode(this)
            u8Idx = ceil(rand(1) * 3);
            c = this.ceModes{u8Idx};
            fprintf('VendorDevice getMode()\n');
        end
        
        function turnOnAwesome(this)
            this.lAwesome = true;
            fprintf('VendorDevice turnOnAwesome()\n');
        end
        
        function turnOffAwesome(this)
            this.lAwesome = false;
            fprintf('VendorDevice turnOffAwesome()\n');
        end
        
        function l = getAwesomeState(this)
            l = this.lAwesome;
            fprintf('VendorDevice getAwesomeState()\n');
        end
        
    end
    
end

