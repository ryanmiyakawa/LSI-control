purge;


% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

cl = Clock('Master');
icc = InterferometerCameraControl(cl);
icc.build()
