purge;

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure;
clock = Clock('Master');
hio = HardwareIOWithSave('test', clock);
hio.build(h, 10, 10);
