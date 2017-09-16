classdef PupilFillSelect < HandlePlus
    
    
	properties (Constant)
    
    end
    
    
    properties
        
        dWidth              = 420;
        dHeight             = 190;
        cSelected           % Need to store the name of the saved file
    
    end
    
    properties (SetAccess = private)
        cSaveDir            = 'save/scanner-pupil';
    end
    
    properties (Access = private)
                      
        hPanel
        cDir
        uilOptions
                                
    end
    
        
    events
        
        eSizeChange
        
    end
    

    
    methods
        
        
        function this = PupilFillSelect()
                     
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
            
            this.init();   
        end
        
                
        function build(this, hParent, dLeft, dTop)
                                    
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Pupil Fill',...
                'Clipping', 'on',...
                'Position', Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
			drawnow;
            
            dPad = 10;
            this.uilOptions.build(this.hPanel, 10, 20, this.dWidth - 20, this.dHeight - 3*dPad - Utils.dEDITHEIGHT);
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
        
        function refreshList(this)
            this.uilOptions.refresh();
        end
                 

    end
    
    methods (Access = private)
        
        function init(this)
                        
            this.uilOptions = UIList(cell(1,0), '', false, false, false, true);
            this.uilOptions.setRefreshFcn(@this.refresh);
            this.uilOptions.refresh();
            
            addlistener(this.uilOptions, 'eChange', @this.handleOptionsChange);
            this.cSelected = this.uilOptions.ceSelected{1};
        end
        
        function ceReturn = refresh(this)
                        
            cPath = fullfile(this.cDir, '..', this.cSaveDir);
            ceReturn = Utils.dir2cell(cPath, 'date', 'descend');
                    
        end
        
        function handleOptionsChange(this, src, evt)
            this.cSelected = this.uilOptions.ceSelected{1};
        end
        
    end 
    
    
end