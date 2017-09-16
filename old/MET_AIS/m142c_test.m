purge;


% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

cl = Clock('Master');
m142c = M142Control(cl);
m142c.build()
