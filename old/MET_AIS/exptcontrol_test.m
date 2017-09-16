purge

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd, 'classes'));
addpath(fullfile(pwd, 'functions'));


clock               = Clock('Master');
reticleControl      = ReticleControl(clock);
waferControl        = WaferControl(clock);
pupilFill           = PupilFill(clock, 'pupil');
preTool             = PreTool();
shutter             = Shutter('imaging', clock);
exptControl         = ExptControl( ...
                        clock, ...
                        shutter, ...
                        waferControl, ...
                        reticleControl, ...
                        pupilFill);



exptControl.build();
