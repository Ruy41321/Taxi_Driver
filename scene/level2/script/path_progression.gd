extends PathFollow2D

var SPEED = 0.5
var limit = 1
var npc = null

func _process(delta: float) -> void:
	if !npc:
		return
	if progress_ratio == limit:
		if limit == 0 && npc.wanna_join:
			despawn_npc()
			return
		SPEED *= -1
		change_direction(npc, limit)
		limit = 0 if limit else 1
	progress_ratio += delta * SPEED

func despawn_npc():
	$"../../../HeavyDoor".play()
	remove_child(npc)
	set_npc(null)
	$"../../..".randSpawnNpc()

func spawn_npc(val):
	if val:
		change_direction(val, 0)
		add_child(val)
		$"../../../HeavyDoor".play()
		npc = get_child(-1)
		progress_ratio = 0
		npc.position.x = 0
		npc.position.y = 0

func set_npc(val):
	npc = val
	if npc:
		npc.wanna_join = false
		$"../..".toggle_marker()
		npc.wanna_join = true
		change_direction(npc, 1)
		npc.reparent(self)
		npc = get_child(-1)
		progress_ratio = 1
		npc.position.x = 0
		npc.position.y = 0
		
func change_direction(obj, reverse):
	var direction = get_meta("direction")
	if reverse:
		direction = "right" if get_meta("direction") == "left" else "left"
	obj.call("flip", direction)
	
func get_park():
	return $"../.."
