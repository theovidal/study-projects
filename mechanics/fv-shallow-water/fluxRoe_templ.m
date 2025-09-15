% Routine to calculate the Roe scheme at only one cell interface
% Used in the Hydrostatic Reconstruction scheme

function [ff] = fluxRoe_templ(v, vp)
    delta = vp-v;
    grav = 1.;
    %--------------------------------------------------------------------------------------
    
    % flux initialization
    flul = zeros(1,2);    % f(u_i)      %  flux evaluated at u_i   (row vector)
    flur = zeros(1,2);    % f(u_{i+1})  %  flux evaluated at u_{i+1}

    lambdav = zeros(2); % Roe eigenvalues
    Rmatv = zeros(2,2); % Roe eigenvectors
    alphav = zeros(2);  % Roe alpha coefficients, alpha = R^{-1}\Deltaq

    % set f(u_i) 
    rl = v(1);   % water height
    rul = v(2);  % momentum
    
    ul = rul/rl;   % velocity 
    
    flul(1) = rul;
    flul(2) = rul*ul + grav*rl^2/2;

    % set f(u_{i+1}) 
    rr = vp(1);   % water height
    rur = vp(2);  % momentum
    
    ur = rur/rr;   % velocity
    
    flur(1) = rur;
    flur(2) = rur*ur + grav*rr^2/2;

    %---------------------------------------------------------------------------
    % Roe averages
    
    hroe = 0.5 * (rr + rl); % water height 
    uroe = (sqrt(rl)*ul + sqrt(rr)*ur) / (sqrt(rl) + sqrt(rr));  % velocity
    croe = sqrt(grav * hroe); % velocity tied to kinetic energy conservation
    
    % Roe eigenvalues
    lambdav(1) = uroe - croe;
    lambdav(2) = uroe + croe;
    
    % Roe eigenvectors
    % Rmatv(component number, grid cell, corresponding U component)
    Rmatv(1,1) = 1.;
    Rmatv(2,1) = uroe - croe;
    
    Rmatv(1,2) = 1.;
    Rmatv(2,2) = uroe + croe;     

    % coefficients projection Delta U (analytical formulas)
    alphav(1) = ((uroe + croe) * delta(1) - delta(2)) / (2 * croe);
    alphav(2) = (-(uroe - croe) * delta(1) + delta(2)) / (2 * croe);
    
    %--------------------------------------------------------------------------
    % Roe flux
    
    %ff = 0.5*(flul+flur)'; % for centered expression

    ff=flul'; % column vector (consistent with Rmatv)
    for k=1:2
        % ff = ff -0.5*abs(lambdav(k,i))*alphav(k,i)*Rmatv(:,i,k); %centered expression
        ff = ff + min(lambdav(k), 0.) * alphav(k) * Rmatv(:,k);
    end

    ff = ff';
end