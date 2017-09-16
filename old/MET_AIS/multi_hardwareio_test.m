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

for n = 0:60
    
    hio = HardwareIO(sprintf('Test %.0f', n), cl);
    hio.api = APIVHardwareIO(cName, 0, cl);
    hio.build(h, 10, 10 + 4*n);

end