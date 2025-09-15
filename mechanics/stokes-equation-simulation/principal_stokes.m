% =====================================================
%
% une routine pour la mise en oeuvre des EF Taylor-Hood
% (P^2-P^1) pour l'equation de Stokes
%
% | - nu*\Delta u + \Grad p = f,   dans \Omega
% |                 - div u = 0,   dans \Omega
% |                       u = g,   sur \Gamma_D
% |           nu*du/dn - pn = 0,   sur \Gamma_N
%
% =====================================================
function [Numtri, Coorneu, Nbpt, numsommets, MM, KK, U1, U2, P, P_exact, t, LL, tilde_LL] = principal_stokes(nom_maillage, nu, verification)

% lecture du maillage et affichage
% ---------------------------------
[Nbpt,Nbtri,Coorneu,Refneu,Numtri,~,~,~,~] = lecture_msh_ordre2(nom_maillage);

% ----------------------
% calcul des matrices EF
% ----------------------

% declarations
% ------------

% on ne connait pas encore le nombre de sommets, attention ce n'est pas la moitie du nombre des noeuds !

MM = sparse(Nbpt, Nbpt);    % matrice de masse
KK = sparse(Nbpt, Nbpt);    % matrice de rigidite : bloc (u_i, v_i)
EE = sparse(Nbpt, Nbpt);  % bloc (p, v1) carre temporaire, ce bloc sera rectangulaire apres extraction des noeuds correspondant aux sommets
FF = sparse(Nbpt, Nbpt);  % bloc (p, v2) carre temporaire, ce bloc sera rectangulaire apres extraction des noeuds correspondant aux sommets
isavertex = zeros(Nbpt, 1); % tableau booleen "is a vertex" reperant les noeuds qui sont des sommets (et pas des milieux)

tic

% boucle sur les triangles
% ------------------------
for l=1:Nbtri
  index = Numtri(l,:);

  % Coordonnees des sommets du triangle
  S1=Coorneu(index(1),:);
  S2=Coorneu(index(2),:);
  S3=Coorneu(index(3),:);

  % On met 1 dans les entrees de isavertex correspondants aux 3 sommets
  isavertex(Numtri(l,1)) = 1;
  isavertex(Numtri(l,2)) = 1;
  isavertex(Numtri(l,3)) = 1;

  % Calcul des matrices elementaires du triangle l
  Mel = matM_elem_p2(S1, S2, S3);
  Kel = matK_elem_p2(S1, S2, S3);
  [Eel, Fel] = matsEF_elem(S1, S2, S3); 

  % On fait l'assemblage des blocs (u_i, v_i)

  for i=1:6
      I = index(i);
      for j=1:6
          J = index(j);

          MM(I, J) = MM(I, J) + Mel(i, j);
          KK(I, J) = KK(I, J) + Kel(i, j);
      end % j
  end % i

  % On fait l'assemblage des blocs (p, v1) et (p, v2)

  for i=1:6
      I = index(i);
      for j=1:3
          J = index(j);

          EE(I, J) = EE(I, J) + Eel(i, j);
          FF(I, J) = FF(I, J) + Fel(i, j);
      end % j
  end % i

end % for l

% find(isavertex~=0) donne la liste des numeros des sommets
numsommets = find(isavertex==1);
Ns = length(numsommets);   % nombre de sommets

%EE = zeros(Nbpt, Ns);      % bloc rectangulaire (p, v1)
%FF = zeros(Nbpt, Ns);      % bloc rectangulaire (p, v2)

% On extrait de EEtmp et FFtmp les colonnes correspondantes a des sommets
% (par ailleurs les autres colonnes sont a priori nulles)

% Suppression des colonnes ne correspondant pas à des sommets
EE(:, isavertex==0) = [];
FF(:, isavertex==0) = [];

% Matrice éléments finis par blocs
AA = sparse(2*Nbpt + Ns, 2*Nbpt + Ns);

AA(1:Nbpt, 1:Nbpt) = nu * KK;
AA((Nbpt+1):(2*Nbpt), (Nbpt+1):(2*Nbpt)) = nu * KK;
AA(1:Nbpt, (2*Nbpt+1):(2*Nbpt + Ns)) = EE;
AA((Nbpt+1):(2*Nbpt), (2*Nbpt+1):(2*Nbpt + Ns)) = FF;
AA((2*Nbpt+1):(2*Nbpt + Ns), 1:Nbpt) = EE';
AA((2*Nbpt+1):(2*Nbpt + Ns), (Nbpt+1):(2*Nbpt)) = FF';

% Pseudo-elimination
% ------------------
% on n'impose Dirichlet que sur les inconnues P2 de la vitesse
LL = zeros(2*Nbpt+Ns,1);  % vecteur second membre

% TODO: maintenant le problème est sur la limite en P, l'élimination a
% peut-être fait n'importe quoi
[tilde_AA, tilde_LL] = elimine_stokes(AA, LL, Coorneu, Refneu, Nbpt, Ns, verification);

% Resolution du systeme lineaire
% ----------
UU = tilde_AA\tilde_LL;

t = toc;

% visualisation
% -------------
U1 = UU(1:Nbpt);
U2 = UU((Nbpt+1):(2*Nbpt));
P = UU((2*Nbpt+1):(2*Nbpt + Ns));

x = Coorneu(:, 1);
y = Coorneu(:, 2);
% Pour le calcul de P, on ne garde que les noeuds correspondant à des
% éléments P1, donc les sommets des triangles
P_exact =  -2 * (x(isavertex == 1) - 3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                        fin de la routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%24
