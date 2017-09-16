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

cName = 'Test';
cl = Clock('master');
ho = HardwareO(cName, cl);% 
ho.api = APIVHardwareO('TestAPI', cl);
ho.build(h, 10, 10);
