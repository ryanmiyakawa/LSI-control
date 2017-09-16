purge;

addpath(pwd);
addpath(fullfile(pwd,'classes'));
addpath(fullfile(pwd,'functions'));

h = figure;
a = ReticlePickPanel();
a.build(h, 10, 10);
