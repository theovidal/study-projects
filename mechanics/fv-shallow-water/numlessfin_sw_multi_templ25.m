% MF206 Introduction to CFD 2025
% Instructor: Marica Pelanti
% Final Application Lesson - FINAL EXAM 
% ---------------------------------------------------------
% solution of the 1D shallow water equations via FV conservative schemes
% TEMPLATE TO FILL
%-------------------------------------------------------------------------------
%
% qv = matrix of conserved variables   Nct \times 2
% columns = conserved variables (2)
% rows = cell values (Nct)
% qv(:,1) = flow height
% qv(:,2) = momentum 
%

clear all; close all; clc
grav = 1.; % gravity constant
%--------------------------------------------------------------------------------
% Set initial conditions
%--------------------------------------------------------------------------------
% Example of Initial condition: Riemann problem 
%
% Set Riemann problem left and right states
%
%--------------------------------------------------------
% Left state
rhol = 3.; % water height
ul = 0.;   % velocity
% Right state
rhor = 1;  % water height
ur = 0.;   % velocity
%-----------------------------------------------------
xd = 0.0;     % location of initial discontinuity;
% 
%-----------------------------------------------------
% left and right states in terms of conserved variables
  rhoul = rhol*ul;   % momentum of left state
  rhour = rhor*ur;   % momentum of right state
%
%--------------------------------------------------------------------------------
% grid and time step
%
Nc = 200;             % number of grid cells over the interval [xl xr]
Nct = Nc+4;           % total number of grid cells (including 4 ghost cells) 
rat = 0.4;%0.1;       % fixed ratio dt/h % chosen so that CFL = max(lambda) dt/h \leq 1.
xl= -4.;              % left limit of space interval  [xl xr]      
xr = 4.;              % right limit of space interval [xl xr]
tf=1.2;%             % final time %
%
% Type of BC (= 1 zero-order extrapolation, = 2 solid fixed wall)
bcl=1; % Left BC
bcr=1; % Right BC
%
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

% Dimension:
% - Cell number
% - u1 = h, u2 = hu
qv_rusanov  = zeros(Nct,2);
qv_roe  = zeros(Nct,2);

% Initial conditions Riemann problem

for k = 1:Nct		   
  if (xt(k) < xd)       % Left state
     qv_rusanov(k,1) = rhol;
     qv_rusanov(k,2) = rhoul;

     qv_roe(k,1) = rhol;
     qv_roe(k,2) = rhoul;
  else                  % Right state
     qv_rusanov(k,1) = rhor;
     qv_rusanov(k,2) = rhour;

     qv_roe(k,1) = rhor;
     qv_roe(k,2) = rhour;
  end 
end

Ncp2 = Nc+2;
Ncp3 = Nc+3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
for  istep=1:MaxStep
    w_rusanov = qv_rusanov;  % store old qv 
    w_roe = qv_roe;  % store old qv 
   
    % update solution at new time level
    for i=3:Ncp2
        fluip = fluxswRSn_templ(w_rusanov(i,:), w_rusanov(i+1,:));
        flui = fluxswRSn_templ(w_rusanov(i-1,:), w_rusanov(i,:));
        qv_rusanov(i,:) = w_rusanov(i,:) - dt/h*(fluip-flui);  
    end 	

    fRoe = fluxRoe(Nct, Ncp3, w_roe);
    
    % update solution at new time level
    for i=3:Ncp2   
        fluip = fRoe(i,:);      % first-order Roe flux at i+1/2 (row vector) - mod 2025
        flui  = fRoe(i-1,:);    % first-order Roe flux at i-1/2 - mod 2025    
        qv_roe(i,:) = w_roe(i,:) - dt/h*(fluip-flui);  
    end  

    % set Bondary conditions
    % left ghost cells
    for k = 1:2      
        qv_rusanov(2,k) =  qv_rusanov(3,k); % zero-order extrapolation
        qv_rusanov(1,k) =  qv_rusanov(3,k);	

        qv_roe(2,k) =  qv_roe(3,k); % zero-order extrapolation
        qv_roe(1,k) =  qv_roe(3,k);	
    end 

    if (bcl==2)  % solid wall     
        qv_rusanov(2,1) =  qv_rusanov(3,1); % symmetry
        qv_rusanov(1,1) =  qv_rusanov(4,1);
        
        qv_rusanov(2,2) = -qv_rusanov(3,2); % negate momentum
        qv_rusanov(1,2) = -qv_rusanov(4,2);

        qv_roe(2,1) =  qv_roe(3,1); % symmetry
        qv_roe(1,1) =  qv_roe(4,1);
        
        qv_roe(2,2) = -qv_roe(3,2); % negate momentum
        qv_roe(1,2) = -qv_roe(4,2);
    end
    % right ghost cells      
    for k = 1:2      
        qv_rusanov(Nct-1,k) =  qv_rusanov(Ncp2,k); % zero-order extrapolation
        qv_rusanov(Nct,k) =  qv_rusanov(Ncp2,k);	

        qv_roe(Nct-1,k) =  qv_roe(Ncp2,k); % zero-order extrapolation
        qv_roe(Nct,k) =  qv_roe(Ncp2,k);
    end 
    
    if (bcr==2)  % solid wall
        qv_rusanov(Nct-1,1) = qv_rusanov(Ncp2,1); % symmetry
        qv_rusanov(Nct,1) =  qv_rusanov(Nc+1,1);
        
        qv_rusanov(Nct-1,2) = -qv_rusanov(Ncp2,2); % negate momentum
        qv_rusanov(Nct,2) = -qv_rusanov(Nc+1,2);

        qv_roe(Nct-1,1) = qv_roe(Ncp2,1); % symmetry
        qv_roe(Nct,1) =  qv_roe(Nc+1,1);
        
        qv_roe(Nct-1,2) = -qv_roe(Ncp2,2); % negate momentum
        qv_roe(Nct,2) = -qv_roe(Nc+1,2);
    end      
    %                
    %-------------------------------------    
    t=t+dt;  % time increment 
    %------------------------------------------------------------------------
end  % end time loop
%------------------------------------------------------------------------
%
%-- Plot numerical solution at final time in terms of variables h, rho*u, u
%
%
rhosol_rusanov = qv_rusanov(3:Ncp2,1);   % water height
rhousol_rusanov = qv_rusanov(3:Ncp2,2);  % momentum
usol_rusanov = zeros(size(rhosol_rusanov)); % velocity initialization

rhosol_roe = qv_roe(3:Ncp2,1);   % water height
rhousol_roe = qv_roe(3:Ncp2,2);  % momentum
usol_roe = zeros(size(rhosol_roe)); % velocity initialization

for ii=1:Nc
 if (rhosol_rusanov(ii)>0)
  usol_rusanov(ii) = rhousol_rusanov(ii)./rhosol_rusanov(ii);  % velocity (definition allows handling dry states)
 end

 if (rhosol_roe(ii)>0)
  usol_roe(ii) = rhousol_roe(ii)./rhosol_roe(ii);  % velocity (definition allows handling dry states)
 end
end

% exact solution
[uex,rhoex,xx] = fswrpex(rhol,rhor,t);

rhouex = rhoex.*uex;

figure(4) % water height
plot(xx,rhoex,'r-',x,rhosol_rusanov,'bo', x, rhosol_roe, 'g+')
%      axis([xl xr  0  1.1])
grid     
title(sprintf('Height at t = %d, Nc = %d',istep*dt,Nc))
legend('exact','Rusanov', 'Roe','Location','NorthEast')
set(gca,'FontSize',20)

figure(5) % velocity
plot(xx,uex,'r-',x,usol_rusanov,'bo', x, usol_roe, 'g+')
%      axis([xl xr  0  1.1])
grid     
title(sprintf('Velocity at t = %d, Nc = %d',istep*dt,Nc))
legend('exact','Rusanov', 'Roe','Location','NorthWest')
set(gca,'FontSize',20)

figure(6) % momentum
plot(xx,rhouex,'r-',x,rhousol_rusanov,'bo', x, rhousol_roe, 'g+')
%      axis([xl xr  0  1.1])
grid     
title(sprintf('Momentum at t = %d, Nc = %d',istep*dt,Nc))
legend('exact','Rusanov', 'Roe','Location','NorthWest')
set(gca,'FontSize',20)      
  

