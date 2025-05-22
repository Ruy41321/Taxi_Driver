extends Node2D

var destination
var wanna_join = false

func set_destination(park):
	destination = park

func flip(direction):
	var flag = 1 if direction == "left" else 0
	$Npc/Head.flip_h = flag
	$Npc/Body.flip_h = flag
	$Npc/Foot.flip_h = flag
	
func jump_in_out():
	if visible:
		$Npc/CollisionShape2D.disabled = 1
		visible = 0
	else:
		$Npc/CollisionShape2D.disabled = 0
		visible = 1
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && body.get_meta("Name") == "Taxi":
		body.call("set_npc", self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D && body.get_meta("Name") == "Taxi":
		body.call("set_npc", null)
