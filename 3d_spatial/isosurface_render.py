#!/usr/bin/env python
import sys
import vtk

#skin = 105
skin = 100
#skin = 90.0
bone = 140
#bone = 250.0
rgb = [[skin, 1.0, 0.0, 0.0], #skin
      [bone, 1.0, 1.0, 1.0]] #bone
opacity = [[skin, 0.5], #skin
           [bone, 1.0]] #bone

def main(argv):
  if len(argv) < 2:
    print "usage:",argv[0]," data.vtk"
    exit(1)
  data_fn = argv[1]
  reader = vtk.vtkStructuredPointsReader()
  reader.SetFileName(data_fn)
  reader.Update()
  data = reader.GetOutput()
  skin = vtk.vtkMarchingCubes()
  skin.ComputeNormalsOn()
  skin.ComputeGradientsOn()
  skin.SetValue(0, rgb[0][0])
  skin.SetInput(data)
  skin_mapper = vtk.vtkPolyDataMapper()
  skin_mapper.SetInputConnection(skin.GetOutputPort())
  skin_mapper.ScalarVisibilityOff()
  skin_actor = vtk.vtkActor()
  skin_property = vtk.vtkProperty()
  skin_property.SetColor(rgb[0][1], rgb[0][2], rgb[0][3])
  skin_property.SetOpacity(opacity[0][1])
  skin_actor.SetProperty(skin_property)
  skin_actor.SetMapper(skin_mapper)
  bone = vtk.vtkMarchingCubes()
  bone.ComputeNormalsOn()
  bone.ComputeGradientsOn()
  bone.SetValue(0, rgb[1][0])
  bone.SetInput(data)
  bone_mapper = vtk.vtkPolyDataMapper()
  bone_mapper.SetInputConnection(bone.GetOutputPort())
  bone_mapper.ScalarVisibilityOff()
  bone_actor = vtk.vtkActor()
  bone_actor.GetProperty().SetColor(rgb[1][1], rgb[1][2], rgb[1][3])
  bone_actor.GetProperty().SetOpacity(opacity[1][1])
  bone_actor.SetMapper(bone_mapper)
  renderer = vtk.vtkRenderer()
  renderWin = vtk.vtkRenderWindow()
  renderWin.AddRenderer(renderer)
  renderInteractor = vtk.vtkRenderWindowInteractor()
  renderInteractor.SetRenderWindow(renderWin)
  renderer.AddActor(skin_actor)
  #renderer.AddActor(bone_actor)
  renderer.SetBackground(0,0,0)
  renderWin.SetSize(400, 400)
  renderInteractor.Initialize()
  renderWin.Render()
  renderInteractor.Start()

if __name__ == '__main__':
  main(sys.argv)
