extends Node2D


var taxi_scene = preload("res://scene/Taxi/Taxi.tscn")
var player_scene = preload("res://scene/Player/Player.tscn")

var player_instance = null
var taxi_instance = null


func add_player(authority_id: int):
	player_instance = player_scene.instantiate()

	player_instance.level = self
	player_instance.name = "Player_" + str(authority_id)
	player_instance.player_id = authority_id
	player_instance.position = Vector2(600, 330)

	add_child(player_instance, true)

func add_taxi(authority_id: int):
	taxi_instance = taxi_scene.instantiate()
	taxi_instance.name = "Taxi_" + str(authority_id)
	taxi_instance.taxi_id = authority_id
	taxi_instance.level = self
	add_child(taxi_instance, true)

func _enter_tree() -> void:
	set_multiplayer_authority(1)

func _ready() -> void:
	MultiplayerManager.level_node = self
	var dict = {}
	if (multiplayer.get_unique_id() == MultiplayerManager.player1_id):
		dict = {
			"command": "spawn_player",
			"authority_id": multiplayer.get_unique_id()
		}
	elif (multiplayer.get_unique_id() == MultiplayerManager.player2_id):
		dict = {
			"command": "spawn_taxi",
			"authority_id": multiplayer.get_unique_id()
		}
	else:
		print("Error: Invalid player ID. Please check the multiplayer setup.")
		return
	MultiplayerManager.receive_message(dict)
	MultiplayerManager.relay_message.rpc_id(1, MultiplayerManager.current_room_id, dict)

func _process(_delta: float) -> void:
	if player_instance == null || taxi_instance == null:
		for child in get_children():
			if typeof(child) == TYPE_OBJECT and child.name.begins_with("Player_"):
				player_instance = child
				break
		if has_node("Taxi"):
			taxi_instance = get_node("Taxi")

func handle_win(winner):
	show_winner.rpc(winner)
	show_winner(winner)

@rpc("any_peer")
func show_winner(winner):
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
	if (multiplayer.get_unique_id() != 1):
		$Camera2D/PauseMenu/MarginContainer/VBoxContainer/Restart.disabled = 1
	get_tree().paused = 1
