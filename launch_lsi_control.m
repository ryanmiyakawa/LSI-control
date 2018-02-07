% delete timers:
if exist('purge', 'file')
    purge;
end

% micpath:
% First just get mic.Utils so we can have genpath_exclude:
cMicPath = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'cnanders', 'matlab-instrument-control', 'src');
addpath(cMicPath);
addpath(mic.Utils.genpath_exclude(cMicPath, {'\+mic'}));

% Hardware path:
cBL12Path = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '..', 'src');
addpath(cBL12Path);
% micpath:

hardware = bl12014.Hardware();


app = lsicontrol.ui.LSI_Control('hardware', hardware);



%%
app.build()

if strcmp(char(java.lang.System.getProperty('user.name')), 'rhmiyakawa')
    drawnow
%     app.hFigure.Position = [29        -165        1750        1000];
%    lsi.hFigure.Position = [-3966         500        1600         1000];
end