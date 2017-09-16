purge;


% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

clock = Clock('Master');
rl = ReticleLeveler(clock, 'Reticle-Leveler');
h = figure;
rl.build(h, 10, 10);
