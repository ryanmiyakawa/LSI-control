classdef ProcessTool < HandlePlus
    
    % rcs
    
	properties
        
        uieUser
        uieBase                 % checkbox
        uieUL1Name
        uieUL1Thick
        uieUL1PABTemp
        uieUL1PABTime
        uieUL2Name
        uieUL2Thick
        uieUL2PABTemp
        uieUL2PABTime
        uieResistName
        uieResistThick
        uieResistPABTemp
        uieResistPABTime
        uieResistPEBTemp
        uieResistPEBTime
        uieDevName
        uieDevTime
        uieRinseName
        uieRinseTime
        dWidth = 335
        dHeight = 400
  
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        hPanel
        hAxes
        uitPre
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = ProcessTool()
            
            this.init();
            
        end
        
        
        function makePre(this)
            % hide everything
            this.hideAll();
            if ishandle(this.hPanel)
                set(this.hPanel, 'BackgroundColor', Utils.dColorPre);
            end
            this.uitPre.show();
            
        end
        
        function makeActive(this)
            this.showAll();
            if ishandle(this.hPanel)
                set(this.hPanel, 'BackgroundColor', Utils.dColorActive);
            end
            this.uitPre.hide();
        end
        
        %{
        function makePost(this)
            this.showAll();
            this.styleVerifiedAll();
            if ishandle(this.hPanel)
                set(this.hPanel, 'BackgroundColor', Utils.dColorPost);
            end
            this.uitPre.hide();
        end
        %}
                
        function build(this, hParent, dLeft, dTop)
                        
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Process',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
			drawnow;
                        
           
            dPadX = 10;
            dWidthName = 120;
            dWidthThick = 55;
            dWidthTemp = 55;
            dWidthTime = 55;
                     
            dTop = 20;
            dSep = 55;

            

            % Build filter Hz, Volts scale and time step

            
            this.uieUser.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                Utils.dEDITHEIGHT ...
            );
        
            dTop = dTop + dSep;
            
            this.uieUL1Name.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieUL1Thick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieUL1PABTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieUL1PABTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                Utils.dEDITHEIGHT ...
            );
        
        
        
            dTop = dTop + dSep;
            
            this.uieUL2Name.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieUL2Thick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieUL2PABTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieUL2PABTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                Utils.dEDITHEIGHT ...
            );
        
            dTop = dTop + dSep;
            
            this.uieResistName.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieResistThick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieResistPABTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieResistPABTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                Utils.dEDITHEIGHT ...
            );
        
            
        
        
            dTop = dTop + dSep;
            
            
            this.uieResistPEBTemp.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthTemp, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieResistPEBTime.build( ...
                this.hPanel, ...
                2*dPadX + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                Utils.dEDITHEIGHT ...
            );
        
        
            dTop = dTop + dSep;
            
            this.uieDevName.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieDevTime.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthTime, ...
                Utils.dEDITHEIGHT ...
            );
        
            dTop = dTop + dSep;
            
            this.uieRinseName.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                Utils.dEDITHEIGHT ...
            );
        
            this.uieRinseTime.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthTime, ...
                Utils.dEDITHEIGHT ...
            );
        
            %{
            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position', Utils.lt2lb([0 0 this.dWidth this.dHeight], this.hPanel),...
                'XColor', [0 0 0], ...
                'YColor', [0 0 0], ...
                'HandleVisibility','on', ...
                'DataAspectRatio', [1 1 1], ...
                'PlotBoxAspectRatio', [this.dWidth this.dHeight 1], ...
                'Visible', 'off' ...  % prevents axis lines, tick marks, and labels from being displayed; does not affect children of axes
            );
        
            % Draw a patch on the axes that is transparent
            
            dL = 0;
            dR = this.dWidth;
            dT = this.dHeight;
            dB = 0;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb(0.4, 1, 1), ...
                'Parent', this.hAxes, ...
                'FaceAlpha', 0.3 ...
            );
        
            uistack(this.hAxes, 'top');
            %}
        
            
            this.uitPre.build( ...
                this.hPanel, ...
                0, ...
                0, ...
                this.dWidth, ...
                this.dHeight ...
            );
            this.uitPre.hide();
                           
        end
        
        function show(this)            

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
            end

        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
        
        
        
        function handleClock(this)
            
            
            
            
        end
        
            

    end
    
    methods (Access = private)
        
        function init(this)
            
            this.uieUser            = UIEdit('User', 'c');
            this.uieBase            = UIEdit('Base', 'c');              
            this.uieUL1Name         = UIEdit('UL 1', 'c');
            this.uieUL1Thick        = UIEdit('Thick (nm)', 'u8');
            this.uieUL1PABTemp      = UIEdit('PAB Temp', 'u8');
            this.uieUL1PABTime      = UIEdit('PAB Time', 'u8');
            this.uieUL2Name         = UIEdit('UL 2', 'c');
            this.uieUL2Thick        = UIEdit('Thick (nm)', 'u8');
            this.uieUL2PABTemp      = UIEdit('PAB Temp', 'u8');
            this.uieUL2PABTime      = UIEdit('PAB Time', 'u8');
            this.uieResistName      = UIEdit('Resist', 'c');
            this.uieResistThick     = UIEdit('Thick (nm)', 'u8');
            this.uieResistPABTemp   = UIEdit('PAB Temp', 'u8');
            this.uieResistPABTime   = UIEdit('PAB Time', 'u8');
            this.uieResistPEBTemp   = UIEdit('PEB Temp', 'u8');
            this.uieResistPEBTime   = UIEdit('PEB Time', 'u8');
            this.uieDevName         = UIEdit('Dev', 'c');
            this.uieDevTime         = UIEdit('Dev Time', 'u8');
            this.uieRinseName       = UIEdit('Rinse Name', 'c');
            this.uieRinseTime       = UIEdit('Rinse Time', 'u8');
            
            this.uitPre             = UIText('1. Process', 'center', 'bold', 20);
            
            % Defaults
            this.uieUser.setVal('Development');
            this.uieUL1Name.setVal('NCX011');
            this.uieUL1Thick.setVal(uint8(20));
            this.uieUL1PABTemp.setVal(uint8(200));
            this.uieUL1PABTime.setVal(uint8(90));
            this.uieResistName.setVal('Fuji-1201E');
            this.uieResistThick.setVal(uint8(35));
            this.uieResistPABTemp.setVal(uint8(110));
            this.uieResistPABTime.setVal(uint8(60));
            this.uieResistPEBTemp.setVal(uint8(100));
            this.uieResistPEBTime.setVal(uint8(60));
            this.uieDevName.setVal('MF26A');
            this.uieDevTime.setVal(uint8(30));
            this.uieRinseName.setVal('DIH20');
            this.uieRinseTime.setVal(uint8(30));
            
        end
        
        
        function handleCloseRequestFcn(this, src, evt)
           
        end
        
        function hideAll(this)
            
            this.uieUser.hide();
            this.uieBase.hide();             % checkbox
            this.uieUL1Name.hide();
            this.uieUL1Thick.hide();
            this.uieUL1PABTemp.hide();
            this.uieUL1PABTime.hide();
            this.uieUL2Name.hide();
            this.uieUL2Thick.hide();
            this.uieUL2PABTemp.hide();
            this.uieUL2PABTime.hide();
            this.uieResistName.hide();
            this.uieResistThick.hide();
            this.uieResistPABTemp.hide();
            this.uieResistPABTime.hide();
            this.uieResistPEBTemp.hide();
            this.uieResistPEBTime.hide();
            this.uieDevName.hide();
            this.uieDevTime.hide();
            this.uieRinseName.hide();
            this.uieRinseTime.hide();
            
        end
        
        
        function showAll(this)
            
            this.uieUser.show();
            this.uieBase.show();             
            this.uieUL1Name.show();
            this.uieUL1Thick.show();
            this.uieUL1PABTemp.show();
            this.uieUL1PABTime.show();
            this.uieUL2Name.show();
            this.uieUL2Thick.show();
            this.uieUL2PABTemp.show();
            this.uieUL2PABTime.show();
            this.uieResistName.show();
            this.uieResistThick.show();
            this.uieResistPABTemp.show();
            this.uieResistPABTime.show();
            this.uieResistPEBTemp.show();
            this.uieResistPEBTime.show();
            this.uieDevName.show();
            this.uieDevTime.show();
            this.uieRinseName.show();
            this.uieRinseTime.show();
            
        end
        
        function styleVerifiedAll(this)
            
            this.uieUser.styleVerified();
            this.uieBase.styleVerified();             
            this.uieUL1Name.styleVerified();
            this.uieUL1Thick.styleVerified();
            this.uieUL1PABTemp.styleVerified();
            this.uieUL1PABTime.styleVerified();
            this.uieUL2Name.styleVerified();
            this.uieUL2Thick.styleVerified();
            this.uieUL2PABTemp.styleVerified();
            this.uieUL2PABTime.styleVerified();
            this.uieResistName.styleVerified();
            this.uieResistThick.styleVerified();
            this.uieResistPABTemp.styleVerified();
            this.uieResistPABTime.styleVerified();
            this.uieResistPEBTemp.styleVerified();
            this.uieResistPEBTime.styleVerified();
            this.uieDevName.styleVerified();
            this.uieDevTime.styleVerified();
            this.uieRinseName.styleVerified();
            this.uieRinseTime.styleVerified();
            
        end

    end % private
    
    
end