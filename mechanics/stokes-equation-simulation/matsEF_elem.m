function [Eel, Fel] = matsEF_elem(S1, S2, S3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcul de la matrice elementaire du bloc rectangulaire (p, dv1/dx)
%
% SYNOPSIS [Eel] = matE_elem(S1, S2, S3)
%
% INPUT * S1, S2, S3 : les 2 coordonnees des 3 sommets du triangle
%                      (vecteurs reels 1x2)
%
% OUTPUT - Eel matrice elementaire rectangulaire (matrice 6x3)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Préliminaires, pour faciliter la lecture:
x1 = S1(1); y1 = S1(2);
x2 = S2(1); y2 = S2(2);
x3 = S3(1); y3 = S3(2);

det = (x2 - x1)*(y3 - y1) - (x3 - x1) * (y2 - y1);

% Matrice B définie dans le sujet, ici directement transposée et inversée
B = [
    y3 - y1 , y1 - y2 ;
    x1 - x3 , x2 - x1
] / det;

% calcul de la matrice elementaire du bloc rectangulaire (p, dv1/dx)
% ------------------------------------------------------------------
Eel = zeros(6, 3);
Fel = zeros(6, 3);

% Points et poids de quadrature, définissant une formule de quadrature
% d'ordre 4
S_hat = [0.0915762135098, 0.0915762135098;
         0.8168475729805, 0.0915762135098;
         0.0915762135098, 0.8168475729805;
         0.1081030181681, 0.4459484909160;
         0.4459484909160, 0.1081030181681;
         0.4459484909160, 0.4459484909160];
poids = [0.05497587183, 0.05497587183, 0.05497587183, 0.1116907948, 0.1116907948, 0.1116907948];

s=size(S_hat);
N_pts = s(1);

lambda1 = @(x, y) (1 - x - y);
lambda2 = @(x, y) x;
lambda3 = @(x, y) y;

% Composantes x des gradients des w_i, fonctions de base des éléments P2
gradw_x = {
    @(x, y) 4*x + 4*y - 3;
    @(x, y) 4*x - 1;
    @(x, y) 0;
    @(x, y) 4*(1 - 2*x - y);
    @(x, y) 4*y;
    @(x, y) -4*y;
};

% Composantes y des gradients des w_i, fonctions de base des éléments P2
gradw_y = {
    @(x, y) 4*x + 4*y - 3;
    @(x, y) 0;
    @(x, y) 4*y - 1;
    @(x, y) -4*x;
    @(x, y) 4*x;
    @(x, y) 4*(1 - x - 2*y);
};

% Les fonctions lambda, qui sont égales aux fonctions de base des
% éléments P1
lambda = { lambda1 ; lambda2 ; lambda3 };

for i=1:6
    for j=1:3
        for q = 1:N_pts
            gradw_x_i = gradw_x{i};
            gradw_y_i = gradw_y{i};
            lambda_j = lambda{j};
            x = S_hat(q, 1);
            y = S_hat(q, 2);
            
            integral = abs(det) * poids(q) * lambda_j(x, y) .* [gradw_x_i(x, y); gradw_y_i(x, y)];
            Eel(i, j) = Eel(i, j) - B(1, :) * integral;
            Fel(i, j) = Fel(i, j) - B(2, :) * integral;
        end
    end % j
end % i

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                        fin de la routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%24
