#!/usr/bin/env python
import sys
import vtk

rgb = [[50, 1.0, 0.0, 0.0],
      [150, 0.0, 0.0, 1.0]]
opacity = [[0, 0.0],
           [150, 0.2]]

volume = vtk.vtkVolume()
volumeProperty = vtk.vtkVolumeProperty()

def keyPressed(caller, eventId):
  code = caller.GetKeyCode()
  delta = 1
  opdelta = 0.1
  if code == 'o': # o,p control first color value
    rgb[0][0] -= delta
    opacity[0][0] = rgb[0][0]
    print 'rgb[0]',rgb[0][0]
  elif code == 'p':
    rgb[0][0] += delta
    opacity[0][0] = rgb[0][0]
    print 'rgb[0]',rgb[0][0]
  elif code == 'a': # a,s control second color value
    rgb[1][0] -= delta
    opacity[1][0] = rgb[1][0]
    print 'rgb[1]',rgb[1][0]
  elif code == 's':
    rgb[1][0] += delta
    opacity[1][0] = rgb[1][0]
    print 'rgb[1]',rgb[1][0]
  elif code == 'r': # r,t control first opacity value
    opacity[0][1] -= opdelta
    print 'op[0]',opacity[0][1]
  elif code == 't':
    opacity[0][1] += opdelta
    print 'op[0]',opacity[0][1]
  elif code == 'f': # f,g control second opacity value
    opacity[1][1] -= opdelta
    print 'op[1]',opacity[1][1]
  elif code == 'g':
    opacity[1][1] += opdelta
    print 'op[1]',opacity[1][1]
  updateColorOpacity()

def updateColorOpacity():
  opacityFunction = vtk.vtkPiecewiseFunction()
  for op in opacity:
    opacityFunction.AddPoint(op[0], op[1])
  colorFunction = vtk.vtkColorTransferFunction()
  for c in rgb:
    colorFunction.AddRGBPoint(c[0], c[1], c[2], c[3])
  global volumeProperty
  volumeProperty.SetColor(colorFunction)
  volumeProperty.SetScalarOpacity(opacityFunction)
  global volume
  volume.Update()

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
  opacityFunction.AddPoint(150, 0.2)
  # color function
  colorFunction = vtk.vtkColorTransferFunction()
  colorFunction.AddRGBPoint(50, 1.0, 0.0, 0.0)
  colorFunction.AddRGBPoint(150, 0.0, 0.0, 1.0)
  # volume setup:
  #volumeProperty = vtk.vtkVolumeProperty()
  global volumeProperty
  volumeProperty.SetColor(colorFunction)
  volumeProperty.SetScalarOpacity(opacityFunction)
  # composite function (using ray tracing)
  compositeFunction = vtk.vtkVolumeRayCastCompositeFunction()
  volumeMapper = vtk.vtkVolumeRayCastMapper()
  volumeMapper.SetVolumeRayCastFunction(compositeFunction)
  volumeMapper.SetInput(data)
  # make the volume
  #volume = vtk.vtkVolume()
  global volume
  volume.SetMapper(volumeMapper)
  volume.SetProperty(volumeProperty)
  # renderer
  renderer = vtk.vtkRenderer()
  renderWin = vtk.vtkRenderWindow()
  renderWin.AddRenderer(renderer)
  renderInteractor = vtk.vtkRenderWindowInteractor()
  renderInteractor.SetRenderWindow(renderWin)
  renderInteractor.AddObserver( vtk.vtkCommand.KeyPressEvent, keyPressed )
  renderer.AddVolume(volume)
  renderer.SetBackground(0,0,0)
  renderWin.SetSize(400, 400)
  renderInteractor.Initialize()
  renderWin.Render()
  renderInteractor.Start()

if __name__ == '__main__':
  main(sys.argv)
