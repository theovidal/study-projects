function val = g1(x, y, verification)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluation de la fonction sur le bord.
%
% SYNOPSIS val = g1(x,y)
%
% INPUT * x,y : les 2 coordonnees du point ou on veut evaluer la fonction.
%
% OUTPUT - val: valeur de la fonction sur ce point.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    val = zeros(size(x));

    % Bord gauche

    if verification == 1
        % Domaine rectangle
        val(x == 0) = (2-y(x == 0)) .* y(x == 0);
    else
        % Canal
        val(x == 0) = 4 * (2-y(x == 0)) .* (y(x == 0) - 1);
    end
end