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
Nc = 1000;             % number of grid cells over the interval [xl xr]
Nct = Nc+4;           % total number of grid cells (including 4 ghost cells) 
rat = 0.4;%0.1;       % fixed ratio dt/h % chosen so that CFL = max(lambda) dt/h \leq 1.
xl= -4.;              % left limit of space interval  [xl xr]      
xr = 4.;              % right limit of space interval [xl xr]
tf=0;%             % final time %
%
% Type of BC (= 1 zero-order extrapolation, = 2 solid fixed wall)
bcl=1; % Left BC
bcr=1; % Right BC
%
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

% Dimension:
% - Cell number
% - u1 = h, u2 = hu
qv  = zeros(Nct,2);

% Initial conditions Riemann problem

for k = 1:Nct		   
  if (xt(k) < xd)       % Left state
     qv(k,1) = rhol;
     qv(k,2) = rhoul;
  else                  % Right state
     qv(k,1) = rhor;
     qv(k,2) = rhour;
  end 
end

Ncp2 = Nc+2;
Ncp3 = Nc+3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
for  istep=1:MaxStep
    w = qv;  % store old qv 
   
    % update solution qv
    switch method  	
    case 'Rusanov'	
        
        % update solution at new time level
        for i=3:Ncp2
            fluip = fluxswRSn_templ(w(i,:), w(i+1,:));
            flui = fluxswRSn_templ(w(i-1,:), w(i,:));
            qv(i,:) = w(i,:) - dt/h*(fluip-flui);  
        end 	
     
     case 'Roe'	
        fRoe = fluxRoe(Nct, Ncp3, w);
        
        % update solution at new time level
        for i=3:Ncp2   
            fluip = fRoe(i,:);      % first-order Roe flux at i+1/2 (row vector) - mod 2025
            flui  = fRoe(i-1,:);    % first-order Roe flux at i-1/2 - mod 2025    
            qv(i,:) = w(i,:) - dt/h*(fluip-flui);  
        end
     end      

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
    %------------------------------------------------------------------------
end  % end time loop
%------------------------------------------------------------------------
%
%-- Plot numerical solution at final time in terms of variables h, rho*u, u
%
%
rhosol = qv(3:Ncp2,1);   % water height
rhousol = qv(3:Ncp2,2);  % momentum
usol = zeros(size(rhosol)); % velocity initialization

%--------------------------------------------------------------
% Integrals calculation
h_int = h*sum(rhosol);
hu_int = h*sum(rhousol);

fprintf("Numerical integral for h: %.5f\n", h_int);
fprintf("Numerical integral for hu: %.5f\n", hu_int);

for ii=1:Nc
 if (rhosol(ii)>0)
  usol(ii) = rhousol(ii)./rhosol(ii);  % velocity (definition allows handling dry states)
 end
end
%  Plot results 

      figure(1) % water height
      plot(x,rhosol,'bo')
%      axis([xl xr  0  1.1])
      grid     
      title(sprintf('Height at t = %d, Nc = %d',istep*dt,Nc))
      set(gca,'FontSize',20)

      figure(2) % velocity
      plot(x,usol,'bo')
%      axis([xl xr  0  1.1])
      grid     
      title(sprintf('Velocity at t = %d, Nc = %d',istep*dt,Nc))
      set(gca,'FontSize',20)
            
      figure(3) % momentum
      plot(x,rhousol,'bo')
%      axis([xl xr  0  1.1])
      grid     
      title(sprintf('Momentum at t = %d, Nc = %d',istep*dt,Nc))
      set(gca,'FontSize',20)      
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% depends on functions:  .... (numerical fluxes)
% feswrpex.m, fhint.m (exact solution)
%------------------------------------------------------
iexact=1;   % = 1 to add comparison with exact solution computed in fswrpex.m

if (iexact ==1)
% exact solution
[uex,rhoex,xx] = fswrpex(rhol,rhor,t);

rhouex = rhoex.*uex;

      figure(4) % water height
      plot(xx,rhoex,'r-',x,rhosol,'bo')
%      axis([xl xr  0  1.1])
      grid     
      title(sprintf('Height at t = %d, Nc = %d',istep*dt,Nc))
      legend('exact','computed','Location','NorthEast')
      set(gca,'FontSize',20)

      figure(5) % velocity
      plot(xx,uex,'r-',x,usol,'bo')
%      axis([xl xr  0  1.1])
      grid     
      title(sprintf('Velocity at t = %d, Nc = %d',istep*dt,Nc))
      legend('exact','computed','Location','NorthWest')
      set(gca,'FontSize',20)
      
      figure(6) % momentum
      plot(xx,rhouex,'r-',x,rhousol,'bo')
%      axis([xl xr  0  1.1])
      grid     
      title(sprintf('Momentum at t = %d, Nc = %d',istep*dt,Nc))
      legend('exact','computed','Location','NorthWest')
      set(gca,'FontSize',20)      
             
end      

