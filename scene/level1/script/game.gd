extends Node2D


var taxi_scene = preload("res://scene/Taxi/Taxi.tscn")
var player_scene = preload("res://scene/Player/Player.tscn")

var player_instance = null
var taxi_instance = null

func add_player():
	player_instance = player_scene.instantiate()

	player_instance.level = self
	player_instance.name = "Player"
	player_instance.player_id = MultiplayerManager.player_id
	player_instance.position = Vector2(600, 330)

	add_child(player_instance, true)

func add_taxi():
	taxi_instance = taxi_scene.instantiate()
	taxi_instance.name = "Taxi"
	taxi_instance.player_id = 1
	taxi_instance.level = self
	add_child(taxi_instance, true)

func _ready() -> void:
	if (MultiplayerManager.is_host):
		add_player()
		add_taxi()
	if player_instance == null || taxi_instance == null:
		if has_node("Player"):
			player_instance = get_node("Player")
		if has_node("Taxi"):
			taxi_instance = get_node("Taxi")

func handle_win(winner):
	$WinAudio.play()
	$Camera2D/G1vsG2.visible = 1
	if winner == "player":
		$Camera2D/G1vsG2/PlayerLabel.text = "Player Won"
		$Camera2D/G1vsG2/TaxiLabel.text = "Taxi Lost"
	else:
		var temp
		$Camera2D/G1vsG2/PlayerLabel.text = "Player Lost"
		$Camera2D/G1vsG2/TaxiLabel.text = "Taxi Won"
		temp = $Camera2D/G1vsG2/PlayerBg.material
		$Camera2D/G1vsG2/PlayerBg.material = $Camera2D/G1vsG2/TaxiBg.material
		$Camera2D/G1vsG2/TaxiBg.material = temp
	$Camera2D/PauseMenu.visible = 1
	$Camera2D/PauseMenu/MarginContainer/VBoxContainer/Resume.disabled = 1
	get_tree().paused = 1
