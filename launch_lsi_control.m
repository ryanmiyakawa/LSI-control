% Open this shortcut from the desktop to make sure that the javapath is
% initialized in the right director.

addpath('../../../ryan_toolbox');

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Java path:
cJavaLibPath = pwd;

% mic library
cDirMic = '../../../matlab-instrument-control';
addpath(genpath(cDirMic));

% example/app src
cDirSrc = cDirThis;
addpath(genpath(cDirSrc));

purge
% delete timers:
delete(timerfind)

cJavaLibPath = pwd;
app = lsicontrol.ui.LSI_Control('cJavaLibPath', cJavaLibPath);

