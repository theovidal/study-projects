# Initial quantities
# reagents :
nA_ini = float(input("Initial quantity of A : "))
nB_ini = float(input("Initial quantity of B : "))
# products :
nC_ini = 0
nD_ini = 0

# Stoichiometric numbers
# reagents :
stoichioA = int(input("Stoichiometric number of A (reagent) : "))
stoichioB = int(input("Stoichiometric number of B (reagent) : "))
# products :
stoichioC = int(input("Stoichiometric number of C (product) : "))
stoichioD = int(input("Stoichiometric number of D (product) : "))

# Names of reagents and products
# reagents :
rA = input("Name of A (reagent) : ")
rB = input("Name of B (reagent) : ")
# products :
rC = input("Name of C (product) : ")
rD = input("Name of D (product) : ")


# Variables initialization
r_limit = ""
xmax = 0
# Final quantities of reagents and products : initially to 0
nA_fin = 0
nB_fin = 0
nC_fin = 0
nD_fin = 0

# Printing the initial state of the system
print("Material balance in the initial state :")
print("n(" + rA + ") = " + "%.1e" % nA_ini + " mol")
print("n(" + rB + ") = " + "%.1e" % nB_ini + " mol")
print("n(" + rC + ") = " + "%.1e" % nC_ini + " mol")
print("n(" + rD + ") = " + "%.1e" % nD_ini + " mol")
print("-------------------------------------")

# Researching the limiting reagant and xmax
xf1 = nA_ini / stoichioA
xf2 = nB_ini / stoichioB

if xf1 < xf2:
    xmax = xf1
    r_limit = rA
else:
    xmax = xf2
    r_limit = rB

# Printing them
print("The limiting reagent is " + r_limit)
print("xmax=" + "%.1e" % xmax + " mol")
print("----------------------------")

# Calculating the material balance in the final state
nA_fin = nA_ini - stoichioA * xmax
nB_fin = nB_ini - stoichioB * xmax
nC_fin = stoichioC * xmax
nD_fin = stoichioD * xmax

# Printing the final state of the system
print("Material balance in the final state")
print("n(" + rA + ") = " + "%.1e" % nA_fin + " mol")
print("n(" + rB + ") = " + "%.1e" % nB_fin + " mol")
print("n(" + rC + ") = " + "%.1e" % nC_fin + " mol")
print("n(" + rD + ") = " + "%.1e" % nD_fin + " mol")
print("-------------------------------------")
