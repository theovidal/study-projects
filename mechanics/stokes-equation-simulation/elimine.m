function [tilde_AA, tilde_LL] = elimine(AA, LL, Refneu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Application de la méthode de pseudo-élimination pour des conditions de
% Dirichlet homogènes
%
% SYNOPSIS [tilde_AA, tilde_LL] = elimine(AA, LL, Refneu)
%
% INPUT * AA, LL, Refneu
%
% OUTPUT - tilde_AA, tilde_LL : les matrices avec des lignes et colonnes
% éliminées
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tilde_AA = AA; % =N
    tilde_LL = LL;

    indices = find(Refneu); % Position des noeuds = 1

    tilde_AA(:, indices) = 0; % Colonnes à 0
    tilde_AA(indices, :) = 0; % Lignes à 0
    tilde_AA(sub2ind(size(tilde_AA), indices, indices)) = 1; % 1 pour les Aii
end