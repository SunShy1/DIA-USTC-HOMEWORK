%   Matlad code implementing Chan-Vese model in the paper 'Active Contours Without Edges'
%   This method works well for bimodal images, for example the image 'three.bmp'


clear;
close all;
clc;

Img=imread('vessel.bmp');    % Warning: example image that CV model does NOT work well

U=Img(:,:,1);
% get the size

[nrow,ncol] =size(U); 
ic=nrow/2-27;
jc=ncol/2;
r=3;
phi_0 = sdf2circle(nrow,ncol,ic,jc,r);
figure; mesh(phi_0); title('Signed Distance Function')
numIter = 5; 
a= 55;b=50;  % For TWOCELL

a=6;b=5;
initial=6*ones(nrow,ncol);
initial(a:end-b,a:end-b)=0;
initial(a+1:end-b+1,a+1:end-b+1)=-6;
phi_0 = initial;

delta_t = 5;
lambda = 5.0;
nu = 5;
mu = 0.04;
epsilon = 0.13;
% Edge Indicator Function.
I = double(U);

c=47;a=6;b=5;
I(1:a,:)=c+rand(a,ncol);
I(end-a:end,:)=c+rand(a+1,ncol);
I(:,end-b:end)=c+rand(nrow,b+1);
I(:,1:b)=c+rand(nrow,b);
I(1:a,end-5:end)=I(1:a,end-5:end)+4;

sigma = 0.5;                          
G = fspecial('gaussian',15,sigma);    
II = conv2(I,G,'same');           
[Ix,Iy]=gradient(II);
f = Ix.^2+Iy.^2;
g=1./( 1 + f );                          


% iteration should begin from here
phi=phi_0; 
figure(2);
subplot(1,2,1); mesh(phi);
subplot(1,2,2); imagesc(uint8(I));colormap(gray)
hold on;
plotLevelSet(phi,0,'r');

for k=1:300
    phi = evolution_cv(G, phi, mu, nu, lambda, delta_t,epsilon, numIter, g);   % update level set function
    if mod(k,2)==0
%         pause(.00005);
        figure(2); clc; axis equal; 
        title(sprintf('Itertion times: %d', k));
        subplot(1,2,1); mesh(phi);
        subplot(1,2,2); imagesc(uint8(I));colormap(gray);
        hold on; plotLevelSet(phi,0,'r');
    end    
end;
