classdef SetupWaferLeveler < HandlePlus
    
    

    %% Properties

    properties (Constant)
        dHeight = 350; % width of the UIElement
        dWidth = 140;  % height of the UIElement
    end

    properties (Dependent = true)
    end

    properties
        
        uieCh1
        uieCh2
        uieCh3
        uieCh4
        uieCh5
        uieCh6

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

        
        function this = SetupWaferLeveler(cName)
        
            this.cName = cName;
            this.init();
        end

        
        function init(this)
                        
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir       = cPath(1:end-length(cFile));
            this.cSaveDir   = sprintf('%s../save/setup-wafer-leveler', this.cDir);
            this.cSavePath  = sprintf('%s/%s.mat', this.cSaveDir, this.cName);
            
            % UIEdit
            this.uieCh1    = UIEdit('Ch. 1', 'd');
            this.uieCh2    = UIEdit('Ch. 2', 'd');
            this.uieCh3    = UIEdit('Ch. 3', 'd');
            this.uieCh4    = UIEdit('Ch. 4', 'd');
            this.uieCh5    = UIEdit('Ch. 5', 'd');
            this.uieCh6    = UIEdit('Ch. 6', 'd');
            
            % Defaults
            this.uieCh1.setVal(0);
            this.uieCh2.setVal(0);
            this.uieCh3.setVal(0);
            this.uieCh4.setVal(0);
            this.uieCh5.setVal(0);
            this.uieCh6.setVal(0);
            
            % Listeners        
            addlistener(this.uieCh1, 'eChange', @this.handleChange);
            addlistener(this.uieCh2, 'eChange', @this.handleChange);
            addlistener(this.uieCh3, 'eChange', @this.handleChange);
            addlistener(this.uieCh4, 'eChange', @this.handleChange);
            addlistener(this.uieCh5, 'eChange', @this.handleChange);
            addlistener(this.uieCh6, 'eChange', @this.handleChange);
            
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


            this.uieCh1.build(hPanel, dLeftCol1, dTop + 0*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCh2.build(hPanel, dLeftCol1, dTop + 1*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCh3.build(hPanel, dLeftCol1, dTop + 2*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCh4.build(hPanel, dLeftCol1, dTop + 3*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCh5.build(hPanel, dLeftCol1, dTop + 4*dSep, dEditWidth, Utils.dEDITHEIGHT);
            this.uieCh6.build(hPanel, dLeftCol1, dTop + 5*dSep, dEditWidth, Utils.dEDITHEIGHT);

        
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
        
        
        