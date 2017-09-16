% Assume tilt about x axis then tilt about y axis

addpath(genpath(fullfile(pwd, '../../Functions')));

close all
clc
clear

dThetaX = 15*pi/180;
dThetaY = 10*pi/180;
dHeight = 100e-6;

% Normal vector.  Assumes rotation about the x axis by dThetaX, then in
% this new coordinate system, rotate about the y axis by dThetaY

dN = [sin(dThetaY) -cos(dThetaY)*sin(dThetaX) cos(dThetaY)*cos(dThetaX)]

% Use the point v1 = [0, 0, 0] as in the known point in the plane.  
% Use v2 = [x, y, z] as the general point in the plane
% The equation of the plane is n dot (v2 - v1) = 0 or 
% dN(1)*x + dN(2)*y + dN(3)*z = 0
% Solving for z gives z = (dN(1)*x + dN(2)*y)/dN(3) then we just shift z

dNum = 20;
dLength = 6*25.4e-3;

dX = linspace(-dLength/2, dLength/2, dNum);
dY = fliplr(linspace(-dLength/2, dLength/2, dNum));

[dXX, dYY] = meshgrid(dX, dY);

z = @(x,y) (-dN(1).*x - dN(2).*y)./dN(3) + dHeight;
dZZ = z(dXX, dYY);


figure
surf(dXX, dYY, dZZ);
xlabel('x');
ylabel('y');
zlim([-20e-3, 20e-3])

% Given x, y can ask for height

dP1 = [0.5, 0]*1e-1;
dP2 = [-0.3, -0.3]*1e-1;
dP3 = [-0.3, 0.3]*1e-1;

dH1 = z(dP1(1), dP1(2));
dH2 = z(dP2(1), dP2(2));
dH3 = z(dP3(1), dP3(2));

dMeas1 = [dP1, dH1];
dMeas2 = [dP2, dH2];
dMeas3 = [dP3, dH3];

hold on
dMarkerSize = 50
plot3(dP1(1), dP1(2), dH1, '.r', 'MarkerSize', dMarkerSize);
plot3(dP2(1), dP2(2), dH2, '.b', 'MarkerSize', dMarkerSize);
plot3(dP3(1), dP3(2), dH3, '.k', 'MarkerSize', dMarkerSize);

% Given the points, compute the normal

dMeasV1 = dMeas3 - dMeas1;
dMeasV2 = dMeas2 - dMeas1;

dNMeas = cross(dMeasV1, dMeasV2);
dNMeas = dNMeas./(sqrt(sum(dNMeas.^2)))


% Using the normal, can figure out the height at each sensor
% minus the DC offset. The difference between the measured height at the
% location of the sensor and the mathematical height of the plane gives the
% offset.  Use the average of all three

zMeasPlane = @(x,y) (-dNMeas(1).*x - dNMeas(2).*y)./dNMeas(3);

dOffset1 = dH1 - zMeasPlane(dP1(1), dP1(2));
dOffset2 = dH2 - zMeasPlane(dP2(1), dP2(2));
dOffset3 = dH3 - zMeasPlane(dP3(1), dP3(2));

dOffsetAvg = (dOffset1 + dOffset2 + dOffset3)/3;

% There is probably a good way to figure out the error based on the height
% returned since the sensor locations move with height and angle

dTheta1 = 30*pi/180;
dTheta2 = 150*pi/180;
dTheat3 = -90*pi/180;  % Use as the join in the dot product

dTheta = [30, 150, -90]*pi/180;



% You are given height measurements from three sensors.  If the height is
% not zero, the x/y locations of the sensors won't be the design location.
% The interaction area where the sensor meassures the wafers radially
% shifts in as the wafer moves up and radially shifts out as the wafer
% moves down

% Step 1: Figure out where the sensors measure the surface based on the
% actual wafer height.  (Assume tip + tilt = 0, or that their effect is
% negligible) 
%
% Step 2: Figure out z value of the plane at these locations.


dR0     = 4e-3;
dAOI    = 3*pi/180;
dR      = dR0 - dHeight/tan(dAOI)

% Get the height of the actual plane at each of the three sensor 
% interaction areas

for m = 1:length(dTheta)
        
    dX = dR*cos(dTheta(m));
    dY = dR*sin(dTheta(m));    
    dZMeas(m) = z(dX, dY);

end

dZMeas

% Step 3: Start by assuming that the z offset of the plane is 0. I.E., the
% the reported sensor readings do come from design x, y locations.  Based
% on the three 3D points, compute the normal to the plane, and the equation
% of the plane.
%
% Step 4: With the equation of the plane, compute the difference between
% the height of the plane at the (x, y) location of each sensor, and the
% reported height measured at that sensor. This offset should be about the
% same for each sensor.  The mean of this is the approximate z offset of
% the plane.
%
% Repeat, this time the guess for z offset equal to the value computed in
% the previous loop. Use this z value to correct the (x, y) locations of
% each sensor position, giving a new set of three (x, y, z) points (always
% use the z reported by the sensors.  Compute a new normal, and again
% compute the z-offset.
%
% Keep doing this until the computed z-offset matches the initial guess.
% This means there is consistency and the result will be correct.

dZGuess = 0;

for (n = 1:2)
    
    % Corrected sensor radius offset
    dR = dR0 -dZGuess/tan(dAOI)
    
    % Corrected sensor location based on the guess of the z offset and
    % generate three assumed (x, y, z) measured points on the plane.  Note
    % the x, y locations will be wrong initially if z offset != 0
    
    for m = 1:length(dTheta)
        
        dX = dR*cos(dTheta(m));
        dY = dR*sin(dTheta(m));
        dXYZMeas(m, :) = [dX, dY, dZMeas(m)]
                
    end
    
    % Two in-plane vectors
    
    dV1 = dXYZMeas(1, :) - dXYZMeas(3, :);
    dV2 = dXYZMeas(2, :) - dXYZMeas(3, :);
    
    % Cross product and normalize to get the normal to the plane
    
    dNMeas = cross(dV1, dV2);
    dNMeas = dNMeas./(sqrt(sum(dNMeas.^2)))
    
    % Generate a function that gives the height of the plane as a function
    % of x, y coordinate
    
    zMeasPlane = @(x,y) (-dNMeas(1).*x - dNMeas(2).*y)./dNMeas(3);
    
    % Using the assumed three (x, y) sensor locations, get the difference
    % in height between the reported sensor height and the height of the
    % plane
    
    for m = 1:length(dTheta)
        dOffset(m) = dXYZMeas(m, 3) - zMeasPlane(dXYZMeas(m, 1), dXYZMeas(m, 2));
    end
    
    dOffset
    dOffsetAvg = mean(dOffset)
    dError = dZGuess - dOffsetAvg
    
    % Update dZ to the average offset and iterate
    dZGuess = dOffsetAvg

end
      






