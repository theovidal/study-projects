function [tilde_AA, tilde_LL]  = elimine_stokes(AA,LL, Coorneu, Refneu, Nbpt, Ns, verification)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Application de la méthode de pseudo-élimination pour le problème de
% Stokes
%
% SYNOPSIS [tilde_AA, tilde_LL]  = elimine_stokes(AA,LL, Coorneu, Refneu, Nbpt, Ns, verification)
%
% INPUT * AA,LL, Coorneu, Refneu, Nbpt, Ns, verification
%
% OUTPUT - tilde_AA, tilde_LL : les matrices avec des lignes et colonnes
% éliminées
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % On souhaite uniquement appliquer des conditions aux limites sur les
    % composantes de la vitesse, donc on laisse la pression libre (un 0
    % ne changera pas les lignes et colonnes correspondantes)
    extended_Refneu = [Refneu; Refneu; zeros(Ns, 1)];

    % - Bord gauche (= 1) : condition non homogène, ne pas enlever les colonnes
    [tilde_AA_tmp, tilde_LL_tmp] = elimine_nh(AA, LL, extended_Refneu == 1);

    % - Bords haut et bas (= 2) : condition homogène, tout enlever
    [tilde_AA, tilde_LL] = elimine(tilde_AA_tmp, tilde_LL_tmp, extended_Refneu == 2);
    
    % On impose des conditions limite de type Dirichlet uniquement pour les
    % composantes de la vitesse
    % Les fonctions g1 et g2 renvoient 0 si le noeud n'est pas au bord,
    % donc il n'est pas nécessaire de filtrer les valeurs
    tilde_LL(1:Nbpt) = g1(Coorneu(:, 1), Coorneu(:, 2), verification);
    tilde_LL((Nbpt+1):(2*Nbpt)) = g2(Coorneu(:, 1), Coorneu(:, 2));
end