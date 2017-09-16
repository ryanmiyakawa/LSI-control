classdef UIEdit_AIS < HandlePlus

   
        %% properties
    properties (Constant, Access = private)
        dHeight = 18;
    end
    
    


    properties

        cData = ''  %this is what the textbox contains. feel free to access it directly...
        value
    end


    properties (Access = private)
        cLabel
        cbFcn
        lShowLabel
        hLabel
        hUI % made private 2013.06.11 % made setAccess private 3013/06/20
    end


    properties (SetAccess = private)
        
            % mixed type to store typecast version of cData

    end


    events
        
    end

    %%
    methods
        
        %% constructor
        function this= UIEdit_AIS(cLabel, dValue, lShowLabel)

            if exist('lShowLabel', 'var') ~= 1
                lShowLabel = true;
            end

            this.cLabel = cLabel;
            this.lShowLabel = lShowLabel;
            this.value = dValue;
            this.cData = num2str(this.value);

        end
        
        function setCBFcn(this, cb)
            this.cbFcn = cb;
        end
        
        function setVal(this, val)
            this.value = val;
            this.cData = num2str(this.value);
        end
        function val = getVal(this)
            if ~isempty(this.hUI)
                this.cData = get(this.hUI, 'String');
                this.value = str2double(this.cData);
            end
            val = this.value;
        end
        
        function cb(this, src, evt)
            this.cbFcn();
        end
       

        %% Build
        function build(this, hParent, dLeft, dTop, dWidth, dHeight)

            if this.lShowLabel
                this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'HorizontalAlignment', 'left' ...
                );

                %'BackgroundColor', [1 1 1] ...
            
                dTop = dTop + 13;
            end

            this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'BackgroundColor', [1 1 1], ...
                'Position', Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'edit', ...
                'String', this.cData, ...
                'Callback', @this.cb, ...
                'HorizontalAlignment','left' ...
            );
        
            %'BackgroundColor', [1 1 1] ...

        end

        

       



        %% Destructor ?
        function delete(this)
            
            % this.msg('delete');
            
        %     if ~isempty(this.hUI)
        %         delete(this.hUI);
        %     end
        end

        

    end
end