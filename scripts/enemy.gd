extends Area2D
class_name CBJEnemy

var origin := Vector2.ZERO
var patrol := 100.0
var speed := 65.0
var elapsed := 0.0
var flying := false
var type := "mouse"
var active := true

func _ready() -> void:
 collision_layer = 4
 collision_mask = 2
 var col := CollisionShape2D.new()
 var shape := CircleShape2D.new()
 shape.radius = 17
 col.shape = shape
 add_child(col)
 body_entered.connect(_on_body)
 queue_redraw()

func _physics_process(delta: float) -> void:
 if not active:return
 elapsed += delta
 position.x = origin.x + sin(elapsed*speed/maxf(10.0,patrol))*patrol
 if flying:
  position.y = origin.y + sin(elapsed*2.3)*23
 queue_redraw()

func _draw() -> void:
 var base := Color("c8a2a1")
 if type=="bee":base=Color("f5ce5e")
 if type=="bat":base=Color("796baf")
 if type=="bird":base=Color("94c3d2")
 if type=="dog":base=Color("bd8969")
 if type=="robot":base=Color("a0bdc8")
 draw_circle(Vector2.ZERO,17,base)
 draw_circle(Vector2(-6,-4),3,Color("1d1830"))
 draw_circle(Vector2(6,-4),3,Color("1d1830"))
 draw_line(Vector2(-8,8),Vector2(8,8),Color("47354a"),2)
 if flying:
  draw_arc(Vector2(-15,-12),11,PI,TAU,9,Color("e7d7d5"),3)
  draw_arc(Vector2(15,-12),11,PI,TAU,9,Color("e7d7d5"),3)

func _on_body(body: Node2D) -> void:
 if body is CatPlayer:
  if body.velocity.y>80 and body.global_position.y < global_position.y-9:
   active=false
   body.velocity.y=-280
   queue_free()
  else:
   body.hurt()
