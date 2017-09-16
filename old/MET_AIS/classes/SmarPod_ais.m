classdef SmarPod_ais < MotionControl_ais
%SMARPOD Class to control a SmarAct Haxapod stage using Java wrappers
%   (inherits from MotionControl<JavaDevice)
%
%
%
%
% Example of use :
% cl = Clock('test_clock');
% smarpod = SmarPod(cl);
% smarpod.
%
%
    
    % rcs
    
    properties (Constant)
        dWidth = 300;
        dHeight = 305;
    end
    
	properties
        hioX
        hioY
        hioZ
        hioRx
        hioRy
        hioRz
        
        cl % clock
    end
    
    properties (SetAccess = private)
    end
    
    properties (Access = private)                 
    end
    
    events    
    end

    methods
        
        
        function this = SmarPod_ais(clock)
        %SMARPOD Class constructor
        %   smarPod = SmarPod_ais(clock)
        %
        % See also MotionControl, JavaDevice
              
            % Call MotionControl constructor explicitly to pass in args if
            % you don't explicitly call, it will call it w/o the arguments
            this@MotionControl_ais( ...
                clock, ...
                'Smarpod-1', ...
                uint8([0, 1, 2, 3, 4, 5]), ...
                'Grating stage 6-axis control', ...
                {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'}, ...
                {'hio', 'hio', 'hio', 'hio', 'hio', 'hio'}, ...
                'ais-dev1.dhcp.lbl.gov'); 
                        
            % Expose HardwareIO members of MotionControl in a nice way
            this.hioX = this.cehio{1};
            this.hioY = this.cehio{2};
            this.hioZ = this.cehio{3};
            this.hioRx = this.cehio{4};
            this.hioRy = this.cehio{5};
            this.hioRz = this.cehio{6};
                        
            this.hioX.setup.uieStepRaw.setVal(100e-6);
            this.hioY.setup.uieStepRaw.setVal(100e-6);
        end
        
        function connect_to(this)
            this.connect();
        end
               
    end
    
    methods (Access = protected)
    end
    
    methods (Access = private)
    end 
    
end