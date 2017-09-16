% % close all, then clear
% 
% % close all initializes the 'CloseRequestFunction' of every window that has
% % a visible handle.
% 
% % This order is important because it deletes any open windows that have a
% % visible handle, before deleting the reference to the objects that created
% % the windows. If you call clear first, you delete reference to the object
% % that created the open window but the open window stays open and now you
% % have a window that points to nothing which crashes MATLAB when you try to
% % interact with the window.
% 
% % Whenever you run clear on a class instance, it calls the destructor (if
% % defined) BUT only when there are no outstanding references to the object
% % (like open windows, etc).  To define a destructor, define a delete()
% % method in the class
% 
% close all 
% 
% % loop through workspace variables and call delete on each one
% % that is an object
% 
% ceVars = who;
% for(n = 1:length(ceVars))
%    if isobject(eval(ceVars{n})) &&...
%       isvalid(eval(ceVars{n}))
%        fprintf('multi_test deleting %s\n', ceVars{n});
%        delete(eval(ceVars{n}));
%    end
% end
% 
% clear all

purge;

% Set current directory to the directory containing this file
[filepath, filename, ext] = fileparts(mfilename('fullpath'));
cd(filepath);

addpath(pwd);
addpath(fullfile(pwd,'classes'));


h = figure;

cl = Clock('Master');
axWaferX = Axis('Wafer X', cl);
axWaferY = Axis('Wafer Y', cl);
axWaferZ = Axis('Wafer Z', cl);
axWaferX2 = Axis('Wafer X2', cl);
axWaferY2 = Axis('Wafer Y2', cl);
axWaferZ2 = Axis('Wafer Z2', cl);

axWaferX3 = Axis('Wafer X3', cl);
axWaferY3 = Axis('Wafer Y3', cl);
axWaferZ3 = Axis('Wafer Z3', cl);

diM1 = Diode('M1 pop-in', cl);
diM2 = Diode('M2 pop-in', cl);
sh1 = Shutter('MET shuter', cl);
sh2 = Shutter('DCT shutter', cl);

dSep = 50;

dLeft = 0;
axWaferX.build(h, dLeft, 10 + 0*dSep);
axWaferY.build(h, dLeft, 10 + 1*dSep);
axWaferZ.build(h, dLeft, 10 + 2*dSep);
axWaferX2.build(h, dLeft, 10 + 3*dSep);
axWaferY2.build(h, dLeft, 10 + 4*dSep);
axWaferZ2.build(h, dLeft, 10 + 5*dSep);
axWaferX3.build(h, dLeft, 10 + 6*dSep);
axWaferY3.build(h, dLeft, 10 + 7*dSep);
axWaferZ3.build(h, dLeft, 10 + 8*dSep);

dLeft = 320;
diM1.build(h, dLeft, 10 + 0*dSep);
diM2.build(h, dLeft, 10 + 1*dSep);
sh1.build(h, dLeft, 10 + 2*dSep);
sh2.build(h, dLeft, 10 + 3*dSep);


