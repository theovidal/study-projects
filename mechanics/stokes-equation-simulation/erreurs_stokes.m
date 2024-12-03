% =====================================================
%
% Routine de calcul des solutions numériques pour l'équation de Stokes, et
% comparaison des erreurs (différence, erreur L2, erreur H1) et des temps
% de calcul
%
% =====================================================
clear all; close all; clc

% Viscosité
nu = 1;

% Vérifier le résultat numérique avec la solution analytique exacte du
% canal droit
verification = 1;

% Répertoires où sont situés les différents maillages
if verification == 1
    repertoire = "geomRectangle_partie3";
else
    repertoire = "geomRectangle_partie3_2";
end

% Noms des maillages dans les répertoires (un renommage est nécessaire
% après génération par GMSH)
noms_maillage = ["01.msh", "005.msh", "0025.msh", "00125.msh"];
% Valeur de h correspondant à chaque maillage ci-dessus
h = [0.1, 0.05, 0.025];

% ----- DÉBUT DU SCRIPT -----

erreurs_l2_U1 = zeros(size(h));
erreurs_h1_U1 = zeros(size(h));

erreurs_l2_U2 = zeros(size(h));
erreurs_h1_U2 = zeros(size(h));

temps = zeros(size(h));

for i=1:length(h)
    fprintf('Traitement du cas h=%f\n', h(i))

    [Numtri, Coorneu, Nbpt, numsommets, MM, KK, U1, U2, P, P_exact, t] = principal_stokes(sprintf('%s/%s', repertoire, noms_maillage(i)), nu, verification);

    if verification == 1
        % Partie 1 : canal droit

        x = Coorneu(:, 1);
        y = Coorneu(:, 2);

        % Les solutions analytiques exactes sont connues (cf exercice 1 du
        % TD1 de MEC_4MF01_TA)
        U1_exact = (2 - y) .* y;
        U2_exact = zeros(Nbpt, 1);
    
        Diff_U1 = U1 - U1_exact;
        Diff_U2 = U2 - U2_exact;
        Diff_P = P - P_exact;

        affiche_solution_comparee(Numtri, Coorneu, Nbpt, numsommets, h(i), U1, Diff_U1, U2, Diff_U2, P, Diff_P);

        % On calcule les erreurs et on les compiles, pour en faire ensuite
        % des graphes
        [erreur_l2_U1, erreur_h1_U1] = calcule_erreurs(U1, U1_exact, MM, KK);
        [erreur_l2_U2, erreur_h1_U2] = calcule_erreurs(U2, U2_exact, MM, KK);
    
        erreurs_l2_U1(i) = erreur_l2_U1;
        erreurs_h1_U1(i) = erreur_h1_U1;
        erreurs_l2_U2(i) = erreur_l2_U2;
        erreurs_h1_U2(i) = erreur_h1_U2;        
    else
        % Partie 2 : canal avec marche descendante
        % On ne connait pas de solutions analytique, on compare simplement
        % les résolutions numériques
        affiche_solution(Numtri, Coorneu, Nbpt, numsommets, h, U1, U2, P);
    end

    temps(i) = t;
end

if verification == 1
    affiche_erreurs(h, erreurs_l2_U1, erreurs_h1_U1);
    affiche_erreurs(h, erreurs_l2_U2, erreurs_h1_U2);
end

affiche_temps(h, temps)

% ----------------------------------------------------------

% Affichage des erreurs L2 et H1, lorsque la solution analytique est connue
function affiche_erreurs(h, erreur_l2, erreur_h1, name)
    logh = log(1 ./ h);

    % Les erreurs renvoyées par la fonction calcule_erreurs sont déjà
    % normalisées
    ord_l2 = log(erreur_l2);
    ord_h1 = log(erreur_h1);
    
    figure(length(h) + 1)
    subplot(2, 1, 1)
    %title(sprintf("Graphe de convergence de %s", name))

    grid on
    hold on
    
    % Estimation des pentes des erreurs par une régression linéaire
    P2 = polyfit(logh, ord_l2, 1);
    P1 = polyfit(logh, ord_h1, 1);
    
    yfit_2 = polyval(P2, logh);
    yfit_1 = polyval(P1, logh);
    
    plot(logh, ord_l2, 'r*-');
    plot(logh, yfit_2, 'r--');
    plot(logh, ord_h1, 'bo-');
    plot(logh, yfit_1, 'b--');
    
    xlabel('log(1/h)')
    legend('L2 norm', sprintf('L2 norm lin m=%.4f', P2(1)), 'H1 norm', sprintf('H1 norm lin m=%.4f', P1(1)))
end


% Calcul des erreurs normalisées par rapport à une solution connue
function [erreur_l2, erreur_h1] = calcule_erreurs(U, U_exact, MM, KK)
    Diff = U - U_exact;

    erreur_l2 = sqrt(dot(Diff, MM*Diff)) / sqrt(dot(U_exact, MM*U_exact));
    erreur_h1 = sqrt(dot(Diff, KK*Diff)) / sqrt(dot(U_exact, KK*U_exact));
end

% Affichage des solutions numériques, lorsque la solution analytique n'est
% pas connue explicitement
function affiche_solution(Numtri, Coorneu, Nbpt, numsommets, h, U1, U2, P)
    Ns=length(numsommets);

    figure
    sgtitle(sprintf('Représentation de la solution pour h=%.3f', h))

    subplot(2, 2, 1);
    affiche_ordre2(U1, Numtri, Coorneu, "U1");

    subplot(2, 2, 2)
    affiche_ordre2(U2, Numtri, Coorneu, "U2");

    subplot(2, 2, 3)
    quiver(Coorneu(:, 1), Coorneu(:, 2), U1, U2)
    title('(U1h, U2h)')

    subplot(2, 2, 4)

    % Dans la i-eme entree de DEnumnoeudAnumsommet on trouve le numero en tant que sommet du i-eme noeud  
    % (et on trouve 0 si l'i-eme noeud n'est pas un sommet) 
    DEnumnoeudAnumsommet = zeros(Nbpt, 1);
    DEnumnoeudAnumsommet(numsommets) = 1:Ns;   
    % Pour l'affichage on decale les numeros dans Numtri
    NumtriDecale = DEnumnoeudAnumsommet(Numtri(:,1:3)); 

    affiche_ordre1(P, NumtriDecale, Coorneu(numsommets,:), 'P');
end

% Affichage de la solution numérique et des écarts à une solution analytique
function affiche_solution_comparee(Numtri, Coorneu, Nbpt, numsommets, h, U1, Diff_U1, U2, Diff_U2, P, Diff_P)
    Ns=length(numsommets);

    figure
    sgtitle(sprintf('Représentation de la solution et des erreurs pour h=%.3f', h))

    subplot(2, 3, 1)
    affiche_ordre2(Diff_U1, Numtri, Coorneu, "U1 - U1h");

    subplot(2, 3, 2)
    affiche_ordre2(Diff_U2, Numtri, Coorneu, "U2 - U2h");

    subplot(2, 3, 3)
    quiver(Coorneu(:, 1), Coorneu(:, 2), U1, U2)
    title('(U1h, U2h)')

    % Dans la i-eme entree de DEnumnoeudAnumsommet on trouve le numero en tant que sommet du i-eme noeud  
    % (et on trouve 0 si l'i-eme noeud n'est pas un sommet) 
    DEnumnoeudAnumsommet = zeros(Nbpt, 1);
    DEnumnoeudAnumsommet(numsommets) = 1:Ns;   
    % Pour l'affichage on decale les numeros dans Numtri
    NumtriDecale = DEnumnoeudAnumsommet(Numtri(:,1:3)); 

    subplot(2, 3, 4)
    affiche_ordre1(Diff_P, NumtriDecale, Coorneu(numsommets,:), 'P - Ph');
    
    subplot(2, 3, 5)
    affiche_ordre1(P, NumtriDecale, Coorneu(numsommets,:), 'P');
end

% Affichage du graphe des temps d'exécutions pour différents pas du
% maillage
function affiche_temps(h, temps)
    figure(length(h) + 1)
    sgtitle('Comparaison de valeurs pour différents pas de maillage')
    subplot(2, 1, 2)
    title('Temps de calcul')
    plot(log(1 ./ h), temps);
    xlabel('log(1/h)')
    ylabel('Temps (s)')
end
