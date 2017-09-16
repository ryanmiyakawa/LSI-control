purge;

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure( ...
    'Position', [20 50 500 720], ... % left bottom width height
    'MenuBar', 'none' ...
);
cl = Clock('Master');
m3cap = Mod3CapSensor(cl);
m3cap.build(h, 10, 10);
