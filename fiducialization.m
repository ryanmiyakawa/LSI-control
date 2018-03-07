% Fiducialization

% The goal 


a1 = [1, 3]';
a2 = [2, 0]';

b1 = [0, 5]';
b2 = [-5 0]';


% This matrix projects any vector onto the a basis
Ta = inv([a1, a2]);

% This matrix projects any vector onto the b basis
Tb = inv([a1, a2]);


% let this be some point in space:
pt = [11; 13];


