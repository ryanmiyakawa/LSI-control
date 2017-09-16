purge

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd, 'classes'));
addpath(fullfile(pwd, 'functions'));

dHeight         = 500;
dWidth          = 1270;

%{
h = figure( ...
    'Position', [(1280-dWidth)/2 (780-dHeight)/2 dWidth dHeight], ... % left bottom width height
    'Menubar', 'none' ...
);
%}

pretool = PreTool();
% pretool.build(h, 10, 10);
pretool.build();
