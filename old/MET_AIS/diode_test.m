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

h = figure;

clock = Clock('master');
di = Diode('test', clock);
di.build(h, 10, 10);
