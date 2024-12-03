%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% routine de lecture de fichiers de maillages triangulaires 2D d'ORDRE 2 au format .msh
%
% SYNOPSIS [Nbpt,Nbtri,Coorneu,Refneu,Numtri,Reftri,Nbaretes,Numaretes,Refaretes]=lecture_msh_ordre2(nomfile)
%
% INPUT * nom_maillage : le nom d'un fichier de maillage au format msh
%                   AVEC SON SUFFIXE .msh et ENTRE GUILLEMETS
%
% OUTPUT - Nbpt : nbre de noeuds (sommets et milieux des aretes) (entier)
%        - Nbtri : nbre de triangles (entier)
%        - Coorneu : coordonnees (x, y) des noeuds (matrice reelle Nbpt x 2)
%        - Refneu : reference des noeuds (vecteur entier Nbpt x 1)
%        - Numtri : liste des triangles
%                   (6 numeros de noeuds (3 sommets puis 3 milieux) - matrice entiere Nbtri x 6)
%        - Reftri : reference des triangles (matrice entiere Nbtri x 1)
%        - Nbaretes : Nombre d'aretes sur la frontiere.
%        - Numaretes(Nbaretes,3) = numero des 3 noeuds (2 sommets puis milieu) de chaque arete de la frontiere
%		     - Refaretes(Nbaretes,1) = Reference de chaque arete de la frontiere
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%24
function [Nbpt,Nbtri,Coorneu,Refneu,Numtri,Reftri,Nbaretes,Numaretes,Refaretes]=lecture_msh_ordre2(nomfile)

fid=fopen(nomfile,'r');
if fid <=0,
   msg=['Le fichier de maillage : ' nomfile ' n''a pas ete trouve'];
   error(msg);
end

while ~strcmp(fgetl(fid),'$Nodes'), end
Nbpt = str2num(fgetl(fid));
Coorneu = zeros(Nbpt,2);
Refneu = zeros(Nbpt,1);
Nbaretes = 0;
Numaretes = [];
Refaretes = [];
RefneuBis = zeros(Nbpt,1);

for i=1:Nbpt
  tmp= str2num(fgetl(fid));
  Coorneu(i,:) = tmp(2:3);
end

while ~strcmp(fgetl(fid),'$Elements'), end
Nbtri = str2num(fgetl(fid));
tmp= str2num(fgetl(fid));
test = tmp(2);

while ( (test~=15) && (test~=8) && (test~=9)) %MODorder2%
  tmp= str2num(fgetl(fid));
  test = tmp(2);
  Nbtri = Nbtri-1;
end

% on traite les noeuds des coins
while ((test~=8) && (test~=9)) %MODorder2%
     Refneu(tmp(end))=tmp(end-2);
     tmp= str2num(fgetl(fid));
     test = tmp(2);
     Nbtri = Nbtri-1;
end

% on traite les noeuds du bord
k=1;
while (test~=9) %MODorder2%
    RefneuBis(tmp(6:8)')=tmp(4); %MODorder2%
    Numaretes= [Numaretes;tmp(6:8)]; %MODorder2%
    Refaretes= [Refaretes;tmp(4)];
    tmp= str2num(fgetl(fid));
    test = tmp(2);
    Nbaretes=Nbaretes+1;
    Nbtri=Nbtri-1;
    k=k+1;
end
Refneu(find(Refneu==0))=RefneuBis(find(Refneu==0));

Numtri = zeros(Nbtri,6); %MODorder2%
Reftri = zeros(Nbtri,1);

% on traite les references des triangles
for i=1:Nbtri
    Numtri(i,:) = tmp(end-5:end); %MODorder2%
    Reftri(i)=tmp(end-6); %MODorder2%
    tmp= str2num(fgetl(fid));
end

fclose(fid);
