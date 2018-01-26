%{
ScanSetup is a ui element used to set up scan states for use in the
mic.scan class.  ScanSetup is implemented by instantiating ScanAxisSetups
which control parameters for the individual axes.

Instantiate with at least parameter dScanAxes,  ceOutputOptions, and
ceScanAxisLabels, which control the dimensionality of the scan, the labels
for the output options, and the labels for the input axis options
respectively

Pass parameter 
    fhOnScanChangeParams = @(ceScanStates, u8ScanAxisIdx, lUseDeltas)
To initialize a callback that will be called any time a scan parameter is
changed, passing a cell array of scanstates, the axis numbers of the active
scans as defined in the uipopup, and the useDeltas boolean array to
determine whether scans will be about the current axis value

%}

classdef ScanSetupLSI < mic.ui.common.ScanSetup
    
    
    properties (Constant)
        
    end
    
    
    properties (SetAccess = private)
        
        
    end
    
    
    properties (Access = protected)


    end
    
    
    
    methods
        
        % constructor
        
        
        function this = ScanSetupLSI(varargin)
            this@mic.ui.common.ScanSetup(varargin{:});
           

            
        end
        
        
        % The primary difference with this specialized LSI is that we are
        % going to set up the states in serial, with linear motions in X
        % then linear motions in Y.
        %
        % Set up axes as pairs:
        
       function [ceScanStates, u8ScanAxisIdx, lUseDeltas] = buildScanStateArray(this)
            
            % Save the scan idx of each axis and whether to use deltas
            u8ScanAxisIdx = [];
            lUseDeltas = [];
            
            for k = 1:this.dScanAxes
                u8ScanAxisIdx(k) = this.saScanAxisSetups{k}.getScanAxisIndex();
                lUseDeltas(k) = this.saScanAxisSetups{k}.useDelta();
            end
            
            % Create a cell array of the scan ranges for each
            % scanAxisSetup:
            ceScanRanges = cell(1,this.dScanAxes);
            
            for k = 1:this.dScanAxes
                ceScanRanges{k} = this.saScanAxisSetups{k}.getScanRanges();
            end
            
            % Now need to build a list of states corresponding to the scan
            % ranges:
            dNumScanStates = 0;
            for k = 1:2:this.dScanAxes
                dNumScanStates = dNumScanStates +  length(ceScanRanges{k}) * length(ceScanRanges{k + 1});
            end
            ceScanStates = cell(0);
            
            switch this.dScanAxes/2
                
                case 1 % X-Y scan
                    % Axis 1
                    for k = 1:length(ceScanRanges{1})
                            ceScanStates{end + 1} = struct('indices', [k, 1], ...
                                'axes', u8ScanAxisIdx(1:2), ...
                                'values',[ceScanRanges{1}(k), ceScanRanges{2}(1)]); %#ok<AGROW>
                    end
                    % Axis 2 in series:
                     for k = 1:length(ceScanRanges{2})
                            ceScanStates{end + 1} = struct('indices', [1, k], ...
                                'axes', u8ScanAxisIdx(1:2), ...
                                'values',[ceScanRanges{1}(1), ceScanRanges{2}(k)]); %#ok<AGROW>
                    end
                    
                case 2 %Y-X scan with intermediate steps
                    % Axis 1
                    
                    for m = 1:length(ceScanRanges{2})
                        for k = 1:length(ceScanRanges{1})
                        
                        
                            ceScanStates{end + 1} = struct('indices', [k, m], ...
                                'axes', u8ScanAxisIdx(1:2), ...
                                'values',[ceScanRanges{1}(k), ceScanRanges{2}(m)]); %#ok<AGROW>
                        end
                    end
                    
                    % Axis 2 in series:
                    for m = 1:length(ceScanRanges{4})
                        for k = 1:length(ceScanRanges{3})
                         
                            ceScanStates{end + 1} = struct('indices', [m, k], ...
                                'axes', u8ScanAxisIdx(1:2), ...
                                'values',[ceScanRanges{4}(m), ceScanRanges{3}(k)]); %#ok<AGROW>
                         end
                    end
                    
            end
       end
       
       function paramChangeCallback(this)
            % For testing just echo somethign:
            disp('param change callback');
            
            % Get current scan parameters and route to param change
            % callback:
            [ceScanStates, u8ScanAxisIdx, lUseDeltas] = this.buildScanStateArray();
            cAxisNames = this.ceScanAxisLabels(u8ScanAxisIdx);
            this.fhOnScanChangeParams(ceScanStates, u8ScanAxisIdx(1:2), lUseDeltas, cAxisNames);
       end
        
       
        
       
         % Builds the UI elements
        function build(this,  hParent,  dLeft,  dTop,  dWidth,  dHeight)
            
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', ([dLeft dTop dWidth dHeight]));
            drawnow
            
            % First build scan axes:
            
            dLeft = 10;
            dPad = 6;
            dY = 45;
            dScanButHeight = 70;
            dTop = 2;
            
            for k = 1:this.dScanAxes
                this.saScanAxisSetups{k}.build(this.hPanel, dLeft, ...
                    dTop);
                if mod(k,2) == 1 && this.dScanAxes > 2
                    dTop = dTop + dPad + dY*.75;
                else
                    dTop = dTop + dPad + dY*1.25;
                end
            end
            
            dTop = dTop + 3*dPad;
             
            % Build only if there is more than one axis
 
            this.uibStartScan.build(this.hPanel, 140, dTop, 45, 30);
            this.uipOutput.build(this.hPanel, 10, dTop - 10, 120, 40);
            this.uibStopScan.build(this.hPanel, 195, dTop, 45, 30);
            
            
            this.uiSLScanSetup.build(this.hPanel, 487, 10, 340, dHeight - 20);
            
            this.uibStartScan.setColor([.7, .75, .9]);
            this.uibStopScan.setColor([.9, .7, .7]);
            
        end
       
        
        
    end
    
    methods (Access = protected)
        
        
        
        
        
        
    end
end