extends RigidBody2D

var has_explode = 0

func explode():
	if has_explode:
		return
	has_explode = 1
	$Sprite2D.visible = 0
	$CollisionShape2D.disabled = 1
	$BoomAnimation.visible = 1
	$BoomAnimation.play()
	$ExplosionAudio.play()
