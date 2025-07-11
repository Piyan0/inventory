extends CanvasLayer

var cursor_at_id= 0
var can_place= true
var items_reference_for_delete =[]
#0. id, 1.name_ind, 2.name_en
var item_data= [
  [1, 'Kapak', 'Axe'],
  [2, 'Papan', 'Woof'],
  [3, 'Papan', 'Placeholder'],
  [4, 'Placeholder', 'Placeholder'],
  [5, 'Placeholder', 'Placeholder'],
  [6, 'Placeholder', 'Placeholder'],
  
  ]

var item_availabe= [
  
]

var item_placed = 0:
  set(v):

    item_placed= v
    check()

@export_group('Inventory Data')
@export_range(1, 4) var item_slot= 1
@export var items_id= [
  1, 2, 3, 4
  ]
  
var last_dropped_items_id=[]

@export var expected_items= [
  1,2
  ]
var items_in_queue= []
@export_group('')
@export var pointer: TextureRect
@onready var pointer_anim= $TextureRect/AnimationPlayer

@onready var item_place= [
  [false, $HBoxContainer/NinePatchRect2/VBoxContainer2/HBoxContainer2/TextureRect],
  [false ,$HBoxContainer/NinePatchRect2/VBoxContainer2/HBoxContainer2/TextureRect2 ],
  [false,$HBoxContainer/NinePatchRect2/VBoxContainer2/HBoxContainer2/TextureRect3 ],
  [false,$HBoxContainer/NinePatchRect2/VBoxContainer2/HBoxContainer2/TextureRect4 ]
]
@onready var items= [
  $HBoxContainer/NinePatchRect/FlowContainer/TextureRect,
  $HBoxContainer/NinePatchRect/FlowContainer/TextureRect2,
  $HBoxContainer/NinePatchRect/FlowContainer/TextureRect3,
  $HBoxContainer/NinePatchRect/FlowContainer/TextureRect6,
  $HBoxContainer/NinePatchRect/FlowContainer/TextureRect4,
  $HBoxContainer/NinePatchRect/FlowContainer/TextureRect5,
]

@onready var inital_item_active=$HBoxContainer/NinePatchRect/FlowContainer/TextureRect

func play_ready_anim(hide= false, wait_time= 0.0):
  var anim : AnimationPlayer= $AnimationPlayer
  if hide:
    anim.play('hide')
    if wait_time!= 0:
      await get_tree().create_timer(wait_time).timeout
    else:
      await anim.animation_finished
    return
  anim.play('show')
  if wait_time!= 0:
    await get_tree().create_timer(wait_time).timeout
  else:
    await anim.animation_finished

  
func _ready() -> void:
  open_inventory()
    
func open_inventory():
  await play_ready_anim(false, 0.2)
  await get_tree().create_timer(0.4).timeout
  set_up_item.call_deferred()
  pointer.position= items[0].global_position
  for i in item_slot:
    item_place[i][1].show()
func check():
  
  var correct_label= $HBoxContainer/NinePatchRect2/VBoxContainer2/Label
  if item_placed== item_slot:
    if not is_items_valid():
      show_info()
    else:
      show_info(correct_label)
      items_did_valid= true
      set_hint_key_text(KEY_ESCAPE, 'Continue')
  else:
    if warning_showned:
      hide_info()

func is_items_valid():
  var _expected_items= expected_items
  var _items_in_queue= items_in_queue
  _expected_items.sort()
  _items_in_queue.sort()
  return JSON.stringify(_expected_items)== JSON.stringify(_items_in_queue)
  

@export_dir var  item_directory
@export var item_node: PackedScene
var items_did_valid= false

var warning_showned= false
func hide_info(warning=$HBoxContainer/NinePatchRect2/VBoxContainer2/NinePatch):
  warning_showned= false
  var separator= $HBoxContainer/NinePatchRect2/VBoxContainer2/Control
  var height= 10
  
  warning.hide()
  separator.custom_minimum_size.y= height
  separator.show()
  
  var tween= create_tween()
  await tween.tween_property(separator, 'custom_minimum_size:y', 0, 0.2).set_trans(Tween.TRANS_CUBIC).finished


  
  
func show_info(warning=$HBoxContainer/NinePatchRect2/VBoxContainer2/NinePatch):
  warning_showned= true
  var separator= $HBoxContainer/NinePatchRect2/VBoxContainer2/Control
  separator.show()
  var height= 10
  var tween= create_tween()
  await tween.tween_property(separator, 'custom_minimum_size:y', height, 0.2).set_trans(Tween.TRANS_CUBIC).finished

  separator.hide()
  warning.show()

func free_all_item():
  for i in items_reference_for_delete:
    i.queue_free()
    
func set_up_item():
  items_reference_for_delete= []
  last_dropped_items_id= []
  items_did_valid= false
  last_dropped_items_id= []
  item_availabe= []
 # res://inventory/texture/item/Papan.png
  var texture_path= func(item_name):
    return item_directory+'/'+item_name+'.png'
   
  for i in items_id.size():
    var item= get_item(items_id[i])
    var item_name= item[1]
    var texture= load ( texture_path.call(item_name) )
    var ins= item_node.instantiate()
    ins.set_up([texture, item_name, items[i].global_position ] )
    items_reference_for_delete.push_back(ins)
    add_item(ins, item[0])
    add_child(ins)


func delete_item(id, drop= false):
  if drop:
    last_dropped_items_id.push_back(id)
    
  var item= get_avail_item(id)
  if item[4]== 'erased': return
  item[1].queue_free()
  item[4]= 'erased'
  items_id.erase(id)
  

  
func get_avail_item_place():
  for i in item_place:
    if i[0] == false:
      return i
  
func is_item_placed_max():
  return item_placed == item_slot

func get_avail_item(id):
  for i in item_availabe:
    if i[3] == id:
      return i
  
func get_item(id):
  for i in item_data:
    if i[0] == id:
      return i
      
func add_item(node, id):
  item_availabe.push_back([false, node, node.position, id, 'available'])
  
  
  
func change_pointer(node, direction):
  var target = null
  
  match direction:
    'up':
      target= node.get_node(node.focus_neighbor_top)
    'left':
      target= node.get_node(node.focus_neighbor_left)
    'right':
      target= node.get_node(node.focus_neighbor_right)
    'down':
      target= node.get_node(node.focus_neighbor_bottom)
  
  cursor_at_id= items.find(target)
  
  pointer.position= target.global_position
  inital_item_active= target
  pointer_anim.stop()
  pointer_anim.play('idle')
  
func clear_item():
  set_hint_key_text(KEY_ESCAPE, 'Back')
  items_in_queue= []
  item_placed= 0
  can_place= false
  for i in item_place:
    i[0] = false
    
  for i in item_availabe:
    if i[0] == false or i[4]=='erased': continue
  
    await i[1].move(i[2])
    i[0]= false
  can_place= true

var KEY_ESCAPE= 'esc'
var KEY_C= 'c'
var KEY_ENTER= 'enter'

func set_hint_key_text(id, new_txt):
  var hint_keys_lbl= {
    'esc':$HBoxContainer5/HBoxContainer3/Label,
    'c': $HBoxContainer5/HBoxContainer4/Label,
    'enter': $HBoxContainer5/HBoxContainer2/Label,
  }
  
  hint_keys_lbl[id].text= new_txt
  

func _input(event: InputEvent) -> void:
  
  if event.is_action_pressed("square") and item_placed == 0:
    await play_ready_anim(true, 0.2)
    free_all_item()
    return 
    
  if event.is_action_pressed('square') and items_did_valid:
    set_hint_key_text(KEY_ESCAPE, 'Back')
    await play_ready_anim(true, 0.2)
    free_all_item()
    items_did_valid= false
    var correct_label= $HBoxContainer/NinePatchRect2/VBoxContainer2/Label
    for i in items_in_queue:
      delete_item(i)
    items_in_queue= []
    item_placed= 0
    hide_info(correct_label)
    for i in item_place:
      i[0] = false
    
      
    return
      
  if event.is_action_pressed('square'):
    clear_item()
    
  if event.is_action_pressed('circle'):
    if not can_place or is_item_placed_max(): return
    if cursor_at_id > item_availabe.size()-1: return 
    
    set_hint_key_text(KEY_ESCAPE, 'Clear Input')
    
    var item_is_placed= item_availabe[cursor_at_id][0] == true
    var item_not_available= item_availabe[cursor_at_id][4] == 'erased'
    
    if item_is_placed or item_not_available : return
    items_in_queue.push_back(item_availabe[cursor_at_id][3])
    item_placed+= 1
    item_availabe[cursor_at_id][0] = true
    item_availabe[cursor_at_id][1].move(get_avail_item_place()[1].global_position)
    get_avail_item_place()[0] = true
    
  if event.is_action_pressed('tris'):
    delete_item(item_availabe[cursor_at_id][3], true)
    Output.print(last_dropped_items_id)
    
  if event.is_action_pressed('up'):
    change_pointer(inital_item_active, 'up')
  
  elif event.is_action_pressed('down'):
    change_pointer(inital_item_active, 'down')
  
  elif event.is_action_pressed('right'):
    change_pointer(inital_item_active, 'right')
  
  elif event.is_action_pressed('left'):
    change_pointer(inital_item_active, 'left')
  
  
