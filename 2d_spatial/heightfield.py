#! /usr/bin/env python
import vtk
import sys

def main(argv):
  if len(argv) < 2:
    print "usage: ",argv[0]," <data.vtk>"
    exit(1)
  data_fn = argv[1]
  reader = vtk.vtkPolyDataReader()
  reader.SetFileName(data_fn)
  reader.Update()
  data = reader.GetOutput()
  #sphere = vtk.vtkSphereSource()

  trianglize = vtk.vtkDelaunay2D()
  trianglize.SetInput(data)
  trianglize.Update()

  
  mapper = vtk.vtkPolyDataMapper()
  #mapper.SetInput(data)
  #mapper.SetInputConnection(reader.GetOutputPort())
  mapper.SetInputConnection(trianglize.GetOutputPort())
  
  actor = vtk.vtkActor()
  actor.SetMapper(mapper)
  
  renderer = vtk.vtkRenderer()
  renderWindow = vtk.vtkRenderWindow()
  renderWindow.SetSize(400,300)
  viewport = [0, 400, 0, 300]
  #renderer.SetViewport(viewport)
  renderWindow.AddRenderer(renderer)

  #sText = vtk.vtkTextSource()
  #sText.SetText("UPPMAX")
  #mText = vtk.vtkPolyDataMapper()
  #mText.SetInputConnection(sText.GetOutputPort())
  ##aText = vtk.vtkActor()
  #aText.SetMapper(mText)
  #renderer.AddActor(aText)
  
  renderer.AddActor(actor)
  renderer.SetBackground(0.4,0.3,0.2)

  interactor = vtk.vtkRenderWindowInteractor()
  interactor.SetRenderWindow(renderWindow)
  
  renderWindow.Render()
  interactor.Start()

if __name__ == "__main__":
  main(sys.argv)
