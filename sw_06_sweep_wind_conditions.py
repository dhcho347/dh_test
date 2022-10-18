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

#%%
import enum
from math import ceil
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from floris.tools import FlorisInterface
from floris.tools.visualization import visualize_cut_plane
#%%

"""
06_sweep_wind_conditions

This example demonstrates vectorization of wind speed and wind direction.  
When the intialize function is passed an array of wind speeds and an
array of wind directions it automatically expands the vectors to compute
the result of all combinations.

This calculation is performed for a single-row 5 turbine farm.  In addition 
to plotting the powers of the individual turbines, an energy by turbine
calculation is made and plotted by summing over the wind speed and wind direction
axes of the power matrix returned by get_turbine_powers()

"""

# Instantiate FLORIS using either the GCH or CC model
fi = FlorisInterface("examples/inputs/cc_60mw.yaml") # GCH model matched to the default "legacy_gauss" of V2
HH=float(fi.floris.flow_field.reference_wind_height) # for 1
RD=max(fi.floris.farm.rotor_diameters)

# Define a 5 turbine farm
# D = 126.
layout_x = fi.layout_x
layout_y = fi.layout_y
 # layout_x = np.array([0, RD*1, RD*2, RD*3,RD*4])*6 ; print(layout_x)
 # layout_y = np.array(0, 0, 0, 0, 0)
 # fi.reinitialize(layout = [layout_x, layout_y]) 

# Define a ws and wd to sweep 
# Note that all combinations will be computed 
ws_array = np.arange(3, 26, 1.) 
wd_array = np.arange(181,361,1.) #270기준. -20 / +25 
fi.reinitialize(wind_speeds=ws_array, wind_directions=wd_array) 

""" # plot. 1 layout 
fig, ax_list = plt.subplots(3, 1, figsize=(10, 8)) 
ax_list = ax_list.flatten() 
visualize_cut_plane(horizontal_plane, ax=ax_list[0], title="Horizontal") 
visualize_cut_plane(y_plane, ax=ax_list[1], title="Streamwise profile") 
 """
 
# Define a matrix of yaw angles to be all 0 
# Note that yaw angles is now specified as a matrix whose dimesions are 
# wd/ws/turbine 
num_wd = len(wd_array) 
num_ws = len(ws_array) 
num_turbine = len(layout_x) 
yaw_angles = np.zeros((num_wd, num_ws, num_turbine)) 

# Calculate
fi.calculate_wake(yaw_angles=yaw_angles) 

# Collect the turbine powers
turbine_powers = fi.get_turbine_powers() / 1E3 # In kW 
turbine_ais =fi.get_turbine_ais() 
turbine_Cts = fi.get_turbine_Cts() 
turbine_average_velocities  = fi.get_turbine_average_velocities() 

## 3D to 2D array and CSV save (모든 풍속에 대한 풍향/터빈별 값)
# 0: 풍향, 1: 풍속, 2: 터빈
## 0. nparray to csv
farm_WD_WS = np.sum(turbine_powers, axis=(2)); np.savetxt("power_WD_WS.csv",farm_WD_WS, delimiter=',')
ais = np.sum(turbine_ais, axis=(2)); np.savetxt("ais_farm_WD_WS.csv",ais, delimiter=',')
Cts = np.sum(turbine_Cts, axis=(2)); np.savetxt("Cts_farm_WD_WS.csv",Cts, delimiter=',')


## 1. nparray to csv
energy_by_WD_turbine = np.sum(turbine_powers, axis=(1)); np.savetxt("power_WD_Turbine.csv",energy_by_WD_turbine, delimiter=',')
ais = np.sum(turbine_ais, axis=(1)); np.savetxt("ais_WD_Turbine.csv",ais, delimiter=',')
Cts = np.sum(turbine_Cts, axis=(1)); np.savetxt("Cts_WD_Turbine.csv",Cts, delimiter=',')

##3D to 1D array (모든 풍향, 풍속에 대한 터빈별 값)
energy_by_turbine = np.sum(turbine_powers, axis=(0,1)) # Sum over wind direction (0-axis) and wind speed (1-axis)
energy_by_winddirection=np.sum(turbine_powers, axis=(1,2)); np.savetxt("energy_by_winddirection.csv",energy_by_winddirection, delimiter=',')
energy_by_windspeed = np.sum(turbine_powers, axis=(0,2)); np.savetxt("energy_by_windspeed.csv",energy_by_winddirection, delimiter=',')
 
 
""" 
# 2. df to CSV
df_opt.yaw_angles_opt.to_csv('sw08_yaw_'+str(ws)+'_180-270.csv',index=False)
df_opt.to_csv('sw08_'+str(ws)+'__180-270.csv',index=False)
"""

# dh. txt output
f=open("_rst_06.txt","a",encoding="utf8")
print('\n Turbine info. RD={0}, HH={1}, {2}'.format(RD,HH,0),file=f)
print('WD {0} X WS {1} X Turbines {2} '.format(num_wd,num_ws,num_turbine,file=f) )
print('turbine power ={0}'.format(turbine_powers))
print('avg_velocities ={0}'.format(turbine_average_velocities),file=f)
print('Axial induction factor ={0}'.format(turbine_ais),file=f)
print('Thrust coeff ={0}'.format(turbine_Cts),file=f)
#print('Farm power ={0}'.format(farm_power),file=f)



##dh. 여기서 부터는 출력
"""

# Show results by ws and wd
# plot1. # layout
## fig. 평면
horizontal_plane = fi.calculate_horizontal_plane(x_resolution=200, y_resolution=100, height=HH, wd=226)
y_plane = fi.calculate_y_plane(x_resolution=200, z_resolution=100, crossstream_dist=0.0)
cross_plane = fi.calculate_cross_plane(y_resolution=100, z_resolution=100, downstream_dist=630.0)

fig, ax_list = plt.subplots(3, 1, figsize=(10, 8)) 
ax_list = ax_list.flatten() 
visualize_cut_plane(horizontal_plane, ax=ax_list[0], title="Horizontal") 
visualize_cut_plane(y_plane, ax=ax_list[1], title="Streamwise profile") 

# plot2
num_col=2
fig, axarr = plt.subplots(ceil(num_ws/num_col), num_col, sharex=True,sharey=True,figsize=(6,10)) 
axarr = axarr.flatten() 
for ws_idx, ws in enumerate(ws_array): # speed
    ax = axarr[ws_idx] 
    for t in range(num_turbine):
        ax.plot(wd_array, turbine_powers[:,ws_idx,t].flatten(),label='T%d' % t) 
    ax.legend() 
    ax.grid(True)
    ax.set_title('Wind Speed = %.1f' % ws)
    ax.set_ylabel('Power (kW)')
ax.set_xlabel('Wind Direction (deg)')
# turbinePower [WD, WS, turbine]

# Sum across wind speeds and directions to show energy produced 
# by turbine as bar plot
# 풍속 3개 통합 출력량
print(turbine_powers.shape) # 3D array [WD, WS, turbine]
##3D to 1D array
energy_by_turbine = np.sum(turbine_powers, axis=(0,1)) # Sum over wind direction (0-axis) and wind speed (1-axis)
tmp=energy_by_winddirection = np.sum(turbine_powers, axis=(1,2)); np.savetxt(tmp+".csv",tmp, delimiter=',')
tmp=energy_by_windspeed = np.sum(turbine_powers, axis=(0,2)); np.savetxt(tmp+".csv",tmp, delimiter=',')
# np.savetxt("powerbyWS.csv",energy_by_windspeed, delimiter=',')
# np.savetxt("powerbyTurbine.csv",energy_by_turbine, delimiter=',')

#plot3
# By turbine
fig, ax = plt.subplots()
ax.bar(['T%d' % t for t in range(num_turbine)],energy_by_turbine)
ax.set_title('Energy Produced by Turbine')

#plot4
# by wind direction
fig, ax = plt.subplots()
ax.plot(wd_array,energy_by_winddirection, color='r',label='All Turbine')
ax.set_title('Energy Produced by WindDirection')
plt.show()

"""
