function [Mel] = matM_elem_p2(S1, S2, S3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcul de la matrice de masse elementaire en P2 Lagrange
%
% SYNOPSIS [Mel] = matM_elem_p2(S1, S2, S3)
%
% INPUT * S1, S2, S3 : les 2 coordonnees des 3 sommets du triangle
%                      (vecteurs reels 1x2)
%
% OUTPUT - Mel matrice de masse elementaire (matrice 6x6)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preliminaires, pour faciliter la lecture:
x1 = S1(1); y1 = S1(2);
x2 = S2(1); y2 = S2(2);
x3 = S3(1); y3 = S3(2);

det = (x2 - x1)*(y3 - y1) - (x3 - x1) * (y2 - y1);

% calcul de la matrice de masse
% -------------------------------
% Initialisation
Mel = zeros(6, 6);

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

% Coordonnées barycentriques
lambda1 = @(x, y) (1 - x - y);
lambda2 = @(x, y) x;
lambda3 = @(x, y) y;

% Fonctions de base des éléments P2
w = {
    @(x, y) lambda1(x, y) * (2 * lambda1(x, y) - 1) ;
    @(x, y) lambda2(x, y) * (2 * lambda2(x, y) - 1) ;
    @(x, y) lambda3(x, y) * (2 * lambda3(x, y) - 1) ;
    @(x, y) 4 * lambda1(x, y) * lambda2(x, y) ;
    @(x, y) 4 * lambda3(x, y) * lambda2(x, y) ;
    @(x, y) 4 * lambda1(x, y) * lambda3(x, y) ;
};

for i=1:6
    for j=1:6
        for q = 1:N_pts
            w_i = w{i};
            w_j = w{j};
            x = S_hat(q, 1);
            y = S_hat(q, 2);
            Mel(i, j) = Mel(i, j) + abs(det) * poids(q) * w_i(x, y) * w_j(x, y);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                        fin de la routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%24
