purge;


% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

h = figure();

cl = Clock('Master');
d141 = D141(cl);
d141.build(h, 10, 10)
