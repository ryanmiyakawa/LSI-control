% Open this shortcut from the desktop to make sure that the javapath is
% initialized in the right director.

addpath('../ryan_toolbox');

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% mic library
cDirMic = '../matlab-instrument-control';
addpath(genpath(cDirMic));

% example/app src
cDirSrc = fullfile(cDirThis, 'mic_src');
addpath(genpath(cDirSrc));

purge
cJavaLibPath = pwd;
app = app.LSI_Control();

