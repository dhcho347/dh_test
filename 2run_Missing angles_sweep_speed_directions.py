# Copyright 2022 NREL

# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# See https://floris.readthedocs.io for documentation

import numpy as np
import matplotlib.pyplot as plt
from floris.tools import FlorisInterface
from floris.tools.optimization.yaw_optimization.yaw_optimizer_scipy import (
    YawOptimizationScipy
)
from floris.tools.optimization.yaw_optimization.yaw_optimizer_sr import (
    YawOptimizationSR
)

"""
This example demonstrates how to perform a yaw optimization for multiple wind directions and wind speed.
First, we initialize our Floris Interface, and then generate a 3 turbine wind farm. Next, we create the yaw optimization object `yaw_opt` and perform the optimization using the SerialRefine method. Finally, we plot the results.
"""

# Load the default example floris object
fi = FlorisInterface("inputs/cc_100mw.yaml") # GCH model matched to the default "legacy_gauss" of V2

# Reinitialize as a 3-turbine farm with range of WDs and 1 WS
D = 126.0 # Rotor diameter for the NREL 5 MW

for ws in np.arange(14.0, 15.0, 1.0): #dh. multiple wind speed
    fi.reinitialize(
        wind_directions=np.arange(224.0, 231.0, 1.0),  #dh. multiple wind directions
        wind_speeds=[ws], 
    )

    # Initialize optimizer object and run optimization using the Serial-Refine method
    yaw_opt = YawOptimizationSR(fi)  #, exploit_layout_symmetry=False)
    #yaw_opt = YawOptimizationScipy(fi)  #, exploit_layout_symmetry=False)
    df_opt = yaw_opt.optimize()

    print("Optimization results:")
    print(df_opt)