% rasterplusX

args = [5, 2, 8]
Npts = 1000;

% xamp
% yamp
% nrows

xamp  = args(1)
yamp  = args(2)
Nrows1 = args(3);


yrow = linspace(-1, 1, Nrows1);

dY = (Yrow(1)-Yrow(0))/4;

Npts1 = Npts / (Nrows1*2)
xrow = linspace(-1, 1, Npts1)


for i=0,Nrows1-1 
    if mod(i, 2) == 0
        
        
    x = [x, even(i) ? xrow : (-xrow)]
    y = [y, Yrow[i] + dblarr(Npts1)]
endfor
x = [x, rotate(x,2)+dY]  ;--- there and back
y = [y-dY, rotate(y,2)+dY]

xy1 = [xamp*transpose(x), yamp*transpose(y)]