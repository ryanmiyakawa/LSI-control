purge;

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure( ...
    'Position', [20 20 1250 720] ... % left bottom width height
);
cl = Clock('Master');
rd = ReticleDisplay(cl);
rd.build(h, 20, 20);
