extends SceneTree

func _initialize() -> void:
 call_deferred("_run")

func _run() -> void:
 var scene: PackedScene = load("res://scenes/main.tscn")
 if scene == null:
  push_error("Main scene did not load")
  quit(1)
  return
 var root: Node = scene.instantiate()
 get_root().add_child(root)
 await process_frame
 if root.LEVELS.size() != 8:
  push_error("Expected eight levels")
  quit(1)
  return
 for i in range(8):
  root.unlocked = 8
  root._start_level(i)
  await process_frame
  if root.player == null or root.player.cat_id != root.LEVELS[i]["cat"]:
   push_error("Level protagonist mismatch at %d" % i)
   quit(1)
   return
  if root.goal_area == null or root.active_checkpoint_index != 0 or root.collected_count != 0:
   push_error("Level initialization failed at %d" % i)
   quit(1)
   return
  var expected_zones := 2 if i == 6 else (1 if i in [2,4] else 0)
  if root.environmental_zones.size() != expected_zones:
   push_error("Environmental zone count mismatch at %d" % i)
   quit(1)
   return
 # Environment zones must exist on the levels that use them.
 if root.level != 7:
  push_error("Final level was not loaded")
  quit(1)
  return
 # The exit must visibly remain locked until eight objects are collected.
 if root.goal_sign.text != "SAÍDA TRANCADA":
  push_error("Exit must start locked")
  quit(1)
  return
 root.collected_count = root.REQUIRED_SACHES
 root._update_goal_visual()
 if root.goal_sign.text != "SAÍDA ABERTA":
  push_error("Exit did not unlock after required collectibles")
  quit(1)
  return
 root.collected_count = 0
 root._update_goal_visual()
 # The exit must not complete a level until enough sachets are collected.
 root._complete_level()
 if root.phase != "playing":
  push_error("Exit incorrectly opened without required sachets")
  quit(1)
  return
 root._toggle_pause()
 if root.phase != "paused":
  push_error("Pause failed")
  quit(1)
  return
 root._toggle_pause()
 if root.phase != "playing":
  push_error("Resume failed")
  quit(1)
  return
 # A new dialogue should not be cleared by a timer from an older message.
 root._dialogue("Mensagem nova", 0.1)
 if root.notice.text != "Mensagem nova":
  push_error("Dialogue did not update")
  quit(1)
  return
 print("CBJ smoke test passed: 8 levels, characters, goals, pause, dialogue")
 quit(0)
