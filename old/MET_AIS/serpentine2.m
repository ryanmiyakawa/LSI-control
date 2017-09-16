% serpentine

clear
clc
close all

dXAmp = 10;
dYAmp = 4;

dNumX = 7;  % number of ver lines always make odd
dNumY = 5;  % number of hor lines always make odd

% Assume constant velocity of beam.  This means length and time are
% proportional

dTimeStep       = 24e-6;
dPeriod         = 200e-3;

dN = round(dPeriod/dTimeStep);

% Width of X partial
dXPartial = dXAmp/(dNumX - 1);
dYPartial = dYAmp/(dNumY - 1);

% Lowest horizontal line gets half a x partial length added to right
% Top horizontal line gets half a x partial length added to left
% Middle horizontal lines get full x partial added (half on each side)

dLength1 = (dXAmp + dXPartial/2)*2 + (dXAmp + dXPartial)*(dNumY - 2) + dYAmp;

% Right vertical line gets half a y partial length added to bottom
% Middle vertical lines get full y partial added (half on top half on bot)
% Left horizontal line gets half a y partial length added to top

dLength2 = (dYAmp + dYPartial/2)*2 + (dYAmp + dYPartial)*(dNumY - 2) + dXAmp;

% Length of full fill

dLength = dLength1 + dLength2;

% Distance between samples

dDelta = dLength/dN; 

% Draw scan dominated by horizontal line

h_x = [];
h_y = [];

for n = 1:dNumY
    
    if mod(n, 2) == 0
        % even
        % goes right to left.  even are always in the middle so they get
        % half of a partial on left and right side
        % baseline start is right; baseline end is left
        
        x1 = dXAmp/2 + dXPartial/2;
        x2 = -dXAmp/2 - dXPartial/2;
        
        x = x1:-dDelta:x2;
                
    else
        % odd
        % left to right
        if n == 1
            
            % add half partial on right
            x1 = -dXAmp/2;
            x2 = dXAmp/2 + dXPartial/2;
        
        elseif n == dNumY
            
            % add half partial on left
            x1 = -dXAmp/2 - dXPartial/2;
            x2 = dXAmp/2;
            
        else
            
            % add half partial on right and left
            x1 = -dXAmp/2 - dXPartial/2;
            x2 = dXAmp/2 + dXPartial/2;
        end
        
        x = x1:dDelta:x2;

        
    end
    
    y1 = (n - 1)*dYPartial - dYAmp/2;
    y2 = (n)*dYPartial - dYAmp/2;
    
    
    y = y1:dDelta:y2;
    
    % Draw horizontal line
    h_x(end + 1: end + length(x)) = x;
    h_y(end + 1: end + length(x)) = y1;
    
    if (n ~= dNumY)
    
        % Draw vert line
        h_x(end + 1: end + length(y)) = x2;
        h_y(end + 1: end + length(y)) = y;
    end
    
end


figure 
subplot(121)
hold on
plot([1:1:length(h_x)], h_x, '.-r')
plot([1:1:length(h_y)], h_y, '.-b')

subplot(122)
plot(h_x, h_y, '.-b')



v_x = [];
v_y = [];

for n = 1:dNumX
    
    if mod(n, 2) == 0
        
        % even
        % bottom to top.  even are always in the middle so they get
        % half of a partial on left and right side
        % baseline start is right; baseline end is left
        
        y1 = -dYAmp/2 - dYPartial/2;
        y2 = dYAmp/2 + dYPartial/2;
                
        y = y1:dDelta:y2;
                
    else
        % odd
        % top to bottom
        if n == 1
            
            % add half partial on bottom
            
            y1 = dYAmp/2;
            y2 = -dYAmp/2 - dYPartial/2;
         
        
        elseif n == dNumX
            
            % add half partial on top
            
            y1 = dYAmp/2 + dYPartial/2;
            y2 = -dYAmp/2;
            
            
        else
            
            % add half partial on top and bottom
            
            y1 = dYAmp/2 + dYPartial/2;
            y2 = -dYAmp/2 - dYPartial/2;
            
            
        end
        
        y = y1:-dDelta:y2;
        
        
    end
    
    % x goes from right to left
    
    x1 = dXAmp/2 - (n - 1)*dXPartial;
    x2 = dXAmp/2 - (n)*dXPartial;
    
    x = x1:-dDelta:x2;
    
    
    % Draw vertical line
    v_y(end + 1:end + length(y)) = y;
    v_x(end + 1:end + length(y)) = x1;
    
   
    
    if (n ~= dNumX)
    
        % Draw horizontal line after
        
        v_y(end + 1:end + length(x)) = y2;
        v_x(end + 1:end + length(x)) = x;
        
    end
    
end


figure 
subplot(121)
hold on
plot([1:1:length(v_x)], v_x, '.-r')
plot([1:1:length(v_y)], v_y, '.-b')
subplot(122)
plot(v_x, v_y, '.-b')

% Add everything

x_full = [h_x, v_x]
y_full = [h_y, v_y];

figure 
subplot(121)
hold on
plot([1:1:length(x_full)], x_full, '.-r')
plot([1:1:length(y_full)], y_full, '.-b')
subplot(122)
plot(x_full, y_full, '.-b')
axis image






