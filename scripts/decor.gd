extends Node2D
class_name CBJDecor

var level := 0
var length := 2600.0
var clock := 0.0

func _process(delta: float) -> void:
 clock+=delta
 queue_redraw()

func _draw() -> void:
 var palette = [Color("b6a0a5"),Color("e2c8a5"),Color("78b996"),Color("7083b1"),Color("dba4a4"),Color("829ac1"),Color("c5a179"),Color("d7a4d5")]
 var color: Color=palette[level]
 for i in range(int(length/130.0)+1):
  var x := float(i)*130.0+40.0
  if level==0:
   draw_rect(Rect2(x,320,85,105),Color("624760"))
   draw_rect(Rect2(x+9,333,67,62),color)
   draw_rect(Rect2(x+15,401,55,8),Color("3e2d47"))
  elif level==1:
   draw_rect(Rect2(x,360,110,68),Color("8e6b78"))
   draw_rect(Rect2(x+4,362,102,8),color)
   draw_rect(Rect2(x+18,375,15,24),Color("493b53"))
  elif level==2:
   draw_line(Vector2(x+38,440),Vector2(x+38,250),Color("6e594d"),16)
   draw_circle(Vector2(x+38,260),57,Color("4d8965"))
   draw_circle(Vector2(x+10,288),38,Color("70a878"))
  elif level==3:
   draw_circle(Vector2(x,260),35,Color("47506a"))
   draw_circle(Vector2(x+80,300),43,Color("515778"))
  elif level==4:
   draw_rect(Rect2(x,315,100,115),Color("75546a"))
   draw_rect(Rect2(x+20,335,18,24),Color("efbd8e"))
   draw_rect(Rect2(x+65,335,18,24),Color("efbd8e"))
  elif level==5:
   draw_rect(Rect2(x,290,80,140),Color("354b68"))
   draw_rect(Rect2(x+20,313,10,17),Color("d2b1a6"))
  elif level==6:
   draw_rect(Rect2(x,330,105,100),Color("715b4b"))
   draw_rect(Rect2(x+5,335,95,7),color)
  else:
   draw_rect(Rect2(x,290,75,140),Color("79517d"))
   draw_circle(Vector2(x+35,290),22,Color("f1c56c"))
 for i in range(int(length/160.0)):
  var x := i*160.0+70
  var y := 180.0+sin(i*2.0)*50.0
  var alpha := 0.45+0.4*absf(sin(clock*1.3+i))
  draw_circle(Vector2(x,y),2.5,Color(1,0.86,0.65,alpha))
