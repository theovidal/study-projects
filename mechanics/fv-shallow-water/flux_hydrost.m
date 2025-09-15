function [ff] = flux_hydrost(Ul, Ur, bl, br, side, method)
    % side = 'left' (flux calculation between i and i+1) or 'right' (flux calculation between i-1 and i)
    grav = 1.;
    ff = zeros(1, 2);

    b_star = max(bl, br);
    
    % Left state

    hl = Ul(1);   % water height
    hul = Ul(2);  % momentum

    if(hl>0)
     ul = hul/hl;   % velocity
    else
     ul=0;  % set zero velocity if dry state
    end
    
    hl_star = max(hl + bl - b_star, 0);
    Ul_star = [hl_star, ul * hl_star];
    
    % Right state    
    hr = Ur(1);   % water height
    hur = Ur(2);  % momentum

    if(hr>0)
     ur = hur/hr;   % velocity
    else
     ur=0;  % set zero velocity if dry state
    end
    
    hr_star = max(hr + br - b_star, 0);
    Ur_star = [hr_star, ur * hr_star];
    
    % Flux
    switch method
    case 'Rusanov'
        F_star = fluxswRSn_templ(Ul_star, Ur_star);

    case 'Roe'
        F_star = fluxRoe_templ(Ul_star, Ur_star);
    end
    
    if strcmp(side, 'left') % left flux
        ff = F_star + [0, 0.5*grav*(hl^2 - hl_star^2)];
    else % right flux
        ff = F_star + [0, 0.5*grav*(hr^2 - hr_star^2)];
    end