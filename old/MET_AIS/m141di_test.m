purge;

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure;
cl = Clock('Master');
m141di = M141Diode(cl);
m141di.build(h, 10, 10);
