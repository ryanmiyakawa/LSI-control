classdef METMain < HandlePlus
    
    % rcs
    
    properties (Constant)
       
        dHeight         = 400
        dWidth          = 140
        
    end
	properties
        
        reticleControl      % ReticleControl
        waferControl        % WaferControl
        pupilControl        % ScannerControl
        fieldControl        % ScannerControl
        preTool             % PreTool
        exptControl         % ExptControl
        shutter             % Shutter
        
        m141Control
        m142Control
        m143Control
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        clock
        hFigure
        
        uibM141Control
        uibM142Control
        uibM143Control
        uibReticleControl
        uibWaferControl
        uibPreTool
        uibExptControl
        uibPupilScanner
        uibFieldScanner
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = METMain()
            
            
            this.init();
            
        end
        
                
        function build(this)
                        
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'MET5', ...
                'Position', [0 0 this.dWidth this.dHeight], ... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            drawnow;

            dButtonWidth = 120;
            dTop = 10;
            dPad = 10;
            dSep = 40;
            
            this.uibM141Control.build(this.hFigure,  dPad, dTop + 0*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            this.uibM142Control.build(this.hFigure,  dPad, dTop + 1*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            this.uibM143Control.build(this.hFigure,  dPad, dTop + 2*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            
            
            this.uibReticleControl.build(this.hFigure,  dPad, dTop + 3*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            this.uibWaferControl.build(this.hFigure,    dPad, dTop + 4*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            this.uibPreTool.build(this.hFigure,         dPad, dTop + 5*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            this.uibExptControl.build(this.hFigure,     dPad, dTop + 6*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            this.uibPupilScanner.build(this.hFigure,       dPad, dTop + 7*dSep, dButtonWidth, Utils.dEDITHEIGHT);
            this.uibFieldScanner.build(this.hFigure,       dPad, dTop + 8*dSep, dButtonWidth, Utils.dEDITHEIGHT);
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            
            this.msg('delete');
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            %{
            % Clean up clock tasks
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            %}
            
            % Since all child classes refrence the clock, we need to delete
            % it first.  I originally thought this is so the clock wouldn't
            % continue to try to execute tasks that belong to deleted function
            % handles, but this isn't it.
            %
            % When you delete a class, you delete all of its properties.
            % Since we make the clock a property of each child class, it
            % will get deleted when the first child class is deleted (in
            % this case it is the ReticleControl class).  When this happens,
            % all of the other classes will have ...
            % Acutally, it doesn't make sense to me why we have to delete
            % the clock first, but it works.
                
            % Maybe it has something to do with the fact that the clock is
            % a private property of the child classes and when we delete
            % the child class, the reference to the clock persists through
            % the private property?
            %
            % No this is wrong.  Private properties are deleted.  
            
            % Delete the clock
            delete(this.clock);
                       
        end         

    end
    
    methods (Access = private)
        
        
        function handleButtonM141Control(this, src, evt)
            this.m141Control.build();
        end
        
        function handleButtonM142Control(this, src, evt)
            this.m142Control.build();
        end
        
        function handleButtonM143Control(this, src, evt)
            this.m143Control.build();
        end
        
        function handleButtonReticleControl(this, src, evt)
            this.reticleControl.build();
        end
        
        function handleButtonWaferControl(this, src, evt)
            this.waferControl.build(); 
        end
        
        function handleButtonPreTool(this, src, evt)
            this.preTool.build();
        end
        
        function handleButtonExptControl(this, src, evt)
            this.exptControl.build();
        end
        
        function handleButtonPupilFill(this, src, evt)
            this.pupilControl.build();
        end
        
        function handleButtonFieldFill(this, src, evt)
            this.fieldControl.build();
        end
        
        function handlePreToolSizeChange(this, src, evt)
            
            % evt has a property stData
            %   dX
            %   dY
            
            %{
            this.msg('handlePreToolSizeChange');
            disp(evt.stData.dX)
            disp(evt.stData.dY)
            %}
           
            this.waferControl.updateFEMPreview(evt.stData.dX, evt.stData.dY);
        end
        
        function init(this)
            
            this.clock              = Clock('Master');
            this.m141Control        = M141Control(this.clock);
            this.m142Control        = M142Control(this.clock);
            this.m143Control        = M143Control(this.clock);
            this.reticleControl     = ReticleControl(this.clock);
            this.waferControl       = WaferControl(this.clock);
            this.pupilControl       = ScannerControl(this.clock, 'pupil');
            this.fieldControl       = ScannerControl(this.clock, 'field');
            this.preTool            = PreTool();
            this.shutter            = Shutter('imaging', this.clock);
            this.exptControl        = ExptControl( ...
                                        this.clock, ...
                                        this.shutter, ...
                                        this.waferControl, ...
                                        this.reticleControl, ...
                                        this.pupilControl);
            
            addlistener(this.preTool.femTool, 'eSizeChange', @this.handlePreToolSizeChange);
            addlistener(this.preTool, 'eNew', @this.handlePreToolNew);
            addlistener(this.preTool, 'eDelete', @this.handlePreToolDelete);
            
            addlistener(this.pupilControl, 'eNew', @this.handlePupilFillNew);
            addlistener(this.pupilControl, 'eDelete', @this.handlePupilFillDelete);
            
            
            this.uibM141Control     = UIButton('M141');
            this.uibM142Control     = UIButton('M142');
            this.uibM143Control     = UIButton('M143');
            
            this.uibReticleControl  = UIButton('Reticle');
            this.uibWaferControl    = UIButton('Wafer');
            this.uibPreTool         = UIButton('Pre Tool');
            this.uibPupilScanner       = UIButton('Pupil Scanner');
            this.uibFieldScanner       = UIButton('Field Scanner');
            this.uibExptControl     = UIButton('Expt. Control');
            
            addlistener(this.uibM141Control, 'eChange', @this.handleButtonM141Control);
            addlistener(this.uibM142Control, 'eChange', @this.handleButtonM142Control);
            addlistener(this.uibM143Control, 'eChange', @this.handleButtonM143Control);
            
            
            addlistener(this.uibReticleControl, 'eChange', @this.handleButtonReticleControl);
            addlistener(this.uibWaferControl,   'eChange', @this.handleButtonWaferControl);
            addlistener(this.uibPreTool,        'eChange', @this.handleButtonPreTool);
            addlistener(this.uibExptControl,    'eChange', @this.handleButtonExptControl);
            addlistener(this.uibPupilScanner,   'eChange', @this.handleButtonPupilFill);
            addlistener(this.uibFieldScanner,   'eChange', @this.handleButtonFieldFill);

        end
        
        
        function handleCloseRequestFcn(this, src, evt)
            this.msg('closeRequestFcn()');
            % purge;
            delete(this.hFigure);
            % this.saveState();
        end
            
        function handlePreToolNew(this, src, evt)
            this.exptControl.uilPrescriptions.refresh();
        end
        
        function handlePreToolDelete(this, src, evt)
            this.exptControl.uilPrescriptions.refresh();
        end
        
        function handlePupilFillNew(this, src, evt)
            % uil property is private, so I exposed a public method
            this.preTool.pupilFillSelect.refreshList();
        end
        
        function handlePupilFillDelete(this, src, evt)
            % uil property is private, so I exposed a public method
            this.preTool.pupilFillSelect.refreshList();
        end

    end % private
    
    
end