classdef WaferLeveler < HandlePlus
    
    % rcs
    
    properties (Constant)
      
        dWidth          = 425
        dHeight         = 340
        dTargetWidth    = 80;
        
    end
    
	properties
        
        wcs
        hs
        setup
        cName
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        cl
        dDelay = 0.5
        uibLevel
        
        
        hPanelTargets
        uitTargets
        uieCh1
        uieCh2
        uieCh3
        uieCh4
        uieCh5
        uieCh6
        
        uitStatus
        hPanel
        uibSetup
        cDir
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = WaferLeveler(cl, cName)
            
            this.cl = cl;
            this.cName = cName;
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            
            %{
            if ~exist('cJavaName', 'var')
                cJavaName = this.cJavaName;
            end
            %}
            

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Leveler',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
                
			drawnow;
            
            dTop = 20;
            dPad = 10;
            
            % Level button
            this.uibLevel.build(this.hPanel, ...
                dPad, ...
                dTop, ...
                this.hs.dWidth + this.dTargetWidth + dPad, ...
                Utils.dEDITHEIGHT);
            
            
            
            dTop = dTop + Utils.dEDITHEIGHT + dPad;
            dLeft = this.hs.dWidth + 2*dPad;
            
            % Build HS
            this.hs.build(this.hPanel, dPad, dTop);
            
            this.hPanelTargets = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Targets',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dTargetWidth this.hs.dHeight], this.hPanel) ...
            );
                        
            
            dOffset = 65;
            dSep = 28;
            dTextWidth = 50;
            
            % Setup button
            
            this.uibSetup.build(this.hPanelTargets, ...
                dPad, ...
                20, ...
                24, ...
                24);
            
            this.uitTargets.build(this.hPanelTargets, dLeft, dOffset + -0.75*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uieCh1.build(this.hPanelTargets, dPad, dOffset + 0*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uieCh2.build(this.hPanelTargets, dPad, dOffset + 1*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uieCh3.build(this.hPanelTargets, dPad, dOffset + 2*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uieCh4.build(this.hPanelTargets, dPad, dOffset + 3*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uieCh5.build(this.hPanelTargets, dPad, dOffset + 4*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uieCh6.build(this.hPanelTargets, dPad, dOffset + 5*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            
            this.uitStatus.build(this.hPanel, dPad, this.dHeight - 30, this.dWidth - 2*dPad, Utils.dTEXTHEIGHT);           
            
        end
        
          
        
        function level(this)
            
            % TBD
            this.msg('level()');
            
            % As you level, change the this.uitStatus.cVal = 'New value' 
            
        end
        
        function lReturn = isLevel(this)
            
            % TBD
            
            lReturn = true;
            
        end
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            %{
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            %}
                        
            
        end
        
       
        
        function handleClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
                       
            
        end
        
            

    end
    
    methods (Access = private)
        
        function init(this)
            
            this.uibLevel = UIButton('Level', false);
            
            this.wcs = WaferCoarseStage(this.cl);
            this.hs = HeightSensor(this.cl);
            this.cl.add(@this.handleClock, this.id(), this.dDelay);
            this.setup = SetupWaferLeveler(this.cName);
            
            
            this.uitTargets = UIText('Targets', 'left');
            this.uieCh1 = UIText(num2str(this.setup.uieCh1.val()), 'left');
            this.uieCh2 = UIText(num2str(this.setup.uieCh2.val()), 'left');
            this.uieCh3 = UIText(num2str(this.setup.uieCh3.val()), 'left');
            this.uieCh4 = UIText(num2str(this.setup.uieCh4.val()), 'left');
            this.uieCh5 = UIText(num2str(this.setup.uieCh5.val()), 'left');
            this.uieCh6 = UIText(num2str(this.setup.uieCh6.val()), 'left');
            
            this.uitStatus = UIText('Status...', 'left');
            
            
            this.uibSetup = UIButton( ...
                'Setup', ...
                true, ...
                imread(sprintf('%s../assets/settings-24.png', this.cDir)) ...
            );
            
            addlistener(this.uibLevel, 'eChange', @this.handleLevelButton);
            addlistener(this.uibSetup, 'eChange', @this.handleSetupButton);
            addlistener(this.setup, 'eChange', @this.handleSetup);
            
        end
        
        
        function handleLevelButton(this, src, evt)
            
            this.level();
            
        end
        
        function handleSetupButton(this, src, evt)
            this.setup.build();
        end
        
        function handleSetup(this, src, evt)
            
            this.uieCh1.cVal = num2str(this.setup.uieCh1.val());
            this.uieCh2.cVal = num2str(this.setup.uieCh2.val());
            this.uieCh3.cVal = num2str(this.setup.uieCh3.val());
            this.uieCh4.cVal = num2str(this.setup.uieCh4.val());
            this.uieCh5.cVal = num2str(this.setup.uieCh5.val());
            this.uieCh6.cVal = num2str(this.setup.uieCh6.val());
            
        end
        
        


    end % private
    
    
end