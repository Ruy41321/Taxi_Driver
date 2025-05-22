extends CharacterBody2D

const SPEED = 10.0
const UP = "up"
const DOWN = "down"
const LEFT = "left"
const RIGHT = "right"
var old_direction = Vector2()
var slowdown_fix = 0.4
var slowdown_moltiplicator = 0.1
var last_position = Vector2()
var broken = 0
var curr_direction = ""
@onready var benzineIndicator = $"../BenzineIndicator"
@onready var lancetta = $"../BenzineIndicator/Lancetta"
var benzine = 270
var current_speed
var time = 0
var is_accellerating = 0
var finished = 0
var park: Area2D = null
var npc = null
var npc_in = 0
var cash = 0

func _process(_delta: float) -> void:
	handle_brum_sound()
	update_tachimetro(max(abs(old_direction.x), abs(old_direction.y)))
	update_benzineIndicator()
	if !benzine:
		$"..".handle_win(true)
	if benzine and !broken:
		benzine -= 0.005
	if benzine < 0:
		benzine = 0
	lancetta.rotation_degrees = benzine
	if park && npc && Input.is_action_just_pressed("Interact"):
		if npc_in:
			pull_out()
		else:
			pull_in()
	if time == int(ceil($"../PlayTime".time_left)):
		$"..".handle_win(true)
		
func _physics_process(_delta: float) -> void:
	$"../TimeLeft".text = str(ceil($"../PlayTime".time_left))
	var direction = get_direction()
	apply_slowdown(direction)
	velocity = direction * SPEED
	if (change_animation(direction)):
		old_direction = Vector2()
		return
	move_and_slide()
	is_invested()
	check_collision()
		
func pull_in():
	if npc.wanna_join:
		return
	npc.destination.toggle_marker()
	$CarJoin.play()
	npc.reparent(self)
	set_npc(get_child(-1))
	park.call("set_npc_to_path", null)
	npc.jump_in_out()
	npc_in = 1

func pull_out():
	if park != npc.destination:
		return
	$CarJoin.play()
	park.call("set_npc_to_path", npc)
	npc.jump_in_out()
	npc_in = 0
	add_cash(30)
		
func add_cash(num):
	$CashEarn.play()
	$"../Cash/Add".text = "+ $ " + str(num)
	$"../Cash/Add".start_fade_in()
	cash += num
	$"../Cash/Amount".text = "$ " + str(cash)
	
		
func set_park(val):
	park = val
	
func set_npc(val):
	if !npc_in:
		npc = val
			
func is_invested():
	if max(abs(old_direction.x), abs(old_direction.y)) > 10:
		for i in $ShapeCast.get_collision_count():
			var c  = $ShapeCast.get_collider(i)
			if c is CharacterBody2D && c.get_meta("Name") == "Player" && !finished:
				finished = 1
				$Kill.play()
				player_invested()
				check_collision()
				return 1
	return 0

var Random = RandomNumberGenerator.new()
func handle_brum_sound():
	if broken:
		$BrumAudio.stop()
		return
	if !$CarStarting.playing && !$BrumAudio.playing:
		$BrumAudio.pitch_scale = Random.randf_range(0.9, 1.1)
		$BrumAudio.play()

func player_invested():
	var x = float($"../Player".position.x)
	var y = float($"../Player".position.y)
	get_parent().remove_child($"../Player")
	var bodyPart = preload("res://scene/level1/sub_scene/body_part.tscn").instantiate()
	bodyPart.position = Vector2(x, y)
	get_parent().add_child(bodyPart)
	bodyPart.get_child(0).get_child(0).visible = 1
	bodyPart.get_child(0).get_child(1).disabled = 0
	bodyPart.get_child(1).get_child(0).visible = 1
	bodyPart.get_child(1).get_child(1).disabled = 0
	bodyPart.get_child(2).get_child(0).visible = 1
	bodyPart.get_child(2).get_child(1).disabled = 0
	time = int(ceil($"../PlayTime".time_left)) - 2
	
func update_tachimetro(speed):
	$"../Tachimetro/Lancetta".rotation_degrees = speed
	$"../Tachimetro/Numero".text = str(int(speed))

func update_benzineIndicator():
	if benzine:
		benzine -= 0.003 * (max(abs(old_direction.x), abs(old_direction.y)))
	if benzine <= 270:
		benzineIndicator.texture = ResourceLoader.load("res://assets/benzineIndicator/benzineIndicator270.png")
	if benzine <= 180:
		benzineIndicator.texture = ResourceLoader.load("res://assets/benzineIndicator/benzineIndicator180.png")
	if benzine <= 120:
		benzineIndicator.texture = ResourceLoader.load("res://assets/benzineIndicator/benzineIndicator120.png")
	if benzine <= 90:
		benzineIndicator.texture = ResourceLoader.load("res://assets/benzineIndicator/benzineIndicator90.png")
	if benzine <= 45:
		benzineIndicator.texture = ResourceLoader.load("res://assets/benzineIndicator/benzineIndicator45.png")
	if benzine <= 25:
		benzineIndicator.texture = ResourceLoader.load("res://assets/benzineIndicator/benzineIndicator25.png")	
	
func apply_slowdown(direction):
	var slow_down = 0
	var space = Input.is_action_pressed("ui_slow_down")
	#if !is_accellerating && get_slide_collision_count():
	#	direction.x = 0
	#	direction.y = 0
	if (space):
		slowdown_moltiplicator *= 1.1
		slow_down += slowdown_moltiplicator
	slow_down += slowdown_fix
	if (direction.x != 0):
		if (direction.x < 0):
			slow_down *= -1
		if (abs(direction.x) < abs(slow_down)):
			direction.x = 0
		else:
			direction.x -= slow_down
	if (direction.y != 0):
		if (direction.y < 0):
			slow_down *= -1
		if (abs(direction.y) < abs(slow_down)):
			direction.y = 0
		else:
			direction.y -= slow_down
	slow_down = abs(slow_down)
	old_direction = direction
	if (direction.x == 0 && direction.y == 0):
		slowdown_moltiplicator = 0.1

func get_direction():
	var direction = Vector2()
	if !(broken || $CarStarting.playing || !benzine):
		if (old_direction.y == 0):
			direction.x = Input.get_axis("ui_left", "ui_right")	
		if (old_direction.x == 0):
			direction.y = Input.get_axis("ui_up", "ui_down")
	direction = direction.normalized()
	is_accellerating = max(abs(direction.x), abs(direction.y))
	direction.x += old_direction.x
	direction.y += old_direction.y
	return direction
	
func check_collision():	
	for i in get_slide_collision_count():
		var c  = get_slide_collision(i)
		if c.get_collider() is RigidBody2D: 
			apply_collision(c)
		else:
			if max(abs(old_direction.x), abs(old_direction.y)) > 50:
				is_invested()
				broken = 1
				update_tachimetro(0)
				$AnimatedSprite2D.visible = 0
				if !$AnimatedSprite2D.flip_h:
					$BrokenSprite.flip_h = 1
				$BrokenSprite.visible = 1
				$CrashAudio.play()
				old_direction.x /= 2
				old_direction.y /= 2
				time = int(ceil($"../PlayTime".time_left)) - 1
			elif  max(abs(old_direction.x), abs(old_direction.y)) > 45:
				old_direction.x /= 1.1
				old_direction.y /= 1.1

func apply_collision(c: KinematicCollision2D):
	if c.get_collider().get_meta("Name") == "Birillo":
		c.get_collider().apply_impulse(-c.get_normal() * (abs(old_direction.x) + abs(old_direction.y)))
		old_direction.x /= 2
		old_direction.y /= 2
	elif c.get_collider().get_meta("Name") == "Fuel":
		if max(abs(old_direction.x), abs(old_direction.y)) > 25:
			c.get_collider().call("explode")
			old_direction.x /= 2
			old_direction.y /= 2
			broken = 1
			$Timer.start()
		elif  max(abs(old_direction.x), abs(old_direction.y)) > 20:
				old_direction.x /= 1.1
				old_direction.y /= 1.1
	elif c.get_collider().get_meta("Name") == "Ball":
		pass
	elif c.get_collider().get_meta("Name") == "bodyPart":
		c.get_collider().apply_impulse(-c.get_normal() * (abs(old_direction.x) + abs(old_direction.y)))
		old_direction.x /= 2
		old_direction.y /= 2
		
func flip(h, sprites):
	var i = 0
	if h:
		while(sprites[i]):
			sprites[i].flip_h = !sprites[i].flip_h
			i += 1
	else:
		while(sprites[i]):
			sprites[i].flip_v = !sprites[i].flip_v
			i += 1
				
var last_change = -1
func can_change(dir):
	if curr_direction == dir:
		return 1
	var curr_time = Time.get_ticks_msec()
	if curr_time - last_change < 10:
		return 0
	last_change = Time.get_ticks_msec()
	curr_direction = dir
	return 1

func change_animation(direction):
	if direction.x > 0 && can_change("right"):
		$ShapeCast.rotation_degrees = 270
		$ShapeCast.position.y = 2
		$VerticalShape.disabled = 1
		$HorizontalShape.disabled = 0
		if $AnimatedSprite2D.animation != "horizontal":
			$AnimatedSprite2D.animation = "horizontal"
		if !$AnimatedSprite2D.flip_h:
			flip(1, [$AnimatedSprite2D, null])
	elif direction.x < 0 && can_change("left"):
		$ShapeCast.rotation_degrees = 90
		$ShapeCast.position.y = 2
		$VerticalShape.disabled = 1
		$HorizontalShape.disabled = 0
		if $AnimatedSprite2D.animation != "horizontal":
			$AnimatedSprite2D.animation = "horizontal"
		if $AnimatedSprite2D.flip_h:
			flip(1, [$AnimatedSprite2D, null])
	elif direction.y > 0 && can_change("down"):
		$ShapeCast.rotation_degrees = 0
		$ShapeCast.position.y = 0.3
		$VerticalShape.disabled = 0
		$HorizontalShape.disabled = 1
		if $AnimatedSprite2D.animation != "down":
			$AnimatedSprite2D.animation = "down"
	elif direction.y < 0 && can_change("up"):
		$ShapeCast.rotation_degrees = 180
		$ShapeCast.position.y = 0.3
		$VerticalShape.disabled = 0
		$HorizontalShape.disabled = 1
		if $AnimatedSprite2D.animation != "up":
			$AnimatedSprite2D.animation = "up"
	else:
		return 1
	return 0

var exploded = 0

func _on_timer_timeout() -> void:
	if !exploded:
		$BoomAnimation.play()
		$ExplosionAudio.play()
		exploded = 1
		$Timer.wait_time = 1
		$Timer.start()
	else:
		$"..".handle_win(false)
		get_parent().remove_child(self) 

func _on_play_time_timeout() -> void:
		$"../TimeLeft".text = str(0)
		if !finished:
			$"..".handle_win(true)
	
