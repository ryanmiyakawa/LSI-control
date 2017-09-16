purge;

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

h = figure;
cl = Clock('Master');
hs = HeightSensor('Height Sensor', cl);
% np.build(h, 10, 10);
