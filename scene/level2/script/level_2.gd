extends Node2D

@onready var NpcPath =  $TaxiPark/Path2D/Progression
@onready var NpcPath1 =  $TaxiPark1/Path2D/Progression
@onready var NpcPath2 =  $TaxiPark2/Path2D/Progression
@onready var NpcPath3 =  $TaxiPark3/Path2D/Progression
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	randSpawnNpc()
	$SpawnCd.wait_time = 1

func randSpawnNpc():
	$SpawnCd.start()

func _on_spawn_cd_timeout() -> void:
	var result = randGenNpc()
	var destination
	
	result[0].spawn_npc(result[1])
	var rand 
	while (1):
		rand = rng.randi_range(1, 4)
		match rand:
			1:
				destination = $TaxiPark
			2:
				destination = $TaxiPark1
			3:
				destination = $TaxiPark2
			4:
				destination = $TaxiPark3
		if destination != result[0].get_park():
			break
	result[1].set_destination(destination)

func randGenNpc():
	var rand = rng.randi_range(1, 4)
	var npc
	var npcPath
	match rand:
		1:
			npc = preload("res://scene/level2/sub_scene/Npc.tscn").instantiate()
		2:
			npc = preload("res://scene/level2/sub_scene/Npc1.tscn").instantiate()
		3:
			npc = preload("res://scene/level2/sub_scene/Npc2.tscn").instantiate()
		4:
			npc = preload("res://scene/level2/sub_scene/Npc3.tscn").instantiate()
	rand = rng.randi_range(1, 4)
	match rand:
		1:
			npcPath = NpcPath
		2:
			npcPath = NpcPath1
		3:
			npcPath = NpcPath2
		4:
			npcPath = NpcPath3
		_:
			print("problem")
	return [npcPath, npc]

func handle_win(has_win):
	$Camera2D/G1.visible = 1
	$Camera2D/G1/Status.visible = 1
	if has_win :
		if win_condition():
			$WinAudio.play()
			$Camera2D/G1/Status.text = "YOU WON\n Grade: " + get_grade()
			$Camera2D/G1/WinBg.visible = 1
		else:
			$GameOver.play()
			if $Taxi.broken:
				$Camera2D/G1/Status.text = "GAME OVER\nNon ci paghi neanche i danni"
			else:
				$Camera2D/G1/Status.text = "GAME OVER\nNon ci paghi neanche la benzina"
			$Camera2D/G1/LoseBg.visible = 1
	else:
		$GameOver.play()
		$Camera2D/G1/Status.text = "GAME OVER\nNon c'è bisogno di aggiungere altro"
		$Camera2D/G1/LoseBg.visible = 1
	$Camera2D/PauseMenu.visible = 1
	$Camera2D/PauseMenu/MarginContainer/VBoxContainer/Resume.disabled = 1
	get_tree().paused = 1

func win_condition():
	var cash_out
	
	cash_out = 100 if $Taxi.broken else 50
	if int($Taxi.cash) < cash_out:
		return 0
	return 1

func get_grade():
	var grade
	var cash_out
	
	cash_out = 100 if $Taxi.broken else 50
	if int($Taxi.cash) > cash_out:
		grade = "C"
	if int($Taxi.cash) > cash_out + 20:
		grade = "B"
	if int($Taxi.cash) > cash_out + 50:
		grade = "A"
	if int($Taxi.cash) > cash_out + 80:
		grade = "S"
	return grade
