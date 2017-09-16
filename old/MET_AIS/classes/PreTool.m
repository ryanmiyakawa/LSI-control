classdef PreTool < HandlePlus
    
    % A figure that lets you configure:
    %
    %   Process
    %   Reticle
    %   Pupilfill
    %   FEM
    %
    % in order to create a complete prescription for running the MET. It
    % lets you save the prescription and checks to make sure you don't
    % overwrite an existing file.  The entire goal is to save .mat files to
    % met5gui/prescriptions.
    % 
    % This panel does not contain a UIList with all of the available
    % prescriptinos. It is intended that the list is shown in the
    % ExptControl panel and all support code to handle deleting
    % prescriptions and such needs to live in ExptControl
    %
    % This method will dispatch eNew anytime a new pre is added and a
    % listener should tell ExptControl to append a new pre to the end of
    % its list
    % 
    % Later on, I might think it was dumb to not have the prescription list
    % here (for code organization purposes).  The decision, however, was
    % based on UX.  I want the "control" panel to feel like you are
    % choosing available prescriptions to add to your wafer, I don't want
    % it to feel like you have to go to the "PreTool" panel and "send" a
    % prescription over to the control panel. Either way the same code
    % needs to exist. 
    %
    % I think I moved away from this.
   
    
    properties (Constant)
       
        dWidth          = 1250
        dHeight         = 720
        
    end
    
	properties
        
        processTool              
        reticleTool                
        pupilFillSelect            
        femTool                  
                
    end
    
    properties (SetAccess = private)
    
        cSaveDir        = 'save/pre-tool'

    end
    
    properties (Access = private)
          
        hFigure
        hPanel
        hPanelSaved
        cDir
        uilSaved
        uibSave         % button for saving
    
    end
    
        
    events
        
        eDelete
        eSizeChange
        eNew
        
    end
    

    
    methods
        
        
        function this = PreTool()
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            this.init();
            
        end
        
                
        function build(this)
              
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            dScreenSize = get(0, 'ScreenSize');
            
            dPad = 10;
            dTop = 10;
            
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  'Build Prescription',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            drawnow;            
            
            %{
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Build Prescription',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidth ...
                    this.dHeight], hParent) ...
            );
            drawnow; 
            %}
                        
            % set(this.hFigure, 'renderer', 'OpenGL'); % Enables proper stacking
             
            %{
            dTop = 20;
            % Panel
            this.processTool.build( ...
                this.hPanel, ...
                dPad, ...
                dTop);
            this.reticleTool.build(...
                this.hPanel, ...
                dPad + this.processTool.dWidth + dPad, ...
                dTop);
            this.pupilFillSelect.build( ...
                this.hPanel, ...
                dPad + this.processTool.dWidth + dPad, ...
                dTop + this.reticleTool.dHeight + dPad);
            this.femTool.build( ...
                this.hPanel, ...
                dPad + this.processTool.dWidth + dPad + this.reticleTool.dWidth + dPad, ...
                dTop);
            this.uibSave.build( ...
                this.hPanel, ...
                dPad + this.processTool.dWidth + dPad + this.reticleTool.dWidth + dPad, ...
                dTop + this.femTool.dHeight + dPad, ...
                100, ...
                Utils.dEDITHEIGHT);
            %}
            
            % Figure
            
            
            this.processTool.build( ...
                this.hFigure, ...
                dPad, ...
                dTop);
            this.reticleTool.build(...
                this.hFigure, ...
                dPad + this.processTool.dWidth + dPad, ...
                dTop);
            this.pupilFillSelect.build( ...
                this.hFigure, ...
                dPad + this.processTool.dWidth + dPad, ...
                dTop + this.reticleTool.dHeight + dPad);
            this.femTool.build( ...
                this.hFigure, ...
                dPad + this.processTool.dWidth + dPad + this.reticleTool.dWidth + dPad, ...
                dTop);
            this.uibSave.build( ...
                this.hFigure, ...
                dPad + this.processTool.dWidth + dPad + this.reticleTool.dWidth + dPad, ...
                dTop + this.femTool.dHeight + dPad, ...
                this.femTool.dWidth, ...
                55);
            
            this.hPanelSaved = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Build Prescription',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([ ...
                    dPad ...
                    dTop + this.processTool.dHeight + 2*dPad ...
                    this.dWidth - 2*dPad ...
                    280], this.hFigure) ...
            );
            drawnow; 
            this.uilSaved.build( ...
                this.hPanelSaved, ...
                dPad, ...
                20, ...
                this.dWidth - 4*dPad, ...
                225);
            
            this.uilSaved.refresh();
            
                                  
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
            
            % Delete the figure
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
                        
        end
        
        
        function loadPre(cName)
            
            
 
        end
        
        function ceReturn = refreshSaved(this)
            
            cPath = fullfile(this.cDir, '..', this.cSaveDir);
            ceReturn = Utils.dir2cell(cPath, 'date', 'descend');
            
        end
                    

    end
    
    methods (Access = private)
        
        function init(this)
             
            this.processTool            = ProcessTool();
            this.reticleTool        = ReticleTool();
            this.pupilFillSelect    = PupilFillSelect();
            this.femTool            = FEMTool();
            this.uibSave            = UIButton('Save');
            addlistener(this.uibSave, 'eChange', @this.handleSave);
            
            %{
            this.ec                 = ExptControl();
            addlistener(this.ec, 'ePreChange', @this.handlePreChange);
            %}
            
            this.uilSaved   = UIList(cell(1,0), '', true, true, false, true);
            this.uilSaved.setRefreshFcn(@this.refreshSaved);
            
            addlistener(this.uilSaved, 'eDelete', @this.handleSavedDelete);
            addlistener(this.uilSaved, 'eChange', @this.handleSavedChange);
            
            
           
        end        
        
        
        function handleCloseRequestFcn(this, src, evt)
            delete(this.hFigure);
            % this.saveState();
        end
        
        
        function handleSave(this, src, evt)
            
            % Generate a suggestion for the filename
            % [yyyy-mm-dd]-[num]-[Resist]-[Reticle]-[Field]-[Illum
            % abbrev.]-[FEM rows x FEM cols]
            
           
            cResist = this.processTool.uieResistName.val();
            if (length(cResist) > 10)
                cResist = cResist(1:10);
            end
            
            cIllum = this.pupilFillSelect.cSelected;
            if (length(cIllum) > 10)
                cIllum = cIllum(1:10);
            end
            
           
            cName = sprintf('%s_%s_%s_%s_%s_%1dx%1d', ...
                datestr(now,'yymmdd-HHMM'), ...
                cResist, ...
                this.reticleTool.uipReticle.val(), ...
                this.reticleTool.uipField.val(), ...
                cIllum, ...
                length(this.femTool.dDose), ...
                length(this.femTool.dFocus) ...
            );
            
            
            if ~exist(this.cSaveDir, 'dir')
                mkdir(this.cSaveDir)
            end
                                
            
            cName = fullfile(this.cSaveDir, cName);
            [cFileName, cPathName, cFilterIndex] = uiputfile('*.mat', 'Save As:', cName);
            
            % uiputfile returns 0 when the user hits cancel
            if cFileName ~= 0
                
                
                
                this.savePre(cFileName, cPathName)
            end
            
                        
            
        end
        
        function savePre(this, cFileName, cPathName)
            
            % Create a nested recursive structure of all public properties
            
            s = this.saveClassInstance();
            
            % Remove unwanted fields from the structure.  We don't want to
            % overwrite the list of available prescriptions when one is
            % loaded
            
            % s.pfs = rmfield(s.pfs, 'uilOptions');
                        
            % Save
            save(fullfile(cPathName, cFileName), 's');
            
            % Dispatch
            stData = struct();
            stData.cName = cFileName;
            notify(this, 'eNew', EventWithData(stData));
            this.msg('handlePreChange');
              
            
            % If the name is not already on the list, append it
            if isempty(strmatch(cFileName, this.uilSaved.ceOptions, 'exact'))
                this.uilSaved.prepend(cFileName);
            end
            
            
        end
        
        function handleSavedDelete(this, src, evt)
        
            % In this case, evt is an instance of EventWithData (custom
            % class that extends event.EventData) that has a property
            % stData (a structure).  The structure has one property called
            % options which is a cell array of the items on the list that
            % were just deleted.
            % 
            % Need to loop through them and delete them from the directory.
            % The actual filenames are appended with .mat
                        
            for k = 1:length(evt.stData.ceOptions)
                
                
                cFile = fullfile(this.cDir, '..', this.cSaveDir, evt.stData.ceOptions{k});
                
                %{
                cFile = sprintf('%s../%s/%s.mat', ...
                    this.cDir, ...
                    this.cSaveDir, ...
                    evt.stData.ceOptions{k} ...
                );
                %}
            
                if exist(cFile, 'file') ~= 0
                    % File exists, delete it
                    delete(cFile);
                else
                    this.msg(sprintf('Cannot find file: %s; not deleting.', cFile));
                end
                
            end
            
            notify(this, 'eDelete')
            
        end
               
        
        function handleSavedChange(this, src, evt)
                        
            if ~isempty(this.uilSaved.ceSelected)
                                
                % Load the .mat file (assume that cName is the filename in the
                % prescriptions directory

                cFile = fullfile(this.cDir, '..', this.cSaveDir, this.uilSaved.ceSelected{1});

                if exist(cFile, 'file') ~= 0

                    load(cFile); % populates s in local workspace
                    this.loadClassInstance(s);

                else

                    % warning message box

                    h = msgbox( ...
                        'This file cannot be found.  Click OK below to continue.', ...
                        'File does not exist', ...
                        'warn', ...
                        'modal' ...
                        );

                    % wait for them to close the message
                    uiwait(h);

                end
                
                %{
                
                % nofity ePreChange with a custom EventWithData class that has
                % a cOption property we can pass to the listner (PreTool) that
                % can then load the prescription
                
                stData = struct();
                stData.cOption = this.uilSaved.ceSelected{1};
                notify(this, 'ePreChange', EventWithData(stData));
                this.msg('handlePreChange');
                %}
                
            end
            
        end
        

    end 
    
    
end