#! /usr/bin/env python
import vtk
import sys

def main(argv):
  if len(argv) < 2:
    print "usage: ",argv[0]," <data> [flat]"
    exit(1)
  data_fn = argv[1]
  flat = False
  if len(argv) > 2:
    flat = True
  
  mapper = vtk.vtkPolyDataMapper()
  if data_fn.find('.vtk') != -1:
    reader = vtk.vtkPolyDataReader()
    reader.SetFileName(data_fn)
    reader.Update()
    data = reader.GetOutput()
    trianglize = vtk.vtkDelaunay2D()
    trianglize.SetInput(data)
    trianglize.Update()
    mapper.SetInputConnection(trianglize.GetOutputPort())
  elif data_fn.find('.pgm') != -1:
    reader = vtk.vtkPNMReader()
    reader.SetFileName(data_fn)
    reader.Update()
    data = reader.GetOutput()
    geometry = vtk.vtkImageDataGeometryFilter()
    geometry.SetInputConnection(reader.GetOutputPort())
    geometry.Update()
    if flat:
      merge = vtk.vtkMergeFilter()
      merge.SetGeometry(geometry.GetOutput())
      merge.SetScalars(data)
      mapper.SetInputConnection(merge.GetOutputPort())
    else:
      warp = vtk.vtkWarpScalar()
      warp.SetInputConnection(geometry.GetOutputPort())
      warp.SetScaleFactor(0.3) # looked good
      warp.Update()
      merge = vtk.vtkMergeFilter()
      merge.SetGeometry(warp.GetOutput())
      merge.SetScalars(data)
      mapper.SetInputConnection(merge.GetOutputPort())
  elif data_fn.find('.dcm') != -1:
    reader =vtk.vtkDICOMImageReader()
    reader.SetFileName(data_fn)
    reader.Update()
    data = reader.GetOutput()
    geometry = vtk.vtkImageDataGeometryFilter()
    geometry.SetInput(data)
    geometry.Update()
    if flat:
      mapper.SetInputConnection(geometry.GetOutputPort())
    else:
      warp = vtk.vtkWarpScalar()
      warp.SetInputConnection(geometry.GetOutputPort())
      warp.Update()
      mapper.SetInputConnection(warp.GetOutputPort())
  else:
    print "unrecognized data file:",data_fn
    exit(1)
  
  lut = vtk.vtkLookupTable()
  lut.SetNumberOfColors(10)
  lut.SetHueRange(0.5,0.3)
  lut.SetSaturationRange(0.6,0.5)
  lut.SetValueRange(1.0,0.5)
  lut.Build()

  mapper.ImmediateModeRenderingOff()
  mapper.SetLookupTable(lut)
 
  actor = vtk.vtkActor()
  actor.SetMapper(mapper)
  
  renderer = vtk.vtkRenderer()
  renderWindow = vtk.vtkRenderWindow()
  renderWindow.SetSize(700,700)
  renderWindow.AddRenderer(renderer)
 
  renderer.AddActor(actor)
  renderer.SetBackground(0.4,0.3,0.2)

  interactor = vtk.vtkRenderWindowInteractor()
  interactor.SetRenderWindow(renderWindow)
  
  renderWindow.Render()
  interactor.Start()

if __name__ == "__main__":
  main(sys.argv)
