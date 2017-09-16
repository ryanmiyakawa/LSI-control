classdef UIPopup_AIS < HandlePlus
    
    % uip
    
    % This class creates an instance of a uicontrol style==popupmenu.  It
    % provides set logic for updating cdOptions or u8Selected so that these
    % properties stay valid as the list changes length.  It also provides a
    % val() method to return the selected value.  Like UIEdit, this is a
    % method since it can return a mixed type.  The cell array of options
    % can be any type (uint8, char, ....)
    
    properties (Constant)
        dHeight = 30;
    end
    
    properties
        
        ceOptions       % cell array of mixed type
        u8Selected      % get selected index (force uint8)
        % cSelected

    end
    
    properties (SetAccess = private)
    end
    
    properties (Access = private)
        
        hLabel
        hUI
        cLabel
        lShowLabel
        cbFcn
    end
    
    
    events
      eChange  
    end
    
    
    methods
        
       % constructor
       
       function this= UIPopup_AIS( ....
                ceOptions, ...
                cLabel, ...
                lShowLabel ...
                )
                        
            this.ceOptions = ceOptions;
            this.cLabel = cLabel;
            this.lShowLabel = lShowLabel;
            
       end
       
       function setCb(this, cb)
            this.cbFcn = cb;
           
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight)
           
           
           if this.lShowLabel
               
               this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'HorizontalAlignment', 'left'...
                );
           
                dTop = dTop + 15;
           end
           
           
           this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'BackgroundColor', 'white', ...
                'Position', Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'popupmenu', ...
                'String', this.ceOptions, ...
                'Callback', @this.cb, ...
                'HorizontalAlignment','left'...
            );
        
       end
       
       
       function cb(this, src, evt)
           
            switch src
                case this.hUI
                    this.u8Selected = uint8(get(src, 'Value'));
            end

            this.cbFcn();
       end
       
       
       % modifiers
       
       function set.ceOptions(this, ceVal)
          
           % prop
           if iscell(ceVal)
                this.ceOptions = ceVal;
                
                if ~isempty(this.u8Selected)
                    
                    % Correct for the case when the number of options has
                    % decreased to less than the active option before they
                    % were updated
                    
                    if this.u8Selected > length(this.ceOptions)                        
                        this.u8Selected = uint8(length(this.ceOptions));
                    end
                    
                    % Correct for the case when ceOptions was empty and it
                    % was just now filled.  For this case u8Selected would
                    % be 0 and would not make it into the above logic.
                    % Need to update u8Selected to 1
                    
                    if this.u8Selected == uint8(0) && ...
                       ~isempty(this.ceOptions)
                   
                        this.u8Selected = uint8(1);
                    end
                    
                else
                    this.u8Selected = uint8(1); % default
                end
                
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
                set(this.hUI, 'Value', this.u8Selected);
                set(this.hUI, 'String', this.ceOptions);               
           end
           
           
           notify(this,'eChange');
           
       end
       
       function set.u8Selected(this, u8Val)
           
           % prop
           if isinteger(u8Val)
               if(u8Val <= length(this.ceOptions))
                   this.u8Selected = u8Val;
                   % this.cSelected = this.ceOptions{this.u8Selected};
               end
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'Value', this.u8Selected);
           end
           
           notify(this,'eChange');
               
       end
       
       function out = val(this)
           
            % returns a mixed type (whatever type)
            out = this.ceOptions{this.u8Selected};
       end
    end
end