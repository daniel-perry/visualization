#! /usr/bin/env python

import csv
import vtk
import sys

def main(argv):
  if len(argv) < 2:
    print "usage: ",argv[0]," <file.pts> <file.data> <outfile.vtk> [flat]"
    exit(1)
  pts_fn = argv[1]
  data_fn = argv[2]
  out_fn = argv[3]
  flat = False
  if len(argv) > 4:
    flat = True
  pts = csv.reader(open(pts_fn,"r"), delimiter='\n')
  data = csv.reader(open(data_fn,"r"), delimiter='\n')
  points = vtk.vtkPoints()
  values = vtk.vtkDoubleArray()
  values.SetNumberOfComponents(1)
  #grid = vtk.vtkUnstructuredGrid()
  grid = vtk.vtkPolyData()
  for p,d in zip(pts,data):
    p = p[0]
    data = float(d[0])
    parts =  p.split(' ')
    point = []
    for pp in parts:
      if len(pp) > 0:
        point.append(float(pp))
    if flat:
      point[2] = 0.0
    else:
      point[2] = data
    points.InsertNextPoint( point )
    values.InsertNextValue( data )
  grid.SetPoints(points)
  grid.GetPointData().SetScalars(values)
  w = vtk.vtkUnstructuredGridWriter()
  w = vtk.vtkPolyDataWriter()
  w.SetFileName(out_fn)
  w.SetInput(grid)
  w.Update()

if __name__ == "__main__":
  main(sys.argv)
