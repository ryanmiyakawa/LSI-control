% Lissajous

close all
clear
clc

% x = A*sin(at * delta)
% b = B*sin(bt)

dA = 1;
dB = 1;

da = 5;
db = 4;

% There are two options. 
%
% 1. Choose the average scan frequency; period is deterministic
% 2. Choose the period of the full fill ans solve for average scan freq


dFreqAvg = 100;
dPeriod = 40e-3;

lUsePeriod = false;

if (lUsePeriod)
    
    % Solve for frequency scale factor used in Lissajous eqn based on
    % period
    
    dFreqScale = lcm(da, db)/(da*db)/dPeriod;

else
    
    % Solve for freqscale based on avg frequency and compute period based
    % on the scale factor.  The Lissajous pattern can be reformulated as:
    %
    % x = sin(2*pi*a*f_scale*t)
    % y = sin(2*pi*b*f_scale*t)
    %
    % With this formulation, the frequency of the x waveform is a*f_scale
    % and the frequency of the y waveform is b*f_scale.  If the average
    % freq is to be f_avg, f_scale can be solved for with this eqn:
    %
    % f_avg = (a + b)*f_scale/2
    %
    % The idea of the Lissajous that it is two sin waves that are at
    % slightly different frequencies.  The "Lissajous period" is the least 
    % common multiple of the individual periods.  There is a simple
    % calculation here:
    % http://stackoverflow.com/questions/9620324/how-to-calculate-the-period-of-a-lissajous-curve

    
    dFreqScale = dFreqAvg*2/(da + db);
    dPeriod = lcm(da, db)/(da*db)/dFreqScale;
    
end


dDelta = 0;
dTimeStep = 24e-6;

% Period is least common multiple of the periods normalized by the product
% of the frequency.  It will always be something like 
% http://stackoverflow.com/questions/9620324/how-to-calculate-the-period-of-a-lissajous-curve

dT = 0:dTimeStep:dPeriod;

dX = dA*sin(2*pi*da*dFreqScale*dT + dDelta);
dY = dA*sin(2*pi*db*dFreqScale*dT);

figure
plot(dX, dY, '.b');

figure
hold on
plot(dT, dX, '-r');
plot(dT, dY, '-b');
