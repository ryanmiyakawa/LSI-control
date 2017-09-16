% Open this shortcut from the desktop to make sure that the javapath is
% initialized in the right director.

% Running this script will create and build a ZTS_Control instance and
% connect to the hexapod.



[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% mic library
cDirMic = '../matlab-instrument-control';
addpath(genpath(cDirMic));

% example/app src
cDirSrc = fullfile(cDirThis, 'mic_src');
addpath(genpath(cDirSrc));

% vendor
cDirVendor = fullfile(cDirThis, 'vendor');
addpath(genpath(cDirVendor));

purge

app = app.LSI_Control();

