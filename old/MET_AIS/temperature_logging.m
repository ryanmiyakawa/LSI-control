%% Temperature-log
% Here's a script that helps you log the temperature;
% It requires to have the GalilXZStageLib-1.0.jar in the same folder, and
% uses the met5gui (in particular the Monitor class)
% Over long measurement campaign, make sure to deactivate the mac sleep
% mode (the "Cafeine" app does that temporarily)


% Manually
% IP: 192.168.1.10
% Subnet: 255.255.255.0
% Router: 192.168.1.1

addpath(pwd);
addpath(fullfile(pwd,'classes'));

%% Connecting to the Wago

javaaddpath('jar/GalilXZStageLib-1.0.jar')

%%
wago = cxro.serm.wago.DiodeSensorWago('192.168.1.7');
wago.connect();

%% Calibration

wago2temp_c =  327.67;




%% better

%clock for the monitor
cl = Clock('Temperature');
%create a function handle to measure the temperature
readTemp = @() 327.67*wago.getSingleInput(0);
monitor = Monitor('Temperature',cl,readTemp);

%%
monitor.sampling_freq_Hz = 1;
monitor.duration_s       = 60*5; % 1 hr

%%

%in case you want to save the measurement later
monitor.filename = 'mytemplog';

hTemp = figure;
monitor.build(hTemp);

% monitor.start
monitor.acquire;

%conversely,
%monitor.acquire %will automatically save the data the end of run

%%
%monitor.saveToFile()