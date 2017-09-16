purge;


% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

clock = Clock('Master');
ts = TempSensor(clock);
h = figure;
ts.build(h, 10, 10);
