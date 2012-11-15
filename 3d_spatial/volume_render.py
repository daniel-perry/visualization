#!/usr/bin/env python
import sys
import vtk

#skin = 105
skin = 90
#bone = 140
bone = 250
rgb = [[skin, 1.0, 0.0, 0.0], #skin
      [bone, 1.0, 1.0, 1.0]] #bone
opacity = [[skin, 0.1], #skin
           [bone, 1.0]] #bone

volume = vtk.vtkVolume()
volumeProperty = vtk.vtkVolumeProperty()

def keyPressed(caller, eventId):
  code = caller.GetKeyCode()
  delta = 1
  opdelta = 0.01
  if code == 'o': # o,p control first color value
    rgb[0][0] -= delta
    opacity[0][0] = rgb[0][0]
    print 'skin val',rgb[0][0]
  elif code == 'p':
    rgb[0][0] += delta
    opacity[0][0] = rgb[0][0]
    print 'skin val',rgb[0][0]
  elif code == 'a': # a,s control second color value
    rgb[1][0] -= delta
    opacity[1][0] = rgb[1][0]
    print 'bone val',rgb[1][0]
  elif code == 's':
    rgb[1][0] += delta
    opacity[1][0] = rgb[1][0]
    print 'bone val',rgb[1][0]
  elif code == 'r': # r,t control first opacity value
    opacity[0][1] -= opdelta
    print 'skin op',opacity[0][1]
  elif code == 't':
    opacity[0][1] += opdelta
    print 'skin op',opacity[0][1]
  elif code == 'f': # f,g control second opacity value
    opacity[1][1] -= opdelta
    print 'bone op',opacity[1][1]
  elif code == 'g':
    opacity[1][1] += opdelta
    print 'bone op',opacity[1][1]
  updateColorOpacity()

def updateColorOpacity():
  opacityFunction = vtk.vtkPiecewiseFunction()
  opacityFunction.AddPoint(0, 0.0)
  opacityFunction.AddPoint(opacity[0][0]-10, 0.0)
  opacityFunction.AddPoint(opacity[0][0], opacity[0][1]) # skin
  opacityFunction.AddPoint(opacity[1][0], opacity[1][1]) # bone
  #for op in opacity:
  #  print "op",op[0],op[1]
  #  opacityFunction.AddPoint(op[0], op[1])
  colorFunction = vtk.vtkColorTransferFunction()
  colorFunction.AddRGBPoint(0, 0,0,0)
  colorFunction.AddRGBPoint(rgb[0][0]-10, 0,0,0)
  colorFunction.AddRGBPoint(rgb[0][0], rgb[0][1], rgb[0][2], rgb[0][3]) # skin
  colorFunction.AddRGBPoint(rgb[1][0], rgb[1][1], rgb[1][2], rgb[1][3]) # bone
  #for c in rgb:
    #print 'rgb',c[0],c[1],c[2],c[3]
    #colorFunction.AddRGBPoint(c[0], c[1], c[2], c[3])
  global volumeProperty
  volumeProperty.SetColor(colorFunction)
  volumeProperty.SetScalarOpacity(opacityFunction)
  #global volume
  #volume.Update()

def main(argv):
  if len(argv) < 2:
    print "usage:",argv[0]," data.vtk"
    exit(1)
  data_fn = argv[1]
  reader = vtk.vtkStructuredPointsReader()
  reader.SetFileName(data_fn)
  reader.Update()
  data = reader.GetOutput()
  updateColorOpacity()
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
