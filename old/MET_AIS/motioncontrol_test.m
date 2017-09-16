purge;


% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

clock = Clock('Master');
mc = MotionControl( ...
    clock, ...
    'M141-Stage', ...
    uint8([0, 1, 2]), ...
    {'X', 'Y', 'Z'} ...
);

h = figure;
mc.build(h, 10, 10);
