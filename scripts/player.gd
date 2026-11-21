extends CharacterBody2D
class_name CatPlayer

signal damaged

const CAT_DATA = {
 "ceviche": {"speed": 230.0, "jump": -385.0},
 "bolinha": {"speed": 210.0, "jump": -440.0},
 "januario": {"speed": 290.0, "jump": -370.0}
}
var cat_id := "ceviche"
var jumps := 0
var coyote := 0.0
var jump_buffer := 0.0
var invincible := 0.0
var animation_clock := 0.0
var sprite: Sprite2D
var visual: Node2D
var enabled := true
# Horizontal environmental velocity is applied continuously while inside zones.
var environmental_push := 0.0

func _ready() -> void:
 collision_layer = 2
 collision_mask = 1
 var collider := CollisionShape2D.new()
 var box := RectangleShape2D.new()
 box.size = Vector2(28, 34)
 collider.shape = box
 add_child(collider)
 visual = Node2D.new()
 add_child(visual)
 sprite = Sprite2D.new()
 sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 sprite.hframes = 8
 sprite.vframes = 5
 sprite.scale = Vector2(1.15,1.15)
 visual.add_child(sprite)
 configure(cat_id)

func configure(id: String) -> void:
 cat_id = id if CAT_DATA.has(id) else "ceviche"
 if sprite != null:
  sprite.texture = load("res://assets/generated/%s_sheet.png" % cat_id)

func _physics_process(delta: float) -> void:
 if not enabled:
  velocity.x = move_toward(velocity.x,0,1600*delta)
  move_and_slide()
  return
 invincible = maxf(0.0, invincible-delta)
 var axis := Input.get_axis("move_left", "move_right")
 var speed: float = CAT_DATA[cat_id]["speed"]
 velocity.x = move_toward(velocity.x, axis*speed + environmental_push, (1550.0 if absf(axis)>0.01 else 2100.0)*delta)
 if absf(axis)>0.01:
  sprite.flip_h = axis<0
 if is_on_floor():
  coyote = 0.12
  jumps = 0
 else:
  coyote = maxf(0.0,coyote-delta)
  velocity.y = minf(velocity.y+1050.0*delta,800.0)
 jump_buffer = maxf(0.0,jump_buffer-delta)
 if Input.is_action_just_pressed("jump"):
  jump_buffer = 0.14
 if jump_buffer>0.0 and (coyote>0.0 or jumps<2):
  velocity.y = CAT_DATA[cat_id]["jump"] * (1.0 if jumps==0 else 0.88)
  jumps += 1
  coyote = 0.0
  jump_buffer = 0.0
 if Input.is_action_just_released("jump") and velocity.y < -120:
  velocity.y *= 0.55
 move_and_slide()
 animation_clock += delta
 var row := 0
 var fps := 3.0
 if not is_on_floor():
  row = 3 if velocity.y<0 else 2
  fps = 8.0
 elif absf(velocity.x)>155:
  row = 1
  fps = 12.0
 elif absf(velocity.x)>12:
  row = 1
  fps = 8.0
 sprite.frame = row*8+int(animation_clock*fps)%8
 sprite.modulate.a = 0.4 if invincible>0.0 and int(invincible*12)%2==0 else 1.0

func hurt() -> void:
 if invincible>0.0 or not enabled:
  return
 invincible = 1.1
 damaged.emit()
