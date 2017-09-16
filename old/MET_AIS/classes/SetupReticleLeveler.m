classdef SetupReticleLeveler < HandlePlus
    
    

    %% Properties

    properties (Constant)
        dHeight = 240; % width of the UIElement
        dWidth = 140;  % height of the UIElement
    end

    properties (Dependent = true)
    end

    properties
        
        uieCap1
        uieCap2
        uieCap3
        uieCap4

        cName        % name identifier
    end

    properties (SetAccess = private)
    end

    properties (Access = private)
        hFigure
        cDir
        cSaveDir
        cSavePath
    end

    events
        
        eChange
        
    end 

    methods

        
        function this = SetupReticleLeveler(cName)
        
            this.cName = cName;
            this.init();
        end

        
        function init(this)
                        
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir       = cPath(1:end-length(cFile));
            this.cSaveDir   = sprintf('%s../save/setup-reticle-leveler', this.cDir);
            this.cSavePath  = sprintf('%s/%s.mat', this.cSaveDir, this.cName);
            
            % UIEdit
            this.uieCap1    = UIEdit('Cap1', 'd');
            this.uieCap2    = UIEdit('Cap1', 'd');
            this.uieCap3    = UIEdit('Cap1', 'd');
            this.uieCap4    = UIEdit('Cap1', 'd');

            % Defaults
            this.uieCap1.setVal(0);
            this.uieCap2.setVal(0);
            this.uieCap3.setVal(0);
            this.uieCap4.setVal(0);
            
            % Listeners        
            addlistener(this.uieCap1, 'eChange', @this.handleChange);
            addlistener(this.uieCap2, 'eChange', @this.handleChange);
            addlistener(this.uieCap3, 'eChange', @this.handleChange);
            addlistener(this.uieCap4, 'eChange', @this.handleChange);
            
            % Load stored data
            this.load();
            
            
        end
        
        function handleChange(this, src, evt)
            notify(this, 'eChange');
        end

        function build(this)
                
            if ishghandle(this.hFigure)
               this.closeRequestFcn();
               return;
            end

            dSep = 55;
            dTop = 10;
            dLeftCol1 = 20;
            dEditWidth = 100;


            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  this.cName,...
                'Position', [100 100 this.dWidth this.dHeight],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.cb ...
                );

            hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', '',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([0 0 this.dWidth this.dHeight], this.hFigure) ...
            );
            drawnow;


            this.uieCap1.build(hPanel, dLeftCol1, dTop + 0*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCap2.build(hPanel, dLeftCol1, dTop + 1*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCap3.build(hPanel, dLeftCol1, dTop + 2*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCap4.build(hPanel, dLeftCol1, dTop + 3*dSep, dEditWidth, Utils.dEDITHEIGHT);

        end
        
        
        function save(this)
            
            % Create a nested recursive structure of all public properties
            
            s = this.saveClassInstance();
            
            % Remove uilSaved from the structure.  We don't want to
            % overwrite the list of available prescriptions when one is
            % loaded
            
            s = rmfield(s, 'cName');
                        
            % Save
            
            if ~exist(this.cSaveDir, 'dir')
                mkdir(this.cSaveDir);
            end
            save(this.cSavePath, 's');
            
        end
        
        function load(this)
            
            if exist(this.cSavePath, 'file') ~= 0
                
                load(this.cSavePath); % populates s in local workspace
                this.loadClassInstance(s); 
            end
            
        end
       

        %% Modifiers

        %% Event handlers
        function cb(this, src, ~)
        %CB Callback that (for now) shuts down the UIelement
            switch src
                case this.hFigure
                    this.closeRequestFcn();
            end
        end

        function closeRequestFcn(this)
        
            %CLOSEREQUESTFCN Callback that shuts down the UIElement
            
            this.save();
            delete(this.hFigure);
        end

        %% Destructor
        function delete(this)
        %DELETE Class destructor
        %   DiodeSetup.delete()

            this.msg('delete()');
        end

    end
    
end
        
        
        