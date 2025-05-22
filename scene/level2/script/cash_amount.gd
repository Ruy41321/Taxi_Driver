extends RichTextLabel

var speed = 1
var fade_in_progress = false
var fade_out_progress = false

var time = 0

func start_fade_in():
	fade_in_progress = true
	fade_out_progress = false
	visible = 1
	time = 0

func start_fade_out():
	fade_out_progress = true
	fade_in_progress = false
	time = 0

func _process(delta: float) -> void:
	if fade_in_progress:
		fade_in(delta)
	elif fade_out_progress:
		fade_out(delta)

func fade_in(delta: float) -> void:
	time += delta
	var alpha = clamp(time * speed, 0, 1)
	modulate.a = alpha
	if alpha >= 1:
		fade_in_progress = false  # Terminare il fade-in
		start_fade_out()

func fade_out(delta: float) -> void:
	time += delta
	var alpha = clamp(1 - time * speed, 0, 1)
	modulate.a = alpha
	if alpha <= 0:
		fade_out_progress = false  # Terminare il fade-out
		visible = 0
