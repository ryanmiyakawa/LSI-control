purge

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure( ...
    'Position', [20 20 800 600] ... % left bottom width height
);

pfs = PupilFillSelect();%
pfs.build(h, 10, 10);
