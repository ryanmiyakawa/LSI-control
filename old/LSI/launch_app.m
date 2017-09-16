[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% mic library
cDirMic = '../../matlab-instrument-control';
addpath(genpath(cDirMic));

% example/app src
cDirSrc = fullfile(cDirThis, 'src');
addpath(genpath(cDirSrc));

% vendor
cDirVendor = fullfile(cDirThis, 'vendor');
addpath(genpath(cDirVendor));

purge

app = app.LSI_Control();

%
% FUN STUFF TO COPY TO THE COMMAND WINDOW

% 1.
% Click the jog button a few times so the value is not zero

% 2. 
% Copy this code to command window

% 
% % Get value in mm units
% app.uiDeviceX.getValCal('mm')
% % Get value in um units
% app.uiDeviceX.getValCal('um')
% % Get value in the display units (whatever they happen to be)
% app.uiDeviceX.getValCalDisplay()
% % Get value in raw units (no conversion from the device)
% app.uiDeviceX.getValRaw()



%{
app.uiDeviceX.turnOn()
app.uiDeviceX.turnOff()
app.uiDeviceX.disable()
app.uiDeviceX.setDestCal(5, 'mm')
app.uiDeviceX.moveToDest()
%}
