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

cl = Clock('master');
hio = HardwareIO('Test Motor', cl);
hio.api = APIVHardwareIO('TestAPI', 0, cl);
hio.build(h, 10, 10);
