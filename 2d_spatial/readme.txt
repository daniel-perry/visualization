# readme.txt - some example commands, how to run the python scripts:

#converting .pts .data to .vtk:
# for 3d usage:
./data2vtk.py data/data_assignment1/assignment1.pts data/data_assignment1/assignment1.data data/data_assignment1/assignment1.vtk
# for flat colormaps
./data2vtk.py data/data_assignment1/assignment1.pts data/data_assignment1/assignment1.data data/data_assignment1/assignment1_flat.vtk flat

# heightfields cmds:
./heightfield.py data/data_assignment1/assignment1.vtk 
./heightfield.py data/data_assignment1/MtHood.pgm

# contour cmds:
# note: to change number of contours, have to edit script..
./contourmaps.py data/data_assignment1/body.vtk
./contourmaps.py data/data_assignment1/brain.vtk
./contourmaps.py data/watermelon/im1.dcm

#colormap cmds:
# flat torso colormap
./colormap.py data/data_assignment1/assignment1_flat.vtk 
# heightfield + colormap
./colormap.py data/data_assignment1/assignment1.vtk 
# flat mt hood colormap
./colormap.py data/data_assignment1/MtHood.pgm flat
# heightfield + colormap
./colormap.py data/data_assignment1/MtHood.pgm

