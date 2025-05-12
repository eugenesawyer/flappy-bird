extends Node

@export var pipe_scene: PackedScene

const SCROLL_SPEED: int = 4
const PIPE_DELAY: int = 100
const PIPE_RANGE: int = 400
var GROUND_HEIGHT: int = 128

var game_running: bool
var game_over: bool
var scroll
var score
var screen_size: Vector2i
var pipes: Array

func _ready():
	screen_size = get_window().size
	new_game()

func _process(delta: float):
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		
		$Ground.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()

func _on_pipe_timer_timeout():
	generate_pipes()
	
func _on_ground_hit():
	$Bird.falling = false
	stop_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	
	$Bird.reset()
	$ScoreLabel.text = "SCORE: 0"
	$GameOver.hide()
	get_tree().call_group("pipes", "queue_free")
	
	get_tree().call_group("pipes", "queue_free") 
	pipes.clear()
	generate_pipes()

func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()

func generate_pipes(): 
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - GROUND_HEIGHT) / 2  + randi_range(-PIPE_RANGE, PIPE_RANGE)
	
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	
	add_child(pipe)
	pipes.append(pipe)

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$Bird.flying = false
	game_running = false
	game_over = true
	$GameOver.show()

func bird_hit():
	$Bird.falling = true
	stop_game()

func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)

func _on_game_over_restart():
	new_game()
