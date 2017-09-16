% serpentine

clear
clc
close all

dXAmp = 10;
dYAmp = 4;

dVertNum = 8;  % number of ver lines
dHorzNum = 8;  % number of hor lines

%{

Total "length" of one period of horizontal serpeintine, including vertical
connectors is 2*dYAmp + dYNum*dXAmp; Length of vertical serpentine,
including horizontal connectors is 2*dXAmp + dXNum*dYAmp;

The total length is the sum

%}

% Assume constant velocity of beam.  This means length and time are
% proportional

dTimeStep       = 24e-6;
dPeriod         = 200e-3;

dN = round(dPeriod/dTimeStep)

dLength = 2*dYAmp + dHorzNum*dXAmp + 2*dXAmp + dVertNum*dYAmp
dDelta = dLength/dN

% Points in full lines
dNX = floor(dXAmp/dLength*dN) % lr
dNY = floor(dYAmp/dLength*dN) % ud

% Points in partial line

dLengthXPartial = dXAmp/(dVertNum - 1)
dLengthYPartial = dYAmp/(dHorzNum - 1);

dNXPartial = floor(dLengthXPartial/dLength*dN)
dNYPartial = floor(dLengthYPartial/dLength*dN)

% Points in partial ver

% First set of in horizontal lines

xrow = linspace(-dXAmp/2, dXAmp/2, dNX);
yrow = linspace(-dYAmp/2, dYAmp/2, dNY);


h_x = [];
h_y = [];

for n = 0:dHorzNum/2 - 1
    
    
    if (n == dHorzNum/2 - 1)
        y1 = n*2*dLengthYPartial - dYAmp/2;
        y2 = (n + 1)*2*dLengthYPartial - dLengthYPartial - dYAmp/2;
        yrow_partial = linspace(y1, y2, dNYPartial/2);
    else
        y1 = n*2*dLengthYPartial - dYAmp/2;
        y2 = (n + 1)*2*dLengthYPartial - dYAmp/2;
        yrow_partial = linspace(y1, y2, dNYPartial);
    end
    
            
    if mod(n,2) == 0
        
        
        % Even.  Goes
        h_x(end + 1: end + dNX) = xrow;
        h_x(end + 1: end + length(yrow_partial)) = dXAmp/2;
        
        
        h_y(end + 1: end + dNX) = y1;
        h_y(end + 1: end + length(yrow_partial)) = yrow_partial;
        
    else
        
        h_x(end + 1: end + dNX) = fliplr(xrow);
        h_x(end + 1: end + length(yrow_partial)) = -dXAmp/2;
        
        h_y(end + 1: end + dNX) = y1;
        h_y(end + 1: end + length(yrow_partial)) = yrow_partial;      
        
    end
    
end

figure 
hold on
plot([1:1:length(h_x)], h_x, '.-r')
plot([1:1:length(h_y)], h_y, '.-b')


if (mod(dHorzNum, 4) == 0)
    h_x_full = [h_x, h_x];
else
    h_x_full = [h_x, -h_x];
end

h_y_full = [h_y, -h_y];


figure
subplot(121)
hold on
plot([1:1:length(h_x_full)], h_x_full, '.-r')
plot([1:1:length(h_y_full)], h_y_full, '.-b')
subplot(122)
plot(h_x_full, h_y_full, '.-b');

v_x = [];
v_y = [];

for n = 0:dVertNum/2 - 1
    
    
    if (n == dVertNum/2 - 1)
        x1 = n*2*dLengthXPartial - dXAmp/2;
        x2 = (n + 1)*2*dLengthXPartial - dLengthXPartial - dXAmp/2;
        xrow_partial = linspace(x1, x2, dNXPartial/2);
    else
        x1 = n*2*dLengthXPartial - dXAmp/2;
        x2 = (n + 1)*2*dLengthXPartial - dXAmp/2;
        xrow_partial = linspace(x1, x2, dNXPartial);
    end
    
            
    if mod(n,2) == 0
        
        % Even.  Goes
        v_x(end + 1: end + dNY) = x1;
        v_x(end + 1: end + length(xrow_partial)) = xrow_partial;
        
        
        v_y(end + 1: end + dNY) = yrow;
        v_y(end + 1: end + length(xrow_partial)) = dYAmp/2;
        
    else
        
        
        
        % Even.  Goes
        v_x(end + 1: end + dNY) = x1;
        v_x(end + 1: end + length(xrow_partial)) = xrow_partial;
        
        
        v_y(end + 1: end + dNY) = fliplr(yrow);
        v_y(end + 1: end + length(xrow_partial)) = -dYAmp/2;
              
        
    end
    
end


figure 
subplot(121)
hold on
plot([1:1:length(v_x)], v_x, '.-r')
plot([1:1:length(v_y)], v_y, '.-b')
title('vertical scan first half');
legend({'x', 'y'})
subplot(122)
plot(v_x, v_y, '.-b');



v_x_full = [v_x, -v_x];

if (mod(dVertNum, 4) == 0)
    v_y_full = [v_y, v_y];
else
    v_y_full = [v_y, -v_y];
end


figure
subplot(121)
hold on
plot([1:1:length(v_x_full)], v_x_full, '.-r')
plot([1:1:length(v_y_full)], v_y_full, '.-b')
title('vertical scan full');
legend({'x', 'y'})
subplot(122)
plot(v_x_full, v_y_full, '.-b');



x = [h_x_full, v_x_full];
y = [h_y_full, v_y_full];

figure
subplot(121)
hold on
plot([1:1:length(x)], x, '.-r')
plot([1:1:length(y)], y, '.-b')
title('horizontal + vertical scan full');
legend({'x', 'y'})
subplot(122)
plot(x, y, '.-b')
title('x vs y');
axis image







