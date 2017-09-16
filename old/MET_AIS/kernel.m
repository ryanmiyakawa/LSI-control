
clc
close all
clear

Lx = 5;
Ly = 5;

sigx = 0.5;
sigy = 0.5;

Nx = 100;
Ny = 100;

% Sample spacing

dx = Lx/Nx;
dy = Ly/Ny;


% Sampled simulation points 1D 

x = -Lx/2:dx:Lx/2 - dx;
y = -Ly/2:dy:Ly/2 - dy;
u = -1/2/dx: 1/Nx/dx: 1/2/dx - 1/Nx/dx;
v = -1/2/dy: 1/Ny/dy: 1/2/dy - 1/Ny/dy;

[Y,X] = meshgrid(y,x);
[V,U] = meshgrid(v,u);


% Add together a bunch of random amplitude and located gaussians

s_sum = zeros(size(X));

figure
for n = 1:14
    
    x0 = randn(1)*Lx*0.2;
    y0 = randn(1)*Ly*0.2;
    amp = abs(randn(1));
    s = amp*exp(-(((X-x0)/sigx).^2/2+((Y-y0)/sigy).^2/2)); 
    
    s_sum = s_sum + s;
    mesh(X, Y, s_sum)

    drawnow;
end







%{

S = fftshift(fft2(s));

filt_sigma      = 0.3*(u(end) - u(1));
filt_gauss      = exp(-((U/filt_sigma).^2/2+(V/filt_sigma).^2/2)); 
filt_phase      = exp(j*2*pi*0.4*(randn(size(S)).*filt_gauss));

filt_amp        = ones(size(S)) - 0.4*abs(randn(size(S)).*filt_gauss);

filt = filt_amp; %filt_phase;


figure
subplot(131)
mesh(angle(filt))
subplot(132)
mesh(abs(filt))
subplot(133)
mesh(filt_gauss)


S_filt = filt.*S;

s_filt = abs(ifft2(ifftshift(S_filt)));

figure
subplot(121)
mesh(X, Y, s)
subplot(122)
mesh(X, Y, s_filt)
%}
