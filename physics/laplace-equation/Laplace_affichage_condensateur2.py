#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Affichage de la solution de l'équation de Laplace / version 2
"""

import numpy as np
import time
import matplotlib.pyplot as plt

def graphe_equipot(B,f,cb=False, nb_equipot =25):
    Nx,Ny=B.shape
    plt.figure()
    plt.imshow(B,origin='lower',cmap='binary',interpolation='nearest')
    if cb==True:
        plt.imshow(f,origin ='lower') # Pour tracer un colorplot de f
        plt.colorbar()
    x = np.linspace(0,Nx-1,Nx) # Array de 0 à Nx -1 inclus en Nx points
    y = np.linspace(0,Ny-1,Ny)
    cont = plt.contour(y,x,f,nb_equipot,colors='k') # Trace les équipotentielles
    plt.title ('equipotentielles')
    plt.clabel(cont, fmt='%1.1f')
    plt.show()

V=np.load('condensateur-1000-V.npy')
B=np.load('condensateur-1000-B.npy')

N=len(V)
#Lignes nouvelles
a=N//4
b=(3*N)//4
Bint=B[a:b,a:b]
Vint=V[a:b,a:b]

# Affichage
graphe_equipot(Bint,Vint,cb=True,nb_equipot =15)
