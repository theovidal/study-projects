 function fhs = fhint(hm,hl, hr)
% function used to compute exact solution to dam-break in fswrpex.m 
grav=1.; % gravity constant;

% h = height
% u = velocity
% input = hl,hr (left and right data)
% output = hm 
% Here assume initial velocity=0
ul=0.;
ur=0.;
 
fhs = ur+(hm-hr)*sqrt(0.5*grav*(1./hm+1./hr)) ...
   -ul-2.*(sqrt(grav*hl)-sqrt(grav*hm));
