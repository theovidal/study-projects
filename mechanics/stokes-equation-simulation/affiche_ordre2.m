function affiche_ordre2(UU,Numtri,Coorneu, titre)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% permet de voir le vecteur UU (restreint aux sommets) sur le maillage (Numtri, Coorneu)
%
% SYNOPSIS : affiche_ordre2(UU,Numtri,Coorneu,titre)
%
% INPUT * UU vecteur de valeurs aux noeuds (vecteur Nbpt x 1)
%       * Numtri : liste de triangles
%                   (6 numeros de noeuds - matrice entiere Nbtri x 6)
%       * Coorneu : coordonnees (x, y) des noeuds (matrice reelle Nbpt x 2)
%       * titre (optionel) un titre (string)
%
% OUTPUT une fenetre graphique
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% control on the input args
if (nargin<4), titre = ''; end;

trisurf(Numtri(:,1:3),Coorneu(:,1),Coorneu(:,2),UU); %MODorder2%
view(2);
shading interp
% shading faceted
% shading flat
colorbar;

% ajouter eventuellement un titre
title(titre);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                        fin de la routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%24
