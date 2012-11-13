#!/usr/bin/env python
import sys
import vtk

def main(argv):
  if len(argv) < 2:
    print "usage:",argv[0]," data.vtk"
    exit(1)
  data_fn = argv[1]
  reader = vtk.vtkStructuredPointsReader()
  reader.SetFileName(data_fn)
  reader.Update()
  data = reader.GetOutput()
  # opacity function
  opacityFunction = vtk.vtkPiecewiseFunction()
  opacityFunction.AddPoint(0, 0.0)
  opacityFunction.AddPoint(50, 0.05)
  opacityFunction.AddPoint(100, 0.1)
  opacityFunction.AddPoint(150, 0.2)
  # color function
  colorFunction = vtk.vtkColorTransferFunction()
  colorFunction.AddRGBPoint(50, 1.0, 0.0, 0.0)
  colorFunction.AddRGBPoint(100, 0.0, 1.0, 0.0)
  colorFunction.AddRGBPoint(150, 0.0, 0.0, 1.0)
  # volume setup:
  volumeProperty = vtk.vtkVolumeProperty()
  volumeProperty.SetColor(colorFunction)
  volumeProperty.SetScalarOpacity(opacityFunction)
  # composite function (using ray tracing)
  compositeFunction = vtk.vtkVolumeRayCastMIPFunction()
  volumeMapper = vtk.vtkVolumeRayCastMapper()
  volumeMapper.SetVolumeRayCastFunction(compositeFunction)
  volumeMapper.SetInput(data)
  # make the volume
  volume = vtk.vtkVolume()
  volume.SetMapper(volumeMapper)
  volume.SetProperty(volumeProperty)
  # renderer
  renderer = vtk.vtkRenderer()
  renderWin = vtk.vtkRenderWindow()
  renderWin.AddRenderer(renderer)
  renderInteractor = vtk.vtkRenderWindowInteractor()
  renderInteractor.SetRenderWindow(renderWin)
  renderer.AddVolume(volume)
  renderer.SetBackground(0,0,0)
  renderWin.SetSize(400, 400)
  renderInteractor.Initialize()
  renderWin.Render()
  renderInteractor.Start()

if __name__ == '__main__':
  main(sys.argv)
