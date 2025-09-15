% MF206 Introduction to CFD 2025
% Instructor: Marica Pelanti
% Final Application Lesson - FINAL EXAM 
% ---------------------------------------------------------
% solution of the 1D shallow water equations via FV conservative schemes
% SWE with bottom topography b
% Hydrostatic Reconstruction Method 
% Uses Rusanov for homogeneous system
% TEMPLATE TO FILL
%-------------------------------------------------------------------------------
%
% qv = matrix of conserved variables   Nct \times 2
% columns = conserved variables (2)
% rows = cell values (Nct)
% qv(:,1) = flow height
% qv(:,2) = momentum 

clear all; close all; clc

grav = 1.; % gravity constant
%---------------------------------------------------------------------------
% grid and time step
%
Nc = 200;        % number of grid cells over the interval [xl xr]
Nct = Nc+4;      % total number of grid cells (including 4 ghost cells) 
rat = 0.8;       % fixed ratio dt/h % chosen so that CFL = max(lambda) dt/h \leq 1.
xl= 0.;          % left limit of space interval  [xl xr]      
xr = 1.;         % right limit of space interval [xl xr]
tf= 0.4;        % final time %
%
% Type of BC (= 1 zero-order extrapolation, = 2 solid fixed wall)
bcl = 1; % Left BC
bcr = 1; % Right BC

%------------------------------------------------------------------
% Set initial conditions 
% iproblb=1 : small perturbation problem; iproblb=2 : oscillating lake
iproblb=1;

%------------------------------------------------------------------
% Control output
nsteps = 200;     % number of steps with time and graphic output

generateVideo = false;

if generateVideo
    vt = VideoWriter('oscillating.avi');
    vt.Quality = 100;
    open(vt);
end

%-------------------------------------------------------------
% Set method ('Rusanov' or 'Roe')
method = 'Roe';
%-------------------------------------------------------------
% Finite Volume discretization 
% assume uniform grid with grid spacing = h
%
% 	
%              xl    					xr
%  X   |   X   |---X---|---X---|---X---  ...  --|---X---|   X   |   X
%  1       2       3       4       5              Nc+2    Nc+3    Nc+4=Nct
%  
%  1,2 : ghost cells on the left of xl
%  Nc+3,Nc+4 : ghost cells on the right of xr
%-------------------------------------------------------------
% mesh width
h = (xr-xl)/Nc;

% time step (here fixed)
dt = rat*h;

x  = [xl+h/2:h:xr-h/2]';        % coordinates of cell centers  
xt = [xl-3*h/2:h:xr+3*h/2]';    % coordinates of cell centers including ghost cells

MaxStep = ceil(tf/dt);          % number of time steps
%-----------------------------------------------------------------------

% Initialization

t=0.0 ;                         % initial time 
qv  = zeros(Nct,2);
bot = zeros(Nct,1);   % bottom topography

%---------------------------------------------------------------------------

if (iproblb==1)
% Initial conditions [LeVeque test J. Comput. Phys., 146:346, 1998]
  hfix = 1;
  pert = 0.2;

  for k = 1:Nct		  % water height  perturbation
     qv(k,1) =hfix;     
   if ((xt(k)> 0.1)&&(xt(k) < 0.2)) % better && than & - 15/03/2020
     qv(k,1) =hfix+pert;	
   end 
  end 

  for k = 1:Nct	          % set topography
    htot = qv(k,1);
   if ((xt(k)> 0.4)&&(xt(k) < 0.6)) % better && than & - 15/03/2020
      bot(k) = 0.25*(cos(pi*(xt(k)-0.5)/0.1)+1.0);	
      qv(k,1)= htot - bot(k);
   end 
  end
  
else % iproblb=2 (oscillating lake) 
% Initial conditions [Audusse et al. test SIAM J. Sci. Comput., 25:2050, 2004]

 for k = 1:Nct	          % set topography 
      bot(k) = 0.5*(1.-0.5*(cos(pi*(xt(k)-0.5)/0.5)+1.0));	
 end

 for k = 1:Nct		  % water height
  htemp(k) = .4-bot(k)+0.04*sin((xt(k)-0.5)/.25);
  htottemp(k) = bot(k) + htemp(k);
  htotv(k) = max (bot(k), htottemp(k));
  qv(k,1) = htotv(k)-bot(k);
 end 

end
%-------------------------------------------------------------------
Ncp2 = Nc+2; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
for  istep=1:MaxStep % starts time integration loop
    w = qv;  % store old qv 
    
    % update solution qv
    for i=3:Ncp2
        fluip = flux_hydrost(w(i,:), w(i+1,:), bot(i), bot(i+1), 'left', method); % Left flux
        flui = flux_hydrost(w(i-1,:), w(i,:), bot(i-1), bot(i), 'right', method); % Right flux
        qv(i,:) = w(i,:) - dt/h*(fluip-flui);  
    end 
     
    %------------------------------------------------------------- ---       
    %
    % set Bondary conditions
    % left ghost cells
    for k = 1:2      
        qv(2,k) =  qv(3,k); % zero-order extrapolation
        qv(1,k) =  qv(3,k);	
    end  
    if (bcl==2)  % solid wall     
        qv(2,1) =  qv(3,1); % symmetry
        qv(1,1) =  qv(4,1);
        
        qv(2,2) = -qv(3,2); % negate momentum
        qv(1,2) = -qv(4,2);
    end
    % right ghost cells      
    for k = 1:2      
        qv(Nct-1,k) =  qv(Ncp2,k); % zero-order extrapolation
        qv(Nct,k) =  qv(Ncp2,k);	
    end         
    if (bcr==2)  % solid wall
        qv(Nct-1,1) = qv(Ncp2,1); % symmetry
        qv(Nct,1) =  qv(Nc+1,1);
        
        qv(Nct-1,2) = -qv(Ncp2,2); % negate momentum
        qv(Nct,2) = -qv(Nc+1,2);
    end       
    %                
    %-------------------------------------    
    t=t+dt;  % time increment 

    if (generateVideo && floor(nsteps*istep/MaxStep)>floor(nsteps*(istep-1)/MaxStep))
        rhosol = qv(3:Ncp2,1);   % height
        bottom = bot(3:Ncp2,1);  % bottom
        htotsol = bottom +rhosol;  % water level h+b
       
        hFig = figure('Visible','off');
        plot(x,htotsol,'bo')
        axis([xl xr  0  1.22])
        if (iproblb==2)
        axis([xl xr  0  0.5])
        end
        hold on
        plot(x,bottom,'--k')
        grid     
        title(sprintf('Height at t = %d, Nc = %d',istep*dt,Nc))
        set(gca,'FontSize',20)
        hold off
        frame = getframe(gcf);
        writeVideo(vt,frame);
        close(hFig);
    end
%------------------------------------------------------------------------
end  % end time loop
duration = toc
%------------------------------------------------------------------------
%
%-- Plot numerical solution at final time in terms of  variables h+b,u
%
%  variables at interior cells 
rhosol = qv(3:Ncp2,1);   % height
rhousol = qv(3:Ncp2,2);  % momentum
bottom = bot(3:Ncp2,1);  % bottom

usol = zeros(size(rhosol));

htotsol = bottom +rhosol;  % water level h+b

for ii=1:Nc
 if (rhosol(ii)>0)
  usol(ii) = rhousol(ii)./rhosol(ii);  % velocity
 end
end

%  Plot results 

figure(1) % (total) water height
plot(x,htotsol,'bo')
axis([xl xr  0  1.22])
if (iproblb==2)
    axis([xl xr  0  0.5])
end
hold on
plot(x,bottom,'--k')
grid     
title(sprintf('Height at t = %d, Nc = %d',istep*dt,Nc))
set(gca,'FontSize',20)
hold off

figure(2) % velocity
plot(x,usol,'bo')
%      axis([xl xr  0  1.1])
grid     
title(sprintf('Velocity at t = %d, Nc = %d',istep*dt,Nc))
set(gca,'FontSize',20)

figure(3) % water height - zoom
plot(x,htotsol,'bo')
axis([0 1 0.98 1.12])    
if (iproblb==2)
    axis([xl xr  0  1.])
end
grid     
title(sprintf('Height at t = %d, Nc = %d',istep*dt,Nc))
set(gca,'FontSize',20)
      
if generateVideo
    close(vt);
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% depends on functions: ....m (numerical fluxes)
%
