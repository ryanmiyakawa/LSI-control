purge

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);
            

% if ~isempty(timerfind)
%     stop(timerfind);
%     delete(timerfind); % delete existing timers
% end

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure( ...
    'Position', [20 20 800 600] ... % left bottom width height
);

ft = FEMTool();
ft.build(h, 10, 10);

fh = @(src, evt) disp(evt.stData.dX);
addlistener(ft, 'eSizeChange', fh);
