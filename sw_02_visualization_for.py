import matplotlib.pyplot as plt
import numpy as np
import ast
import pandas as pd

from pathlib import Path
from floris.tools import FlorisInterface
from floris.tools.visualization import visualize_cut_plane
from floris.tools.visualization import plot_rotor_values

fi = FlorisInterface("examples/inputs/gch_60mw.yaml")

wd_array = [270.0]
ws_array = [10.0]
# fi.reinitialize(wind_directions=wd_array, wind_speeds=ws_array)

f = Path('examples\inputs') / 'opti_yawangle_all.xlsx'
optimized_yaw = pd.read_excel(f, index_col=0)
num_ws = len(ws_array)
num_wd = len(wd_array)
num_turbine = 20
yaw_angles = np.zeros((num_wd, num_ws, num_turbine))

for col in optimized_yaw.columns[:23]: #wind speed 3 to 25 (max 23)
    for ix in optimized_yaw.index[:180]: #wind direction 181 to 360 (max 180)
        converted = " ".join(optimized_yaw[col][ix][1:-1].split())
        each_yaw = ast.literal_eval(f'[{converted.replace(" ", ", ")}]')
        yaw_angles[:, :] = np.asarray(each_yaw, dtype='float32')
        fi.reinitialize(wind_directions=[str(ix)], wind_speeds=[str(col)])
        print("Draw Horizontal Plane with ws"+str(col)+'wd'+str(ix))
        horizontal_plane = fi.calculate_horizontal_plane(x_resolution=400, y_resolution=200, height=90.0, yaw_angles=yaw_angles)
        visualize_cut_plane(horizontal_plane, title="Horizontal Plane, WS="+str(col)+", WD="+str(ix))
        plt.savefig(f'graphs_hor\sw_02_wd[{ix}]ws[{col}]horizontal.png',dpi=500)
        fi.calculate_wake(yaw_angles=yaw_angles)
        fig, axes, _ , _ = plot_rotor_values(fi.floris.flow_field.u, wd_index=0, ws_index=0, n_rows=4, n_cols=5, return_fig_objects=True)
        fig.suptitle("Rotor Plane, WS="+str(col)+", WD="+str(ix))
        plt.savefig(f'graphs_rot\sw_02_wd[{ix}]ws[{col}]rotor.png',dpi=500)
        plt.close('all')



# yaw_angles = np.array([[[0.0, 10.9375, 12.5, 14.0625, 10.9375, 0.0, 7.8125, 10.9375, 10.9375, 14.0625, 0.0, 7.8125, 7.8125, 9.375, 10.9375, 0.0, 0.0, 0.0, 0.0, 0.0]]])
# horizontal_plane = fi.calculate_horizontal_plane(x_resolution=400, y_resolution=200, height=90.0, yaw_angles=yaw_angles)

# visualize_cut_plane(horizontal_plane, title="Horizontal Plane, WS="+str(ws_array)+", WD="+str(wd_array))
# plt.savefig('graphs\sw_02_ws'+str(ws_array)+'wd'+str(wd_array)+'horizontal.png',dpi=500)
# fi.calculate_wake(yaw_angles=yaw_angles)
# fig, axes, _ , _ = plot_rotor_values(fi.floris.flow_field.u, wd_index=0, ws_index=0, n_rows=4, n_cols=5, return_fig_objects=True)
# fig.suptitle("Rotor Plane, WS="+str(ws_array)+", WD="+str(wd_array))

# plt.savefig('graphs\sw_02_ws'+str(ws_array)+'wd'+str(wd_array)+'rotor.png',dpi=500)