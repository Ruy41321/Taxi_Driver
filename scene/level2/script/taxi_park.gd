extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.get_meta("Name") == "Taxi":
		body.call("set_park", self)
	
func _on_body_exited(body: Node2D) -> void:
	if body.get_meta("Name") == "Taxi":
		body.call("set_park", null)

func set_npc_to_path(npc):
	$Path2D/Progression.set_npc(npc)
	
func toggle_marker():
	$Sprite/Control.visible = !$Sprite/Control.visible
