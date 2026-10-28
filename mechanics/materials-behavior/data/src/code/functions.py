import pandas as pd
import matplotlib.pyplot as plt

def write_pretty_output(input_data, output_data, cols = None):
    data = pd.read_csv(input_data, header = None, skiprows = 34, delimiter=' ')
    data_cut = data.iloc[:,[0,1,7]]
    data_cut.columns = cols
    print(data_cut)
    data_cut.to_csv(output_data, sep=';', index=False)

## This function should be customized further for more ability
## It's a quick spagetti code
def draw_data(input_data, figure_title, style = 1):
    data_traction1_ex2 = pd.read_csv(input_data, delimiter=",")
    
    fig, ax = plt.subplots(nrows = 1, 
                           ncols = 2,
                           figsize = (10, 5))

    fig.suptitle(figure_title)
    plt.subplots_adjust(wspace=0.3)

    if style == 1:
        ax[0].plot(data_traction1_ex2["Time"], data_traction1_ex2["EXX"], label="EXX - Strain", 
               linestyle="None", marker = "x", markerfacecolor='magenta', markeredgecolor = "magenta", markersize = 3)

    elif style == 2:
        ax[0].plot(data_traction1_ex2["Time"], data_traction1_ex2["EXX"], label="EXX - Strain", 
               linestyle="dotted", color = "magenta", linewidth = 1)
    
    ax[0].legend(frameon=True, loc='upper left', fontsize=12, facecolor='white', edgecolor='black')
    ax[0].grid(True)

    if data_traction1_ex2["Time"].min() < 0:
        ax[0].set_xlim([data_traction1_ex2["Time"].min()*1.1, data_traction1_ex2["Time"].max()*1.1])
    else:
        ax[0].set_xlim([0, data_traction1_ex2["Time"].max()*1.1])

    if data_traction1_ex2["EXX"].min() < 0:
        ax[0].set_ylim([data_traction1_ex2["EXX"].min()*1.1, data_traction1_ex2["EXX"].max()*1.1])
    else:
        ax[0].set_ylim([0, data_traction1_ex2["EXX"].max()*1.1])

    ax[0].set_xlabel("Time (s)", fontsize=14)
    ax[0].set_ylabel("Deformation (mm/mm)", fontsize=14)

    if style == 1:
        ax[1].plot(data_traction1_ex2["EXX"], data_traction1_ex2["SXX"], label="Stress - Strain", 
                   linestyle="None", marker = "x", markerfacecolor='magenta', markeredgecolor = "magenta", markersize = 3)
    elif style == 2:
        ax[1].plot(data_traction1_ex2["EXX"], data_traction1_ex2["SXX"], label="Stress - Strain", 
               linestyle="dotted", color = "magenta", linewidth = 1)
        
    ax[1].legend(frameon=True, loc='upper left', fontsize=12, facecolor='white', edgecolor='black')
    ax[1].grid(True)

    if data_traction1_ex2["EXX"].min() < 0:
        ax[1].set_xlim([data_traction1_ex2["EXX"].min()*1.1, data_traction1_ex2["EXX"].max()*1.1])
    else:
        ax[1].set_xlim([0, data_traction1_ex2["EXX"].max()*1.1])

    if data_traction1_ex2["SXX"].min() < 0:
        ax[1].set_ylim([data_traction1_ex2["SXX"].min()*1.1, data_traction1_ex2["SXX"].max()*1.1])
    else:
        ax[1].set_ylim([0, data_traction1_ex2["SXX"].max()*1.1])

    ax[1].set_xlabel("Deformation (mm/mm)", fontsize=14)
    ax[1].set_ylabel("Contraintes (MPa)", fontsize=14)







