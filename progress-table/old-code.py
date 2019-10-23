# Quantités de matière initiales
# réactifs:
n1_ini = float(input("Quantité initiale de 1 : "))
n2_ini = float(input("Quantité initiale de 2 : "))
# produits
n3_ini = 0
n4_ini = 0

# Nombres stoechiométriques
# réactifs:
stoechio1 = int(input("Coefficiant stoechiométrique de 1 (réactif) : "))
stoechio2 = int(input("Coefficiant stoechiométrique de 2 (réactif) : "))
# produits
stoechio3 = int(input("Coefficiant stoechiométrique de 3 (produit) : "))
stoechio4 = int(input("Coefficiant stoechiométrique de 4 (produit) : "))

# Formules des réactifs et produits
# réactifs:
r1 = input("Nom de 1 (réactif) : ")
r2 = input("Nom de 2 (réactif) : ")
# produits
p1 = input("Nom de 3 (produit) : ")
p2 = input("Nom de 4 (produit) : ")


# initialisation des variables
r_limit=""
xmax=0
# Quantité de matières finales: à zéro au départ
n1_fin =0
n2_fin =0
n3_fin = 0
n4_fin = 0

# Affichage de l'état initial du système
# mise en forme de l'affichage, En écriture scientifique, à 2 CS
#  "%.1e"%   signifie écriture scientifique à 1 chiffre après la virgule (donc 2 C.S.)
print("Etat initial du système:")
print("n("+ r1 +") = "+"%.1e"%n1_ini + " mol")
print("n("+ r2 +") = "+"%.1e"%n2_ini + " mol")
print("n("+ p1 +") = "+"%.1e"%n3_ini + " mol")
print("n("+ p2 +") = "+ "%.1e"%n4_ini + " mol")
print("-------------------------------------")

# recherche du réactif limitant et de xmax
xf1 = n1_ini/stoechio1
xf2 = n2_ini/stoechio2

if xf1 < xf2:
    xmax = xf1
    r_limit = r1
else:
    xmax = xf2
    r_limit = r2

# Affichage du réactif limitant et de xmax
print("Le réactif limitant est "+r_limit)
print ("xmax="+"%.1e"%xmax+" mol")
print("----------------------------")

# Calcul des quantités de matière finales
n1_fin = n1_ini - stoechio1*xmax
n2_fin = n2_ini - stoechio2*xmax
n3_fin = stoechio3*xmax
n4_fin = stoechio4*xmax

# Affichage de l'état final du système
print("Etat final du système:")
print("n("+ r1 +") = "+"%.1e"%n1_fin + " mol")
print("n("+ r2 +") = "+"%.1e"%n2_fin+ " mol")
print("n("+ p1 +") = "+"%.1e"%n3_fin + " mol")
print("n("+ p2 +") = "+"%.1e"%n4_fin + " mol")
print("-------------------------------------")