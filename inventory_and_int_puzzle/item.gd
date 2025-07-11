extends TextureRect

func move(pos):
  var tween= create_tween()
  tween.tween_property(self, 'position', pos, 0.2).set_trans(Tween.TRANS_CUBIC)
  await tween.finished
#0.texture, 1.text, 2.position
func set_up(data):
  texture= data[0]
  $Label.text= data[1]
  position= data[2]
