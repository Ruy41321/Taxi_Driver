extends CharacterBody2D


const SPEED = 100.0
var push_force = 80
var direction = Vector2()
var time = 0

var taxi
var playtime


@export var player_id := 1:
	set(id):
		player_id = id

func _ready() -> void:
	taxi = get_parent().get_parent().get_node("Taxi")
	playtime = get_parent().get_parent().get_node("PlayTime")

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Interact"):
		for i in $ShapeCast.get_collision_count():
			var c  = $ShapeCast.get_collider(i)
			if c is CharacterBody2D && c.get_meta("Name") == "Taxi": 
				jumpOnTaxi()
	if time == int(ceil(playtime.time_left)):
		$"..".handle_win("player")

func _physics_process(_delta: float) -> void:
	var is_running = false
	get_direction()
	is_running = Input.is_action_pressed("ui2_shift")
	velocity = direction * SPEED
	if is_running:
		velocity *= 2
	change_animation(is_running)
	move_and_slide()
	check_collision()
	
func jumpOnTaxi():
	$CarJoin.play()
	taxi.finished = 0
	visible = 0	
	$CollisionShape2D.disabled = 1
	time = int(ceil(playtime.time_left)) - 1
	
func get_direction():
	direction.x = Input.get_axis("ui2_left", "ui2_right")	
	direction.y = Input.get_axis("ui2_up", "ui2_down")	
	direction = direction.normalized()
	
func check_collision():
	for i in get_slide_collision_count():
		var c  = get_slide_collision(i)
		#if c.get_collider().name == "Taxi":
			#$"..".handle_win("player")
		if c.get_collider() is RigidBody2D: 
			apply_collision(c)

func apply_collision(c: KinematicCollision2D):
	if c.get_collider().get_meta("Name") == "Birillo":
		c.get_collider().apply_impulse(-c.get_normal() * (abs(direction.x) + abs(direction.y)))
	if c.get_collider().get_meta("Name") == "Fuel":
		pass
	if c.get_collider().get_meta("Name") == "Ball":
		c.get_collider().apply_impulse(-c.get_normal() * (abs(direction.x) + abs(direction.y)))
	
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
				
func change_animation(is_running):
	if direction.x > 0:
		if $Head.flip_h:
			flip(1, [$Head, $Body, $Foot, null])
	if direction.x < 0:
		if !$Head.flip_h:
			flip(1, [$Head, $Body, $Foot, null])
	if (direction.x != 0 || direction.y != 0):
		if is_running:
			$AnimationPlayer.play("run")
		else:
			$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("Idle")
