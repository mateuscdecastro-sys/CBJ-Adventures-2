extends Node2D

const PlayerScene = preload("res://scripts/player.gd")
const EnemyScene = preload("res://scripts/enemy.gd")
const DecorScene = preload("res://scripts/decor.gd")
const SAVE_PATH = "user://cbj_adventures_v2.json"
const REQUIRED_SACHES := 8
const LEVELS = [
 {"name":"O Mistério da Sala","cat":"ceviche","enemy":"mouse","intro":"Os sachês sumiram! Ceviche encontra pequenas pegadas na sala.","outro":"Ceviche encontrou uma pista! As pegadas levam à cozinha."},
 {"name":"Caos na Cozinha","cat":"bolinha","enemy":"bee","intro":"Bolinha salta pelos armários seguindo um estranho barulho.","outro":"Bolinha descobre uma passagem que leva ao quintal."},
 {"name":"A Selva do Quintal","cat":"januario","enemy":"bird","intro":"Januário corre pelo jardim atrás de um ladrão misterioso.","outro":"O suspeito desaparece em um túnel sob as raízes."},
 {"name":"Túneis Secretos","cat":"ceviche","enemy":"bat","intro":"Ceviche investiga túneis escuros cheios de caminhos secretos.","outro":"Uma etiqueta revela que os sachês foram levados para a cidade."},
 {"name":"Corrida pelos Telhados","cat":"januario","enemy":"bird","intro":"Januário atravessa os telhados para alcançar uma pista distante.","outro":"O rastro termina perto de um depósito iluminado."},
 {"name":"A Cidade Adormecida","cat":"bolinha","enemy":"dog","intro":"Bolinha precisa avançar silenciosamente pelas ruas noturnas.","outro":"Bolinha encontra o endereço do depósito perdido."},
 {"name":"O Depósito Perdido","cat":"ceviche","enemy":"robot","intro":"Ceviche explora caixas e máquinas para abrir o caminho final.","outro":"Os sachês estão aqui! Agora é hora de reunir os amigos."},
 {"name":"O Grande Resgate","cat":"januario","enemy":"robot","intro":"Os três amigos chegaram juntos. Cada um ajudará no resgate!","outro":"Ceviche, Bolinha e Januário recuperaram os sachês!"}
]
const PALETTE = ["#a887a6","#c9a18d","#75ae85","#8492b4","#c28c9d","#7996bc","#b68e69","#d1a2d4"]
var level := 0
var unlocked := 1
var total_saches := 0
var best := {}
var player: CatPlayer
var world: Node2D
var ui: Control
var hud: Label
var notice: Label
var audio: AudioStreamPlayer
var sfx: AudioStreamPlayer
var checkpoint := Vector2(80,395)
var hearts := 3
var collected := 0
var collected_count := 0
var phase := "menu"
var transition_lock := false
var current_width := 2900.0
var pause_button: Button
var touch_controls: Array[Button] = []
var ending_index := 0
var goal_area: Area2D
var goal_art: Polygon2D
var goal_sign: Label
var checkpoint_flags: Array[Polygon2D] = []
var active_checkpoint_index := 0
var pause_overlay: ColorRect
var paused := false
var environmental_zones: Array[Area2D] = []

func _ready() -> void:
 _load_save()
 _show_menu()

func _load_save() -> void:
 if not FileAccess.file_exists(SAVE_PATH):return
 var f := FileAccess.open(SAVE_PATH,FileAccess.READ)
 if f==null:return
 var data = JSON.parse_string(f.get_as_text())
 if data is Dictionary:
  unlocked=clampi(int(data.get("unlocked",1)),1,8)
  total_saches=maxi(0,int(data.get("saches",0)))
  best=data.get("best",{}) if data.get("best",{}) is Dictionary else {}

func _save() -> void:
 var f := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if f!=null:
  f.store_string(JSON.stringify({"unlocked":unlocked,"saches":total_saches,"best":best}))

func _reset_scene() -> void:
 paused=false
 Input.action_release("move_left")
 Input.action_release("move_right")
 Input.action_release("jump")
 for child in get_children():
  remove_child(child)
  child.queue_free()
 touch_controls.clear()
 checkpoint_flags.clear()
 environmental_zones.clear()
 goal_art=null
 goal_sign=null
 transition_lock=false

func _unhandled_input(event: InputEvent) -> void:
 if event.is_action_pressed("pause") and not event.is_echo():
  if phase=="playing" or phase=="paused":
   _toggle_pause()
   get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
 if phase=="playing":
  paused=true
  phase="paused"
  world.process_mode=Node.PROCESS_MODE_DISABLED
  pause_overlay=ColorRect.new()
  pause_overlay.color=Color(0.05,0.04,0.10,0.92)
  pause_overlay.size=Vector2(960,540)
  ui.add_child(pause_overlay)
  _text(pause_overlay,"JOGO PAUSADO",Vector2(323,145),38,Color("ffd47b"))
  _button(pause_overlay,"CONTINUAR",Rect2(340,255,280,64),_toggle_pause)
  _button(pause_overlay,"VOLTAR AO MENU",Rect2(340,341,280,64),_show_menu)
  for action in ["move_left","move_right","jump"]:
   Input.action_release(action)
 elif phase=="paused":
  paused=false
  phase="playing"
  world.process_mode=Node.PROCESS_MODE_INHERIT
  if is_instance_valid(pause_overlay):pause_overlay.queue_free()

func _text(parent: Node, words: String, at: Vector2, size: int=22, color: Color=Color.WHITE) -> Label:
 var l:=Label.new()
 l.text=words
 l.position=at
 l.add_theme_font_size_override("font_size",size)
 l.add_theme_color_override("font_color",color)
 parent.add_child(l)
 return l

func _button(parent: Node, words: String, at: Rect2, fn: Callable) -> Button:
 var b:=Button.new()
 b.text=words
 b.position=at.position
 b.size=at.size
 b.add_theme_font_size_override("font_size",19)
 parent.add_child(b)
 b.pressed.connect(fn)
 return b

func _panel(parent: Node, at: Rect2, color: Color) -> ColorRect:
 var rect:=ColorRect.new()
 rect.position=at.position
 rect.size=at.size
 rect.color=color
 parent.add_child(rect)
 return rect

func _show_menu() -> void:
 phase="menu"
 _reset_scene()
 var layer:=CanvasLayer.new()
 add_child(layer)
 ui=Control.new()
 layer.add_child(ui)
 _panel(ui,Rect2(0,0,960,540),Color("171329"))
 var texture:=TextureRect.new()
 texture.texture=load("res://assets/generated/bg_1.png")
 texture.modulate=Color(1,1,1,.23)
 texture.size=Vector2(960,540)
 ui.add_child(texture)
 _text(ui,"C.B.J ADVENTURES 2.0",Vector2(235,22),39,Color("ffd37c"))
 _text(ui,"A GRANDE AVENTURA DOS SACHÊS",Vector2(296,75),18)
 _text(ui,"🐟 %d sachês     •     %d/8 fases desbloqueadas" % [total_saches,unlocked],Vector2(278,111),20)
 for i in range(8):
  var index:=i
  var x:=50+(i%2)*460
  var y:=160+int(i/2)*81
  var cat_name: String=LEVELS[i]["cat"].capitalize()
  var words: String="%02d  %s  •  %s" % [i+1,LEVELS[i]["name"],cat_name] if i<unlocked else "%02d  🔒 Bloqueada" % [i+1]
  var b:=_button(ui,words,Rect2(x,y,445,64),func():_start_level(index))
  b.disabled=i>=unlocked
 _text(ui,"WASD / setas para mover • Espaço para saltar • Touch no Android",Vector2(148,504),16,Color("d0bedc"))

func _make_solid(rect: Rect2, variant: int=0) -> void:
 var body:=StaticBody2D.new()
 body.position=rect.position+rect.size*.5
 world.add_child(body)
 var col:=CollisionShape2D.new()
 var box:=RectangleShape2D.new()
 box.size=rect.size
 col.shape=box
 body.add_child(col)
 var visual:=Polygon2D.new()
 var h:=rect.size*.5
 visual.polygon=PackedVector2Array([Vector2(-h.x,-h.y),Vector2(h.x,-h.y),Vector2(h.x,h.y),Vector2(-h.x,h.y)])
 visual.color=Color(PALETTE[level]).darkened(.38 if variant==0 else .12)
 body.add_child(visual)
 var top:=Polygon2D.new()
 top.polygon=PackedVector2Array([Vector2(-h.x,-h.y),Vector2(h.x,-h.y),Vector2(h.x,-h.y+7),Vector2(-h.x,-h.y+7)])
 top.color=Color(PALETTE[level]).lightened(.2)
 body.add_child(top)

func _make_collectible(pos: Vector2, rare: bool=false) -> void:
 var area:=Area2D.new()
 area.position=pos
 area.collision_layer=8
 area.collision_mask=2
 world.add_child(area)
 var col:=CollisionShape2D.new()
 var shape:=CircleShape2D.new()
 shape.radius=15 if rare else 12
 col.shape=shape
 area.add_child(col)
 var polygon:=Polygon2D.new()
 polygon.polygon=PackedVector2Array([Vector2(-11,-14),Vector2(11,-14),Vector2(13,11),Vector2(-13,11)])
 polygon.color=Color("f9d36c") if not rare else Color("ff86c1")
 area.add_child(polygon)
 var emblem:=Polygon2D.new()
 emblem.polygon=PackedVector2Array([Vector2(-6,-5),Vector2(6,-5),Vector2(0,6)])
 emblem.color=Color("f39a62")
 area.add_child(emblem)
 area.body_entered.connect(func(body:Node2D):
  if body==player and phase=="playing":
   var value:=5 if rare else 1
   total_saches+=value
   collected+=value
   collected_count+=1
   _sound("collect")
   _save()
   _hud()
   _update_goal_visual()
   if collected_count>=REQUIRED_SACHES and is_instance_valid(goal_area) and goal_area.overlaps_body(player):
    _complete_level()
   if collected_count==REQUIRED_SACHES and phase=="playing":
    _dialogue("Saída liberada! Encontre o portal verde.",3.0)
   area.queue_free()
 )

func _make_enemy(pos:Vector2, kind:String, distance:float=80.0) -> void:
 var enemy:CBJEnemy=EnemyScene.new()
 enemy.position=pos
 enemy.origin=pos
 enemy.patrol=distance
 enemy.speed=65+level*9
 enemy.type=kind
 enemy.flying=kind in ["bee","bird","bat"]
 world.add_child(enemy)

func _make_hazard(pos:Vector2, width:float=50.0) -> void:
 var area:=Area2D.new()
 area.position=pos
 area.collision_layer=4
 area.collision_mask=2
 world.add_child(area)
 var col:=CollisionShape2D.new()
 var box:=RectangleShape2D.new()
 box.size=Vector2(width,18)
 col.shape=box
 area.add_child(col)
 var art:=Polygon2D.new()
 art.polygon=PackedVector2Array([Vector2(-width*.5,9),Vector2(-width*.33,-10),Vector2(-width*.16,9),Vector2(0,-10),Vector2(width*.16,9),Vector2(width*.33,-10),Vector2(width*.5,9)])
 art.color=Color("f07789")
 area.add_child(art)
 area.body_entered.connect(func(body:Node2D):
  if body==player and phase=="playing":player.hurt()
 )

# Environmental interactions. Spring pads launch the cat upward; wind zones
# push the cat horizontally; warehouse belts move the cat while grounded.
func _make_environment_zone(pos: Vector2, size: Vector2, kind: String, strength: float) -> void:
 var area := Area2D.new()
 area.position = pos
 area.collision_layer = 0
 area.collision_mask = 2
 world.add_child(area)
 var collision := CollisionShape2D.new()
 var rect := RectangleShape2D.new()
 rect.size = size
 collision.shape = rect
 area.add_child(collision)
 var art := Polygon2D.new()
 var half := size * 0.5
 art.polygon = PackedVector2Array([Vector2(-half.x,-half.y),Vector2(half.x,-half.y),Vector2(half.x,half.y),Vector2(-half.x,half.y)])
 art.color = Color("f7cb71",0.6) if kind == "spring" else (Color("9ddaf5",0.23) if kind == "wind" else Color("b9a2d6",0.48))
 area.add_child(art)
 if kind != "spring":
  area.set_meta("push_strength", strength)
  area.set_meta("push_kind", kind)
  environmental_zones.append(area)
 if kind == "spring":
  area.body_entered.connect(func(body: Node2D):
   if body == player and phase == "playing" and body.velocity.y >= 0:
    body.velocity.y = -strength
    _dialogue("Super salto!",1.1)
  )

func _make_checkpoint(pos:Vector2, checkpoint_id:int) -> void:
 var area:=Area2D.new()
 area.position=pos
 area.collision_mask=2
 world.add_child(area)
 var col:=CollisionShape2D.new()
 var box:=RectangleShape2D.new()
 box.size=Vector2(38,100)
 col.shape=box
 area.add_child(col)
 var flag:=Polygon2D.new()
 flag.polygon=PackedVector2Array([Vector2(-5,35),Vector2(-5,-46),Vector2(33,-31),Vector2(-5,-16)])
 flag.color=Color("7de2b5")
 area.add_child(flag)
 checkpoint_flags.append(flag)
 area.body_entered.connect(func(body:Node2D):
  if body==player and phase=="playing" and checkpoint_id>active_checkpoint_index:
   active_checkpoint_index=checkpoint_id
   checkpoint=Vector2(pos.x,395)
   _sound("checkpoint")
   for flag_index in range(checkpoint_flags.size()):
    checkpoint_flags[flag_index].color=Color("ffe08a") if flag_index<=active_checkpoint_index-1 else Color("7de2b5")
   _dialogue("Checkpoint ativado!",1.8)
   _hud()
 )

func _make_goal(pos:Vector2) -> void:
 goal_area=Area2D.new()
 goal_area.position=pos
 goal_area.collision_mask=2
 world.add_child(goal_area)
 var shape:=CollisionShape2D.new()
 var rect:=RectangleShape2D.new()
 rect.size=Vector2(64,94)
 shape.shape=rect
 goal_area.add_child(shape)
 goal_art=Polygon2D.new()
 goal_art.polygon=PackedVector2Array([Vector2(-28,-45),Vector2(28,-45),Vector2(28,45),Vector2(-28,45)])
 goal_area.add_child(goal_art)
 goal_sign=Label.new()
 goal_sign.position=Vector2(-45,-80)
 goal_area.add_child(goal_sign)
 _update_goal_visual()
 goal_area.body_entered.connect(func(body:Node2D):
  if body==player and phase=="playing" and not transition_lock:
   if collected_count>=REQUIRED_SACHES:
    _complete_level()
   else:
    _dialogue("Colete mais %d sachês para abrir a saída!" % (REQUIRED_SACHES-collected_count),2.5)
 )

func _update_goal_visual() -> void:
 if not is_instance_valid(goal_art) or not is_instance_valid(goal_sign):return
 var ready:=collected_count>=REQUIRED_SACHES
 goal_art.color=Color("63c9a5") if ready else Color("8a778c")
 goal_sign.text="SAÍDA ABERTA" if ready else "SAÍDA TRANCADA"

func _layout() -> void:
 var widths=[2800,2900,3100,3200,3400,3300,3500,3900]
 current_width=float(widths[level])
 var bg:=Sprite2D.new()
 bg.texture=load("res://assets/generated/bg_%d.png" % (level+1))
 bg.centered=false
 bg.scale=Vector2(current_width/960.0,1.0)
 bg.modulate=Color(1,1,1,.85)
 world.add_child(bg)
 var decor:CBJDecor=DecorScene.new()
 decor.level=level
 decor.length=current_width
 world.add_child(decor)
 # Individual level profiles: varied verticality, distance, obstacles and density.
 var profiles=[
  [Vector2(220,350),Vector2(450,295),Vector2(690,365),Vector2(930,270),Vector2(1180,340),Vector2(1430,280),Vector2(1690,350),Vector2(1950,275),Vector2(2200,345)],
  [Vector2(210,355),Vector2(390,280),Vector2(550,210),Vector2(740,145),Vector2(940,245),Vector2(1160,340),Vector2(1400,240),Vector2(1640,165),Vector2(1900,290),Vector2(2240,350)],
  [Vector2(260,355),Vector2(580,310),Vector2(850,265),Vector2(1150,340),Vector2(1470,235),Vector2(1800,300),Vector2(2110,250),Vector2(2420,345)],
  [Vector2(220,340),Vector2(430,245),Vector2(640,330),Vector2(860,200),Vector2(1080,310),Vector2(1300,175),Vector2(1550,330),Vector2(1790,235),Vector2(2050,325),Vector2(2340,230)],
  [Vector2(320,340),Vector2(670,295),Vector2(1010,340),Vector2(1360,265),Vector2(1720,345),Vector2(2070,275),Vector2(2400,330),Vector2(2740,260)],
  [Vector2(220,365),Vector2(500,300),Vector2(790,360),Vector2(1070,260),Vector2(1360,345),Vector2(1650,240),Vector2(1930,340),Vector2(2230,270),Vector2(2560,350)],
  [Vector2(250,350),Vector2(480,270),Vector2(710,185),Vector2(950,320),Vector2(1200,240),Vector2(1460,155),Vector2(1700,335),Vector2(1950,245),Vector2(2230,175),Vector2(2500,320),Vector2(2790,245)],
  [Vector2(260,340),Vector2(540,245),Vector2(840,335),Vector2(1150,225),Vector2(1470,340),Vector2(1780,245),Vector2(2100,330),Vector2(2430,210),Vector2(2770,340),Vector2(3120,255)]
 ]
 var segments: Array=profiles[level]
 # Interrupted floor segments for selected later levels, with safe jumpable gaps.
 var gaps=[]
 if level in [2,4,5,7]:gaps=[950,1900] if level!=7 else [950,1900,2850]
 var floor_start:float=-120.0
 for gap in gaps:
  _make_solid(Rect2(floor_start,450,float(gap)-floor_start,120))
  _make_hazard(Vector2(float(gap)+57,464),110)
  floor_start=float(gap)+115.0
 _make_solid(Rect2(floor_start,450,current_width-floor_start+200,120))
 var platform_width=140.0 if level in [1,3,6] else 180.0
 for i in range(segments.size()):
  var p:Vector2=segments[i]
  _make_solid(Rect2(p.x,p.y,platform_width,18),1)
  _make_collectible(p+Vector2(platform_width*.5,-27),i%5==4)
  if i%3==1:_make_enemy(Vector2(p.x+platform_width*.5,p.y-43),LEVELS[level]["enemy"],30)
 for i in range(10+level*2):
  var x:=185.0+i*(current_width-350.0)/float(10+level*2)
  _make_collectible(Vector2(x,416))
 for i in range(3+level):
  var x:=430.0+i*(current_width-750.0)/float(3+level)
  _make_enemy(Vector2(x,425),LEVELS[level]["enemy"],minf(90.0,45.0+level*5))
 for i in range(2+int(level/2)):
  _make_hazard(Vector2(750+i*490,442),50)
 # Level-specific environmental obstacles, positioned away from the start.
 if level == 1: # Kitchen: springy cushions below the upper shelves.
  _make_environment_zone(Vector2(620,440),Vector2(95,18),"spring",610.0)
  _make_environment_zone(Vector2(1660,440),Vector2(95,18),"spring",570.0)
 elif level == 2: # Backyard: a gust pushes the cat toward the branches.
  _make_environment_zone(Vector2(1270,370),Vector2(180,125),"wind",125.0)
 elif level == 4: # Rooftops: tailwind rewards momentum.
  _make_environment_zone(Vector2(1550,350),Vector2(180,140),"wind",150.0)
 elif level == 6: # Warehouse: conveyor belts shift the cat sideways.
  _make_environment_zone(Vector2(1060,425),Vector2(240,40),"belt",95.0)
  _make_environment_zone(Vector2(2250,425),Vector2(240,40),"belt",-105.0)
 elif level == 7: # Finale: each cat encounters a spring-assisted section.
  _make_environment_zone(Vector2(1340,440),Vector2(110,18),"spring",570.0)
  _make_environment_zone(Vector2(2710,440),Vector2(110,18),"spring",610.0)
 _make_checkpoint(Vector2(current_width*.47,394),1)
 _make_checkpoint(Vector2(current_width*.78,394),2)
 _make_goal(Vector2(current_width-110,397))

func _start_level(index:int) -> void:
 if index>=unlocked:return
 level=index
 hearts=3
 collected=0
 collected_count=0
 checkpoint=Vector2(80,395)
 active_checkpoint_index=0
 phase="playing"
 _reset_scene()
 world=Node2D.new()
 add_child(world)
 _layout()
 player=PlayerScene.new()
 player.cat_id=LEVELS[level]["cat"]
 player.position=checkpoint
 world.add_child(player)
 player.damaged.connect(_on_damage)
 var cam:=Camera2D.new()
 cam.position_smoothing_enabled=true
 cam.position_smoothing_speed=6
 cam.limit_left=0
 cam.limit_right=int(current_width)
 cam.limit_top=0
 cam.limit_bottom=540
 player.add_child(cam)
 cam.make_current()
 var layer:=CanvasLayer.new()
 add_child(layer)
 ui=Control.new()
 layer.add_child(ui)
 _panel(ui,Rect2(0,0,960,54),Color(0.07,0.05,0.14,.85))
 hud=_text(ui,"",Vector2(20,12),18)
 _button(ui,"PAUSA",Rect2(848,6,100,40),_toggle_pause)
 _touch("◀",Rect2(25,426,104,94),"move_left")
 _touch("▶",Rect2(143,426,104,94),"move_right")
 _touch("PULO",Rect2(798,419,142,102),"jump")
 notice=_text(ui,"",Vector2(135,80),22,Color("ffdc91"))
 _hud()
 _music()
 _dialogue(LEVELS[level]["intro"]+"  Colete 8 sachês para abrir a saída.",4.8)

func _touch(words:String,rect:Rect2,action:String) -> void:
 var b:=Button.new()
 b.text=words
 b.position=rect.position
 b.size=rect.size
 b.modulate.a=.65
 b.mouse_filter=Control.MOUSE_FILTER_STOP
 ui.add_child(b)
 b.button_down.connect(func():Input.action_press(action))
 b.button_up.connect(func():Input.action_release(action))
 touch_controls.append(b)

func _music() -> void:
 audio=AudioStreamPlayer.new()
 add_child(audio)
 var stream:AudioStreamWAV=load("res://assets/audio/theme_%d.wav" % (level+1))
 stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
 audio.stream=stream
 audio.volume_db=-13
 audio.play()
 sfx=AudioStreamPlayer.new()
 add_child(sfx)
 sfx.volume_db=-6

func _sound(name:String) -> void:
 if is_instance_valid(sfx):
  sfx.stream=load("res://assets/audio/%s.wav" % name)
  sfx.play()

func _dialogue(words:String,duration:float=2.8) -> void:
 if not is_instance_valid(notice):return
 notice.text=words
 var this_notice:=notice
 get_tree().create_timer(duration).timeout.connect(func():
  if is_instance_valid(this_notice) and this_notice.text==words:this_notice.text=""
 )

func _hud() -> void:
 if is_instance_valid(hud):
  hud.text="%02d/08  %s   ♥ %d   Sachês %d/%d   Total %d" % [level+1,LEVELS[level]["cat"].capitalize(),hearts,collected_count,REQUIRED_SACHES,total_saches]

func _on_damage() -> void:
 if phase!="playing":return
 hearts-=1
 _sound("hit")
 _hud()
 if hearts<=0:
  hearts=3
  _dialogue("Vamos tentar novamente!",1.8)
 player.global_position=checkpoint
 player.velocity=Vector2.ZERO
 player.invincible=1.6
 _hud()

func _physics_process(_delta:float) -> void:
 if phase!="playing" or not is_instance_valid(player):return
 if player.global_position.y>660:
  _on_damage()
 # Recalculate the effect each physics frame. Enter/exit impulses previously
 # vanished as soon as the player moved and could leave permanent drift.
 var push := 0.0
 for zone in environmental_zones:
  if is_instance_valid(zone) and zone.overlaps_body(player):
   var kind: String = str(zone.get_meta("push_kind"))
   if kind == "wind" or (kind == "belt" and player.is_on_floor()):
    push += float(zone.get_meta("push_strength"))
 player.environmental_push = clampf(push, -240.0, 240.0)
 # Story-controlled protagonist changes during the finale.
 if level==7:
  var fraction:=player.global_position.x/current_width
  var new_cat: String="januario" if fraction<.34 else ("bolinha" if fraction<.68 else "ceviche")
  if new_cat!=player.cat_id:
   player.configure(new_cat)
   _dialogue("Agora é a vez de %s!" % new_cat.capitalize(),2)
   _hud()

func _complete_level() -> void:
 if transition_lock or collected_count<REQUIRED_SACHES:return
 transition_lock=true
 phase="ending"
 player.enabled=false
 player.velocity=Vector2.ZERO
 world.process_mode=Node.PROCESS_MODE_DISABLED
 _sound("win")
 unlocked=maxi(unlocked,mini(level+2,8))
 best[str(level)]=maxi(int(best.get(str(level),0)),collected)
 _save()
 _show_ending()

func _draw_person(parent:Node2D,pos:Vector2,hair:Color,shirt:Color) -> void:
 var torso:=Polygon2D.new()
 torso.position=pos+Vector2(0,20)
 torso.polygon=PackedVector2Array([Vector2(-13,-6),Vector2(13,-6),Vector2(15,28),Vector2(-15,28)])
 torso.color=shirt
 parent.add_child(torso)
 var head:=Polygon2D.new()
 head.position=pos
 head.polygon=PackedVector2Array([Vector2(-11,-14),Vector2(11,-14),Vector2(11,13),Vector2(-11,13)])
 head.color=Color("e9bc98")
 parent.add_child(head)
 var cap:=Polygon2D.new()
 cap.position=pos
 cap.polygon=PackedVector2Array([Vector2(-13,-17),Vector2(13,-17),Vector2(13,-8),Vector2(-13,-8)])
 cap.color=hair
 parent.add_child(cap)

func _show_ending() -> void:
 var overlay:=ColorRect.new()
 overlay.color=Color(0.08,0.06,0.15,.96)
 overlay.size=Vector2(960,540)
 ui.add_child(overlay)
 _text(overlay,"FASE %d CONCLUÍDA!" % (level+1),Vector2(288,65),35,Color("ffd47b"))
 _text(overlay,LEVELS[level]["outro"],Vector2(135,135),20)
 var stage:=Node2D.new()
 stage.position=Vector2(480,310)
 overlay.add_child(stage)
 var floor_art:=Polygon2D.new()
 floor_art.polygon=PackedVector2Array([Vector2(-340,74),Vector2(340,74),Vector2(340,96),Vector2(-340,96)])
 floor_art.color=Color("675179")
 stage.add_child(floor_art)
 # Portraits based on the supplied photograph and approved character concept.
 for human in [{"id":"tamires","name":"Tamires","x":95},{"id":"mateus","name":"Mateus","x":220}]:
  var portrait:=Sprite2D.new()
  portrait.texture=load("res://assets/generated/%s_portrait.png" % human["id"])
  portrait.position=Vector2(human["x"],-3)
  portrait.scale=Vector2(.36,.36)
  portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  stage.add_child(portrait)
  var name_label:=Label.new()
  name_label.text=human["name"]
  name_label.position=Vector2(human["x"]-35,58)
  name_label.add_theme_font_size_override("font_size",15)
  stage.add_child(name_label)
 var cats:Array=[LEVELS[level]["cat"]]
 if level==7:cats=["ceviche","bolinha","januario"]
 for i in range(cats.size()):
  var sprite:=Sprite2D.new()
  sprite.texture=load("res://assets/cats/cat_%s.png" % cats[i])
  sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  sprite.position=Vector2(-120+i*70,50)
  sprite.scale=Vector2(1.65,1.65)
  stage.add_child(sprite)
 _text(overlay,"Reencontro com Tamires e Mateus ♥",Vector2(310,427),23,Color("ffd9ac"))
 _text(overlay,"Sachês nesta fase: %d    •    Total: %d" % [collected,total_saches],Vector2(290,461),18)
 var next_index:=level+1
 var caption:="VER CRÉDITOS" if level==7 else "PRÓXIMA FASE"
 _button(overlay,caption,Rect2(364,495,230,39),func():
  if next_index>=8:_show_credits()
  else:_start_level(next_index)
 )

func _show_credits() -> void:
 phase="credits"
 _reset_scene()
 var layer:=CanvasLayer.new()
 add_child(layer)
 var panel:=Control.new()
 layer.add_child(panel)
 _panel(panel,Rect2(0,0,960,540),Color("241936"))
 _text(panel,"C.B.J ADVENTURES",Vector2(290,70),40,Color("ffd17e"))
 _text(panel,"OS SACHÊS FORAM RESGATADOS!",Vector2(250,146),24)
 _text(panel,"Ceviche, Bolinha e Januário voltaram para casa.",Vector2(185,211),22)
 _text(panel,"Juntos, encontraram Tamires e Mateus e celebraram!",Vector2(180,248),21)
 _text(panel,"Total de sachês: %d" % total_saches,Vector2(360,310),23,Color("ffd17e"))
 _text(panel,"Com amor, Tamires, Mateus e os três gatos ♥",Vector2(250,367),23)
 _button(panel,"VOLTAR AO MENU",Rect2(347,440,266,62),_show_menu)
