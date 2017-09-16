classdef ReticleLeveler < HandlePlus
    
    % rcs
    
    properties (Constant)
      
        dWidth          = 425
        dHeight         = 280
        dTargetWidth    = 80;
        
    end
    
	properties
        
        rcs
        mod3
        setup
        cName
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        cl
        dDelay = 0.5
        uibLevel
        uitCap1
        uitCap2
        uitCap3
        uitCap4
        uitTargets
        uitStatus
        hPanel
        hPanelTargets
        uibSetup
        cDir
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = ReticleLeveler(cl, cName)
            
            this.cl = cl;
            this.cName = cName;
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            

            % Panel
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Reticle Leveler',...
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
                this.mod3.dWidth + this.dTargetWidth + dPad, ...
                Utils.dEDITHEIGHT);
            
            
            
            dTop = dTop + Utils.dEDITHEIGHT + dPad;
            dLeft = this.mod3.dWidth + 2*dPad;
            
            % Build Mod3
            this.mod3.build(this.hPanel, dPad, dTop);
            
            this.hPanelTargets = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Targets',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dTargetWidth this.mod3.dHeight], this.hPanel) ...
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
            this.uitCap1.build(this.hPanelTargets, dPad, dOffset + 0*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uitCap2.build(this.hPanelTargets, dPad, dOffset + 1*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uitCap3.build(this.hPanelTargets, dPad, dOffset + 2*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uitCap4.build(this.hPanelTargets, dPad, dOffset + 3*dSep, dTextWidth, Utils.dTEXTHEIGHT);
            this.uitStatus.build(this.hPanel, dPad, this.dHeight - 30, this.dWidth - 2*dPad, Utils.dTEXTHEIGHT);           
            
        end
        
          
        
        function level(this)
            
            % TBD
            this.msg('ReticleLever.level()');
            
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
            
           
            this.rcs = ReticleCoarseStage(this.cl);
            this.mod3 = Mod3(this.cl);
            this.cl.add(@this.handleClock, this.id(), this.dDelay);
            this.setup = SetupReticleLeveler(this.cName);
            
            this.uitCap1 = UIText(num2str(this.setup.uieCap1.val()), 'left');
            this.uitCap2 = UIText(num2str(this.setup.uieCap2.val()), 'left');
            this.uitCap3 = UIText(num2str(this.setup.uieCap3.val()), 'left');
            this.uitCap4 = UIText(num2str(this.setup.uieCap4.val()), 'left');
            this.uitTargets = UIText('Targets', 'left');
            this.uitStatus = UIText('Status...', 'left');
            
            this.uibLevel = UIButton('Level', false);
            
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
            
            
            this.uitCap1.cVal = num2str(this.setup.uieCap1.val());
            this.uitCap2.cVal = num2str(this.setup.uieCap2.val());
            this.uitCap3.cVal = num2str(this.setup.uieCap3.val());
            this.uitCap4.cVal = num2str(this.setup.uieCap4.val());
            
            
        end
        
        


    end % private
    
    
end