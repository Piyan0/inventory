extends CanvasLayer

var list= []
func print(t):
  if list.size()>10:
    for i in list:
      i.queue_free()
      
    list= []
  var lbl= $Label.duplicate()
  lbl.text= str(t)
  lbl.show()
  $VBoxContainer.add_child(lbl)
  list.push_back(lbl)
  
