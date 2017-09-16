
clear
clc
close all

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));

dSigX = 0.1;
dPhaseX = 1/4;
dOffsetX = 0;

dSigY = 0.2;
dPhaseY = 0;
dOffsetY = 0;

dScale = 10;
dHz = 100;
dFilterHz = 10000;
dTimeStep = 24e-6;

st = PupilFillCore.getSaw( ...
    dSigX, ...
    dPhaseX, ...
    dOffsetX, ...
    dSigY, ...
    dPhaseY, ...
    dOffsetY, ...
    dScale, ...
    dHz, ...
    dFilterHz, ...
    dTimeStep);


figure
hold on
plot(st.dT, st.dX, '.-r');
plot(st.dT, st.dY, '.-b');


st = PupilFillCore.getSerpentine( ...
    1, ...
    1, ...
    8, ...
    8, ...
    0, ...
    0, ...
    50e-3, ...
    10, ...
    1000, ...
    24e-6);


figure
subplot(121)
hold on
plot(st.dT, st.dX, '.-r');
plot(st.dT, st.dY, '.-b');
subplot(122)
plot(st.dX, st.dY, '.b');
axis image



st = PupilFillCore.getSerpentine2( ...
    1, ...
    1, ...
    7, ...
    7, ...
    0, ...
    0, ...
    50e-3, ...
    10, ...
    1000, ...
    24e-6);


figure
subplot(121)
hold on
plot(st.dT, st.dX, '.-r');
plot(st.dT, st.dY, '.-b');
subplot(122)
plot(st.dX, st.dY, '.b');
axis image

