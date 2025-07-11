extends CanvasLayer

var current_answer = [0,0,0,0]
var current_arrow_id = 0

@export var expected_answer : Array [int]= [1, 2 ,3 ,4]
@onready var arrows = [
  [
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer/Control/TextureRect2,
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer/Control2/TextureRect3
  ],[
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer2/Control/TextureRect2,
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer2/Control2/TextureRect3
  ],[
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer3/Control/TextureRect2,
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer3/Control2/TextureRect3
  ],[
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer4/Control/TextureRect2,
    $NinePatchRect/NinePatchRect2/HBoxContainer/VBoxContainer/VBoxContainer4/Control2/TextureRect3
  ]
]
@onready var labels = [
  $NinePatchRect/VBoxContainer/Label,
  $NinePatchRect/VBoxContainer/Label2,
  $NinePatchRect/VBoxContainer/Label3,
  $NinePatchRect/VBoxContainer/Label4
]

func _ready() -> void:
  open_puzzle()

func open_puzzle():
  update_arrows_pos()
  update_current_answer()

func update_arrows_pos():
  for i in arrows:
    for j in i:
      j.hide()
  for i in arrows[current_arrow_id]:
    i.show()
    
func update_current_answer():
  for i in 4:
    labels[i].text = str( current_answer[i] )

func modify_answer(add_by, id):
  current_answer[id] += add_by
  current_answer[id] = clamp(current_answer[id], 0, 9)
  update_current_answer()
  
func answer_correct():
  return JSON.stringify(expected_answer) == JSON.stringify(current_answer)
func _input(event: InputEvent) -> void:
  if event.is_action_pressed('circle'):
    if answer_correct():
      Output.print('benar')
    else:
      Output.print('Salah')
    return
  if event.is_action_pressed("left"):
    current_arrow_id-=1
    current_arrow_id= clamp(current_arrow_id, 0, 3)
    update_arrows_pos()
  if event.is_action_pressed("right"):
    current_arrow_id+=1
    current_arrow_id= clamp(current_arrow_id, 0, 3)
    update_arrows_pos()
  
  if event.is_action_pressed('up'):
    modify_answer(1, current_arrow_id)
    set_process_input(false)
    var active_arrow= arrows[current_arrow_id][0]
    var anim = active_arrow.get_parent().get_parent().get_node('AnimationPlayer')
    anim.play('up_hit')
    active_arrow.modulate= Color('#64bd00')
    await get_tree().create_timer(0.1).timeout
    active_arrow.modulate= Color('#3b3456')
    
    set_process_input(true)
    
  if event.is_action_pressed('down'):
    modify_answer(-1, current_arrow_id)
    set_process_input(false)
    var active_arrow= arrows[current_arrow_id][1]
    var anim = active_arrow.get_parent().get_parent().get_node('AnimationPlayer')
    anim.play('down_hit')
    active_arrow.modulate= Color('#64bd00')
    await get_tree().create_timer(0.1).timeout
    active_arrow.modulate= Color('#3b3456')
    
    set_process_input(true)
