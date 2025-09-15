#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
résolution de l'équation de Laplace par la méthode de Jacobi
"""

import numpy as np
import time
import matplotlib.pyplot as plt


def une_iteration(B,V):
    ecartmax=0
    for i in range(Nx):
        for j in range(Ny):
            pot=V[i,j]
            if B[i,j]==0:
                V[i,j]=(V[i+1,j]+V[i-1,j]+V[i,j+1]+V[i,j-1])/4.
                ecartmax=max(ecartmax,abs(pot-V[i,j]))
    return(ecartmax)

def iterations(B,V,eps):
    ecart = eps+1.
    nb_iterations = 0
    while ecart>eps:
        ecart=une_iteration(B,V)
        nb_iterations+= 1
    return nb_iterations



def graphe_equipot(B,f, nb_equipot =25):
    Nx,Ny=B.shape
    plt.figure()
    plt.imshow(B,origin='lower',cmap='binary',interpolation='nearest')
    x = np.linspace(0,Nx-1,Nx) # Array de 0 à Nx -1 inclus en Nx points
    y = np.linspace(0,Ny-1,Ny)
    cont = plt.contour(y,x,f,nb_equipot,colors='k') # Trace les é quipotentielles
    plt.title ('equipotentielles')
    plt.clabel(cont, fmt='%1.1f')
    plt.show()
    plt.savefig('condensateur.jpg')


# initialisation
Nx=100
Ny=100

d=12
L=40
epsilon=1e-3
B=np.zeros((Nx,Ny))
V=np.zeros((Nx,Ny))

# Bords de la grille
for i in range(Nx):
    B[i,0]=1
    B[i,Ny-1]=1
for j in range(Ny):
    B[0,j]=1
    B[Nx-1,j]=1

# Armatures du condensateur (// = floor division)
for i in range(L):
        B[(Nx-L)//2+i,(Ny+d)//2]=1
        V[(Nx-L)//2+i,(Ny+d)//2]=100
        B[(Nx-L)//2+i,(Ny-d)//2]=1
        V[(Nx-L)//2+i,(Ny-d)//2]=-100

# Calcul

start = time.time()
iterations(B,V,epsilon)
end = time.time()
elapsed = end - start
print(f'Temps d\'exécution : {elapsed:.3}s')

# Affichage
graphe_equipot(B,V,nb_equipot =20)


