purge

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure();


st1 = struct();
st1.lAsk        = true;
st1.cTitle      = 'Switch?';
st1.cQuestion   = 'Do you want to change from true to false?';
st1.cAnswer1    = 'Yes of course!';
st1.cAnswer2    = 'No not yet.';
st1.cDefault    = st1.cAnswer2;


st2 = struct();
st2.lAsk        = true;
st2.cTitle      = 'Switch?';
st2.cQuestion   = 'Do you want to change from true to false?';
st2.cAnswer1    = 'Yes of course!';
st2.cAnswer2    = 'No not yet.';
st2.cDefault    = st2.cAnswer2;

clock = Clock('Master');
hiot = HardwareIOToggle( ...
    'Test', ...
    clock, ...
    'Test', ...
    imread(sprintf('%s/assets/axis-play.png', pwd)), ...
    imread(sprintf('%s/assets/axis-pause.png', pwd)), ...
    st1, ...
    st2);

hiot.build(h, 10, 10);
