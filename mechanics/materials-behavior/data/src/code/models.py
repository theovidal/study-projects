from mtest import *
import mfront
import std
import tfel.tests
import numpy as np
import pandas as pd
import pprint


class lk:
    def __init__(self, model_input_file = {}, 
                 behavior_name = 'asterlinearkinematic', 
                 behavior_location = '/apps/binary/tfel/behaviors/src/libAsterBehaviour.so'):
        self.model_input_file = model_input_file
        self.behavior_name = behavior_name
        self.behavior_location = behavior_location
        self._allowed_material_property_inputs = self.get_material_property_inputs()
        self._allowed_external_state_variable_inputs = self.get_external_state_variable_inputs()
        self._allowed_internal_state_variable_inputs = self.get_internal_state_variable_inputs()
        self._generic_input = self.create_generic_input()

        if not model_input_file:
            print("No input file provided. Creating a generic input file...")
            print("Warning: You need to set the material properties and external state variables manually.")
            self.model_input_file = self._generic_input
        
        # Here we require more work to correct the input file
        # This implementation should be changed at some point
        else:
            print("Input file loaded successfully.")
            print("Checking if all required fields are present...")
            self.model_input_file = self.complete_dict(user_dict=self.model_input_file, default_dict=self._generic_input)
            # self.print_input()


        # Check material property part
        # self.analyze_material_property()       

    def create_generic_input(self):
        generic_dict = {
            "material_property": {},  # Empty dictionary for material properties
            "output": {
                "filename": None  # Placeholder for output filename
            },
            "external_state_variable": {},  # Empty dictionary for external state variables
            "time": {
                "start_time": None,  # Placeholder for start time
                "end_time": None,    # Placeholder for end time
                "step_time": None    # Placeholder for step time
            },
            "load": {
                "method": None,      # Placeholder for load method
                "direction": None,   # Placeholder for load direction
                "loading_blocks": {
                    2: {
                        "time": None,  # Placeholder for time in block 2
                        "load": None   # Placeholder for load in block 2
                    },
                    1: {
                        "time": None,  # Placeholder for time in block 1
                        "load": None   # Placeholder for load in block 1
                    }
                }
            }
        }

        for key in self._allowed_material_property_inputs:
            generic_dict["material_property"][key] = None
        
        for key in self._allowed_external_state_variable_inputs:
            generic_dict["external_state_variable"][key] = None
        
        return generic_dict

    def complete_dict(self, user_dict, default_dict):

        # Recursively update user_dict with values from default_dict
        for key, value in default_dict.items():
            if key not in user_dict:  # If the key is missing, set the default value
                user_dict[key] = value
            elif isinstance(value, dict):  # If the value is a dictionary, go deeper
                user_dict[key] = self.complete_dict(user_dict.get(key, {}), value)
            else:  # If not, just set the default value if it's missing
                user_dict.setdefault(key, value)
        return user_dict


    def print_input(self):
        pprint.pprint(self.model_input_file)

    def get_material_property_inputs(self):
        self.behavior_instance = Behaviour('aster', self.behavior_location, self.behavior_name, 'PlaneStrain')
        return self.behavior_instance.getMaterialPropertiesNames()

    def get_external_state_variable_inputs(self):
        self.behavior_instance = Behaviour('aster', self.behavior_location, self.behavior_name, 'PlaneStrain')
        return self.behavior_instance.getExternalStateVariablesNames()

    def get_internal_state_variable_inputs(self):
        self.behavior_instance = Behaviour('aster', self.behavior_location, self.behavior_name, 'PlaneStrain')
        return self.behavior_instance.getInternalStateVariablesNames()

    def analyze_material_property(self):

        # A is the reference list of material properties
        A = self._allowed_material_property_inputs

        # B is the user input
        B = list(self.model_input_file["material_property"].keys())

        # Let's check if something is missing in B
        missing_in_B = [item for item in A if item not in B]

        if missing_in_B:
            print(f"Parameters missing in your input: {missing_in_B}")
        else:
            print("All material properties are defined in the input file!")

        # Find items in user input that should not be there
        extra_in_B = [item for item in B if item not in A]

        if extra_in_B:
            print(f"Extra items in user input: {extra_in_B}")

            # Remove extra items from B
            for item in extra_in_B:
                B.remove(item)
            print(f"Updated B after removing extra items: {B}")

        else:
            print("No extra items in user input.")

    def setMaterialProperty(self, key, value):
        self.model_input_file["material_property"][key] = value
        print(f"Property '{key}' set to {value}")

    def getMaterialProperty(self, key):
        return self.model_input_file["material_property"][key]
    

    def run_simulation(self):
        m = MTest()
        setVerboseMode(VerboseLevel.VERBOSE_LEVEL0)
        m.setPredictionPolicy(PredictionPolicy.LINEARPREDICTION)
        m.setBehaviour("aster",self.behavior_location, self.behavior_name)

        for key, value in self.model_input_file["material_property"].items():
            getattr(m, "setMaterialProperty")(key, value)

        for key, value in self.model_input_file["external_state_variable"].items():
            getattr(m, "setExternalStateVariable")(key, value)


        getattr(m, "setTimes")(np.arange(self.model_input_file["time"]["start_time"], 
                                        self.model_input_file["time"]["end_time"] + self.model_input_file["time"]["step_time"], 
                                        self.model_input_file["time"]["step_time"]).tolist())
        
        loading_data = {block["time"]: block["load"] for block in sorted(self.model_input_file["load"]["loading_blocks"].values(), key=lambda x: x["time"])}

        getattr(m, "setImposedStrain")(self.model_input_file["load"]["direction"], loading_data)
        getattr(m, "setOutputFileName")(self.model_input_file["output"]["filename"])
        getattr(m, "execute")()
        del m

    def print_output(self):
        total_skipped_rows = 15 + len(self._allowed_internal_state_variable_inputs)*6
        data = pd.read_csv(self.model_input_file["output"]["filename"], skiprows = total_skipped_rows, header=None, delimiter=r"\s+")

        extension = ["XX", "YY", "ZZ", "XY", "XZ", "YZ"]
        res = ["E", "S"]
        titles = ['Time']

        for val in res:
            for ext in extension:
                titles.append(val + ext)

        for val in self._allowed_internal_state_variable_inputs:
            if self.behavior_instance.getInternalStateVariableType(val) == 0: # Scalar
                titles.append(val)
            else:
                for ext in extension:
                    titles.append(val + ext)

        titles.append("Stored Energy")
        titles.append("Disspated Energy")

        data.columns = titles

        return data
    
    def graph_e_and_sigma_time(self, dataframe):
        import matplotlib.pyplot as plt

        fig, ax = plt.subplots(nrows = 1, 
                               ncols = 2,
                               figsize = (10, 5))
        
        ax[0].plot(dataframe["Time"], dataframe["EXX"], label="EXX - Strain", color="red", linestyle="-")
        ax[0].legend(frameon=True, loc='upper left', fontsize=12, facecolor='white', edgecolor='black')
        ax[0].grid(True)
        if dataframe["Time"].min() < 0:
            ax[0].set_xlim([dataframe["Time"].min()*1.1, dataframe["Time"].max()*1.1])
        else:
            ax[0].set_xlim([0, dataframe["Time"].max()*1.1])

        if dataframe["EXX"].min() < 0:
            ax[0].set_ylim([dataframe["EXX"].min()*1.1, dataframe["EXX"].max()*1.1])
        else:
            ax[0].set_ylim([0, dataframe["EXX"].max()*1.1])

        ax[0].set_xlabel("Time (s)")
        ax[0].set_ylabel("Strain (mm/mm)")

        ax[1].plot(dataframe["Time"], dataframe["SXX"], label="SXX - Stress", color="blue", linestyle="-")
        ax[1].legend(frameon=True, loc='upper left', fontsize=12, facecolor='white', edgecolor='black')
        ax[1].grid(True)
        if dataframe["SXX"].min() < 0:
            ax[1].set_xlim([dataframe["Time"].min()*1.1, dataframe["Time"].max()*1.1])
        else:
            ax[1].set_xlim([0, dataframe["Time"].max()*1.1])        
        
        if dataframe["SXX"].min() < 0:
            ax[1].set_ylim([dataframe["SXX"].min()*1.1, dataframe["SXX"].max()*1.1])
        else:
            ax[1].set_ylim([0, dataframe["SXX"].max()*1.1])
        ax[1].set_xlabel("Time (s)")
        ax[1].set_ylabel("Stress (MPa)")

    def graph_e_and_sigma(self, dataframe, input_data, savefig_name):
        import matplotlib.pyplot as plt

        ext_data = pd.read_csv(input_data, delimiter=",")
        
        fig, ax = plt.subplots(nrows = 1, 
                               ncols = 1,
                               figsize = (10, 5))
        
        ax.plot(dataframe["EXX"], dataframe["SXX"], label="Simulation", color="green", linestyle="-")
        ax.plot(ext_data["EXX"], ext_data["SXX"], label="Experimental", color="magenta",
               linestyle="None", marker = "x", markerfacecolor='magenta', markeredgecolor = "magenta", markersize = 3)
        ax.legend(frameon=True, loc='upper left', fontsize=12, facecolor='white', edgecolor='black')
        ax.grid(True)

        if dataframe["EXX"].min() < 0:
            ax.set_xlim([dataframe["EXX"].min()*1.1, dataframe["EXX"].max()*1.1])
        else:
            ax.set_xlim([0, dataframe["EXX"].max()*1.1])

        if dataframe["SXX"].min() < 0:
            ax.set_ylim([dataframe["SXX"].min()*1.1, dataframe["SXX"].max()*1.1])
        else:
            ax.set_ylim([0, dataframe["SXX"].max()*1.1])
        ax.set_xlabel("Strain (mm/mm)")
        ax.set_ylabel("Stress (MPa)")

        fig.savefig(savefig_name, dpi = 300, bbox_inches="tight")