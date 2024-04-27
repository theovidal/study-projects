#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Affichage de la solution de l'équation de Laplace / version 3
"""

import numpy as np
import time
import matplotlib.pyplot as plt

def graphe_equipot(B,f,Ex,Ey, nb_equipot =25):
    Nx,Ny=B.shape
    plt.figure()
    plt.imshow(B,origin='lower',cmap='binary',interpolation='nearest')
    x = np.linspace(0,Nx-1,Nx) # Array de 0 à Nx -1 inclus en Nx points
    y = np.linspace(0,Ny-1,Ny)
    cont = plt.contour(x,y,f,nb_equipot,colors='k',linewidths=.5) # Trace les é quipotentielles
    plt.title ('champ et equipotentielles')
    plt.clabel(cont, fmt='%1.1f')
    cont=plt.streamplot(x,y,Ex,Ey,linewidth=.5,density=5.)
    plt.show()
#    plt.savefig('condensateur.jpg')

def calcul_champ(B,f):
    Nx,Ny=B.shape
    Ex=np.zeros((Nx,Ny))
    Ey=np.zeros((Nx,Ny))
    for i in np.arange(1,Nx-1):
        for j in np.arange(1,Nx-1):
            if B[i,j]== 0:
                Ex[i,j]=(V[i-1,j]-V[i+1,j])/2
                Ey[i,j]=(V[i,j-1]-V[i,j+1])/2
    return(Ex,Ey)

V=np.load('condensateur-1000-V.npy')
B=np.load('condensateur-1000-B.npy')

N=len(V)
a=N//4
b=(3*N)//4
Bint=B[a:b,a:b]
Vint=V[a:b,a:b]
(Ey,Ex)=calcul_champ(B,V)
Exint=Ex[a:b,a:b]
Eyint=Ey[a:b,a:b]

# Affichage
graphe_equipot(Bint,Vint,Exint,Eyint,nb_equipot =15)
