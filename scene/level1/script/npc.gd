extends CharacterBody2D


const SPEED = 50.0
var TIME = 1200
var cd = TIME
var direction = Vector2()

func get_direction():
	if cd > 0:
		direction.x = 1
	else:
		direction.x = -1
	direction = direction.normalized()
	
func _physics_process(_delta: float) -> void:
	get_direction()
	velocity = direction * SPEED
	change_animation()
	move_and_slide()
	cd -= 1
	if (cd < -TIME):
		cd = TIME
	else:
		cd -= 1
	
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
				
func change_animation():
	if direction.x > 0:
		if $Head.flip_h:
			flip(1, [$Head, $Body, $Foot, null])
	if direction.x < 0:
		if !$Head.flip_h:
			flip(1, [$Head, $Body, $Foot, null])
	if (direction.x != 0 || direction.y != 0):
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("Idle")
