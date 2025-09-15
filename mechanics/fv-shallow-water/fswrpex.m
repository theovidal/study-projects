function [uex,rhoex,xx] = fswrpex(hl,hr,t)

   
% exact solution for dam break problem for shallow water equations
% Assume initial velocity = 0: ul = ur = 0
% left-going rarefaction, right-going shock
% assume space interval [xx1 xx2] 
% Left and right boundary: free flow
%

   xx1=-4;
   xx2=4;
   sloc=0.0;  % initial discontinuity location
   mx1=1000;  % number of x points
%--------------------------------------------------------------------
 grav=1.;  % gravity constant
%------------------------------------------------------------------  
   cl = sqrt(grav*hl);
   cr=sqrt(grav*hr);
    
   ul=0;
   ur=0;
   
   hm0 = 0.5*(hl+hr); % initial guess
   options=optimset('Display','iter','TolFun',1e-10); 
   hmed = fsolve(@(hm)fhint(hm,hl, hr),hm0,options);
   umed= ul+2.*(sqrt(grav*hl)-sqrt(grav*hmed));
   cmed = sqrt(grav*hmed);
  
   us = (hr*ur-hmed*umed)/(hr-hmed); % shock speed    
   
   xx=linspace(xx1,xx2,mx1);
   xs = t*us+sloc;
   xrl=t*(ul-cl)+sloc;
   xrr=t*(umed-cmed)+sloc;
   
   uex=umed*ones(1,mx1);
   rhoex=hmed*ones(1,mx1);
   
   
   ii=find(xx >=xs);
 
   uex(ii)=ur;
   rhoex(ii)=hr;
    
   kk=find(xx<xrr);
   
   tm=max(t,1.e-10);
   Aconst = ul+2.*sqrt(grav*hl); 
   rhoex(kk) =1./(9.*grav).*(Aconst - (xx(kk)-sloc)/tm).^2;
   uex(kk) = Aconst - 2.*sqrt(grav*rhoex(kk));
   
   ll=find(xx<xrl);
   uex(ll)= ul;
   rhoex(ll)=hl;

%%%%%%%%%%%%%%%%%

