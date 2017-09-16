classdef _HeightSensor < HandlePlus
%HEIGHTSENSOR  Class that gives the controls to the heightsensor
%   hs = HeightSensor('name', cl) creates an instance of a HeightSensor

    %% things to implement :
    % axis wafer X
    % axis wafer Y
    
    % height sensor reading 123456 + compound
    % angle reading
    % cap sensors reading
    
    % height setter
    % angle setter (Tx, Ty)
    
    % settings : set scales
    % levelling iterations n#, z tolerance
    
    
    % visualization
    


%% Properties

    properties (Constant)
        dWidth  = 1024  %width 
        dHeight = 768  %height
    end

    properties (Dependent = true)
        height = -1;
        tiltX = -1;
        tiltY = -1;

    end

    properties
       
        axWaferX    %X-Axis   
        axWaferY    %Y-Axis
        axHeight    %compound; height kinematics
        axTiltX     %compound; 
        axTiltY
        
        diHeightC1  %centered diode 1
        diHeightC2  %centered diode 2
        diHeightC3  %centered diode 3
        diHeightO1  %off-centered diode 1
        diHeightO2  %off-centered diode 2
        diHeightO3  %off-centered diode 3
        
        diCap1      %cap-sensor 1
        diCap2      %cap-sensor 2
        diCap3      %cap-sensor 3
        
        scX         %scanning procedure for X-Axis
        scY         %scanning procedure for Y-Axis
        scZ         %scanning procedure for Z-Axis
        
        uitext;
        
        % TODO these handles might be removed later :
        buttonWaferXY00
        buttonWaferLL
        buttonWaferDS
        buttonWaferFS

    end

    properties (SetAccess = private)
        cl      % clock
        cName   % name identifier
        
        %UI handles
        hFigure;    % handle to the parent for building the uielement
        ui2d        % Axis for plotting the data

    end

    properties (Access = private)
        cDir    % current directory
    end

    events
        
    end
 %% Static methods
     methods 
         
    function this = HeightSensor(cName, cl)
    %HEIGHTSENSOR Class constructor
    %   hs = HeightSensor('name', clock)
        
        this.cName  = cName;
        this.cl  = cl;
        
        this.init();
    end
    
%% Methods

    function init(this)
	%INIT Initializes the class
    %   HeightSensor.init()
    %   primarily used by the HeightSensor class constructor
    %
        this.axWaferX   = Axis('Wafer X',this.cl);  
        this.axWaferY  	= Axis('Wafer Y',this.cl);
        this.axHeight   = Axis('Wafer Height',this.cl); %FIXME : pb w display
        this.axTiltX    = Axis('Tilt X',this.cl);
        this.axTiltY    = Axis('Tilt Y',this.cl);
        
%         this.diHeightC1 = Diode('HS Channel 1',this.cl);
%         this.diHeightC2 = Diode('HS Channel 2',this.cl);
%         this.diHeightC3 = Diode('HS Channel 3',this.cl);
%         this.diHeightO1 = Diode('HS Channel 4',this.cl);
%         this.diHeightO2 = Diode('HS Channel 5',this.cl);
%         this.diHeightO3 = Diode('HS Channel 6',this.cl);
        
        this.diHeightC1 = HardwareO('HS Chan 1',this.cl);
        this.diHeightC2 = HardwareO('HS Chan 2',this.cl);
        this.diHeightC3 = HardwareO('HS Chan 3',this.cl);
        this.diHeightO1 = HardwareO('HS Chan 4',this.cl);
        this.diHeightO2 = HardwareO('HS Chan 5',this.cl);
        this.diHeightO3 = HardwareO('HS Chan 6',this.cl);
        
            this.diHeightC1.fhReadVal = @() this.fhRead(1);
            this.diHeightC2.fhReadVal = @() this.fhRead(2);
            this.diHeightC3.fhReadVal = @() this.fhRead(3);
            this.diHeightO1.fhReadVal = @() this.fhRead(4);
            this.diHeightO2.fhReadVal = @() this.fhRead(5);
            this.diHeightO3.fhReadVal = @() this.fhRead(6);
        
        this.diCap1     = Diode('Cap Sensor 1-test',this.cl);
        this.diCap2     = Diode('Cap Sensor 2-test',this.cl);
        this.diCap3     = Diode('Cap Sensor 3-test',this.cl);
        
        this.scX        =  Scan('Scan X', this.cl, ...
                    @this.fhMoveFcnX, @this.fhSettleFcnX, @this.fhAcqFcnX);
        this.scY        =  Scan('Scan Y', this.cl, ...
                    @this.fhMoveFcnY, @this.fhSettleFcnY, @this.fhAcqFcnY);
        this.scZ        =  Scan('Scan Z', this.cl, ...
                    @this.fhMoveFcnZ, @this.fhSettleFcnZ, @this.fhAcqFcnZ);
                
        fh = @this.fhReadingUpdate;
        pollingP = 200e-3;
        this.cl.add(fh, [class(this),':','HSReadingUpdate'], pollingP);
        
        this.ui2d = UI2DNav(300,300);

    end
    

    function build(this,hFigure)
	%BUILD Builds the uielement controls associated with the height sensor
	%   HeightSensor.build(hParent, dTop, dLeft)
        
        if nargin<2
            if isempty(this.hFigure)
                this.hFigure = figure( ...
                    'NumberTitle', 'off',...
                    'MenuBar', 'none',...
                    'Name',  this.cName,...
                    'Position', [20 50 this.dWidth this.dHeight],... % left bottom width height
                    'Resize', 'off',...
                    'HandleVisibility', 'on',... % lets close all close the figure
                    'Visible', 'on');
                    %'CloseRequestFcn', @this.cb ... %TODO : refactor the callback

                drawnow;
            else
                clf(this.hFigure)
            end
        else
            this.hFigure = hFigure;
        end
            
            this.ui2d.build(this.hFigure, 0, this.dHeight-300)
        
            this.axWaferX.build(this.hFigure,Axis.dWidth,0);
            this.axWaferY.build(this.hFigure,Axis.dWidth,Axis.dHeight);
            this.axHeight.build(this.hFigure,Axis.dWidth,Axis.dHeight*2);
            this.axTiltX.build( this.hFigure,Axis.dWidth,Axis.dHeight*3);
            this.axTiltY.build( this.hFigure,Axis.dWidth,Axis.dHeight*4);
            
            this.diHeightC1.build(this.hFigure,0,Diode.dHeight*0)
            this.diHeightC2.build(this.hFigure,0,Diode.dHeight*1)
            this.diHeightC3.build(this.hFigure,0,Diode.dHeight*2)
            this.diHeightO1.build(this.hFigure,0,Diode.dHeight*3)
            this.diHeightO2.build(this.hFigure,0,Diode.dHeight*4)
            this.diHeightO3.build(this.hFigure,0,Diode.dHeight*5)
        
            this.diCap1.build(this.hFigure,0,Diode.dHeight*7)
            this.diCap2.build(this.hFigure,0,Diode.dHeight*8)
            this.diCap3.build(this.hFigure,0,Diode.dHeight*9)

            this.scX.build(this.hFigure,Axis.dWidth,Scan.dHeight*7)
            this.scY.build(this.hFigure,Axis.dWidth,Scan.dHeight*8)
            this.scZ.build(this.hFigure,Axis.dWidth,Scan.dHeight*9)
            
            this.uitext = uicontrol('Parent', this.hFigure,...
                'Style', 'text',...
                'FontName','Courier','FontSize',12,...
                'String',sprintf('height : \t%fum\ntilt X : \t%fmrad\ntilt Y : \t%fmrad\n',this.height, this.tiltX, this.tiltY),...
                'Units','pixels',...
                'Position',Utils.lt2lb([0 Scan.dHeight*10.5 300 36*2],this.hFigure),...
                'Callback',@this.handleUI);
            
            
        this.buttonWaferXY00 = uicontrol('Parent', this.hFigure,...
                'style','pushbutton',...
                'String',sprintf('Wafer XY -> (0,0)'),...
                'Units','pixels',...
                'Position',Utils.lt2lb([3*Axis.dWidth 0 72 36],this.hFigure),...
                'Callback',@this.fhWaferXY00);
            
        this.buttonWaferLL = uicontrol('Parent', this.hFigure,...
                'style','pushbutton',...
                'String',sprintf('Wafer -> LL'),...
                'Units','pixels',...
                'Position',Utils.lt2lb([3*Axis.dWidth 36 72 36],this.hFigure),...
                'Callback',@this.fhWaferLL);
            
        this.buttonWaferDS = uicontrol('Parent', this.hFigure,...
                'style','pushbutton',...
                'String',sprintf('Wafer -> DS'),...
                'Units','pixels',...
                'Position',Utils.lt2lb([3*Axis.dWidth 108 72 36],this.hFigure),...
                'Callback',@this.fhWaferDS);
            
        this.buttonWaferFS = uicontrol('Parent', this.hFigure,...
                'style','pushbutton',...
                'String',sprintf('Wafer -> FS'),...
                'Units','pixels',...
                'Position',Utils.lt2lb([3*Axis.dWidth 144 72 36],this.hFigure),...
                'Callback',@this.fhWaferFS);
            drawnow;
            
            
            
            
    end
    
        %TODO remove this quick'n'dirty fix
    function dVal = fhRead(this, channelNb)
    %FHREAD Function handle that reads the height on a channel
    %   dVal = HeightSensor.fhRead(channelNb)
    %   primarily meant to be used by Axis UIElement
        noise_nm = 3;
        [arg1, arg2, arg3, arg4, arg5, arg6] = ...
            HeightSensorCore.virtualWaferPosition(...
                this.axWaferX.uieDest.val(),...
                this.axWaferY.uieDest.val(),...
                this.axHeight.uieDest.val(),...
                this.axTiltX.uieDest.val()*1e-3,...
                this.axTiltY.uieDest.val()*1e-3); 
            %TODO ^refactor to a 'read' function
            if      channelNb ==1
                dVal = arg1;
            elseif  channelNb ==2
                dVal = arg2;
            elseif  channelNb ==3
                dVal = arg3;
            elseif  channelNb ==4
                dVal = arg4;
            elseif  channelNb ==5
                dVal = arg5;
            elseif  channelNb ==6
                dVal = arg6;
            end
             dVal = dVal + rand(1,1)*noise_nm*1e-3;
    end
    
    function fhReadingUpdate(this)
    %FHREADINGUPDATE Function handle that updates the measurements
        if ~isempty(this.uitext)
            set(this.uitext, ...
                'String',sprintf('height : \t%+3.3fnm  \ntilt X : \t  %+1.3fmrad\ntilt Y : \t  %+1.3fmrad\n',this.height, this.tiltX, this.tiltY))
        end
    end

   
    
        %TODO : Refactor ?
        function fhMoveFcnX(this, value)
        %FHMOVEFCNX Scanning procedure 'Move X 'function handle
            this.axWaferX.uieDest.setVal(value)
            this.axWaferX.moveToDest();
        end

        function value = fhSettleFcnX(this)
        %FHSETTLEFCNX Scanning procedure 'Settle X' function handle
            value = this.axWaferX.avVirtual.isStopped();
            %this.axis.avVirtual.dPos
        end

        function value = fhAcqFcnX(this)
        %FHACQFCNX Scanning procedure 'Acquire X' function handle
            value = 0; %FIXME : does nothing
        end


        function fhMoveFcnY(this, value)
        %FHMOVEFCNY Scanning procedure 'Move Y 'function handle
            this.axWaferY.uieDest.setVal(value)
            this.axWaferY.moveToDest();
        end

        function value = fhSettleFcnY(this)
        %FHSETTLEFCNY Scanning procedure 'Settle Y' function handle
            value = this.axWaferY.avVirtual.isStopped();
            %this.axis.avVirtual.dPos
        end

        function value = fhAcqFcnY(this)
        %FHACQFCNY Scanning procedure 'Acquire Y' function handle
            value = 0; %FIXME : does nothing
        end
        

        function fhMoveFcnZ(this, value)
        %FHMOVEFCNZ Scanning procedure 'Move Z 'function handle
            
            this.axHeight.uieDest.setVal(value)
            this.axHeight.moveToDest();
        end

        function value = fhSettleFcnZ(this)
        %FHSETTLEFCNZ Scanning procedure 'Settle Z' function handle
            value = this.axHeight.avVirtual.isStopped();
            %this.axis.avVirtual.dPos
        end

        function value = fhAcqFcnZ(this)
        %FHACQFCNZ Scanning procedure 'Acquire Z'function handle
            value = 0;
        end
        


        % TODO : refactor and/or implement
        function fhWaferXY00(this, src, evt)
        %FHWAFERXY00 Callback that starts a wafer homing procedure
            disp('Homing the wafer >Not implemented yet<')
        end

        function fhWaferLL(this, src, evt)
        %FHWAFERLL Callback that moves the wafer to the loadlock
            disp('Moving the wafer to the loadlock >Not implemented yet<')
        end

        function fhWaferFS(this, src, evt)
        %FHWAFERFS Callback that nobody understands. You should comfort it
            disp('Clicked on WaferFS')
        end

        function fhWaferDS(this, src, evt)
        %FHWAFERDS Callback that nobody understands. You should comfort it
            disp('Clicked on WaferDS')
        end


function height = get.height(this)
    if ~isempty(this.diHeightC1) && ~isempty(this.diHeightC2) && ~isempty(this.diHeightC3)
        height = HeightSensorCore.getHeight(this.diHeightC1.readRaw(), this.diHeightC2.readRaw(), this.diHeightC3.readRaw());
    else
        height = -1;
    end
end

function tiltX = get.tiltX(this)
    if ~isempty(this.diHeightO1) && ~isempty(this.diHeightO2) && ~isempty(this.diHeightO3)
        [tiltX, tiltY] = HeightSensorCore.getTilt(this.diHeightO1.readRaw(), this.diHeightO2.readRaw(), this.diHeightO3.readRaw());
    else
        tiltX = -1;
    end
end

function tiltY = get.tiltY(this)
    if ~isempty(this.diHeightO1) && ~isempty(this.diHeightO2) && ~isempty(this.diHeightO3)
        [tiltX, tiltY] = HeightSensorCore.getTilt(this.diHeightO1.readRaw(), this.diHeightO2.readRaw(), this.diHeightO3.readRaw());
    else
        tiltY = -1;
    end
end


        function cb(this, src, evt)   
        %CB General callback
%             switch src
%                 case this.hFigure
%                     this.closeRequestFcn();
%                     
%             end
            if(isequal(src,this.hFigure))
                %this.delete;
                %this.closeRequestFcn();                    
            end
        end
        
        function delete(this)
        %DELETE Class destructor
        %   HeightSensor.delete()
            if ~isempty(this.hFigure)
                delete(this.hFigure);
            end
                        
            if ~isempty(this.axWaferX)
                this.axWaferX.delete
            end
            if ~isempty(this.axWaferY)
                this.axWaferY.delete
            end
            if ~isempty(this.axHeight)
                this.axHeight.delete
            end
            if ~isempty(this.axTiltX)
                this.axTiltX.delete
            end
            if ~isempty(this.axTiltY)
                this.axTiltY.delete
            end
            
            if ~isempty(this.diHeightC1)
                this.diHeightC1.delete
            end
            if ~isempty(this.diHeightC1)
                this.diHeightC1.delete
            end
            if ~isempty(this.diHeightC2)
                this.diHeightC2.delete
            end
            if ~isempty(this.diHeightC3)
                this.diHeightC3.delete
            end
            if ~isempty(this.diHeightO1)
                this.diHeightO1.delete
            end
            if ~isempty(this.diHeightO2)
                this.diHeightO2.delete
            end
            if ~isempty(this.diHeightO3)
                this.diHeightO3.delete
            end
            
            if ~isempty(this.diCap1)
                this.diCap1.delete
            end
            if ~isempty(this.diCap2)
                this.diCap2.delete
            end
            if ~isempty(this.diCap3)
                this.diCap3.delete
            end
            
            if ~isempty(this.scX)
                this.scX.delete
            end
            
            if ~isempty(this.scY)
                this.scY.delete
            end
            
            if ~isempty(this.scZ)
                this.scZ.delete
            end
        end
           

    end %methods
end %classdef