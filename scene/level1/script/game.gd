extends Node2D

func _ready() -> void:
	if (MultiplayerManager.is_host):
		MultiplayerManager.add_player()

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
