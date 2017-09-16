classdef HeightSensorCore < HandlePlus
%HEIGHTSENSORCORE Provides the calculation routines required by the HS
%   It is a static class
%
% See also HEIGHTSENSOR, PUPILFILLCORE

%FIXME : can it be a normal class (~handle)

    properties (Constant)

    aoi = 3*pi/180              % angle of incidence
    R = 135e3;                  % detector chief radius
    Delta = 4000;               % emitter offset
    H = 135e3*tan(3*pi/180)     % nominal wafer height
    
    %channel clocking angles (alpha1 = 0deg; beta1=90deg)
    alpha2 = 120*pi/180;        % second centered channel angle
    alpha3 = 240*pi/180;        % third centered channel angle
    beta2 = 30*pi/180;          % second offsetted channel angle
    beta3 = 150*pi/180;         % third offsetted channel angle

    sensor_positions = ...
        [0 0 0 0 sqrt(3)/2 -sqrt(3)/2;...
         0 0 0 1      -1/2       -1/2]*4000; % location of the channels

    end

    methods (Static)

        function height = getHeight(height1, height2, height3)
        %GETHEIGHT Computes the height of the wafer based on centered chan
        %   height = HeightSensorCore.getHeight(height1, height2, height3)
        %       It performs a basic average of the three centered channel
        %       readings
        %
        % See also GETTILT
        
            height = (height1 + height2 + height3)/3;
        end

        function [theta, phi] = getTilt(height_i, height_j, height_k)
        %GETTILT Computes the tip and tilt of the wafer based on off-chans
        %  [theta, phi] = HeightSensorCore.getTilt(height_i, height_j, height_k)
        %
        % See also GETHEIGHT

            %position of the intersection points
            I = [HeightSensorCore.sensor_positions(:,4);height_i];
            J = [HeightSensorCore.sensor_positions(:,5);height_j];
            K = [HeightSensorCore.sensor_positions(:,6);height_k];
            %cross products between vectors joining to intersection points
            %will give 
            ni = -cross(J-I,K-I)/norm(cross(J-I,K-I));
            nj = -cross(K-J,I-J)/norm(cross(K-J,I-J));
            nk = -cross(I-K,J-K)/norm(cross(I-K,J-K));

            nx = [1;0;0];
            ny = [0;1;0];
            nz = [0;0;1];

            theta   = asin(ni'*ny);
            phi     = asin(ni'*nx);
        end

        %FIXME approximate 
        function [ c1, c2, c3, o1, o2, o3 ] = virtualWaferPosition(posX ,posY, posH, posTheta, posPhi)
        %VIRTUALWAFERPOSITION Computes the reading of the sensors knowing wafer pos
        %   [c1,c2,c3,o1,o2,o3 ] = virtualWaferPosition(posX ,posY, posH, posTheta, posPhi)
            dx =  HeightSensorCore.sensor_positions(1,:);
            dy =  HeightSensorCore.sensor_positions(2,:);
            c1 = posH+(posX + dx(1))*tan(posPhi) + (posY + dy(1))*tan(posTheta);
            c2 = posH+(posX + dx(2))*tan(posPhi) + (posY + dy(2))*tan(posTheta);
            c3 = posH+(posX + dx(3))*tan(posPhi) + (posY + dy(3))*tan(posTheta);
            o1 = posH+(posX + dx(4))*tan(posPhi) + (posY + dy(4))*tan(posTheta);
            o2 = posH+(posX + dx(5))*tan(posPhi) + (posY + dy(5))*tan(posTheta);
            o3 = posH+(posX + dx(6))*tan(posPhi) + (posY + dy(6))*tan(posTheta);

        end

        %TODO : correct that
        function sensorUI(this, height)
        %SENSORUI Builds a visual aid of one channel reading
        %   HeightSensorCore.sensorUI(height)
            detector_width_um = 600;
            beam_sigma_um = 100;
            x= -detector_width_um/2:detector_width_um/2;
            gauss  = @(x,y) exp(-(x.^2+y.^2)/beam_sigma_um.^2);
            y= x*2;
            [X,Y] = meshgrid(x,y);
            hAxisSensor = axes('Units', 'pixels',...
                'Position',[0 0 100 200]);%, 'Parent',hParent);
            imagesc(x,y,gauss(X,Y-height).*sign(Y),'Parent',hAxisSensor);
            set(hAxisSensor,'Visible','off')
            colormap gray
        end

    end %methods
end %classdef


%% LEGACY
% classdef HeightSensor < handle
%     %HEIGHTSENSOR senses the height of the wafer
%     %   It is a mostrly static class that takes a wafer and gives the
%     %   reading of the 6x2 diodes
% 
% %% Properties
% 
% properties (Constant)
%     aoi = 3*pi/180 % angle of incidence
%     R = 135e3; % detector chief radius
%     Delta = 4000; %emitter offset
%     H = 135e3*tan(3*pi/180) %Nominal wafer height
%     
%     %channel clocking angles (alpha1 = 0deg; beta1=90deg)
%     alpha2 = 120*pi/180;
%     alpha3 = 240*pi/180;
%     beta2 = 30*pi/180;
%     beta3 = 150*pi/180;
% end
% 
% properties
%     wafer;
%     sensor_positions = ...
%         [0 0 0 0 sqrt(3)/2 -sqrt(3)/2;...
%          0 0 0 1      -1/2       -1/2]*4000;
%      sensor_readings = [1 1 1 1 1 1; 1 1 1 1 1 1];
%      beam_sigma_um = 100;
%      detector_width_um = 600;
%      detector_height_um = 600;
%      hPanel
%      hParent
%      
%      hAxisSensor1
%      hAxisSensor2
%      hAxisSensor3
%      hAxisSensor4
%      hAxisSensor5
%      hAxisSensor6
%      
%      hAxisLaser1
%      hAxisLaser2
%      hAxisLaser3
%      
%      lbLine_select
%           
% end
% 
% properties (Access = private)
%     
% end
% 
% events
%     eChange;
% end
% 
% methods
% %% Constructor    
% function this = HeightSensor(wafer)
%     this.wafer = wafer;
% end
%     
% function readings = read(this)
%     
% end
% 
% function [values] = height2dual(this,shift)
% 	%[val_seg_up, val_seg_down] = HeightSensor.height2height(shift_um) 
%     %gives the value of the two segmented diode for particular position of
%     %the beam on the detector
%     %it assumes a perfectly gaussian beam having a sigma as defined in the
%     %class properties (this should be updated with calibration). 
%     % The value is not normalized.
% 
% 	gauss  = @(x,y) exp(-(x.^2+y.^2)/this.beam_sigma_um.^2);
%     gauss_shifted  = @(x,y) gauss(x,y+shift);
%     
%     %integrating the (shifted)gaussian beam for the edge of the sensor to the
%     %central position
%     values(1) = quad2d(gauss_shifted,...
%         -this.detector_width_um/2,this.detector_width_um/2,...
%         -this.detector_height_um,                        0);
%     values(2) = quad2d(gauss_shifted,...
%         -this.detector_width_um/2,this.detector_width_um/2,...
%         0                        ,this.detector_height_um/2);
%     
%     %for debugging purpose : show the spot
%      x= -this.detector_width_um/2:this.detector_width_um/2;
%      y=x;
%      [X,Y] = meshgrid(x,y);
%      imagesc(gauss_shifted(X,Y))
%      axis image
%     
% end
% 
% %#super dirty
% function height = dual2height(this,values)
%     %height = HeightSensor.dual2height([val_seg_up, val_seg_down]) 
%     %determines the centroidal height of the beam
%     %based on the measurement of the wo segments of a diode
%     %   This determination is done asumming a perfect gaussian beam of 
%     %   and makes use sigma as defined in the properties; the method used
%     %   is psdeu-dichontomic and could be refined further if need
%     
%     total_power = values(1)+values(2); %unuseful, for reference
%     ratio = values(2)/values(1); %ratio of the two detected power
%     
% 	gauss  = @(x,y) exp(-(x.^2+y.^2)/this.beam_sigma_um.^2);
%     guess_position = 0; %initial guess for the position
%     merit = inf; %initial merit function value
%     threshold = 0.001; %precision in um required in the determination of the height
%     step = 1; %initial step size for the iteration
%     
%     i=1; %control index, to avoid infinite loops
%     while (abs(ratio-merit)>threshold && i<300)
%         %calculating the ratio between the two segments for the initial
%         %guess
%         down = quad2d(gauss,...
%             -this.detector_width_um/2,this.detector_width_um/2,...
%             -this.detector_height_um,              guess_position);
%         up = quad2d(gauss,...
%             -this.detector_width_um/2,this.detector_width_um/2,...
%             guess_position              ,this.detector_height_um/2);
%         merit = up/down;
%         mm(i) = merit;
% 
%         %height is updated
%         height = guess_position;
%         
%         %#danger
%         % if we are close to the threshold, we refine the step size, to
%         % avoid oscillation (there still can be some oscillation, though)
%         if abs((ratio-mm(i)))<5*threshold
%             step = step/2;
%         end
%         %updating the position guess
%         if merit > ratio
%             guess_position = guess_position+step;
%         else
%             guess_position = guess_position-step;
%         end
%         i = i+1; %useful to avoid infinite loops
%     end
%     
%         plot(ratio-mm); xlabel('iteration'); ylabel('\Delta guess'); title('dual2height')
% end
% 
% function height = getHeight(this,channel)
% 	R= this.R;
%     H = this.H;
%     aoi=this.aoi;
%     alpha2 = this.alpha2;
%     alpha3 = this.alpha3;
%     beta2 = this.beta2;
%     beta3 = this.beta3;
%     Delta = this.Delta;
%     %lines are the coordinates of all laser directions;
%     %i stand for incident, r for reflected.
%     %first row is the initial point, second is the direction
%     %reflected lines are calculated after the position of the wafer is set
%     
%     switch channel
%         case 1 %x-channel
%             %position of the laser
%             l0  = [-R;0;0];
%             %directing vector for the laser
%             l_0 = [0;0;-H] - [-R;0;0];
%         case 2
%             l0  = [-R*cos(alpha2);-R*sin(alpha2);0];
%             l_0 = [0;0;-H]-[-R*cos(alpha2);-R*sin(alpha2);0];
%         case 3
%             l0  = [-R*cos(alpha3);-R*sin(alpha3);0];
%             l_0 = [0;0;-H] - l0;
%         case 4 %y-offset channel
%             l0  = [0;-(R+Delta);0];
%             l_0 = [0;-Delta;-H] - l0;
%         case 5
%             l0  = [-(R+Delta)*cos(beta2);-(R+Delta)*sin(beta2);0];
%             l_0 = [-Delta*cos(beta2);-Delta*sin(beta2);-H] - l0;
%         case 6
%             l0  = [-(R+Delta)*cos(beta3);-(R+Delta)*sin(beta3);0];
%             l_0 = [-Delta*cos(beta3);-Delta*sin(beta3);-H] - l0;
%         otherwise
%             error('wrong channel selected (must be [1..6]) !')
%     end
% 
%     %one point of the wafer plane
%     p0 = [0;0;this.wafer.height-H];
%     %normal vector to wafer
%     n1 = this.wafer.nVector;
%     
%     %let's compute the intersection point between the laser and the wafer
%     wafer_intersection = ((p0-l0)'*n1)/(l_0'*n1);
%     
% %     %visualisation
%      t=linspace(0,wafer_intersection,100);
% %     plot(l0(1) + l_0(1)*t,l0(3) + l_0(3)*t,'k')
%     
%     %coordinate of the intersection point
% 	l1 = [l0(1) + l_0(1)*wafer_intersection;...
%           l0(2) + l_0(2)*wafer_intersection;...
%           l0(3) + l_0(3)*wafer_intersection];
%       
% 
%     %let's compute the directing vector for the reflected beam
%     theta_wafer = asin(n1'*[1;0;0]./norm(n1'*[0;0;1]));
%     refl_angle = aoi-2*theta_wafer;
%     height = l1(3)+H;
%     
%     %%%%for chan1 only
%     %direction vector for reflected beam
%     %l_1 = [cos(refl_angle) 0 sin(refl_angle)];
%     % changing the direction of the vector 
%     %(using a 180deg rotation matrix about z)
%     l_1 = [-1 0 0; 0 -1 0; 0 0 1]*l_0;
%     
%     
%     %position of the detector
%     p2 = -l0; % detector is at the opposite of the laser
%     switch channel
%         case 4 %y-offset channel
%             p2  = [0;(R-Delta);0];
%             %norm(p2+l0)
%         case 5
%             p2  = [(R-Delta)*cos(beta2);(R-Delta)*sin(beta2);0];
%         case 6
%             p2  = [(R-Delta)*cos(beta3);(R-Delta)*sin(beta3);0];
%     end
%         
%     %normal to the detector
%     n2 = -l0/norm(l0); % detector is at the opposite
%     
%     
%     %let's compute the directing vector for the reflected beam
%     diode_intersection = ((p2-l1)'*n2)/(l_1'*n2);
% 	l2 = [l1(1) + l_1(1)*diode_intersection;...
%           l1(2) + l_1(2)*diode_intersection;...
%           l1(3) + l_1(3)*diode_intersection];
% 
% 
%       height = (l1(3) + l_1(3)*diode_intersection)/2;
%         if channel >3
%            height
%            
%        end
% 
% 
%     
%     
% %     t2 = linspace(0,diode_intersection,100);
% % 
% %     if isempty(this.hAxisLaser1)
% %         this.hAxisLaser1 = axes('Parent',hParent,'Position',[0.1 0.3 0.2 0.2]);
% %         this.hAxisLaser2 = axes('Parent',hParent,'Position',[0.2 0.3 0.1 0.2]);
% %         this.hAxisLaser3 = axes('Parent',hParent,'Position',[0.3 0.3 0.2 0.1]);
% %     end
% %     
% %     
% %     plot(this.hAxisLaser1,l0(1) + l_0(1)*t,l0(2) + l_0(2)*t,'b',...
% %          l1(1)+l_1(1)*t2,l1(2)+l_1(2)*t2,'r');
% %     xlabel('x [um]')
% %     ylabel('y [um]')
% %     
% %     plot(this.hAxisLaser2,l0(3) + l_0(3)*t,l0(2) + l_0(2)*t,'b',...
% %          l1(3)+l_1(3)*t2,l1(2)+l_1(2)*t2,'r');
% %     xlabel('z [um]')
% %     ylabel('y [um]')
% %     
% %     plot(this.hAxisLaser3,l0(1) + l_0(1)*t,l0(3) + l_0(3)*t,'b',...
% %         l1(1)-acos(theta_wafer)*(-0.5e5:0.5e5),l1(3)+asin(theta_wafer)*(-0.5e5:0.5e5),'k',...
% %         l1(1)+l_1(1)*t2,l1(3)+l_1(3)*t2,'r');
% % 	xlabel('x [um]')
% %     ylabel('z [um]')
% 
% end
% 
% %#check orientation
% function [theta, phi] = getTilt(this)
%     %[theta, phi] = HeightSensor.GetTilt determines the tilt using the
%     %measurement of the offsetted channels
%     %#for debugging; setting hard heights
% %     height_i =0.2;
% %     height_j =0.2;
% %     height_k =0.2;
%     
% 
%     
%     idx4 = 4;
%     idx5 = 5;
%     idx6 = 6;
% 
%     height_i = this.getHeight(idx4);
%     height_j = this.getHeight(idx5);
%     height_k = this.getHeight(idx6);
%     
%     %position of the intersection points
%     I = [this.sensor_positions(:,idx4);height_i];
%     J = [this.sensor_positions(:,idx5);height_j];
%     K = [this.sensor_positions(:,idx6);height_k];
%     %cross products between vectors joining to intersection points
%     %will give 
%     ni = -cross(J-I,K-I)/norm(cross(J-I,K-I));
%     nj = -cross(K-J,I-J)/norm(cross(K-J,I-J));
%     nk = -cross(I-K,J-K)/norm(cross(I-K,J-K));
%     
%     nx = [1;0;0];
%     ny = [0;1;0];
%     nz = [0;0;1];
%     
%     theta   = asin(ni'*ny);
%     phi     = asin(ni'*nx);
% end
% 
% 
% function buildDiodes(this,hParent)
%     %HeightSensor.Panel displays the position of the beam for each channel
%     %based on the position of the wafer
%    
%     %meshrid for plotting
%     x= -this.detector_width_um/2:this.detector_width_um/2;
%     gauss  = @(x,y) exp(-(x.^2+y.^2)/this.beam_sigma_um.^2);
%     y= x*2;
%     [X,Y] = meshgrid(x,y);
%     %#for debugging : set arbitrary heights
%     height1 = this.getHeight(1);
%     height2 = this.getHeight(2);
%     height3 = this.getHeight(3);
%     height4 = this.getHeight(4);
%     height5 = this.getHeight(5);
%     height6 = this.getHeight(6);
%     
% %     height1 = this.getHeight(1);
% %     height2 = this.getHeight(2);
% %     height3 = this.getHeight(3);
% %     height4 = this.getHeight(4);
% %     height5 = this.getHeight(5);
% %     height6 = this.getHeight(6);
% if isempty(this.hAxisSensor1)
%     this.hAxisSensor1 = axes('Parent',hParent,'Position',[0.1 0.3 0.1 0.2]);
%     this.hAxisSensor2 = axes('Parent',hParent,'Position',[0.2 0.3 0.1 0.2]);
%     this.hAxisSensor3 = axes('Parent',hParent,'Position',[0.3 0.3 0.1 0.2]);
%     this.hAxisSensor4 = axes('Parent',hParent,'Position',[0.1 0.1 0.1 0.2]);
%     this.hAxisSensor5 = axes('Parent',hParent,'Position',[0.2 0.1 0.1 0.2]);
%     this.hAxisSensor6 = axes('Parent',hParent,'Position',[0.3 0.1 0.1 0.2]);
% end
%     %plotting everything
%     imagesc(x,y,gauss(X,Y-height1).*sign(Y),'Parent',this.hAxisSensor1);
%     set(this.hAxisSensor1,'Visible','off')
%     imagesc(x,y,gauss(X,Y-height2).*sign(Y),'Parent',this.hAxisSensor2);
%     set(this.hAxisSensor2,'Visible','off')
%     imagesc(x,y,gauss(X,Y-height3).*sign(Y),'Parent',this.hAxisSensor3);
%     set(this.hAxisSensor3,'Visible','off')
%     imagesc(x,y,gauss(X,Y-height4).*sign(Y),'Parent',this.hAxisSensor4);
% 
%     imagesc(x,y,gauss(X,Y-height5).*sign(Y),'Parent',this.hAxisSensor5);
%     set(this.hAxisSensor5,'Visible','off')
%     imagesc(x,y,gauss(X,Y-height6).*sign(Y),'Parent',this.hAxisSensor6);
%     set(this.hAxisSensor6,'Visible','off')
% end
% 
% 
% function cb_line(this,varargin)
%     this.buildLaser(this.hParent)
%     notify(this,'eChange');
% end
% 
% function buildLaser(this,hParent, varargin)
%     this.hParent = hParent;
%     if isempty(this.lbLine_select)
%         this.lbLine_select = uicontrol(  'Style','listbox',...
%                                 'String', '1|2|3|4|5|6',...
%                                 'Position', [450 300 10 88],...
%                                 'Callback',@this.cb_line);
%     end
%                         
%     channel = get(this.lbLine_select,'Value');    
%     
%     R= this.R;
%     H = this.H;
%     aoi=this.aoi;
%     alpha2 = this.alpha2;
%     alpha3 = this.alpha3;
%     beta2 = this.beta2;
%     beta3 = this.beta3;
%     Delta = this.Delta;
%     
%     switch channel
%         case 1 %x-channel
%             %position of the laser
%             l0  = [-R;0;0];
%             %directing vector for the laser
%             l_0 = [0;0;-H] - [-R;0;0];
%         case 2
%             l0  = [-R*cos(alpha2);-R*sin(alpha2);0];
%             l_0 = [0;0;-H]-[-R*cos(alpha2);-R*sin(alpha2);0];
%         case 3
%             l0  = [-R*cos(alpha3);-R*sin(alpha3);0];
%             l_0 = [0;0;-H] - l0;
%         case 4 %y-offset channel
%             l0  = [0;-(R+Delta);0];
%             l_0 = [0;-Delta;-H] - l0;
%         case 5
%             l0  = [-R*cos(beta2);-R*sin(beta2);0];
%             l_0 = [-Delta*cos(beta2);-Delta*sin(beta2);-H] - l0;
%         case 6
%             l0  = [-R*cos(beta3);-R*sin(beta3);0];
%             l_0 = [-Delta*cos(beta3);-Delta*sin(beta3);-H] - l0;
%         otherwise
%             error('wrong channel selected (must be [1..6]) !')
%     end
% 
%     %one point of the wafer plane
%     p0 = [0;0;this.wafer.height-H];
%     %normal vector to wafer
%     n1 = this.wafer.nVector;
%     wafer_intersection = ((p0-l0)'*n1)/(l_0'*n1);
% 	l1 = [l0(1) + l_0(1)*wafer_intersection;...
%           l0(2) + l_0(2)*wafer_intersection;...
%           l0(3) + l_0(3)*wafer_intersection];
%     theta_wafer = asin(n1'*[1;0;0]./norm(n1'*[0;0;1]));
%     refl_angle = aoi-2*theta_wafer;
%     height = l1(3)+H;
%     l_1 = [-1 0 0; 0 -1 0; 0 0 1]*l_0;
%     
%     %#correction
%     p2 = -l0; % detector is at the opposite of the laser
%     switch channel
%         case 4 %y-offset channel
%             p2  = [0;(R-Delta);0];
%             norm(p2+l0)
%         case 5
%             p2  = [(R-Delta)*cos(beta2);(R-Delta)*sin(beta2);0];
%         case 6
%             p2  = [(R-Delta)*cos(beta3);(R-Delta)*sin(beta3);0];
%     end
%     n2 = l0/norm(l0); % detector is at the opposite
%     diode_intersection = ((p2-l1)'*n2)/(l_1'*n2);
%     t=linspace(0,wafer_intersection,100);
%     t2 = linspace(0,diode_intersection,100);
% 
%     if isempty(this.hAxisLaser1)
%         this.hAxisLaser1 = axes('Parent',hParent,'Position',[0.5 0.3 0.2 0.2]);
%         this.hAxisLaser2 = axes('Parent',hParent,'Position',[0.75 0.3 0.1 0.2]);
%         this.hAxisLaser3 = axes('Parent',hParent,'Position',[0.5 0.15 0.2 0.1]);
%     end
%     
%     
%     plot(this.hAxisLaser1,l0(1) + l_0(1)*t,l0(2) + l_0(2)*t,'b',...
%          l1(1)+l_1(1)*t2,l1(2)+l_1(2)*t2,'r');
%     set(get(this.hAxisLaser1,'XLabel'),'String','x [um]')
%     set(get(this.hAxisLaser1,'YLabel'),'String','y [um]')
%     set(this.hAxisLaser1,'Xlim',[-R R]);
%     set(this.hAxisLaser1,'Ylim',[-R R]);
%     try
%         set(this.hAxisLaser1,'XTick',sort([l0(1);l1(1);l1(1)+l_1(1)*diode_intersection]))
%     catch err
%     end
%     try
%         set(this.hAxisLaser1,'YTick',sort([l0(2);l1(2);l1(2)+l_1(2)*diode_intersection]))
%     catch err
%     end
% 
%     
%     
%     plot(this.hAxisLaser2,l0(3) + l_0(3)*t,l0(2) + l_0(2)*t,'b',...
%          l1(3)+l_1(3)*t2,l1(2)+l_1(2)*t2,'r');
%      set(this.hAxisLaser2,'Xlim',[-1.1*H 0.1*H]);
%      set(this.hAxisLaser2,'Ylim',[-R R]);
%      try
%          set(this.hAxisLaser2,'XTick',sort([l0(3);l1(3);l1(3)+l_1(3)*diode_intersection]))
%      catch err
%      end
%      try
%          set(this.hAxisLaser2,'YTick',sort([l0(2);l1(2);l1(2)+l_1(2)*diode_intersection]))
%      catch err
%      end
%      
%      
%      
%      plot(this.hAxisLaser3,l0(1) + l_0(1)*t,l0(3) + l_0(3)*t,'b',...
%          l1(1)-acos(theta_wafer)*(-0.5e5:0.5e5),l1(3)+asin(theta_wafer)*(-0.5e5:0.5e5),'k',...
%          l1(1)+l_1(1)*t2,l1(3)+l_1(3)*t2,'r');
%      set(get(this.hAxisLaser3,'YLabel'),'String','z [um]')
%      set(this.hAxisLaser3,'Xlim',[-R R]);
%      set(this.hAxisLaser3,'Ylim',[-1.1*H 0.1*H]);
%      try
%          set(this.hAxisLaser3,'XTick',sort([l0(1);l1(1);l1(1)+l_1(1)*diode_intersection]))
%      catch err
%      end
%      try
%          set(this.hAxisLaser3,'XTick',sort([l0(3);l1(3);l1(3)+l_1(3)*diode_intersection]))
%      catch err
%      end
%     
% 
% end
% 
% 
% function test(this)
%     R= this.R;
%     H = this.H;
%     aoi=this.aoi;
%     alpha2 = this.alpha2;
%     alpha3 = this.alpha3;
%     beta2 = this.beta2;
%     beta3 = this.beta3;
%     Delta = this.Delta;
%     %lines are the coordinates of all laser directions;
%     %i stand for incident, r for reflected.
%     %first row is the initial point, second is the direction
%     %reflected lines are calculated after the position of the wafer is set
%     line_1i = [-R 0 0; 0 0 -H];
%     %line_1r ;
%     
%     line_2i = [-R*cos(alpha2) -R*sin(alpha2) 0; 0 0 -H];
%     %line_2r ;
%     
%     line_3i = [-R*cos(alpha3) -R*sin(alpha3) 0; 0 0 -H];
%     %line_3r ;
%     
%     line_4i = [0 -(R+Delta) 0; 0 -Delta -H];
%     %line_4r ;
%     
%     line_5i = [-R*cos(beta2) -R*cos(beta2) 0; -Delta*cos(beta2) -Delta*sin(beta2) -H];
%     %line_5r ;
%     
%     line_6i = [-R*cos(beta3) -R*cos(beta3) 0; -Delta*cos(beta3) -Delta*sin(beta3) -H];
%     %line_6r ;
%     
%     %one point of the wafer plane
%     p0 = [0 0 this.wafer.height];
%     %normal vector to wafer
%     n1 = this.wafer.nVector;
%     
%     %position of the laser
%     l0 = line_1i(1,:);
%     %directing vector for the laser
%     l_0 = line_1i(2,:) - line_1i(1,:);
%     
%     %let's compute the intersection point between the laser and the wafer
%     wafer_intersection = ((p0-l0)*n1')/(l_0*n1');
%     
%     t=linspace(0,wafer_intersection,100);
%     plot(line_1i(1,1)+(line_1i(2,1)-line_1i(1,1))*t,...
%          line_1i(1,3)+(line_1i(2,3)-line_1i(1,3))*t,'k')
% 	
%     
%     
%     %coordinate of the intersection point
% 	l1 = [line_1i(1,1)+(line_1i(2,1)-line_1i(1,1))*wafer_intersection ...
%           0 ...
%           line_1i(1,3)+(line_1i(2,3)-line_1i(1,3))*wafer_intersection];
%     %let's compute the directing vector for the reflected beam
%     theta_wafer = asin(n1*[1;0;0]./norm(n1*[0;0;1]));
%     refl_angle = aoi-2*theta_wafer;
%     
%     %%%%for chan1 only
%     %direction vector for reflected beam
%     l_1 = [cos(refl_angle) 0 sin(refl_angle)];
%     
%     %position of the detector
%     p2 = [R 0 0];
%     %normal to the detector
%     n2 = [-1 0 0];
%     %let's compute the directing vector for the reflected beam
%     diode_intersection = ((p2-l1)*n2')/(l_1*n2');
%     t2 = linspace(0,diode_intersection,100);
% 
%     plot(l1(1)+l_1(1)*t2,l1(3)+l_1(3)*t2);
%     
%     plot(line_1i(1,1)+(line_1i(2,1)-line_1i(1,1))*t,...
%          line_1i(1,3)+(line_1i(2,3)-line_1i(1,3))*t,'b',...
%          l1(1)-acos(theta_wafer)*(-0.5e5:0.5e5),l1(3)+asin(theta_wafer)*(-0.5e5:0.5e5),'k',...
%          l1(1)+l_1(1)*t2,l1(3)+l_1(3)*t2,'r');
%     axis equal
%     %plot((line_1i(2,1)-line_1i(1,1))*t,(line_1i(2,3)-line_1i(1,3))*t,...
%     %     l1(1)+(l_1(1)-l1(1))*t2,l1(3)+(l_1(3)-l1(3))*t2);
% end
%     
% end
%     
% end

