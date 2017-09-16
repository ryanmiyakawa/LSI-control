purge;

addpath(pwd);
addpath(fullfile(pwd,'classes'));
addpath(fullfile(pwd,'functions'));

h = figure;
rt = ReticleTool();
rt.build(h, 10, 10);
