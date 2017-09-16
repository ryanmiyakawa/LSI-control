classdef D141 < HandlePlus
    
    properties (Constant)
               
    end
    
    
	properties
       
        hiot
        di
        
        
    end
    
    properties (SetAccess = private)
    
        dHeight
        dWidth
        
    end
    
    properties (Access = private)
         
        d141wago 
        d141vm
        hPanel
        uitConnect
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = D141(clock)
              
            % Call parent constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            
            this.d141wago   = D141Wago(clock);
            this.d141vm     = D141VoltMeter(clock);
                                   
            this.dWidth = 310;
            
            % Expose HIOT and Diode UI elements in a clean way
            
            this.hiot   = this.d141wago.hiot;
            this.di     = this.d141vm.di;
            
        end
        
        function build(this, hParent, dLeft, dTop)
                        
            dSep = 28;
            dTopPad = 20;
            dBotPad = 10;
            
            % Build panel
            
            this.dHeight = dTopPad + Utils.dEDITHEIGHT + 2*dSep + dBotPad;
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'D141',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;
            
            % Build connect button exposed from one of the base JavaDevice
            % instancees and set the uitConnect property of the other
            % JavaDevice instances to point to it so hitting connect once
            % connects all of the JavaDevice instances
            
            this.d141wago.uitConnectPublic.build( ...
                this.hPanel, ...
                10, ...
                dTopPad, ...
                50, ...
                Utils.dEDITHEIGHT); 
            
            this.d141vm.uitConnectPublic      = this.uitConnect;
            
            % Build UI elements
            
            dOffset = dTopPad + Utils.dEDITHEIGHT + 5;
            this.hiot.build(this.hPanel, dLeft, dOffset + 0*dSep);
            this.di.build(this.hPanel, dLeft, dOffset + 1*dSep);
            
            
        end
               
    end
    
    methods (Access = protected)
        
                
    end
    
    methods (Access = private)
        
        

    end 
    
    
end