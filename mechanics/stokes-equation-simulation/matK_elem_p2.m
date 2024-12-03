function [Kel] = matK_elem_p2(S1, S2, S3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcul de la matrice de rigidité elementaire en P2 Lagrange
%
% SYNOPSIS [Kel] = matK_elem_p2(S1, S2, S3)
%
% INPUT * S1, S2, S3 : les 2 coordonnees des 3 sommets du triangle
%                      (vecteurs reels 1x2)
%
% OUTPUT - Kel matrice de rigidité elementaire (matrice 6x6)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preliminaires, pour faciliter la lecture:
x1 = S1(1); y1 = S1(2);
x2 = S2(1); y2 = S2(2);
x3 = S3(1); y3 = S3(2);

det = (x2 - x1)*(y3 - y1) - (x3 - x1) * (y2 - y1);

% Matrice B définie dans le sujet, ici directement transposée et inversée
B = [
    y3 - y1 , y1 - y2 ;
    x1 - x3 , x2 - x1
] / det;

% calcul de la matrice de rigidité
% -------------------------------
% Initialisation
Kel = zeros(6, 6);

% Points et poids de quadrature, définissant une formule de quadrature
% d'ordre 2
S_hat = [1/6, 1/6;
         2/3, 1/6;
         1/6, 2/3];
poids = 1/6;

s=size(S_hat);
N_pts = s(1);

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

for i=1:6
    for j=1:6
        for q = 1:N_pts
            gradw_x_i = gradw_x{i};
            gradw_y_i = gradw_y{i};
            gradw_x_j = gradw_x{j};
            gradw_y_j = gradw_y{j};
            x = S_hat(q, 1);
            y = S_hat(q, 2);
            Kel(i, j) = Kel(i, j) + abs(det) * poids * dot(B*[gradw_x_i(x, y); gradw_y_i(x, y)], B*[gradw_x_j(x, y); gradw_y_j(x, y)]);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                        fin de la routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%24
