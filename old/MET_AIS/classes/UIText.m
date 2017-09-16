classdef UIText < HandlePlus
    
    % uitx
    
    % meant to be inside of a panel.  Matlab makes the default background
    % color of a uicontrol('text') the same as panels
    
    properties (Constant)
       
    end
    
      
    properties
        cVal
    end
    
    
    properties (Access = private)
        hUI
        cHorizontalAlignment
        cFontWeight
        dFontSize
        
    end
    
    
    events

    end
    
    
    methods
        
       % constructor
       
       function this = UIText(cVal, cHorizontalAlignment, cFontWeight, dFontSize)
           
            % defaults
            if exist('cHorizontalAlignment', 'var') ~= 1
                cHorizontalAlignment = 'left';
            end
            
            if exist('cFontWeight', 'var') ~= 1
                cFontWeight = 'normal';
            end
            
            if exist('dFontSize', 'var') ~= 1
                dFontSize = 10;
            end
            
            
           this.cVal = cVal;
           this.cHorizontalAlignment = cHorizontalAlignment;
           this.cFontWeight = cFontWeight;
           this.dFontSize = dFontSize;
            
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
                                  
            this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'HorizontalAlignment', this.cHorizontalAlignment, ...
                'FontWeight', this.cFontWeight, ...
                'FontSize', this.dFontSize, ...
                'Position', Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'text', ...
                'String', this.cVal ...
                );
       end
       
       
       function set.cVal(this, cVal)
           
           % prop
           if ischar(cVal)
               this.cVal = cVal;
           else
               cMsg = sprintf('UIText.set.cVal() requires type "char".  You supplied type "%s".  Not overwriting the cVal property.', ...
                   class(cVal) ...
                   );
               cTitle = 'UIText.set.sVal() error';
               msgbox(cMsg, cTitle, 'warn');
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'String', this.cVal);
           end
            
           
       end
       
       
       function show(this)
    
            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'off');
            end

        end
       
       
        
    end
end