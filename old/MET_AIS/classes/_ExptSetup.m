classdef _ExptSetup < HandlePlus
    
    % rcs
    
	properties
        
        pt                          % ProcessTool 
        rt                          % ReticleTool 
        pfs                         % PupilFillSelect
        ft                          % FEMTool
        uibSave 
        ec
                
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        hFigure
        uibMatrix
        dWidth          = 1250
        dHeight         = 740
        cDir
        cSaveDir    = 'prescriptions'
      
    end
    
        
    events
        
        eSizeChange
        eNewPre
        
    end
    

    
    methods
        
        
        function this = ExptSetup()
            
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            this.init();
            
        end
        
                
        function build(this)
              
            dPad = 10;
            dTop = 10;
            
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name',  'Experiment Setup', ...
                'Position', [20 50 this.dWidth this.dHeight], ... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on', ...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            
            
            set(this.hFigure, 'renderer', 'OpenGL'); % Enables proper stacking
            
                 
            
            this.pt.build(this.hFigure, dPad, dTop);
            this.rt.build(this.hFigure, dPad + this.pt.dWidth + dPad, dTop);
            this.pfs.build(this.hFigure, dPad + this.pt.dWidth + dPad, dTop + this.rt.dHeight + dPad);
            this.ft.build(this.hFigure, dPad + this.pt.dWidth + dPad + this.rt.dWidth + dPad, dTop);
            this.uibSave.build(this.hFigure, ...
                dPad + this.pt.dWidth + dPad + this.rt.dWidth + dPad, ...
                dTop + this.ft.dHeight + dTop, ...
                100, ...
                Utils.dEDITHEIGHT);
            
            this.ec.build(this.hFigure, dPad, dTop + this.pt.dHeight + dTop);
                                  
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
                    

    end
    
    methods (Access = private)
        
        function init(this)
             
            this.pt                 = ProcessTool();
            this.rt                 = ReticleTool();
            this.pfs                = PupilFillSelect();
            this.ft                 = FEMTool();
            this.uibSave            = UIButton('Save');
            addlistener(this.uibSave, 'eChange', @this.handleSave);
            
            this.ec                 = ExptControl();
            addlistener(this.ec, 'ePreChange', @this.handlePreChange);
           
        end
        
        
        
        
        function handleCloseRequestFcn(this, src, evt)
            delete(this.hFigure);
            % this.saveState();
        end
        
        function handleSave(this, src, evt)
            
            % Generate a suggestion for the filename
            % [yyyy-mm-dd]-[num]-[Resist]-[Reticle]-[Field]-[Illum
            % abbrev.]-[FEM rows x FEM cols]
            
            cResist = this.pt.uieResistName.val();
            if (length(cResist) > 10)
                cResist = cResist(1:10);
            end
            
            cIllum = this.pfs.val();
            if (length(cIllum) > 10)
                cIllum = cIllum(1:10);
            end
            
            
            cName = sprintf('%s--%s--%s--%s--%s--%1dx%1d', ...
                datestr(now,'yyyy-mm-dd-HH-MM'), ...
                cResist, ...
                this.rt.uipReticle.val(), ...
                this.rt.uipField.val(), ...
                cIllum, ...
                length(this.ft.dDose), ...
                length(this.ft.dFocus) ...
            );
            
            cSaveName = Utils.listSaveAs(cName, this.uilPrescriptions);
            if ~strcmp(cSaveName, '')
                this.savePre(cSaveName);
            else
                % do nothing
            end
            
            
        end
        
        function savePre(this, cName)
            
            cPath = sprintf('%s../%s/%s.mat', ...
                this.cDir, ...
                this.cSaveDir, ...
                cName ...
            );
            
            % Create a nested recursive structure of all public properties
            
            s = this.saveClassInstance();
            
            % Remove unwanted fields from the structure.  We don't want to
            % overwrite the list of available prescriptions when one is
            % loaded
            
            % s = rmfield(s, 'ec');
                        
            % Save
            save(cPath, 's');
            
            % Dispatch
            stData = struct();
            stData.cName = [cName, '.mat'];
            notify(this, 'eNewPre', EventWithData(stData));
            this.msg('handlePreChange');
              
            %{
            % If the name is not already on the list, append it
            if isempty(strmatch(cName, this.uilPrescriptions.ceOptions, 'exact'))
                this.uilPrescriptions.append([cName, '.mat']);
            end
            %}
            
        end
        
        function handlePrescriptionsDelete(this, src, evt)
        
            % In this case, evt is an instance of EventWithData (custom
            % class that extends event.EventData) that has a property
            % stData (a structure).  The structure has one property called
            % options which is a cell array of the items on the list that
            % were just deleted.
            % 
            % Need to loop through them and delete them from the directory.
            % The actual filenames are appended with .mat
            
            
            this.msg('handleSavedDelete');
            evt.stData.ceOptions
            
            for k = 1:length(evt.stData.ceOptions)
                
                cFile = sprintf('%s../%s/%s.mat', ...
                    this.cDir, ...
                    this.cSaveDir, ...
                    evt.stData.ceOptions{k} ...
                );
            
                if exist(cFile, 'file') ~= 0
                    % File exists, delete it
                    delete(cFile);
                else
                    this.msg(sprintf('Cannot find file: %s; not deleting.', cFile));
                end
                
            end
            
        end
               
        
        function handlePrescriptionsChange(this, src, evt)
            
            % Load the .mat file
            
            if ~isempty(this.uilPrescriptions.ceSelected)
                
                % ceSelected is a cell of selected options - use the first
                % one.  Populates a structure named s in the local
                % workspace of this method
                
                cFile = sprintf('%s../%s/%s', ...
                    this.cDir, ...
                    this.cSaveDir, ...
                    this.uilPrescriptions.ceSelected{1} ...
                    );
                
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
                
                
            else
                
                % ceSelected is an empty [1x0] cell.  do nothing
                
            end
            
 
        end
        
        
        function refreshPrescriptions(this)
            
            
            % Loop through all of the pupilfills in the pupilfill directory
            % and update the contents of the list
                            
            % Get a structure (size n x 1) for each .mat file.  Each structure
            % contains: name, date, bytes, isdir, datenum
            
            
            stFiles = dir(sprintf('%s../%s/*.mat', ...
                this.cDir, ...
                this.cSaveDir ...
            ));
           
            % Sort by ascending date and get the ordering index. {asFiles.date}
            % creates a cell array of strings where each item is the date
            % of one of the files, which can be sorted by sort. 
            
            % NOTES: when you use sort on a cell array of strings, the
            % 'mode' parameter (ascending, descending) does not work.  It
            % will default to ascending and you have to flip afterward.
            
            % [csDate,anIndex] = sort({asFiles.date});
            
            % It turns out that doesn't matter, because the code above had
            % problems because the date is formatted dd-month-yyyy and it
            % ended up sorting by dd, not the full date.
            
            % To sort by date modified use:
            [ceDate, dIndex] = sort([stFiles.datenum],'descend');
            dIndex = fliplr(dIndex);
            
            % To sort by name use:
            % [ceDate, dIndex] = sort({stFiles.name}); % sorts in ascending ASCII, need to flip anIndex
            % dIndex = fliplr(dIndex);            
            
            % Use index to reorder the structures
            
            stSortedFiles = stFiles(dIndex);
            ceSortedFiles = {stSortedFiles.name};
            
            if(isempty(ceSortedFiles))
                this.uilPrescriptions.ceOptions = cell(1, 0);
            else
                this.uilPrescriptions.ceOptions = ceSortedFiles;
            end
                    
            
        end
        
        
        function handlePlay(this, src, evt)
            
            this.msg('handlePlay');
            
            if this.uitPlay.lVal
                % play was just clicked, now showing pause.  Start FEM
                this.startFEM();
            end
            
        end
        
        
        function startFEM(this)
            
           this.msg('startFEM'); 
            
        end
        
        function oThis = bIsRunningFEM(oThis)
            
            if get(oThis.hIsRunningToggle,'Value')
                % We were stopped and want to start
                oThis.bIsRunning = 1;
                oThis.startFEM();
            else
                % We were running and want to pause/stop. Use a verfication
                % question to pause execution of this .m file, this way the
                % stop button can essentially act as a pause button and a
                % stop button.
                qstring = sprintf('Are you sure you want to abort?');
                qanswer = questdlg(qstring,'Warning','Yes, ABORT','Resume','Resume');
                switch qanswer
                    case 'Yes, ABORT'
                        oThis.bIsRunning = 0; % FEM loop requires this = 1 for a shot
                    otherwise
                        oThis.bIsRunning = 1;
                end
            end
        end
        

    end 
    
    
end